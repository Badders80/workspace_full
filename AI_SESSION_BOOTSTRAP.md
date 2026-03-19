# AI Session Bootstrap
Version: v2.2.0
Updated: 2026-03-19
Status: ACTIVE - STACK registry authority model applied

## Canonical Root
`/home/evo/workspace`

## Control Plane
- `/home/evo/` is system home only.
- Keep root usage limited to dotfiles, wrappers, auth, global tool config, and launcher behavior.
- Do not treat `/home/evo/` as the source of truth for active code or governance docs.

## Legacy Roots
- Older `/home/evo/00_DNA` references are historical and should be treated as drift unless explicitly archived.

## Required Context Files
1. `/home/evo/workspace/AI_SESSION_BOOTSTRAP.md`
2. `/home/evo/workspace/AGENTS.md`
3. `/home/evo/workspace/DNA/AGENTS.md`
4. `/home/evo/workspace/DNA/agents/AI_CONTEXT.md`
5. `/home/evo/workspace/DNA/ops/CONVENTIONS.md`
6. `/home/evo/workspace/DNA/ops/STACK.md`
7. `/home/evo/workspace/DNA/ops/TRANSITION.md`
8. `/home/evo/workspace/DNA/INBOX.md`
9. `/home/evo/workspace/DNA/ops/DECISION_LOG.md`

## Active Paths
- Workspace rules: `/home/evo/workspace/AGENTS.md`
- DNA rules: `/home/evo/workspace/DNA/AGENTS.md`
- AI context: `/home/evo/workspace/DNA/agents/AI_CONTEXT.md`
- Memory protocol: `/home/evo/workspace/DNA/agents/MEMORY_PROTOCOL.md`
- Stack registry: `/home/evo/workspace/DNA/ops/STACK.md`
- Transition log: `/home/evo/workspace/DNA/ops/TRANSITION.md`
- Decision log: `/home/evo/workspace/DNA/ops/DECISION_LOG.md`
- Deferred queue: `/home/evo/workspace/DNA/INBOX.md`
- Tech radar: `/home/evo/workspace/DNA/ops/TECH_RADAR.md` (consult on demand)
- Gate script: `/home/evo/workspace/_scripts/evo-check.sh`
- Task runner: `/home/evo/workspace/Justfile`

## Active Projects
- Evolution_Platform: `/home/evo/workspace/projects/Evolution_Platform`
- SSOT_Build: `/home/evo/workspace/projects/SSOT_Build`
- Evolution_Content: `/home/evo/workspace/projects/Evolution_Content`

## Deferred Or Archived
- `seo-baseline` is archived out of the active platform surface as of 2026-03-12.
- `Evolution_Marketplace` was archived out of the active workspace surface on 2026-03-19.
- Evolution_Studio remains a deferred rebuild workstream.
- Evolution_Intelligence remains a deferred rebuild workstream.
- External or vendor infrastructure stays outside the active merge core until re-scoped.

## Current Focus
- Control-plane alignment between `/home/evo` and `/home/evo/workspace`
- Google Cloud routing through `evolution-engine`
- State-trap mapping and repository seam planning
- Archive-first cleanup of stale surfaces

## Phase Rule
No build starts until `just check` is GREEN.

## Context Chain
<- inherits from: none (root map)
-> overrides by: /home/evo/workspace/AGENTS.md
-> live map: /home/evo/workspace/AI_SESSION_BOOTSTRAP.md
-> conventions: /home/evo/workspace/DNA/ops/CONVENTIONS.md
