#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/agent-context.sh"

if [ -f /home/evo/.config/evo/auth.direct.sh ]; then
  # shellcheck disable=SC1091
  source /home/evo/.config/evo/auth.direct.sh
fi

issues=0
warnings=0

ok() {
  printf 'ok    %s\n' "$1"
}

warn() {
  warnings=$((warnings + 1))
  printf 'warn  %s\n' "$1"
}

fail() {
  issues=$((issues + 1))
  printf 'fail  %s\n' "$1"
}

check_file() {
  local file="$1"
  local label="$2"

  if [ -f "$file" ]; then
    ok "$label"
  else
    fail "$label missing ($file)"
  fi
}

check_wrapper() {
  local name="$1"
  local path="$HOME/.local/bin/$name"

  if [ ! -f "$path" ]; then
    warn "wrapper missing: $path"
    return
  fi

  if grep -q "$WORKSPACE_ROOT/_scripts/" "$path"; then
    ok "wrapper routed to workspace: $name"
  else
    warn "wrapper not yet routed to workspace: $name"
  fi
}

echo "Workspace sanity check"
echo

check_file "$WORKSPACE_AI_BOOTSTRAP" "bootstrap present"
check_file "$WORKSPACE_AGENTS" "workspace AGENTS present"
check_file "$WORKSPACE_DNA_AGENTS" "DNA AGENTS present"
check_file "$WORKSPACE_CONVENTIONS" "conventions present"
check_file "$WORKSPACE_STACK" "stack registry present"
check_file "$WORKSPACE_TRANSITION" "transition log present"
check_file "$WORKSPACE_DECISIONS" "decision log present"

for project in Evolution_Platform SSOT_Build; do
  if [ -d "$WORKSPACE_ROOT/projects/$project" ]; then
    ok "project present: $project"
  else
    warn "project missing: $project"
  fi
done

ok "seo-baseline archive state skipped (archive relocated)"

for wrapper in dna-context geminic claudec aidere evo evo-doctor; do
  check_wrapper "$wrapper"
done

if [ -f "$HOME/.config/evo/auth.direct.sh" ]; then
  ok "auth bootstrap present"
else
  fail "auth bootstrap missing ($HOME/.config/evo/auth.direct.sh)"
fi

if [ -f "$HOME/.env" ]; then
  perms="$(stat -c '%a' "$HOME/.env" 2>/dev/null || printf '?')"
  if [ "$perms" = "600" ]; then
    ok "vault permissions are 600"
  else
    warn "vault permissions are $perms (expected 600)"
  fi
else
  fail "vault missing ($HOME/.env)"
fi

if [ -n "${GEMINI_API_KEY:-}" ] || [ -n "${GOOGLE_API_KEY:-}" ]; then
  warn "raw Google API key variables are still exported in this shell"
else
  ok "raw Google API key variables are not exported"
fi

if [ -n "${GOOGLE_CLOUD_PROJECT:-}" ]; then
  ok "GOOGLE_CLOUD_PROJECT=$GOOGLE_CLOUD_PROJECT"
else
  warn "GOOGLE_CLOUD_PROJECT is not exported"
fi

if [ -n "${GOOGLE_CLOUD_LOCATION:-${GOOGLE_CLOUD_REGION:-}}" ]; then
  ok "Google location set to ${GOOGLE_CLOUD_LOCATION:-$GOOGLE_CLOUD_REGION}"
else
  warn "GOOGLE_CLOUD_LOCATION is not exported"
fi

if workspace_check_gcloud_adc; then
  ok "gcloud ADC is ready"
else
  warn "gcloud ADC is not ready; run gcloud auth application-default login"
fi

if grep -q '"selectedType"[[:space:]]*:[[:space:]]*"gemini-api-key"' "$HOME/.gemini/settings.json" 2>/dev/null; then
  warn "Gemini CLI settings still prefer gemini-api-key auth"
fi

echo
printf 'issues: %s\n' "$issues"
printf 'warnings: %s\n' "$warnings"

if [ "$issues" -gt 0 ]; then
  exit 1
fi
