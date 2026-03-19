#!/bin/bash
# ═══════════════════════════════════════════════════════════
# Evo Vault - One Point for API Keys
# Simple health check for the central vault
# ═══════════════════════════════════════════════════════════

CONTROL_ROOT="/home/evo"
WORKSPACE_ROOT="$CONTROL_ROOT/workspace"
PROJECT_ROOT="$WORKSPACE_ROOT/projects"
VAULT="$CONTROL_ROOT/.env"
TEMPLATE="$WORKSPACE_ROOT/DNA/vault/env.template"
SCHEMA="$WORKSPACE_ROOT/DNA/vault/env.schema"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

show_help() {
    cat << 'EOF'
Evo Vault - One Point for API Keys

Usage: vault.sh [command]

Commands:
  check       Verify vault health (symlinks, permissions)
  validate    Validate .env against schema
  status      Show vault status summary
  edit        Open vault in editor
  template    Show env.template
  help        Show this help

The vault is simple:
  - ONE file: /home/evo/.env (master)
  - All projects symlink to it
  - Never commit .env files

EOF
}

validate_vault() {
    echo "🔐 Evo Vault Validation"
    echo "═══════════════════════════════════════════════════════"
    
    if [[ ! -f "$VAULT" ]]; then
        echo -e "${RED}❌ Master vault not found at $VAULT${NC}"
        return 1
    fi
    
    # Load schema and check required keys
    local missing=0
    local warnings=0

    if [[ ! -f "$SCHEMA" ]]; then
        echo -e "${YELLOW}⚠${NC} Validation schema missing at $SCHEMA"
    fi
    
    echo "Checking required environment variables..."
    echo ""
    
    # Check critical keys (simplified - just check if they exist)
    CRITICAL_KEYS=(
        "OPENAI_API_KEY"
        "ANTHROPIC_API_KEY"
        "GEMINI_API_KEY"
        "DATABASE_URL"
        "SUPABASE_URL"
    )
    
    for key in "${CRITICAL_KEYS[@]}"; do
        if grep -q "^${key}=" "$VAULT" 2>/dev/null && \
           ! grep -q "^${key}=\s*$" "$VAULT" 2>/dev/null && \
           ! grep -q "^${key}=\.\.\." "$VAULT" 2>/dev/null; then
            value=$(grep "^${key}=" "$VAULT" | cut -d'=' -f2 | head -c 20)
            echo -e "${GREEN}✓${NC} $key is set (${value}...)"
        else
            echo -e "${YELLOW}⚠${NC} $key is missing or empty"
            ((missing++))
        fi
    done
    
    echo ""
    if [[ $missing -eq 0 ]]; then
        echo -e "${GREEN}✅ All critical keys present${NC}"
        return 0
    else
        echo -e "${YELLOW}⚠ $missing critical key(s) missing${NC}"
        echo "Run 'evo vault edit' to add them"
        return 1
    fi
}

check_vault() {
    echo "🔐 Evo Vault Health Check"
    echo "═══════════════════════════════════════════════════════"
    
    local errors=0
    
    # 1. Check master vault exists
    if [[ -f "$VAULT" ]]; then
        local perms=$(stat -c "%a" "$VAULT")
        if [[ "$perms" == "600" ]]; then
            echo -e "${GREEN}✅${NC} Master vault exists with secure permissions (600)"
        else
            echo -e "${YELLOW}⚠️ ${NC} Master vault permissions: $perms (should be 600)"
            echo "   Fix: chmod 600 $VAULT"
            ((errors++))
        fi
        
        # Count keys
        local key_count=$(grep -c "^[A-Z].*=" "$VAULT" 2>/dev/null || echo "0")
        echo "   Contains ~$key_count API keys"
    else
        echo -e "${RED}❌${NC} Master vault NOT FOUND at $VAULT"
        echo "   Create: cp $TEMPLATE $VAULT && chmod 600 $VAULT"
        ((errors++))
    fi
    
    echo ""
    
    # 2. Check project symlinks
    echo "📁 Project Symlinks"
    local project_dirs=()
    if [[ -d "$PROJECT_ROOT" ]]; then
        shopt -s nullglob
        project_dirs=( "$PROJECT_ROOT"/Evolution_* )
        shopt -u nullglob
    else
        echo -e "${YELLOW}⚠${NC} Projects root missing: $PROJECT_ROOT"
    fi

    local linked=0
    local missing=0

    for proj in "${project_dirs[@]}"; do
        if [[ -d "$proj" ]]; then
            local name=$(basename "$proj")
            if [[ -L "$proj/.env" ]]; then
                local target=$(readlink "$proj/.env")
                if [[ "$target" == "$VAULT" ]]; then
                    echo -e "${GREEN}✅${NC} $name → $VAULT"
                    ((linked++))
                else
                    echo -e "${YELLOW}⚠️ ${NC} $name → $target (unexpected target)"
                    ((missing++))
                fi
            else
                echo -e "${RED}❌${NC} $name - no symlink (fix: cd $proj && ln -sf /home/evo/.env .env)"
                ((missing++))
            fi
        fi
    done
    
    echo ""
    
    # 3. Summary
    echo "═══════════════════════════════════════════════════════"
    if [[ $errors -eq 0 && $missing -eq 0 ]]; then
        echo -e "${GREEN}✅ Vault is healthy${NC}"
        echo "   $linked projects linked to central vault"
        return 0
    else
        echo -e "${YELLOW}⚠️ Vault needs attention${NC}"
        echo "   Fix the issues above, then run: vault.sh check"
        return 1
    fi
}

show_status() {
    echo "🔐 Evo Vault Status"
    echo "═══════════════════════════════════════════════════════"
    
    if [[ -f "$VAULT" ]]; then
        local size=$(stat -c "%s" "$VAULT")
        local modified=$(stat -c "%y" "$VAULT" | cut -d' ' -f1)
        echo "Master vault: $VAULT"
        echo "Size: $size bytes | Last modified: $modified"
        
        # List configured services (without showing values)
        echo ""
        echo "Configured services:"
        grep "^[A-Z].*_API_KEY=" "$VAULT" 2>/dev/null | cut -d'=' -f1 | sed 's/^/  • /' || echo "  (none found)"
    else
        echo "Master vault: NOT FOUND"
    fi
    
    echo ""
    echo "Template: $TEMPLATE"
    if [[ -f "$TEMPLATE" ]]; then
        echo "Status: Available"
    else
        echo "Status: MISSING"
    fi
}

edit_vault() {
    if [[ -f "$VAULT" ]]; then
        ${EDITOR:-nano} "$VAULT"
    else
        echo "Vault not found. Creating from template..."
        cp "$TEMPLATE" "$VAULT"
        chmod 600 "$VAULT"
        ${EDITOR:-nano} "$VAULT"
    fi
}

show_template() {
    cat "$TEMPLATE"
}

# Main
case "${1:-check}" in
    check)
        check_vault
        ;;
    validate)
        validate_vault
        ;;
    status)
        show_status
        ;;
    edit)
        edit_vault
        ;;
    template)
        show_template
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        echo "Unknown command: $1"
        echo "Run 'vault.sh help' for usage"
        exit 1
        ;;
esac
