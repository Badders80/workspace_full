#!/usr/bin/env bash
set -euo pipefail

DATE_TAG="${1:-$(date +%F)-groq-watchdog}"
TARGET_ROOT="${TARGET_ROOT:-/home/evo/workspace/projects/SSOT_Build}"
PROMPT_FILE="/tmp/agent_audit_prompt.txt"
BACKUP_PROMPT="/tmp/agent_audit_prompt.backup.$$"

cleanup() {
  if [ -f "$BACKUP_PROMPT" ]; then
    mv "$BACKUP_PROMPT" "$PROMPT_FILE"
  else
    rm -f "$PROMPT_FILE"
  fi
}
trap cleanup EXIT

if [ -f "$PROMPT_FILE" ]; then
  cp "$PROMPT_FILE" "$BACKUP_PROMPT"
fi

snippet() {
  local id="$1"
  local file="$2"
  local start="$3"
  local end="$4"
  local note="$5"
  echo "${id} ${file}:${start}-${end} ${note}"
  if [ -f "$file" ]; then
    echo '```text'
    nl -ba "$file" | sed -n "${start},${end}p"
    echo '```'
  else
    echo "UNVERIFIED: missing file ${file}"
  fi
  echo
}

{
  cat <<EOF
You are receiving a curated evidence bundle from ${TARGET_ROOT}.
Use only the evidence items below. Do not use any outside files.
Unsupported claim must be exactly: UNVERIFIED

Return strict sections:
1) CHECK RESULTS
2) MUST_MIGRATE_ENDPOINTS
3) HARD BLOCKERS
4) NON-BLOCKING ALERTS
5) TOP 5 FIXES

EOF

  snippet "E1" "${TARGET_ROOT}/vite.config.ts" 69 70 "INVESTOR_UPDATES_ROOT default path behavior"
  snippet "E2" "${TARGET_ROOT}/vite.config.ts" 101 135 "Dev middleware save endpoint and filesystem write"
  snippet "E3" "${TARGET_ROOT}/vite.config.ts" 239 355 "GLM and Groq dev middleware AI proxy endpoints"
  snippet "E4" "${TARGET_ROOT}/App.tsx" 2093 2129 "localStorage load and seed fallback"
  snippet "E5" "${TARGET_ROOT}/App.tsx" 2131 2148 "localStorage save with silent catch"
  snippet "E6" "${TARGET_ROOT}/App.tsx" 2195 2211 "OWN-002 runtime mirroring from TRN-002"
  snippet "E7" "${TARGET_ROOT}/intake/v0.1/trainers.csv" 1 3 "CSV social/profile columns"
  snippet "E8" "${TARGET_ROOT}/App.tsx" 112 132 "TS trainer/owner social_links type fields"
  snippet "E9" "${TARGET_ROOT}/package.json" 1 30 "build scripts and module type"
  snippet "E10" "${TARGET_ROOT}/scripts/sync-seed.mjs" 1 25 "seed sync script behavior"
  snippet "E11" "${TARGET_ROOT}/.gitignore" 1 20 "ignored files patterns"
  snippet "E12" "${TARGET_ROOT}/intake/v0.1/documents.csv" 1 8 "absolute file paths in data artifact"
} > "$PROMPT_FILE"

set -a
source /home/evo/.env >/dev/null 2>&1 || true
set +a

GEMINI_AUDIT_ENABLED=0 \
ANTHROPIC_AUDIT_ENABLED=0 \
CODEX_AUDIT_ENABLED=0 \
GROQ_AUDIT_ENABLED=1 \
GROQ_AUDIT_PROFILE=watchdog \
/home/evo/workspace/_scripts/evo-audit-partners.sh --date="${DATE_TAG}"
