#!/bin/bash
set -euo pipefail

source /home/evo/workspace/_scripts/agent-context.sh

if ! command -v gemini >/dev/null 2>&1; then
  echo "Error: gemini command not found"
  echo "Install: npm install -g @google/gemini-cli"
  exit 1
fi

workspace_prepare_google_adc

mkdir -p "$HOME/.gemini"
workspace_render_context_bundle > "$HOME/.gemini/GEMINI.md"
export GEMINI_SYSTEM_MD="$HOME/.gemini/GEMINI.md"

if ! workspace_check_gcloud_adc; then
  echo "ADC is required for geminic."
  echo "Run:"
  echo "  gcloud auth application-default login"
  echo "  gcloud config set project $GOOGLE_CLOUD_PROJECT"
  exit 1
fi

if grep -q '"selectedType"[[:space:]]*:[[:space:]]*"gemini-api-key"' "$HOME/.gemini/settings.json" 2>/dev/null; then
  echo "warning: ~/.gemini/settings.json still selects gemini-api-key auth." >&2
  echo "warning: switch the Gemini CLI auth mode in a follow-up pass." >&2
fi

echo "Launching gemini with workspace context and GCP ADC: $GOOGLE_CLOUD_PROJECT ($GOOGLE_CLOUD_LOCATION)"
exec gemini "$@"
