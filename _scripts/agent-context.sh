#!/bin/bash
set -euo pipefail

WORKSPACE_ROOT="/home/evo/workspace"
WORKSPACE_AI_BOOTSTRAP="$WORKSPACE_ROOT/AI_SESSION_BOOTSTRAP.md"
WORKSPACE_AGENTS="$WORKSPACE_ROOT/AGENTS.md"
WORKSPACE_DNA_AGENTS="$WORKSPACE_ROOT/DNA/AGENTS.md"
WORKSPACE_AI_CONTEXT="$WORKSPACE_ROOT/DNA/agents/AI_CONTEXT.md"
WORKSPACE_CONVENTIONS="$WORKSPACE_ROOT/DNA/ops/CONVENTIONS.md"
WORKSPACE_STACK="$WORKSPACE_ROOT/DNA/ops/STACK.md"
WORKSPACE_TRANSITION="$WORKSPACE_ROOT/DNA/ops/TRANSITION.md"
WORKSPACE_INBOX="$WORKSPACE_ROOT/DNA/INBOX.md"
WORKSPACE_DECISIONS="$WORKSPACE_ROOT/DNA/ops/DECISION_LOG.md"
WORKSPACE_TECH_RADAR="$WORKSPACE_ROOT/DNA/ops/TECH_RADAR.md"
WORKSPACE_MEMORY_PROTOCOL="$WORKSPACE_ROOT/DNA/agents/MEMORY_PROTOCOL.md"
WORKSPACE_MERGE_PLAN="$WORKSPACE_ROOT/_docs/MERGE_PLAN_2026-03-10.md"

workspace_context_files() {
  cat <<'EOF'
/home/evo/workspace/AI_SESSION_BOOTSTRAP.md
/home/evo/workspace/AGENTS.md
/home/evo/workspace/DNA/AGENTS.md
/home/evo/workspace/DNA/agents/AI_CONTEXT.md
/home/evo/workspace/DNA/ops/CONVENTIONS.md
/home/evo/workspace/DNA/ops/STACK.md
/home/evo/workspace/DNA/ops/TRANSITION.md
/home/evo/workspace/DNA/INBOX.md
/home/evo/workspace/DNA/ops/DECISION_LOG.md
EOF
}

workspace_context_prompt() {
  cat <<'EOF'
MANDATORY: Read these workspace files before responding:

1. /home/evo/workspace/AI_SESSION_BOOTSTRAP.md
2. /home/evo/workspace/AGENTS.md
3. /home/evo/workspace/DNA/AGENTS.md
4. /home/evo/workspace/DNA/agents/AI_CONTEXT.md
5. /home/evo/workspace/DNA/ops/CONVENTIONS.md
6. /home/evo/workspace/DNA/ops/STACK.md
7. /home/evo/workspace/DNA/ops/TRANSITION.md
8. /home/evo/workspace/DNA/INBOX.md
9. /home/evo/workspace/DNA/ops/DECISION_LOG.md

Treat /home/evo/workspace as canonical.
Treat /home/evo as control plane only.
Prefer workspace paths over any older /home/evo paths.
Consult /home/evo/workspace/DNA/ops/TECH_RADAR.md on demand only for prior tool evaluation notes.
Summarize what you learned before continuing.
EOF
}

workspace_render_context_bundle() {
  local file

  printf '# Evolution Workspace Context\n\n'
  printf 'Generated: %s\n\n' "$(date -Iseconds)"

  while IFS= read -r file; do
    printf '## %s\n\n' "$file"
    if [ -f "$file" ]; then
      cat "$file"
    else
      printf 'MISSING: %s\n' "$file"
    fi
    printf '\n\n'
  done < <(workspace_context_files)
}

workspace_prepare_google_adc() {
  unset GEMINI_API_KEY GOOGLE_API_KEY

  export GOOGLE_CLOUD_PROJECT="${GOOGLE_CLOUD_PROJECT:-evolution-engine}"
  export GOOGLE_CLOUD_LOCATION="${GOOGLE_CLOUD_LOCATION:-${GOOGLE_CLOUD_REGION:-us-central1}}"
  export GOOGLE_CLOUD_REGION="${GOOGLE_CLOUD_REGION:-$GOOGLE_CLOUD_LOCATION}"
  export GOOGLE_APPLICATION_CREDENTIALS="${GOOGLE_APPLICATION_CREDENTIALS:-/home/evo/.config/gcloud/application_default_credentials.json}"
  export GOOGLE_GENAI_USE_VERTEXAI="${GOOGLE_GENAI_USE_VERTEXAI:-1}"
  export GEMINI_DEFAULT_AUTH_TYPE="${GEMINI_DEFAULT_AUTH_TYPE:-vertex-ai}"
  export GEMINI_CLI_SYSTEM_SETTINGS_PATH="${GEMINI_CLI_SYSTEM_SETTINGS_PATH:-/home/evo/.config/evo/gemini-system-settings.json}"
}

workspace_check_gcloud_adc() {
  command -v gcloud >/dev/null 2>&1 || return 1
  gcloud auth application-default print-access-token >/dev/null 2>&1
}
