#!/bin/bash
# Stage 2: Configure Google-First Services
# Run this AFTER Stage 1 (gcloud installed)

set -e

echo "🚀 Stage 2: Configuring Google-First Services"
echo "=============================================="
echo ""

# Check gcloud is installed
if ! command -v gcloud &> /dev/null; then
    echo "❌ gcloud not found. Run Stage 1 first:"
    echo "   ~/_scripts/install-gcloud.sh"
    exit 1
fi

# Source existing env
if [ -f ~/.env ]; then
    export $(grep -v '^#' ~/.env | xargs)
fi

echo "🔑 Ensuring authentication..."
if ! gcloud auth application-default print-access-token &> /dev/null; then
    echo "Authenticating with Google Cloud..."
    gcloud auth application-default login
else
    echo "✅ Already authenticated"
fi

echo ""
echo "📋 GCP Project Configuration"
echo "------------------------------"

# Get current project
CURRENT_PROJECT=$(gcloud config get-value project 2>/dev/null || echo "")

if [ -z "$CURRENT_PROJECT" ]; then
    echo "⚠️  No default project set"
    echo ""
    echo "Available projects:"
    gcloud projects list --format="table(projectId,name)" --limit=10
    echo ""
    read -p "Enter project ID to use: " PROJECT_ID
    gcloud config set project $PROJECT_ID
else
    echo "✅ Current project: $CURRENT_PROJECT"
    read -p "Use this project? (Y/n): " use_current
    if [[ $use_current =~ ^[Nn]$ ]]; then
        gcloud projects list --format="table(projectId,name)" --limit=10
        read -p "Enter project ID: " PROJECT_ID
        gcloud config set project $PROJECT_ID
    else
        PROJECT_ID=$CURRENT_PROJECT
    fi
fi

# Get region
DEFAULT_REGION="us-central1"
read -p "Enter region (default: $DEFAULT_REGION): " REGION
REGION=${REGION:-$DEFAULT_REGION}

echo ""
echo "🔧 Updating configuration files..."
echo "-----------------------------------"

# Update ~/.env
cat >> ~/.env << EOF

# ============================================
# Google Cloud Configuration ($(date +%Y-%m-%d))
# ============================================
GOOGLE_CLOUD_PROJECT=$PROJECT_ID
GOOGLE_CLOUD_REGION=$REGION
GOOGLE_APPLICATION_CREDENTIALS=~/.config/gcloud/application_default_credentials.json

# Claude Code - Vertex AI
CLAUDE_CODE_USE_VERTEX=1
ANTHROPIC_VERTEX_PROJECT_ID=$PROJECT_ID
CLOUD_ML_REGION=$REGION
EOF

echo "✅ Updated ~/.env"

# Update shell profile for persistent access
SHELL_PROFILE=""
if [ -f ~/.bashrc ]; then
    SHELL_PROFILE=~/.bashrc
elif [ -f ~/.zshrc ]; then
    SHELL_PROFILE=~/.zshrc
fi

if [ -n "$SHELL_PROFILE" ]; then
    # Check if already added
    if ! grep -q "GOOGLE_CLOUD_PROJECT" $SHELL_PROFILE; then
        cat >> $SHELL_PROFILE << EOF

# Google Cloud SDK
echo 'source ~/.env 2>/dev/null' >> $SHELL_PROFILE
EOF
        echo "✅ Updated $SHELL_PROFILE"
    fi
fi

# Create helper scripts directory
mkdir -p ~/.local/bin

# Create 'google-project' helper
cat > ~/.local/bin/google-project << 'EOF'
#!/bin/bash
# Quick switcher for Google Cloud projects

if [ -z "$1" ]; then
    echo "Current project: $(gcloud config get-value project)"
    echo ""
    echo "Available projects:"
    gcloud projects list --format="table(projectId,name)" --limit=20
    echo ""
    echo "Usage: google-project <project-id>"
else
    gcloud config set project $1
    # Update .env
    sed -i "s/GOOGLE_CLOUD_PROJECT=.*/GOOGLE_CLOUD_PROJECT=$1/" ~/.env
    sed -i "s/ANTHROPIC_VERTEX_PROJECT_ID=.*/ANTHROPIC_VERTEX_PROJECT_ID=$1/" ~/.env
    echo "✅ Switched to project: $1"
fi
EOF
chmod +x ~/.local/bin/google-project

echo "✅ Created helper: google-project"

echo ""
echo "=============================================="
echo "📊 Configuration Summary"
echo "=============================================="
echo "Project: $PROJECT_ID"
echo "Region:  $REGION"
echo ""
echo "✅ Ready to use Google services:"
echo "   • Claude Code → Vertex AI"
echo "   • gcloud CLI  → Configured"
echo ""
echo "🚀 Test Claude Code:"
echo "   source ~/.env && claude"
echo ""
echo "📝 To switch projects later:"
echo "   google-project <project-id>"
echo "=============================================="
