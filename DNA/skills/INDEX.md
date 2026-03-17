# Available Skills

- `ui_tweaks.md` — Safe UI component changes (CSS, Tailwind, minor JSX adjustments)
- `multi_file_debug.md` — Debugging strategy for changes across multiple files
- `release_checklist.md` — Pre-deploy verification steps
- `comfyui_vram_safety.md` — VRAM-safe workflow edits (if/when added)
- `registry/approved_sources.md` — Curated repositories and tools (don't reinvent the wheel)
- `registry/starred_repo_registry.md` — Auto-generated starred repo review registry
- `registry/starred_repo_registry.json` — Canonical starred repo registry (status/category/notes)

## 🔄 Star Sync

- Run `node scripts/sync_starred_repos.mjs` to sync GitHub stars into registry.
- New repos are auto-marked as `Assess` and existing manual statuses are preserved.

## 📊 Process & Evaluation

- `TECH_RADAR.md` — Tool evaluation tracker (Reject/Assess/Trial/Adopt)
- `_archive/2026-02/INBOX.md` — Archived rapid capture log

## 🧠 System Optimization

- `MEMORY_OPTIMIZATION.md` — WSL2 + VS Code memory fixes
- Run `just memory` to check RAM usage
- Run `just optimize-memory` for full cleanup
