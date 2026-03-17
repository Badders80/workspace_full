#!/usr/bin/env bash
#
# RETIRED: Google Docs markdown sync left the active workspace model on 2026-03-16.
# Google Drive is assets only. Keep this script for historical reference or diagnostics only.
# Do not treat it as part of the live agent context chain or active automation surface.
#
# One-way workspace Markdown -> native Google Docs mirror (incremental).
# Updated: 2026-03-14 — expanded to root workspace docs plus DNA/ and projects/ markdown
#
# Safety guarantees:
# - Reads local sources only.
# - Apply mode uploads/updates selected files only.
# - Remote deletes only happen in explicit --prune-stale mode for managed workspace docs.

set -euo pipefail

APPLY=0
VERIFY=0
PRUNE_STALE=0
SAMPLE_LIMIT=20
REMOTE_ROOT="${REMOTE_ROOT:-gdrive:_evo-context/_gdocs-key}"
STATE_FILE="${STATE_FILE:-/home/evo/.cache/sync-md-context-gdocs.state.tsv}"
LOCK_FILE="${LOCK_FILE:-}"
UPLOAD_DELAY_SECONDS="${UPLOAD_DELAY_SECONDS:-1}"
RCLONE_TPSLIMIT="${RCLONE_TPSLIMIT:-1}"
SOURCE_EVO_OVERRIDE=""

EXCLUDED_DIRS=(
  ".git"
  "node_modules"
  ".venv"
  "venv"
  "dist"
  "build"
  ".next"
  "coverage"
  ".local"
  ".npm"
  ".npm-global"
  ".cache"
  ".bun"
  ".vscode-server"
  ".antigravity-server"
  ".gemini"
  ".openfang"
  ".codex"
  ".Trash"
  "_archive"
  "_logs"
  "_locks"
  "_sandbox"
)

usage() {
  cat <<'EOF'
Usage:
  sync-md-context-gdocs.sh [--dry-run] [--apply] [--verify] [--prune-stale] [--sample-limit N]
                           [--remote-root RCLONE_REMOTE_PATH] [--source-evo PATH]
                           [--lock-file PATH]

Options:
  --dry-run              Simulate only (default).
  --apply                Perform uploads.
  --verify               Compare selected local docs against the remote mirror without uploading.
  --prune-stale          Delete stale remote docs under the managed workspace mirror.
  --sample-limit N       Number of sample mappings to print (default: 20).
  --remote-root PATH     Rclone remote destination root.
                         Default: gdrive:_evo-context/_gdocs-key
  --source-evo PATH      Override workspace source root.
                         Default: /home/evo/workspace
  --lock-file PATH       Override the lock file path.
  -h, --help             Show this help.

Behavior:
  - Source root: /home/evo/workspace (canonical post-2026-03-10)
  - Selects current workspace markdown only:
      * Root-level markdown files in /home/evo/workspace
      * Any markdown under DNA/
      * Any markdown under projects/
  - Uploads them as native Google Docs via rclone import.
  - Maintains a local hash state file for incremental updates.
  - Verify mode checks expected remote docs, missing remote docs, and stale remote docs.
  - Prune-stale mode removes only stale remote docs under workspace/.
EOF
}

fail() { printf 'ERROR: %s\n' "$*" >&2; exit 1; }
log()  { printf '%s\n' "$*"; }

need_cmd() {
  command -v "$1" >/dev/null 2>&1 || fail "Required command not found: $1"
}

is_noncurrent_path() {
  local rel_lower="$1"
  [[ "$rel_lower" == _archive/* || "$rel_lower" == */_archive/* || \
     "$rel_lower" == _logs/*    || "$rel_lower" == */_logs/*    || \
     "$rel_lower" == _locks/*   || "$rel_lower" == */_locks/*   || \
     "$rel_lower" == _sandbox/* || "$rel_lower" == */_sandbox/* ]]
}

is_included_markdown_path() {
  local rel="$1"
  local rel_lower="${rel,,}"

  is_noncurrent_path "$rel_lower" && return 1

  [[ "$rel_lower" == *.md ]] || return 1

  if [[ "$rel_lower" != */* ]]; then
    return 0
  fi

  [[ "$rel_lower" == dna/* || "$rel_lower" == projects/* ]]
}

collect_key_files() {
  local label="$1" root="$2"
  local f rel first=1 excluded
  local find_cmd=(find "$root" "(" -type d "(")

  for excluded in "${EXCLUDED_DIRS[@]}"; do
    [[ $first -eq 1 ]] && first=0 || find_cmd+=(-o)
    find_cmd+=(-name "$excluded")
  done
  find_cmd+=(")" -prune ")" -o "(" -type f -iname "*.md" -print ")")

  while IFS= read -r f; do
    rel="${f#${root}/}"
    is_included_markdown_path "$rel" && printf '%s\t%s\t%s\n' "$label" "$f" "$rel"
  done < <("${find_cmd[@]}")
}

# --- Argument parsing ---
while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run)     APPLY=0 ;;
    --apply)       APPLY=1 ;;
    --verify)      VERIFY=1; APPLY=0 ;;
    --prune-stale) PRUNE_STALE=1; VERIFY=1; APPLY=0 ;;
    --sample-limit) shift; SAMPLE_LIMIT="$1" ;;
    --remote-root)  shift; REMOTE_ROOT="$1" ;;
    --source-evo)   shift; SOURCE_EVO_OVERRIDE="$1" ;;
    --lock-file)    shift; LOCK_FILE="$1" ;;
    -h|--help)      usage; exit 0 ;;
    *) fail "Unknown argument: $1 (run with --help)" ;;
  esac
  shift
done

[[ "$SAMPLE_LIMIT" =~ ^[0-9]+$ ]] || fail "--sample-limit must be a non-negative integer"
[[ "$RCLONE_TPSLIMIT" =~ ^[0-9]+([.][0-9]+)?$ ]] || fail "RCLONE_TPSLIMIT must be numeric"

need_cmd rclone
need_cmd find
need_cmd sha256sum
need_cmd awk
need_cmd timeout
need_cmd flock

# Resolve source — workspace is canonical, /home/evo is fallback only
if [[ -n "$SOURCE_EVO_OVERRIDE" ]]; then
  [[ -d "$SOURCE_EVO_OVERRIDE" ]] || fail "--source-evo path does not exist: $SOURCE_EVO_OVERRIDE"
  SOURCE_EVO="$SOURCE_EVO_OVERRIDE"
elif [[ -d "/home/evo/workspace" ]]; then
  SOURCE_EVO="/home/evo/workspace"
else
  fail "Cannot resolve workspace root. Use --source-evo PATH."
fi

if [[ -z "$LOCK_FILE" ]]; then
  LOCK_FILE="${SOURCE_EVO}/_locks/sync-md-context-gdocs.lock"
fi

mkdir -p "$(dirname "$LOCK_FILE")"
exec 9>"$LOCK_FILE"
if ! flock -n 9; then
  fail "Another sync-md-context-gdocs.sh run is already active."
fi

TMP_LIST="$(mktemp)"
TMP_STATE="$(mktemp)"
TMP_REMOTE="$(mktemp)"
TMP_EXPECTED="$(mktemp)"
TMP_WORKDIR="$(mktemp -d)"
cleanup() { rm -f "$TMP_LIST" "$TMP_STATE" "$TMP_REMOTE" "$TMP_EXPECTED"; rm -rf "$TMP_WORKDIR"; }
trap cleanup EXIT

collect_key_files "workspace" "$SOURCE_EVO" >> "$TMP_LIST"
sort -u "$TMP_LIST" -o "$TMP_LIST"

TOTAL_KEYS="$(wc -l <"$TMP_LIST" | awk '{print $1}')"

declare -A PREV_HASH=()
HAVE_STATE_FILE=0
if [[ -f "$STATE_FILE" ]]; then
  HAVE_STATE_FILE=1
  while IFS=$'\t' read -r key hash; do
    [[ -n "${key:-}" && -n "${hash:-}" ]] || continue
    PREV_HASH["$key"]="$hash"
  done <"$STATE_FILE"
fi

declare -A REMOTE_PRESENT=()
REMOTE_LIST_OK=0
if timeout 60s rclone lsf "$REMOTE_ROOT" --recursive --files-only >"$TMP_REMOTE" 2>/dev/null; then
  REMOTE_LIST_OK=1
  while IFS= read -r remote_file; do
    [[ -n "${remote_file}" ]] || continue
    REMOTE_PRESENT["$remote_file"]=1
  done <"$TMP_REMOTE"
fi

if [[ "$VERIFY" -eq 1 && "$REMOTE_LIST_OK" -ne 1 ]]; then
  fail "Verify/prune mode requires a readable remote listing for $REMOTE_ROOT."
fi

declare -A NEW_HASH=()
declare -A EXPECTED_REMOTE=()
UPLOAD_CANDIDATES=0
SKIP_UNCHANGED=0
FAILURES=0
SAMPLE_COUNT=0

if [[ "$APPLY" -eq 1 ]]; then
  mkdir -p "$(dirname "$STATE_FILE")"
  timeout 60s rclone mkdir "$REMOTE_ROOT" >/dev/null
fi

MODE_LABEL="DRY-RUN"
[[ "$APPLY" -eq 1 ]] && MODE_LABEL="APPLY"
[[ "$VERIFY" -eq 1 ]] && MODE_LABEL="VERIFY"
[[ "$PRUNE_STALE" -eq 1 ]] && MODE_LABEL="PRUNE-STALE"

log "Mode:        $MODE_LABEL"
log "Source root: $SOURCE_EVO"
log "Remote root: $REMOTE_ROOT"
log "Total key files selected: $TOTAL_KEYS"
log

while IFS=$'\t' read -r label full_path rel_path; do
  key="${label}/${rel_path}"
  rel_no_ext="${rel_path%.*}"
  remote_rel_path="${label}/${rel_no_ext}.docx"
  remote_doc_path="${REMOTE_ROOT}/${remote_rel_path}"
  EXPECTED_REMOTE["$remote_rel_path"]=1
  printf '%s\n' "$remote_rel_path" >>"$TMP_EXPECTED"
  sha="$(sha256sum "$full_path" | awk '{print $1}')"
  NEW_HASH["$key"]="$sha"

  if [[ "${PREV_HASH[$key]:-}" == "$sha" ]]; then
    SKIP_UNCHANGED=$((SKIP_UNCHANGED + 1))
    if [[ "$VERIFY" -eq 1 && "$SAMPLE_COUNT" -lt "$SAMPLE_LIMIT" && -z "${REMOTE_PRESENT[$remote_rel_path]:-}" ]]; then
      log "  ! missing remote doc: ${remote_rel_path}"
      SAMPLE_COUNT=$((SAMPLE_COUNT + 1))
    fi
    continue
  fi

  UPLOAD_CANDIDATES=$((UPLOAD_CANDIDATES + 1))

  if [[ "$SAMPLE_COUNT" -lt "$SAMPLE_LIMIT" ]]; then
    if [[ "$VERIFY" -eq 1 ]]; then
      if [[ -n "${REMOTE_PRESENT[$remote_rel_path]:-}" ]]; then
        log "  - present remote doc: ${remote_rel_path}"
      else
        log "  ! missing remote doc: ${remote_rel_path}"
      fi
    else
      log "  - ${label}/${rel_path} -> ${remote_doc_path}"
    fi
    SAMPLE_COUNT=$((SAMPLE_COUNT + 1))
  fi

  if [[ "$APPLY" -eq 1 ]]; then
    tmp_txt="${TMP_WORKDIR}/file_${UPLOAD_CANDIDATES}.txt"
    cp "$full_path" "$tmp_txt"

    if ! rclone copyto "$tmp_txt" "$remote_doc_path" \
      --drive-import-formats=txt \
      --drive-allow-import-name-change \
      --checkers 1 \
      --transfers 1 \
      --tpslimit "$RCLONE_TPSLIMIT" \
      --retries 8 \
      --retries-sleep 10s \
      --low-level-retries 10 \
      --contimeout 30s \
      --timeout 180s \
      >/dev/null; then
      FAILURES=$((FAILURES + 1))
      if [[ -n "${PREV_HASH[$key]:-}" ]]; then
        NEW_HASH["$key"]="${PREV_HASH[$key]}"
      else
        unset 'NEW_HASH[$key]'
      fi
      log "    ! upload failed: ${key}"
    else
      REMOTE_PRESENT["$remote_rel_path"]=1
      [[ "$UPLOAD_DELAY_SECONDS" != "0" ]] && sleep "$UPLOAD_DELAY_SECONDS"
    fi
  fi
done <"$TMP_LIST"

log
if [[ "$VERIFY" -eq 1 ]]; then
  EXPECTED_COUNT="$(wc -l <"$TMP_EXPECTED" | awk '{print $1}')"
  REMOTE_MANAGED_COUNT="$(awk 'BEGIN{count=0} /^workspace\// {count++} END{print count}' "$TMP_REMOTE")"
  PENDING_UPDATE_COUNT="$UPLOAD_CANDIDATES"
  MISSING_COUNT=0
  STALE_COUNT=0
  STALE_SAMPLE_COUNT=0
  DELETE_ATTEMPTS=0
  DELETE_FAILURES=0

  while IFS= read -r remote_file; do
    [[ -n "${remote_file}" ]] || continue
    [[ "$remote_file" == workspace/* ]] || continue
    if [[ -z "${EXPECTED_REMOTE[$remote_file]:-}" ]]; then
      STALE_COUNT=$((STALE_COUNT + 1))
      if [[ "$STALE_SAMPLE_COUNT" -lt "$SAMPLE_LIMIT" ]]; then
        log "  ! stale remote doc: ${remote_file}"
        STALE_SAMPLE_COUNT=$((STALE_SAMPLE_COUNT + 1))
      fi
      if [[ "$PRUNE_STALE" -eq 1 ]]; then
        DELETE_ATTEMPTS=$((DELETE_ATTEMPTS + 1))
        if ! timeout 60s rclone deletefile "${REMOTE_ROOT}/${remote_file}" >/dev/null 2>&1; then
          DELETE_FAILURES=$((DELETE_FAILURES + 1))
          log "    ! delete failed: ${remote_file}"
        fi
      fi
    fi
  done <"$TMP_REMOTE"

  while IFS= read -r expected_file; do
    [[ -n "${expected_file}" ]] || continue
    if [[ -z "${REMOTE_PRESENT[$expected_file]:-}" ]]; then
      MISSING_COUNT=$((MISSING_COUNT + 1))
    fi
  done <"$TMP_EXPECTED"

  if [[ "$PRUNE_STALE" -eq 1 ]]; then
    log "Prune summary:"
  else
    log "Verify summary:"
  fi
  log "  expected remote docs:            $EXPECTED_COUNT"
  log "  actual managed remote docs:      $REMOTE_MANAGED_COUNT"
  log "  pending local updates:           $PENDING_UPDATE_COUNT"
  log "  missing remote docs:             $MISSING_COUNT"
  log "  stale remote docs:               $STALE_COUNT"
  if [[ "$PRUNE_STALE" -eq 1 ]]; then
    log "  attempted stale deletions:       $DELETE_ATTEMPTS"
    log "  failed stale deletions:          $DELETE_FAILURES"
  fi
elif [[ "$APPLY" -eq 1 ]]; then
  log "Upload summary:"
  log "  unchanged skipped:               $SKIP_UNCHANGED"
  log "  attempted uploads:               $UPLOAD_CANDIDATES"
  log "  successful uploads:              $((UPLOAD_CANDIDATES - FAILURES))"
  log "  failed uploads:                  $FAILURES"
else
  log "Dry-run summary:"
  log "  unchanged skipped:               $SKIP_UNCHANGED"
  log "  would upload:                    $UPLOAD_CANDIDATES"
fi

if [[ "$APPLY" -eq 1 ]]; then
  : >"$TMP_STATE"
  for key in "${!NEW_HASH[@]}"; do
    printf '%s\t%s\n' "$key" "${NEW_HASH[$key]}" >>"$TMP_STATE"
  done
  sort "$TMP_STATE" -o "$TMP_STATE"
  mv "$TMP_STATE" "$STATE_FILE"
  log "State file updated: $STATE_FILE"
fi

if [[ "$FAILURES" -gt 0 ]]; then
  fail "Completed with upload failures (${FAILURES}). Re-run to retry."
fi

if [[ "$PRUNE_STALE" -eq 1 && "$DELETE_FAILURES" -gt 0 ]]; then
  fail "Completed with stale delete failures (${DELETE_FAILURES}). Re-run to retry."
fi

if [[ "$VERIFY" -eq 1 && "$PRUNE_STALE" -eq 0 && ( "$PENDING_UPDATE_COUNT" -gt 0 || "$MISSING_COUNT" -gt 0 || "$STALE_COUNT" -gt 0 ) ]]; then
  exit 2
fi

if [[ "$PRUNE_STALE" -eq 1 && "$MISSING_COUNT" -gt 0 ]]; then
  exit 2
fi

exit 0
