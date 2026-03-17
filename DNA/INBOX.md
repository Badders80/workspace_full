# INBOX

Deferred workspace items and active cleanup queue.

## Current Status

- `/home/evo/workspace` is canonical.
- `/home/evo` is control plane only.
- Site-wide alignment audit is in progress.
- `seo-baseline` was archived out of the active platform surface on 2026-03-12.

## Active Cleanup Queue

- [x] Rewrite the core stale DNA docs and path references
- [x] Finish Gemini CLI auth enforcement on `vertex-ai`
- [x] Verify GCP ADC state for `evolution-engine`
- [ ] Map state traps in `Evolution_Platform` and `SSOT_Build` into seam-ready work items
- [ ] Build a secret registry before the rotation pass

## Deferred Workstreams

- [ ] Evolution_Studio - contract-first rebuild. Define API surface, align status enums, and fix workspace boundaries before feature work.
- [ ] Evolution_Intelligence - module-contract rebuild. Remove placeholders, define adapters, and keep only callable or testable modules.
- [ ] Vendor or external infrastructure - excluded from merge core and requires separate contract-led scoping before reintegration.

## Archived Reactivation Candidates

- [ ] `seo-baseline` - archived legacy SEO surface. Only reactivate by explicit re-scope from `/home/evo/workspace/_archive/projects/2026-03-12/Evolution_Platform/seo-baseline`.

## SSOT_Build Follow-Up

- [ ] Define explicit folder rules for `Horses/`, `data/`, `docs/`, and `public/`
- [ ] Verify `Horses/` contains only active structured horse-state, not issued or history items
- [ ] Update `README.md` to reflect current top-level structure accurately
- [ ] Keep anything historical, prototype-only, or superseded out of repo root and in dated archive batches

## Context Chain
<- inherits from: /home/evo/workspace/DNA/AGENTS.md
-> overrides by: none
-> live map: /home/evo/workspace/AI_SESSION_BOOTSTRAP.md
-> conventions: /home/evo/workspace/DNA/ops/CONVENTIONS.md

---

## Session Backlog — 2026-03-16

- [ ] BUILD_SOP.md — new-build checklist with skills/agent selection step
- [ ] Starred repo inventory doc — document what exists so nothing gets rebuilt
- [ ] Evolution_Marketplace — create GitHub remote and connect local repo
- [ ] Fix just check — missing .env symlinks for Evolution_Content and Evolution_Marketplace
- [ ] End-of-session ritual — add a Codex prompt template that always updates `AI_SESSION_BOOTSTRAP.md` + `DNA/INBOX.md` before session close; store it in `DNA/ops/TEMPLATES.md` or an equivalent governed surface
- [ ] Trial correction rulebook — add `DNA/ops/lessons.md` to the `AI_SESSION_BOOTSTRAP.md` load sequence if present, create an initial empty `lessons.md`, then test one deliberate correction/reopen loop and log the result
- [ ] Steal Claude Skills limit — add to a `CLAUDE.md` template or `DNA/ops/TEMPLATES.md`: `Limit global/project rules/skills to 5-10 clearly defined, non-overlapping items for reliability.`
- [ ] Trial Paperclip — create `trial/paperclip-agents`, test a dry-run install under `gateways/openclaw/`, and log budget/stop behavior without changing the wider workspace
- [ ] Trial Lossless Claw — create `trial/lossless-claw`, install under `gateways/openclaw/`, run a long-context dry run, and log recall/compression behavior
- [ ] Merge three-tier Claude setup — review the Google Doc, add a modular `.claude/rules/` dir pattern, define an auto `MEMORY.md` trigger, and update templates with token-cap and negative-rules guidance

## Tech Radar Backlog - 2026-03-17

- [ ] Trial Claude Code Hooks - prototype a minimal safe hook set, dry-run it in a bounded Claude workflow, and keep any workspace-specific logic outside destructive paths
- [ ] Trial Free Claude Cowork Skills - audit 5-10 non-overlapping skills, install only the smallest useful subset, and log overlap with existing DNA and `CLAUDE.md` rules
- [ ] Trial OpenClaw free worker path - validate Ollama or other free-tier routing inside `gateways/openclaw/` only, then record cost, latency, and reliability tradeoffs
- [ ] Trial Magic Animator - animate one existing design asset, export a code-ready format, and verify whether it actually helps the current UI or marketing flow
- [ ] Trial skills.sh - install a small skill pack and record whether the ecosystem adds more value than prompt or template reuse alone
- [ ] Trial claude-mem - test the plugin in one contained Claude session and compare recall plus token drag against the current DNA + lessons approach
- [ ] Trial AionUi - run one short CLI-unification experiment and document whether the desktop layer beats the current terminal-native workflow
- [ ] Trial SuperClaude Framework - run one bounded commands or personas workflow and measure whether the extra structure improves planning or review quality
