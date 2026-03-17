#!/bin/bash
# Setup script for Claude Code with Google Vertex AI
# Run this after configuring your GCP project

echo "🦞 Setting up Claude Code with Google Vertex AI..."
echo ""

# Check if gcloud is installed
if ! command -v gcloud &> /dev/null; then
    echo "❌ gcloud CLI not found. Installing..."
    
    # Install gcloud (for Debian/Ubuntu/WSL)
    sudo apt-get update
    sudo apt-get install -y apt-transport-https ca-certificates gnupg curl
    
    # Add Google Cloud SDK repo
    echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | \
        sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
    
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | \
        sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
    
    # Install
    sudo apt-get update && sudo apt-get install -y google-cloud-sdk
    
    echo "✅ gcloud installed!"
else
    echo "✅ gcloud already installed"
fi

echo ""
echo "🔑 Authenticating with Google Cloud..."
gcloud auth application-default login

echo ""
echo "📋 Getting your GCP project ID..."
PROJECT_ID=$(gcloud config get-value project 2>/dev/null)

if [ -z "$PROJECT_ID" ]; then
    echo "⚠️  No default project set. Please set one:"
    echo "   gcloud config set project YOUR_PROJECT_ID"
    echo ""
    echo "Available projects:"
    gcloud projects list --limit=10
else
    echo "✅ Using project: $PROJECT_ID"
    
    # Update .env file with the project ID
    sed -i "s/# ANTHROPIC_VERTEX_PROJECT_ID=.*/ANTHROPIC_VERTEX_PROJECT_ID=$PROJECT_ID/" ~/.env
    echo "✅ Updated ~/.env with project ID"
fi

echo ""
echo "📝 Current configuration:"
grep -E "CLAUDE_CODE|VERTEX" ~/.env | grep -v "^#"

echo ""
echo "🚀 To use Claude Code with Vertex AI, run:"
echo "   export CLAUDE_CODE_USE_VERTEX=1"
echo "   export ANTHROPIC_VERTEX_PROJECT_ID=$PROJECT_ID"
echo "   export CLOUD_ML_REGION=us-central1"
echo "   claude"
echo ""
echo "Or source your .env: source ~/.env && claude"
