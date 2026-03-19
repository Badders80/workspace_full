#!/usr/bin/env bash
set -euo pipefail

WORKSPACE_ROOT="/home/evo/workspace"
SYSTEM_HOME="/home/evo"
OUT_DIR="$WORKSPACE_ROOT/_logs/audit_runs"
PROMPT_FILE="/tmp/agent_audit_prompt.txt"

# Model defaults (operator-overridable via env vars)
GEMINI_MODEL="${GEMINI_AUDIT_MODEL:-gemini-2.5-pro}"
GROQ_MODEL="${GROQ_AUDIT_MODEL:-openai/gpt-oss-120b}"
ANTHROPIC_MODEL="${ANTHROPIC_AUDIT_MODEL:-claude-sonnet-4-20250514}"
CODEX_MODEL="${CODEX_AUDIT_MODEL:-gpt-5.3-codex}"

# Per-auditor enable flags
GEMINI_ENABLED="${GEMINI_AUDIT_ENABLED:-1}"
GROQ_ENABLED="${GROQ_AUDIT_ENABLED:-1}"
ANTHROPIC_ENABLED="${ANTHROPIC_AUDIT_ENABLED:-1}"
CODEX_ENABLED="${CODEX_AUDIT_ENABLED:-1}"

# Per-auditor timeouts (seconds)
GEMINI_TIMEOUT_SECONDS="${GEMINI_AUDIT_TIMEOUT_SECONDS:-180}"
GROQ_TIMEOUT_SECONDS="${GROQ_AUDIT_TIMEOUT_SECONDS:-180}"
ANTHROPIC_TIMEOUT_SECONDS="${ANTHROPIC_AUDIT_TIMEOUT_SECONDS:-180}"
CODEX_TIMEOUT_SECONDS="${CODEX_AUDIT_TIMEOUT_SECONDS:-240}"

GROQ_DIRECT_CMD="${GROQ_DIRECT_CMD:-/home/evo/workspace/_scripts/evo-groq-direct.sh}"
ANTHROPIC_DIRECT_CMD="${ANTHROPIC_DIRECT_CMD:-/home/evo/workspace/_scripts/evo-anthropic-direct.sh}"
GROQ_AUDIT_PROFILE="${GROQ_AUDIT_PROFILE:-watchdog}"

usage() {
  cat <<'USAGE'
Usage: evo-audit-partners.sh [YYYY-MM-DD]
       evo-audit-partners.sh --date YYYY-MM-DD
       evo-audit-partners.sh --date=YYYY-MM-DD
       evo-audit-partners.sh --help

Runs first-level core partner audits (Codex, Gemini, Groq, Anthropic) and writes:
- per-partner reports under /home/evo/workspace/_logs/audit_runs/
- a rollup of RED_FLAG/ALERT signals for operator adjudication

This runner does not hard-pass or hard-fail readiness.

Useful env controls:
- GEMINI_AUDIT_ENABLED=0|1 (same pattern for GROQ/ANTHROPIC/CODEX)
- GEMINI_AUDIT_TIMEOUT_SECONDS=180 (same pattern for GROQ/ANTHROPIC/CODEX)
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
        echo "ERROR: --date requires a value"
        usage
        exit 1
      fi
      DATE_TAG="$1"
      ;;
    --date=*)
      DATE_TAG="${1#*=}"
      ;;
    -*)
      echo "ERROR: unknown flag: $1"
      usage
      exit 1
      ;;
    *)
      if [ -z "$DATE_TAG" ]; then
        DATE_TAG="$1"
      else
        echo "ERROR: unexpected argument: $1"
        usage
        exit 1
      fi
      ;;
  esac
  shift
done

[ -n "$DATE_TAG" ] || DATE_TAG="$(date +%F)"

DEFAULT_PROMPT="Audit /home/evo/workspace as an independent first-level reviewer.

Rules:
- Use actual checks/inspection, not assumptions.
- Scope: /home/evo/workspace only, plus root env governance at /home/evo/.env.
- No code changes. Read-only audit.

Run checks for:
1) Gate health (just check)
2) Env governance (verify /home/evo/.env is canonical and current projects link correctly)
3) Documentation integrity (context chain and registration for key docs)
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

prompt_for_groq() {
  if [ "$GROQ_AUDIT_PROFILE" = "general" ]; then
    printf '%s\n' "$PROMPT"
    return
  fi

  cat <<EOF
Groq Watchdog Audit - Structural Trap Detection

Purpose:
- Deterministic trap detection only.
- No architecture critique.
- No speculation.
- Binary outcomes only.

Scope prompt:
$PROMPT

Output format (strict):
1) CHECK RESULTS
2) HARD BLOCKERS
3) NON-BLOCKING ALERTS
4) TOP 5 FIXES

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
EOF
}

mkdir -p "$OUT_DIR"

declare -a PARTNER_STATUS=()
declare -a RED_FLAGS=()
declare -a ALERTS=()

GEMINI_OUT="$OUT_DIR/GEMINI_AUDIT_${DATE_TAG}.md"
GROQ_OUT="$OUT_DIR/GROQ_AUDIT_${DATE_TAG}.md"
ANTHROPIC_OUT="$OUT_DIR/ANTHROPIC_AUDIT_${DATE_TAG}.md"
CODEX_OUT="$OUT_DIR/CODEX_AUDIT_${DATE_TAG}.md"
ROLLUP_OUT="$OUT_DIR/AUDIT_SIGNAL_ROLLUP_${DATE_TAG}.md"

sanitize_output_file() {
  local output_file="$1"
  # Prevent gate failures from leaked absolute host paths in tool stack traces.
  sed -i 's#/home/evo/#/home/evo_redacted/#g' "$output_file" || true
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
    echo "- Workspace: \`${WORKSPACE_ROOT}\`"
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
    echo "← inherits from: /home/evo/workspace/AGENTS.md"
    echo "→ overrides by: none"
    echo "→ live map: /home/evo/workspace/AI_SESSION_BOOTSTRAP.md"
    echo "→ conventions: /home/evo/workspace/DNA/ops/CONVENTIONS.md"
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
      details="- Command unavailable in current environment."
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

if is_enabled "$GEMINI_ENABLED"; then
  if command -v gemini >/dev/null 2>&1; then
    run_partner "Gemini" "$GEMINI_MODEL" "$GEMINI_OUT" "$GEMINI_TIMEOUT_SECONDS" env AUDIT_ROOT="$WORKSPACE_ROOT" AUDIT_MODEL="$GEMINI_MODEL" AUDIT_PROMPT="$PROMPT" bash -lc 'cd "$AUDIT_ROOT" && gemini --model "$AUDIT_MODEL" --prompt "$AUDIT_PROMPT" --output-format text'
  else
    run_missing_tool_report "Gemini" "$GEMINI_MODEL" "$GEMINI_OUT" "\`gemini\` CLI not found on PATH."
  fi
else
  run_missing_tool_report "Gemini" "$GEMINI_MODEL" "$GEMINI_OUT" "Disabled for this run (GEMINI_AUDIT_ENABLED=0)."
fi

if is_enabled "$GROQ_ENABLED"; then
  if [ -n "$GROQ_DIRECT_CMD" ] && [ -x "$GROQ_DIRECT_CMD" ]; then
    run_partner "Groq" "$GROQ_MODEL" "$GROQ_OUT" "$GROQ_TIMEOUT_SECONDS" env AUDIT_PROMPT="$(prompt_for_groq)" bash -lc "$GROQ_DIRECT_CMD"
  elif [ -n "$GROQ_DIRECT_CMD" ]; then
    run_missing_tool_report "Groq" "$GROQ_MODEL" "$GROQ_OUT" "Configured GROQ_DIRECT_CMD is not executable: $GROQ_DIRECT_CMD"
  else
    run_missing_tool_report "Groq" "$GROQ_MODEL" "$GROQ_OUT" "GROQ_DIRECT_CMD is empty."
  fi
else
  run_missing_tool_report "Groq" "$GROQ_MODEL" "$GROQ_OUT" "Disabled for this run (GROQ_AUDIT_ENABLED=0)."
fi

if is_enabled "$ANTHROPIC_ENABLED"; then
  if [ -n "$ANTHROPIC_DIRECT_CMD" ] && [ -x "$ANTHROPIC_DIRECT_CMD" ]; then
    run_partner "Anthropic" "$ANTHROPIC_MODEL" "$ANTHROPIC_OUT" "$ANTHROPIC_TIMEOUT_SECONDS" env AUDIT_PROMPT="$PROMPT" bash -lc "$ANTHROPIC_DIRECT_CMD"
  elif [ -n "$ANTHROPIC_DIRECT_CMD" ]; then
    run_missing_tool_report "Anthropic" "$ANTHROPIC_MODEL" "$ANTHROPIC_OUT" "Configured ANTHROPIC_DIRECT_CMD is not executable: $ANTHROPIC_DIRECT_CMD"
  else
    run_missing_tool_report "Anthropic" "$ANTHROPIC_MODEL" "$ANTHROPIC_OUT" "ANTHROPIC_DIRECT_CMD is empty."
  fi
else
  run_missing_tool_report "Anthropic" "$ANTHROPIC_MODEL" "$ANTHROPIC_OUT" "Disabled for this run (ANTHROPIC_AUDIT_ENABLED=0)."
fi

if is_enabled "$CODEX_ENABLED"; then
  if command -v codex >/dev/null 2>&1; then
    run_partner "Codex" "$CODEX_MODEL" "$CODEX_OUT" "$CODEX_TIMEOUT_SECONDS" codex exec -m "$CODEX_MODEL" -c 'model_reasoning_effort="xhigh"' -C "$WORKSPACE_ROOT" -s read-only --skip-git-repo-check "$PROMPT"
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
  echo "- Workspace: \`${WORKSPACE_ROOT}\`"
  echo "- Runner: \`evo-audit-partners.sh\`"
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
  echo "- Audit readiness is decided by the audit operator after evidence review."
  echo
  echo "## Context Chain"
  echo "← inherits from: /home/evo/workspace/AGENTS.md"
  echo "→ overrides by: none"
  echo "→ live map: /home/evo/workspace/AI_SESSION_BOOTSTRAP.md"
  echo "→ conventions: /home/evo/workspace/DNA/ops/CONVENTIONS.md"
} > "$ROLLUP_OUT"

echo "Core partner audit artifacts written:"
echo " - $GEMINI_OUT"
echo " - $GROQ_OUT"
echo " - $ANTHROPIC_OUT"
echo " - $CODEX_OUT"
echo " - $ROLLUP_OUT"
