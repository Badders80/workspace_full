# Holistic /home/evo Workspace Audit
**Generated:** Sunday 01 March 2026 22:09:28
**Run ID:** 20260301_220928

---


## Phase 1 — Top-Level Disk Usage

```
=== /home/evo items (sorted by size) ===
51G	/home/evo/projects
11G	/home/evo/.local
7.5G	/home/evo/.venv
6.7G	/home/evo/.cache
5.7G	/home/evo/_backups
3.9G	/home/evo/.npm-global
2.4G	/home/evo/_archive
2.2G	/home/evo/.vscode-server
1.9G	/home/evo/.antigravity-server
1.7G	/home/evo/.npm
1.5G	/home/evo/.kimi
1.1G	/home/evo/.openclaw
592M	/home/evo/.gemini
364M	/home/evo/.kombai-binaries
197M	/home/evo/_sandbox
153M	/home/evo/.bun
114M	/home/evo/.codex
38M	/home/evo/openclaw-mission-control
24M	/home/evo/openclaw
6.8M	/home/evo/_docs
6.7M	/home/evo/.fzf
6.7M	/home/evo/.claude
5.2M	/home/evo/_output
4.3M	/home/evo/00_DNA
1.2M	/home/evo/.aider
852K	/home/evo/.openfang
716K	/home/evo/.docker
668K	/home/evo/evo-dotfiles
580K	/home/evo/.config
248K	/home/evo/.dotnet
196K	/home/evo/_scripts
96K	/home/evo/.vscode-remote-containers
84K	/home/evo/_logs
84K	/home/evo/.nv
72K	/home/evo/.bash_history
64K	/home/evo/.Trash
40K	/home/evo/.triton
24K	/home/evo/.ruff_cache
20K	/home/evo/.kombai
20K	/home/evo/.jules
16K	/home/evo/models
16K	/home/evo/audit_log_20260301_153605.txt
12K	/home/evo/overnight_run.sh
12K	/home/evo/SERVICE_INVENTORY.md
12K	/home/evo/.git-templates
12K	/home/evo/.copilot
8.0K	/home/evo/overnight_factory.sh
8.0K	/home/evo/QUICKSTART.md
8.0K	/home/evo/Justfile
8.0K	/home/evo/.vscode
8.0K	/home/evo/.ssh
8.0K	/home/evo/.github
8.0K	/home/evo/.bashrc.bak_20260214_140246
8.0K	/home/evo/.bashrc.bak_20260214_135911
8.0K	/home/evo/.bashrc.backup.20260228_171342
8.0K	/home/evo/.bashrc
4.0K	/home/evo/telemetry-id
4.0K	/home/evo/start_overnight.sh
4.0K	/home/evo/overnight_nohup.log
4.0K	/home/evo/overnight_log.txt
4.0K	/home/evo/install.cmd
4.0K	/home/evo/evolution.code-workspace
4.0K	/home/evo/PROJECTS_INDEX.md
4.0K	/home/evo/Downloads
4.0K	/home/evo/.zshrc
4.0K	/home/evo/.wget-hsts
4.0K	/home/evo/.vault
4.0K	/home/evo/.profile
4.0K	/home/evo/.npmrc
4.0K	/home/evo/.landscape
4.0K	/home/evo/.gitconfig
4.0K	/home/evo/.git-credentials
4.0K	/home/evo/.env
4.0K	/home/evo/.editorconfig
4.0K	/home/evo/.claude.json.backup.1772164452577
4.0K	/home/evo/.claude.json
4.0K	/home/evo/.bash_profile
4.0K	/home/evo/.bash_logout
4.0K	/home/evo/.aider.input.history
4.0K	/home/evo/.aider.chat.history.md
0	/home/evo/FINAL_STRUCTURE.md
0	/home/evo/.sudo_as_admin_successful
0	/home/evo/.motd_shown
0	/home/evo/.azure
0	/home/evo/.aws

=== Total ===
96G	/home/evo

=== Disk available ===
Filesystem      Size  Used Avail Use% Mounted on
/dev/sdd       1007G  136G  820G  15% /
```

## Phase 2 — Broken Symlinks

**37 broken symlinks found.**

| Category | Count | Action |
| -------- | ----- | ------ |
| .gemini node_modules/.bin | 12 | Ignore (npm artifacts) |
| .codex/tmp | 18 | Safe to delete |
| pnpm store | 2 | Ignore (pnpm internal) |
| _archive | 3 | Review |
| Other | 2 | Review |

### Non-trivial broken symlinks:
```
/home/evo/.docker/features.json
/home/evo/.openclaw/workspace/skills/linkedin
/home/evo/_archive/Evolution_Studio/.env.local
/home/evo/_archive/Asset_Generation/models
/home/evo/_archive/Asset_Generation/cache
```

## Phase 3 — Dead Path References in Scripts & Docs

**74 unique absolute paths referenced.**

**25 missing paths:**
```
/home/evo/00_DNA/ops/DECISION_LOG.md.
/home/evo/_backups/auto/evo-backup-
/home/evo/_config/bash-evo.sh
/home/evo/_output/factory_test.wav
/home/evo/models/Checkpoints
/home/evo/models/GGUF
/home/evo/projects/Asset_Generation
/home/evo/projects/ComfyUI
/home/evo/projects/Evolution-3.1
/home/evo/projects/Evolution-Content-Factory
/home/evo/projects/Evolution-Studio-MCP
/home/evo/projects/Evolution_
/home/evo/projects/Evolution_Content_Engine
/home/evo/projects/Evolution_Content_Factory
/home/evo/projects/Evolution_Guru
/home/evo/projects/Firecrawl
/home/evo/projects/Infrastructure/Local_LLM
/home/evo/projects/Infrastructure/Local_LLM_2
/home/evo/projects/Local_LLM
/home/evo/projects/N8N
/home/evo/projects/References
/home/evo/projects/Sandbox
/home/evo/projects/evolution-content-engine
/home/evo/projects/n8n
/home/evo/projects/tiktok-content
```

## Phase 4 — Git Repo Inventory

```
REPO                                                         BRANCH          UNCOMMITTED  LAST DATE    LAST MSG
----                                                         ------          -----------  ---------    --------
/home/evo/.claude/plugins/marketplaces/claude-plugins-official main            0            2026-02-24   Merge pull request #457 from anthropics/kenshiro/e
/home/evo/.fzf                                               master          0            2026-02-25   Fix double subtraction of header lines from FZF_TO
/home/evo/.gemini/history/4cfa0ce6e8d6c8cf043a0c6e9ec80540d7c73ed94781fbbbccee02f8915e7a72 main            2            2026-02-16   Initial commit
/home/evo/.gemini/history/7807da39ee6c36039e28e941eb05e72d1e6cce3cc691720c50a734953f242345 main            3            2026-02-17   Initial commit
/home/evo/.gemini/history/8622edd22d9e5412be0dbe5b0c3a023ba181ca55a684dd296919178d29a6f66a main            2            2026-02-16   Initial commit
/home/evo/.gemini/history/c926bf45f40ca09a46d9d61a45f86039a396e66c67da4312ff0782fee5110c34 main            2            2026-02-16   Initial commit
/home/evo/.gemini/history/ccfd480e57915d7434ff31d2e3b95504b92a94dcd3f311c7b617d4f36d438505 main            2            2026-02-17   Initial commit
/home/evo/.gemini/history/e4676fae6540cca626dcef41c3602a87baf6372797169c1466befbefb53ef95c main            3            2026-02-19   Initial commit
/home/evo/.gemini/history/e941177a0ea0c89ec9ccdbe41f9adf3ac6e2fc0d0f1f7cdbf802242e5f7e4f30 main            3            2026-02-22   Initial commit
/home/evo/.gemini/history/evo                                main            3            2026-02-17   Initial commit
/home/evo/.npm-global/lib/node_modules/@tobilu/qmd/node_modules/node-llama-cpp/llama/llama.cpp HEAD            0            2026-02-21   ## SQUASHED ##
/home/evo/.openclaw/skills/clawd-cursor                      main            1            2026-02-25   bump v0.5.4 - security hardening, privacy clarific
/home/evo/.vscode-server/data/User/globalStorage/kilocode.kilo-code/tasks/019c3f3c-68f9-764c-8383-9a24fd9c54cf/checkpoints master          0            2026-02-09   Task: 019c3f3c-68f9-764c-8383-9a24fd9c54cf, Time: 
/home/evo/.vscode-server/data/User/globalStorage/kilocode.kilo-code/tasks/019c415f-9778-715f-9c6d-4d58845e2ac1/checkpoints master          0            2026-02-09   Task: 019c415f-9778-715f-9c6d-4d58845e2ac1, Time: 
/home/evo/.vscode-server/data/User/globalStorage/kilocode.kilo-code/tasks/019c4aad-3aa7-71b8-9ee4-bba2332a0e31/checkpoints master          0            2026-02-11   Task: 019c4aad-3aa7-71b8-9ee4-bba2332a0e31, Time: 
/home/evo/.vscode-server/data/User/globalStorage/kilocode.kilo-code/tasks/019c4fb3-5582-71c6-b401-88b956710899/checkpoints master          0            2026-02-12   Task: 019c4fb3-5582-71c6-b401-88b956710899, Time: 
/home/evo/.vscode-server/data/User/globalStorage/kilocode.kilo-code/tasks/019c9877-568a-756b-a7c7-11299385f40d/checkpoints main            0            2026-02-26   Task: 019c9877-568a-756b-a7c7-11299385f40d, Time: 
/home/evo/00_DNA                                             main            19           2026-03-01   Update README.md with new directory structure
/home/evo/_archive/Asset_Generation                          main            6            2026-01-21   Merge pull request #2 from Badders80/feature/ui-ta
/home/evo/_archive/Evolution-Content-Builder                 main            0            2026-02-19   Add CLAUDE.md file
/home/evo/_archive/Evolution-Content-Factory                 master          0            2026-02-19   Add reference to Evolution_Content_Factory.md
/home/evo/_archive/Evolution_Studio                          main            14           2026-02-19   Add reference to core bible documents
/home/evo/_archive/evolution-email-builder                   main            0            2026-02-19   Add CLAUDE.md file
/home/evo/_backups/dna/20260214                              main            3            2026-02-03   Add Tech_Stack_2026.md - vanilla tech stack docume
/home/evo/_backups/projects/.archived/ComfyUI_Workflows_fresh main            1            2026-01-05   Initial commit: ComfyUI workflow builder v0.0
/home/evo/_backups/projects/.archived/ComfyUI_fresh          HEAD
ERR        1            no commits   
/home/evo/_backups/projects/.archived/evolution-content-backup-20260223 main            6            2026-02-20   docs: Phase 3 complete - All tasks finished
/home/evo/_sandbox/Evolution_Pitch_Deck_Builder              main            26           2026-02-19   feat: Initialize pitch deck project structure
/home/evo/evo-dotfiles                                       main            1            2026-02-27   claudec - skip permissions, vault auth, DNA loads 
/home/evo/openclaw-mission-control                           master          0            2026-02-27   Merge pull request #185 from hanushh/fix-agent-aut
/home/evo/projects/Evolution_Command                         main            0            2026-03-01   Complete rewrite to OpenClaw Mission Control
/home/evo/projects/Evolution_Content                         main            1            2026-03-01   chore: ignore generated export artifacts
/home/evo/projects/Evolution_Platform                        evolution-4.0   1            2026-03-01   Update metadata and remove broken brand_voice syml
/home/evo/projects/Evolution_Studio                          main            1            2026-02-28   sprint2: archive studio completion receipts
/home/evo/projects/External/Firecrawl                        main            2            2026-02-10   fix(billing): bump tally RPC from update_tally_9_t
/home/evo/projects/Infrastructure/ComfyUI                    master          2            2026-02-04   ComfyUI v0.12.2
/home/evo/projects/Infrastructure/ComfyUI/custom_nodes/ComfyUI-GGUF main            0            2026-01-12   Only include metadata on new comfy versions
```

## Phase 5 — /00_DNA Structure & Integrity

```
=== Tree (3 levels) ===
/home/evo/00_DNA
/home/evo/00_DNA/.git
/home/evo/00_DNA/.gitignore
/home/evo/00_DNA/.gitmodules
/home/evo/00_DNA/.obsidian
/home/evo/00_DNA/.obsidian/app.json
/home/evo/00_DNA/.obsidian/appearance.json
/home/evo/00_DNA/.obsidian/core-plugins.json
/home/evo/00_DNA/.obsidian/templates
/home/evo/00_DNA/.obsidian/templates/Daily Log.md
/home/evo/00_DNA/.obsidian/templates/Decision.md
/home/evo/00_DNA/.obsidian/templates/Meeting Notes.md
/home/evo/00_DNA/README.md
/home/evo/00_DNA/_archive
/home/evo/00_DNA/_archive/00_DNA_ROOT_MERGE.md
/home/evo/00_DNA/_archive/2026-02
/home/evo/00_DNA/_archive/2026-02/ACTION_PLAN.md
/home/evo/00_DNA/_archive/2026-02/BRAND_VOICE.md
/home/evo/00_DNA/_archive/2026-02/Branding.md
/home/evo/00_DNA/_archive/2026-02/CLEANUP_PLAN.md
/home/evo/00_DNA/_archive/2026-02/DNA_POPULATION_STATUS.md
/home/evo/00_DNA/_archive/2026-02/Evolution_Content_Factory.md
/home/evo/00_DNA/_archive/2026-02/INBOX.md
/home/evo/00_DNA/_archive/2026-02/MESSAGING_CHEAT_SHEET.md
/home/evo/00_DNA/_archive/2026-02/OPERATIONAL_CONFIG_DRAFT.md
/home/evo/00_DNA/_archive/2026-02/README.md
/home/evo/00_DNA/_archive/2026-02/READY_TO_BUILD.md
/home/evo/00_DNA/_archive/2026-02/REORGANIZATION_COMPLETE.md
/home/evo/00_DNA/_archive/2026-02/RESEARCH
/home/evo/00_DNA/_archive/2026-02/TYPOGRAPHY_SYSTEM.md
/home/evo/00_DNA/_archive/2026-02/_maps
/home/evo/00_DNA/_archive/AGENTS_MERGE.md
/home/evo/00_DNA/_archive/BRAND_MERGE.md
/home/evo/00_DNA/_archive/BUILD_PHILOSOPHY_MERGE.md
/home/evo/00_DNA/_archive/COMPLETE_AUDIT_OUTPUT.txt
/home/evo/00_DNA/_archive/Evolution_LLM_Stack.md
/home/evo/00_DNA/_archive/INDEX.md
/home/evo/00_DNA/_archive/INFORMATION_GAPS.md
/home/evo/00_DNA/_archive/OPS_MERGE.md
/home/evo/00_DNA/_archive/README.md
/home/evo/00_DNA/_archive/REPO_AUDIT_2026-01-27.md
/home/evo/00_DNA/_archive/SESSION_STARTER.md
/home/evo/00_DNA/_archive/build-philosophy
/home/evo/00_DNA/_archive/build-philosophy/ARCHITECTURE_STRATEGY.md
/home/evo/00_DNA/_archive/build-philosophy/BUILD_BRAIN.md
/home/evo/00_DNA/_archive/build-philosophy/Evolution_OS.md
/home/evo/00_DNA/_archive/build-philosophy/Master_Config_2026.md
/home/evo/00_DNA/_archive/build-philosophy/SANDBOX_PHILOSOPHY.md
/home/evo/00_DNA/_archive/build-philosophy/SEPARATION_OF_CONCERNS.md
/home/evo/00_DNA/_archive/build-philosophy/Tech_Stack_2026.md
/home/evo/00_DNA/_archive/build-philosophy/_MERGED_MEGA_DOC.md
/home/evo/00_DNA/_archive/build-philosophy/llm-architecture.md
/home/evo/00_DNA/_backups
/home/evo/00_DNA/_backups/20260301_152041_spotless
/home/evo/00_DNA/_backups/20260301_152041_spotless/content-strategy
/home/evo/00_DNA/_backups/20260301_152041_spotless/scripts
/home/evo/00_DNA/_backups/20260301_152041_spotless/skills
/home/evo/00_DNA/_backups/20260301_152041_spotless/system-prompts
/home/evo/00_DNA/_backups/20260301_152041_spotless/workflows
/home/evo/00_DNA/_obsidian
/home/evo/00_DNA/_obsidian/README.md
/home/evo/00_DNA/_obsidian/✈️ Travel Checklist.md
/home/evo/00_DNA/_obsidian/✈️ Travel Mode.md
/home/evo/00_DNA/_obsidian/🏗️ Build Rules.md
/home/evo/00_DNA/_obsidian/🏠 Home.md
/home/evo/00_DNA/_obsidian/🐳 Docker Guide.md
/home/evo/00_DNA/_obsidian/📋 Projects.md
/home/evo/00_DNA/_obsidian/🔐 Secrets Guide.md
/home/evo/00_DNA/_obsidian/🚀 QUICK_START.md
/home/evo/00_DNA/_obsidian/🛠️ Enhancements Guide.md
/home/evo/00_DNA/agents
/home/evo/00_DNA/agents/AGENTS.core.md
/home/evo/00_DNA/agents/AI_CONTEXT.md
/home/evo/00_DNA/agents/AI_TOOL_WRAPPERS.md
/home/evo/00_DNA/agents/MEMORY_PROTOCOL.md
/home/evo/00_DNA/agents/OPERATING_BACKLOG.md
/home/evo/00_DNA/agents/README.md
/home/evo/00_DNA/brand
/home/evo/00_DNA/brand-identity
/home/evo/00_DNA/brand-identity/Brand_Voice_System
/home/evo/00_DNA/brand-identity/Brand_Voice_System/.git
/home/evo/00_DNA/brand-identity/Brand_Voice_System/.gitignore
/home/evo/00_DNA/brand-identity/Brand_Voice_System/00_kernel
/home/evo/00_DNA/brand-identity/Brand_Voice_System/01_modules
/home/evo/00_DNA/brand-identity/Brand_Voice_System/02_logic
/home/evo/00_DNA/brand-identity/Brand_Voice_System/CLAUDE.md
/home/evo/00_DNA/brand-identity/README.md
/home/evo/00_DNA/brand/BRAND_SYSTEM.md
/home/evo/00_DNA/brand/CHANGELOG.md
/home/evo/00_DNA/brand/INTELLIGENCE_SYSTEM.md
/home/evo/00_DNA/brand/METRICS_SYSTEM.md
/home/evo/00_DNA/brand/README.md
/home/evo/00_DNA/brand/_archive
/home/evo/00_DNA/brand/_archive/BRAND_SYSTEM_Claude.md
/home/evo/00_DNA/brand/_archive/Brand_Voice_System
/home/evo/00_DNA/brand/_archive/EVOLUTION_INTELLIGENCE.md
/home/evo/00_DNA/brand/_archive/EVOLUTION_STABLES.md
/home/evo/00_DNA/brand/_archive/FULL_BRAND_DUMP.md
/home/evo/00_DNA/brand/_archive/INTELLIGENCE_SYSTEM_Claude.md
/home/evo/00_DNA/brand/_archive/MEGA_BRAND_GUIDE.md
/home/evo/00_DNA/brand/_archive/VISUAL_SYSTEM.md
/home/evo/00_DNA/build-philosophy
/home/evo/00_DNA/build-philosophy/BUILD_SYSTEM.md
/home/evo/00_DNA/build-philosophy/MACHINE_CONFIG.md
/home/evo/00_DNA/build-philosophy/README.md
/home/evo/00_DNA/build-philosophy/STACK_2026.md
/home/evo/00_DNA/content-strategy
/home/evo/00_DNA/content-strategy/SEO
/home/evo/00_DNA/content-strategy/SEO/SEO_AUDIT_REPORT.md
/home/evo/00_DNA/content-strategy/SEO/SEO_GUIDE.md
/home/evo/00_DNA/content-strategy/TIKTOK_STRATEGY.md
/home/evo/00_DNA/ops
/home/evo/00_DNA/ops/DECISION_LOG.md
/home/evo/00_DNA/ops/MEMORY_OPTIMIZATION.md
/home/evo/00_DNA/ops/QUICK_REFERENCE.md
/home/evo/00_DNA/ops/README.md
/home/evo/00_DNA/ops/TECH_RADAR.md
/home/evo/00_DNA/ops/remote-access.yaml
/home/evo/00_DNA/scripts
/home/evo/00_DNA/scripts/README.md
/home/evo/00_DNA/scripts/antfarm.sh
/home/evo/00_DNA/scripts/audit_jules_repos.sh
/home/evo/00_DNA/scripts/clawbot-tiktok-pipeline.sh
/home/evo/00_DNA/scripts/clone_jules_repos.sh
/home/evo/00_DNA/scripts/commit_evolution_3.1.sh
/home/evo/00_DNA/scripts/complete_audit.sh
/home/evo/00_DNA/scripts/comprehensive_audit.sh
/home/evo/00_DNA/scripts/execute_migration.sh
/home/evo/00_DNA/scripts/final_cleanup.sh
/home/evo/00_DNA/scripts/fix_broken_items.sh
/home/evo/00_DNA/scripts/fix_structure_properly.sh
/home/evo/00_DNA/scripts/pre-commit-hook.sh
/home/evo/00_DNA/scripts/review_evolution_guru.sh
/home/evo/00_DNA/scripts/run_all.sh
/home/evo/00_DNA/scripts/shell
/home/evo/00_DNA/scripts/shell/bash-evo.sh
/home/evo/00_DNA/scripts/shell/evo-ai.sh
/home/evo/00_DNA/scripts/shell/kimi-startup.sh
/home/evo/00_DNA/scripts/sync_agents.sh
/home/evo/00_DNA/scripts/sync_starred_repos.mjs
/home/evo/00_DNA/scripts/verify_complete_build.sh
/home/evo/00_DNA/skills
/home/evo/00_DNA/skills/INDEX.md
/home/evo/00_DNA/skills/guides
/home/evo/00_DNA/skills/guides/comfyui_vram_safety.md
/home/evo/00_DNA/skills/guides/multi_file_debug.md
/home/evo/00_DNA/skills/guides/release_checklist.md
/home/evo/00_DNA/skills/guides/ui_tweaks.md
/home/evo/00_DNA/skills/registry
/home/evo/00_DNA/skills/registry/approved_sources.md
/home/evo/00_DNA/skills/registry/starred_repo_registry.json
/home/evo/00_DNA/skills/registry/starred_repo_registry.md
/home/evo/00_DNA/system-prompts
/home/evo/00_DNA/system-prompts/AI_SESSION_BOOTSTRAP.md
/home/evo/00_DNA/system-prompts/PROMPT_LIBRARY.md
/home/evo/00_DNA/system-prompts/library
/home/evo/00_DNA/system-prompts/library/CONTENT_GATEKEEPER.md
/home/evo/00_DNA/vault
/home/evo/00_DNA/vault/README.md
/home/evo/00_DNA/vault/env.schema
/home/evo/00_DNA/vault/env.template
/home/evo/00_DNA/workflows
/home/evo/00_DNA/workflows/ANTFARM_BLUEPRINT.md
/home/evo/00_DNA/workflows/MIGRATION_STRATEGY.md
/home/evo/00_DNA/workflows/STANDARD_WORKFLOWS.md

=== Key file check ===
  ❌ MISSING: OPERATING_BACKLOG.md
  ❌ MISSING: DECISION_LOG.md
  ❌ MISSING: TECH_RADAR.md
  ❌ MISSING: INBOX.md

=== Git status ===
 M README.md
 M "_obsidian/\360\237\217\227\357\270\217 Build Rules.md"
 M agents/AGENTS.core.md
 M agents/AI_CONTEXT.md
 M ops/QUICK_REFERENCE.md
 M ops/TECH_RADAR.md
 M scripts/audit_jules_repos.sh
 M scripts/execute_migration.sh
 M scripts/fix_broken_items.sh
 M scripts/run_all.sh
 M scripts/sync_agents.sh
 M scripts/sync_starred_repos.mjs
 M scripts/verify_complete_build.sh
 M skills/INDEX.md
 M skills/registry/approved_sources.md
 M system-prompts/AI_SESSION_BOOTSTRAP.md
 M system-prompts/PROMPT_LIBRARY.md
 M workflows/STANDARD_WORKFLOWS.md
?? scripts/README.md

=== Recent commits ===
32010a8 Update README.md with new directory structure
04e3d8e Antfarm Implementation Phase 1 ✅
3c495b1 chore: spotless dna lockdown complete - doctor paths aligned
2237022 docs(dna): finalize BUILD_BRAIN with antfarm routing and superpowers trial trigger
2498762 feat(dna): add build methodology selection and superpowers trial routing
3577013 feat(dna): finalize starred repo registry — auth, pagination, radar tags, content fixes
e4b2102 docs: formalize build philosophy canonicalization in decision log
11ad4d9 docs: sync build philosophy with Safe-Path and canonical project names
3e9695e sprint3: brand consolidation - 9 files → 3 canonical
c02442e docs: update backlog post sprint 1+2
```

## Phase 6 — /projects Inventory

```
=== Projects listing ===
total 52
drwxr-xr-x 10 evo  evo  4096 Mar  1 16:16 .
drwxr-x--- 50 evo  evo  4096 Mar  1 22:05 ..
-rw-r--r--  1 evo  evo   302 Feb 14 13:52 .gemini.md
lrwxrwxrwx  1 evo  evo    16 Mar  1 16:16 00_DNA -> /home/evo/00_DNA
drwxr-xr-x 13 evo  evo  4096 Mar  1 15:33 Evolution_Command
drwxr-xr-x 20 evo  evo  4096 Mar  1 18:29 Evolution_Content
drwxr-xr-x  8 evo  evo  4096 Mar  1 15:33 Evolution_Intelligence
drwxr-xr-x 13 evo  evo  4096 Mar  1 18:29 Evolution_Platform
drwxr-xr-x 11 evo  evo  4096 Mar  1 18:29 Evolution_Studio
drwxr-xr-x  4 root root 4096 Feb 27 09:22 External
drwxr-xr-x  4 evo  evo  4096 Feb 27 17:15 Infrastructure
-rw-rw-r--  1 evo  evo  7621 Feb 19 21:37 PROJECT_CONSOLIDATION_ANALYSIS.md
drwxr-xr-x  3 evo  evo  4096 Feb 28 19:28 _archive

=== Per-project details ===
  [00_DNA] size=4.3M stack=unknown NO .env
  [Evolution_Command] size=848M stack=node next.js  .env symlink → /home/evo/.env ✅
  [Evolution_Content] size=272M stack=unknown .env symlink → /home/evo/.env ✅
  [Evolution_Intelligence] size=112K stack=python  .env symlink → /home/evo/.env ✅
  [Evolution_Platform] size=1.4G stack=node next.js  .env symlink → /home/evo/.env ✅
  [Evolution_Studio] size=800M stack=node  .env symlink → /home/evo/.env ✅
  [External] size=142M stack=unknown NO .env
  [Infrastructure] size=48G stack=unknown NO .env
  [_archive] size=56K stack=unknown NO .env

=== Project sizes ===
48G	/home/evo/projects/Infrastructure/
1.4G	/home/evo/projects/Evolution_Platform/
848M	/home/evo/projects/Evolution_Command/
800M	/home/evo/projects/Evolution_Studio/
272M	/home/evo/projects/Evolution_Content/
142M	/home/evo/projects/External/
4.3M	/home/evo/projects/00_DNA/
112K	/home/evo/projects/Evolution_Intelligence/
56K	/home/evo/projects/_archive/
```

## Phase 7 — Root-Level Clutter & Loose Files

```
=== Files directly in /home/evo (non-hidden) ===
/home/evo/FINAL_STRUCTURE.md
/home/evo/Justfile
/home/evo/PROJECTS_INDEX.md
/home/evo/QUICKSTART.md
/home/evo/SERVICE_INVENTORY.md
/home/evo/audit_log_20260301_153605.txt
/home/evo/evolution.code-workspace
/home/evo/install.cmd
/home/evo/overnight_factory.sh
/home/evo/overnight_log.txt
/home/evo/overnight_nohup.log
/home/evo/overnight_run.sh
/home/evo/start_overnight.sh
/home/evo/telemetry-id

=== Non-hidden dirs at root ===
/home/evo
/home/evo/00_DNA
/home/evo/Downloads
/home/evo/_archive
/home/evo/_backups
/home/evo/_docs
/home/evo/_logs
/home/evo/_output
/home/evo/_sandbox
/home/evo/_scripts
/home/evo/evo-dotfiles
/home/evo/models
/home/evo/openclaw
/home/evo/openclaw-mission-control
/home/evo/projects

=== .bashrc backups ===
-rw-r--r-- 1 evo evo 6477 Feb 28 20:54 /home/evo/.bashrc
-rw-r--r-- 1 evo evo 6594 Feb 28 17:13 /home/evo/.bashrc.backup.20260228_171342
-rw-r--r-- 1 evo evo 4643 Feb 14 13:59 /home/evo/.bashrc.bak_20260214_135911
-rw-r--r-- 1 evo evo 4813 Feb 14 14:02 /home/evo/.bashrc.bak_20260214_140246

=== overnight/audit loose files ===
-rw-r--r-- 1 evo evo 12598 Mar  1 15:36 /home/evo/audit_log_20260301_153605.txt
-rw-rw-r-- 1 evo evo  4897 Feb 27 22:28 /home/evo/overnight_factory.sh
-rw-r--r-- 1 evo evo   341 Feb 28 09:39 /home/evo/overnight_log.txt
-rw-rw-r-- 1 evo evo   213 Feb 27 22:25 /home/evo/overnight_nohup.log
-rwxr-xr-x 1 evo evo  9657 Feb 27 22:25 /home/evo/overnight_run.sh
-rwxrwxr-x 1 evo evo   197 Feb 27 22:26 /home/evo/start_overnight.sh
```

## Phase 8 — Duplication & Shadow Repos

```
=== All repos and their remotes ===
  /home/evo/.claude/plugins/marketplaces/claude-plugins-official → https://github.com/anthropics/claude-plugins-official.git
  /home/evo/.fzf → https://github.com/junegunn/fzf.git
  /home/evo/.gemini/history/4cfa0ce6e8d6c8cf043a0c6e9ec80540d7c73ed94781fbbbccee02f8915e7a72 → no remote
  /home/evo/.gemini/history/7807da39ee6c36039e28e941eb05e72d1e6cce3cc691720c50a734953f242345 → no remote
  /home/evo/.gemini/history/8622edd22d9e5412be0dbe5b0c3a023ba181ca55a684dd296919178d29a6f66a → no remote
  /home/evo/.gemini/history/c926bf45f40ca09a46d9d61a45f86039a396e66c67da4312ff0782fee5110c34 → no remote
  /home/evo/.gemini/history/ccfd480e57915d7434ff31d2e3b95504b92a94dcd3f311c7b617d4f36d438505 → no remote
  /home/evo/.gemini/history/e4676fae6540cca626dcef41c3602a87baf6372797169c1466befbefb53ef95c → no remote
  /home/evo/.gemini/history/e941177a0ea0c89ec9ccdbe41f9adf3ac6e2fc0d0f1f7cdbf802242e5f7e4f30 → no remote
  /home/evo/.gemini/history/evo → no remote
  /home/evo/.npm-global/lib/node_modules/@tobilu/qmd/node_modules/node-llama-cpp/llama/llama.cpp → no remote
  /home/evo/.openclaw/skills/clawd-cursor → https://github.com/AmrDab/clawd-cursor.git
  /home/evo/.vscode-server/data/User/globalStorage/kilocode.kilo-code/tasks/019c3f3c-68f9-764c-8383-9a24fd9c54cf/checkpoints → no remote
  /home/evo/.vscode-server/data/User/globalStorage/kilocode.kilo-code/tasks/019c415f-9778-715f-9c6d-4d58845e2ac1/checkpoints → no remote
  /home/evo/.vscode-server/data/User/globalStorage/kilocode.kilo-code/tasks/019c4aad-3aa7-71b8-9ee4-bba2332a0e31/checkpoints → no remote
  /home/evo/.vscode-server/data/User/globalStorage/kilocode.kilo-code/tasks/019c4fb3-5582-71c6-b401-88b956710899/checkpoints → no remote
  /home/evo/.vscode-server/data/User/globalStorage/kilocode.kilo-code/tasks/019c9877-568a-756b-a7c7-11299385f40d/checkpoints → no remote
  /home/evo/00_DNA → https://github.com/Badders80/00_DNA.git
  /home/evo/_archive/Asset_Generation → https://github.com/Badders80/Asset_Generation.git
  /home/evo/_archive/Evolution-Content-Builder → https://github.com/Badders80/Evolution-Content-Builder.git
  /home/evo/_archive/Evolution-Content-Factory → https://github.com/Badders80/Evolution-Content-Factory.git
  /home/evo/_archive/Evolution_Studio → https://github.com/Badders80/Evolution_Studio.git
  /home/evo/_archive/evolution-email-builder → https://github.com/Badders80/evolution-email-builder.git
  /home/evo/_backups/dna/20260214 → https://github.com/Badders80/00_DNA.git
  /home/evo/_backups/projects/.archived/ComfyUI_Workflows_fresh → https://github.com/Badders80/ComfyUI_Workflows.git
  /home/evo/_backups/projects/.archived/ComfyUI_fresh → https://github.com/Badders80/ComfyUI.git
  /home/evo/_backups/projects/.archived/evolution-content-backup-20260223 → no remote
  /home/evo/_sandbox/Evolution_Pitch_Deck_Builder → https://github.com/Badders80/Evolution_Pitch_Deck_Builder
  /home/evo/evo-dotfiles → https://github.com/Badders80/evo-dotfiles.git
  /home/evo/openclaw-mission-control → https://github.com/abhi1693/openclaw-mission-control.git
  /home/evo/projects/Evolution_Command → https://github.com/Badders80/Evolution-Command.git
  /home/evo/projects/Evolution_Content → https://github.com/Badders80/Evolution_Content.git
  /home/evo/projects/Evolution_Platform → https://github.com/Badders80/Evolution-3.1.git
  /home/evo/projects/Evolution_Studio → https://github.com/Badders80/Evolution-Studio.git
  /home/evo/projects/External/Firecrawl → https://github.com/mendableai/firecrawl.git
  /home/evo/projects/Infrastructure/ComfyUI → https://github.com/comfyanonymous/ComfyUI.git
  /home/evo/projects/Infrastructure/ComfyUI/custom_nodes/ComfyUI-GGUF → https://github.com/city96/ComfyUI-GGUF.git

=== openclaw-mission-control vs Evolution_Command ===
  openclaw-mission-control → https://github.com/abhi1693/openclaw-mission-control.git
  Evolution_Command        → https://github.com/Badders80/Evolution-Command.git
  ✅ Different remotes

=== Root dirs duplicating /projects names ===
  ⚠️  00_DNA at BOTH /projects/ and /home/evo/
  ⚠️  _archive at BOTH /projects/ and /home/evo/

=== _archive contents ===
total 40
drwxr-xr-x 10 evo evo 4096 Feb 28 21:18 .
drwxr-x--- 50 evo evo 4096 Mar  1 22:05 ..
drwxr-xr-x  5 evo evo 4096 Feb 17 16:40 Asset_Generation
drwxr-xr-x 11 evo evo 4096 Feb 19 15:28 Evolution-Content-Builder
drwxrwxr-x 10 evo evo 4096 Feb 19 14:58 Evolution-Content-Factory
drwxr-xr-x 13 evo evo 4096 Feb 19 22:25 Evolution_Studio
drwxr-xr-x  6 evo evo 4096 Feb 19 15:39 evolution-email-builder
drwxr-xr-x  3 evo evo 4096 Feb 22 15:10 evolution-ui
drwxr-xr-x  2 evo evo 4096 Feb 27 17:20 sudo_cleanup_required
drwxr-xr-x  2 evo evo 4096 Feb 28 21:18 unknown_models
```

## Phase 9 — Shell & Tooling Health

```
=== Key tools ===
  just         /home/evo/.local/bin/just      just 1.46.0
  tmux         /usr/bin/tmux                  
  docker       /usr/bin/docker                Docker version 29.2.0, build 0b9d198
  git          /usr/bin/git                   git version 2.43.0
  node         /usr/bin/node                  v22.22.0
  python3      /usr/bin/python3               Python 3.12.3
  bun          NOT FOUND                      
  pnpm         /usr/bin/pnpm                  10.28.2
  npm          /home/evo/.npm-global/bin/npm  11.8.0
  rg           NOT FOUND                      
  fzf          NOT FOUND                      

=== evo command ===
/home/evo/.local/bin/evo

=== Justfile targets ===
backlog
backup
cd-dna
cd-scripts
check
decisions
default
dna
docker-clean
docker-list
docker-status
doctor
install-enhancements
install-hooks
memory
optimize-memory
proj
status
stop-all
studio
update
vault
vault-check

=== Docker containers ===
NAMES                                       IMAGE                                     STATUS
openclaw-mission-control-webhook-worker-1   openclaw-mission-control-webhook-worker   Restarting (1) 27 seconds ago
evo-orchestrator                            evolution_content-orchestrator            Up 2 hours

=== Listening ports ===
tcp   LISTEN 0      1000   10.255.255.254:53         0.0.0.0:*          
tcp   LISTEN 0      4096        127.0.0.1:11434      0.0.0.0:*          
tcp   LISTEN 0      4096    127.0.0.53%lo:53         0.0.0.0:*          
tcp   LISTEN 0      4096       127.0.0.54:53         0.0.0.0:*          
tcp   LISTEN 0      4096                *:8000             *:*          

=== PATH additions in .bashrc ===
export PATH="$HOME/.local/bin:$PATH"
export PATH="$PATH:/mnt/c/Users/Evo/y/google-cloud-sdk/bin"
export PATH="$HOME/.npm-global/bin:$PATH"
case ":$PATH:" in
  *) export PATH="$PNPM_HOME:$PATH" ;;
export PUPPETEER_EXECUTABLE_PATH="/mnt/c/Program Files/Google/Chrome/Application/chrome.exe"
export PATH="$HOME/.fzf/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
```

## Phase 10 — Active vs Stale

```
=== Files modified in last 7 days ===
/home/evo/.bash_history
/home/evo/.bash_profile
/home/evo/.bashrc
/home/evo/.bashrc.backup.20260228_171342
/home/evo/.bun/install/cache/5995d9e183d4e02d.npm
/home/evo/.bun/install/cache/8798a6a49b2b16d4.npm
/home/evo/.bun/install/cache/@kilocode/plugin@7.0.30@@@1/dist/example.d.ts
/home/evo/.bun/install/cache/@kilocode/plugin@7.0.30@@@1/dist/example.js
/home/evo/.bun/install/cache/@kilocode/plugin@7.0.30@@@1/dist/index.d.ts
/home/evo/.bun/install/cache/@kilocode/plugin@7.0.30@@@1/dist/index.js
/home/evo/.bun/install/cache/@kilocode/plugin@7.0.30@@@1/dist/shell.d.ts
/home/evo/.bun/install/cache/@kilocode/plugin@7.0.30@@@1/dist/shell.js
/home/evo/.bun/install/cache/@kilocode/plugin@7.0.30@@@1/dist/tool.d.ts
/home/evo/.bun/install/cache/@kilocode/plugin@7.0.30@@@1/dist/tool.js
/home/evo/.bun/install/cache/@kilocode/plugin@7.0.30@@@1/package.json
/home/evo/.bun/install/cache/@kilocode/plugin@7.0.33@@@1/dist/example.d.ts
/home/evo/.bun/install/cache/@kilocode/plugin@7.0.33@@@1/dist/example.js
/home/evo/.bun/install/cache/@kilocode/plugin@7.0.33@@@1/dist/index.d.ts
/home/evo/.bun/install/cache/@kilocode/plugin@7.0.33@@@1/dist/index.js
/home/evo/.bun/install/cache/@kilocode/plugin@7.0.33@@@1/dist/shell.d.ts
/home/evo/.bun/install/cache/@kilocode/plugin@7.0.33@@@1/dist/shell.js
/home/evo/.bun/install/cache/@kilocode/plugin@7.0.33@@@1/dist/tool.d.ts
/home/evo/.bun/install/cache/@kilocode/plugin@7.0.33@@@1/dist/tool.js
/home/evo/.bun/install/cache/@kilocode/plugin@7.0.33@@@1/package.json
/home/evo/.bun/install/cache/@kilocode/sdk@7.0.30@@@1/dist/client.d.ts
/home/evo/.bun/install/cache/@kilocode/sdk@7.0.30@@@1/dist/client.js
/home/evo/.bun/install/cache/@kilocode/sdk@7.0.30@@@1/dist/gen/client.gen.d.ts
/home/evo/.bun/install/cache/@kilocode/sdk@7.0.30@@@1/dist/gen/client.gen.js
/home/evo/.bun/install/cache/@kilocode/sdk@7.0.30@@@1/dist/gen/client/client.gen.d.ts
/home/evo/.bun/install/cache/@kilocode/sdk@7.0.30@@@1/dist/gen/client/client.gen.js
/home/evo/.bun/install/cache/@kilocode/sdk@7.0.30@@@1/dist/gen/client/index.d.ts
/home/evo/.bun/install/cache/@kilocode/sdk@7.0.30@@@1/dist/gen/client/index.js
/home/evo/.bun/install/cache/@kilocode/sdk@7.0.30@@@1/dist/gen/client/types.gen.d.ts
/home/evo/.bun/install/cache/@kilocode/sdk@7.0.30@@@1/dist/gen/client/types.gen.js
/home/evo/.bun/install/cache/@kilocode/sdk@7.0.30@@@1/dist/gen/client/utils.gen.d.ts
/home/evo/.bun/install/cache/@kilocode/sdk@7.0.30@@@1/dist/gen/client/utils.gen.js
/home/evo/.bun/install/cache/@kilocode/sdk@7.0.30@@@1/dist/gen/core/auth.gen.d.ts
/home/evo/.bun/install/cache/@kilocode/sdk@7.0.30@@@1/dist/gen/core/auth.gen.js
/home/evo/.bun/install/cache/@kilocode/sdk@7.0.30@@@1/dist/gen/core/bodySerializer.gen.d.ts
/home/evo/.bun/install/cache/@kilocode/sdk@7.0.30@@@1/dist/gen/core/bodySerializer.gen.js
/home/evo/.bun/install/cache/@kilocode/sdk@7.0.30@@@1/dist/gen/core/params.gen.d.ts
/home/evo/.bun/install/cache/@kilocode/sdk@7.0.30@@@1/dist/gen/core/params.gen.js
/home/evo/.bun/install/cache/@kilocode/sdk@7.0.30@@@1/dist/gen/core/pathSerializer.gen.d.ts
/home/evo/.bun/install/cache/@kilocode/sdk@7.0.30@@@1/dist/gen/core/pathSerializer.gen.js
/home/evo/.bun/install/cache/@kilocode/sdk@7.0.30@@@1/dist/gen/core/queryKeySerializer.gen.d.ts
/home/evo/.bun/install/cache/@kilocode/sdk@7.0.30@@@1/dist/gen/core/queryKeySerializer.gen.js
/home/evo/.bun/install/cache/@kilocode/sdk@7.0.30@@@1/dist/gen/core/serverSentEvents.gen.d.ts
/home/evo/.bun/install/cache/@kilocode/sdk@7.0.30@@@1/dist/gen/core/serverSentEvents.gen.js
/home/evo/.bun/install/cache/@kilocode/sdk@7.0.30@@@1/dist/gen/core/types.gen.d.ts
/home/evo/.bun/install/cache/@kilocode/sdk@7.0.30@@@1/dist/gen/core/types.gen.js
/home/evo/.bun/install/cache/@kilocode/sdk@7.0.30@@@1/dist/gen/core/utils.gen.d.ts
/home/evo/.bun/install/cache/@kilocode/sdk@7.0.30@@@1/dist/gen/core/utils.gen.js
/home/evo/.bun/install/cache/@kilocode/sdk@7.0.30@@@1/dist/gen/sdk.gen.d.ts
/home/evo/.bun/install/cache/@kilocode/sdk@7.0.30@@@1/dist/gen/sdk.gen.js
/home/evo/.bun/install/cache/@kilocode/sdk@7.0.30@@@1/dist/gen/types.gen.d.ts
/home/evo/.bun/install/cache/@kilocode/sdk@7.0.30@@@1/dist/gen/types.gen.js
/home/evo/.bun/install/cache/@kilocode/sdk@7.0.30@@@1/dist/index.d.ts
/home/evo/.bun/install/cache/@kilocode/sdk@7.0.30@@@1/dist/index.js
/home/evo/.bun/install/cache/@kilocode/sdk@7.0.30@@@1/dist/server.d.ts
/home/evo/.bun/install/cache/@kilocode/sdk@7.0.30@@@1/dist/server.js

=== Top-level dirs not touched in 90+ days ===

=== Archive/legacy directories ===
/home/evo/.cache/uv/archive-v0
/home/evo/.claude/backups
/home/evo/00_DNA/brand/_archive
/home/evo/00_DNA/_backups
/home/evo/00_DNA/_archive
/home/evo/_backups
/home/evo/_backups/openclaw/openclaw-backup
/home/evo/_backups/projects/.archived
/home/evo/projects/Evolution_Studio/_archive
/home/evo/projects/_archive
/home/evo/projects/Evolution_Content/_archive
/home/evo/.config/gcloud/legacy_credentials
/home/evo/.openclaw/extensions-backups
/home/evo/.openclaw/workspace/archives
/home/evo/_archive
```

## Phase 11 — .env Audit (Keys Only, No Values)

```
=== Root .env keys ===
CLAUDE_CODE_USE_VERTEX
ELEVENLABS_API_KEY
FAL_API_KEY
FIRECRAWL_API_KEY
GEMINI_API_KEY
SUPABASE_SERVICE_ROLE_KEY
SUPABASE_URL

=== /evo/.env keys ===
ANTHROPIC_API_KEY
ANTHROPIC_VERTEX_PROJECT_ID
CLAUDE_CODE_USE_VERTEX
CLOUD_ML_REGION
MOONSHOT_API_KEY
SUPABASE_KEY
SUPABASE_URL

=== Key diff (root vs /evo) ===
0a1,2
> ANTHROPIC_API_KEY
> ANTHROPIC_VERTEX_PROJECT_ID
2,6c4,6
< ELEVENLABS_API_KEY
< FAL_API_KEY
< FIRECRAWL_API_KEY
< GEMINI_API_KEY
< SUPABASE_SERVICE_ROLE_KEY
---
> CLOUD_ML_REGION
> MOONSHOT_API_KEY
> SUPABASE_KEY

=== Per-project .env key counts ===
  00_DNA: no .env
  Evolution_Command: 7 keys
  Evolution_Content: 7 keys
  Evolution_Intelligence: 7 keys
  Evolution_Platform: 7 keys
  Evolution_Studio: 7 keys
  External: no .env
  Infrastructure: no .env
  _archive: no .env
```

## Phase 12 — Hidden Tool Directories

```
=== All hidden dirs at root (sorted by size) ===
11G	/home/evo/.local
7.5G	/home/evo/.venv
6.7G	/home/evo/.cache
3.9G	/home/evo/.npm-global
2.2G	/home/evo/.vscode-server
1.9G	/home/evo/.antigravity-server
1.7G	/home/evo/.npm
1.5G	/home/evo/.kimi
1.1G	/home/evo/.openclaw
592M	/home/evo/.gemini
364M	/home/evo/.kombai-binaries
153M	/home/evo/.bun
114M	/home/evo/.codex
6.7M	/home/evo/.fzf
6.7M	/home/evo/.claude
1.2M	/home/evo/.aider
852K	/home/evo/.openfang
716K	/home/evo/.docker
580K	/home/evo/.config
248K	/home/evo/.dotnet
96K	/home/evo/.vscode-remote-containers
84K	/home/evo/.nv
72K	/home/evo/.bash_history
64K	/home/evo/.Trash
40K	/home/evo/.triton
24K	/home/evo/.ruff_cache
20K	/home/evo/.kombai
20K	/home/evo/.jules
12K	/home/evo/.git-templates
12K	/home/evo/.copilot
8.0K	/home/evo/.vscode
8.0K	/home/evo/.ssh
8.0K	/home/evo/.github
8.0K	/home/evo/.bashrc.bak_20260214_140246
8.0K	/home/evo/.bashrc.bak_20260214_135911
8.0K	/home/evo/.bashrc.backup.20260228_171342
8.0K	/home/evo/.bashrc
4.0K	/home/evo/.zshrc
4.0K	/home/evo/.wget-hsts
4.0K	/home/evo/.vault
4.0K	/home/evo/.profile
4.0K	/home/evo/.npmrc
4.0K	/home/evo/.landscape
4.0K	/home/evo/.gitconfig
4.0K	/home/evo/.git-credentials
4.0K	/home/evo/.env
4.0K	/home/evo/.editorconfig
4.0K	/home/evo/.claude.json.backup.1772164452577
4.0K	/home/evo/.claude.json
4.0K	/home/evo/.bash_profile
4.0K	/home/evo/.bash_logout
4.0K	/home/evo/.aider.input.history
4.0K	/home/evo/.aider.chat.history.md
0	/home/evo/.sudo_as_admin_successful
0	/home/evo/.motd_shown
0	/home/evo/.azure
0	/home/evo/.aws

=== Known AI tool dirs ===
  ✅ .openclaw  size=1.1G  modified=2026-03-01
  ✅ .gemini  size=592M  modified=2026-03-01
  ✅ .codex  size=114M  modified=2026-03-01
  ✅ .aider  size=1.2M  modified=2026-02-03
  ✅ .claude  size=6.7M  modified=2026-02-27
  ✅ .copilot  size=12K  modified=2026-02-14
  ✅ .jules  size=20K  modified=2026-02-13
  ✅ .kimi  size=1.5G  modified=2026-03-01
  ✅ .openfang  size=852K  modified=2026-02-28
  ✅ .antigravity-server  size=1.9G  modified=2026-02-28
  ✅ .kombai  size=20K  modified=2026-02-26

=== .bashrc backup files ===
-rw-r--r-- 1 evo evo 6.4K Feb 28 20:54 /home/evo/.bashrc
-rw-r--r-- 1 evo evo 6.5K Feb 28 17:13 /home/evo/.bashrc.backup.20260228_171342
-rw-r--r-- 1 evo evo 4.6K Feb 14 13:59 /home/evo/.bashrc.bak_20260214_135911
-rw-r--r-- 1 evo evo 4.8K Feb 14 14:02 /home/evo/.bashrc.bak_20260214_140246
```

## Phase 13 — Consolidated Findings & Action Plan

### Summary

| Severity | Count |
| -------- | ----- |
| 🔴 CRITICAL | 0
0 |
| 🟠 HIGH | 25 |
| 🟡 MEDIUM | 13 |
| 🔵 INFO | 14 |

### All Findings

| Severity | Category | Finding | Detail |
| -------- | -------- | ------- | ------ |
| HIGH | Dead Ref | /home/evo/00_DNA/ops/DECISION_LOG.md. | Referenced but missing |
| HIGH | Dead Ref | /home/evo/_backups/auto/evo-backup- | Referenced but missing |
| HIGH | Dead Ref | /home/evo/_config/bash-evo.sh | Referenced but missing |
| HIGH | Dead Ref | /home/evo/_output/factory_test.wav | Referenced but missing |
| HIGH | Dead Ref | /home/evo/models/Checkpoints | Referenced but missing |
| HIGH | Dead Ref | /home/evo/models/GGUF | Referenced but missing |
| HIGH | Dead Ref | /home/evo/projects/Asset_Generation | Referenced but missing |
| HIGH | Dead Ref | /home/evo/projects/ComfyUI | Referenced but missing |
| HIGH | Dead Ref | /home/evo/projects/Evolution-3.1 | Referenced but missing |
| HIGH | Dead Ref | /home/evo/projects/Evolution-Content-Factory | Referenced but missing |
| HIGH | Dead Ref | /home/evo/projects/Evolution-Studio-MCP | Referenced but missing |
| HIGH | Dead Ref | /home/evo/projects/Evolution_ | Referenced but missing |
| HIGH | Dead Ref | /home/evo/projects/Evolution_Content_Engine | Referenced but missing |
| HIGH | Dead Ref | /home/evo/projects/Evolution_Content_Factory | Referenced but missing |
| HIGH | Dead Ref | /home/evo/projects/Evolution_Guru | Referenced but missing |
| HIGH | Dead Ref | /home/evo/projects/Firecrawl | Referenced but missing |
| HIGH | Dead Ref | /home/evo/projects/Infrastructure/Local_LLM | Referenced but missing |
| HIGH | Dead Ref | /home/evo/projects/Infrastructure/Local_LLM_2 | Referenced but missing |
| HIGH | Dead Ref | /home/evo/projects/Local_LLM | Referenced but missing |
| HIGH | Dead Ref | /home/evo/projects/N8N | Referenced but missing |
| HIGH | Dead Ref | /home/evo/projects/References | Referenced but missing |
| HIGH | Dead Ref | /home/evo/projects/Sandbox | Referenced but missing |
| HIGH | Dead Ref | /home/evo/projects/evolution-content-engine | Referenced but missing |
| HIGH | Dead Ref | /home/evo/projects/n8n | Referenced but missing |
| HIGH | Dead Ref | /home/evo/projects/tiktok-content | Referenced but missing |
| MEDIUM | Broken Symlink | /home/evo/.docker/features.json | → /mnt/c/Users/Evo/.docker/features.json |
| MEDIUM | Broken Symlink | /home/evo/.openclaw/workspace/skills/linkedin | → ../.agents/skills/linkedin |
| MEDIUM | Broken Symlink | /home/evo/_archive/Evolution_Studio/.env.local | → /mnt/scratch/vault/central_keys.env |
| MEDIUM | Broken Symlink | /home/evo/_archive/Asset_Generation/models | → /home/evo/projects/ComfyUI/models |
| MEDIUM | Broken Symlink | /home/evo/_archive/Asset_Generation/cache | → /home/evo/projects/Asset_Generation/cache_local |
| MEDIUM | 00_DNA | Missing: OPERATING_BACKLOG.md | /home/evo/00_DNA/OPERATING_BACKLOG.md |
| MEDIUM | 00_DNA | Missing: DECISION_LOG.md | /home/evo/00_DNA/DECISION_LOG.md |
| MEDIUM | 00_DNA | Missing: TECH_RADAR.md | /home/evo/00_DNA/TECH_RADAR.md |
| MEDIUM | 00_DNA | Missing: INBOX.md | /home/evo/00_DNA/INBOX.md |
| MEDIUM | Projects | 00_DNA has no .env | /home/evo/projects/00_DNA/ |
| MEDIUM | Projects | External has no .env | /home/evo/projects/External/ |
| MEDIUM | Projects | Infrastructure has no .env | /home/evo/projects/Infrastructure/ |
| MEDIUM | Projects | _archive has no .env | /home/evo/projects/_archive/ |
| INFO | Root Clutter | Loose file: overnight_nohup.log | Consider moving to _docs/_scripts |
| INFO | Root Clutter | Loose file: start_overnight.sh | Consider moving to _docs/_scripts |
| INFO | Root Clutter | Loose file: QUICKSTART.md | Consider moving to _docs/_scripts |
| INFO | Root Clutter | Loose file: overnight_run.sh | Consider moving to _docs/_scripts |
| INFO | Root Clutter | Loose file: evolution.code-workspace | Consider moving to _docs/_scripts |
| INFO | Root Clutter | Loose file: FINAL_STRUCTURE.md | Consider moving to _docs/_scripts |
| INFO | Root Clutter | Loose file: overnight_log.txt | Consider moving to _docs/_scripts |
| INFO | Root Clutter | Loose file: telemetry-id | Consider moving to _docs/_scripts |
| INFO | Root Clutter | Loose file: install.cmd | Consider moving to _docs/_scripts |
| INFO | Root Clutter | Loose file: Justfile | Consider moving to _docs/_scripts |
| INFO | Root Clutter | Loose file: audit_log_20260301_153605.txt | Consider moving to _docs/_scripts |
| INFO | Root Clutter | Loose file: PROJECTS_INDEX.md | Consider moving to _docs/_scripts |
| INFO | Root Clutter | Loose file: SERVICE_INVENTORY.md | Consider moving to _docs/_scripts |
| INFO | Root Clutter | Loose file: overnight_factory.sh | Consider moving to _docs/_scripts |

### Fix Now (CRITICAL + HIGH)

- [ ] **[HIGH]** Dead Ref — /home/evo/00_DNA/ops/DECISION_LOG.md.
  - Referenced but missing
- [ ] **[HIGH]** Dead Ref — /home/evo/_backups/auto/evo-backup-
  - Referenced but missing
- [ ] **[HIGH]** Dead Ref — /home/evo/_config/bash-evo.sh
  - Referenced but missing
- [ ] **[HIGH]** Dead Ref — /home/evo/_output/factory_test.wav
  - Referenced but missing
- [ ] **[HIGH]** Dead Ref — /home/evo/models/Checkpoints
  - Referenced but missing
- [ ] **[HIGH]** Dead Ref — /home/evo/models/GGUF
  - Referenced but missing
- [ ] **[HIGH]** Dead Ref — /home/evo/projects/Asset_Generation
  - Referenced but missing
- [ ] **[HIGH]** Dead Ref — /home/evo/projects/ComfyUI
  - Referenced but missing
- [ ] **[HIGH]** Dead Ref — /home/evo/projects/Evolution-3.1
  - Referenced but missing
- [ ] **[HIGH]** Dead Ref — /home/evo/projects/Evolution-Content-Factory
  - Referenced but missing
- [ ] **[HIGH]** Dead Ref — /home/evo/projects/Evolution-Studio-MCP
  - Referenced but missing
- [ ] **[HIGH]** Dead Ref — /home/evo/projects/Evolution_
  - Referenced but missing
- [ ] **[HIGH]** Dead Ref — /home/evo/projects/Evolution_Content_Engine
  - Referenced but missing
- [ ] **[HIGH]** Dead Ref — /home/evo/projects/Evolution_Content_Factory
  - Referenced but missing
- [ ] **[HIGH]** Dead Ref — /home/evo/projects/Evolution_Guru
  - Referenced but missing
- [ ] **[HIGH]** Dead Ref — /home/evo/projects/Firecrawl
  - Referenced but missing
- [ ] **[HIGH]** Dead Ref — /home/evo/projects/Infrastructure/Local_LLM
  - Referenced but missing
- [ ] **[HIGH]** Dead Ref — /home/evo/projects/Infrastructure/Local_LLM_2
  - Referenced but missing
- [ ] **[HIGH]** Dead Ref — /home/evo/projects/Local_LLM
  - Referenced but missing
- [ ] **[HIGH]** Dead Ref — /home/evo/projects/N8N
  - Referenced but missing
- [ ] **[HIGH]** Dead Ref — /home/evo/projects/References
  - Referenced but missing
- [ ] **[HIGH]** Dead Ref — /home/evo/projects/Sandbox
  - Referenced but missing
- [ ] **[HIGH]** Dead Ref — /home/evo/projects/evolution-content-engine
  - Referenced but missing
- [ ] **[HIGH]** Dead Ref — /home/evo/projects/n8n
  - Referenced but missing
- [ ] **[HIGH]** Dead Ref — /home/evo/projects/tiktok-content
  - Referenced but missing

### Fix Soon (MEDIUM)

- [ ] Broken Symlink — /home/evo/.docker/features.json
  - → /mnt/c/Users/Evo/.docker/features.json
- [ ] Broken Symlink — /home/evo/.openclaw/workspace/skills/linkedin
  - → ../.agents/skills/linkedin
- [ ] Broken Symlink — /home/evo/_archive/Evolution_Studio/.env.local
  - → /mnt/scratch/vault/central_keys.env
- [ ] Broken Symlink — /home/evo/_archive/Asset_Generation/models
  - → /home/evo/projects/ComfyUI/models
- [ ] Broken Symlink — /home/evo/_archive/Asset_Generation/cache
  - → /home/evo/projects/Asset_Generation/cache_local
- [ ] 00_DNA — Missing: OPERATING_BACKLOG.md
  - /home/evo/00_DNA/OPERATING_BACKLOG.md
- [ ] 00_DNA — Missing: DECISION_LOG.md
  - /home/evo/00_DNA/DECISION_LOG.md
- [ ] 00_DNA — Missing: TECH_RADAR.md
  - /home/evo/00_DNA/TECH_RADAR.md
- [ ] 00_DNA — Missing: INBOX.md
  - /home/evo/00_DNA/INBOX.md
- [ ] Projects — 00_DNA has no .env
  - /home/evo/projects/00_DNA/
- [ ] Projects — External has no .env
  - /home/evo/projects/External/
- [ ] Projects — Infrastructure has no .env
  - /home/evo/projects/Infrastructure/
- [ ] Projects — _archive has no .env
  - /home/evo/projects/_archive/

### Review Later (INFO)

- [ ] Root Clutter — Loose file: overnight_nohup.log
  - Consider moving to _docs/_scripts
- [ ] Root Clutter — Loose file: start_overnight.sh
  - Consider moving to _docs/_scripts
- [ ] Root Clutter — Loose file: QUICKSTART.md
  - Consider moving to _docs/_scripts
- [ ] Root Clutter — Loose file: overnight_run.sh
  - Consider moving to _docs/_scripts
- [ ] Root Clutter — Loose file: evolution.code-workspace
  - Consider moving to _docs/_scripts
- [ ] Root Clutter — Loose file: FINAL_STRUCTURE.md
  - Consider moving to _docs/_scripts
- [ ] Root Clutter — Loose file: overnight_log.txt
  - Consider moving to _docs/_scripts
- [ ] Root Clutter — Loose file: telemetry-id
  - Consider moving to _docs/_scripts
- [ ] Root Clutter — Loose file: install.cmd
  - Consider moving to _docs/_scripts
- [ ] Root Clutter — Loose file: Justfile
  - Consider moving to _docs/_scripts
- [ ] Root Clutter — Loose file: audit_log_20260301_153605.txt
  - Consider moving to _docs/_scripts
- [ ] Root Clutter — Loose file: PROJECTS_INDEX.md
  - Consider moving to _docs/_scripts
- [ ] Root Clutter — Loose file: SERVICE_INVENTORY.md
  - Consider moving to _docs/_scripts
- [ ] Root Clutter — Loose file: overnight_factory.sh
  - Consider moving to _docs/_scripts
