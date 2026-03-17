# Memory Protocol

## Goal

Keep agents aligned through files, not chat history.

## The Three Layers

### 1. Structural Truth

These files define what is canonical right now:

- `/home/evo/workspace/AI_SESSION_BOOTSTRAP.md`
- `/home/evo/workspace/AGENTS.md`
- `/home/evo/workspace/DNA/AGENTS.md`
- `/home/evo/workspace/DNA/ops/CONVENTIONS.md`
- `/home/evo/workspace/DNA/ops/STACK.md`

### 2. Historical Truth

These files explain how the workspace got here:

- `/home/evo/workspace/DNA/ops/TRANSITION.md`
- `/home/evo/workspace/DNA/ops/DECISION_LOG.md`

Consult `/home/evo/workspace/DNA/ops/TECH_RADAR.md` on demand for prior tool evaluation notes. It is not part of the default session-start chain.

### 3. Working Queue

These files capture what is active or deferred:

- `/home/evo/workspace/DNA/INBOX.md`
- project-local backlog sections in active `README.md` files
- targeted audit documents in `/home/evo/workspace/_docs/`

## Retired Pattern

The old `OPERATING_BACKLOG.md` pattern is retired in the active workspace.
Use `DNA/INBOX.md` for workspace-level queueing and repo-local backlog sections
for implementation detail.

## Session Start Rule

Before coding or giving project-state advice:

1. Read the current context chain from `AI_SESSION_BOOTSTRAP.md`
2. Read `STACK.md`
3. Read `TRANSITION.md`
4. Read `INBOX.md`
5. Read `DECISION_LOG.md`

## Session End Rule

When the session changes something meaningful:

1. Append structural changes to `DNA/ops/TRANSITION.md`
2. Update `DNA/ops/STACK.md` when the live adopted or active tool registry changes
3. Record architecture choices in `DNA/ops/DECISION_LOG.md`
4. Update `DNA/INBOX.md` or the relevant project backlog note

## Command Shortcuts

- `evo context`
- `evo transition`
- `evo backlog`
- `evo decisions`
- `evo doctor`

## Reminder

The memory is the files. If the files are stale, the agent memory is stale.
