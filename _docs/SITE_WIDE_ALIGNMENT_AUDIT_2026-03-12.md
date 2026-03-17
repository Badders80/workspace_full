# Site-Wide Alignment Audit
Date: 2026-03-12
Status: Active audit baseline

## Purpose

Establish one workable control plane for `/home/evo` and one canonical build surface at `/home/evo/workspace` before further cloud, repo, or orchestration work.

This audit is intentionally site-wide, but not uniformly deep:

- `/home/evo` is audited as control plane only.
- `/home/evo/workspace` is audited as the canonical build surface.
- Active repos are audited for drift, state traps, and archive candidates.

## Immediate Quarantine Completed

Tracked secret material was scrubbed from:

- `/home/evo/workspace/projects/Evolution_Platform/.env.example`
- `/home/evo/workspace/projects/Evolution_Platform/seo-baseline/.env.local.backup`

Follow-up still required:

- Rotate the exposed `N8N_LICENSE_KEY`.
- Rotate the exposed `N8N_API_KEY`.
- Rotate the previously stored `NEXTAUTH_SECRET` from `seo-baseline/.env.local.backup`.

## Executive Summary

The main drift source is not Firestore itself. It is the split between:

- root launchers and shell aliases,
- workspace bootstrap docs,
- stale DNA and `_docs` material,
- local API-key auth defaults,
- repo-level local-state assumptions.

The highest-leverage path is:

1. finish secret quarantine and rotation,
2. repair the root control plane,
3. rewrite or archive stale governance docs,
4. make repo dynamic state explicit behind seams,
5. then move Google-backed storage and runtime surfaces.

## Scope

### `/home/evo` control plane

Reviewed:

- `~/.env`
- `~/.bashrc`
- `~/.profile`
- `~/.bash_aliases`
- `~/.zshrc`
- `~/.local/bin/*`
- `~/.claude/*`
- `~/.gemini/*`
- `~/.codex/*`
- `~/.openclaw/*`
- `openclaw/`
- `openclaw-mission-control/`

### `/home/evo/workspace` canonical surface

Reviewed:

- `AGENTS.md`
- `AI_SESSION_BOOTSTRAP.md`
- `MANIFEST.md`
- `DNA/`
- `_docs/`
- `_scripts/`
- active repos under `projects/`

### Active repos

- `Evolution_Platform`
- `SSOT_Build`
- `Evolution_Marketplace`
- `Evolution_Content`

## Findings

### P0: Secret and auth drift

1. Root secret sprawl is real.

`/home/evo/.env` currently holds many provider secrets directly, including:

- `ANTHROPIC_API_KEY`
- `ELEVENLABS_API_KEY`
- `FAL_API_KEY`
- `FIRECRAWL_API_KEY`
- `GEMINI_API_KEY`
- `GLM_API_KEY`
- `GROQ_API_KEY`
- `HUGGINGFACE_TOKEN`
- `KIMI_API_KEY`
- `N8N_API_KEY`
- `N8N_LICENSE_KEY`
- `SUPABASE_SERVICE_ROLE_KEY`
- `ZHIPU_API_KEY`

It does not currently expose `GOOGLE_CLOUD_PROJECT`, `GOOGLE_CLOUD_LOCATION`, or other clear GCP-routing defaults in the active root vault surface.

2. Gemini is currently configured for API-key auth, not GCP-routed auth.

Evidence:

- `/home/evo/.gemini/settings.json` uses `"selectedType": "gemini-api-key"`.
- Root tooling still references `GEMINI_API_KEY`.
- No working shell bootstrap currently exports a GCP project consistently.

3. Local tool logs contain secret leakage.

`/home/evo/.codex/log/codex-tui.log` contains recorded command payloads that include raw API credentials and token-bearing commands from prior sessions. This is a local-only leak surface, but it is still a real secret sink.

4. OpenClaw stores active auth material in local config.

`/home/evo/.openclaw/openclaw.json` currently stores:

- local gateway auth token
- Telegram allowlist configuration
- `dangerouslyDisableDeviceAuth: true`

This may be acceptable for local experimentation, but it is not aligned with a hardened control plane.

### P1: Root control-plane drift

1. Root wrappers still point at pre-workspace DNA.

Stale wrappers:

- `/home/evo/.local/bin/geminic`
- `/home/evo/.local/bin/kimic`
- `/home/evo/.local/bin/kiloc`
- `/home/evo/.local/bin/dna-context`

These still reference `/home/evo/00_DNA/...` instead of `/home/evo/workspace/...`.

2. Root `evo` launcher path is broken.

Evidence:

- `~/.bashrc` defines `alias evo="/home/evo/_scripts/evo.sh"`.
- `/home/evo/_scripts/evo.sh` does not exist.
- `/home/evo/.local/bin/evo` points to `/home/evo/_scripts/evo-doctor.sh`.
- `/home/evo/_scripts/evo-doctor.sh` does not exist.

3. Google setup script is incorrect in a way that blocks stable auth bootstrap.

`/home/evo/workspace/_scripts/setup-google-services.sh` appends:

- `echo 'source ~/.env 2>/dev/null' >> $SHELL_PROFILE`

instead of appending:

- `source ~/.env 2>/dev/null`

So the shell profile is not actually being configured to source the env file.

4. Shell startup does not currently provide a stable auth bootstrap.

No active root shell file was found sourcing `~/.env`, exporting GCP routing, or normalizing Google auth consistently.

### P1: Workspace governance drift

1. Workspace bootstrap docs are mostly aligned.

These are usable as canonical root docs:

- `/home/evo/workspace/AI_SESSION_BOOTSTRAP.md`
- `/home/evo/workspace/AGENTS.md`
- `/home/evo/workspace/DNA/AGENTS.md`
- `/home/evo/workspace/DNA/ops/CONVENTIONS.md`
- `/home/evo/workspace/DNA/ops/TRANSITION.md`

2. `AI_CONTEXT.md` is stale and should not be treated as authoritative in current form.

`/home/evo/workspace/DNA/agents/AI_CONTEXT.md` still points to:

- `/home/evo/00_DNA/...`
- `/evo/...`
- legacy project status tables
- projects that are not current active surfaces

3. `DECISION_LOG.md` mixes important history with now-wrong root assumptions.

`/home/evo/workspace/DNA/ops/DECISION_LOG.md` still presents `/home/evo/projects`, `/home/evo/00_DNA`, and `/evo/.env` era conventions as if they were current runtime rules.

4. `_docs/` contains multiple stale planning artifacts that now compete with the bootstrap layer.

Most likely archive-first candidates:

- `/home/evo/workspace/_docs/AGENTS_STUB.md`
- `/home/evo/workspace/_docs/MERGE_PLAN_2026-03-10.md`
- `/home/evo/workspace/_docs/EVOLUTION_MASTER_CONTEXT.md`
- `/home/evo/workspace/_docs/HOLISTIC_EVO_AUDIT_20260301_220928.md`

5. `MANIFEST.md` under-declares the current project surface.

`/home/evo/workspace/MANIFEST.md` only lists `Evolution_Platform` and `SSOT_Build` as active projects, while the actual workspace also contains `Evolution_Marketplace` and `Evolution_Content`.

### P1: Repo state traps and cloud blockers

#### Evolution_Platform

1. Direct SSOT file reads are still live.

`/home/evo/workspace/projects/Evolution_Platform/src/lib/ssot/seed-loader.ts` reads `SSOT_Build/intake/v0.1/seed.json` directly from disk.

2. HLT draft state is still filesystem-bound.

`/home/evo/workspace/projects/Evolution_Platform/src/app/api/ssot/hlt/route.ts`:

- creates directories
- enumerates JSON files
- reads JSON files
- writes JSON files

This is a repository-seam blocker.

3. Additional dynamic state reads are still local filesystem reads.

Examples:

- updates HTML under `public/updates`
- media files under `public/videos/prudentia`

4. Google Sheets fallback URLs are hardcoded in runtime routes.

Examples:

- `/home/evo/workspace/projects/Evolution_Platform/src/app/api/interest/route.ts`
- `/home/evo/workspace/projects/Evolution_Platform/src/app/api/auth/[...nextauth]/route.ts`

These are not GCP-routed, not centralized, and not explicitly governed.

5. A Python/SQLite/ComfyUI subtree is embedded inside the repo.

Notable paths:

- `/home/evo/workspace/projects/Evolution_Platform/app/database/`
- `/home/evo/workspace/projects/Evolution_Platform/app/assets/database/`
- `/home/evo/workspace/projects/Evolution_Platform/app/frontend_management.py`

This appears unrelated to the active Next.js web surface and is a strong archive candidate unless it has a confirmed live owner.

6. The repo still exposes an ambiguous edit surface.

`app/` is mostly a wrapper/re-export shell for `src/app/`, but both exist. That is better than two divergent apps, but it still creates an easy place for accidental edits and confusion.

7. `seo-baseline` remains an active drift magnet.

It is explicitly deferred in workspace rules, but it still contains:

- auth routes
- env backup
- duplicate local state behavior

This should be archived or frozen more aggressively.

#### SSOT_Build

1. The app is intentionally local-first, and still fully local-first.

Current live rules include:

- canonical `intake/v0.1/seed.json`
- runtime fetch of `/intake/v0.1/seed.json`
- local browser persistence via `localStorage`
- dev middleware writes to local filesystem

2. Gemini usage is API-key based in dev middleware.

`/home/evo/workspace/projects/SSOT_Build/vite.config.ts` reads `GEMINI_API_KEY` directly for the Gemini profile route.

3. Repository-seam documentation exists, but runtime seams do not.

The README backlog is directionally correct, but it is still only backlog.

4. Seed metadata still contains stale absolute paths.

`seed.json` still carries `/home/evo/projects/SSOT_Build/...` values in document paths and `_meta.sourcePath`.

#### Evolution_Marketplace

This repo currently looks much cleaner than the others:

- local demo mode exists
- Supabase is explicit
- no obvious Firestore drift
- no obvious secret leaks in tracked files were found in this pass

It is not the urgent source of platform drift right now.

#### Evolution_Content

This currently behaves more like an asset/library surface than an active runtime codebase. It is low-risk from a cloud/state standpoint, but still participates in workspace drift through symlink-heavy library structure.

### P1: GCP alignment drift

1. The intent is Google-first, but the runtime control plane is not.

Evidence chain:

- `GOOGLE_FIRST_STRATEGY.md` describes Vertex/ADC direction.
- `setup-google-services.sh` is broken.
- root shell does not source env reliably.
- `.gemini/settings.json` is set to API-key auth.
- root `.env` surface lacks active `GOOGLE_CLOUD_PROJECT` routing in the current shell bootstrap.

2. Google auth policy needs to distinguish local human tooling from shared/runtime tooling.

Required rule:

- shared tooling, automations, deployed services, and orchestrators must use GCP ADC/service accounts bound to `evolution-engine`
- local human exceptions may exist, but must be explicit and never silently fall back to `GEMINI_API_KEY` or `GOOGLE_API_KEY`

## Capability Map

### OpenClaw

Existing capability surface:

- Local gateway config in `/home/evo/.openclaw/openclaw.json`
- Workspace path already aimed at `/home/evo/workspace/gateways/openclaw/workspace`
- Telegram channel enabled with allowlist
- Token auth enabled for gateway
- Mission Control repo at `/home/evo/openclaw-mission-control`
- FastAPI backend in `/home/evo/openclaw-mission-control/backend/app/main.py`
- API-first model documented in `/home/evo/openclaw-mission-control/README.md`
- Local UI documented at `http://localhost:3000`
- Backend health documented at `http://localhost:8000/healthz`
- OpenAPI export script present: `backend/scripts/export_openapi.py`
- Board webhook API surfaces present in backend router wiring

### Gemini

Existing capability surface:

- User-level Gemini config in `/home/evo/.gemini`
- Auth currently set to API-key mode
- Multiple extensions enabled across `/home/evo/*`
- Installed extensions include `vertex`, `github`, `postgres`, `devops`, `web-accessibility`, `huggingface`, `gemini-llm-council`, and others
- Antigravity MCP config file exists but is currently empty

### Evolution_Platform

Existing programmatic capability surface:

- Next.js API routes under `src/app/api/`
- auth, interest, media, updates, SSOT read routes, HLT draft route

### SSOT_Build

Existing programmatic capability surface:

- Vite middleware endpoints in `vite.config.ts`
- investor update write endpoint
- URL proxy
- AI profile proxy endpoints for Anthropic, GLM/Zhipu, Groq, and Gemini

## Archive Candidates

Archive-first candidates that are likely causing more confusion than value:

1. `/home/evo/workspace/_docs/AGENTS_STUB.md`
2. `/home/evo/workspace/_docs/MERGE_PLAN_2026-03-10.md`
3. `/home/evo/workspace/_docs/EVOLUTION_MASTER_CONTEXT.md`
4. `/home/evo/workspace/_docs/HOLISTIC_EVO_AUDIT_20260301_220928.md`
5. `/home/evo/workspace/projects/Evolution_Platform/seo-baseline/`

Assess-and-archive candidates:

1. `/home/evo/workspace/projects/Evolution_Platform/app/database/`
2. `/home/evo/workspace/projects/Evolution_Platform/app/assets/database/`
3. orphaned root wrapper conventions that still target `/home/evo/00_DNA` or `/home/evo/_scripts`

Do not archive yet:

1. `/home/evo/workspace/DNA/agents/AI_CONTEXT.md`

Reason:

It is stale, but still functions as a conceptually important entrypoint and should be rewritten, not discarded blindly.

## Recommended Governance Model

### `/home/evo`

Keep this minimal and stable:

- root env vault
- root env loader
- launcher wrappers
- shell bootstrap
- preferred auth defaults
- tool login state
- OpenClaw/Gemini/Codex local config

Do not treat `/home/evo` as a documentation or project working surface.

### `/home/evo/workspace`

This is the operational source of truth:

- workspace bootstrap
- AGENTS and DNA rules
- archive policy
- provider strategy
- repo inventory
- orchestration model
- active roadmap docs

### Repo level

Each repo should only hold:

- implementation details
- repo-local exceptions
- env examples with placeholders only
- README material specific to that repo

## Secret System Design

### 1. One local dev vault

Keep `/home/evo/.env` as the local human-dev vault for now.

Rules:

- real values live only here or in other explicitly local secret files
- never commit real values to tracked files
- no duplicated project-owned copies unless a project truly requires a local-only override

### 2. One metadata registry

Create a metadata-only registry in workspace DNA, for example:

- `/home/evo/workspace/DNA/ops/SECRET_REGISTRY.md`

Each key should record:

- variable name
- provider
- owner
- consumers
- storage location
- scope
- rotation status
- last rotated

Never store values in the registry.

### 3. One env schema

Keep `/home/evo/.env.schema` as the declared key contract.

Use it for:

- allowed variables
- descriptions
- scope classification
- whether the variable belongs in local dev, cloud runtime, or both

### 4. Google rules

For Google ecosystem access:

- ADC/service accounts are mandatory for shared tools, automation, runtime, and deployed workloads
- `GEMINI_API_KEY` and `GOOGLE_API_KEY` are break-glass or local-only exceptions
- exceptions must be explicit, documented, and not silently selected by wrappers

### 5. Cloud secret storage

For deployed/runtime workloads:

- use GCP Secret Manager
- use service accounts plus ADC for Google services
- do not depend on root `.env` in deployed environments

### 6. Local log hygiene

Treat these as secret sinks:

- `~/.codex/log/`
- tool debug logs
- backup env files
- copied shell snippets
- generated config backups

Policy:

- no raw credentials in command literals
- no logging of secret values
- periodic purge or archive-with-redaction for local logs that captured credentials

### 7. Project env examples

All `*.env.example` files must contain placeholders only.

Also:

- no backup env files with real values inside repos
- no API tokens inside sample configs

## Roadmap

### Phase 0: Finish secret quarantine

1. Rotate `N8N_LICENSE_KEY`
2. Rotate `N8N_API_KEY`
3. Rotate the `NEXTAUTH_SECRET` previously stored in `seo-baseline/.env.local.backup`
4. Audit local logs and config backups for credentials that should be purged or archived with redaction

### Phase 1: Repair the root control plane

1. Rewrite `geminic`, `kimic`, `kiloc`, and `dna-context` to use `/home/evo/workspace/...`
2. Replace the broken `evo` alias and wrapper with a workspace-aware launcher
3. Fix `setup-google-services.sh`
4. Add one explicit root auth loader instead of ad hoc shell behavior

### Phase 2: Reassert canonical docs

1. Rewrite `DNA/agents/AI_CONTEXT.md` for workspace reality
2. Rewrite or split `DNA/ops/DECISION_LOG.md` into historical decisions vs current rules
3. Update `MANIFEST.md` project status
4. Archive stale `_docs` planning/context files

### Phase 3: Normalize secret governance

1. Add `SECRET_REGISTRY.md`
2. Normalize `.env.schema`
3. Define Google auth policy
4. Move runtime/deployed secret strategy to Secret Manager + ADC

### Phase 4: Clean repo boundaries

1. Freeze `Evolution_Platform/src/app` as canonical app surface
2. Keep `app/` as wrapper-only or collapse it deliberately
3. Decide whether the Python/ComfyUI subtree in `Evolution_Platform` is in-scope or archive material
4. Archive `seo-baseline`

### Phase 5: Build repository seams

1. `SsotReadRepository`
2. `SsotDraftRepository`
3. `BlobStore`

Start with local implementations as default.

### Phase 6: Google alignment

1. Make ADC the default for shared/runtime Google tooling
2. Stand up Firestore Native only after seams exist
3. Use GCS for blobs and generated artifacts
4. Move runtime services to Cloud Run when repo boundaries and storage seams are stable

## Recommended Next Move

Do these next, in order:

1. Fix root wrappers and shell bootstrap.
2. Rewrite `AI_CONTEXT.md`.
3. Archive stale `_docs`.
4. Stand up `SECRET_REGISTRY.md` and env-schema cleanup.

That sequence will remove more drift than any immediate Firestore implementation.
