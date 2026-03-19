# Workspace Manifest
Created: 2026-03-10
Updated: 2026-03-19
Status: ACTIVE

## Structure
- DNA/ - operating brain, brand, conventions, skills, prompts
- projects/ - active project code
- _scripts/ - workspace gates, launchers, audit runners
- _docs/ - planning and execution briefs, including storage policy
- _locks/ - concurrency coordination
- _logs/ - audit runs and drift reports
- _archive/ - RELOCATED to /home/evo/_archive/ (outside workspace root)
- _sandbox/ - experiments and temporary work
- models/ - local model storage

## Operating Docs
- `AI_SESSION_BOOTSTRAP.md` - canonical workspace entry map
- `AGENTS.md` - workspace operating rules
- `DNA/ops/TRANSITION.md` - append-only structural handoff log
- `DNA/INBOX.md` - deferred queue and active cleanup items
- `DNA/ops/STACK.md` - live adopted and active tool registry
- `DNA/ops/DECISION_LOG.md` - architectural history and current path notices
- `DNA/ops/CONVENTIONS.md` - workspace conventions, registry authority, and active automation notes
- `_docs/STORAGE_POLICY.md` - where `C:` vs `S:` should be used for installs, data, WSL, Docker, and scratch workloads

## Automation
- Google Docs Sync - retired 2026-03-16. Google Drive is assets only and is not part of the active agent context path.
- Analysis Mirror - scripted workspace-to-GitHub analysis mirror is the active cloud AI review path without heavy archives or generated assets. See `DNA/ops/CONVENTIONS.md` for scope and commands.

## Active Projects
- Evolution_Platform - live platform, canonical at `projects/Evolution_Platform`
- SSOT_Build - mission control build, canonical at `projects/SSOT_Build`
- Evolution_Content - active content and asset surface, canonical at `projects/Evolution_Content`

## Deferred Or Archived
- `seo-baseline` was archived out of `Evolution_Platform` on 2026-03-12.
- `Evolution_Marketplace` was archived out of the active workspace projects on 2026-03-19.
- Evolution_Studio and Evolution_Intelligence remain deferred rebuild workstreams.
- External or vendor infrastructure remains excluded from the active merge core.

## Archive Index
- `/home/evo/_archive/projects/2026-03-10/` - non-active projects archived on workspace creation
- `/home/evo/_archive/projects/2026-03-12/` - `seo-baseline` removed from the active platform surface
- `/home/evo/_archive/projects/2026-03-19/` - `Evolution_Marketplace` removed from active workspace projects
- `/home/evo/_archive/root-cleanup/2026-03-10/` - root loose files archived on workspace creation
- `/home/evo/_archive/00_DNA/2026-03-10/` - original 00_DNA and DNA folders archived on workspace creation

## Search
`rg -n "<term>" /home/evo/_archive/*/MANIFEST.md`
