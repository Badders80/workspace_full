#!/bin/bash
# ═══════════════════════════════════════════════════════════
# Quick Memory Check - See what's eating RAM
# ═══════════════════════════════════════════════════════════

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo "🧠 Memory Status"
echo "═══════════════════════════════════════════════════════════"
echo ""

# Get memory info
MEM_TOTAL=$(free -m | awk '/^Mem:/{print $2}')
MEM_USED=$(free -m | awk '/^Mem:/{print $3}')
MEM_AVAIL=$(free -m | awk '/^Mem:/{print $7}')
MEM_PERCENT=$((MEM_USED * 100 / MEM_TOTAL))

# Color code the percentage
if [[ $MEM_PERCENT -gt 90 ]]; then
    COLOR=$RED
elif [[ $MEM_PERCENT -gt 70 ]]; then
    COLOR=$YELLOW
else
    COLOR=$GREEN
fi

echo -e "RAM Usage: ${COLOR}${MEM_USED}MB / ${MEM_TOTAL}MB (${MEM_PERCENT}%)${NC}"
echo -e "Available: ${GREEN}${MEM_AVAIL}MB${NC} (can be reclaimed)"
echo ""

# Show top consumers
echo "Top Memory Consumers:"
echo "───────────────────────────────────────────────────────────"
ps aux --sort=-%mem | head -6 | tail -5 | awk '{
    pid=$2
    mem=$4
    cmd=$11
    # Truncate long commands
    if (length(cmd) > 40) cmd = substr(cmd, 1, 40) "..."
    printf "  %-8s %5s %s\n", pid, mem"%", cmd
}'

echo ""

# Check for potential issues
echo "Quick Health Check:"
echo "───────────────────────────────────────────────────────────"

# VS Code zombies
VSCODE_ZOMBIES=$(ps aux | grep vscode-server | grep -v grep | wc -l)
if [[ $VSCODE_ZOMBIES -gt 0 ]]; then
    echo -e "  ${YELLOW}⚠${NC}  $VSCODE_ZOMBIES VS Code zombie processes"
else
    echo -e "  ${GREEN}✓${NC}  No VS Code zombie processes"
fi

# Node process count
NODE_COUNT=$(ps aux | grep -E "(node|npm)" | grep -v grep | wc -l)
if [[ $NODE_COUNT -gt 15 ]]; then
    echo -e "  ${YELLOW}⚠${NC}  $NODE_COUNT Node processes (high)"
else
    echo -e "  ${GREEN}✓${NC}  $NODE_COUNT Node processes (normal)"
fi

# WSL Config
if [[ -f /etc/wsl.conf ]]; then
    echo -e "  ${GREEN}✓${NC}  WSL memory limits configured"
else
    echo -e "  ${YELLOW}⚠${NC}  No WSL memory limits (run: just optimize-memory)"
fi

echo ""

# Tips based on usage
if [[ $MEM_PERCENT -gt 85 ]]; then
    echo -e "${YELLOW}⚠ High memory usage detected!${NC}"
    echo ""
    echo "Quick fixes:"
    echo "  just optimize-memory    # Run full optimization"
    echo "  pkill -f vscode-server  # Kill VS Code zombies"
    echo "  wsl --shutdown          # Restart WSL (Windows side)"
    echo ""
fi

echo "Run 'just optimize-memory' for full cleanup"
