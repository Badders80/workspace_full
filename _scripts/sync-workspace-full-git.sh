#!/usr/bin/env bash
#
# Broad workspace -> Git repository snapshot for agent tooling.
# Default mode is dry-run; use --apply to commit and push.

set -euo pipefail

APPLY=0
SOURCE_ROOT_OVERRIDE=""
REMOTE_URL_OVERRIDE=""
EXPORT_REPO="${EXPORT_REPO:-/home/evo/.cache/workspace-full-export}"
BRANCH="${BRANCH:-main}"
COMMIT_MESSAGE_OVERRIDE=""
SAMPLE_LIMIT=40
MAX_FILE_SIZE_MB="${MAX_FILE_SIZE_MB:-95}"

PRUNE_DIR_NAMES=(
  ".git"
)

EXCLUDE_PATHS=(
  "_reference/"
  "DNA/vault/archive/"
  "gateways/openclaw/workspace/workspace-gateway-*/"
)

MEDIA_EXTENSIONS=(
  "*.mp3"
  "*.mp4"
  "*.jpg"
  "*.jpeg"
  "*.png"
  "*.gif"
  "*.webp"
  "*.svg"
  "*.mov"
  "*.wav"
)

SECRET_PATTERNS=(
  ".env"
  "**/.env"
  ".env.*"
  "**/.env.*"
  "*.pem"
  "*.key"
  "*.p12"
  "*.pfx"
  "*.crt"
  "*service-account*.json"
  "credentials*.json"
)

usage() {
  cat <<'EOF'
Usage:
  sync-workspace-full-git.sh [--dry-run] [--apply]
                             [--source-root PATH]
                             [--remote-url URL]
                             [--export-repo PATH]
                             [--branch NAME]
                             [--commit-message MESSAGE]
                             [--sample-limit N]
                             [--max-file-size-mb N]

Options:
  --dry-run                Simulate only (default).
  --apply                  Export, commit, and push the workspace snapshot.
  --source-root PATH       Override workspace source root. Default: /home/evo/workspace
  --remote-url URL         Git remote for the export repo. Required unless set by env.
  --export-repo PATH       Local cached repo for the broad snapshot workflow.
                           Default: /home/evo/.cache/workspace-full-export
  --branch NAME            Target branch. Default: main
  --commit-message MSG     Commit message to use in apply mode.
  --sample-limit N         Number of sample files to print in dry-run mode.
  --max-file-size-mb N     Delete files larger than this before git add.
                           Default: 95
  -h, --help               Show this help.

Snapshot scope:
  - Includes as much of the workspace as GitHub will accept
  - Excludes nested .git directories, media assets, secret-shaped files,
    and files above the configured size limit
EOF
}

fail() { printf 'ERROR: %s\n' "$*" >&2; exit 1; }
log()  { printf '%s\n' "$*"; }

need_cmd() {
  command -v "$1" >/dev/null 2>&1 || fail "Required command not found: $1"
}

resolve_source_root() {
  if [[ -n "$SOURCE_ROOT_OVERRIDE" ]]; then
    [[ -d "$SOURCE_ROOT_OVERRIDE" ]] || fail "--source-root path does not exist: $SOURCE_ROOT_OVERRIDE"
    printf '%s\n' "$SOURCE_ROOT_OVERRIDE"
    return
  fi

  [[ -d "/home/evo/workspace" ]] || fail "Cannot resolve workspace root. Use --source-root PATH."
  printf '%s\n' "/home/evo/workspace"
}

resolve_remote_url() {
  [[ -n "$REMOTE_URL_OVERRIDE" ]] || fail "Remote URL required. Use --remote-url URL."
  printf '%s\n' "$REMOTE_URL_OVERRIDE"
}

build_rsync_excludes() {
  local pattern

  for pattern in "${PRUNE_DIR_NAMES[@]}"; do
    printf '%s\n' "$pattern/"
  done

  for pattern in "${EXCLUDE_PATHS[@]}"; do
    printf '%s\n' "$pattern"
  done

  for pattern in "${MEDIA_EXTENSIONS[@]}"; do
    printf '%s\n' "$pattern"
  done

  for pattern in "${SECRET_PATTERNS[@]}"; do
    printf '%s\n' "$pattern"
  done
}

prune_excluded_export_paths() {
  local export_root="$1"

  rm -rf "${export_root}/DNA/vault/archive"
  rm -rf "${export_root}"/gateways/openclaw/workspace/workspace-gateway-*
}

build_export_manifest() {
  local export_root="$1"
  local source_root="$2"
  local total_files="$3"
  local payload_size="$4"
  local oversized_removed="$5"

  cat > "${export_root}/WORKSPACE_FULL_MANIFEST.md" <<EOF
# Workspace Full Snapshot

Generated: $(date -u +"%Y-%m-%d %H:%M:%S UTC")
Source root: \`${source_root}\`
Mode: broad GitHub-safe workspace snapshot for agent tooling

## Purpose

This repository is the broadest practical export of the live workspace for remote agent tooling and investigation. It is intentionally wider than the curated analysis mirror.

## Included

- The live workspace content copied from the canonical root
- Project and gateway source trees with nested repository contents preserved as files
- Local dependency installs and generated code when they fit inside GitHub constraints

## Excluded

- Nested \`.git/\` directories
- Vault archives and runtime gateway workspace snapshots
- Secret-shaped files such as local env files, keys, certs, and credential JSON
- Media assets such as \`.mp3\`, \`.mp4\`, \`.jpg\`, \`.jpeg\`, \`.png\`, \`.gif\`, \`.webp\`, \`.svg\`, \`.mov\`, and \`.wav\`
- Files larger than ${MAX_FILE_SIZE_MB} MB

## Snapshot

- Selected files: ${total_files}
- Approx payload size: ${payload_size}
- Oversized files removed: ${oversized_removed}
EOF
}

is_known_sample_secret_file() {
  local rel="$1"

  case "$rel" in
    gateways/hermes-agent/repo/agent/redact.py|\
    gateways/hermes-agent/repo/tests/agent/test_redact.py|\
    gateways/hermes-agent/repo/tests/tools/test_mcp_tool.py|\
    gateways/hermes-agent/repo/tests/tools/test_skills_guard.py|\
    gateways/hermes-agent/repo/skills/mcp/native-mcp/SKILL.md)
      return 0
      ;;
  esac

  return 1
}

should_scan_file_for_secrets() {
  local rel="$1"
  local base="${rel##*/}"
  local base_lower="${base,,}"

  case "$rel" in
    _reference/*|\
    */node_modules/*|\
    */venv/*|\
    */.venv/*|\
    */site-packages/*)
      return 1
      ;;
  esac

  case "$base_lower" in
    .env.example|.env.sample|.env.template)
      return 1
      ;;
    *.so|*.dll|*.dylib|*.a|*.o|*.pyc)
      return 1
      ;;
  esac

  return 0
}

scan_for_potential_secrets() {
  local export_root="$1"
  local file findings=0 line rel

  while IFS= read -r -d '' file; do
    rel="${file#${export_root}/}"
    is_known_sample_secret_file "$rel" && continue
    should_scan_file_for_secrets "$rel" || continue

    while IFS= read -r line; do
      case "${line,,}" in
        *replace-with*|*your-*|*example*|*sample*|*template*|*placeholder*)
          continue
          ;;
      esac

      if [[ "$line" =~ AUTH_TOKEN=[A-Za-z0-9._-]{16,} ]] || \
         [[ "$line" =~ ghp_[A-Za-z0-9]{20,} ]] || \
         [[ "$line" =~ github_pat_[A-Za-z0-9_]{20,} ]] || \
         [[ "$line" =~ sk-[A-Za-z0-9]{20,} ]] || \
         [[ "$line" =~ AIza[0-9A-Za-z_-]{20,} ]] || \
         [[ "$line" =~ -----BEGIN[[:space:]][A-Z[:space:]]+PRIVATE[[:space:]]KEY----- ]]; then
        log "Potential secret detected in export: ${rel}"
        findings=$((findings + 1))
        break
      fi
    done < "$file"
  done < <(find "$export_root" -type f -print0)

  [[ "$findings" -eq 0 ]] || fail "Potential secrets remain in the workspace-full export."
}

ensure_export_repo() {
  local export_repo="$1"
  local remote_url="$2"
  local branch="$3"

  mkdir -p "$(dirname "$export_repo")"

  if [[ -d "${export_repo}/.git" ]]; then
    if git -C "$export_repo" remote get-url origin >/dev/null 2>&1; then
      git -C "$export_repo" remote set-url origin "$remote_url"
    else
      git -C "$export_repo" remote add origin "$remote_url"
    fi
    git -C "$export_repo" fetch origin --prune >/dev/null 2>&1 || true
  else
    rm -rf "$export_repo"
    mkdir -p "$export_repo"
    git -C "$export_repo" init -b "$branch" >/dev/null
    git -C "$export_repo" remote add origin "$remote_url"
  fi

  if git -C "$export_repo" show-ref --verify --quiet "refs/remotes/origin/${branch}"; then
    git -C "$export_repo" checkout -B "$branch" "origin/${branch}" >/dev/null 2>&1
  else
    git -C "$export_repo" checkout -B "$branch" >/dev/null 2>&1
  fi
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run) APPLY=0 ;;
    --apply) APPLY=1 ;;
    --source-root) shift; SOURCE_ROOT_OVERRIDE="${1:-}" ;;
    --remote-url) shift; REMOTE_URL_OVERRIDE="${1:-}" ;;
    --export-repo) shift; EXPORT_REPO="${1:-}" ;;
    --branch) shift; BRANCH="${1:-}" ;;
    --commit-message) shift; COMMIT_MESSAGE_OVERRIDE="${1:-}" ;;
    --sample-limit) shift; SAMPLE_LIMIT="${1:-}" ;;
    --max-file-size-mb) shift; MAX_FILE_SIZE_MB="${1:-}" ;;
    -h|--help) usage; exit 0 ;;
    *) fail "Unknown argument: $1 (run with --help)" ;;
  esac
  shift
done

[[ "$SAMPLE_LIMIT" =~ ^[0-9]+$ ]] || fail "--sample-limit must be a non-negative integer"
[[ "$MAX_FILE_SIZE_MB" =~ ^[0-9]+$ ]] || fail "--max-file-size-mb must be a non-negative integer"

need_cmd find
need_cmd git
need_cmd rsync
need_cmd du

SOURCE_ROOT="$(resolve_source_root)"
REMOTE_URL="$(resolve_remote_url)"

TMP_EXCLUDES="$(mktemp)"
TMP_OVERSIZED="$(mktemp)"
cleanup() {
  rm -f "$TMP_EXCLUDES" "$TMP_OVERSIZED"
}
trap cleanup EXIT

build_rsync_excludes > "$TMP_EXCLUDES"
ensure_export_repo "$EXPORT_REPO" "$REMOTE_URL" "$BRANCH"

rsync -a --delete --delete-excluded --exclude-from="$TMP_EXCLUDES" "${SOURCE_ROOT}/" "${EXPORT_REPO}/"
prune_excluded_export_paths "${EXPORT_REPO}"

find "${EXPORT_REPO}" -type f -size +"${MAX_FILE_SIZE_MB}"M -print | sort > "$TMP_OVERSIZED"
if [[ -s "$TMP_OVERSIZED" ]]; then
  while IFS= read -r file; do
    rm -f "$file"
  done < "$TMP_OVERSIZED"
fi

TOTAL_FILES="$(find "${EXPORT_REPO}" -type f | wc -l | awk '{print $1}')"
PAYLOAD_SIZE="$(du -sh "${EXPORT_REPO}" | awk '{print $1}')"
OVERSIZED_REMOVED="$(wc -l < "$TMP_OVERSIZED" | awk '{print $1}')"
build_export_manifest "$EXPORT_REPO" "$SOURCE_ROOT" "$TOTAL_FILES" "$PAYLOAD_SIZE" "$OVERSIZED_REMOVED"
scan_for_potential_secrets "$EXPORT_REPO"

log "Mode:            $([[ "$APPLY" -eq 1 ]] && printf 'APPLY' || printf 'DRY-RUN')"
log "Source root:     $SOURCE_ROOT"
log "Remote URL:      $REMOTE_URL"
log "Export repo:     $EXPORT_REPO"
log "Branch:          $BRANCH"
log "Max file size:   ${MAX_FILE_SIZE_MB} MB"
log "Files:           $TOTAL_FILES"
log "Payload:         $PAYLOAD_SIZE"
log "Oversized drop:  $OVERSIZED_REMOVED"
log

if [[ "$SAMPLE_LIMIT" -gt 0 ]]; then
  log "Sample files:"
  find "${EXPORT_REPO}" -type f | sed "s#^${EXPORT_REPO}/##" | sort | sed -n "1,${SAMPLE_LIMIT}p" | sed 's/^/  - /'
  log
fi

if [[ -s "$TMP_OVERSIZED" ]]; then
  log "Oversized files removed:"
  sed "s#^${EXPORT_REPO}/#  - #g" "$TMP_OVERSIZED"
  log
fi

if [[ "$APPLY" -ne 1 ]]; then
  log "Dry-run only. Re-run with --apply to commit and push the snapshot."
  exit 0
fi

git -C "$EXPORT_REPO" add -A

if git -C "$EXPORT_REPO" diff --cached --quiet; then
  log "Export repo already up to date."
  exit 0
fi

COMMIT_MESSAGE="${COMMIT_MESSAGE_OVERRIDE:-Update workspace full snapshot $(date -u +"%Y-%m-%d %H:%M UTC")}"

git -C "$EXPORT_REPO" -c core.hooksPath=/dev/null commit -m "$COMMIT_MESSAGE" >/dev/null
git -C "$EXPORT_REPO" push -u origin "$BRANCH"

log
log "Workspace full snapshot pushed successfully."
log "Commit: $(git -C "$EXPORT_REPO" rev-parse --short HEAD)"
