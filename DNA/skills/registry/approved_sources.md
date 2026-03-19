# ✅ Approved Sources - Curated Tools & References

> **⚠️ THIS IS THE SINGLE SOURCE OF TRUTH**
> 
> All GitHub repo references across DNA point here. Update this file when evaluating new tools.
> 
> **Starred repos:** https://github.com/Badders80?tab=stars

**Principle:** Before building anything, check here first.  
**Rule:** Adapt > Integrate > Build from scratch

---

## ⭐ Starred Repo Review Workflow

When operator says: `I've added this new repo to my starred list in GitHub, please review`

Treat this as a **review request**, not an install instruction.

### 1) Inputs
- GitHub URL or `owner/repo`
- Review focus (security, architecture, readiness, etc.)
- Depth (`quick scan` or `deep review`)

### 2) Analysis
- Read README and examples: purpose, scope, maturity
- Inspect project structure: source layout, tests, config, CI
- Check maintenance signals: commit recency, open issues, release cadence, license
- Compare against this approved-sources list:
  - Does it duplicate an already approved tool?
  - Does it violate build or safety constraints?
- Check `TECH_RADAR.md` before repeating an evaluation

### 3) Output
- Findings ordered by severity (critical -> minor)
- File/area pointers for where concerns were found
- Recommendation aligned to radar statuses:
  - `Reject`, `Assess`, `Trial`, or `Adopt`
- If useful, add/update this file with category + rationale + date

### 4) Default Rule
- Do not adopt directly from a star.
- New stars enter `Assess` first unless already equivalent to an adopted tool.

### 5) Star Registry
- Current active surface: `skills/registry/starred_repo_registry.md`
- The old sync script and JSON registry were retired from the live workspace
  surface during cleanup because they no longer existed as real files.
- If star sync is reintroduced later, document the script path and all output
  files here before treating it as active automation again.

---

## 🎯 Current Lean-In Set (Build Direction)

These are the strongest repos to lean on first for your current stack.

| Repository | Direction | Why |
|------------|-----------|-----|
| [snarktank/antfarm](https://github.com/snarktank/antfarm) | Lean for multi-agent orchestration | Best fit for repeatable OpenClaw-centered build workflows |
| [gsd-build/get-shit-done](https://github.com/gsd-build/get-shit-done) | Lean for scoped execution | Strong discuss -> plan -> execute structure for long coding tasks |
| [openclaw/openclaw](https://github.com/openclaw/openclaw) | Keep as core runtime | Foundation layer already aligned with agent-heavy workflow |
| [VoltAgent/awesome-agent-skills](https://github.com/VoltAgent/awesome-agent-skills) | Lean for skill reuse | Reduces custom skill reinvention |
| [sickn33/antigravity-awesome-skills](https://github.com/sickn33/antigravity-awesome-skills) | Lean for battle-tested skill patterns | Large practical skill corpus for rapid execution |
| [czlonkowski/n8n-mcp](https://github.com/czlonkowski/n8n-mcp) + [czlonkowski/n8n-skills](https://github.com/czlonkowski/n8n-skills) | Lean for automation bridge | Strongest direct path from AI workflow design to n8n execution |
| [tobi/qmd](https://github.com/tobi/qmd) | Lean for local knowledge retrieval | Good fit for local-first DNA search and context lookup |
| [unslothai/unsloth](https://github.com/unslothai/unsloth) | Lean for local model tuning | Best fit for constrained VRAM model iteration |

---

## 🎯 How to Use This File

1. **Before starting a new feature:** Search this file for related solutions
2. **If you find a match:** Evaluate → Adapt → Document why you chose it
3. **If no match exists:** Build it, then add your solution here for future use
4. **Found a new gem?** Add it with context about what it's good for

---

## 🤖 AI / LLM Skills & Patterns

### Official Resources
| Repository | What it does | When to use |
|------------|--------------|-------------|
| [google-gemini/gemini-skills](https://github.com/google-gemini/gemini-skills) | Google's official skill patterns for Gemini | Building AI agents, prompt patterns |
| [VoltAgent/awesome-agent-skills](https://github.com/VoltAgent/awesome-agent-skills) | Community-curated agent skills | Looking for proven agent patterns |

### Pattern Libraries
| Repository | What it does | When to use |
|------------|--------------|-------------|
| [simonw/llm](https://github.com/simonw/llm) | CLI tool for LLM interactions | Command-line LLM tooling |
| [langchain-ai/langchain](https://github.com/langchain-ai/langchain) | LLM orchestration framework | Complex multi-step AI workflows |
| [microsoft/promptflow](https://github.com/microsoft/promptflow) | Visual workflow for LLM apps | Visual prompt engineering |

### Agent Orchestration & Multi-Agent Systems
| Repository | What it does | When to use |
|------------|--------------|-------------|
| [snarktank/antfarm](https://github.com/snarktank/antfarm) | Agent team builder for OpenClaw | Building multi-agent teams quickly |
| [rowboatlabs/rowboat](https://github.com/rowboatlabs/rowboat) | Open source AI coworker with persistent memory | Long-running agent sessions, memory |
| [VoltAgent/awesome-claude-code-subagents](https://github.com/VoltAgent/awesome-claude-code-subagents) | 100+ specialized subagents | Before building custom agents |
| [qualifire-dev/rogue](https://github.com/qualifire-dev/rogue) | AI red team / adversarial testing | Testing agent behavior before ship |
| [affaan-m/everything-claude-code](https://github.com/affaan-m/everything-claude-code) | Complete Claude Code configs | Setting up Claude agent properly |
| [sickn33/antigravity-awesome-skills](https://github.com/sickn33/antigravity-awesome-skills) | 900+ battle-tested skills | Before building any skill from scratch |
| [czlonkowski/n8n-skills](https://github.com/czlonkowski/n8n-skills) | n8n workflows for Claude Code | n8n workflow automation |
| [Zie619/n8n-workflows](https://github.com/Zie619/n8n-workflows) | 4,343+ searchable n8n workflows + AI-BOM security scanner | Finding n8n workflow templates, security auditing |

---

## ⚡ Productivity & Development Philosophy

### Get Shit Done
| Repository | What it does | When to use |
|------------|--------------|-------------|
| [gsd-build/get-shit-done](https://github.com/gsd-build/get-shit-done) | Focus-driven productivity system | You need to ship fast |
| [obra/superpowers](https://github.com/obra/superpowers) | Curated developer superpowers | Leveling up your tooling |

### Build Philosophy
| Resource | What it teaches | When to reference |
|----------|-----------------|-------------------|
| [The 12-Factor App](https://12factor.net/) | Best practices for SaaS | Building scalable services |
| [Basecamp's Shape Up](https://basecamp.com/shapeup) | Product development methodology | Planning product cycles |

---

## 🛠️ Tools We Actually Use

### Already in Evo Stack
| Tool | Purpose | Why we chose it |
|------|---------|-----------------|
| [FZF](https://github.com/junegunn/fzf) | Fuzzy finder | Fast, works everywhere, zero config |
| [Zoxide](https://github.com/ajeetdsouza/zoxide) | Smart cd | Learns from history, "just works" |
| [Just](https://github.com/casey/just) | Task runner | Better than Make, simple syntax |
| [Starship](https://github.com/starship/starship) | Prompt | Fast, informative, customizable |
| [Obsidian](https://obsidian.md/) | Knowledge base | Local-first, markdown, graph view |

### Under Evaluation
| Tool | Purpose | Evaluation criteria |
|------|---------|---------------------|
| [n8n](https://n8n.io/) | Workflow automation | Currently using - evaluate alternatives |
| [Firecrawl](https://github.com/mendableai/firecrawl) | Web scraping | Currently using - watch for v2 |

---

## 🏗️ Architecture & Design Patterns

### Monorepo vs Multi-repo
| Resource | Position | When to reference |
|----------|----------|-------------------|
| [Why Google Stores Billions of Lines in a Single Repo](https://research.google/pubs/pub45462/) | Pro-monorepo | Considering monorepo architecture |
| [How to Structure a Repository](https://medium.com/@jonathanmundell/how-to-structure-a-repository-1b65f40f1e5c) | Balanced view | Repository organization decisions |

### Domain-Driven Design
| Resource | What it teaches | When to reference |
|----------|-----------------|-------------------|
| [Domain-Driven Design Reference](https://domainlanguage.com/ddd/reference/) | DDD patterns | Complex domain modeling |
| [Modular Monolith](https://www.youtube.com/watch?v=5OjqD-ow8GE) | Pragmatic architecture | Scaling without microservices |

---

## 🔐 Security & Best Practices

### Secrets Management
| Resource | What it covers | When to reference |
|----------|----------------|-------------------|
| [GitHub's Token Scanning](https://docs.github.com/en/code-security/secret-scanning) | Preventing secret leaks | Setting up repos |
| [Mozilla's Web Security Guidelines](https://infosec.mozilla.org/guidelines/web_security) | Web security basics | Building web apps |

### AI Safety
| Resource | What it covers | When to reference |
|----------|----------------|-------------------|
| [OWASP LLM Top 10](https://owasp.org/www-project-top-10-for-large-language-model-applications/) | LLM security risks | Building AI features |

---

## 🎨 Frontend & UI

### Component Libraries
| Repository | What it provides | When to use |
|------------|------------------|-------------|
| [shadcn/ui](https://github.com/shadcn-ui/ui) | Copy-paste React components | Need polished UI fast |
| [Radix UI](https://www.radix-ui.com/) | Headless UI primitives | Building custom components |
| [Tailwind UI](https://tailwindui.com/) | Official Tailwind components | Prototype to production |

### Styling
| Resource | What it teaches | When to reference |
|----------|-----------------|-------------------|
| [Every Layout](https://every-layout.dev/) | CSS layout patterns | Responsive design |
| [Refactoring UI](https://refactoringui.com/) | Design for developers | Making things look good |

---

## 📊 Data & Storage

### Databases
| Tool | Best for | When to choose |
|------|----------|----------------|
| [Supabase](https://supabase.com/) | Postgres + Auth + Realtime | Full-stack apps |
| [PostgreSQL](https://www.postgresql.org/) | Reliable relational data | When you need SQL |
| [SQLite](https://www.sqlite.org/) | Simple, file-based | Local-first, embedded |

### Vector DBs (for AI)
| Tool | Best for | When to choose |
|------|----------|----------------|
| [Chroma](https://www.trychroma.com/) | Local embeddings | Private AI, prototyping |
| [Pinecone](https://www.pinecone.io/) | Managed vector search | Production at scale |
| [pgvector](https://github.com/pgvector/pgvector) | Postgres extension | Already using Postgres |

---

## 🚀 Deployment & Infrastructure

### Containerization
| Tool | What it does | When to use |
|------|--------------|-------------|
| [Docker](https://www.docker.com/) | Containerization | Isolating dependencies |
| [Docker Compose](https://docs.docker.com/compose/) | Multi-container apps | Local development |

### Cloud
| Provider | Best for | When to choose |
|----------|----------|----------------|
| [Vercel](https://vercel.com/) | Next.js, frontend | React/Next.js hosting |
| [Railway](https://railway.app/) | Full-stack, databases | Quick deployment |
| [Fly.io](https://fly.io/) | Docker containers | Container-based apps |

---

## 📚 Learning Resources

### When You're Stuck
| Resource | What it provides | When to use |
|----------|------------------|-------------|
| [MDN Web Docs](https://developer.mozilla.org/) | Web platform docs | HTML/CSS/JS reference |
| [DevDocs.io](https://devdocs.io/) | Aggregated docs | Offline documentation |

### Keeping Current
| Newsletter/Podcast | Focus | Why subscribe |
|-------------------|-------|---------------|
| [Console.dev](https://console.dev/) | Developer tools | Curated tool discovery |
| [TLDR Newsletter](https://tldr.tech/) | Tech news | Stay current quickly |

---

## ❌ Anti-Patterns (What to Avoid)

### Over-Engineering
- ❌ Kubernetes for < 10 services
- ❌ Microservices when you don't need scale
- ❌ Building your own auth instead of using Clerk/Auth0
- ❌ Custom CSS framework when Tailwind exists

### Premature Optimization
- ❌ Caching before measuring performance
- ❌ Database sharding before hitting limits
- ❌ Multi-region deployment before product-market fit

---

## 📝 Adding to This List

When you find a new tool/pattern:

```markdown
### [Repository Name](URL)
**What:** One-line description
**Use when:** Specific use case
**Why approved:** Personal experience or trusted source
**Added:** YYYY-MM-DD
```

**Criteria for approval:**
1. Solves a real problem you've encountered
2. Better than alternatives you've tried
3. Actively maintained
4. Simple to understand and use

---

**Remember:** This list is living documentation. Update it when you find better tools or your needs change. The goal is **fast, informed decisions** - not analysis paralysis.

---

*Last updated: 2026-02-27*  
*Starred repos reference: https://github.com/Badders80?tab=stars*
