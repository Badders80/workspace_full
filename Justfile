# Justfile - Task runner for Evolution Stables
# Usage: just <task>
# Install just: curl --proto '=https' --tlsv1.2 -sSf https://just.systems/install.sh | bash

# Default task - show help
default:
    @just --list

# ═══════════════════════════════════════════════════════════
# Daily Commands
# ═══════════════════════════════════════════════════════════

# Check current workspace gate, vault, docker
check:
    @echo "🔍 Running all checks..."
    bash /home/evo/workspace/_scripts/evo-check.sh
    bash /home/evo/workspace/_scripts/vault.sh check
    bash /home/evo/workspace/_scripts/evo-docker.sh status

# Quick status - what's happening
status:
    @echo "📊 Project Status"
    @echo "═══════════════════════════════════════════════════════════"
    @evo backlog | head -30

# ═══════════════════════════════════════════════════════════
# Vault Management
# ═══════════════════════════════════════════════════════════

# Edit the central API vault
vault:
    evo vault edit

# Check vault health
vault-check:
    evo vault check

# ═══════════════════════════════════════════════════════════
# Docker Management
# ═══════════════════════════════════════════════════════════

# See what's running
docker-status:
    evo docker status

# List Docker projects
docker-list:
    evo docker list

# Start N8N workflows
n8n:
    evo docker start n8n

# Start Evolution Studio
studio:
    evo docker start studio

# Stop all Docker containers (emergency)
stop-all:
    evo docker stop-all

# ═══════════════════════════════════════════════════════════
# DNA / Memory
# ═══════════════════════════════════════════════════════════

# Show current backlog
backlog:
    evo backlog

# Show decision log
decisions:
    evo decisions

# Quick capture into the sidecar research vault
research-capture title body='':
    bash /home/evo/workspace/_scripts/research-capture.sh "{{title}}" "{{body}}"

# Launch Obsidian for the research vault from Windows PowerShell
research-vault-open:
    powershell -ExecutionPolicy Bypass -File "\\wsl.localhost\Ubuntu\home\evo\workspace\_scripts\open-research-vault.ps1"

# Sync workspace vault -> local Windows Obsidian vault
research-vault-pull:
    powershell -ExecutionPolicy Bypass -File "\\wsl.localhost\Ubuntu\home\evo\workspace\_scripts\research-vault-sync.ps1" -Direction pull

# Sync local Windows Obsidian vault -> workspace vault
research-vault-push:
    powershell -ExecutionPolicy Bypass -File "\\wsl.localhost\Ubuntu\home\evo\workspace\_scripts\research-vault-sync.ps1" -Direction push

# Seed the research vault with the current website/profile source set
research-seed:
    bash -lc 'python3 /home/evo/workspace/_scripts/seed_research_sources.py'

# Edit DNA
dna:
    code /home/evo/workspace/DNA

# Commit DNA changes
dna-commit msg:
    git -C /home/evo/workspace add DNA/ && git -C /home/evo/workspace commit -m "{{msg}}" -- DNA/

# ═══════════════════════════════════════════════════════════
# Navigation
# ═══════════════════════════════════════════════════════════

# Go to projects
proj:
    cd /home/evo/workspace/projects

# Go to DNA
cd-dna:
    cd /home/evo/workspace/DNA

# Go to scripts
cd-scripts:
    cd /home/evo/workspace/_scripts

# ═══════════════════════════════════════════════════════════
# Maintenance
# ═══════════════════════════════════════════════════════════

# Install git hooks (prevent .env commits)
install-hooks:
    bash /home/evo/workspace/_scripts/install-git-hooks.sh

# Install enhancements (fzf, zoxide, just, starship)
install-enhancements:
    bash /home/evo/workspace/_scripts/install-enhancements.sh

# Clean up Docker
docker-clean:
    evo docker clean

# Update all git repos (DNA + projects)
update:
    @echo "🔄 Updating all repositories..."
    @echo ""
    @echo "Updating DNA..."
    cd /home/evo/workspace/DNA && git pull
    @echo ""
    @echo "Updating projects..."
    @for dir in /home/evo/workspace/projects/*/; do \
        if [ -d "$$dir/.git" ]; then \
            echo "  $$(basename $$dir)..."; \
            cd "$$dir" && git pull 2>/dev/null || echo "    (failed or no remote)"; \
        fi \
    done
    @echo ""
    @echo "✅ Update complete"

# Backup DNA and projects
backup:
    @echo "💾 Creating backup..."
    @mkdir -p /home/evo/_archive/backups/auto
    @tar czf "/home/evo/_archive/backups/auto/evo-backup-$(date +%Y%m%d-%H%M%S).tar.gz" \
        -C /home/evo/workspace \
        --exclude='node_modules' \
        --exclude='.next' \
        --exclude='__pycache__' \
        --exclude='.Trash' \
        --exclude='models' \
        --exclude='.cache' \
        DNA projects _docs _locks _logs _sandbox _scripts AGENTS.md AI_SESSION_BOOTSTRAP.md Justfile MANIFEST.md 2>/dev/null
    @echo "✅ Backup created in /home/evo/_archive/backups/auto/"

# Full system check + update
doctor: check backup
    @echo "✅ System checked and backed up"


# ═══════════════════════════════════════════════════════════
# Memory Management (WSL2 Optimization)
# ═══════════════════════════════════════════════════════════

# Quick memory check (what's using RAM)
memory:
    bash /home/evo/workspace/_scripts/memory-check.sh

# Full memory optimization (WSL config, cleanup, kill zombies)
optimize-memory:
    bash /home/evo/workspace/_scripts/memory-optimize.sh

# ═══════════════════════════════════════════════════════════
# Audit Helpers
# ═══════════════════════════════════════════════════════════

audit-partners date='':
    @/home/evo/workspace/_scripts/evo-audit-partners.sh {{date}}

audit-groq-watchdog date='':
    @/home/evo/workspace/_scripts/evo-groq-watchdog.sh {{date}}

audit-claude-meta date='':
    @/home/evo/workspace/_scripts/evo-audit-claude-meta.sh {{date}}

audit-partners-claude date='':
    @/home/evo/workspace/_scripts/evo-audit-claude-meta.sh {{date}}

audit-openfang-bridge date='':
    @/home/evo/workspace/_scripts/evo-openfang-audit-bridge.sh {{date}}

# ═══════════════════════════════════════════════════════════
# Analysis Mirror
# ═══════════════════════════════════════════════════════════

analysis-mirror:
    bash /home/evo/workspace/_scripts/sync-analysis-mirror-git.sh

analysis-mirror-apply:
    bash /home/evo/workspace/_scripts/sync-analysis-mirror-git.sh --apply

workspace-full:
    bash /home/evo/workspace/_scripts/sync-workspace-full-git.sh --remote-url https://github.com/Badders80/workspace_full.git

workspace-full-apply:
    bash /home/evo/workspace/_scripts/sync-workspace-full-git.sh --apply --remote-url https://github.com/Badders80/workspace_full.git
