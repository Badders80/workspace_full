# INBOX

Deferred workspace items and active cleanup queue.

## Current Status

- `/home/evo/workspace` is canonical.
- `/home/evo` is control plane only.
- WSL is now intentionally lean: dead projects, archives, and large historical payloads should live outside WSL.
- Site-wide alignment audit is in progress.
- `seo-baseline` was archived out of the active platform surface on 2026-03-12.

## Active Cleanup Queue

- [x] Rewrite the core stale DNA docs and path references
- [x] Finish Gemini CLI auth enforcement on `vertex-ai`
- [x] Verify GCP ADC state for `evolution-engine`
- [x] Purge root-level `/home/evo` drift and remove dead WSL archive debt
- [x] Remove inactive OpenClaw/OpenFang runtime and reclaim WSL disk space
- [ ] Map state traps in `Evolution_Platform` and `SSOT_Build` into seam-ready work items
- [ ] Build a secret registry before the rotation pass
- [ ] Reboot clean and verify Docker Desktop WSL integration resumes normally against the compacted Ubuntu VHD
- [ ] Force Gemini CLI auth to `vertex-ai` at the settings level, not only through wrapper env vars
- [ ] Deduplicate `~/.gemini/skills` bundles and extension conflicts so Gemini boots without override noise
- [ ] Review audit and health scripts, retire stale wrappers, and keep only the current workspace-native checks

## Deferred Workstreams

- [ ] Evolution_Studio - contract-first rebuild. Define API surface, align status enums, and fix workspace boundaries before feature work.
- [ ] Evolution_Intelligence - module-contract rebuild. Remove placeholders, define adapters, and keep only callable or testable modules.
- [ ] Vendor or external infrastructure - excluded from merge core and requires separate contract-led scoping before reintegration.

## Archived Reactivation Candidates

- [ ] `seo-baseline` - archived legacy SEO surface. Only reactivate by explicit re-scope from `/home/evo/workspace/_archive/projects/2026-03-12/Evolution_Platform/seo-baseline`.
- [ ] `Evolution_Marketplace` - archived project surface. Only reactivate by explicit re-scope from `/home/evo/_archive/projects/2026-03-19/Evolution_Marketplace`.

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

## Session Backlog - 2026-03-16

- [ ] BUILD_SOP.md - new-build checklist with skills/agent selection step
- [ ] Starred repo inventory doc - document what exists so nothing gets rebuilt
- [x] Evolution_Marketplace - archived out of active workspace projects on 2026-03-19 (`/home/evo/_archive/projects/2026-03-19/Evolution_Marketplace`)
- [x] Fix just check - missing .env symlinks for Evolution_Content and Evolution_Marketplace
- [ ] End-of-session ritual - add a Codex prompt template that always updates `AI_SESSION_BOOTSTRAP.md` + `DNA/INBOX.md` before session close; store it in `DNA/ops/TEMPLATES.md` or an equivalent governed surface
- [ ] Trial correction rulebook - add `DNA/ops/lessons.md` to the `AI_SESSION_BOOTSTRAP.md` load sequence if present, create an initial empty `lessons.md`, then test one deliberate correction or reopen loop and log the result
- [ ] Steal Claude Skills limit - add to a `CLAUDE.md` template or `DNA/ops/TEMPLATES.md`: `Limit global or project rules or skills to 5-10 clearly defined, non-overlapping items for reliability.`
- [ ] Trial Lossless Claw - create `trial/lossless-claw`, install under `gateways/openclaw/`, run a long-context dry run, and log recall or compression behavior
- [ ] Merge three-tier Claude setup - review the Google Doc, add a modular `.claude/rules/` dir pattern, define an auto `MEMORY.md` trigger, and update templates with token-cap and negative-rules guidance

## Tech Radar Backlog - 2026-03-17

- [ ] Trial Claude Code Hooks - prototype a minimal safe hook set, dry-run it in a bounded Claude workflow, and keep any workspace-specific logic outside destructive paths
- [ ] Trial Free Claude Cowork Skills - audit 5-10 non-overlapping skills, install only the smallest useful subset, and log overlap with existing DNA and `CLAUDE.md` rules
- [ ] Trial OpenClaw free worker path - validate Ollama or other free-tier routing inside `gateways/openclaw/` only, then record cost, latency, and reliability tradeoffs
- [ ] Trial Magic Animator - animate one existing design asset, export a code-ready format, and verify whether it actually helps the current UI or marketing flow
- [ ] Trial skills.sh - install a small skill pack and record whether the ecosystem adds more value than prompt or template reuse alone
- [ ] Trial claude-mem - test the plugin in one contained Claude session and compare recall plus token drag against the current DNA + lessons approach
- [ ] Steal AionUi cron - add scheduled unattended automation concepts to the AlphaClaw watchdog or task layer if the capability is missing
- [ ] Steal SuperClaude commands - add the best 5 slash commands and any genuinely useful MCP setup patterns to the existing Claude Code Hooks trial

## Tech Radar Backlog - 2026-03-19

- [ ] Start AlphaClaw trial - `git checkout -b trial/alphaclaw && cd /home/evo/workspace/gateways/openclaw/` then install per repo with Google Workspace or Drive disabled, test watchdog plus Git sync on a dev agent, and dry-run first
- [ ] Trial skills.sh - `git checkout -b trial/skills-sh && cd /home/evo/workspace/gateways/openclaw/` then `npx skills add anthropics/skills` plus 2-3 top skills, and test on one task with Scrapling
- [ ] Trial claude-mem - `git checkout -b trial/claude-mem && cd /home/evo/workspace/gateways/openclaw/` then `curl -fsSL https://install.cmem.ai/openclaw.sh | bash` and compare it alongside the DNA chain
- [ ] Trial NVIDIA Nemotron 3 Super - `git checkout -b trial/nemotron-super && cd /home/evo/workspace/gateways/openclaw/` then pull the local Ollama model, treat the first pass as `256K` context unless proven otherwise, and test one full research or coding loop
- [ ] Trial OpenClaw + Scrapling - install the Scrapling path only inside `gateways/openclaw/`, test one bounded research scrape, and log reliability versus the current approach
- [ ] Steal autoresearch loop - add the overnight metrics-driven optimization prompt to the existing `Claude Code Hooks` trial rather than creating a separate tool path
- [ ] Trial promptfoo - `npm install -g promptfoo && promptfoo init`, add Gemini or OpenRouter providers plus a small DNA-chain eval suite, run `promptfoo eval`, and log sample results to `DNA/ops/tech-radar-intake/2026-03-17_promptfoo_test.md`
- [ ] Adopt gists.sh habit - prefer the `gists.sh` domain when sharing gists, test one sample gist view, and log the example to `DNA/ops/tech-radar-intake/2026-03-17_gistssh_test.md`
- [ ] Trial Pi agent - `npm install -g @mariozechner/pi-coding-agent`, load `/home/evo/workspace/DNA/AGENTS.md` as context, test one simple task, and log the session sample to `DNA/ops/tech-radar-intake/2026-03-17_pi_test.md`
- [ ] Trial OpenCode - install it in a bounded test path, load `/home/evo/workspace/AI_SESSION_BOOTSTRAP.md` as context, test one small execution task, and log the session sample to `DNA/ops/tech-radar-intake/2026-03-17_opencode_test.md`
- [ ] Harden Obsidian research sidecar - keep Obsidian as the local-first hub for the sidecar research layer, define what syncs in or out of the workspace, and prevent research notes from becoming a shadow source of truth over DNA
- [x] Reduce `evo-audit-partners.sh` to the preferred core set (`Codex`, `Gemini`, `Groq`, `Anthropic`) and remove retired `Kimi` or `GLM` routes from the first-level runner
- [x] Align `evo-audit-claude-meta.sh` and `evo-groq-watchdog.sh` to the reduced core partner model and workspace-native path or context-chain outputs

## Post-Nuke Plan - 2026-03-19

- [x] Complete WSL home purge and compact `S:\\WSL_Ubuntu\\ext4.vhdx`
- [ ] After reboot, verify: `wsl`, Docker Desktop Ubuntu integration, `geminic`, and `evo-doctor`
- [ ] Keep all new implementation work inside `gateways/openclaw/` only, one branch at a time
- [ ] Execute trials in this order: AlphaClaw -> skills.sh -> claude-mem -> NVIDIA Nemotron 3 Super
- [ ] Keep Google-first as policy, but document any products that still require AI Studio auth rather than Vertex so they are treated as exceptions, not defaults
