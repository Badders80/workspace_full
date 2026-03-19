#!/usr/bin/env bash

set -Eeuo pipefail

MODE="dry-run"
PRUNE_CACHES=0
PRUNE_S_DRIVE=0

STAMP="$(date +%Y%m%d_%H%M%S)"
HOME_DIR="/home/evo"
WORKSPACE_DIR="$HOME_DIR/workspace"
REFERENCE_DIR="$WORKSPACE_DIR/_reference"
ARCHIVE_ROOT="$HOME_DIR/_archive/system_purge_$STAMP"
S_DRIVE="/mnt/s"
SHELL_BACKUP_DONE=0

usage() {
  cat <<'EOF'
Usage:
  bash evo-system-purge.sh [--execute] [--prune-caches] [--prune-s-drive]

Default behavior is dry-run.

Flags:
  --execute        Perform the actions instead of only printing them.
  --prune-caches   Remove rebuildable caches from /home/evo.
  --prune-s-drive  Delete unused S: drive project folders:
                   /mnt/s/ComfyUI
                   /mnt/s/Evolution-Content-Factory

Notes:
  - OpenClaw/OpenFang assets are archived, not deleted.
  - openclaw-mission-control is moved into workspace/_reference.
  - S: drive cleanup is destructive and only runs with --prune-s-drive.
EOF
}

log() {
  printf '%s\n' "$*"
}

run() {
  if [[ "$MODE" == "dry-run" ]]; then
    printf '[dry-run] %s\n' "$*"
  else
    printf '[run] %s\n' "$*"
    eval "$@"
  fi
}

archive_path() {
  local src="$1"
  local dest_name="$2"
  local dest="$ARCHIVE_ROOT/$dest_name"

  if [[ ! -e "$src" ]]; then
    log "[skip] missing: $src"
    return
  fi

  run "mkdir -p \"$ARCHIVE_ROOT\""
  run "mv \"$src\" \"$dest\""
}

move_reference() {
  local src="$HOME_DIR/openclaw-mission-control"
  local dest="$REFERENCE_DIR/openclaw-mission-control"

  if [[ ! -d "$src" ]]; then
    log "[skip] missing: $src"
    return
  fi

  if [[ -e "$dest" ]]; then
    log "[skip] destination already exists: $dest"
    return
  fi

  run "mkdir -p \"$REFERENCE_DIR\""
  run "mv \"$src\" \"$dest\""
}

remove_line_if_present() {
  local file="$1"
  local pattern="$2"

  if [[ ! -f "$file" ]] || ! grep -q "$pattern" "$file"; then
    return
  fi

  if [[ "$SHELL_BACKUP_DONE" -eq 0 ]]; then
    run "cp \"$file\" \"$file.bak.$STAMP\""
    SHELL_BACKUP_DONE=1
  fi
  run "sed -i '/$pattern/d' \"$file\""
}

delete_path() {
  local target="$1"

  if [[ ! -e "$target" ]]; then
    log "[skip] missing: $target"
    return
  fi

  run "rm -rf \"$target\""
}

show_sizes() {
  log ""
  log "Current size snapshot:"
  du -sh \
    "$HOME_DIR/_archive" \
    "$HOME_DIR/.cache" \
    "$HOME_DIR/.npm" \
    "$HOME_DIR/.vscode-server" \
    "$HOME_DIR/openclaw" \
    "$HOME_DIR/openclaw-mission-control" \
    "$WORKSPACE_DIR/gateways/openclaw" \
    "$S_DRIVE/ComfyUI" \
    "$S_DRIVE/Evolution-Content-Factory" \
    2>/dev/null || true
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --execute)
      MODE="execute"
      ;;
    --prune-caches)
      PRUNE_CACHES=1
      ;;
    --prune-s-drive)
      PRUNE_S_DRIVE=1
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      printf 'Unknown argument: %s\n\n' "$1" >&2
      usage >&2
      exit 1
      ;;
  esac
  shift
done

log "Evo system purge"
log "Mode: $MODE"
log "Archive root: $ARCHIVE_ROOT"
if [[ "$PRUNE_CACHES" -eq 1 ]]; then
  log "Cache prune: enabled"
fi
if [[ "$PRUNE_S_DRIVE" -eq 1 ]]; then
  log "S: drive destructive prune: enabled"
fi

show_sizes

log ""
log "Stopping OpenClaw service first so Restart=always cannot respawn it..."
run "systemctl --user stop openclaw-gateway.service || true"
run "systemctl --user disable openclaw-gateway.service || true"
run "systemctl --user reset-failed openclaw-gateway.service || true"

log ""
log "Killing related processes..."
run "pkill -f openclaw-gateway || true"
run "pkill -f openfang || true"

log ""
log "Archiving root-level OpenClaw/OpenFang drift..."
archive_path "$HOME_DIR/openclaw" "openclaw_root_repo"
archive_path "$HOME_DIR/.openclaw" "openclaw_state"
archive_path "$HOME_DIR/.openfang" "openfang_state"
archive_path "$HOME_DIR/.openfang-codex-bot" "openfang_codex_bot"
archive_path "$HOME_DIR/.openfang-general-bot" "openfang_general_bot"
archive_path "$HOME_DIR/tools/openfang-bots" "openfang_bots"
archive_path "$WORKSPACE_DIR/gateways/openclaw" "workspace_gateway_openclaw"

log ""
log "Archiving the user service definition..."
archive_path "$HOME_DIR/.config/systemd/user/openclaw-gateway.service" "openclaw-gateway.service"
run "rm -f \"$HOME_DIR/.config/systemd/user/default.target.wants/openclaw-gateway.service\""
run "systemctl --user daemon-reload || true"

log ""
log "Removing the global OpenClaw package..."
run "npm uninstall -g openclaw || true"

log ""
log "Cleaning shell startup hooks..."
remove_line_if_present "$HOME_DIR/.bashrc" "OpenClaw Completion"
remove_line_if_present "$HOME_DIR/.bashrc" "openclaw\\.bash"

log ""
log "Moving mission-control reference into workspace governance..."
move_reference

if [[ "$PRUNE_CACHES" -eq 1 ]]; then
  log ""
  log "Pruning rebuildable caches..."
  delete_path "$HOME_DIR/.cache/pip"
  delete_path "$HOME_DIR/.cache/workspace-full-export"
  delete_path "$HOME_DIR/.cache/uv"
  delete_path "$HOME_DIR/.cache/ms-playwright"
  delete_path "$HOME_DIR/.npm/_cacache"
  delete_path "$HOME_DIR/.npm/_npx"
fi

if [[ "$PRUNE_S_DRIVE" -eq 1 ]]; then
  log ""
  log "Deleting unused S: drive projects..."
  delete_path "$S_DRIVE/ComfyUI"
  delete_path "$S_DRIVE/Evolution-Content-Factory"
fi

log ""
log "Post-action checks:"
run "systemctl --user is-enabled openclaw-gateway.service || true"
run "systemctl --user is-active openclaw-gateway.service || true"
run "ps aux | grep -E 'openclaw|openfang' | grep -v grep || true"

log ""
log "Important:"
log "- Archiving inside /home/evo does not shrink the WSL VHD by itself."
log "- After real deletions, compact S:\\WSL_Ubuntu\\ext4.vhdx from Windows if you want disk space back."
log "- Run with --execute once the dry-run output looks right."
