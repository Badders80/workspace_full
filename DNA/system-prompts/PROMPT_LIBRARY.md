# Evolution Workspace Prompt Library

Status: ACTIVE - slimmed 2026-03-19.

Purpose: a minimal manual starter for external or cloud agents that cannot
automatically load the live workspace files. This file is not the source of
truth. The source of truth is the workspace DNA chain.

## Canonical Rules

- Canonical build root: `/home/evo/workspace`
- `/home/evo` is control plane only: auth, wrappers, global tool config, and
  the shared vault
- Shared vault: `/home/evo/.env`
- Do not use the retired pre-workspace DNA path
- Do not treat any older pre-workspace project path as the active root
- No build starts until `just check` is GREEN

## Required Context Chain

Read these files before giving project-state advice or suggesting changes:

1. `/home/evo/workspace/AI_SESSION_BOOTSTRAP.md`
2. `/home/evo/workspace/AGENTS.md`
3. `/home/evo/workspace/DNA/AGENTS.md`
4. `/home/evo/workspace/DNA/agents/AI_CONTEXT.md`
5. `/home/evo/workspace/DNA/ops/CONVENTIONS.md`
6. `/home/evo/workspace/DNA/ops/STACK.md`
7. `/home/evo/workspace/DNA/ops/TRANSITION.md`
8. `/home/evo/workspace/DNA/INBOX.md`
9. `/home/evo/workspace/DNA/ops/DECISION_LOG.md`

Consult `/home/evo/workspace/DNA/ops/TECH_RADAR.md` only on demand.

## Current Working Model

- Primary workspace agent: `Codex CLI`
- Advisory or review surface: Claude browser/chat using `workspace_full` or
  pasted context
- Capability-specific terminal agents: `Claude Code`, `Gemini CLI`
- Utility surfaces: `Aider`, `OpenRouter` or `Groq` API paths, and `Jules`
  when explicitly needed
- Memory remains model-agnostic: every agent should follow the same DNA chain

## Copy/Paste Starter

```text
You are working inside the Evolution Stables workspace.

Before responding, read:
1. /home/evo/workspace/AI_SESSION_BOOTSTRAP.md
2. /home/evo/workspace/AGENTS.md
3. /home/evo/workspace/DNA/AGENTS.md
4. /home/evo/workspace/DNA/agents/AI_CONTEXT.md
5. /home/evo/workspace/DNA/ops/CONVENTIONS.md
6. /home/evo/workspace/DNA/ops/STACK.md
7. /home/evo/workspace/DNA/ops/TRANSITION.md
8. /home/evo/workspace/DNA/INBOX.md
9. /home/evo/workspace/DNA/ops/DECISION_LOG.md

Treat /home/evo/workspace as canonical.
Treat /home/evo as control plane only.
Prefer /home/evo/workspace paths over any older pre-workspace path.
Prefer the live workspace DNA chain over any retired legacy reference.
Use /home/evo/.env as the single shared vault contract.
Consult /home/evo/workspace/DNA/ops/TECH_RADAR.md only on demand.
Summarize what you learned before continuing.
```

## Google Execution Rule

- Default Google work to `evolution-engine` via ADC and Vertex AI
- Do not assume raw Google API keys are the default path

## Notes

- If an external cloud agent cannot read local files, use the `workspace_full`
  snapshot or paste the context bundle instead of inventing replacements.
- Historical multi-platform prompt blocks were archived outside the workspace on
  2026-03-19.
