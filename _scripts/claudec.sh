#!/bin/bash
set -euo pipefail

source /home/evo/workspace/_scripts/agent-context.sh

if ! command -v claude >/dev/null 2>&1; then
  echo "Error: claude command not found"
  echo "Install: npm install -g @anthropic-ai/claude-cli"
  exit 1
fi

if claude --help 2>&1 | grep -q "system-prompt"; then
  exec claude --system-prompt "$(workspace_context_prompt)" "$@"
fi

printf '%s\n' "$(workspace_context_prompt)" | exec claude "$@"
