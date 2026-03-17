#!/usr/bin/env bash
set -euo pipefail

ROOT="/home/evo"
DATE_TAG="${1:-$(date +%F)}"
AGENT_ID="${OPENFANG_AUDIT_AGENT_ID:-}"
OUT_DIR="$ROOT/_logs/audit_runs"

if [ -z "$AGENT_ID" ]; then
  AGENT_ID="$(openfang agent list | awk '/audit-watchdog/ {print $1; exit}')"
fi

if [ -z "$AGENT_ID" ]; then
  echo "❌ No audit-watchdog agent found. Spawn one first."
  exit 1
fi

WS_ROOT="/home/evo/.openfang/workspaces/audit-watchdog-${AGENT_ID:0:8}"
SCOPE_DIR="$WS_ROOT/scope_${DATE_TAG}"

mkdir -p "$OUT_DIR"
rm -rf "$SCOPE_DIR"
mkdir -p "$SCOPE_DIR"

# MIGRATION BRIDGE — remove after workspace migration is complete.
# OpenFang file tools are workspace-scoped, so copy a minimal evidence bundle
# into the agent workspace for deterministic cross-validation.
cp "$ROOT/Justfile" "$SCOPE_DIR/"
cp "$ROOT/_scripts/evo-audit-partners.sh" "$SCOPE_DIR/"
cp "$ROOT/_logs/audit_runs/AUDIT_SIGNAL_ROLLUP_${DATE_TAG}.md" "$SCOPE_DIR/"
cp "$ROOT/.env.audit" "$SCOPE_DIR/"

PROMPT="Use tools to read only files under ${SCOPE_DIR} and produce sections CHECK RESULTS, MUST_FIX_FINDINGS, NON_BLOCKING_ALERTS, TOP_5_FIXES. Include RED_FLAG and ALERT markers. Each finding must include severity, file path, line, impact, remediation."

RAW_JSON="$(openfang message "$AGENT_ID" "$PROMPT" --json)"
OUT_FILE="$OUT_DIR/OPENFANG_AUDIT_${DATE_TAG}.md"

{
  echo "# OpenFang Audit ${DATE_TAG}"
  echo
  echo "- Partner: \`OpenFang audit-watchdog\`"
  echo "- Agent ID: \`${AGENT_ID}\`"
  echo "- Scope bundle: \`${SCOPE_DIR}\`"
  echo
  echo "## Model Output"
  echo
  printf '%s\n' "$RAW_JSON" | sed -n 's/^.*"response": "\(.*\)".*$/\1/p' | sed 's/\\n/\n/g' | sed 's/\\"/"/g'
  echo
  echo "## Context Chain"
  echo "← inherits from: /home/evo/AGENTS.md"
} > "$OUT_FILE"

echo "✅ OpenFang bridge audit artifact written:"
echo " - $OUT_FILE"
