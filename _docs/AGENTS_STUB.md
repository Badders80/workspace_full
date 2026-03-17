# AGENTS

## Migration Status

MERGE IN PROGRESS — do not treat this workspace as stable until `MERGE_PLAN_2026-03-10.md` Phase 4 is complete.

`/home/evo2` is LEGACY during this consolidation and must not be referenced as canonical.

## Scope

Workspace-level rules for `/home/evo`.

## Canonical Root

- Canonical root is `/home/evo`.
- `/home/evo2` is a legacy reference root only.
- New sessions, live docs, and active scripts must resolve authority from `/home/evo`.

## Laws

1. Nothing is added without a home in the structure.
2. Docs lead, code follows (break-glass only for production incidents).
3. Every `.md` has a context chain.
4. One `.env` at `/home/evo/.env`.
5. No build starts without `just check` GREEN.
6. Update bootstrap before structural changes.
7. Read/update transition log every session.
8. Out-of-scope work goes to inbox.
9. Session ends with Done/Next/Blocked/Decisions.
10. Symlinks are documented or auto-scanned.
11. New `.md` files are registered in conventions.

## Target Structure

The canonical merged root follows this structure:

- `/home/evo/DNA/`
- `/home/evo/projects/`
- `/home/evo/_scripts/`
- `/home/evo/_locks/`
- `/home/evo/_logs/`
- `/home/evo/_docs/`
- `/home/evo/_archive/`
- `/home/evo/_sandbox/`
- `/home/evo/models/`

## Guardrails

- Do not treat `/home/evo2` as source of truth.
- Replace `/home/evo2` path references in docs, scripts, and env policy before issuing new agent sessions.
- Use `_locks/` for folder-level ownership during merge execution.
- Keep deferred material isolated until explicitly re-scoped.

## Active Merge Notes

- `Evolution_Platform` core build path is a LIFT item.
- `Evolution_Content` orchestration pattern is a LIFT item.
- Studio contracts/workspace, intelligence modules, env strategy, and command/gateway patterns are REWRITE items.
- External/vendor infra and `seo-baseline` remain DEFER items.

## Required Reading Order

1. `/home/evo/AI_SESSION_BOOTSTRAP.md`
2. `/home/evo/AGENTS.md`
3. `/home/evo/DNA/AGENTS.md`
4. `/home/evo/DNA/ops/CONVENTIONS.md`
5. `/home/evo/DNA/ops/TRANSITION.md`
6. `/home/evo/_docs/MERGE_PLAN_2026-03-10.md`

## Context Chain
← inherits from: /home/evo/AI_SESSION_BOOTSTRAP.md
→ overrides by: /home/evo/DNA/AGENTS.md
→ live map: /home/evo/_docs/
→ conventions: /home/evo/DNA/ops/CONVENTIONS.md
