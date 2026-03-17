#!/usr/bin/env bash

set -u

WORKSPACE_ROOT="/home/evo/workspace"
SYSTEM_HOME="/home/evo"
LEGACY_ROOT=""  # evo2 removed 2026-03-16
STATUS="GREEN"

check_file() {
    local path="$1"
    if [ -f "$path" ]; then
        echo "PASS  file exists: $path"
    else
        echo "FAIL  missing file: $path"
        STATUS="RED"
    fi
}

echo "== evo-check =="

if [[ -n "$LEGACY_ROOT" && ( "$PWD" == "$LEGACY_ROOT" || "$PWD" == "$LEGACY_ROOT/"* ) ]]; then
    echo "FAIL  running from legacy root: $PWD"
    STATUS="RED"
elif [[ "$PWD" != "$WORKSPACE_ROOT" && "$PWD" != "$WORKSPACE_ROOT/"* ]]; then
    echo "FAIL  not running from workspace root: $PWD"
    STATUS="RED"
else
    echo "PASS  canonical root target: $WORKSPACE_ROOT"
fi

check_file "$WORKSPACE_ROOT/AGENTS.md"
check_file "$WORKSPACE_ROOT/AI_SESSION_BOOTSTRAP.md"
check_file "$WORKSPACE_ROOT/DNA/AGENTS.md"
check_file "$WORKSPACE_ROOT/DNA/ops/CONVENTIONS.md"
check_file "$WORKSPACE_ROOT/DNA/ops/STACK.md"
check_file "$SYSTEM_HOME/.env"

if [ "$STATUS" = "GREEN" ]; then
    echo "GREEN"
    exit 0
fi

echo "RED"
exit 1
