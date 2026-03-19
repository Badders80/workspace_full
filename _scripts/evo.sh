#!/bin/bash
set -euo pipefail

source /home/evo/workspace/_scripts/agent-context.sh

show_help() {
  cat <<'EOF'
evo - workspace control plane helper

Usage: evo [command]

Commands:
  doctor        Run workspace sanity checks
  context       Show canonical workspace context files
  gemini        Launch Gemini with workspace context
  claude        Launch Claude with workspace context
  aider         Launch Aider with workspace context
  codex         Launch Codex
  backlog       Show the active inbox/deferred queue
  transition    Show the transition log
  decisions     Show the decision log
  memory        Show the memory protocol
  radar         Show the tech radar
  vault         Run vault helper
  docker        Run docker helper
  tldr          Run tool-tldr helper
  help          Show this help
EOF
}

print_file() {
  local file="$1"
  if [ -f "$file" ]; then
    cat "$file"
  else
    echo "Missing: $file"
    exit 1
  fi
}

cmd_context() {
  echo "Canonical workspace context files:"
  while IFS= read -r file; do
    echo "  $file"
  done < <(workspace_context_files)
}

cmd_backlog() {
  echo "OPERATING_BACKLOG.md is retired in the current workspace."
  echo "Showing DNA/INBOX.md instead."
  echo
  print_file "$WORKSPACE_INBOX"
}

cmd_transition() {
  print_file "$WORKSPACE_TRANSITION"
}

cmd_decisions() {
  print_file "$WORKSPACE_DECISIONS"
}

cmd_memory() {
  print_file "$WORKSPACE_MEMORY_PROTOCOL"
}

cmd_radar() {
  print_file "$WORKSPACE_TECH_RADAR"
}

case "${1:-help}" in
  doctor)
    exec /home/evo/workspace/_scripts/evo-doctor.sh
    ;;
  context)
    cmd_context
    ;;
  gemini)
    shift
    exec /home/evo/workspace/_scripts/geminic.sh "$@"
    ;;
  claude)
    shift
    exec /home/evo/workspace/_scripts/claudec.sh "$@"
    ;;
  aider)
    shift
    exec /home/evo/workspace/_scripts/aidere.sh "$@"
    ;;
  codex)
    shift
    exec bash /home/evo/workspace/_scripts/codexc.sh "$@"
    ;;
  backlog)
    cmd_backlog
    ;;
  transition)
    cmd_transition
    ;;
  decisions)
    cmd_decisions
    ;;
  memory)
    cmd_memory
    ;;
  radar)
    cmd_radar
    ;;
  vault)
    shift
    exec /home/evo/workspace/_scripts/vault.sh "$@"
    ;;
  docker)
    shift
    exec /home/evo/workspace/_scripts/evo-docker.sh "$@"
    ;;
  tldr)
    shift
    exec /home/evo/workspace/_scripts/tool-tldr.sh "$@"
    ;;
  help|--help|-h)
    show_help
    ;;
  *)
    echo "Unknown command: $1"
    echo "Run 'evo help' for usage"
    exit 1
    ;;
esac
