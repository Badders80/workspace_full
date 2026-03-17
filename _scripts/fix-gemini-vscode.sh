#!/bin/bash

# Script to help fix VS Code Gemini Code Assist "not eligible" error

echo "=== Fixing VS Code Gemini Code Assist Configuration ==="

# Check if VS Code is running
if pgrep -x "code" > /dev/null; then
    echo "⚠️  VS Code is running. Please close it before continuing."
    exit 1
fi

echo "✅ VS Code is closed"

# Check if .vscode-server directory exists
if [ -d "$HOME/.vscode-server" ]; then
    echo "✅ VS Code server directory found"
    
    # Clean VS Code server extensions
    GEMINI_EXT_DIR="$HOME/.vscode-server/extensions/google.geminicodeassist-*/"
    if ls $GEMINI_EXT_DIR 2>/dev/null; then
        echo "✅ Found Gemini Code Assist extension"
        echo "   $(ls -la $GEMINI_EXT_DIR | head -1)"
    else
        echo "❌ Gemini Code Assist extension not found"
    fi
fi

# Clean .gemini directory
if [ -d "$HOME/.gemini" ]; then
    echo "✅ Found .gemini directory"
    
    # Display current account info
    if [ -f "$HOME/.gemini/google_accounts.json" ]; then
        echo "   Current active account: $(jq -r '.active' $HOME/.gemini/google_accounts.json)"
    fi
    
    # Ask to reset configuration
    read -p "Do you want to reset Gemini configuration? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "🔄 Resetting .gemini directory"
        
        # Backup existing config
        if [ ! -d "$HOME/.gemini.backup" ]; then
            mkdir "$HOME/.gemini.backup"
        fi
        cp -r $HOME/.gemini/* $HOME/.gemini.backup/
        
        # Clean session data
        rm -f $HOME/.gemini/oauth_creds.json
        rm -f $HOME/.gemini/state.json
        cat > $HOME/.gemini/google_accounts.json << 'EOF'
{
  "active": "",
  "old": []
}
EOF
        
        echo "✅ Configuration reset complete"
    fi
fi

# Check Google AI Studio API Keys
echo
echo "=== Google AI Studio API Key Check ==="
echo "To verify your API key and quota tier:"
echo "  1. Go to https://aistudio.google.com/app/apikey"
echo "  2. Check if your API key has Tier 1 access (or higher)"
echo "  3. If you only have free tier, you may need to upgrade to paid access"

# Summary of recommended steps
echo
echo "=== Recommended Steps ==="
echo "1. Clear browser cookies for: accounts.google.com and console.cloud.google.com"
echo "2. Open VS Code"
echo "3. Click your profile icon (bottom left) and select \"Sign Out\""
echo "4. Wait a few seconds, then click \"Sign In\" again"
echo "5. When signing in, ensure you select your personal Gmail account (not a work account)"
echo "6. Do NOT use the API Key method for login"

echo
echo "=== Done ==="