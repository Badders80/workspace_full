#!/bin/bash
# ═══════════════════════════════════════════════════════════
# Memory Optimization Script for Evolution Stables
# Fixes WSL2 + VS Code memory issues
# ═══════════════════════════════════════════════════════════

EVO_ROOT="/home/evo"

echo "🧠 Memory Optimization for WSL2 + VS Code"
echo "═══════════════════════════════════════════════════════════"
echo ""

# ─── 1. Create WSL Config (limits memory usage) ─────────────────
echo "📋 Step 1: Creating WSL configuration..."

if [[ ! -f /etc/wsl.conf ]]; then
    sudo tee /etc/wsl.conf > /dev/null << 'EOF'
[wsl2]
# Limit WSL2 to 12GB RAM (half of your 24GB)
memory=12GB
# Limit to 8 processors
processors=8
# Don't swap to Windows page file (prevents disk thrashing)
swap=0
# Allow WSL2 to reclaim memory when not in use
localhostForwarding=true
EOF
    echo "  ✅ Created /etc/wsl.conf"
    echo "  ⚠️  RESTART WSL REQUIRED: wsl --shutdown"
else
    echo "  ℹ️  /etc/wsl.conf already exists"
fi

echo ""

# ─── 2. Clean VS Code Server Cache ──────────────────────────────
echo "📋 Step 2: Cleaning VS Code server cache..."

VSCODE_CACHE="$HOME/.vscode-server"
if [[ -d "$VSCODE_CACHE" ]]; then
    CACHE_SIZE=$(du -sh "$VSCODE_CACHE" 2>/dev/null | cut -f1)
    echo "  Current cache size: $CACHE_SIZE"
    
    # Keep only latest version, remove old ones
    cd "$VSCODE_CACHE/bin" 2>/dev/null && ls -t | tail -n +2 | xargs -r rm -rf
    
    NEW_SIZE=$(du -sh "$VSCODE_CACHE" 2>/dev/null | cut -f1)
    echo "  ✅ Cleaned. New size: $NEW_SIZE"
else
    echo "  ℹ️  No VS Code server cache found"
fi

echo ""

# ─── 3. Kill Zombie VS Code Processes ───────────────────────────
echo "📋 Step 3: Checking for zombie VS Code processes..."

ZOMBIES=$(ps aux | grep vscode-server | grep -v grep | wc -l)
if [[ $ZOMBIES -gt 0 ]]; then
    echo "  Found $ZOMBIES zombie VS Code server processes"
    ps aux | grep vscode-server | grep -v grep | awk '{print $2}' | xargs -r kill -9
    echo "  ✅ Killed zombie processes"
else
    echo "  ✅ No zombie VS Code processes found"
fi

echo ""

# ─── 4. Check for Memory Hogs ───────────────────────────────────
echo "📋 Step 4: Top memory consumers..."

ps aux --sort=-%mem | head -6 | tail -5 | awk '{printf "  %-8s %5s %s\n", $2, $4"%", $11}'

echo ""

# ─── 5. Memory Reclamation Settings ─────────────────────────────
echo "📋 Step 5: Configuring memory reclamation..."

# Add to .bashrc for automatic cleanup
if ! grep -q "drop_caches" ~/.bashrc 2>/dev/null; then
    cat >> ~/.bashrc << 'EOF'

# Memory reclamation: Drop caches when shell starts (safe)
# This frees cached memory that's not actively needed
if [[ -f /proc/sys/vm/drop_caches ]]; then
    sync && echo 1 | sudo tee /proc/sys/vm/drop_caches > /dev/null 2>&1
fi
EOF
    echo "  ✅ Added memory reclamation to .bashrc"
else
    echo "  ℹ️  Memory reclamation already configured"
fi

echo ""

# ─── Summary ────────────────────────────────────────────────────
echo "═══════════════════════════════════════════════════════════"
echo "📊 Summary"
echo "═══════════════════════════════════════════════════════════"
echo ""
echo "Current memory status:"
free -h | grep -E "Mem|Swap" | sed 's/^/  /'
echo ""
echo "Next steps:"
echo "  1. Restart WSL: wsl --shutdown (in Windows PowerShell)"
echo "  2. Reopen WSL terminal"
echo "  3. Run 'just memory' anytime to see current usage"
echo ""
echo "To see memory anytime:"
echo "  just memory    # Shows top consumers + available RAM"
echo ""
