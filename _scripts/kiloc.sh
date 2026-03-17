#!/bin/bash
set -euo pipefail

source /home/evo/workspace/_scripts/agent-context.sh

if ! command -v kilo >/dev/null 2>&1; then
  echo "Error: kilo command not found"
  exit 1
fi

echo "Launching kilo with workspace context"
exec kilo --prompt "$(workspace_context_prompt)" "$@"
