#!/bin/bash
# ═══════════════════════════════════════════════════════════
# Tool TLDR - Quick tool evaluation
# Usage: tool-tldr <url or name>
# Example: tool-tldr "https://github.com/some/cool-tool"
# ═══════════════════════════════════════════════════════════

WORKSPACE_ROOT="/home/evo/workspace"
DNA_ROOT="$WORKSPACE_ROOT/DNA"
STACK_FILE="$DNA_ROOT/ops/STACK.md"
RADAR_FILE="$DNA_ROOT/ops/TECH_RADAR.md"
INBOX_FILE="$DNA_ROOT/INBOX.md"

color_green='\033[0;32m'
color_yellow='\033[1;33m'
color_blue='\033[0;34m'
color_red='\033[0;31m'
color_nc='\033[0m'

show_help() {
    cat << 'EOF'
🎯 Tool TLDR - Quick evaluation helper

Usage: tool-tldr <url or "tool name">

Examples:
  tool-tldr "https://github.com/vercel/next.js"
  tool-tldr "some new ai framework"
  tool-tldr "supabase database"

What it does:
  1. Generates a TLDR template
  2. Checks STACK.md for live overlap
  3. Consults TECH_RADAR.md on demand for prior notes
  4. Suggests next steps

EOF
}

# Check live stack first, then consult radar on demand.
check_existing() {
    local query="$1"
    local keywords=$(echo "$query" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/ /g')
    local found_stack=0
    local found_radar=0

    echo -e "${color_blue}🔍 Checking STACK.md for live tool overlap...${color_nc}"

    for word in $keywords; do
        if [[ ${#word} -gt 3 ]]; then
            if grep -i "$word" "$STACK_FILE" 2>/dev/null >/dev/null; then
                if [[ $found_stack -eq 0 ]]; then
                    echo -e "${color_yellow}  ⚠️  Possible live-stack overlap:${color_nc}"
                    found_stack=1
                fi
                grep -ni "$word" "$STACK_FILE" 2>/dev/null | head -3 | sed 's/^/     /'
            fi
        fi
    done

    if [[ $found_stack -eq 0 ]]; then
        echo -e "${color_green}  ✅ No obvious live-stack overlap found${color_nc}"
    fi
    echo ""

    echo -e "${color_blue}🗂 Consulting TECH_RADAR.md on demand for prior notes...${color_nc}"

    for word in $keywords; do
        if [[ ${#word} -gt 3 ]]; then
            if grep -i "$word" "$RADAR_FILE" 2>/dev/null | grep -q "^###"; then
                if [[ $found_radar -eq 0 ]]; then
                    echo -e "${color_yellow}  ⚠️  Possible prior evaluation notes:${color_nc}"
                    found_radar=1
                fi
                grep -i "$word" "$RADAR_FILE" 2>/dev/null | grep "^###" | head -3 | sed 's/^/     /'
            fi
        fi
    done

    if [[ $found_radar -eq 0 ]]; then
        echo -e "${color_green}  ✅ No obvious prior radar notes found${color_nc}"
    fi
    echo ""
}

# Generate TLDR template
generate_tldr() {
    local input="$1"
    local date_str=$(date +%Y-%m-%d)
    
    echo ""
    echo "═══════════════════════════════════════════════════════════"
    echo "🎯 TOOL TLDR - $date_str"
    echo "═══════════════════════════════════════════════════════════"
    echo ""
    echo -e "${color_blue}Input:${color_nc} $input"
    echo ""
    echo "───────────────────────────────────────────────────────────"
    echo "COPY-PASTE TEMPLATE:"
    echo "───────────────────────────────────────────────────────────"
    echo ""
    echo "### $date_str - [Tool Name]"
    echo "**Source:** [Where you found it]"
    echo "**Link:** $input"
    echo "**Category:** [AI/DevOps/Frontend/Automation/etc]"
    echo ""
    echo "**What it does (one-liner):**"
    echo "[1-2 sentences max]"
    echo ""
    echo "**Key features:**"
    echo "- Feature 1"
    echo "- Feature 2"
    echo "- Feature 3"
    echo ""
    echo "**Hot take (vibe check):**"
    echo "- Promising / Overrated / Confusing / Revolutionary"
    echo "- Solves real problem? Yes/Maybe/No"
    echo "- Better than what we have? Yes/Maybe/No"
    echo ""
    echo "**Overlap check:**"
    echo "- Similar to: [existing tools]"
    echo "- Replaces: [what it might replace]"
    echo "- Complements: [what it works with]"
    echo ""
    echo "**Quick verdict:**"
    echo "- 🔴 Reject = Not for us"
    echo "- 🟡 Assess = Interesting, research more"
    echo "- 🟢 Trial = Test in sandbox"
    echo "- 🔵 Adopt = Production ready"
    echo ""
    echo "**Decision deadline:** [Set a date - usually 1-2 weeks]"
    echo ""
}

# Suggest next steps
suggest_actions() {
    echo ""
    echo "───────────────────────────────────────────────────────────"
    echo "SUGGESTED NEXT STEPS:"
    echo "───────────────────────────────────────────────────────────"
    echo ""
    echo "1. Fill out the template above"
    echo ""
    echo "2. Review the live registry first:"
    echo "   code $STACK_FILE"
    echo ""
    echo "3. Capture notes in INBOX.md if it still looks new:"
    echo "   code $INBOX_FILE"
    echo ""
    echo "4. Consult TECH_RADAR.md on demand for prior notes:"
    echo "   code $RADAR_FILE"
    echo ""
    echo "5. Quick decision shortcuts:"
    echo "   - Obviously crap? Delete and move on"
    echo "   - Educational only? Archive immediately"
    echo "   - Similar to existing? Compare and decide"
    echo "   - Actually new? Assess with deadline"
    echo ""
}

# Main
if [[ $# -eq 0 ]] || [[ "$1" == "--help" ]] || [[ "$1" == "-h" ]]; then
    show_help
    exit 0
fi

input="$*"

generate_tldr "$input"
check_existing "$input"
suggest_actions

echo "═══════════════════════════════════════════════════════════"
