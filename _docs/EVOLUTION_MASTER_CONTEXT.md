# EVOLUTION_MASTER_CONTEXT.md

## Overview
This is the master context file for the Evolution Stables project. It contains information about the project's goals, architecture, and key files.

## Project Goals
- Create a unified platform for horse racing content generation
- Provide a modern, mobile-first user experience
- Integrate AI tools for content creation and curation
- Maintain a consistent brand voice across all content

## Architecture
The project is divided into several repos, each serving a specific purpose:

1. **00_DNA**: Source of truth for all development standards
2. **Evolution_3.1**: Main web application
3. **Evolution_Studio**: Content management system
4. **Evolution_Content_Builder**: AI content generation platform
5. **Evolution_Content_Factory**: Video generation pipeline
6. **Evolution_Research_Engine**: Research and scraping tool
7. **Brand_Voice**: Brand voice and messaging guidelines
8. **Local_LLM**: Local LLM integration
9. **evolution-email-builder**: Email marketing tool
10. **evolution-studio-mcp**: MCP server integration
11. **evolution-studios-engine**: Full stack platform
12. **firecrawl**: Web scraping tool
13. **n8n**: Workflow automation tool
14. **ComfyUI**: AI image generation
15. **Asset_Generation**: Asset generation tool
16. **04_Intelligence**: Local intelligence layer

## Core Bible Documents
- `/home/evo/00_DNA/brand-identity/Evolution_Content_Factory.md`: Content Factory brand guidelines
- `/home/evo/00_DNA/brand-identity/Branding.md`: Q7 layer institutional voice
- `/home/evo/00_DNA/build-philosophy/Evolution_OS.md`: Technical architecture & operations manual

## Key Files to Reference
### 00_DNA
- `/home/evo/00_DNA/AGENTS.core.md`: Universal agent rules
- `/home/evo/00_DNA/build-philosophy/Master_Config_2026.md`: Hardware and architecture specs
- `/home/evo/00_DNA/brand-identity/BRAND_VOICE.md`: Brand voice guidelines
- `/home/evo/00_DNA/brand-identity/MESSAGING_CHEAT_SHEET.md`: Messaging guidelines
- `/home/evo/00_DNA/system-prompts/PROMPT_LIBRARY.md`: System prompts for AI agents

### Evolution_3.1
- `/home/evo/projects/Evolution-3.1/CLAUDE.md`: Project-specific context
- `/home/evo/projects/Evolution-3.1/README.md`: Project documentation

### Evolution_Studio
- `/home/evo/projects/Evolution_Studio/CLAUDE.md`: Project-specific context
- `/home/evo/projects/Evolution_Studio/README.md`: Project documentation

### Evolution_Content_Builder
- `/home/evo/projects/Evolution-Content-Builder/CLAUDE.md`: Project-specific context
- `/home/evo/projects/Evolution-Content-Builder/README.md`: Project documentation

### Evolution_Content_Factory
- `/home/evo/projects/Evolution-Content-Factory/CLAUDE.md`: Project-specific context
- `/home/evo/projects/Evolution-Content-Factory/README.md`: Project documentation

### Evolution_Research_Engine
- `/home/evo/projects/Evolution-Research-Engine/CLAUDE.md`: Project-specific context
- `/home/evo/projects/Evolution-Research-Engine/README.md`: Project documentation

### Brand_Voice
- `/home/evo/projects/Brand_Voice/CLAUDE.md`: Project-specific context
- `/home/evo/projects/Brand_Voice/README.md`: Project documentation

### Local_LLM
- `/home/evo/projects/Local_LLM/CLAUDE.md`: Project-specific context
- `/home/evo/projects/Local_LLM/README.md`: Project documentation

### evolution-email-builder
- `/home/evo/projects/evolution-email-builder/CLAUDE.md`: Project-specific context
- `/home/evo/projects/evolution-email-builder/README.md`: Project documentation

### evolution-studios-engine
- `/home/evo/projects/evolution-studios-engine/CLAUDE.md`: Project-specific context
- `/home/evo/projects/evolution-studios-engine/README.md`: Project documentation

## Important Paths
- **Home Directory**: `/home/evo/`
- **Projects Folder**: `/home/evo/projects/`
- **00_DNA Folder**: `/home/evo/00_DNA/`
- **Models Folder**: `/home/evo/models/`

## Hardware Constraints
- **GPU**: RTX 3060 12GB (CUDA)
- **CPU**: AMD Ryzen 5 7600X (6 Cores / 12 Threads)
- **RAM**: 32GB DDR5 6000MT/s
- **Storage**: Samsung 990 PRO NVMe

## Environment Variables
All environment variables should be set in a `.env` file in the project root. For more information, see each project's README.

## Commands
### 00_DNA
- **Sync Agents**: `/home/evo/00_DNA/workflows/sync_agents.sh`

### Evolution_3.1
- **Dev Server**: `npm run dev` (port 3000)
- **Build**: `npm run build`
- **Start**: `npm run start`

### Evolution_Studio
- **Run Streamlit**: `streamlit run app.py` (port 8501)

### Evolution_Content_Builder
- **Run Backend**: `python app.py` (port 8000)
- **Run Frontend**: `cd builder-ui && npm run dev` (port 5173)

### Evolution_Content_Factory
- **Run Auto Reel Builder**: `python modules/auto_reel_builder.py`

### Evolution_Research_Engine
- **Run Server**: `python src/main.py` (port 8001)

### Local_LLM
- **Run Server**: `python src/llm_integration.py` (port 8002)

### evolution-email-builder
- **Run Dev Server**: `npm run dev` (port 5174)

### evolution-studios-engine
- **Run Dev Server**: `npm run dev` (port 3000)

## Current Phase
- **Main Repos**: Foundation Layer (Phase 1)
- **New Repos**: Scaffolded (Phase 0)

## Next Build Target
1. Implement real scraping logic in Evolution_Research_Engine
2. Improve video generation in Evolution_Content_Factory
3. Integrate all content generation tools

## Source of Truth
All development standards are defined in 00_DNA. Refer to `/home/evo/00_DNA/` for more information.
