# Google-First Tooling Strategy

Two-stage implementation for Google Cloud SDK and service integrations.

## Overview

Standardizing on Google Cloud infrastructure for:
- **AI/LLM APIs** → Vertex AI (Claude, Gemini, etc.)
- **Authentication** → Google OAuth / Service Accounts
- **Project Management** → GCP Projects with unified billing
- **Future integrations** → BigQuery, Cloud Storage, Pub/Sub, etc.

---

## Stage 1: Foundation

Installs Google Cloud SDK (gcloud CLI).

```bash
~/_scripts/install-gcloud.sh
```

**What it does:**
- Detects OS (Ubuntu/Debian/Fedora/RHEL)
- Installs Google Cloud SDK
- Runs `gcloud init` for initial setup

**Prerequisites:**
- Google Cloud account
- Existing GCP project (or create one during init)

---

## Stage 2: Service Configuration

Configures individual services to use Google backends.

```bash
~/_scripts/setup-google-services.sh
```

**What it does:**
- Authenticates with application-default credentials
- Sets default project and region
- Updates `~/.env` with Google configuration
- Configures Claude Code for Vertex AI
- Creates helper scripts (`google-project` switcher)

---

## Current Service Matrix

| Service | Google Backend | Status | Notes |
|---------|---------------|--------|-------|
| Claude Code | Vertex AI | ✅ Ready | `CLAUDE_CODE_USE_VERTEX=1` |
| Gemini | Vertex AI | ✅ Native | Already Google |
| gcloud CLI | N/A | ✅ Ready | Core tooling |

---

## Helper Commands

```bash
# Switch GCP projects
google-project                    # List available
google-project my-project-id      # Switch to project

# View current config
gcloud config list

# Auth management
gcloud auth application-default login
gcloud auth list
```

---

## Environment Variables

Added to `~/.env`:

```bash
GOOGLE_CLOUD_PROJECT=<project-id>
GOOGLE_CLOUD_REGION=us-central1
GOOGLE_APPLICATION_CREDENTIALS=~/.config/gcloud/application_default_credentials.json

CLAUDE_CODE_USE_VERTEX=1
ANTHROPIC_VERTEX_PROJECT_ID=<project-id>
CLOUD_ML_REGION=us-central1
```

---

## Next Steps

1. **Run Stage 1** if gcloud not installed
2. **Run Stage 2** to configure services
3. **Test Claude Code**: `source ~/.env && claude`
4. Select "3rd-party platform" → "Vertex AI" on first run

---

## Future Integrations

Potential Google services to adopt:

- **Cloud Storage** → Replace local file storage
- **Secret Manager** → Centralized secrets (instead of .env files)
- **Cloud Build** → CI/CD pipelines
- **BigQuery** → Analytics/Logs
- **Pub/Sub** → Event-driven workflows

---

## Troubleshooting

**gcloud not found after install:**
```bash
source ~/.bashrc  # or ~/.zshrc
# Or restart terminal
```

**Auth errors:**
```bash
gcloud auth application-default login
```

**Project not set:**
```bash
gcloud config set project YOUR_PROJECT_ID
```

**Claude Code still asking for login:**
```bash
# Ensure env vars are exported
export $(grep -v '^#' ~/.env | xargs)
claude
```
