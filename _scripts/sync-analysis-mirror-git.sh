#!/usr/bin/env bash
#
# One-way curated workspace -> Git repository mirror for cloud analysis.
# Default mode is dry-run; use --apply to commit and push.

set -euo pipefail

APPLY=0
SOURCE_EVO_OVERRIDE=""
REMOTE_URL_OVERRIDE=""
MIRROR_REPO="${MIRROR_REPO:-/home/evo/.cache/workspace-analysis-mirror}"
BRANCH="${BRANCH:-main}"
COMMIT_MESSAGE_OVERRIDE=""
SAMPLE_LIMIT=40

PRUNE_DIR_NAMES=(
  ".git"
  ".next"
  ".pnpm-store"
  ".venv"
  ".vite"
  "__pycache__"
  "build"
  "coverage"
  "dist"
  "models"
  "node_modules"
  "out"
  "venv"
  "_archive"
  "_locks"
  "_logs"
  "_sandbox"
  ".cache"
  ".idea"
  ".mypy_cache"
  ".openclaw"
  ".parcel-cache"
  ".pytest_cache"
  ".ruff_cache"
  ".turbo"
  ".vercel"
  ".windsurf"
)

usage() {
  cat <<'EOF'
Usage:
  sync-analysis-mirror-git.sh [--dry-run] [--apply]
                              [--source-evo PATH]
                              [--remote-url URL]
                              [--mirror-repo PATH]
                              [--branch NAME]
                              [--commit-message MESSAGE]
                              [--sample-limit N]

Options:
  --dry-run              Simulate only (default).
  --apply                Export, commit, and push the analysis mirror.
  --source-evo PATH      Override workspace source root. Default: /home/evo/workspace
  --remote-url URL       Override the Git remote. Default: source root origin URL.
  --mirror-repo PATH     Local cached clone for the mirror workflow.
                         Default: /home/evo/.cache/workspace-analysis-mirror
  --branch NAME          Target branch. Default: main
  --commit-message MSG   Commit message to use in apply mode.
  --sample-limit N       Number of sample files to print in dry-run mode.
  -h, --help             Show this help.

Mirror scope:
  - Includes the text-first "brains" of the workspace:
      * root-level markdown and key build files
      * DNA/, _docs/, _scripts/, gateways/, projects/
      * source code, build/config files, JSON/YAML/TOML data, and scripts
  - Excludes archives, logs, locks, sandboxes, caches, local env files,
    embedded .git dirs, heavy generated media, and runtime-only state.
EOF
}

fail() { printf 'ERROR: %s\n' "$*" >&2; exit 1; }
log()  { printf '%s\n' "$*"; }

need_cmd() {
  command -v "$1" >/dev/null 2>&1 || fail "Required command not found: $1"
}

resolve_source_root() {
  if [[ -n "$SOURCE_EVO_OVERRIDE" ]]; then
    [[ -d "$SOURCE_EVO_OVERRIDE" ]] || fail "--source-evo path does not exist: $SOURCE_EVO_OVERRIDE"
    printf '%s\n' "$SOURCE_EVO_OVERRIDE"
    return
  fi

  [[ -d "/home/evo/workspace" ]] || fail "Cannot resolve workspace root. Use --source-evo PATH."
  printf '%s\n' "/home/evo/workspace"
}

resolve_remote_url() {
  local source_root="$1"
  local remote_url=""

  if [[ -n "$REMOTE_URL_OVERRIDE" ]]; then
    printf '%s\n' "$REMOTE_URL_OVERRIDE"
    return
  fi

  if git -C "$source_root" rev-parse --git-dir >/dev/null 2>&1; then
    remote_url="$(git -C "$source_root" remote get-url origin 2>/dev/null || true)"
  fi

  [[ -n "$remote_url" ]] || fail "Cannot resolve remote URL from $source_root. Use --remote-url URL."
  printf '%s\n' "$remote_url"
}

is_excluded_path() {
  local rel_lower="$1"

  case "$rel_lower" in
    _archive/*|_locks/*|_logs/*|_sandbox/*|models/*|openclaw_sandbox/*)
      return 0
      ;;
    */.env|*/.env.*|*.pem|*.key|*.p12|*.pfx|*.crt|*:zone.identifier)
      return 0
      ;;
    projects/reel-generator/assets/*|projects/evolution_platform/public/videos/*)
      return 0
      ;;
    gateways/openclaw/workspace/workspace-gateway-*/*)
      return 0
      ;;
  esac

  return 1
}

is_allowed_file() {
  local rel="$1"
  local rel_lower="${rel,,}"
  local base="${rel##*/}"
  local base_lower="${base,,}"

  is_excluded_path "$rel_lower" && return 1

  case "$base_lower" in
    .dockerignore|.editorconfig|.eslintignore|.gitignore|.node-version|.npmrc|.nvmrc|.prettierignore|.prettierrc|.python-version|.tool-versions|.vercelignore|dockerfile|justfile|makefile)
      return 0
      ;;
    .env.example|.env.sample|.env.template)
      return 0
      ;;
  esac

  case "$rel_lower" in
    *.cjs|*.css|*.gql|*.graphql|*.html|*.ini|*.js|*.json|*.jsx|*.md|*.mdx|*.mjs|*.ps1|*.py|*.scss|*.sh|*.sql|*.toml|*.ts|*.tsx|*.yaml|*.yml)
      return 0
      ;;
  esac

  return 1
}

collect_root_files() {
  local source_root="$1"
  local f rel

  while IFS= read -r f; do
    rel="${f#${source_root}/}"
    is_allowed_file "$rel" && printf '%s\n' "$rel"
  done < <(find "$source_root" -maxdepth 1 -type f | sort)

  return 0
}

collect_tree_files() {
  local source_root="$1"
  local subtree="$2"
  local f rel first=1 prune_cmd=()
  local subtree_root="${source_root}/${subtree}"

  [[ -d "$subtree_root" ]] || return 0

  prune_cmd=(find "$subtree_root" "(" -type d "(")
  for dir_name in "${PRUNE_DIR_NAMES[@]}"; do
    [[ $first -eq 1 ]] && first=0 || prune_cmd+=(-o)
    prune_cmd+=(-name "$dir_name")
  done
  prune_cmd+=(")" -prune ")" -o "(" -type f -print ")")

  while IFS= read -r f; do
    rel="${f#${source_root}/}"
    is_allowed_file "$rel" && printf '%s\n' "$rel"
  done < <("${prune_cmd[@]}" | sort)

  return 0
}

build_export_manifest() {
  local export_root="$1"
  local source_root="$2"
  local total_files="$3"
  local payload_size="$4"

  cat > "${export_root}/MIRROR_MANIFEST.md" <<EOF
# Workspace Analysis Mirror

Generated: $(date -u +"%Y-%m-%d %H:%M:%S UTC")
Source root: \`${source_root}\`
Mode: curated one-way Git mirror for cloud analysis

## Purpose

This repository is the text-first operating mirror of the active workspace. It is intended to give cloud-based AI tools the logic, contracts, scripts, and build surface of the system without dragging along archives, dependency installs, generated media, or local runtime state.

## Included

- Root-level markdown plus key build and control files
- \`DNA/\`, \`_docs/\`, \`_scripts/\`, \`gateways/\`, and \`projects/\`
- Source code, scripts, build/config files, and text-based data such as JSON, YAML, TOML, HTML, and SQL

## Excluded

- \`_archive/\`, \`_logs/\`, \`_locks/\`, \`_sandbox/\`, \`models/\`, and \`gateways/openclaw/sandbox/\`
- Dependency installs and build output such as \`node_modules/\`, \`.next/\`, \`dist/\`, and \`build/\`
- Local env and credential-shaped files
- Runtime-only state such as \`.openclaw/\`
- Runtime gateway snapshots such as \`gateways/openclaw/workspace/workspace-gateway-*/\`
- Heavy generated media such as \`projects/reel-generator/assets/\` and \`projects/Evolution_Platform/public/videos/\`

## Snapshot

- Selected files: ${total_files}
- Approx payload size: ${payload_size}
EOF
}

scan_for_potential_secrets() {
  local export_root="$1"
  local file findings=0 line

  while IFS= read -r -d '' file; do
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
        log "Potential secret detected in export: ${file#${export_root}/}"
        findings=$((findings + 1))
        break
      fi
    done < "$file"
  done < <(find "$export_root" -type f -print0)

  [[ "$findings" -eq 0 ]] || fail "Potential secrets remain in the analysis mirror export."
}

ensure_mirror_repo() {
  local mirror_repo="$1"
  local remote_url="$2"
  local branch="$3"

  mkdir -p "$(dirname "$mirror_repo")"

  if [[ -d "${mirror_repo}/.git" ]]; then
    git -C "$mirror_repo" remote set-url origin "$remote_url"
    git -C "$mirror_repo" fetch origin --prune
  else
    rm -rf "$mirror_repo"
    git clone "$remote_url" "$mirror_repo" >/dev/null 2>&1 || {
      mkdir -p "$mirror_repo"
      git -C "$mirror_repo" init >/dev/null
      git -C "$mirror_repo" remote add origin "$remote_url"
      git -C "$mirror_repo" fetch origin --prune >/dev/null 2>&1 || true
    }
  fi

  if git -C "$mirror_repo" show-ref --verify --quiet "refs/remotes/origin/${branch}"; then
    git -C "$mirror_repo" checkout -B "$branch" "origin/${branch}" >/dev/null 2>&1
  else
    git -C "$mirror_repo" checkout -B "$branch" >/dev/null 2>&1
  fi
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run) APPLY=0 ;;
    --apply) APPLY=1 ;;
    --source-evo) shift; SOURCE_EVO_OVERRIDE="${1:-}" ;;
    --remote-url) shift; REMOTE_URL_OVERRIDE="${1:-}" ;;
    --mirror-repo) shift; MIRROR_REPO="${1:-}" ;;
    --branch) shift; BRANCH="${1:-}" ;;
    --commit-message) shift; COMMIT_MESSAGE_OVERRIDE="${1:-}" ;;
    --sample-limit) shift; SAMPLE_LIMIT="${1:-}" ;;
    -h|--help) usage; exit 0 ;;
    *) fail "Unknown argument: $1 (run with --help)" ;;
  esac
  shift
done

[[ "$SAMPLE_LIMIT" =~ ^[0-9]+$ ]] || fail "--sample-limit must be a non-negative integer"

need_cmd find
need_cmd git
need_cmd rsync
need_cmd sort
need_cmd du

SOURCE_EVO="$(resolve_source_root)"
REMOTE_URL="$(resolve_remote_url "$SOURCE_EVO")"

TMP_LIST="$(mktemp)"
TMP_EXPORT="$(mktemp -d)"
cleanup() {
  rm -f "$TMP_LIST"
  rm -rf "$TMP_EXPORT"
}
trap cleanup EXIT

collect_root_files "$SOURCE_EVO" >> "$TMP_LIST"
collect_tree_files "$SOURCE_EVO" "DNA" >> "$TMP_LIST"
collect_tree_files "$SOURCE_EVO" "_docs" >> "$TMP_LIST"
collect_tree_files "$SOURCE_EVO" "_scripts" >> "$TMP_LIST"
collect_tree_files "$SOURCE_EVO" "gateways" >> "$TMP_LIST"
collect_tree_files "$SOURCE_EVO" "projects" >> "$TMP_LIST"
sort -u "$TMP_LIST" -o "$TMP_LIST"

TOTAL_FILES="$(wc -l < "$TMP_LIST" | awk '{print $1}')"
[[ "$TOTAL_FILES" -gt 0 ]] || fail "No files selected for the analysis mirror."

mkdir -p "$TMP_EXPORT"
rsync -a --files-from="$TMP_LIST" "${SOURCE_EVO}/" "${TMP_EXPORT}/"

PAYLOAD_SIZE="$(du -sh "$TMP_EXPORT" | awk '{print $1}')"
build_export_manifest "$TMP_EXPORT" "$SOURCE_EVO" "$TOTAL_FILES" "$PAYLOAD_SIZE"
scan_for_potential_secrets "$TMP_EXPORT"

log "Mode:        $([[ "$APPLY" -eq 1 ]] && printf 'APPLY' || printf 'DRY-RUN')"
log "Source root: $SOURCE_EVO"
log "Remote URL:  $REMOTE_URL"
log "Mirror repo: $MIRROR_REPO"
log "Branch:      $BRANCH"
log "Files:       $TOTAL_FILES"
log "Payload:     $PAYLOAD_SIZE"
log

if [[ "$SAMPLE_LIMIT" -gt 0 ]]; then
  log "Sample files:"
  sed -n "1,${SAMPLE_LIMIT}p" "$TMP_LIST" | sed 's/^/  - /'
  log
fi

if [[ "$APPLY" -ne 1 ]]; then
  log "Dry-run only. Re-run with --apply to commit and push the mirror."
  exit 0
fi

ensure_mirror_repo "$MIRROR_REPO" "$REMOTE_URL" "$BRANCH"
rsync -a --delete --exclude=.git/ "${TMP_EXPORT}/" "${MIRROR_REPO}/"

if [[ -z "$(git -C "$MIRROR_REPO" status --short)" ]]; then
  log "Mirror repo already up to date."
  exit 0
fi

git -C "$MIRROR_REPO" add -A

COMMIT_MESSAGE="${COMMIT_MESSAGE_OVERRIDE:-Update workspace analysis mirror $(date -u +"%Y-%m-%d %H:%M UTC")}"

git -C "$MIRROR_REPO" -c core.hooksPath=/dev/null commit -m "$COMMIT_MESSAGE" >/dev/null
git -C "$MIRROR_REPO" push -u origin "$BRANCH"

log
log "Analysis mirror pushed successfully."
log "Commit: $(git -C "$MIRROR_REPO" rev-parse --short HEAD)"
