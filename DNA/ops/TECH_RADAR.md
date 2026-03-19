# EVO TECH RADAR

> Personal research index. Consult on demand - not auto-loaded by agents.
> Agent rule: check STACK.md first for locked/adopted tools. Use this file
> when asked "have we looked at X?" or "find something that could solve Y."
>
> Raw intake dumps -> DNA/ops/tech-radar-intake/YYYY-MM-DD_batch.md
> Workflow: save link -> intake dump -> processor -> Codex prompt -> git commit

_Last updated: 2026-03-19_

---

## Index

| Tool | Category | Status | Notes |
|------|----------|--------|-------|
| Claude Code | AI Coding | ADOPT | Primary orchestrator. See STACK.md |
| Obsidian + DNA | Knowledge Mgmt | ADOPT | Local-first markdown vault. Next step: harden the boundary between Obsidian knowledge sync and governed workspace paths so knowledge stays useful without reintroducing root-level drift. |
| FZF + Zoxide + Just + Starship | Terminal | ADOPT | Lightweight productivity stack |
| OpenClaw Mission Control Template | Agent Dashboard | ADOPT | Default dashboard bootstrap |
| Priority Trial Shortlist | OpenClaw Upgrades | TRIAL | Top 4 current recommendations: AlphaClaw -> skills.sh + claude-mem -> NVIDIA Nemotron 3 Super. Run one branch at a time inside `gateways/openclaw/` after the post-nuke reboot validation. |
| n8n AI Workflows | Automation | TRIAL | Docker running, testing Claude workflow integration |
| NotebookLM for Prompt Creation | Prompt Eng | TRIAL | Testing vs current prompt method |
| tasks/lessons.md Rulebook | Agent Memory | TRIAL | Correction logging -> permanent rules read at session start. Prevents repeat mistakes. |
| Paperclip AI Agent Framework | Multi-Agent Orchestration | ASSESS | Open-source agent teams with roles, budgets, and goals. Interesting, but heavier and less urgent than the current OpenClaw ops and memory trials. |
| Lossless Claw | Memory / OpenClaw Plugin | TRIAL | Local DB lossless message storage + condensation. 25:1 ratio, exact recall. Never forget. |
| Claude Three-Tier Memory Hierarchy | Claude Config / Memory | TRIAL | Global/project/auto tiers + modular rules/skills/agents. Token-aware, gitignored auto. |
| Claude Code Hooks | AI Orchestration / Session Safety | TRIAL | Event-driven Claude Code hooks for deletion guards, alerts, and optional research automation. |
| Free Claude Cowork Skills | Agent Skills | TRIAL | Large free Claude skill library; test a small non-overlapping subset before adding it to worker flows. |
| OpenClaw Free Integration | Agent Runtime / Cost Control | TRIAL | Explore Ollama + low-cost or free model routing for `gateways/openclaw/` without widening workspace write scope. |
| AlphaClaw | Agent Management / OpenClaw | TRIAL | Browser dashboard, watchdog, and Git sync for the OpenClaw island. Disable Google Workspace or Drive paths during any trial. |
| OpenClaw + Scrapling | OpenClaw Plugin / Data Acquisition | TRIAL | Scrapling-backed scraping extension for OpenClaw research tasks. Keep the trial bounded to legitimate island-based research work. |
| Magic Animator | Design / Animation | TRIAL | AI animation export flow for Figma or Canva assets; useful for fast UI or marketing motion prototypes. |
| skills.sh | Agent Modularity | TRIAL | Installable procedural skills ecosystem. Promote from research to limited hands-on trial. |
| claude-mem | Memory | TRIAL | Persistent Claude memory plugin with local storage and viewer; compare against the DNA + lessons flow. |
| AionUi | Agent UI / Desktop | ARCHIVE | Local 24/7 cowork UI for multiple CLIs. Now overlaps too closely with AlphaClaw; steal only the unattended scheduling idea. |
| SuperClaude Framework | Claude Enhancer | ARCHIVE | Large slash-command and persona layer. Covered well enough by Claude Code Hooks plus DNA; steal only the best commands and MCP setup ideas. |
| promptfoo | LLM Evaluation & Red Teaming | TRIAL | Open-source CLI for prompt/model/RAG evals, assertions, side-by-side comparison, CI integration, and automated red-teaming. |
| gists.sh | GitHub Gist Viewer | TRIAL | URL swap that prettifies GitHub Gists with better typography, tabs, and markdown rendering. Zero install. |
| Pi (pi.dev) | Terminal Coding Agent | TRIAL | Minimal TUI coding harness with multi-model support, markdown context loading, and extension hooks. |
| OpenCode | Open-Source AI Coding Agent | TRIAL | Reopened as a bounded trial for low-cost execution loops, subagents, and broad provider support. Treat as worker-path research, not stack adoption. |
| Nano Banana 2 Prompt Libraries | Prompt Engineering / Image Gen | ASSESS | Curated photoreal prompts + JSON/Python dev formats from GitHub/Google. Programmatic image gen potential. |
| BaudBot | Team Coding Agent | ASSESS | Self-hosted persistent coding agent with Slack UI and branch-to-PR automation. Interesting for future team scaling, not current solo fit. |
| OpenClaw Builds | AI Agents / Orchestration | ASSESS | Example OpenClaw build patterns worth scanning for future worker orchestration ideas. |
| NVIDIA Nemotron 3 Super | Local LLM / OpenClaw Brain | TRIAL | 120B total, 12B active open model with strong agentic fit. NVIDIA advertises up to 1M context, but the current Ollama listing shows 256K for the local path. |
| Claude Social Manager | AI Content / Marketing | ASSESS | Claude-driven social audit workflow. Useful only if marketing review becomes a real recurring task. |
| AI Design MCPs | Design / MCP | ASSESS | Design-focused MCP collection worth checking against current shadcn or Tailwind workflow needs. |
| Perplexity Design Gen | AI Design | ASSESS | Fast design-generator idea surface; keep parked behind the current Google-first preference. |
| OpenShell | Agent Security / Runtime | ASSESS | Reported NVIDIA sandbox runtime for safer agent execution. Promising, but wait for durable upstream docs or repo before any trial. |
| PicoClaw | Agent Runtime | ASSESS | Ultra-light local agent runtime with broad provider support; interesting for worker experiments but too early to challenge OpenClaw. |
| OpenClaw Core Runtime | Agent Runtime | ASSESS | Full runtime - advanced path only |
| 21st.dev | Design | ASSESS | npm for design engineers, largest shadcn/ui marketplace |
| Magic MCP (21st-dev) | Dev Tooling | ASSESS | MCP server for AI-powered frontend dev |
| 1code (21st-dev) | Orchestration | ASSESS | Orchestration layer for Claude Code + Codex |
| Gemini Embedding 2 | Embeddings | ASSESS | Multimodal unified embedding - text/image/video/audio/docs |
| Google Workspace Studio | Automation | ASSESS | No-code Gemini agents in Workspace - overlaps with n8n |
| Google Antigravity | Agent IDE | ASSESS | Parallel agents + UI gen - overlaps with current stack |
| NotebookLM MCP Server | Memory | ASSESS | Plug-and-play agent memory - overlaps with DNA system |
| Handoff Documents ("Reheat" Workflow) | Session Memory | ARCHIVE | Already implemented via DNA chain / AI_SESSION_BOOTSTRAP.md. Steal: enforce explicit end-of-session update ritual. |
| Claude Skills (Markdown Workflows) | Session Memory / Config | ARCHIVE | Persistent markdown rules auto-applied. Duplicate of our global/project `CLAUDE.md` hierarchy. Steal: limit 5-10 non-overlapping items guideline. |
| Obsidian + Claude Second Brain | Knowledge Memory | ARCHIVE | External graph for Claude context. Covered by DNA chain + git. |
| Claude Code Hooks Guide | Educational | ARCHIVE | Social explainer for hooks. Keep the real hook implementation note, not the tutorial reel. |
| Chrome Dev Extensions | Dev Tooling | ARCHIVE | Browser-extension roundup. Low leverage versus the current Playwright-centered workflow. |
| Self-Hosted Dev Tools | Dev Tooling | ARCHIVE | Generic self-hosted tool list. Too vague and overlaps adopted GitHub/n8n setup. |
| Golden Ratio Colors | Design | ARCHIVE | Design tip, not a stack decision. |
| Magic Animator Demo | Educational | ARCHIVE | Duplicate demo surface. Refer to the main Magic Animator entry. |
| Codex for Claude | AI Orchestration | ARCHIVE | Output-polishing chain that duplicates the already adopted Claude Code + Codex pairing. |
| Claude Website Gen | UI | ARCHIVE | AI website-generation reel. Covered by shadcn/ui and the current frontend workflow. |
| Claude Code Setup | Educational | ARCHIVE | Setup guide for an already adopted tool. |
| Emergent | AI Building | ARCHIVE | Broad AI app-building surface with insufficient differentiation from the current orchestrator stack. |
| autoresearch | AI Orchestration / Session Safety | ARCHIVE | Overnight optimization loop idea already covered by the `Claude Code Hooks` trial. Steal only the metrics-driven prompt ritual. |
| Figr.design | Design | ARCHIVE | Product-aware AI design copilot with memory and Figma support, but low fit for the current core build stack. |
| Undescribed Instagram Reel | Unknown | ARCHIVE | No extractable content/tool. |
| AI Design Workflows (Claude/Perplexity) | Design Tools | ARCHIVE | UX ideation aids. Not core dev stack. |
| Godofprompt Agentic AI | Educational | ARCHIVE | Conceptual framework only |
| Wizofai Mindset Reset | Educational | ARCHIVE | Philosophical, not actionable |
| Claude Code Features Guide | Educational | ARCHIVE | Already adopted, tutorial only |

---

## Evaluation Criteria

Before moving to Trial or Adopt:
1. **Problem fit** - does it solve a real problem we have?
2. **Overlap** - does it duplicate existing tools?
3. **Complexity** - is the learning curve worth it?
4. **Lock-in** - can we migrate away if needed?
5. **Maintenance** - active project? Will it exist in 2 years?
6. **Philosophy** - does it align with our build rules?

---

## How to Add New Discoveries

1. Save raw notes to `DNA/ops/tech-radar-intake/YYYY-MM-DD_batch.md` or a single-tool intake file.
2. Feed the raw dump to the processor documented in `DNA/ops/GEM_TECH_RADAR_PROCESSOR.md`.
3. Apply the resulting Codex prompt to update the table and any related governance files.

Raw intake can be messy: transcript, README paste, rough notes, or just a URL plus one sentence.

---

## Review Schedule
- **Weekly** - scan Assess items, any ready for Trial?
- **Monthly** - review Trial items, promote or reject?
- **Quarterly** - review Adopt items, still best choice?

_Last updated: 2026-03-19 | Next review: 2026-03-26_

## Context Chain
<- inherits from: /home/evo/workspace/DNA/AGENTS.md
-> overrides by: none
-> live map: /home/evo/workspace/AI_SESSION_BOOTSTRAP.md
-> conventions: /home/evo/workspace/DNA/ops/CONVENTIONS.md
