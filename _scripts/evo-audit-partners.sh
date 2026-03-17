#!/usr/bin/env bash
set -euo pipefail

ROOT="/home/evo"
OUT_DIR="$ROOT/_logs/audit_runs"
PROMPT_FILE="/tmp/agent_audit_prompt.txt"
KIMI_CONFIG_FILE="${KIMI_CONFIG_FILE:-$HOME/.kimi/config.toml}"

# MIGRATION BRIDGE — remove after workspace migration is complete.
# `/home/evo` is already a directory, so we cannot replace it with a symlink.
# Provide a stable bridge path so legacy `/home/evo` references can still resolve
# during phased migration and tool handoffs.
if [ ! -e "$ROOT/evo" ]; then
  ln -s /home/evo "$ROOT/evo" 2>/dev/null || true
fi

# Model defaults (operator-overridable via env vars)
KIMI_MODEL="${KIMI_AUDIT_MODEL:-kimi-code/kimi-for-coding}"
GEMINI_MODEL="${GEMINI_AUDIT_MODEL:-gemini-2.5-pro}"
GLM_MODEL="${GLM_AUDIT_MODEL:-z-ai/glm-4.7-flash}"
GROQ_MODEL="${GROQ_AUDIT_MODEL:-openai/gpt-oss-120b}"
ANTHROPIC_MODEL="${ANTHROPIC_AUDIT_MODEL:-claude-sonnet-4-20250514}"
CODEX_MODEL="${CODEX_AUDIT_MODEL:-gpt-5.3-codex}"

# Per-auditor enable flags
KIMI_ENABLED="${KIMI_AUDIT_ENABLED:-1}"
GEMINI_ENABLED="${GEMINI_AUDIT_ENABLED:-1}"
GLM_ENABLED="${GLM_AUDIT_ENABLED:-1}"
GROQ_ENABLED="${GROQ_AUDIT_ENABLED:-1}"
ANTHROPIC_ENABLED="${ANTHROPIC_AUDIT_ENABLED:-1}"
CODEX_ENABLED="${CODEX_AUDIT_ENABLED:-1}"

# Per-auditor timeouts (seconds)
KIMI_TIMEOUT_SECONDS="${KIMI_AUDIT_TIMEOUT_SECONDS:-180}"
GEMINI_TIMEOUT_SECONDS="${GEMINI_AUDIT_TIMEOUT_SECONDS:-180}"
GLM_TIMEOUT_SECONDS="${GLM_AUDIT_TIMEOUT_SECONDS:-180}"
GROQ_TIMEOUT_SECONDS="${GROQ_AUDIT_TIMEOUT_SECONDS:-180}"
ANTHROPIC_TIMEOUT_SECONDS="${ANTHROPIC_AUDIT_TIMEOUT_SECONDS:-180}"
CODEX_TIMEOUT_SECONDS="${CODEX_AUDIT_TIMEOUT_SECONDS:-240}"

# GLM routing mode:
# - auto: prefer explicit direct command, otherwise use kimi model routing
# - direct: require explicit direct command only
# - kimi: force kimi model routing for GLM
GLM_ROUTE="${GLM_AUDIT_ROUTE:-auto}"
GLM_DIRECT_CMD="${GLM_DIRECT_CMD:-/home/evo/_scripts/evo-glm-direct.sh}"
GLM_ROUTE_USED="unknown"
GROQ_DIRECT_CMD="${GROQ_DIRECT_CMD:-/home/evo/_scripts/evo-groq-direct.sh}"
ANTHROPIC_DIRECT_CMD="${ANTHROPIC_DIRECT_CMD:-/home/evo/_scripts/evo-anthropic-direct.sh}"
LOW_TRUST_AUDIT_MODE="${LOW_TRUST_AUDIT_MODE:-general}"
GROQ_AUDIT_PROFILE="${GROQ_AUDIT_PROFILE:-watchdog}"

usage() {
  cat <<'USAGE'
Usage: evo-audit-partners.sh [YYYY-MM-DD]
       evo-audit-partners.sh --date YYYY-MM-DD
       evo-audit-partners.sh --date=YYYY-MM-DD
       evo-audit-partners.sh --help

Runs first-level partner audits (Kimi, Gemini, GLM, Groq, Anthropic, Codex) and writes:
- per-partner reports under /home/evo/_logs/audit_runs/
- a rollup of RED_FLAG/ALERT signals for operator adjudication

This runner does not hard-pass or hard-fail readiness.

Useful env controls:
- KIMI_AUDIT_ENABLED=0|1 (same pattern for GEMINI/GLM/CODEX)
- KIMI_AUDIT_TIMEOUT_SECONDS=180 (same pattern for GEMINI/GLM/CODEX)
- GLM_AUDIT_ROUTE=auto|direct|kimi
- GLM_DIRECT_CMD='your direct GLM command using $AUDIT_PROMPT'
- LOW_TRUST_AUDIT_MODE=general|focused (applies to GLM + Groq)
- GROQ_AUDIT_PROFILE=watchdog|general (default: watchdog)
USAGE
}

is_enabled() {
  case "${1:-1}" in
    1|true|TRUE|yes|YES|on|ON) return 0 ;;
    *) return 1 ;;
  esac
}

DATE_TAG=""
while [ $# -gt 0 ]; do
  case "$1" in
    -h|--help)
      usage
      exit 0
      ;;
    --date)
      shift
      if [ $# -eq 0 ]; then
        echo "❌ --date requires a value"
        usage
        exit 1
      fi
      DATE_TAG="$1"
      ;;
    --date=*)
      DATE_TAG="${1#*=}"
      ;;
    -*)
      echo "❌ unknown flag: $1"
      usage
      exit 1
      ;;
    *)
      if [ -z "$DATE_TAG" ]; then
        DATE_TAG="$1"
      else
        echo "❌ unexpected argument: $1"
        usage
        exit 1
      fi
      ;;
  esac
  shift
done

[ -n "$DATE_TAG" ] || DATE_TAG="$(date +%F)"

DEFAULT_PROMPT="Audit /home/evo as an independent first-level reviewer.

Rules:
- Use actual checks/inspection, not assumptions.
- Scope: /home/evo only, including root env governance at /home/evo/.env.
- No code changes. Read-only audit.

Run checks for:
1) Gate health (just check)
2) Env governance (verify /home/evo/.env is the canonical root env and matches current workspace policy)
3) Documentation integrity (Context Chain and registration for key docs)
4) Script/workflow integrity (Justfile + _scripts/evo-check.sh + audit helper scripts)
5) Transition logging completeness
6) Residual risk/security issues still open

Output only markdown with these sections:
- Scores (0-10 for each criterion + total /60)
- Findings
- Red Flags (hard blockers)
- Alerts (non-blocking)
- Next Actions

For machine-readable signals:
- Prefix each hard blocker line with exactly: RED_FLAG:
- Prefix each non-blocking line with exactly: ALERT:"

if [ -f "$PROMPT_FILE" ]; then
  PROMPT="$(cat "$PROMPT_FILE")"
else
  PROMPT="$DEFAULT_PROMPT"
fi

LOW_TRUST_EVIDENCE_GUARDRAILS="Evidence requirements (mandatory):
- Every finding must include at least one concrete file path and line reference.
- If evidence is missing, write exactly: UNVERIFIED: <claim>.
- Do not claim tools/tests ran unless output is shown in this run.
- Keep findings limited to observed code/config/log behavior."

prompt_for_low_trust() {
  local partner="$1"
  local lens=""
  if [ "$LOW_TRUST_AUDIT_MODE" != "focused" ]; then
    printf '%s\n' "$PROMPT"
    return
  fi

  case "$partner" in
    "GLM")
      lens="Partner lens: Correctness + runtime safety reviewer.
- Focus on real runtime failures, type/build breakage, and data-loss/security risks.
- Prioritize issues that would break production behavior."
      ;;
    "Groq")
      lens="Partner lens: Data-contract and workflow drift reviewer.
- Focus on schema/CSV/type mismatches, path validity, and doc-vs-code drift.
- Avoid broad architecture claims outside directly cited files."
      ;;
    *)
      lens="Partner lens: Focused reviewer."
      ;;
  esac

  printf '%s\n\n%s\n\n%s\n' "$PROMPT" "$lens" "$LOW_TRUST_EVIDENCE_GUARDRAILS"
}

prompt_for_groq() {
  if [ "$GROQ_AUDIT_PROFILE" = "general" ]; then
    printf '%s\n' "$PROMPT"
    return
  fi

  cat <<EOF
Groq Watchdog Audit - Vibe-Code Structural Trap Detection

Purpose:
- Deterministic trap detection only.
- No architecture critique.
- No speculation.
- Binary outcomes only.

Scope prompt:
$PROMPT

Output format (strict):
1) CHECK RESULTS
2) MUST_MIGRATE_ENDPOINTS
3) HARD BLOCKERS
4) NON-BLOCKING ALERTS
5) TOP 5 FIXES

Status vocabulary:
- PASS
- FAIL
- UNVERIFIED

Evidence requirements (mandatory for each FAIL):
- CHECK_ID
- FILE
- LINE_RANGE
- CODE_SNIPPET
- IMPACT
- FIX

If unsupported by provided evidence, output exactly: UNVERIFIED

Checks:
CONTRACT_001 CSV headers must exactly match TypeScript interface fields.
CONTRACT_002 API response keys must exactly match TypeScript types.
CONTRACT_003 Enum values in code must match documented allowed values.
CONTRACT_004 Derived/mapped fields must be documented in contract layer.
CONTRACT_005 Documentation paths/filenames must resolve to real files.

COUPLING_001 Detect hardcoded ID business logic (if id == "...").
COUPLING_002 Detect runtime mirroring between unrelated entities.
COUPLING_003 Detect cross-entity mutation in UI/component layer.
COUPLING_004 Detect duplicated transformation logic across files.
COUPLING_005 Critical field source of truth: UNKNOWN | FILE | SERVICE.

DEVOPS_001 Detect Vite/dev middleware endpoints (/__*).
DEVOPS_002 Detect filesystem writes inside middleware/runtime handlers.
DEVOPS_003 Detect localhost/loopback assumptions.
DEVOPS_004 Detect server-side behavior embedded in client/runtime path.
DEVOPS_005 Dev-only routes lacking production equivalents.

ERROR_001 Detect catch {}.
ERROR_002 Detect log-only catch without handling.
ERROR_003 Detect async writes/network calls without error handling.
ERROR_004 Detect storage writes without failure signal/confirmation.
ERROR_005 Detect fallback behavior that can overwrite/discard user state.

PATH_001 Detect Unix absolute paths (/home/...).
PATH_002 Detect Windows absolute paths (C:\\...).
PATH_003 Detect hardcoded project-directory paths.
PATH_004 Detect non-configurable paths lacking env/base abstraction.
For PATH_004 include: REPLACE_WITH: RELATIVE_PATH | ENV_ROOT

STATE_001 Detect critical state stored only in localStorage.
STATE_002 Detect unvalidated storage writes.
STATE_003 Detect state restore without schema validation.
STATE_004 Detect missing migration/versioning for persisted state.

MEMORY_001 Detect URL.createObjectURL without URL.revokeObjectURL.
MEMORY_002 Detect unremoved event listeners.
MEMORY_003 Detect timers/intervals without cleanup.

TS_001 Detect @ts-ignore.
TS_002 Detect excessive any.
TS_003 Detect unsafe casts (as unknown as / risky assertions).
TS_004 Detect disabled/relaxed type checks in config.

ENV_001 Detect missing required environment variables.
ENV_002 Detect defaults masking misconfiguration (process.env.X || "").
ENV_003 Detect env logic embedded in app code where config layer expected.

BUILD_001 Detect build dependency on local files not in repo.
BUILD_002 Detect scripts referencing external directories.
BUILD_003 Detect machine-specific build assumptions/config drift.

DIFF_001 (optional) If diff context is provided, limit checks to changed files.

Rules:
- No references to files not provided in evidence context.
- Unsupported claims must be UNVERIFIED.
- Keep findings concise and evidence-backed.
EOF
}

mkdir -p "$OUT_DIR"

declare -a PARTNER_STATUS=()
declare -a RED_FLAGS=()
declare -a ALERTS=()
declare -a ROUTER_CHECKS=()

KIMI_OUT="$OUT_DIR/KIMI_AUDIT_${DATE_TAG}.md"
GEMINI_OUT="$OUT_DIR/GEMINI_AUDIT_${DATE_TAG}.md"
GLM_OUT="$OUT_DIR/GLM_AUDIT_${DATE_TAG}.md"
GROQ_OUT="$OUT_DIR/GROQ_AUDIT_${DATE_TAG}.md"
ANTHROPIC_OUT="$OUT_DIR/ANTHROPIC_AUDIT_${DATE_TAG}.md"
CODEX_OUT="$OUT_DIR/CODEX_AUDIT_${DATE_TAG}.md"
ROLLUP_OUT="$OUT_DIR/AUDIT_SIGNAL_ROLLUP_${DATE_TAG}.md"

sanitize_output_file() {
  local output_file="$1"
  # Prevent gate failures from leaked absolute host paths in tool stack traces.
  sed -i 's#/home/evo/#/home/evo_redacted/#g' "$output_file" || true
}

check_provider_routes() {
  if [ "$GLM_ROUTE" = "direct" ]; then
    ROUTER_CHECKS+=("GLM direct route selected; Kimi config verification skipped.")
    return
  fi

  if [ ! -f "$KIMI_CONFIG_FILE" ]; then
    ROUTER_CHECKS+=("Kimi/GLM provider config not found; route verification skipped.")
    ALERTS+=("[Routing] provider route verification skipped (config missing).")
    return
  fi

  if rg -q '^\[providers\."managed:kimi-code"\]' "$KIMI_CONFIG_FILE" \
    && rg -q '^type = "kimi"$' "$KIMI_CONFIG_FILE" \
    && rg -q '^base_url = "https://api\.kimi\.com/coding/v1"$' "$KIMI_CONFIG_FILE"; then
    ROUTER_CHECKS+=("Kimi model route verified: managed:kimi-code -> type=kimi -> api.kimi.com/coding/v1.")
  else
    ROUTER_CHECKS+=("Kimi model route could not be verified from config.")
    ALERTS+=("[Kimi] route verification failed; check provider mapping.")
  fi

  if rg -Fq "[models.\"${GLM_MODEL}\"]" "$KIMI_CONFIG_FILE" \
    && rg -q '^provider = "z-ai-api"$' "$KIMI_CONFIG_FILE" \
    && rg -q '^\[providers\."z-ai-api"\]' "$KIMI_CONFIG_FILE" \
    && rg -q '^base_url = "https://api\.z\.ai/api/paas/v4"$' "$KIMI_CONFIG_FILE"; then
    ROUTER_CHECKS+=("GLM model mapping verified: ${GLM_MODEL} -> provider z-ai-api -> api.z.ai.")
  else
    ROUTER_CHECKS+=("GLM model mapping could not be verified from config for ${GLM_MODEL}.")
    ALERTS+=("[GLM] route verification failed for ${GLM_MODEL}; check z-ai mapping.")
  fi
}

collect_signals() {
  local partner="$1"
  local status="$2"
  local output_file="$3"
  local line body

  if [ "$status" != "SUCCESS" ]; then
    ALERTS+=("[$partner] auditor command did not complete successfully.")
  fi

  while IFS= read -r line; do
    body="${line#*RED_FLAG:}"
    body="$(echo "$body" | sed 's/^[[:space:]]*//')"
    [ -n "$body" ] && RED_FLAGS+=("[$partner] $body")
  done < <(rg -i '^\s*RED_FLAG:' "$output_file" 2>/dev/null || true)

  while IFS= read -r line; do
    body="${line#*ALERT:}"
    body="$(echo "$body" | sed 's/^[[:space:]]*//')"
    [ -n "$body" ] && ALERTS+=("[$partner] $body")
  done < <(rg -i '^\s*ALERT:' "$output_file" 2>/dev/null || true)
}

write_report() {
  local partner="$1"
  local model="$2"
  local outfile="$3"
  local status="$4"
  local details="$5"
  local output_file="$6"

  {
    echo "# ${partner} Audit ${DATE_TAG}"
    echo
    echo "- Partner: \`${partner}\`"
    echo "- Model: \`${model}\`"
    echo "- Date: \`${DATE_TAG}\`"
    echo "- Workspace: \`${ROOT}\`"
    echo "- Status: \`${status}\`"
    echo
    echo "## Execution"
    echo
    echo "${details}"
    echo
    if [ -s "$output_file" ]; then
      echo "## Model Output"
      echo
      cat "$output_file"
      echo
    fi
    echo "## Context Chain"
    echo "← inherits from: /home/evo/AGENTS.md"
    echo "→ overrides by: none"
    echo "→ live map: /home/evo/AI_SESSION_BOOTSTRAP.md"
    echo "→ conventions: /home/evo/DNA/ops/CONVENTIONS.md"
  } > "$outfile"
}

run_partner() {
  local partner="$1"
  local model="$2"
  local outfile="$3"
  local timeout_sec="$4"
  shift 4

  local slug tmp_out status details exit_code
  slug="$(echo "$partner" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/_/g')"
  tmp_out="$(mktemp "/tmp/${slug}_audit_output.XXXXXX")"

  if timeout "${timeout_sec}s" "$@" >"$tmp_out" 2>&1; then
    status="SUCCESS"
    details="- Command completed successfully."
  else
    exit_code=$?
    status="BLOCKED"
    if [ "$exit_code" -eq 124 ]; then
      details="- Command timed out after ${timeout_sec}s."
    elif [ "$exit_code" -eq 127 ]; then
      details="- Command unavailable in current routing mode."
    else
      details="- Command failed with exit code ${exit_code}. See output below for diagnostics."
    fi
  fi

  sanitize_output_file "$tmp_out"

  if [ "$status" = "SUCCESS" ] && rg -qi "(error code: [0-9]{3}|modelnotfounderror|insufficient balance|rate limit|an unexpected critical error occurred|connection closed|authorization header is badly formatted|\"error\"\s*:|^error:)" "$tmp_out"; then
    status="BLOCKED"
    details="- Command exited successfully but output indicates provider/API error payload."
  fi

  PARTNER_STATUS+=("${partner}: ${status}")
  collect_signals "$partner" "$status" "$tmp_out"
  write_report "$partner" "$model" "$outfile" "$status" "$details" "$tmp_out"
  rm -f "$tmp_out"
}

run_missing_tool_report() {
  local partner="$1"
  local model="$2"
  local outfile="$3"
  local message="$4"
  local tmp slug

  slug="$(echo "$partner" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/_/g')"
  tmp="$(mktemp "/tmp/${slug}_audit_output.XXXXXX")"
  echo "$message" > "$tmp"

  PARTNER_STATUS+=("${partner}: BLOCKED")
  ALERTS+=("[$partner] $message")

  write_report "$partner" "$model" "$outfile" "BLOCKED" "- ${message}" "$tmp"
  rm -f "$tmp"
}


run_glm_direct_preflight() {
  local preflight_prompt preflight_tmp preflight_rc
  preflight_prompt="Reply with exactly: OK"
  preflight_tmp="$(mktemp /tmp/glm_direct_preflight.XXXXXX.log)"

  if timeout 45s env AUDIT_PROMPT="$preflight_prompt" bash -lc "$GLM_DIRECT_CMD" >"$preflight_tmp" 2>&1; then
    preflight_rc=0
  else
    preflight_rc=$?
  fi

  sanitize_output_file "$preflight_tmp"

  if rg -qi '(insufficient balance|no resource package|余额不足|quota exceeded|rate limit|error code:\s*429)' "$preflight_tmp"; then
    ALERTS+=("[GLM (z.ai)] preflight failed: insufficient balance/quota on provider account.")
    run_missing_tool_report "GLM (z.ai)" "$GLM_MODEL" "$GLM_OUT" "GLM direct preflight failed: insufficient balance/quota on provider account."
    rm -f "$preflight_tmp"
    return 1
  fi

  if rg -qi '(authentication paramete|unauthorized|invalid api key|error code:\s*401|missing api key)' "$preflight_tmp"; then
    ALERTS+=("[GLM (z.ai)] preflight failed: authentication/key configuration error.")
    run_missing_tool_report "GLM (z.ai)" "$GLM_MODEL" "$GLM_OUT" "GLM direct preflight failed: authentication/key configuration error."
    rm -f "$preflight_tmp"
    return 1
  fi

  if [ "${preflight_rc:-0}" -ne 0 ]; then
    ALERTS+=("[GLM (z.ai)] preflight failed with exit code ${preflight_rc}; check direct route command.")
    run_missing_tool_report "GLM (z.ai)" "$GLM_MODEL" "$GLM_OUT" "GLM direct preflight failed with exit code ${preflight_rc}; check route command and provider response."
    rm -f "$preflight_tmp"
    return 1
  fi

  ROUTER_CHECKS+=("GLM direct preflight passed.")
  rm -f "$preflight_tmp"
  return 0
}

run_glm_partner() {
  local has_direct_key="0"
  if [ -n "${ZAI_API_KEY:-}" ] || [ -n "${OPENAI_API_KEY:-}" ]; then
    has_direct_key="1"
  fi

  case "$GLM_ROUTE" in
    direct)
      GLM_ROUTE_USED="direct_cmd"
      if [ -n "$GLM_DIRECT_CMD" ] && [ "$has_direct_key" = "1" ]; then
        if run_glm_direct_preflight; then
          run_partner "GLM (z.ai)" "$GLM_MODEL" "$GLM_OUT" "$GLM_TIMEOUT_SECONDS" env AUDIT_PROMPT="$(prompt_for_low_trust "GLM")" bash -lc "$GLM_DIRECT_CMD"
        fi
      elif [ -n "$GLM_DIRECT_CMD" ] && [ "$has_direct_key" != "1" ]; then
        run_missing_tool_report "GLM (z.ai)" "$GLM_MODEL" "$GLM_OUT" "GLM_AUDIT_ROUTE=direct requires ZAI_API_KEY or OPENAI_API_KEY."
      else
        run_missing_tool_report "GLM (z.ai)" "$GLM_MODEL" "$GLM_OUT" "GLM_AUDIT_ROUTE=direct set, but GLM_DIRECT_CMD is empty."
      fi
      ;;
    kimi)
      GLM_ROUTE_USED="kimi_model_router"
      if command -v kimi >/dev/null 2>&1; then
        run_partner "GLM (z.ai)" "$GLM_MODEL" "$GLM_OUT" "$GLM_TIMEOUT_SECONDS" kimi --print --final-message-only --output-format text --thinking -w "$ROOT" -m "$GLM_MODEL" -p "$(prompt_for_low_trust "GLM")"
      else
        run_missing_tool_report "GLM (z.ai)" "$GLM_MODEL" "$GLM_OUT" "GLM_AUDIT_ROUTE=kimi set, but \`kimi\` CLI not found."
      fi
      ;;
    auto)
      if [ -n "$GLM_DIRECT_CMD" ] && [ "$has_direct_key" = "1" ]; then
        GLM_ROUTE_USED="direct_cmd"
        if run_glm_direct_preflight; then
          run_partner "GLM (z.ai)" "$GLM_MODEL" "$GLM_OUT" "$GLM_TIMEOUT_SECONDS" env AUDIT_PROMPT="$(prompt_for_low_trust "GLM")" bash -lc "$GLM_DIRECT_CMD"
        fi
      elif command -v kimi >/dev/null 2>&1; then
        GLM_ROUTE_USED="kimi_model_router"
        run_partner "GLM (z.ai)" "$GLM_MODEL" "$GLM_OUT" "$GLM_TIMEOUT_SECONDS" kimi --print --final-message-only --output-format text --thinking -w "$ROOT" -m "$GLM_MODEL" -p "$(prompt_for_low_trust "GLM")"
      elif [ -n "$GLM_DIRECT_CMD" ] && [ "$has_direct_key" != "1" ]; then
        GLM_ROUTE_USED="direct_cmd_unavailable_key"
        run_missing_tool_report "GLM (z.ai)" "$GLM_MODEL" "$GLM_OUT" "Direct GLM configured but no ZAI_API_KEY/OPENAI_API_KEY available and kimi fallback missing."
      else
        GLM_ROUTE_USED="no_route_available"
        run_missing_tool_report "GLM (z.ai)" "$GLM_MODEL" "$GLM_OUT" "No GLM route available (GLM_DIRECT_CMD empty and \`kimi\` missing)."
      fi
      ;;
    *)
      GLM_ROUTE_USED="invalid_route"
      run_missing_tool_report "GLM (z.ai)" "$GLM_MODEL" "$GLM_OUT" "Invalid GLM_AUDIT_ROUTE: ${GLM_ROUTE}. Expected auto|direct|kimi."
      ;;
  esac

  ROUTER_CHECKS+=("GLM runtime route used: ${GLM_ROUTE_USED} (mode=${GLM_ROUTE}).")
}

check_provider_routes

if is_enabled "$KIMI_ENABLED"; then
  if command -v kimi >/dev/null 2>&1; then
    run_partner "Kimi" "$KIMI_MODEL" "$KIMI_OUT" "$KIMI_TIMEOUT_SECONDS" kimi --print --final-message-only --output-format text --thinking -w "$ROOT" -m "$KIMI_MODEL" -p "$PROMPT"
  else
    run_missing_tool_report "Kimi" "$KIMI_MODEL" "$KIMI_OUT" "\`kimi\` CLI not found on PATH."
  fi
else
  run_missing_tool_report "Kimi" "$KIMI_MODEL" "$KIMI_OUT" "Disabled for this run (KIMI_AUDIT_ENABLED=0)."
fi

if is_enabled "$GEMINI_ENABLED"; then
  if command -v gemini >/dev/null 2>&1; then
    run_partner "Gemini" "$GEMINI_MODEL" "$GEMINI_OUT" "$GEMINI_TIMEOUT_SECONDS" env AUDIT_ROOT="$ROOT" AUDIT_MODEL="$GEMINI_MODEL" AUDIT_PROMPT="$PROMPT" bash -lc 'cd "$AUDIT_ROOT" && gemini --model "$AUDIT_MODEL" --prompt "$AUDIT_PROMPT" --output-format text'
  else
    run_missing_tool_report "Gemini" "$GEMINI_MODEL" "$GEMINI_OUT" "\`gemini\` CLI not found on PATH."
  fi
else
  run_missing_tool_report "Gemini" "$GEMINI_MODEL" "$GEMINI_OUT" "Disabled for this run (GEMINI_AUDIT_ENABLED=0)."
fi

if is_enabled "$GLM_ENABLED"; then
  run_glm_partner
else
  run_missing_tool_report "GLM (z.ai)" "$GLM_MODEL" "$GLM_OUT" "Disabled for this run (GLM_AUDIT_ENABLED=0)."
  ROUTER_CHECKS+=("GLM runtime route used: disabled (mode=${GLM_ROUTE}).")
fi

if is_enabled "$GROQ_ENABLED"; then
  if [ -n "$GROQ_DIRECT_CMD" ]; then
    run_partner "Groq" "$GROQ_MODEL" "$GROQ_OUT" "$GROQ_TIMEOUT_SECONDS" env AUDIT_PROMPT="$(prompt_for_groq)" bash -lc "$GROQ_DIRECT_CMD"
  else
    run_missing_tool_report "Groq" "$GROQ_MODEL" "$GROQ_OUT" "GROQ_DIRECT_CMD is empty."
  fi
else
  run_missing_tool_report "Groq" "$GROQ_MODEL" "$GROQ_OUT" "Disabled for this run (GROQ_AUDIT_ENABLED=0)."
fi

if is_enabled "$ANTHROPIC_ENABLED"; then
  if [ -n "$ANTHROPIC_DIRECT_CMD" ]; then
    run_partner "Anthropic" "$ANTHROPIC_MODEL" "$ANTHROPIC_OUT" "$ANTHROPIC_TIMEOUT_SECONDS" env AUDIT_PROMPT="$PROMPT" bash -lc "$ANTHROPIC_DIRECT_CMD"
  else
    run_missing_tool_report "Anthropic" "$ANTHROPIC_MODEL" "$ANTHROPIC_OUT" "ANTHROPIC_DIRECT_CMD is empty."
  fi
else
  run_missing_tool_report "Anthropic" "$ANTHROPIC_MODEL" "$ANTHROPIC_OUT" "Disabled for this run (ANTHROPIC_AUDIT_ENABLED=0)."
fi

if is_enabled "$CODEX_ENABLED"; then
  if command -v codex >/dev/null 2>&1; then
    run_partner "Codex" "$CODEX_MODEL" "$CODEX_OUT" "$CODEX_TIMEOUT_SECONDS" codex exec -m "$CODEX_MODEL" -c 'model_reasoning_effort="xhigh"' -C "$ROOT" -s read-only --skip-git-repo-check "$PROMPT"
  else
    run_missing_tool_report "Codex" "$CODEX_MODEL" "$CODEX_OUT" "\`codex\` CLI not found on PATH."
  fi
else
  run_missing_tool_report "Codex" "$CODEX_MODEL" "$CODEX_OUT" "Disabled for this run (CODEX_AUDIT_ENABLED=0)."
fi

{
  echo "# Audit Signal Rollup ${DATE_TAG}"
  echo
  echo "- Date: \`${DATE_TAG}\`"
  echo "- Workspace: \`${ROOT}\`"
  echo "- Runner: \`evo-audit-partners.sh\`"
  echo
  echo "## Provider Routing Checks"
  if [ "${#ROUTER_CHECKS[@]}" -eq 0 ]; then
    echo "- none"
  else
    for item in "${ROUTER_CHECKS[@]}"; do
      echo "- ${item}"
    done
  fi
  echo
  echo "## Partner Runs"
  for item in "${PARTNER_STATUS[@]}"; do
    echo "- ${item}"
  done
  echo
  echo "## Red Flags (Must Be Fixed)"
  if [ "${#RED_FLAGS[@]}" -eq 0 ]; then
    echo "- none reported"
  else
    for item in "${RED_FLAGS[@]}"; do
      echo "- ${item}"
    done
  fi
  echo
  echo "## Alerts (Triage Queue)"
  if [ "${#ALERTS[@]}" -eq 0 ]; then
    echo "- none reported"
  else
    for item in "${ALERTS[@]}"; do
      echo "- ${item}"
    done
  fi
  echo
  echo "## Pass/Fail Policy"
  echo "- This runner does not auto-pass or auto-fail readiness."
  echo "- Audit readiness is decided by the audit auditor after evidence review."
  echo
  echo "## Context Chain"
  echo "← inherits from: /home/evo/AGENTS.md"
  echo "→ overrides by: none"
  echo "→ live map: /home/evo/AI_SESSION_BOOTSTRAP.md"
  echo "→ conventions: /home/evo/DNA/ops/CONVENTIONS.md"
} > "$ROLLUP_OUT"

echo "✅ first-level audit artifacts written:"
echo " - $KIMI_OUT"
echo " - $GEMINI_OUT"
echo " - $GLM_OUT"
echo " - $GROQ_OUT"
echo " - $ANTHROPIC_OUT"
echo " - $CODEX_OUT"
echo " - $ROLLUP_OUT"
