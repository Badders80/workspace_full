# 📜 Decision Log - Evolution Stables

**Purpose:** Document significant architectural and strategic decisions.  
**Principle:** Decisions without context are just rules. Understand why.

---

## Read This First (2026-03-12)

- This file is a historical ledger, not the live source of truth for current operating rules.
- `/home/evo/workspace` is the canonical build surface.
- `/home/evo` is control plane only.
- `/home/evo/.env` remains the single shared env source.
- `DNA/agents/AI_CONTEXT.md` is the current agent-entry context.
- `DNA/INBOX.md` replaces the old workspace-level `OPERATING_BACKLOG.md` pattern.
- Older entries may mention legacy paths such as `/home/evo/projects`, `/home/evo/00_DNA`, or `/evo/...`; treat those as historical unless a newer decision reaffirms them.
- Do not rewrite older decisions just to modernize paths; append a new decision when the operating model changes.

---

## 2026-03-16: STACK.md Authority Model + Drive Sync Removal

### Decision
Add `DNA/ops/STACK.md` as the live tool registry and formally confirm
Google Drive context sync is removed from the workspace.

### Authority Model
Three surfaces, three distinct purposes:
- `STACK.md` - live locked and active tool registry (what we use now)
- `DECISION_LOG.md` - historical rationale ledger (why we decided, this file)
- `TECH_RADAR.md` - personal research journal (consult on demand, not auto-loaded by agents)

`TECH_RADAR.md` is not part of the agent entry chain. It is a personal
memory tool: consult it when you want to ask "have we looked at X before?"
or "find something on the radar that could solve Y."

### Drive Sync Confirmed Removed
Google Drive context sync (`sync-md-context-gdocs.sh` plus the old 6-hour cron)
has been decommissioned. Google Drive is assets only going forward.
The `CONVENTIONS.md` operational sync section is now historical and should
not be treated as active automation.

### Impact
- Agents have one unambiguous place to check locked tools (`STACK.md`)
- `TECH_RADAR.md` retains value as a personal research log without blocking the entry chain
- No split-brain between tool-governance surfaces
- Drive sync removal is formally recorded

### Related Files
- `DNA/ops/STACK.md`
- `DNA/ops/TECH_RADAR.md`
- `DNA/ops/CONVENTIONS.md`
- `DNA/ops/DECISION_LOG.md`

---

## 2026-03-13: Stage-One Horse Firestore Writes Use Source-Derived Stud Book IDs

### Decision
For stage-one horse registration in `projects/SSOT_Build`, Firestore documents live at `horses/{microchip_number}`, and `stud_book_id` must be derived from Loveracing / Stud Book source evidence rather than copied from the existing local `horse_id` field.

### Context
- The current local `SSOT_Build` seed still carries legacy internal horse IDs such as `HRS-001` and `HRS-002`.
- Those local IDs are useful inside the prototype, but they are not the Stud Book record IDs and should not become long-term cloud identifiers.
- The upstream factual horse identity source is the Loveracing / Stud Book page, which already exposes the durable Stud Book record in the URL path.
- The first live Firestore workflow for this repo is intentionally limited to horse identity truth only, before trainer/owner/governing associations or lease terms are added.

### Decision Details
- Use the horse microchip as the Firestore document key:
  - `horses/{microchip_number}`
- Derive `stud_book_id` from the Stud Book source URL or equivalent explicit source evidence.
- Treat the current local `horse_id` as a prototype-local identifier only.
- Keep stage-one horse docs limited to identity truth, pedigree/performance links, and verification metadata.

### Impact
- Prevents legacy local UI identifiers from leaking into the long-term Firestore contract.
- Keeps the cloud-side horse identity aligned to external source evidence.
- Makes the first Firestore workflow safe to follow manually for the current two seeded horses before a browser write adapter exists.

### Related Files
- `projects/SSOT_Build/src/lib/ssot/firestore-horse-stage-one.ts`
- `projects/SSOT_Build/data/firestore/stage-one/horses.prudentia-first-gear.json`
- `projects/SSOT_Build/docs/contracts/FIRESTORE_WRITE_MAP_2026-03-13.md`
- `projects/SSOT_Build/README.md`
- `DNA/ops/TRANSITION.md`

---

## 2026-03-13: Horse Sync State Stays Local-First Until Firestore Exists

### Decision
Keep the horse repository surface intact and add a small manual sync-status layer in `SSOT_Build` while Firestore is being brought online, instead of removing local content before the database and repository seam are proven.

### Context
- The current app is still local-first and persists horse edits in browser local state.
- The `evolution-engine` Google project does not yet have a default Firestore database provisioned, so live stage-one horse writes are blocked today.
- The immediate need is operational clarity: know whether a given horse is local only, Firestore only, or manually confirmed as synced, without breaking the current repository surface.

### Decision Details
- Add a horse sync-state model with three statuses:
  - `local`
  - `firestore`
  - `synced`
- Persist that status locally for now as transition support.
- Do not treat the manual status layer as the final truth; replace it with a real Firestore-backed check once the database exists and the repository adapter is validated.
- Keep profile-image blobs out of Firestore and standardize their future Cloud Storage object paths under stable entity-key folders.

### Impact
- Preserves the working local authoring flow while Firestore is still unavailable.
- Gives the horse surface an explicit migration state instead of hidden assumptions.
- Creates a clean bridge from current local/static image handling toward Cloud Storage-backed media.

### Related Files
- `projects/SSOT_Build/App.tsx`
- `projects/SSOT_Build/src/lib/ssot/horse-profile-sync.ts`
- `projects/SSOT_Build/src/lib/ssot/profile-image-storage.ts`
- `projects/SSOT_Build/scripts/write_stage_one_horses_to_firestore.py`
- `projects/SSOT_Build/README.md`
- `DNA/ops/TRANSITION.md`

---

## 2026-03-13: Firestore Build Wiring Is The Next SSOT Priority

### Decision
Now that the first two stage-one horse identity records are live in Firestore, the next SSOT implementation priority is wiring Firestore into the live `SSOT_Build` horse surface rather than continuing with more contract-only work.

### Context
- The project now has a real Firestore database in `evolution-engine` running in Native mode in `australia-southeast1`.
- The `horses` collection already contains the live stage-one Prudentia and First Gear identity records.
- The app still reads from the local seed path and uses a manual sync-state overlay because there is no browser-side Firestore read seam yet.
- We now have enough real cloud state to stop treating Firestore as hypothetical for the horse module.

### Decision Details
- Next implementation target:
  - read live horse identity docs from Firestore
  - compare them against the current local horse surface
  - surface automatic `local|firestore|synced` status in the UI
  - keep local fallback content in place until parity is proven
- Do not expand into trainer/owner/governing/lease Firestore writes before the horse read seam is proven inside the actual build.

### Impact
- Focuses the next session on the highest-value seam with the least ambiguity.
- Converts the current Firestore work from setup into real product integration.
- Keeps the migration incremental and reversible.

### Related Files
- `projects/SSOT_Build/App.tsx`
- `projects/SSOT_Build/src/lib/ssot/firestore-ssot-read-repository.ts`
- `projects/SSOT_Build/src/lib/ssot/horse-profile-sync.ts`
- `projects/SSOT_Build/README.md`
- `DNA/ops/TRANSITION.md`

---

## 2026-03-13: Modular SSOT Assembly Contract For HLT

### Decision
Treat `projects/SSOT_Build` as the only canonical authoring surface for horse and lease data, and define HLT as a derived outcome assembled from five modular inputs: `Horses`, `Trainers / Stables`, `Owners`, `Governing Bodies`, and `Lease Commercial Terms`.

### Context
- The current app already exposes those repository sections as the real intake surfaces in `SSOT_Build`.
- The desired long-term model is modular, so HLT should depend on section qualification and selected records, not on every individual leaf field or on UI-specific shortcuts.
- The current prototype still contains local-only overlays, hardcoded defaults, and coupling that should not become the long-term Firestore contract.
- `Evolution_Platform` previously carried SSOT-shaped consumer logic, but the canonical origin for any Firestore-bound datapoint should be `SSOT_Build`.

### Decision Details
- The stable contract is:
  - `Qualified Horse`
  - `Qualified Trainer / Stable`
  - `Qualified Owner`
  - `Qualified Governing Body`
  - `Complete Lease Commercial Terms`
  - together produce `HLT`
- HLT is a derived assembly layer, not a source record.
- If a required record does not exist, it must be created in its repository section before HLT generation.
- Field-level evolution inside a module is allowed without redesigning HLT, as long as the module still satisfies its qualification rule.
- Firestore should store the canonical modules as independent write surfaces first, with HLT records and generated documents modeled as derived outputs.

### Impact
- Gives `SSOT_Build` a clean domain contract before Firestore implementation.
- Prevents hidden UI defaults and one-off coupling from becoming permanent storage rules.
- Keeps future schema evolution modular at the section level.
- Clarifies that `Evolution_Platform` should consume published SSOT data rather than author it.

### Related Files
- `projects/SSOT_Build/docs/contracts/CURRENT_DATA_CONTRACT_2026-03-13.md`
- `projects/SSOT_Build/README.md`
- `DNA/ops/TRANSITION.md`

---

## 2026-03-13: Google Execution Path Standardization For Reel Generator

### Decision
Standardize `projects/reel-generator` on Vertex AI with ADC against `evolution-engine` as the default Google execution path, while retaining the Gemini Developer API key path only for compatibility checks and quota diagnostics.

### Context
- Workspace governance already prefers Google tooling through `evolution-engine` and ADC over raw API keys.
- `reel-generator` had drifted into a direct `GEMINI_API_KEY` implementation.
- Live verification on March 13, 2026 showed the current Developer API key is valid for text generation but has zero Gemini image-generation quota.
- Live verification also showed the local ADC file exists but fails to refresh with `invalid_rapt`, which means Vertex AI auth is blocked by stale user reauthentication rather than missing code.

### Decision Details
- `scripts/generate_nanobanana.py` now exposes explicit Google auth modes and a `--diagnose-google` flow.
- `/home/evo/.env` now declares the non-secret Vertex defaults:
  - `GOOGLE_GENAI_USE_VERTEXAI=true`
  - `GOOGLE_CLOUD_PROJECT=evolution-engine`
  - `GOOGLE_CLOUD_LOCATION=global`
- A local Google Cloud CLI install under `/home/evo/google-cloud-sdk` is the supported control-plane tool for refreshing ADC and testing future Google workflows in WSL.

### Impact
- Aligns project behavior with workspace policy instead of silently favoring raw API-key flows.
- Separates quota problems from auth problems during debugging.
- Makes future Google-first automation reusable across projects once ADC is refreshed.

### Related Files
- `projects/reel-generator/scripts/generate_nanobanana.py`
- `projects/reel-generator/README.md`
- `/home/evo/.env`
- `DNA/ops/TRANSITION.md`

---

## 2026-02-28: Build Philosophy Canonicalization

### Decision
Canonicalize project names, storage paths, and layer terminology across all build-philosophy documents and core DNA files to eliminate naming drift and path inconsistencies.

### Context
- Multiple DNA build-philosophy docs had minor naming and path drift.
- Old references existed to `evolution-studios-engine`, `evolution-content-engine`, `01_Platform`, and `/mnt/native`.
- The safe-path standard and four-layer architecture were already defined elsewhere in DNA but not applied consistently.

### Decision Details
**Project Naming Alignment:**
- Replaced `evolution-studios-engine` with `EvolutionStudio`.
- Replaced `evolution-content-engine` with `EvolutionContent`.
- Replaced `01_Platform`, `02_Content_Factory`, `04_Intelligence` with `EvolutionPlatform`, `EvolutionContent`, `EvolutionIntelligence` where they refer to current repos.
- Kept `Evolution-3.1` only when referring to the historical codebase or Git history.

**Safe-Path Storage Alignment:**
- Confirmed the canonical safe-path standard:
  - `/home/evo/projects` – all active repos.
  - `/home/evo/models` – all model files and weights.
  - `/home/evo/00_DNA` – source-of-truth docs.
- Removed legacy references to `/mnt/native` and 500GB Ext4 volumes from `Tech_Stack_2026.md`.
- Updated all examples to assume the direct bind-mount of the Samsung 990 PRO into `/home/evo/`.

**Layer Naming Standardization:**
- Standardized the architecture language to four explicit layers: **Content / Intelligence / Infrastructure / External**.
- Updated `DECISION_LOG.md`, `OPERATING_BACKLOG.md`, `SEPARATION_OF_CONCERNS.md`, and related build-philosophy docs to use this four-layer stack consistently.

### Impact
- ✅ Build philosophy is now 100% aligned with actual filesystem layout and repo structure.
- ✅ Removes ambiguity for agents and humans about where code, models, and DNA live.
- ✅ Ensures future architecture and tooling decisions use the same four-layer and safe-path vocabulary.

### Related Files
- `00_DNA/build-philosophy/ARCHITECTURE_STRATEGY.md`
- `00_DNA/build-philosophy/Evolution_OS.md`
- `00_DNA/build-philosophy/Tech_Stack_2026.md`
- `00_DNA/DECISION_LOG.md`
- `00_DNA/OPERATING_BACKLOG.md`
- `00_DNA/build-philosophy/SEPARATION_OF_CONCERNS.md`

---

## 2026-02-27: Model-Agnostic Memory System

### Decision
Create a model-agnostic memory system using DNA files instead of relying on AI session persistence.

### Context
Kimi CLI (and other AI tools) have session persistence, but:
- Sessions don't auto-resume
- Each new terminal starts fresh
- Switching AI tools (Kimi → Claude → Kilo) loses all context
- Re-explaining project structure every session is wasteful

### Decision Details
**Approach:** DNA as persistent memory
- `🧠 AI_CONTEXT.md` - Entry point for ANY AI
- `OPERATING_BACKLOG.md` - Current work & blockers
- `DECISION_LOG.md` - Why we made key choices
- All files are plain markdown (works with any AI)

**Rejected Alternatives:**
- ❌ Rely on Kimi's `--continue` flag (tool-specific, doesn't survive tool switches)
- ❌ Build custom memory server (over-engineered for current needs)
- ❌ Use MCP memory (experimental, adds complexity)

### Impact
- ✅ Can switch between Kimi, Claude, Kilo seamlessly
- ✅ AI picks up context immediately by reading DNA
- ✅ No re-explaining project structure
- ✅ Version-controlled memory (git history of decisions)

### Related Files
- `00_DNA/🧠 AI_CONTEXT.md`
- `00_DNA/🧠 MEMORY_PROTOCOL.md`
- `00_DNA/OPERATING_BACKLOG.md`

---

## 2026-02-27: Consolidation Strategy (Phase 6)

### Decision
Consolidate scattered projects into 4-layer architecture with central vault.

### Context
/evolved into chaos:
- 20+ folders in root
- Projects scattered (Evolution_* folders everywhere)
- Multiple .env files with duplicated keys
- No clear separation of concerns
- Travel mode not configured

### Decision Details
**New Structure:**
```
/evo/
├── 00_DNA/              # Knowledge base
├── projects/            # Active work
│   ├── Content Layer    # What users see
│   ├── Intelligence     # What system knows
│   ├── Infrastructure   # What runs it
│   └── External         # Third-party tools
├── .env                 # One vault for all keys
└── _*/                  # Supporting folders
```

**Key Principles:**
1. Content ≠ Intelligence ≠ Infrastructure ≠ External (strict separation)
2. One vault (`/evo/.env`) symlinked by all projects
3. DNA is source of truth (standards live there, not in projects)

**Rejected Alternatives:**
- ❌ Monorepo (too complex, forces coupling)
- ❌ Keep scattered structure (continues drift)
- ❌ Merge all into single project (loses separation)

### Impact
- ✅ Clean root directory
- ✅ Clear project boundaries
- ✅ Single point for API keys
- ✅ Travel mode ready (OpenClaw + Kimi K2)

### Related Files
- `FINAL_STRUCTURE.md`
- `PROJECTS_INDEX.md`
- `🏗️ Build Rules.md`

---

## 2026-02-27: Central API Vault

### Decision
Use single `/evo/.env` file symlinked by all projects.

### Context
Multiple .env files across projects:
- Duplicated keys
- Inconsistent updates
- Security risk (some committed accidentally)
- Hard to rotate keys

### Decision Details
**Implementation:**
- Master: `/evo/.env` (chmod 600)
- Projects: `ln -sf /evo/.env .env`
- Template: `/evo/_config/.env.template`
- Validation: `evo vault check`

**Rejected Alternatives:**
- ❌ Keep per-project .env files (duplication, drift)
- ❌ Use environment manager (overkill for current scale)
- ❌ HashiCorp Vault (enterprise overkill)

### Impact
- ✅ Change key once, applies everywhere
- ✅ Consistent configuration
- ✅ Easier rotation
- ✅ Simpler backup (one file)

### Related Files
- `🔐 Secrets Guide.md`
- `_config/.env.template`
- `_scripts/vault.sh`

---

## 2026-02-27: DNA as Obsidian Vault

### Decision
Structure 00_DNA as an Obsidian vault for knowledge management.

### Context
DNA was a collection of markdown files but:
- Hard to navigate
- No linking between concepts
- Not visual/graph-based
- Hard to find related information

### Decision Details
**Features:**
- Obsidian app integration (`.obsidian/` folder)
- Wiki-style links: `[[Related Document]]`
- Emoji prefixes for quick visual scanning: `🏠` `🔐` `🧠`
- Graph view for exploring connections

**Rejected Alternatives:**
- ❌ Wiki software (overhead, hosting)
- ❌ Notion (proprietary, API limits)
- ❌ Plain files (hard to navigate at scale)

### Impact
- ✅ Visual knowledge graph
- ✅ Quick navigation
- ✅ Links between related concepts
- ✅ Works offline

### Related Files
- `00_DNA/.obsidian/`
- `🏠 Home.md`

---

## 2026-02-27: Docker Management Philosophy

### Decision
Keep Docker configurations decentralized (per-project) but provide centralized simple management via `evo docker` commands.

### Context
Docker is used extensively but:
- User getting Windows alerts about containers
- Doesn't want to learn Docker deeply
- Each project legitimately needs different container configs
- Needs simple start/stop control without memorizing commands

### Decision Details
**Architecture:**
- Each project keeps its own `docker-compose.yml` (project-specific tweaks)
- No root-level docker-compose (avoids "everything or nothing")
- Simple `evo docker` commands for management
- Human-readable documentation in `🐳 Docker Guide.md`

**Commands Provided:**
- `evo docker status` - See what's running
- `evo docker list` - See available projects
- `evo docker start [project]` - Start specific project
- `evo docker stop [project]` - Stop specific project
- `evo docker stop-all` - Emergency brake
- `evo docker clean` - Free disk space

**Rejected Alternatives:**
- ❌ Single root docker-compose.yml (forces all-or-nothing, loses per-project flexibility)
- ❌ Remove Docker entirely (too many services depend on it)
- ❌ Force user to learn Docker CLI (unnecessary complexity)
- ❌ Kubernetes (massive overkill for local dev)

### Impact
- ✅ Simple commands hide Docker complexity
- ✅ Each project can customize its containers
- ✅ Easy to see what's consuming resources
- ✅ Emergency stop available
- ✅ No Docker knowledge required

### Related Files
- `🐳 Docker Guide.md`
- `_scripts/evo-docker.sh`

---

## 2026-02-27: Development Enhancements Stack

### Decision
Add lightweight productivity tools (FZF, Zoxide, Just, Starship, git hooks) to enhance development workflow without heavy overhead.

### Context
Terminal workflow was basic:
- No fuzzy finding (lots of typing paths)
- No command history search (arrow keys only)
- Basic prompt (no git status visibility)
- Risk of committing secrets (no protection)
- No task runner (typing long commands)

### Decision Details
**Tools Chosen:**

| Tool | Purpose | Overhead |
|------|---------|----------|
| Git hooks | Prevent .env commits | Zero |
| FZF | Fuzzy find files/history | ~10ms startup |
| Zoxide | Smarter cd command | ~5ms startup |
| Just | Task runner | None (on demand) |
| Starship | Pretty prompt | ~20ms startup |
| Bash aliases | Shortcuts | Zero |
| Obsidian templates | Note consistency | Zero |
| EditorConfig | Format consistency | Zero |

**Total overhead:** ~35ms startup, ~10MB RAM

**Why not heavier tools?**
- ❌ Docker-based dev environments (overkill for local work)
- ❌ Complex dotfiles management (maintenance burden)
- ❌ IDE-specific plugins (not portable)
- ❌ Heavy zsh frameworks (slow startup)

**Installation:**
- Optional scripts in `_scripts/`
- Source control for configs
- Easy to uninstall (just remove source lines)

### Impact
- ✅ Faster navigation (Zoxide learns paths)
- ✅ Better command history (FZF)
- ✅ Consistent tasks (Justfile)
- ✅ Visual git status (Starship)
- ✅ Protection from accidents (git hooks)
- ✅ Consistent notes (Obsidian templates)

### Related Files
- `🛠️ Enhancements Guide.md`
- `_scripts/install-git-hooks.sh`
- `_scripts/install-enhancements.sh`
- `_config/bash-evo.sh`
- `Justfile`

---

## 2026-02-27: Approved Sources Registry

### Decision
Create a curated registry of approved tools and repositories in DNA to enable the "Adapt > Integrate > Build" philosophy.

### Context
User has 100+ starred repos on GitHub but:
- No central reference for "what's been vetted" → **SOLVED: skills/approved_sources.md is now single source of truth**
- AI assistants don't know what's pre-approved → **SOLVED: All DNA files point to approved_sources.md**
- Hard to remember why certain tools were chosen
- Re-invention happens when knowledge isn't shared

### Decision Details
**Created:** `skills/approved_sources.md`

**Structure:**
- Organized by category (AI, Productivity, Architecture, Agent Orchestration, etc.)
- Each entry: What it does, When to use, Why approved
- Single source of truth: All DNA files reference this for repo listings
- Anti-patterns section (what to avoid)

**Integration:**
- Referenced in `🧠 AI_CONTEXT.md` - AI assistants check it first
- Referenced in `AGENTS.core.md` - Research Before Build rule
- Living document - add new finds as they're vetted

**Philosophy:**
- Curated > Comprehensive (quality over quantity)
- Opinionated > Neutral (these are YOUR approved tools)
- Living > Static (update as you learn)

### Impact
- ✅ AI assistants can recommend pre-approved solutions
- ✅ New team members (or future you) see what's vetted
- ✅ Prevents re-researching the same tools
- ✅ Documents WHY choices were made

### Related Files
- `skills/approved_sources.md`
- `skills/INDEX.md`

---

## 2026-02-27: Tech Radar - Bullshit Filter System

### Decision
Create a Tech Radar system to track, evaluate, and make decisions about new tools without repeating conversations or randomly adopting tech.

### Context
User is getting firehosed with new AI tools, repos, and "vibe coding" content:
- Instagram reels about new tools daily
- GitHub starred repos piling up
- Same conversations happening multiple times
- No systematic way to evaluate before trying
- Risk of "shiny object syndrome"

### Decision Details
**Created 3-part system:**

1. **_archive/2026-02/INBOX.md** - Rapid capture (archived path)
   - Quick dump of new discoveries
   - Source, link, one-liner, hot take
   - Process every 48 hours (inbox zero)

2. **TECH_RADAR.md** - Evaluation tracker
   - 4 statuses: Reject / Assess / Trial / Adopt
   - Full evaluation criteria
   - Decision deadlines
   - Historical record (Archive)

3. **Integration**
   - AI assistants check radar before recommending
   - User logs new finds in Inbox
   - Regular review schedule (weekly/monthly/quarterly)

**Processed first batch:**
- 9 items from Instagram content firehose
- 4 moved to Assess (Google Workspace, Antigravity, NotebookLM, etc.)
- 1 moved to Trial (NotebookLM prompts)
- 4 archived (educational content, already adopted tools)

**Key insight:** Most "new" tools are:
- Educational content (archive)
- Variations of existing tools (assess vs current stack)
- Solutions to problems we already solved (reject/assess)
- Actual new capabilities (rare - these are gold)

### Impact
- ✅ No more repeated conversations about same tools
- ✅ Clear decision framework (Reject/Assess/Trial/Adopt)
- ✅ Historical memory of why decisions were made
- ✅ Bullshit filter for hype-driven content
- ✅ Still allows experimentation (Trial status)

### Philosophy Alignment
- **Done > Perfect:** Simple markdown system, not a complex app
- **Don't reinvent:** Uses existing Tech Radar concept (ThoughtWorks)
- **Get shit done:** Rapid capture, clear decisions, move on
- **Memory:** DNA tracks everything, no repeated evaluations

### Related Files
- `TECH_RADAR.md`
- `_archive/2026-02/INBOX.md`
- `skills/INDEX.md`

---

## 2026-02-27: Quick Wins Implementation (Done > Perfect)

### Decision
Ship Phase 1 quick wins immediately (VS Code workspace, just update, backup, .env.schema) rather than over-engineering.

### Context
Had a list of potential enhancements:
- High impact: git diff secrets check, just update, container health, backup
- Medium impact: VS Code workspace, .env.schema, custom Starship, uptime monitor

### Decision Details
**Shipped Immediately (80% solutions):**

1. **VS Code Workspace** (`evolution.code-workspace`)
   - Multi-root workspace with 5 folders
   - Excludes build artifacts and large files
   - Recommended extensions pre-configured

2. **Just Update Task** (`just update`)
   - Pulls DNA + all project repos
   - One command sync everything
   - Shows failures but continues

3. **Backup Script** (`just backup`)
   - Creates timestamped tar.gz in `_backups/auto/`
   - Excludes node_modules, .next, models, etc.
   - Simple, works, done.

4. **.env.schema + Validation** (`evo vault validate`)
   - Schema documents required keys
   - Validation checks if critical keys exist
   - Not over-engineered - just checks presence

**Deferred (Don't Need Yet):**
- ❌ Git diff secret scanning (hook already blocks commits)
- ❌ Container health checks (docker status shows state)
- ❌ Custom Starship module (default shows git status)
- ❌ Uptime monitor (no SLA requirements yet)

### Impact
- ✅ VS Code workspace: Open one file, see whole project
- ✅ Just update: Single command to sync everything
- ✅ Backup: One command to protect work
- ✅ Validation: Catch missing env vars before runtime errors

**Time to implement:** 30 minutes total  
**Value:** High - daily workflow improvements

### Philosophy Alignment
- **Done > Perfect:** 80% solutions that work now
- **Don't reinvent:** Used existing tools (just, tar, grep)
- **Leverage best practices:** VS Code workspaces are standard
- **Get shit done:** Shipped in one session vs. planning forever

### Related Files
- `evolution.code-workspace`
- `Justfile` (update, backup tasks)
- `_config/.env.schema`
- `_scripts/vault.sh` (validate function)

---

## 2026-02-27: Shell Persistence Bug - FIXED with Script Installation

### Problem
After implementing `kimic` as a shell function in `bash-evo.sh`, user opened new terminal and got:
```
$ kimic
kimic: command not found
```

**Root Cause:** WSL2 doesn't reliably source `~/.bashrc` in new terminal windows (VS Code terminal, Windows Terminal, non-login shells).

### Attempted Solutions

#### Solution 1: Manual Sourcing (Failed)
- Added `source ~/.bashrc` to workflow
- Failed: Users forget, WSL2 inconsistent

#### Solution 2: .bash_profile Fallback (Partial)
- Added `[[ -f ~/.bashrc ]] && source ~/.bashrc` to `~/.bash_profile`
- Helped but still WSL2 edge cases

#### Solution 3: Script Installation (✅ PERMANENT FIX)
Converted `kimic` from shell function to standalone script:

```bash
# Install to user-local bin (no sudo needed)
cp _scripts/kimic.sh ~/.local/bin/kimic
chmod +x ~/.local/bin/kimic
```

**Why this works:**
- `~/.local/bin` is in PATH by default on WSL2
- Scripts work in EVERY shell type (login, non-login, interactive, non-interactive)
- No sourcing required, no WSL2 edge cases
- Available immediately in new terminals

### Current State
- ✅ `kimic` script installed to `~/.local/bin/kimic`
- ✅ Available in all new terminals without sourcing
- ✅ `evo doctor` verifies installation
- ✅ DNA memory system now reliable

### Verification
```bash
# In a BRAND NEW terminal (no sourcing):
which kimic           # Should show ~/.local/bin/kimic
evo doctor            # Should show ✅ kimic script installed
kimic                 # Should load DNA context
```

### Files
- `_scripts/kimic.sh` - The script
- `_scripts/evo-doctor.sh` - Updated check
- `~/.local/bin/kimic` - Installation location

---

## 2026-02-27: Dotfiles Strategy - Portable DNA System

### Decision
Create two-repo system for portability: `evo-dotfiles` (tools/config) + `evo-brain` (private DNA data).

### Context
DNA system works perfectly on current machine, but:
- No way to replicate on laptop, new PC, server
- Manual setup each time is error-prone
- WSL2 environment not portable
- Want "clone and go" experience

### Decision Details

**Two-Repo Architecture:**

| Repo | Type | Contents | Privacy |
|------|------|----------|---------|
| `evo-dotfiles` | Config | Scripts (kimic, claudec, etc.), bash config, VS Code settings | Can be public |
| `evo-brain` | Data | Actual DNA files (AI_CONTEXT, OPERATING_BACKLOG, DECISION_LOG) | **Private** |

**New Machine Workflow:**
```bash
# 1. Clone dotfiles
git clone git@github.com:yourusername/evo-dotfiles.git
cd evo-dotfiles && ./install.sh

# 2. Clone brain
git clone git@github.com:yourusername/evo-brain.git ~/00_DNA

# 3. Done
evo doctor
kimic
```

**Files Created:**
- `~/evo-dotfiles/` - Dotfiles repo structure
- `install.sh` - One-command setup
- `README.md` - Documentation
- `evo-brain-README.md` - Template for private repo

**Key Insight:** Separation of tools (shareable) from data (private) enables both portability and security.

### Impact
- ✅ One-command setup on any machine
- ✅ DNA syncs across devices via git
- ✅ Tools stay version-controlled
- ✅ Private data stays private

### Next Steps
1. Initialize `evo-dotfiles` repo
2. Initialize `evo-brain` repo (private)
3. Test on fresh WSL instance

### Related Files
- `~/evo-dotfiles/` - Dotfiles directory
- `evo-brain-README.md` - Brain repo template

---

## 2026-02-27: Complete AI Tool Wrapper Family

### Decision
Build wrappers for ALL AI tools in the stack: Kimi, Claude, Aider, Gemini, Kilo.

### Context
User has multiple AI tools but only Kimi had a DNA wrapper. Each tool needs its own "read before we start" trigger.

### Decision Details

**New Wrappers Added:**

| Command | Tool | Method | Status |
|---------|------|--------|--------|
| `kimic` | Kimi CLI | Pipes DNA as first message | ✅ Already done |
| `claudec` | Claude CLI | System prompt injection | ✅ Already done |
| `aidere` | Aider | `--read` flag | ✅ Already done |
| `geminic` | Gemini CLI | `GEMINI_SYSTEM_MD` env var | ✅ **NEW** |
| `kiloc` | Kilo Code CLI | Context file injection | ✅ **NEW** |
| `dna-context` | Any tool | Clipboard/pipe output | ✅ Already done |

**Implementation:**
- Created `_scripts/geminic.sh` and `_scripts/kiloc.sh`
- Installed to `~/.local/bin/`
- Updated `evo-doctor.sh` to check all tools
- Pushed to `evo-dotfiles` repo
- Created `AI_TOOL_WRAPPERS.md` reference doc

**Pattern:**
1. Create wrapper script
2. Install to `~/.local/bin/`
3. Add check to `evo-doctor.sh`
4. Update documentation

### Usage

```bash
# Any AI tool - just add 'c' suffix
kimic                    # Kimi with DNA
claudec                  # Claude with DNA
aidere                   # Aider with DNA
geminic                  # Gemini with DNA
kiloc                    # Kilo with DNA

dna-context | xclip      # Any other tool
```

### Impact
- ✅ Every AI tool in stack has DNA wrapper
- ✅ Consistent pattern: `TOOLc` = tool with context
- ✅ Easy to add new tools
- ✅ All documented

### Related Files
- `_scripts/kimic.sh`, `claudec.sh`, `aidere.sh`, `geminic.sh`, `kiloc.sh`
- `~/.local/bin/*` (installed wrappers)
- `AI_TOOL_WRAPPERS.md` (complete reference)

---

## 2026-02-27: Universal AI Tool DNA Integration

### Decision
Create DNA loaders for ALL AI tools: Kimi, Claude, Aider, VS Code, and web UIs.

### Context
DNA memory system worked for `kimic`, but user has multiple AI tools:
- Kimi CLI (primary)
- Claude CLI (installed)
- Aider (coding assistant)
- VS Code Copilot/Continue/Cline
- Web UIs (ChatGPT, Gemini, etc.)

**Problem:** Each tool needs its own DNA injection method. No universal solution existed.

### Decision Details

**Created Tool-Specific Loaders:**

| Tool | Loader | Method |
|------|--------|--------|
| Kimi | `kimic` | Script: `kimi -p "Read DNA..."` |
| Claude | `claudec` | Script: `claude --system-prompt` |
| Aider | `aidere` | Script: `aider --read DNA...` |
| VS Code Copilot | Auto | `.github/copilot-instructions.md` |
| VS Code Continue | Auto | `.vscode/settings.json` |
| VS Code Cline | Auto | `.vscode/settings.json` |
| Any Web UI | `dna-context` | Clipboard output: `dna-context \| xclip` |
| Any CLI | `dna-context` | Pipe: `dna-context \| tool` |

**Files Created:**
- `_scripts/kimic.sh` → `~/.local/bin/kimic`
- `_scripts/claudec.sh` → `~/.local/bin/claudec`
- `_scripts/aidere.sh` → `~/.local/bin/aidere`
- `_scripts/dna-context.sh` → `~/.local/bin/dna-context`
- `.github/copilot-instructions.md`
- `.vscode/settings.json`

**Key Insight:** Same DNA files, different delivery mechanism per tool. The context is constant; only the injection method varies.

### Usage

```bash
# CLI tools
kimic                    # Kimi with DNA
claudec                  # Claude with DNA
aidere                   # Aider with DNA

# VS Code - automatic
# Just open VS Code, DNA loads via copilot-instructions.md

# Any web UI
dna-context | xclip -selection clipboard
# Paste into ChatGPT, Gemini, etc.
```

### Impact
- ✅ Every AI tool gets DNA context
- ✅ No manual file reading required
- ✅ Consistent context across all tools
- ✅ Easy to add new tools (just create wrapper)

### Related Files
- `_scripts/kimic.sh`, `claudec.sh`, `aidere.sh`, `dna-context.sh`
- `~/.local/bin/*` (installed scripts)
- `.github/copilot-instructions.md`
- `.vscode/settings.json`
- `evo-doctor.sh` (checks all tools)

---

## 2026-02-27: Memory Protocol Enforcement Mechanism

### Decision
Create enforcement tools to ensure AI assistants actually READ DNA files instead of claiming "no previous context."

### Context
The model-agnostic memory system was documented in DNA, but real-world test failed:
- User started new Kimi session: `kimi`
- User asked: "do you recall what we were talking about last?"
- Kimi responded: "I don't have access to our previous conversation history"

**This happened despite:**
- ✅ `🧠 AI_CONTEXT.md` existing
- ✅ `OPERATING_BACKLOG.md` being current
- ✅ `🧠 MEMORY_PROTOCOL.md` documenting the system
- ✅ Previous "fix" being applied

**Root Cause:** Documentation ≠ Enforcement. AI assistants don't automatically read files.

### Decision Details
**Created Enforcement Layer:**

1. **`_config/kimi-startup.sh`** - Function wrapper for `kimi` command
   - Detects new sessions vs. continued sessions
   - Auto-injects DNA context on startup
   - Provides `kimic` (with context), `kimil` (continue), `kimif` (fresh)

2. **Updated `_config/bash-evo.sh`** - Enhanced aliases
   - `kimic` now explicitly instructs AI to READ DNA first
   - Warning message in prompt: "DO NOT say 'I don't have access...'"
   - `kimif` for truly fresh sessions (escape hatch)

**Usage:**
```bash
kimic                 # Start with DNA context (RECOMMENDED)
kimil                 # Continue last session  
kimif                 # Fresh session (no context)
kimi -C               # Continue specific session
```

**Rejected Alternatives:**
- ❌ Alias `kimi='kimi -p "read DNA..."'` (breaks `kimi -C` and other flags)
- ❌ Modify Kimi binary (impossible, external tool)
- ❌ User training only (failed - humans forget)
- ❌ Accept status quo (defeats purpose of memory system)

**Why wrappers work:**
- Shell functions intercept commands before execution
- Can detect context (new vs continued session)
- User-friendly (same command name)
- Non-destructive (can bypass with `command kimi`)

### Impact
- ✅ AI forced to acknowledge DNA before responding
- ✅ No more "I don't have previous context" excuses
- ✅ Clear escape hatch (`kimif`) for truly new work
- ✅ Works with existing Kimi workflows (`-C`, `-S`, etc.)

### Related Files
- `_config/kimi-startup.sh`
- `_config/bash-evo.sh`
- `🧠 MEMORY_PROTOCOL.md`

---

## 2026-02-27: Empty Folder Protection

### Decision
Add README/.gitkeep files to empty critical directories to prevent confusion and document their purpose.

### Context
During a routine sweep, discovered several empty folders:
- `00_DNA/vault/` - No documentation about its purpose
- `models/` - Empty but expected to contain AI models
- `_logs/2026-02-27/` - Empty log directory

Empty folders create ambiguity:
- Are they supposed to be empty?
- Was content accidentally deleted?
- What should go here?

### Decision Details
**Fix:** Add placeholder documentation to empty critical directories:

1. **`00_DNA/vault/README.md`** - Explains vault system, points to master vault at `/evo/.env`
2. **`models/README.md`** - Documents expected model storage structure
3. **`_logs/2026-02-27/.gitkeep`** - Keeps directory in git (standard practice for logs)

**Philosophy:** 
- Empty folders should document WHY they're empty
- Critical infrastructure folders need READMEs
- Logs directories use `.gitkeep` to persist structure

**Rejected Alternatives:**
- ❌ Delete empty folders (they exist for a reason)
- ❌ Ignore them (creates technical debt)
- ❌ Fill with dummy content (misleading)

### Impact
- ✅ No more confusion about empty directories
- ✅ Clear documentation of expected content
- ✅ Self-documenting structure

### Related Files
- `00_DNA/vault/README.md`
- `models/README.md`
- `_logs/*/.gitkeep`

---

## 2026-02-27: Infrastructure & Content Consolidation (Final Polish)

### Decision
Unify all LLM-related infrastructure into `projects/Infrastructure/Evolution_LLM` and remove redundant "drift" folders from the `projects/` root.

### Context
Post-Phase 6, several inconsistencies remained:
- Two LLM folders: `local-llm` (legacy GLM-4) and `Local_LLM_2` (active hybrid orchestrator).
- Three redundant shell folders: `Evolution-Content-Factory`, `evolution-content-engine`, and `n8n`.
- Confusion regarding the purpose of local LLMs vs. Cloud APIs.

### Decision Details
**Implementation:**
- **Evolution_LLM:** Merged `Local_LLM_2` (orchestrator code) with `local-llm` (local model weights). The system now prioritizes a Hybrid Cloud path (Groq/Gemini) but maintains GLM-4 as a local fallback for privacy and cost control.
- **Surgical Cleanup:** Identified that `Evolution_Content` had successfully absorbed the logic of the "Factory" and "Engine" shells. These shells were moved to `_archive/sudo_cleanup_required/`.
- **Active Path:** `projects/External/N8N` confirmed as the active N8N instance.

**Rejected Alternatives:**
- ❌ Delete local models entirely (rejected: local LLMs are vital for privacy/offline fallbacks).
- ❌ Keep separate folders (rejected: creates "Intelligence Drift").

### Impact
- ✅ Single source of truth for LLM infrastructure.
- ✅ Root `projects/` directory is now clean of redundant shells.
- ✅ Clearer distinction between "Cloud Primary" and "Local Fallback" workflows.

### Related Files
- `projects/Infrastructure/Evolution_LLM`
- `PROJECTS_INDEX.md`
- `FINAL_STRUCTURE.md`

---

**When to add to this log:**
- Architectural changes
- Technology choices (why X over Y)
- Process changes
- Strategic pivots
- Anything you might ask "why did we do it this way?" in 3 months

**Remember: Context is king. Document the WHY, not just the WHAT.**

---

## 2026-03-13: Review Bundle Standard For Reel Generator

### Decision
Treat generated image batches as incomplete until they also produce a review bundle: a contact sheet image plus a CSV curation manifest.

### Context
The Google-first Vertex path is now working for `projects/reel-generator`, and image quality is strong enough to move into repeatable asset-library building. At that point the main bottleneck stops being provider auth and becomes curation: quickly reviewing many outputs, picking keepers, and preserving prompt/model metadata for downstream reel assembly.

### Decision Details
**Implementation:**
- Keep generation on Google Vertex AI via ADC as the canonical path.
- Add a desktop-friendly review helper at `projects/reel-generator/scripts/build_review_bundle.ps1`.
- For each completed label, export:
  - `<label>_contact_sheet.png`
  - `<label>_review_manifest.csv`
- Use the review manifest to capture keep/reject choices, ratings, and notes before motion work begins.

**Rejected Alternatives:**
- Reject: Treat the raw image folder as the only review surface. This slows selection and drops metadata context.
- Reject: Block on the existing Python contact-sheet helper only. The current desktop thread cannot reliably execute `wsl.exe`, so a validated fallback is needed right now.

### Impact
- Faster human review of successful Gemini batches
- Better continuity from prompt generation into motion assembly
- Cleaner handoff from experimentation to approved asset-library curation

### Related Files
- `projects/reel-generator/scripts/build_review_bundle.ps1`
- `projects/reel-generator/README.md`

---

## 2026-03-13: Targeted Backfill Over Broad Batch Expansion

### Decision
Once a first image library pass is successful, the next prompt batch should be gap-driven rather than exploratory.

### Context
`adhoc` and `library-v1` now prove the Google Vertex path works and the output quality is high enough to use. At this stage, generating more random variants would spend quota without improving the structure of the reel asset library. What is needed next is intentional coverage of missing roles: tighter details, cleaner middle layers, more pan-ready backgrounds, and vertical-safe reel crops.

### Decision Details
**Implementation:**
- Add `projects/reel-generator/prompts/library_v2_backfill_batch.json`.
- Use it as the next run only after reviewing the current keepers.
- Keep the prompt set focused on visible library gaps rather than generic aesthetic variation.

**Rejected Alternatives:**
- Reject: Run another large exploratory batch immediately.
- Reject: Change providers now that Google is working. Provider work is no longer the bottleneck.

### Impact
- Better quota efficiency
- Stronger reel-ready library coverage
- Cleaner progression from testing to production asset packs

### Related Files
- `projects/reel-generator/prompts/library_v2_backfill_batch.json`
- `projects/reel-generator/assets/adhoc/adhoc_review_manifest.csv`
- `projects/reel-generator/assets/library-v1/library-v1_review_manifest.csv`

---

## 2026-03-13: Remove The Obsolete Gemini Proxy From SSOT Build

### Decision
Remove the legacy Gemini Developer API proxy from `SSOT_Build` because it is no longer used by the app and conflicts with the workspace Google-first cleanup direction.

### Context
The current `SSOT_Build` UI still uses local Vite middleware for profile enrichment, but the active client flow only falls back across GLM, Groq, and Anthropic. The old `/__gemini_profile` middleware remained in `vite.config.ts` as dead compatibility code and still depended on `GEMINI_API_KEY` plus the direct Developer API endpoint. That made `SSOT_Build` the clearest remaining workspace holdout for the pre-Vertex Google route.

### Decision Details
**Implementation:**
- Delete `/__gemini_profile` from `projects/SSOT_Build/vite.config.ts`.
- Remove the stale middleware reference from `projects/SSOT_Build/docs/architecture/CURRENT_BUILD_MAP_2026-03-11.md`.
- Keep only the local middleware routes that are still active in the current UI flow.

**Rejected Alternatives:**
- Reject: Leave the dead route in place “just in case.” This keeps auth drift alive without serving a real user path.
- Reject: Replace it with a new Vertex proxy right now. The next migration step is repository extraction and Firestore writes, not another ad hoc profile-generation route.

### Impact
- One fewer raw-key Google path in the active workspace
- Cleaner alignment with archive-first cleanup
- Less confusion about which AI routes still matter in `SSOT_Build`

### Related Files
- `projects/SSOT_Build/vite.config.ts`
- `projects/SSOT_Build/docs/architecture/CURRENT_BUILD_MAP_2026-03-11.md`

---

## 2026-03-13: Horse Identity Truth Must Be Distinct From HLT Associations

### Decision
Model horse identity truth separately from the horse's current trainer, owner, and governing-body links.

### Context
The modular SSOT and Firestore write-map docs were already locking in the correct high-level rule: horse + trainer/stable + owner + governing body + lease terms = HLT. The remaining nuance was where to place the linked trainer/owner/governing references. Those associations matter for HLT readiness, but they are not the horse's intrinsic identity in the same way the microchip and Stud Book evidence are.

### Decision Details
**Implementation:**
- Treat Stud Book / Loveracing evidence plus `microchip_number` as horse identity truth.
- Allow the horse module to expose current/default trainer, owner, and governing-body links for HLT readiness.
- Do not treat those links as intrinsic horse identity fields.
- Make repository extraction expose explicit qualification paths:
  - horse identity qualification
  - current association readiness
  - lease qualification
  - HLT precondition satisfaction

**Rejected Alternatives:**
- Reject: Treat trainer, owner, and governing-body links as permanent horse identity fields.
- Reject: Force HLT to depend on every minor field inside a module instead of module-level qualification.

### Impact
- Cleaner long-term model for reassignment and future schema evolution
- Better separation between factual horse identity and current commercial/regulatory context
- Safer repository extraction because HLT preconditions can be enforced explicitly instead of through mixed UI state

### Related Files
- `projects/SSOT_Build/docs/contracts/CURRENT_DATA_CONTRACT_2026-03-13.md`
- `projects/SSOT_Build/docs/contracts/FIRESTORE_WRITE_MAP_2026-03-13.md`
- `projects/SSOT_Build/README.md`

---

## 2026-03-16: Workspace GitHub Mirror Is A Curated Analysis Export, Not A Raw Filesystem Mirror

### Decision
Use a dedicated Git analysis mirror for the workspace, built from a clean export of the active text-first build surface rather than from direct commits in the live workspace root.

### Context
- The canonical workspace root is not a single clean git tree; several active projects under `projects/` and `gateways/openclaw/workspace` already carry their own embedded git repositories.
- A naive root-level `git add .` would create embedded-repository gitlinks, which would not give cloud-based tools the actual source content inside those projects.
- The full workspace is about `60G`, with `_archive/` alone accounting for roughly `57G`, so a raw mirror would be slow, noisy, and unsafe to publish.
- The immediate need is a GitHub surface that lets cloud-based AI tools inspect the active system without dragging along historical archives, dependency installs, generated assets, or secret-bearing local files.

### Decision Details
- Keep the GitHub mirror focused on the active workspace surface:
  - governance docs under `DNA/`
  - active docs under `_docs/`
  - active scripts under `_scripts/`
  - active project source trees under `projects/`
  - active gateway source under `gateways/`
- Drive the mirror through a separate cached clone plus clean export, not through normal commits from `/home/evo/workspace`.
- Exclude from the root snapshot:
  - `_archive/`, `_logs/`, `_locks/`, `_sandbox/`, and `models/`
  - `gateways/openclaw/sandbox/`
  - dependency installs and build output such as `node_modules/`, `.next/`, and `dist/`
  - local env files, machine-local state, and credential-shaped files
  - heavyweight generated media and review outputs that are not needed for code/system analysis
- Build mirror pushes from a clean export that strips embedded `.git` directories so nested repos contribute real files to the snapshot instead of gitlinks.

### Impact
- Cloud-based AI tools can inspect the actual active workspace code and docs from one GitHub repo.
- Mirror pushes stay GitHub-safe and readable instead of ballooning around archives and generated artifacts.
- The embedded repos can keep their own histories without blocking a workspace-level analysis mirror.

### Related Files
- `/home/evo/workspace/_scripts/sync-analysis-mirror-git.sh`
- `/home/evo/workspace/DNA/ops/TRANSITION.md`

---

## 2026-03-13: Stage-One Firestore Horse Surface Is `horses/{microchip_number}`

### Decision
Use `horses/{microchip_number}` as the first Firestore write surface and keep that stage limited to horse identity truth only.

### Context
After separating horse identity truth from current HLT associations, the next practical question was what the very first Firestore document actually needs to contain. The best minimal stage is a verified horse identity record derived from Loveracing / Stud Book evidence, keyed by the microchip, without prematurely mixing in trainer, owner, governing-body, lease, or media concerns.

### Decision Details
**Implementation:**
- First collection/document shape: `horses/{microchip_number}`
- Stage-one source links:
  - `pedigree_url`
  - `horse_performance_url`
- Stage-one core fields include:
  - microchip
  - Stud Book record ID
  - horse name
  - core factual horse metadata
  - verification/source timestamps
- Current associations are deferred from the first horse registration pass unless explicitly managed.
- Media and asset blobs remain out of the horse document.

**Rejected Alternatives:**
- Reject: Start with `horses/{horse_id}` as the primary identifier. The microchip is the more durable real-world anchor.
- Reject: Duplicate the same source URLs in multiple fields just for provenance.
- Reject: Include media/assets in the initial Firestore horse document.

### Impact
- Cleaner first Firestore milestone
- Less migration risk from the local prototype into structured cloud data
- A durable identity anchor that matches the horse SSOT model

### Related Files
- `projects/SSOT_Build/docs/contracts/CURRENT_DATA_CONTRACT_2026-03-13.md`
- `projects/SSOT_Build/docs/contracts/FIRESTORE_WRITE_MAP_2026-03-13.md`
- `projects/SSOT_Build/README.md`
