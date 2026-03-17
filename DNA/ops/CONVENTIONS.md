# CONVENTIONS

## Canonical Root

- `/home/evo/workspace`

## Legacy Roots

- `/home/evo/` is system home only, dotfiles only, and not canonical.

## Naming

- `AGENTS.md`: primary agent rules
- `CLAUDE.md`: Claude-only overrides
- `README.md`: human docs with AI section
- `AI_SESSION_BOOTSTRAP.md`: live map

## Env Governance

- SSOT: `/home/evo/.env` only.
- All env validation and schema enforcement must resolve from `/home/evo`.

## Tool Governance

- `/home/evo/workspace/DNA/ops/STACK.md` is the live registry for adopted, active, and locked tools.
- Do not suggest alternatives to tools locked in `STACK.md` unless `STACK.md` and `DECISION_LOG.md` are updated together.
- `/home/evo/workspace/DNA/ops/DECISION_LOG.md` records historical rationale and decision context.
- `/home/evo/workspace/DNA/ops/TECH_RADAR.md` is a consult-on-demand research journal and is not part of the default agent entry chain.

## Registered Markdown Files

- `/home/evo/workspace/AI_SESSION_BOOTSTRAP.md`
- `/home/evo/workspace/AGENTS.md`
- `/home/evo/workspace/MANIFEST.md`
- `/home/evo/workspace/DNA/AGENTS.md`
- `/home/evo/workspace/DNA/agents/AI_CONTEXT.md`
- `/home/evo/workspace/DNA/agents/MEMORY_PROTOCOL.md`
- `/home/evo/workspace/DNA/INBOX.md`
- `/home/evo/workspace/DNA/ops/CONVENTIONS.md`
- `/home/evo/workspace/DNA/ops/STACK.md`
- `/home/evo/workspace/DNA/ops/DECISION_LOG.md`
- `/home/evo/workspace/DNA/ops/TECH_RADAR.md`
- `/home/evo/workspace/DNA/ops/GEM_TECH_RADAR_PROCESSOR.md`
- `/home/evo/workspace/DNA/ops/tech-radar-intake/README.md`
- `/home/evo/workspace/DNA/ops/tech-radar-intake/2026-03-16_batch.md`
- `/home/evo/workspace/DNA/ops/tech-radar-intake/2026-03-16_handoff-documents.md`
- `/home/evo/workspace/DNA/ops/tech-radar-intake/2026-03-16_correction-rulebook.md`
- `/home/evo/workspace/DNA/ops/tech-radar-intake/2026-03-17_batch.md`
- `/home/evo/workspace/DNA/ops/tech-radar-intake/2026-03-17_picoclaw.md`
- `/home/evo/workspace/DNA/ops/TRANSITION.md`
- `/home/evo/workspace/projects/Evolution_Content/assets/library/README.md`
- `/home/evo/workspace/_docs/MERGE_PLAN_2026-03-10.md`
- `/home/evo/workspace/_docs/SITE_WIDE_ALIGNMENT_AUDIT_2026-03-12.md`
- `/home/evo/workspace/_docs/STATE_TRAP_MAP_2026-03-12.md`
- `/home/evo/workspace/_docs/AGENTS_STUB.md`
- `/home/evo/workspace/projects/SSOT_Build/docs/contracts/CURRENT_DATA_CONTRACT_2026-03-13.md`
- `/home/evo/workspace/projects/SSOT_Build/docs/contracts/FIRESTORE_WRITE_MAP_2026-03-13.md`

## Archive Convention

- All archive batches live under `/home/evo/workspace/_archive/<stream>/<YYYY-MM-DD>/`
- Every dated snapshot must contain a `MANIFEST.md` before the batch is considered closed.
- `MANIFEST.md` must list: contents by folder, notable files with one-line descriptions, and reason for archiving.
- Search pattern: `rg -n "<term>" /home/evo/workspace/_archive/*/MANIFEST.md`
- Internal archive (still relevant to active repo): keep inside the workspace archive stream until reactivation.
- External archive (retired from active repo): move to `/home/evo/workspace/_archive/`.
- Second-pass rule: after a build stabilises, promote internal archives to external.

## Operational Sync: Google Docs Context (Retired)

- Status: retired 2026-03-16.
- Google Drive is assets only going forward; no markdown mirror is active.
- Historical script retained at `/home/evo/workspace/_scripts/sync-md-context-gdocs.sh`.
- Do not treat Google Docs sync as an active context path, automation dependency, or agent entry surface.
- The active cloud-facing context path is the GitHub analysis mirror plus `CONTEXT.md`.

## Operational Sync: Git Analysis Mirror

- Script: `/home/evo/workspace/_scripts/sync-analysis-mirror-git.sh`
- Mode: one-way curated push from the local workspace into a dedicated Git mirror clone, then to the configured remote branch
- Local mirror clone default: `/home/evo/.cache/workspace-analysis-mirror`
- Remote default: `origin` URL from `/home/evo/workspace` when present, or `--remote-url` override
- Source scope:
  - root-level markdown plus key build/control files
  - all selected text/code/config files under `DNA/`, `_docs/`, `_scripts/`, `gateways/`, and `projects/`
- Excludes:
  - `_archive`, `_logs`, `_locks`, `_sandbox`, `models`, and `gateways/openclaw/sandbox`
  - embedded `.git` directories, dependency installs, caches, and build output
  - `.env` and other credential-shaped files
  - runtime-only state such as `.openclaw` and `workspace-gateway-*` snapshots
  - heavyweight generated media such as `projects/reel-generator/assets` and `projects/Evolution_Platform/public/videos`

Operational commands:
- Dry-run mirror preview:
  - `/home/evo/workspace/_scripts/sync-analysis-mirror-git.sh`
- Apply mirror sync and push:
  - `/home/evo/workspace/_scripts/sync-analysis-mirror-git.sh --apply`
- Just shortcuts:
  - `just analysis-mirror`
  - `just analysis-mirror-apply`

- The script usage block is the source of truth for the exact selection and operational behavior.

## Context Chain
← inherits from: /home/evo/workspace/AGENTS.md
→ overrides by: none
→ live map: /home/evo/workspace/AI_SESSION_BOOTSTRAP.md
→ conventions: /home/evo/workspace/DNA/ops/CONVENTIONS.md
