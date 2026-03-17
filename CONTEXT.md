# Evolution Workspace Context

> Fetch this file to orient yourself before any session.
> `https://raw.githubusercontent.com/Badders80/workspace/main/CONTEXT.md`

---

## What is Evolution Stables

Evolution Stables is a New Zealand thoroughbred horse racing investment platform. It allows investors to lease fractional ownership of racehorses via tokenised leases. The platform spans a public website (Evolution-3.1), a Mission Control internal app (SSOT), and supporting infrastructure for content, investor updates, and on-chain lease management.

---

## Canonical Workspace

All active work lives at `/home/evo/workspace/` (WSL2 Ubuntu, user `evo`).

- `/home/evo/` is control plane only — dotfiles, auth, global tool config.
- `/home/evo/workspace/` is the canonical build surface. Nothing else is authoritative.

---

## Three Active Repos

| Repo | Local Path | Purpose |
|------|-----------|---------|
| `Badders80/workspace` | `/home/evo/workspace/` | Agent orientation, DNA, governance docs, scripts |
| `Badders80/SSOT` | `/home/evo/workspace/projects/SSOT_Build/` | Mission Control — React/Vite internal app |
| `Badders80/Evolution-3.1` | `/home/evo/workspace/projects/Evolution_Platform/` | Evolution Stables public website |

---

## Key File Locations

| File | Purpose |
|------|---------|
| `/home/evo/workspace/AGENTS.md` | Workspace-level agent rules |
| `/home/evo/workspace/AI_SESSION_BOOTSTRAP.md` | Session orientation and live map |
| `/home/evo/workspace/DNA/` | Brand identity, ops conventions, decision log |
| `/home/evo/workspace/DNA/AGENTS.md` | DNA-specific rules |
| `/home/evo/workspace/DNA/agents/AI_CONTEXT.md` | Quick-loader for any AI assistant |
| `/home/evo/workspace/DNA/ops/CONVENTIONS.md` | Naming, env, archive conventions |
| `/home/evo/workspace/DNA/ops/STACK.md` | Live adopted and active tool registry |
| `/home/evo/workspace/DNA/ops/TRANSITION.md` | Append-only structural handoff log |
| `/home/evo/workspace/DNA/ops/DECISION_LOG.md` | Architectural decision record |
| `/home/evo/workspace/_scripts/` | Operational scripts (gate check, context, sync) |
| `/home/evo/.env` | Secrets — single source of truth, never committed |

---

## Port Map

| Port | Service |
|------|---------|
| 13000 | Mission Control UI (SSOT) |
| 18000 | Mission Control API |
| 18789 | OpenClaw agent runtime |

---

## Agent Entry Chain

Read in this order before answering questions about project state:

```
CONTEXT.md                              ← start here (this file)
  └── AI_SESSION_BOOTSTRAP.md           ← session orientation, current focus
        └── AGENTS.md                   ← workspace rules and guardrails
              └── DNA/AGENTS.md         ← DNA-specific rules
                    └── DNA/agents/AI_CONTEXT.md  ← quick loader
                          └── DNA/ops/CONVENTIONS.md
                                └── DNA/ops/STACK.md
                                      └── DNA/ops/TRANSITION.md
                                            └── DNA/INBOX.md
                                                  └── DNA/ops/DECISION_LOG.md
```

Consult `DNA/ops/TECH_RADAR.md` on demand when evaluating tools or checking prior research.

---

## Guardrails

- No build starts until `just check` is GREEN.
- One `.env` at `/home/evo/.env` — never committed anywhere.
- `projects/` dirs are separate git repos — not committed to this repo.
- `gateways/openclaw/` is OpenClaw's dedicated surface — do not modify outside it without approval.
- Treat `/home/evo/workspace` as canonical; never treat `/home/evo/` as source of truth for code or docs.
