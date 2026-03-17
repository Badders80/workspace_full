# STACK.md — Live Tool Registry

> Canonical registry of tools at Adopt/Active status.
> Agent rule: do not suggest alternatives to tools listed here. Do not
> introduce new tools without updating this file and DECISION_LOG.md.
>
> Evaluation queue -> DNA/ops/TECH_RADAR.md (consult on demand, not auto-loaded)
> Decision rationale -> DNA/ops/DECISION_LOG.md

Last updated: 2026-03-16

---

## AI Orchestration

### Orchestrator Tier (plan, spec, review, approve)
| Tool | Role |
|------|------|
| Claude Code | Primary orchestrator — planning, spec, review |
| Codex CLI | Execution-phase agent — batch prompts |
| Jules | GitHub PR execution (Google AI) |

### Worker Tier (grunt execution — interchangeable by cost/task)
Orchestrators plan and review. Workers execute. Never pay premium rates for grunt work.

| Tool | Notes |
|------|-------|
| Groq | Fast free-tier — llama/mixtral models |
| OpenRouter | Free-tier multi-model routing |
| Kilo | Low-cost execution |
| Gemini API | Google-stack tasks, free tier |

This pattern is not Claude-locked. Any capable orchestrator can run it.

---

## Gateway

| Tool | Port | Notes |
|------|------|-------|
| OpenClaw | 18789 | Island architecture at gateways/openclaw/. Reads workspace context, no write authority outside its own directory. |

---

## Automation

| Tool | Status | Notes |
|------|--------|-------|
| n8n | Active | Self-hosted Docker. Workflow orchestration. Do not suggest Zapier, Make, Pipedream. |

---

## Frontend

| Tool | Status | Notes |
|------|--------|-------|
| shadcn/ui | Adopted | All UI built on this. Do not suggest MUI, Chakra, Mantine, raw Radix. |
| Tailwind CSS | Adopted | Ships with shadcn. |
| Playwright | Adopted | Browser automation + testing. |

---

## Backend / Data

| Tool | Status | Notes |
|------|--------|-------|
| Firestore | Active — primary cloud DB | evolution-engine project, australia-southeast1, Native mode. |
| Google Vertex AI | Active | ADC via evolution-engine. Default Google execution path. Raw API key path for diagnostics only. |
| Supabase | Transitioning out | Being superseded by Firestore. Do not build new integrations against it. |

---

## Google Stack Preference (Soft — Non-Binding)
Where capability is equivalent, prefer Google services (Vertex, Gemini, Jules, Workspace).
This is a preference, not a lock. Locked tools above always take precedence.

---

## Context & Memory

| Tool | Notes |
|------|-------|
| DNA file chain | Model-agnostic memory. Any AI reads DNA first. See DECISION_LOG 2026-02-27. |

---

## Dev Tooling

| Tool | Status |
|------|--------|
| just | Adopted — task runner. `just check` = gate before any build. |
| FZF + Zoxide + Starship | Adopted — terminal productivity stack. |
| WSL2 Ubuntu (user: evo) | Primary dev environment. |
| GitHub (Badders80) | Single source of truth for all repos. |

---

## Secrets

- One `.env` at `/home/evo/.env` — never committed, never duplicated per-project.
- All services source from here.

---

## Port Map

| Port | Service |
|------|---------|
| 13000 | Mission Control UI (SSOT) |
| 18000 | Mission Control API |
| 18789 | OpenClaw gateway |

---

## Evaluating (check TECH_RADAR.md for full status)
These are on the radar but not yet adopted. Consult TECH_RADAR.md for evaluation notes.

- OpenClaw core runtime — Assess
- 21st.dev — Assess
- Magic MCP (21st-dev) — Assess
- 1code (21st-dev) — Assess
- Gemini Embedding 2 — Assess (pending vector-store boundary decision)
- claude-mem — Assess
- SuperClaude Framework — Assess
- PocketBase — Assess (potential v2 backend)
