#!/bin/bash
set -euo pipefail

find_codex_source() {
  local path
  local candidates=(
    "${EVO_CODEX_SOURCE:-}"
    "/mnt/c/Program Files/WindowsApps/OpenAI.Codex_26.313.5234.0_x64__2p2nqsd0c76g0/app/resources/codex"
  )

  for path in "${candidates[@]}"; do
    if [ -f "$path" ]; then
      printf '%s\n' "$path"
      return 0
    fi
  done

  return 1
}

main() {
  local path_codex=""
  local source_bin
  local cache_dir="$HOME/.cache/evo"
  local cache_bin="$cache_dir/codex"

  if path_codex="$(command -v codex 2>/dev/null)" && [ -x "$path_codex" ]; then
    exec "$path_codex" "$@"
  fi

  if ! source_bin="$(find_codex_source)"; then
    echo "Error: codex binary not found"
    exit 1
  fi

  mkdir -p "$cache_dir"

  if [ ! -x "$cache_bin" ] || [ "$source_bin" -nt "$cache_bin" ]; then
    cp "$source_bin" "$cache_bin"
    chmod +x "$cache_bin"
  fi

  exec "$cache_bin" "$@"
}

main "$@"
