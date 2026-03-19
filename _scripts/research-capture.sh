#!/usr/bin/env bash
set -euo pipefail

WORKSPACE_ROOT="${WORKSPACE_ROOT:-/home/evo/workspace}"
VAULT_ROOT="$WORKSPACE_ROOT/_sandbox/research_vault"
INBOX_DIR="$VAULT_ROOT/00_Inbox/manual-captures"

mkdir -p "$INBOX_DIR"

TITLE="${1:-Quick Capture}"
BODY="${2:-}"
STAMP="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
FILE_STAMP="$(date -u +%Y-%m-%d_%H%M%S)"

slugify() {
  printf '%s' "$1" \
    | tr '[:upper:]' '[:lower:]' \
    | sed -E 's/[^a-z0-9]+/-/g; s/^-+//; s/-+$//'
}

SLUG="$(slugify "$TITLE")"
if [[ -z "$SLUG" ]]; then
  SLUG="capture"
fi

TARGET="$INBOX_DIR/${FILE_STAMP}_${SLUG}.md"

cat > "$TARGET" <<EOF
---
note_type: manual_capture
status: raw
captured_at: $STAMP
meeting_date:
people: []
entities: []
topics: []
confidence: 0.7
review_roles:
  - CEO
  - CTO
tags: []
promotion_candidate: false
---

# $TITLE

## What Happened

${BODY:-"-"}

## Why It Matters

-

## Follow-Up

-

## Context Chain
<- inherits from: /home/evo/workspace/AGENTS.md
-> overrides by: none
-> live map: /home/evo/workspace/AI_SESSION_BOOTSTRAP.md
-> conventions: /home/evo/workspace/DNA/ops/CONVENTIONS.md
EOF

printf '%s\n' "$TARGET"
