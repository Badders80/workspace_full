# EVO TECH RADAR

> Personal research index. Consult on demand - not auto-loaded by agents.
> Agent rule: check STACK.md first for locked/adopted tools. Use this file
> when asked "have we looked at X?" or "find something that could solve Y."
>
> Raw intake dumps -> DNA/ops/tech-radar-intake/YYYY-MM-DD_batch.md
> Workflow: save link -> intake dump -> processor -> Codex prompt -> git commit

_Last updated: 2026-03-17_

---

## Index

| Tool | Category | Status | Notes |
|------|----------|--------|-------|
| Claude Code | AI Coding | ADOPT | Primary orchestrator. See STACK.md |
| Obsidian + DNA | Knowledge Mgmt | ADOPT | Local-first markdown vault |
| FZF + Zoxide + Just + Starship | Terminal | ADOPT | Lightweight productivity stack |
| OpenClaw Mission Control Template | Agent Dashboard | ADOPT | Default dashboard bootstrap |
| n8n AI Workflows | Automation | TRIAL | Docker running, testing Claude workflow integration |
| NotebookLM for Prompt Creation | Prompt Eng | TRIAL | Testing vs current prompt method |
| tasks/lessons.md Rulebook | Agent Memory | TRIAL | Correction logging -> permanent rules read at session start. Prevents repeat mistakes. |
| Paperclip AI Agent Framework | Multi-Agent Orchestration | TRIAL | Open-source agent teams with roles/budgets/goals. Autonomous run + human override. Budget safety. |
| Lossless Claw | Memory / OpenClaw Plugin | TRIAL | Local DB lossless message storage + condensation. 25:1 ratio, exact recall. Never forget. |
| Claude Three-Tier Memory Hierarchy | Claude Config / Memory | TRIAL | Global/project/auto tiers + modular rules/skills/agents. Token-aware, gitignored auto. |
| Claude Code Hooks | AI Orchestration / Session Safety | TRIAL | Event-driven Claude Code hooks for deletion guards, alerts, and optional research automation. |
| Free Claude Cowork Skills | Agent Skills | TRIAL | Large free Claude skill library; test a small non-overlapping subset before adding it to worker flows. |
| OpenClaw Free Integration | Agent Runtime / Cost Control | TRIAL | Explore Ollama + low-cost or free model routing for `gateways/openclaw/` without widening workspace write scope. |
| Magic Animator | Design / Animation | TRIAL | AI animation export flow for Figma or Canva assets; useful for fast UI or marketing motion prototypes. |
| skills.sh | Agent Modularity | TRIAL | Installable procedural skills ecosystem. Promote from research to limited hands-on trial. |
| claude-mem | Memory | TRIAL | Persistent Claude memory plugin with local storage and viewer; compare against the DNA + lessons flow. |
| AionUi | Multi-Agent | TRIAL | Local multi-CLI desktop layer; test whether it adds value over current terminal orchestration. |
| SuperClaude Framework | Agent Tooling | TRIAL | Structured commands, personas, and modes for Claude workflows; ready for a bounded trial. |
| Nano Banana 2 Prompt Libraries | Prompt Engineering / Image Gen | ASSESS | Curated photoreal prompts + JSON/Python dev formats from GitHub/Google. Programmatic image gen potential. |
| OpenClaw Builds | AI Agents / Orchestration | ASSESS | Example OpenClaw build patterns worth scanning for future worker orchestration ideas. |
| Nvidia Nemotron-3 Super | AI Models | ASSESS | Large open agent model with long context; evaluate only if benchmarks or low-cost access justify it. |
| Claude Social Manager | AI Content / Marketing | ASSESS | Claude-driven social audit workflow. Useful only if marketing review becomes a real recurring task. |
| AI Design MCPs | Design / MCP | ASSESS | Design-focused MCP collection worth checking against current shadcn or Tailwind workflow needs. |
| Perplexity Design Gen | AI Design | ASSESS | Fast design-generator idea surface; keep parked behind the current Google-first preference. |
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
| OpenCode | AI Coding | ARCHIVE | Open-source Claude Code alternative, but current stack policy blocks trialing orchestrator replacements without `STACK.md` + `DECISION_LOG.md` changes. |
| Claude Code Hooks Guide | Educational | ARCHIVE | Social explainer for hooks. Keep the real hook implementation note, not the tutorial reel. |
| Chrome Dev Extensions | Dev Tooling | ARCHIVE | Browser-extension roundup. Low leverage versus the current Playwright-centered workflow. |
| Self-Hosted Dev Tools | Dev Tooling | ARCHIVE | Generic self-hosted tool list. Too vague and overlaps adopted GitHub/n8n setup. |
| Golden Ratio Colors | Design | ARCHIVE | Design tip, not a stack decision. |
| Magic Animator Demo | Educational | ARCHIVE | Duplicate demo surface. Refer to the main Magic Animator entry. |
| Codex for Claude | AI Orchestration | ARCHIVE | Output-polishing chain that duplicates the already adopted Claude Code + Codex pairing. |
| Claude Website Gen | UI | ARCHIVE | AI website-generation reel. Covered by shadcn/ui and the current frontend workflow. |
| Claude Code Setup | Educational | ARCHIVE | Setup guide for an already adopted tool. |
| Emergent | AI Building | ARCHIVE | Broad AI app-building surface with insufficient differentiation from the current orchestrator stack. |
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

_Last updated: 2026-03-17 | Next review: 2026-03-24_

## Context Chain
<- inherits from: /home/evo/workspace/DNA/AGENTS.md
-> overrides by: none
-> live map: /home/evo/workspace/AI_SESSION_BOOTSTRAP.md
-> conventions: /home/evo/workspace/DNA/ops/CONVENTIONS.md
