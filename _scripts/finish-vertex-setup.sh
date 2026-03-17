#!/bin/bash
# Finish Google Vertex AI Setup for Claude Code
# Run this script to complete configuration

echo "🦞 Completing Google Vertex AI Setup"
echo "====================================="
echo ""

# Check if gcloud installed
if ! command -v gcloud &> /dev/null; then
    echo "❌ gcloud not found. Installing now..."
    echo ""
    
    # Add Google Cloud SDK repo
    sudo apt-get update
    sudo apt-get install -y apt-transport-https ca-certificates gnupg curl
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | \
        sudo gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg
    echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | \
        sudo tee /etc/apt/sources.list.d/google-cloud-sdk.list
    sudo apt-get update
    sudo apt-get install -y google-cloud-sdk
    
    echo "✅ gcloud installed!"
    echo ""
fi

# Authenticate
echo "🔑 Authenticating with Google Cloud..."
gcloud auth application-default login

# List projects
echo ""
echo "📋 Available GCP Projects:"
gcloud projects list --format="table(projectId,name)" --limit=20

# Get project ID
echo ""
read -p "Enter your GCP Project ID: " PROJECT_ID

# Set project
gcloud config set project $PROJECT_ID

# Get region
echo ""
echo "Available regions for Vertex AI:"
echo "  us-central1 (Iowa)"
echo "  us-east5 (Ohio)"
echo "  europe-west1 (Belgium)"
echo "  asia-northeast1 (Tokyo)"
read -p "Enter region (default: us-central1): " REGION
REGION=${REGION:-us-central1}

# Enable Vertex AI API
echo ""
echo "🔧 Enabling Vertex AI API..."
gcloud services enable aiplatform.googleapis.com --project=$PROJECT_ID

# Update .env
ENV_FILE="$HOME/.env"
echo ""
echo "📝 Updating $ENV_FILE..."

# Remove old commented lines
sed -i '/^# Claude Code - Google Vertex AI/,/^# CLOUD_ML_REGION/d' $ENV_FILE

# Add new config
cat >> $ENV_FILE << EOF

# ============================================
# Google Cloud / Vertex AI Configuration
# ============================================
GOOGLE_CLOUD_PROJECT=$PROJECT_ID
GOOGLE_CLOUD_REGION=$REGION
GOOGLE_APPLICATION_CREDENTIALS=~/.config/gcloud/application_default_credentials.json

# Claude Code - Vertex AI Backend
CLAUDE_CODE_USE_VERTEX=1
ANTHROPIC_VERTEX_PROJECT_ID=$PROJECT_ID
CLOUD_ML_REGION=$REGION
EOF

echo "✅ Updated $ENV_FILE"

echo ""
echo "====================================="
echo "✅ Setup Complete!"
echo "====================================="
echo ""
echo "Project: $PROJECT_ID"
echo "Region:  $REGION"
echo ""
echo "🚀 Launch Claude Code with:"
echo "   source ~/.env && claude"
echo ""
echo "📋 On first run, select:"
echo "   1. '3rd-party platform'"
echo "   2. 'Vertex AI'"
echo ""
echo "====================================="
