#!/bin/bash
set -euo pipefail

source /home/evo/workspace/_scripts/agent-context.sh

if ! command -v kimi >/dev/null 2>&1; then
  echo "Error: kimi command not found"
  exit 1
fi

echo "Launching kimi with workspace context"
exec kimi --yolo --prompt "$(workspace_context_prompt)" "$@"
