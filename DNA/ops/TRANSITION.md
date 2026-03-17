# TRANSITION

> /home/evo2 deleted 2026-03-16. This document is historical.

## Purpose

Append-only merge and workspace-consolidation handoff log for the `/home/evo/workspace` canonical root.

## Daily Log

### 2026-03-10 [agent: Codex][phase-1-governance-reroot]
- Done: Wrote `/home/evo/AI_SESSION_BOOTSTRAP.md` and `/home/evo/AGENTS.md` with `/home/evo` as canonical root.
- Next: Complete Phase 2 skeleton and destination mapping before any file moves begin.
- Blocked: `DNA/` governance files and `/home/evo/_scripts/evo-check.sh` were not yet present at the new root when the bootstrap was first written.
- Decisions: `/home/evo2` is legacy only and must not be referenced as canonical for new sessions.

### 2026-03-10 [agent: Codex][phase-2-skeleton]
- Done: Created `/home/evo/DNA/`, `/home/evo/DNA/ops/`, and baseline governance docs required by the new bootstrap.
- Next: Reconcile missing active-path artifacts, especially `/home/evo/_scripts/evo-check.sh`, before merge execution advances.
- Blocked: Phase 2 destination verification still shows no local `evo-check.sh` at `/home/evo/_scripts/evo-check.sh`.
- Decisions: No file moves from `/home/evo2` have been executed in this phase.

### 2026-03-10 [agent: Codex][phase-3-selective-salvage]
- Done: Imported `/home/evo2` audit helper scripts into `/home/evo/_scripts`, rewrote them for `/home/evo` root assumptions, updated `/home/evo/Justfile` audit entries and DNA path references, and added `/home/evo/projects/Evolution_Platform/DONE.md`.
- Next: Reconcile project-level conflicts for `Evolution_Platform` and determine whether any additional lifted files can be merged without overwriting local work.
- Blocked: `/home/evo/projects/Evolution_Platform` has active local modifications and extra content not present in `/home/evo2`, so direct replacement is unsafe. `/home/evo2/projects/Evolution_Content` does not contain the expected orchestration source tree, and `/home/evo2/projects/SSOT_Build` is absent.
- Decisions: Phase 3 proceeded with governance/tooling salvage only where the merge was non-destructive. LIFT project promotion must be conflict-aware, not wholesale.

## Phase 5 — Legacy Freeze (2026-03-10)

- `/home/evo2` is now legacy reference only.
- No active scripts, agent entrypoints, or governance docs route through `/home/evo2`.
- Intentionally deferred workstreams (not blocking merge close):
  - Evolution_Studio rewrite — contract-first rebuild, separate workstream
  - Evolution_Intelligence rewrite — module-contract rebuild, separate workstream
  - `seo-baseline` — isolated, excluded from core
  - vendor/external infra — excluded from core
- These items are registered in `INBOX.md` for future scoping.

### 2026-03-10 [agent: Codex][workspace-reroot]
- Done: Created `/home/evo/workspace` skeleton, moved `Evolution_Platform` and `SSOT_Build` into `/home/evo/workspace/projects/`, copied the selected DNA files into `/home/evo/workspace/DNA/`, moved governance assets into `/home/evo/workspace/`, archived the requested project and root material into dated `/home/evo/workspace/_archive/*/2026-03-10/` batches, rewrote the workspace bootstrap, and added `/home/evo/workspace/MANIFEST.md`.
- Next: Resolve the remaining `/home/evo/projects/External` wrapper if elevated permissions are later available, and decide whether `/home/evo/projects/.gemini.md` should remain untouched under the no-dotfiles rule or be archived by explicit exception.
- Blocked: `/home/evo/projects/External` is root-owned and cannot be moved across parents without elevated permissions. `/home/evo/projects/.gemini.md` was intentionally left untouched because the task also forbids touching dotfiles.
- Decisions: `/home/evo/workspace` is the active working surface. `/home/evo/` remains system home only, with `.env` still SSOT at `/home/evo/.env`.

### 2026-03-11 [agent: Codex][ssot-build-minimum-tidy]
- Done: Reviewed `/home/evo/workspace/projects/SSOT_Build`, updated workspace gate paths in `Justfile` and `_scripts/evo-check.sh`, refreshed `SSOT_Build` README paths, and changed the app bootstrap flow to prefer the latest seed snapshot over stale localStorage payloads while preserving local edits.
- Next: Restore a consistently documented canonical intake source for `SSOT_Build` and then rerun build/demo checks.
- Blocked: `SSOT_Build` build currently depends on `intake/v0.1/seed.json`, which is absent in the working tree until restored or redefined.
- Decisions: Minimum tidy-up before sharing prioritizes buildability, current workspace path correctness, and demo freshness over broader refactors.

### 2026-03-11 [agent: Codex][session-close-ssot-build]
- Done: Restored `SSOT_Build` intake seed from the existing public snapshot, verified `npm run build`, `just check`, and `npx tsc --noEmit`, and added a short next-steps handoff to `/home/evo/workspace/projects/SSOT_Build/README.md`.
- Next: Triage the tracked deletions and untracked assets inside `SSOT_Build`, then do a presentation-focused cleanup pass on bundle size and oversized `App.tsx`.
- Blocked: The legacy `evo` wrapper in `/home/evo/.local/bin/evo` and shell aliases still point to pre-workspace script paths, but they were left untouched because dotfiles and dot-directories are out of scope.
- Decisions: For the current handoff, workspace-native checks are the authoritative gate and the README now holds the immediate follow-up items for the next session.

### 2026-03-11 [agent: Codex][asset-library-recovery]
- Done: Identified the recovered raw asset bundle in the workspace archive, copied it into `/home/evo/workspace/projects/Evolution_Content/assets/library/originals/`, added a reusable asset-mapping script at `/home/evo/workspace/_scripts/asset_library_map.py`, and documented the library plus report outputs.
- Next: Decide whether to also re-home the `/mnt/s/Evolution-Content-Factory/assets` working library into the workspace or keep that path linked as an external working source.
- Blocked: The content-factory working library still lives on `/mnt/s/Evolution-Content-Factory/assets`, so the workspace library remains partly linked to an external location until that move is scoped.
- Decisions: `projects/Evolution_Content/assets/library/` is the canonical discovery surface for asset recovery work in the new workspace; the recovered bundle now lives there as real directories, and `Evolution_Platform/public/images` remains a distribution copy unless a file exists only there.

### 2026-03-12 [agent: Codex][site-wide-alignment-start]
- Done: Archived `projects/Evolution_Platform/seo-baseline` into `/home/evo/workspace/_archive/projects/2026-03-12/Evolution_Platform/seo-baseline`, added the required archive `MANIFEST.md`, rewired root launcher scripts to delegate to `/home/evo/workspace/_scripts`, and replaced stale `/home/evo/00_DNA` context loading with workspace-native context helpers.
- Next: Rewrite the remaining stale DNA docs that still describe `/home/evo/00_DNA` as canonical, then continue the repo-by-repo state-trap mapping for cloud seams.
- Blocked: `~/.gemini/settings.json` still advertises `gemini-api-key` auth, so Gemini CLI itself still needs a verified settings pass after the launcher cleanup.
- Decisions: `seo-baseline` is no longer part of the active `Evolution_Platform` surface; Google local-tool routing now defaults to `evolution-engine` ADC conventions via the control plane instead of exporting raw Google API keys into every shell.

### 2026-03-12 [agent: Codex][docs-auth-seam-map]
- Done: Rewrote the workspace bootstrap, AGENTS, manifest, AI context, memory protocol, and inbox docs for the real `/home/evo/workspace` operating model; added Gemini system settings that enforce `vertex-ai`; switched user Gemini settings to `vertex-ai`; and wrote the first seam-ready state trap map at `/home/evo/workspace/_docs/STATE_TRAP_MAP_2026-03-12.md`.
- Next: Verify live ADC auth against `evolution-engine`, then start implementing the first repository seam in `Evolution_Platform`.
- Blocked: The ADC credential file exists locally, but `gcloud auth application-default print-access-token` is still not succeeding from the current shell.
- Decisions: Gemini CLI auth is now locked to `vertex-ai` by config, while local API-key auth is intentionally scrubbed from the control-plane bootstrap.

### 2026-03-13 [agent: Codex][reel-generator-google-path]
- Done: Audited `projects/reel-generator` against the workspace Google-first rules, confirmed the Gemini Developer API key works for text but has zero image quota, confirmed Vertex AI auth is blocked by stale ADC reauthentication (`invalid_rapt`), installed a local Google Cloud CLI at `/home/evo/google-cloud-sdk`, updated `/home/evo/.env` with `GOOGLE_GENAI_USE_VERTEXAI=true`, `GOOGLE_CLOUD_PROJECT=evolution-engine`, and `GOOGLE_CLOUD_LOCATION=global`, and rewired `scripts/generate_nanobanana.py` to support Vertex/ADC diagnostics plus explicit Google auth mode selection.
- Next: Refresh ADC with `gcloud auth application-default login --project evolution-engine`, then rerun `python3 scripts/generate_nanobanana.py --diagnose-google` and a real image generation test on Vertex AI.
- Blocked: Vertex AI remains unusable until the local Google user credential is reauthenticated; the existing Developer API key still has no Gemini image quota.
- Decisions: `reel-generator` should follow the workspace-standard Google execution path by default: Vertex AI on `evolution-engine` with ADC first, Developer API key second only as a compatibility and diagnostics path.

### 2026-03-13 [agent: Codex][reel-generator-google-validated]
- Done: Verified refreshed ADC for `alex@evolutionstables.nz`, confirmed `gcloud auth application-default print-access-token` works, fixed the Vertex request payload shape in `projects/reel-generator/scripts/generate_nanobanana.py`, proved Vertex text and image generation both succeed against `evolution-engine`, and reran the original `gemini_baseline_test_batch.json` successfully with `Processed: 4/4` and `Successful: 4/4`.
- Next: Review the generated comparison set under `projects/reel-generator/assets/gemini-baseline-compare/test/`, decide whether to keep `gemini-3-pro-image-preview` as the first-choice model, and extend the same Vertex-native pattern to the next Google-first generation workflow.
- Blocked: The standalone Gemini Developer API key still has zero image quota, but this no longer blocks the Google-first path because Vertex AI is now working through ADC.
- Decisions: For this workspace, successful Gemini image generation should be treated as a Vertex/ADC capability on `evolution-engine`, not as a signal that the separate Developer API key has been fixed.

### 2026-03-13 [agent: Codex][reel-generator-test-batch-validated]
- Done: Ran the default command shape `python3 scripts/generate_nanobanana.py --batch prompts/test_batch.json` successfully through the Vertex default path, generated all 5 prompts without overrides, saved the batch manifest at `/home/evo/workspace/projects/reel-generator/assets/adhoc/gemini_batch_results_20260313_153414.json`, and updated the batch-label fallback so unlabeled batch files now group outputs under their filename stem instead of `assets/adhoc`.
- Next: Re-run future unlabeled prompt batches to confirm the new filename-stem label behavior lands assets under cleaner folders such as `assets/test_batch/` or add explicit labels inside batch JSON when a named run is desired.
- Blocked: The already-generated `test_batch.json` assets from this run remain under the historical `adhoc` label because they were produced before the fallback improvement.
- Decisions: Default Google-first runs should be usable with no extra flags; `--auth-mode vertex` is now optional rather than required for routine execution.

### 2026-03-13 [agent: Codex][reel-generator-review-bundles]
- Done: Added a desktop review helper at `/home/evo/workspace/projects/reel-generator/scripts/build_review_bundle.ps1` that reads a successful Gemini batch manifest, creates a contact sheet PNG, and exports a CSV review manifest with keep/rating/notes columns so successful labels can be curated into a reusable asset library.
- Next: Run the review helper on the live `adhoc` and `library-v1` labels, pick keepers by shot role, and use those selections to define the first approved reel asset pack.
- Blocked: The existing Python contact-sheet helper could not be validated from this desktop thread because direct `wsl.exe` execution is hanging here; the new PowerShell review path is the validated desktop fallback.
- Decisions: For reel-generator, a successful generation batch is not considered operationally complete until it also has a human-review surface: a contact sheet plus a curation manifest.

### 2026-03-13 [agent: Codex][reel-generator-v2-backfill-prep]
- Done: Added `/home/evo/workspace/projects/reel-generator/prompts/library_v2_backfill_batch.json` as the next deliberate generation pass, targeting the visible gaps after `adhoc` and `library-v1`: tighter equine foreground detail, cleaner midground rail and start-gate layers, more panoramic backgrounds, and vertical-safe reel portraits.
- Next: Curate the keepers from `adhoc` and `library-v1`, then run the backfill batch only for the missing shot roles instead of spending quota on another broad exploratory pass.
- Blocked: The next batch is intentionally not auto-run because prompt quality is already strong and the smarter use of quota now depends on human keeper selection.
- Decisions: Post-authentication generation work should shift from generic testing to targeted library completion, with each new batch justified by a visible asset gap.

### 2026-03-13 [agent: Codex][ssot-build-modular-contract]
- Done: Wrote `/home/evo/workspace/projects/SSOT_Build/docs/contracts/CURRENT_DATA_CONTRACT_2026-03-13.md` to freeze the modular SSOT model: `Horses`, `Trainers / Stables`, `Owners`, `Governing Bodies`, and `Lease Commercial Terms` as the only canonical inputs to HLT; updated the `SSOT_Build` README to point at the contract; and registered the new markdown file in workspace conventions.
- Next: Map each current `SSOT_Build` save action to one canonical Firestore write surface, then replace browser-local overlay persistence with repository writes behind the same module boundaries.
- Blocked: `SSOT_Build` still persists most runtime edits in browser `localStorage`, so the new contract is defined but not yet enforced by the implementation.
- Decisions: `SSOT_Build` is the only canonical authoring surface for horse and lease data; HLT is a derived assembly outcome that only becomes valid when one qualified `horse`, `trainer/stable`, `owner`, and `governing body` are combined with complete lease commercial terms.

### 2026-03-13 [agent: Codex][ssot-build-gemini-route-cleanup]
- Done: Reviewed the new `SSOT_Build` contract and Firestore write-map docs, confirmed the current UI no longer calls the old Gemini profile proxy, removed the unused `/__gemini_profile` middleware from `projects/SSOT_Build/vite.config.ts`, and updated `docs/architecture/CURRENT_BUILD_MAP_2026-03-11.md` to remove the stale middleware reference.
- Next: Start repository extraction inside `SSOT_Build` for `horses`, `trainers`, `owners`, `governing_bodies`, `lease_terms`, and `hlt_records`, then replace local `save*` and edit-overlay flows behind those repository seams.
- Blocked: The Firestore architecture is ready enough to code against, but the write boundaries are still documented in project-local docs rather than a neutral workspace-wide Firestore contract surface, and runtime persistence is still local-first until the repositories are implemented.
- Decisions: The obsolete direct Gemini Developer API route in `SSOT_Build` is removed under the archive-first policy; active SSOT work should only keep local middleware routes that are still used by the current UI or explicitly required for the next migration step.

### 2026-03-13 [agent: Codex][ssot-build-identity-vs-association-refine]
- Done: Refined the active `SSOT_Build` contract and Firestore write map so horse identity truth is explicitly separated from current HLT associations; the horse module now treats the microchip plus Stud Book evidence as intrinsic identity, while trainer/stable, owner, and governing-body links are documented as mutable current association state for HLT readiness rather than horse identity itself. Updated the repo README to reflect the same sequence.
- Next: Build repository extraction around explicit module qualification helpers: horse identity qualification, current association readiness, and lease qualification, then route HLT generation through those preconditions.
- Blocked: The current runtime still mixes identity and association data in `App.tsx` state and save flows, so the refined boundary exists in docs but not yet in implementation.
- Decisions: The stable SSOT abstraction is module qualification, not individual field coupling; HLT should depend on qualified modules plus lease terms, not on hidden per-field UI assumptions.

### 2026-03-13 [agent: Codex][ssot-build-horse-stage-one-shape]
- Done: Tightened the `SSOT_Build` contract and Firestore write map to define the first concrete Firestore write surface as `horses/{microchip_number}` for horse identity only; renamed the key source links to `pedigree_url` and `horse_performance_url`, mapped current UI field names toward the stage-one Firestore shape, and documented that associations and media are intentionally out of scope for the initial horse registration pass.
- Next: Scaffold the stage-one horse repository around the documented `horses/{microchip_number}` contract, including the field mapping from current local `horse_id`, `breeding_url`, and `performance_profile_url` names.
- Blocked: The live app still writes local horse state with the old field names and mixed identity/association semantics, so the new Firestore shape is documented but not yet enforced in code.
- Decisions: Stage one Firestore work should focus on horse identity truth only; current associations are deferred and media/assets remain out of the horse document entirely.

### 2026-03-13 [agent: Codex][ssot-build-firestore-write-map]
- Done: Wrote `/home/evo/workspace/projects/SSOT_Build/docs/contracts/FIRESTORE_WRITE_MAP_2026-03-13.md` to map the current `SSOT_Build` local save actions to future Firestore write surfaces, distinguishing canonical module writes from derived HLT, document, and archive outputs; updated the README docs index; and registered the markdown file in workspace conventions.
- Next: Start the code implementation by extracting repository interfaces and replacing the current horse, trainer, owner, governing-body, and lease save paths with module-specific repositories.
- Blocked: The current app still uses `localStorage`, local custom arrays, and local edit maps as the active write path, so repository-backed Firestore writes do not exist yet.
- Decisions: Firestore rollout should follow the same module boundaries as the contract: canonical collections first, derived HLT and document records second, downstream consumers last.

### 2026-03-13 [agent: Codex][ssot-build-firestore-horse-samples]
- Done: Added a reusable stage-one horse Firestore mapper at `/home/evo/workspace/projects/SSOT_Build/src/lib/ssot/firestore-horse-stage-one.ts`, prepared Firestore-ready sample payloads for First Gear and Prudentia at `/home/evo/workspace/projects/SSOT_Build/data/firestore/stage-one/horses.prudentia-first-gear.json`, updated the `SSOT_Build` README with a first-run console workflow, and corrected the write-map assumption so `stud_book_id` is derived from Stud Book source evidence rather than copied from the legacy local `horse_id`.
- Next: Add the first write-side horse repository that uses the same stage-one mapping, then decide whether the initial live write path should be Firebase Console only, an admin script, or a browser-side Firestore adapter.
- Blocked: The repo still does not contain a validated live Firestore write adapter or Firebase SDK wiring, so this pass prepares the contract and operator workflow without performing real writes.
- Decisions: For stage-one horse registration, the Firestore document key is the microchip and the Stud Book ID must come from source evidence, not the local `HRS-*` identifiers.

### 2026-03-13 [agent: Codex][ssot-build-sync-status-and-image-path]
- Done: Verified that `evolution-engine` currently has no default Firestore database yet, added a small local-first horse sync-status layer inside `projects/SSOT_Build/App.tsx`, added reusable sync and profile-image path helpers under `src/lib/ssot/`, added a repo script to write the prepared stage-one horse docs once Firestore exists, and documented the Cloud Storage image-path rule in the repo README.
- Next: Create the Firestore database with the chosen mode and location, run the stage-one horse write script, then replace the manual sync status with a real Firestore-backed check.
- Blocked: Live Firestore writes are still blocked because the project currently returns `404` for database `(default)`; there is no Firestore database provisioned in `evolution-engine` yet.
- Decisions: Do not remove local repository content while the Firestore seam is unproven; keep horse sync state manual and local-first until the database and read/write adapter exist, and keep profile-image blobs out of Firestore in favor of Cloud Storage object paths.

### 2026-03-13 [agent: Codex][ssot-build-live-firestore-horses]
- Done: Wrote the two stage-one horse identity docs into the live Firestore database for `evolution-engine` in Native mode (`australia-southeast1`) using ADC-backed REST calls, then verified the live `horses` collection contains `horses/985125000126462` for Prudentia (`stud_book_id: 427416`) and `horses/985125000126713` for First Gear (`stud_book_id: 428364`). Updated the `SSOT_Build` README with the automated write command that targets the prepared stage-one payload.
- Next: Replace the manual horse sync state with a real Firestore-backed read check so the UI can show `local`, `firestore`, or `synced` automatically for the live horse records.
- Blocked: The current desktop shell still does not have Python/Node available directly, so live writes were executed through Firestore REST instead of the repo script; the browser app still lacks a validated Firestore read adapter.
- Decisions: Stage one is now operational on the real Google project; keep the local repository content and manual sync overlay until the browser-side Firestore seam is implemented and parity-checked.

### 2026-03-13 [agent: Codex][session-close-ssot-firestore]
- Done: Closed the day with stage-one horse identity live in Firestore for `evolution-engine`, local repository content preserved in `SSOT_Build`, a manual sync-state layer present in the UI, and Cloud Storage image-path planning documented rather than prematurely pushed into Firestore.
- Next: Wire Firestore into the build itself: implement the browser-side horse read seam, compare Firestore horse docs against the local seed/custom horse surface, and replace the manual `local|firestore|synced` status with an automatic check.
- Blocked: The app still reads from the local seed path only; Firestore is live for the first two horses, but there is no validated browser-side Firestore repository or parity check yet.
- Decisions: The next session should prioritize Firestore integration into `SSOT_Build` over more contract/design work, using the now-live `horses` collection as the first real seam.

### 2026-03-16 [agent: Codex][workspace-git-attach]
- Done: Read the required workspace context chain, confirmed `/home/evo/workspace` was not yet a git repository, initialized it with branch `main`, and attached `origin` to `https://github.com/Badders80/workspace.git`.
- Next: Add a deliberate top-level `.gitignore`, inspect what should actually belong in the repository, and only then create the first commit and push if requested.
- Blocked: The workspace is about `60G` and had no root `.gitignore`, so an initial add/commit/push would be unsafe without a scoping pass.
- Decisions: The GitHub repo is attached at the workspace root, but no files were staged, committed, or pushed in this session.

### 2026-03-16 [agent: Codex][workspace-cloud-snapshot-push]
- Done: Reframed the GitHub path around a dedicated analysis mirror: the active workspace now has a scripted export-and-push workflow that collects the text-first build surface from root files plus `DNA/`, `_docs/`, `_scripts/`, `gateways/`, and `projects/`, while excluding archives, sandboxes, runtime state, and heavy generated media.
- Next: Use the scripted mirror flow for the first real push, then reuse it for future cloud-analysis refreshes instead of trying to treat the live workspace root as a normal git worktree.
- Blocked: The active workspace still contains embedded git repositories, so a naive `git add .` at the root would create embedded-repo pointers instead of shipping the actual project files; the dedicated mirror clone avoids that trap.
- Decisions: The GitHub mirror is the curated "brains of the build" surface, operated through a separate cached clone and clean export path rather than direct commits from the live workspace root.

### 2026-03-16 [agent: Codex][workspace-analysis-mirror-live]
- Done: Created `/home/evo/workspace/_scripts/sync-analysis-mirror-git.sh`, added `just analysis-mirror` and `just analysis-mirror-apply`, cleaned the abandoned root-repo staged index, ran the first live GitHub mirror push to `https://github.com/Badders80/workspace.git`, and verified commit `0790dc0` on `main`. The pushed mirror contains `466` selected files at roughly `6.6M`.
- Next: Re-run `just analysis-mirror-apply` whenever the cloud-analysis repo should be refreshed, and tune the include/exclude rules only if future AI review needs a missing code/config surface.
- Blocked: The live workspace root still is not intended to be used as a normal git worktree; the durable operational path is the cached mirror clone at `/home/evo/.cache/workspace-analysis-mirror`.
- Decisions: Runtime gateway snapshots are excluded from the mirror, the script performs a lightweight secret preflight before committing, and local git hooks are bypassed only inside the cached mirror clone after that preflight passes.

### 2026-03-16 [agent: Codex][stack-registry-authority]
- Done: Created `/home/evo/workspace/DNA/ops/STACK.md`, inserted it into the required agent context chain and validation scripts, retired Google Docs sync in the live docs, marked `sync-md-context-gdocs.sh` as retired, and aligned tool-governance helpers so `STACK.md` is checked first while `TECH_RADAR.md` is consult-on-demand only.
- Next: Keep `STACK.md` and `DECISION_LOG.md` updated together whenever a tool becomes adopted, active, locked, or replaced.
- Blocked: `TECH_RADAR.md` still contains older Adopt history entries; if they diverge from `STACK.md`, treat `STACK.md` as authoritative.
- Decisions: `STACK.md` is now the live tool registry, `TECH_RADAR.md` is not part of the default entry chain, and Google Drive remains assets only.

### 2026-03-16 [agent: Codex][tech-radar-handoff-documents]
- Done: Added a raw tech-radar intake note for the Charles J Dove Claude Code handoff-document reel, distilled it into `DNA/ops/TECH_RADAR.md` as an `ASSESS` item, and brought the radar intake surface into context-chain compliance while registering the new markdown files in conventions.
- Next: Pilot the workflow in one active repo if session restart cost becomes painful, using a local markdown handoff file rather than any cloud doc surface.
- Blocked: No workspace trial has been run yet, so the pattern remains research only and is not part of the adopted stack.
- Decisions: Treat session handoff documents as a workflow pattern on the radar, not an adopted tool change; any future trial should stay markdown-first and should not revive retired Google Docs sync.

### 2026-03-16 [agent: Codex][tech-radar-memory-rules]
- Done: Reclassified the handoff-documents workflow from `ASSESS` to `ARCHIVE` because the DNA chain already covers the underlying problem, added a `TRIAL` radar entry plus raw intake note for the `tasks/lessons.md` correction-rulebook pattern, and queued both the explicit session-close ritual and the lessons-log experiment in `DNA/INBOX.md`.
- Next: Trial the correction-rulebook pattern in one bounded agent path and only promote it if it measurably reduces repeated corrections without bloating the bootstrap load.
- Blocked: There is no baseline yet for repeat-correction frequency or token-cost impact, so the lessons rulebook remains an experiment rather than an adopted memory layer.
- Decisions: Do not duplicate `AI_SESSION_BOOTSTRAP.md` with separate handoff documents; steal only the mandatory end-of-session ritual. Treat `lessons.md` as complementary anti-pattern memory, not a replacement for the DNA chain.

### 2026-03-16 [agent: Codex][tech-radar-intake-stage-1]
- Done: Rewrote `DNA/ops/tech-radar-intake/README.md` to document the new Stage 1 intake-only workflow, added the referenced `DNA/ops/GEM_TECH_RADAR_PROCESSOR.md` path as a governed stub so the workflow no longer points at a missing file, and registered that markdown file in `DNA/ops/CONVENTIONS.md`.
- Next: Replace the processor stub with the real Grok/Gem system prompt and how-to guide when that source text is available.
- Blocked: The actual processor prompt body was not included in this session, so the new processor document is a placeholder rather than the final operating prompt.
- Decisions: `tech-radar-intake/` is now explicitly a raw-dump Stage 1 surface only; distillation and Codex prompt generation belong to the separate processor stage.

### 2026-03-16 [agent: Codex][tech-radar-batch-sync]
- Done: Added the new multi-item raw intake batch, aligned `TECH_RADAR.md` with the processor-based intake workflow, added `Nano Banana 2 Prompt Libraries`, `Claude Three-Tier Memory Hierarchy`, `Claude Skills`, `Obsidian + Claude Second Brain`, `Undescribed Instagram Reel`, and `AI Design Workflows`, and reclassified `Paperclip`, `Lossless Claw`, and `Skills.sh` to match the latest fit assessments while updating related inbox tasks.
- Next: Run the backlog trials for `Paperclip`, `Lossless Claw`, and the Claude three-tier memory merge only if those workstreams rise above current platform priorities.
- Blocked: Several of the source items are Instagram reels or posts with no durable primary-source docs captured yet, so these remain judgment-based radar entries rather than verified implementation plans.
- Decisions: Treat creative-image prompt libraries as future-facing `ASSESS` only, keep design-only workflow posts archived for domain mismatch, and prefer the latest explicit fit verdict when it conflicts with an older radar status.

### 2026-03-17 [agent: Codex][tech-radar-batch-sync-2]
- Done: Added `/home/evo/workspace/DNA/ops/tech-radar-intake/2026-03-17_batch.md` to capture the full March 14-17 discovery sweep one by one, updated `TECH_RADAR.md` with new `TRIAL`, `ASSESS`, and `ARCHIVE` entries, promoted `Skills.sh`, `claude-mem`, `AionUi`, and `SuperClaude Framework` to `TRIAL`, and queued the newly promoted trials in `DNA/INBOX.md`.
- Next: Run the new trial backlog selectively, starting with the lowest-risk workflow enhancers (`Claude Code Hooks`, a small `skills.sh` or free-skills audit, and one bounded `SuperClaude` or `claude-mem` session) before heavier gateway experiments.
- Blocked: Several discoveries still come from Instagram-only surfaces or an attachment with no durable transcript, so parts of the batch remain guided by the supplied descriptions rather than fully inspectable primary docs.
- Decisions: Record the sweep in one governed batch file instead of exploding the conventions registry with dozens of new markdown files, and keep locked-tool governance intact by archiving `OpenCode` rather than advancing an orchestrator replacement without matching `STACK.md` and `DECISION_LOG.md` updates.

### 2026-03-17 [agent: Codex][tech-radar-picoclaw]
- Done: Added a focused intake note for `PicoClaw` at `/home/evo/workspace/DNA/ops/tech-radar-intake/2026-03-17_picoclaw.md`, registered it in conventions, and added `PicoClaw` to `TECH_RADAR.md` as `ASSESS`.
- Next: Revisit only if the worker tier needs a very small local runtime and we can isolate a sidecar-style experiment from the adopted `OpenClaw` gateway path.
- Blocked: The upstream repo explicitly warns that the project is still early and not suitable for production use before `v1.0`, so it is not ready for a serious integration path.
- Decisions: Treat `PicoClaw` as a worker-runtime research item rather than an `OpenClaw` replacement, which preserves current stack-governance boundaries.

## Context Chain
← inherits from: /home/evo/workspace/DNA/AGENTS.md
→ overrides by: none
→ live map: /home/evo/workspace/AI_SESSION_BOOTSTRAP.md
→ conventions: /home/evo/workspace/DNA/ops/CONVENTIONS.md
