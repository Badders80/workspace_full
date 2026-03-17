#!/bin/bash
# ═══════════════════════════════════════════════════════════
# Install Lightweight Enhancements for Evolution Stables
# FZF, Zoxide, Just, Starship
# ═══════════════════════════════════════════════════════════

EVO_ROOT="/home/evo"

echo "🚀 Installing Lightweight Enhancements"
echo "═══════════════════════════════════════════════════════════"

# Check if running in WSL
IS_WSL=false
if grep -q Microsoft /proc/version 2>/dev/null || grep -q WSL /proc/version 2>/dev/null; then
    IS_WSL=true
fi

# Install FZF (fuzzy finder)
install_fzf() {
    echo ""
    echo "📦 Installing FZF (fuzzy finder)..."
    
    if command -v fzf &> /dev/null; then
        echo "  ✅ FZF already installed"
        return
    fi
    
    # Install via git (lightweight, no package manager needed)
    if [[ ! -d ~/.fzf ]]; then
        git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf 2>/dev/null
        ~/.fzf/install --all --no-bash --no-fish --no-zsh 2>/dev/null || true
    fi
    
    # Add to PATH if needed
    if [[ ! -f ~/.fzf/bin/fzf ]]; then
        echo "  ❌ FZF installation failed"
        return
    fi
    
    # Add to .bashrc if not already there
    if ! grep -q "fzf" ~/.bashrc; then
        cat >> ~/.bashrc << 'EOF'

# FZF (fuzzy finder)
[ -f ~/.fzf.bash ] && source ~/.fzf.bash
export PATH="$HOME/.fzf/bin:$PATH"
EOF
    fi
    
    echo "  ✅ FZF installed"
    echo "     Usage: Ctrl+R (history), Ctrl+T (files), Alt+C (cd)"
}

# Install Zoxide (smarter cd)
install_zoxide() {
    echo ""
    echo "📦 Installing Zoxide (smarter cd)..."
    
    if command -v zoxide &> /dev/null; then
        echo "  ✅ Zoxide already installed"
        return
    fi
    
    # Install via official installer
    curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash 2>/dev/null
    
    # Add to .bashrc
    if ! grep -q "zoxide" ~/.bashrc; then
        cat >> ~/.bashrc << 'EOF'

# Zoxide (smarter cd - use 'z' instead of 'cd')
eval "$(zoxide init bash --cmd cd)"  # Replace cd with zoxide
EOF
    fi
    
    echo "  ✅ Zoxide installed"
    echo "     Usage: cd projects (fuzzy match), cd -- (interactive)"
}

# Install Just (task runner)
install_just() {
    echo ""
    echo "📦 Installing Just (task runner)..."
    
    if command -v just &> /dev/null; then
        echo "  ✅ Just already installed"
        return
    fi
    
    # Download binary
    curl --proto '=https' --tlsv1.2 -sSf https://just.systems/install.sh | bash -s -- --to ~/.local/bin 2>/dev/null
    
    # Ensure ~/.local/bin is in PATH
    if ! grep -q ".local/bin" ~/.bashrc; then
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
    fi
    
    echo "  ✅ Just installed"
    echo "     Usage: just (runs default task), just <taskname>"
}

# Install Starship (pretty prompt)
install_starship() {
    echo ""
    echo "📦 Installing Starship (pretty prompt)..."
    
    if command -v starship &> /dev/null; then
        echo "  ✅ Starship already installed"
        return
    fi
    
    # Install via official script
    curl -sS https://starship.rs/install.sh | sh -s -- -y 2>/dev/null
    
    # Add to .bashrc
    if ! grep -q "starship" ~/.bashrc; then
        cat >> ~/.bashrc << 'EOF'

# Starship prompt
eval "$(starship init bash)"
EOF
    fi
    
    # Create minimal config
    mkdir -p ~/.config
    cat > ~/.config/starship.toml << 'EOF'
# Minimal Starship config for Evolution Stables

# Prompt format
format = """$directory$git_branch$git_status$character"""

# Directory
[directory]
truncation_length = 3
truncate_to_repo = true

# Git
[git_branch]
symbol = "🌿 "

[git_status]
conflicted = "🏳"
ahead = "🏎💨"
behind = "😰"
diverged = "😵"
up_to_date = "✓"
untracked = "🤷"
stashed = "📦"
modified = "📝"
staged = '[++\($count\)](green)'
renamed = "👅"
deleted = "🗑"

# Character
[character]
success_symbol = "[➜](bold green)"
error_symbol = "[✗](bold red)"

# Disable modules we don't need
[package]
disabled = true

[nodejs]
disabled = true

[python]
disabled = true

[ruby]
disabled = true

[golang]
disabled = true

[rust]
disabled = true
EOF
    
    echo "  ✅ Starship installed"
    echo "     Shows: current dir, git branch, git status"
}

# Install all
install_fzf
install_zoxide
install_just
install_starship

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "✅ Enhancements installed!"
echo ""
echo "Restart your terminal or run: source ~/.bashrc"
echo ""
echo "Quick reference:"
echo "  Ctrl+R         - Fuzzy search command history"
echo "  Ctrl+T         - Fuzzy find files"
echo "  cd projects    - Zoxide fuzzy matches (try 'cd pro')"
echo "  just           - Run project tasks (see justfile)"
echo "  Prompt shows   - Current dir + git branch + status"
