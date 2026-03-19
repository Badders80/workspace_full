#!/bin/bash
# ═══════════════════════════════════════════════════════════
# Install Git Hooks for Evolution Stables
# Prevents accidents like committing .env files
# ═══════════════════════════════════════════════════════════

CONTROL_ROOT="/home/evo"
WORKSPACE_ROOT="$CONTROL_ROOT/workspace"
PROJECT_ROOT="$WORKSPACE_ROOT/projects"

echo "🔧 Installing Git Hooks"
echo "═══════════════════════════════════════════════════════════"

# Function to install hooks for a git repo
install_hooks() {
    local repo_path=$1
    local repo_name=$(basename "$repo_path")
    
    if [[ ! -d "$repo_path/.git" ]]; then
        return
    fi
    
    echo "Installing hooks for: $repo_name"
    
    # Create pre-commit hook
    cat > "$repo_path/.git/hooks/pre-commit" << 'HOOK'
#!/bin/bash
# Pre-commit hook for Evolution Stables
# Prevents committing sensitive files

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Files that should NEVER be committed
FORBIDDEN_PATTERNS=(
    "\.env$"
    "\.env\.local$"
    "\.env\.production$"
    "\.env\.development$"
    "\.pem$"
    "\.key$"
    "id_rsa"
    "id_ed25519"
    "\.p12$"
    "\.pfx$"
    "password"
    "secret"
    "api.?key"
)

# Get list of staged files
STAGED_FILES=$(git diff --cached --name-only --diff-filter=ACMR)

VIOLATIONS=0

for file in $STAGED_FILES; do
    for pattern in "${FORBIDDEN_PATTERNS[@]}"; do
        if echo "$file" | grep -qiE "$pattern"; then
            echo -e "${RED}❌ BLOCKED: Attempting to commit '$file'${NC}"
            echo "   This file may contain secrets or sensitive data."
            VIOLATIONS=$((VIOLATIONS + 1))
        fi
    done
done

if [[ $VIOLATIONS -gt 0 ]]; then
    echo ""
    echo -e "${RED}Commit blocked! $VIOLATIONS forbidden file(s) detected.${NC}"
    echo ""
    echo "If you're SURE these files are safe to commit:"
    echo "  git commit --no-verify -m 'your message'"
    echo ""
    echo "Better alternatives:"
    echo "  1. Add to .gitignore if they shouldn't be tracked"
    echo "  2. Use .env.example templates for config"
    echo "  3. Store secrets in /home/evo/.env (central vault)"
    exit 1
fi

# Check for large files (>10MB)
LARGE_FILES=$(git diff --cached --name-only --diff-filter=ACMR | xargs -I {} find {} -maxdepth 0 -size +10M 2>/dev/null)

if [[ -n "$LARGE_FILES" ]]; then
    echo -e "${YELLOW}⚠️ WARNING: Large files detected (>10MB):${NC}"
    echo "$LARGE_FILES" | sed 's/^/  /'
    echo ""
    echo "Consider using Git LFS for large files:"
    echo "  git lfs track '*.gguf'  # For AI models"
    echo "  git lfs track '*.mp4'   # For videos"
    echo ""
    read -p "Continue anyway? (yes/no): " confirm
    if [[ "$confirm" != "yes" ]]; then
        exit 1
    fi
fi

echo -e "${GREEN}✅ Pre-commit checks passed${NC}"
exit 0
HOOK
    
    chmod +x "$repo_path/.git/hooks/pre-commit"
    
    # Create post-commit hook for the live workspace governance repo
    if [[ "$repo_path" == "$WORKSPACE_ROOT" ]]; then
        cat > "$repo_path/.git/hooks/post-commit" << 'HOOK'
#!/bin/bash
# Post-commit hook for workspace governance
# Reminds to push changes so memory is backed up

echo "Workspace governance commit complete!"
echo "   Don't forget to push: git push origin main"
HOOK
        chmod +x "$repo_path/.git/hooks/post-commit"
    fi
    
    echo "  ✅ Pre-commit hook installed"
}

# Install for workspace governance repo
echo ""
install_hooks "$WORKSPACE_ROOT"

# Install for each project with a .git folder
echo ""
echo "Scanning projects..."
for proj in "$PROJECT_ROOT"/*/; do
    if [[ -d "$proj/.git" ]]; then
        install_hooks "$proj"
    fi
done

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "✅ Git hooks installed!"
echo ""
echo "What this prevents:"
echo "  • Committing .env files (secrets)"
echo "  • Committing .pem, .key files"
echo "  • Committing files with 'password' or 'secret' in name"
echo "  • Committing files >10MB (warning)"
echo ""
echo "To bypass (emergency only):"
echo "  git commit --no-verify -m 'message'"
