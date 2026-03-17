# Google Vertex AI Setup - COMPLETION GUIDE

## Quick Finish (Run This)

```bash
# One command to finish everything
~/_scripts/finish-vertex-setup.sh
```

This script will:
1. ✅ Install gcloud CLI (if needed)
2. 🔑 Authenticate with Google Cloud
3. 📋 Show your GCP projects
4. 🔧 Enable Vertex AI API
5. 📝 Update ~/.env with your project ID

---

## Manual Steps (If Script Fails)

### Step 1: Install gcloud
```bash
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | \
    sudo gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg

echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | \
    sudo tee /etc/apt/sources.list.d/google-cloud-sdk.list

sudo apt-get update
sudo apt-get install -y google-cloud-sdk
```

### Step 2: Authenticate
```bash
gcloud auth application-default login
```

### Step 3: Set Project
```bash
# List your projects
gcloud projects list

# Set your project
gcloud config set project YOUR_PROJECT_ID
```

### Step 4: Enable Vertex AI API
```bash
gcloud services enable aiplatform.googleapis.com
```

### Step 5: Update .env
Edit `~/.env` and replace the placeholders:

```bash
# Replace these:
# ANTHROPIC_VERTEX_PROJECT_ID=your-gcp-project-id
# CLOUD_ML_REGION=us-central1

# With your actual values:
ANTHROPIC_VERTEX_PROJECT_ID=your-actual-project-id
CLOUD_ML_REGION=us-central1  # or your preferred region
```

---

## Launch Claude Code

```bash
# Load env vars and launch
source ~/.env && claude
```

**On first run:**
1. Select theme (Dark mode recommended)
2. Choose **"3rd-party platform"**
3. Select **"Vertex AI"**
4. Done! Claude Code now routes through Google Cloud

---

## Verify It's Working

```bash
# Check env vars are set
echo $CLAUDE_CODE_USE_VERTEX
echo $ANTHROPIC_VERTEX_PROJECT_ID

# Check gcloud config
gcloud config list
```

---

## Troubleshooting

**"gcloud not found"**
- Run Step 1 above or the finish script

**"Project not found"**
- Create a GCP project at https://console.cloud.google.com

**"API not enabled"**
- Run: `gcloud services enable aiplatform.googleapis.com`

**Claude Code still asks for login**
- Make sure env vars are exported: `export $(grep -v '^#' ~/.env | xargs)`
- Or restart your terminal

---

## Current Status

| Component | Status |
|-----------|--------|
| gcloud CLI | Needs install |
| Authentication | Pending |
| Vertex AI API | Pending |
| .env configured | Partial (template ready) |
| Claude Code ready | Pending |
