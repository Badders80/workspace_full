#!/usr/bin/env bash
set -euo pipefail

ROOT="/home/evo/workspace"
OUT_DIR="$ROOT/_logs/audit_runs"
CLAUDE_MODEL="${CLAUDE_AUDIT_MODEL:-opus}"

usage() {
  cat <<'USAGE'
Usage: evo-audit-claude-meta.sh [YYYY-MM-DD]
       evo-audit-claude-meta.sh --date YYYY-MM-DD
       evo-audit-claude-meta.sh --date=YYYY-MM-DD
       evo-audit-claude-meta.sh --help

Runs level-2 Claude meta-audit over first-level reports.
Codex remains a first-level auditor in this flow.
USAGE
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

mkdir -p "$OUT_DIR"

GEMINI_OUT="$OUT_DIR/GEMINI_AUDIT_${DATE_TAG}.md"
GROQ_OUT="$OUT_DIR/GROQ_AUDIT_${DATE_TAG}.md"
ANTHROPIC_OUT="$OUT_DIR/ANTHROPIC_AUDIT_${DATE_TAG}.md"
CODEX_OUT="$OUT_DIR/CODEX_AUDIT_${DATE_TAG}.md"
CLAUDE_META_OUT="$OUT_DIR/CLAUDE_META_AUDIT_${DATE_TAG}.md"
CLAUDE_META_SIGNAL_OUT="$OUT_DIR/CLAUDE_META_SIGNALS_${DATE_TAG}.md"

declare -a FOUND_REPORTS=()
declare -a MISSING_REPORTS=()
declare -a RED_FLAGS=()
declare -a ALERTS=()

for report in "$GEMINI_OUT" "$GROQ_OUT" "$ANTHROPIC_OUT" "$CODEX_OUT"; do
  if [ -s "$report" ]; then
    if rg -q '^- Status: `SUCCESS`' "$report"; then
      FOUND_REPORTS+=("$report")
    else
      MISSING_REPORTS+=("$report (excluded: status not SUCCESS)")
    fi
  else
    MISSING_REPORTS+=("$report")
  fi
done

tmp_out="$(mktemp /tmp/claude_meta_audit_output.XXXXXX)"
status="SUCCESS"
details="- Command completed successfully."

if ! command -v claude >/dev/null 2>&1; then
  status="BLOCKED"
  details="- \`claude\` CLI not found on PATH."
  echo "claude CLI not found on PATH." > "$tmp_out"
elif [ "${#FOUND_REPORTS[@]}" -eq 0 ]; then
  status="BLOCKED"
  details="- No first-level audit reports found for ${DATE_TAG}. Run partner audits first."
  echo "No first-level audit reports found for ${DATE_TAG}." > "$tmp_out"
else
  found_list="$(printf -- '- %s\n' "${FOUND_REPORTS[@]}")"
  if [ "${#MISSING_REPORTS[@]}" -gt 0 ]; then
    missing_list="$(printf -- '- %s\n' "${MISSING_REPORTS[@]}")"
  else
    missing_list="- none"
  fi

  META_PROMPT="You are the level-2 audit auditor.

Codex is a first-level auditor in this run, not the adjudicator.
Your task is to audit first-level auditor quality and produce an operator decision input.

Available first-level reports:
${found_list}

Missing first-level reports (availability gaps, not automatic failure):
${missing_list}

For each available auditor report:
1) score evidence quality (0-10)
2) identify unsupported claims
3) identify missed critical risks
4) identify contradictory conclusions across auditors

Output only markdown with sections:
- Evidence Quality Scores
- Cross-Auditor Contradictions
- Red Flags
- Alerts
- Decision
- Next Actions

Signal format rules:
- Prefix each hard blocker line exactly with: RED_FLAG:
- Prefix each non-blocking line exactly with: ALERT:

Decision should be operator-facing: PASS_WITH_FLAGS / NEEDS_FIX / HOLD."

  if ! printf '%s\n' "$META_PROMPT" | timeout "${CLAUDE_META_TIMEOUT_SECONDS:-180}s" claude --print --output-format text --model "$CLAUDE_MODEL" --effort high --permission-mode dontAsk --add-dir "$ROOT" >"$tmp_out" 2>&1; then
    status="BLOCKED"
    details="- Claude meta-audit command failed. See output below for diagnostics."
  fi
fi

while IFS= read -r line; do
  body="${line#*RED_FLAG:}"
  body="$(echo "$body" | sed 's/^[[:space:]]*//')"
  [ -n "$body" ] && RED_FLAGS+=("$body")
done < <(rg -i '^\s*RED_FLAG:' "$tmp_out" 2>/dev/null || true)

while IFS= read -r line; do
  body="${line#*ALERT:}"
  body="$(echo "$body" | sed 's/^[[:space:]]*//')"
  [ -n "$body" ] && ALERTS+=("$body")
done < <(rg -i '^\s*ALERT:' "$tmp_out" 2>/dev/null || true)

{
  echo "# Claude Meta-Audit ${DATE_TAG}"
  echo
  echo "- Partner: \`Claude (meta-audit)\`"
  echo "- Model: \`${CLAUDE_MODEL}\`"
  echo "- Date: \`${DATE_TAG}\`"
  echo "- Workspace: \`${ROOT}\`"
  echo "- Status: \`${status}\`"
  echo
  echo "## Inputs"
  echo "- First-level auditors: Gemini, Groq, Anthropic, Codex"
  echo "- Codex role in this flow: first-level auditor only"
  echo
  echo "### Found Reports"
  if [ "${#FOUND_REPORTS[@]}" -eq 0 ]; then
    echo "- none"
  else
    for item in "${FOUND_REPORTS[@]}"; do
      echo "- ${item}"
    done
  fi
  echo
  echo "### Missing Reports"
  if [ "${#MISSING_REPORTS[@]}" -eq 0 ]; then
    echo "- none"
  else
    for item in "${MISSING_REPORTS[@]}"; do
      echo "- ${item}"
    done
  fi
  echo
  echo "## Execution"
  echo
  echo "${details}"
  echo
  if [ -s "$tmp_out" ]; then
    echo "## Model Output"
    echo
    cat "$tmp_out"
    echo
  fi
  echo "## Context Chain"
  echo "← inherits from: /home/evo/workspace/AGENTS.md"
  echo "→ overrides by: none"
  echo "→ live map: /home/evo/workspace/AI_SESSION_BOOTSTRAP.md"
  echo "→ conventions: /home/evo/workspace/DNA/ops/CONVENTIONS.md"
} > "$CLAUDE_META_OUT"

{
  echo "# Claude Meta Signal Rollup ${DATE_TAG}"
  echo
  echo "- Source: \`${CLAUDE_META_OUT}\`"
  echo "- Status: \`${status}\`"
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
  echo "- This runner provides decision input only; operator makes final go/no-go call."
  echo
  echo "## Context Chain"
  echo "← inherits from: /home/evo/workspace/AGENTS.md"
  echo "→ overrides by: none"
  echo "→ live map: /home/evo/workspace/AI_SESSION_BOOTSTRAP.md"
  echo "→ conventions: /home/evo/workspace/DNA/ops/CONVENTIONS.md"
} > "$CLAUDE_META_SIGNAL_OUT"

rm -f "$tmp_out"

echo "✅ Claude meta-audit artifacts written:"
echo " - $CLAUDE_META_OUT"
echo " - $CLAUDE_META_SIGNAL_OUT"
