# Evolution Tech Stack 2026

**Version:** 2026.1 | **Status:** Canonical
**Scope:** Active Software, Services, and Model Registry

---

## 1. Primary Runtimes
- **Python:** 3.12.3 (Venvs at `/home/evo/workspace/projects/[project]/venv`)
- **Node.js:** Latest LTS (Next.js 14 / TypeScript)
- **Database:** Supabase (PostgreSQL) for Expert Ledger and Flucs.

---

## 2. LLM Architecture
**Philosophy:** Local-First Intelligence with Cloud-Hybrid fallback.

### 2.1 Model Registry (Ollama)
| Model | Size | Use Case | Response |
| :--- | :--- | :--- | :--- |
| **liquid-ai-2.6b** | 2.7GB | Fast iteration, simple Q&A | < 2s |
| **evolution-designer** | 6.2GB | Creative content, branding | 2–5s |
| **evolution-coder** | 6.3GB | Code generation, docs | 2–5s |
| **qwen2.5-14b** | 8.6GB | Complex reasoning, strategy | 3–8s |

### 2.2 Model Selection Strategy
1. **Draft:** Start with `liquid-ai` for speed.
2. **Refine:** Use specialized `evolution-*` models for domain work.
3. **Finalize:** Use `qwen2.5-14b` for strategic review.

---

## 3. Automation & Content Factory
- **Orchestration:** n8n (Docker-based)
- **Image/Video Gen:** ComfyUI (FLUX.1-dev, LTX-Video, Wan 2.2)
- **Voice:** ElevenLabs API (Kore Voice, Eleven Turbo v2)
- **Assembly:** FFmpeg (NVENC/CPU hybrid)

---

## 4. Service Discovery (Ports)
| Service | Port | Status |
| :--- | :--- | :--- |
| **Ollama** | 11434 | Active |
| **n8n** | 5678 | Active |
| **ComfyUI** | 8189 | Active |
| **Supabase** | 5432 | Cloud |

---

## 5. Workflow Protocols
- **Scout Agent:** Groq (Llama 3.3 70B via API) for market anomaly detection.
- **Human Gate:** All content requires Telegram Bot approval before publishing.
- **Sunday Hygiene:** Automated VRAM flush, WSL compaction, and Expert Ledger backups.
