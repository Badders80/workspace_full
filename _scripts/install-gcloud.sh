#!/bin/bash
# Stage 1: Google Cloud SDK Installation (Foundation)
# Run this first to establish Google-first tooling baseline

set -e

echo "🚀 Stage 1: Installing Google Cloud SDK Foundation"
echo "=================================================="
echo ""

# Detect OS
if [[ -f /etc/os-release ]]; then
    . /etc/os-release
    OS=$ID
else
    echo "❌ Cannot detect OS"
    exit 1
fi

echo "📦 Detected OS: $OS"
echo ""

# Check if gcloud already installed
if command -v gcloud &> /dev/null; then
    echo "✅ gcloud already installed:"
    gcloud --version | head -1
    echo ""
    read -p "Reinstall/update? (y/N): " update
    if [[ ! $update =~ ^[Yy]$ ]]; then
        echo "Skipping installation."
        exit 0
    fi
fi

echo "🔧 Installing Google Cloud SDK..."
echo ""

case $OS in
    ubuntu|debian)
        # Add Google Cloud SDK apt repository
        sudo apt-get update
        sudo apt-get install -y apt-transport-https ca-certificates gnupg curl
        
        # Add repo key
        curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | \
            sudo gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg
        
        # Add repo
        echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | \
            sudo tee /etc/apt/sources.list.d/google-cloud-sdk.list
        
        # Install
        sudo apt-get update
        sudo apt-get install -y google-cloud-sdk google-cloud-sdk-gke-gcloud-auth-plugin
        ;;
        
    fedora|rhel|centos)
        sudo tee /etc/yum.repos.d/google-cloud-sdk.repo << EOL
[google-cloud-cli]
name=Google Cloud CLI
baseurl=https://packages.cloud.google.com/yum/repos/cloud-sdk-el8-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=0
gpgkey=https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOL
        sudo dnf install -y google-cloud-sdk
        ;;
        
    *)
        echo "❌ Unsupported OS: $OS"
        echo "Install manually: https://cloud.google.com/sdk/docs/install"
        exit 1
        ;;
esac

echo ""
echo "✅ Google Cloud SDK installed!"
echo ""

# Initialize gcloud
echo "🔑 Initializing gcloud..."
gcloud init --skip-diagnostics || true

echo ""
echo "📊 Installation complete!"
echo ""
gcloud --version | head -3

echo ""
echo "=================================================="
echo "📝 Next: Run Stage 2 to configure services"
echo "   ~/_scripts/setup-google-services.sh"
echo "=================================================="
