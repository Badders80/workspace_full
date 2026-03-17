# Merge Plan

> /home/evo2 deleted 2026-03-16. This document is historical.

All /home/evo2 path references in docs, scripts, and env files must be replaced with /home/evo before any agent is given a new session.

Date: 2026-03-10
Scope: Workspace consolidation from `/home/evo2` back into `/home/evo`
Status: Planning only

## Objective

Re-root the canonical workspace from `/home/evo2` back to `/home/evo`, while preserving the `/home/evo2` folder model, governance patterns, and proven implementation slices.

`/home/evo2` is treated as a proved staging environment, not the long-term root.

## Target Structure

The target canonical structure under `/home/evo` is:

```text
/home/evo/
├── DNA/
├── projects/
├── _scripts/
├── _locks/
├── _logs/
├── _docs/
├── _archive/
├── _sandbox/
└── models/
```

### Structure Intent

- `DNA/`: operating brain, conventions, transition log, inbox, system prompts, workflows
- `projects/`: active product code
- `_scripts/`: workspace gates, audit runners, merge helpers
- `_locks/`: concurrency/ownership coordination
- `_logs/`: audit runs, drift reports, merge evidence
- `_docs/`: planning, execution briefs, remediation docs
- `_archive/`: retired or frozen material
- `_sandbox/`: experiments and temporary work
- `models/`: local model storage and symlinked model entry points

## Salvage Matrix

| item from `/home/evo2` | disposition | rationale | merge action in `/home/evo` |
| --- | --- | --- | --- |
| `DNA/ops/*` | MOVE | This is the strongest governance and transition record produced in the clean rebuild. | Re-home into `/home/evo/DNA/ops/`, then rewrite internal path references from `/home/evo2` to `/home/evo`. |
| `AI_SESSION_BOOTSTRAP.md` | MOVE | It is the live-map pattern the workspace was built around. | Recreate at `/home/evo/AI_SESSION_BOOTSTRAP.md` with `/home/evo` as canonical root and updated active paths. |
| `AGENTS.md` | REWRITE | The law set is valid, but the root assumptions are wrong for the merged workspace. | Replace with a `/home/evo` version before any file moves begin. |
| `Justfile` | KEEP | The task-runner pattern is valid and likely reusable if paths and targets are adjusted. | Bring forward selectively after root and path assumptions are rewritten. |
| `_scripts/evo-check.sh` and related audit helpers | MOVE | These scripts encode the gate and audit workflow that made `/home/evo2` workable. | Re-home into `/home/evo/_scripts/`, then rewrite path assumptions, env assumptions, and report destinations. |
| `projects/Evolution_Platform` | MOVE | This is an established LIFT item and the strongest proven build path. | Promote as the baseline platform app under `/home/evo/projects/Evolution_Platform`, excluding known contamination paths. |
| `projects/SSOT_Build` | LIFT | Proven build path, move as-is. | Promote directly to `/home/evo/projects/SSOT_Build`, no structural changes required. |
| `projects/Evolution_Content` | KEEP | The orchestration pattern is worth salvaging, but not every script or local workflow should be brought over as-is. | Preserve the orchestrator/worker core and port only the deterministic, documented flows. |
| Studio workspace/contracts | REWRITE | Contract mismatches, workspace drift, and missing package topology were already identified. | Rebuild the workspace and API contracts under `/home/evo/projects/Evolution_Studio` from explicit interfaces rather than copying the current shape wholesale. |
| Intelligence modules | REWRITE | Scaffold and placeholder-heavy state does not justify direct migration. | Rebuild from concrete module contracts and smoke-tested adapters only. |
| `.env` and env mirror policy | REWRITE | The `/home/evo2` one-way mirror policy becomes invalid once `/home/evo` is canonical again. | Establish `/home/evo/.env` as SSOT, remove mirror semantics, and update schema/audit enforcement accordingly. |
| `seo-baseline` | DEFER | It remains a contaminated lineage and should not be imported into the new core. | Exclude from merge scope entirely; keep isolated for read-only reference if needed. |

## Merge Phases

### Phase 1 — Governance Re-root

Required first step: update `AGENTS.md` to `/home/evo` root BEFORE any file moves begin.

Checklist:
- Draft and approve `/home/evo` workspace `AGENTS.md` with canonical root set to `/home/evo`.
- Draft and approve `/home/evo/AI_SESSION_BOOTSTRAP.md` with `/home/evo` active paths.
- Replace `/home/evo2` path assumptions in governance docs and merge instructions before any agent uses the merged workspace.
- Define the `/home/evo` context chain for `AI_SESSION_BOOTSTRAP.md`, `AGENTS.md`, `DNA/AGENTS.md`, and `DNA/ops/CONVENTIONS.md`.

Exit criteria:
- Governance docs describe `/home/evo` as canonical.
- No new session can reasonably interpret `/home/evo2` as primary.

### Phase 2 — Workspace Skeleton

Checklist:
- Ensure the target top-level `/home/evo` structure exists conceptually and in planning: `DNA/`, `projects/`, `_scripts/`, `_locks/`, `_logs/`, `_docs/`, `_archive/`, `_sandbox/`, `models/`.
- Map every retained `/home/evo2` governance file to its `/home/evo` destination.
- Define which `_docs` files are active planning records versus historical artifacts.
- Define the initial registered markdown set for the merged root.

Exit criteria:
- Every kept item from `/home/evo2` has a target home in `/home/evo`.
- No merge-classified item is homeless.

### Phase 3 — Selective Salvage Execution

Checklist:
- Port `DNA/ops/*`, `AI_SESSION_BOOTSTRAP.md`, `Justfile`, and `_scripts` gate/audit helpers into `/home/evo` with root assumptions rewritten.
- Port the proven `Evolution_Platform` baseline into `/home/evo/projects/Evolution_Platform`.
- Preserve only the validated `Evolution_Content` orchestration core and documented worker patterns.
- Exclude `seo-baseline` from the merged core.
- Keep vendor and external infra out of the canonical core migration scope.

Exit criteria:
- The merged root contains the governance and platform/content slices classified as LIFT or KEEP.
- Deferred material remains explicitly outside core scope.

### Phase 4 — Rewrite Streams and Root Normalization

Checklist:
- Rebuild Studio contracts and workspace topology in `/home/evo/projects/Evolution_Studio`.
- Rebuild Intelligence modules from explicit contracts and real adapters.
- Rewrite env governance so `/home/evo/.env` is SSOT and no `/home/evo2 -> /home/evo` mirror policy remains.
- Rewrite all scripts, docs, and task runners that still reference `/home/evo2`.
- Re-register new markdown files and conventions for the merged root.

Exit criteria:
- `/home/evo` is the only canonical root in docs, scripts, and env policy.
- No live workflow depends on `/home/evo2` as source of truth.

### Phase 5 — Stabilization and Legacy Freeze

Checklist:
- Treat `/home/evo2` as legacy reference only.
- Record final decisions and residual defer items in `/home/evo/DNA/ops/TRANSITION.md`.
- Confirm that future agents start from `/home/evo` governance files only.
- Freeze any remaining `/home/evo2` material as historical reference, not active workspace logic.

Exit criteria:
- `/home/evo` is stable and canonical.
- `/home/evo2` is no longer referenced as authoritative.

## Decision Rules

- LIFT: move proven code paths with minimal structural change.
- KEEP: preserve the pattern or file set, but reconcile selectively.
- REWRITE: rebuild around explicit contracts rather than porting current implementation shape.
- DEFER: leave outside core merge scope and keep isolated.

## Non-Goals

- Do not treat `/home/evo2` as co-canonical after the merge.
- Do not import `seo-baseline` into the merged platform core.
- Do not preserve the one-way env mirror policy after `/home/evo` becomes canonical again.
- Do not migrate vendor/external infra into the core workspace without a separate contract-led plan.

## Context Chain
← inherits from: /home/evo/_docs/AGENTS_STUB.md
→ overrides by: none
→ live map: /home/evo/AI_SESSION_BOOTSTRAP.md
→ conventions: /home/evo/DNA/ops/CONVENTIONS.md
