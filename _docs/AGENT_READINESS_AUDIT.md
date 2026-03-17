# Agentic Readiness Audit - 2026-03-17

## Executive Summary

The repository demonstrates a highly sophisticated **DNA-led architecture** designed for agentic workflows. The intent is to provide a "computable brain" (`DNA/`) that guides AI agents through consistent rules, skills, and context.

However, the current implementation is in a state of **structural drift** and **environment lock-in**, rendering it largely "braindead" for any agent outside of the original `/home/evo/workspace` environment.

---

## 1. Critical Blockers (Red)

### 1.1 Environment Lock-in (Hardcoded Paths)
- **Issue**: Over 1,000 instances of `/home/evo/workspace` are hardcoded in markdown files and bash scripts.
- **Impact**: Agents operating in different environments (like `/app` or a user's local path) will fail to find core context, rules, and scripts.
- **Evidence**: `_scripts/evo-check.sh` and `_scripts/health-check.sh` fail immediately in non-standard environments.

### 1.2 Missing Core Assets
- **Issue**: The `projects/` directory, which should contain the actual codebases (Evolution_Platform, SSOT_Build, etc.), is missing from the current filesystem.
- **Impact**: The agent has rules but no subject matter to work on.
- **Evidence**: `MANIFEST.md` lists `projects/` as active, but `ls projects/` returns an error.

---

## 2. Structural Drift (Yellow)

### 2.1 "Ghost" Skills
- **Issue**: `DNA/skills/INDEX.md` lists numerous skills (e.g., `ui_tweaks.md`, `multi_file_debug.md`), but the actual files do not exist in `DNA/skills/`.
- **Impact**: Agents are told they have "skills" they cannot actually read or use.

### 2.2 Stale System Prompts
- **Issue**: System prompts in `DNA/system-prompts/PROMPT_LIBRARY.md` still reference legacy paths like `/home/evo/00_DNA/`.
- **Impact**: Newly initialized agents will be misdirected to archived or deleted directories.

### 2.3 Broken Diagnostic Chain
- **Issue**: The `just check` and `evo doctor` commands are broken because they rely on a chain of scripts that use absolute paths.
- **Impact**: There is no way for an agent or human to verify the health of the workspace autonomously.

---

## 3. Optimization Opportunities (Green)

### 3.1 Relative Path Migration
- **Recommendation**: Systematically replace `/home/evo/workspace` with relative paths or a `$WORKSPACE_ROOT` environment variable.
- **Benefit**: Makes the repository portable and truly "agent-ready" across different hosting environments.

### 3.2 Skill Tokenization
- **Recommendation**: Convert documentation-heavy skills into structured JSON schemas or "System Prompt Snippets" that can be dynamically injected.
- **Benefit**: Reduces prompt bloat while increasing the precision of agent actions.

### 3.3 Automated Context Pruning
- **Recommendation**: The current "Required Reading Order" is too heavy (10+ files). Implement a "Context Registry" that helps agents pick only the *relevant* DNA files for their specific task.
- **Benefit**: Saves tokens and reduces the "Lost in the Middle" effect in long-context models.

---

## 4. Agentic Readiness Score

| Category | Score | Notes |
| :--- | :--- | :--- |
| **Architectural Intent** | 10/10 | The DNA/Project/Script split is world-class for agents. |
| **Portability** | 1/10 | Totally locked to `/home/evo/workspace`. |
| **Actionability** | 3/10 | Tools and skills are mostly missing or broken. |
| **Context Clarity** | 5/10 | Good docs, but high risk of stale/conflicting info. |

**Overall Readiness: 4.7/10** (Great bones, but currently non-functional).

---

## 5. Roadmap to "Agentic Prime"

1. **Phase 1: Decoupling** (High Priority)
   - [ ] Normalize paths to relative root.
   - [ ] Fix `_scripts/` to use `dirname "$0"` for self-location.
2. **Phase 2: Restoration**
   - [ ] Re-home or symlink missing `projects/`.
   - [ ] Populate `DNA/skills/` with the actual content indexed.
3. **Phase 3: Intelligence Injection**
   - [ ] Update `PROMPT_LIBRARY.md` to match the current structure.
   - [ ] Implement `evo context --smart` to provide task-specific DNA slices.
