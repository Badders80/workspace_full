#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REFRESH=1
REFRESH_WINDOWS=1

for arg in "$@"; do
  case "$arg" in
    --no-refresh)
      REFRESH=0
      ;;
    --no-windows-refresh)
      REFRESH_WINDOWS=0
      ;;
    *)
      echo "Usage: $0 [--no-refresh] [--no-windows-refresh]" >&2
      exit 64
      ;;
  esac
done

if [[ "$REFRESH" -eq 1 ]]; then
  "$SCRIPT_DIR/collect-wsl.sh" >/dev/null

  if [[ "$REFRESH_WINDOWS" -eq 1 ]] && command -v powershell.exe >/dev/null 2>&1; then
    powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$SCRIPT_DIR/collect-windows.ps1" >/dev/null 2>&1 || true
  fi

  "$SCRIPT_DIR/summarize-health.py" >/dev/null
fi

python3 <<'PY'
import json
import sys
from pathlib import Path

LATEST_PATH = Path("/home/evo/workspace/_logs/system-health/latest.json")
rank = {"ok": 0, "warn": 1, "critical": 2}

if not LATEST_PATH.exists():
    print("unknown no-snapshots")
    sys.exit(1)

data = json.loads(LATEST_PATH.read_text(encoding="utf-8"))
machines = data.get("machines", [])
if not machines:
    print("unknown no-snapshots")
    sys.exit(1)

worst = 0
lines: list[str] = []
for machine in machines:
    status = machine.get("status", "ok")
    worst = max(worst, rank.get(status, 0))
    host = ", ".join(machine.get("hostnames", [])) or machine.get("machine_key", "unknown")
    source_parts = []
    for source_name in sorted(machine.get("source_status", {})):
        info = machine["source_status"][source_name]
        age = info.get("age_minutes")
        age_text = f"{age}m" if age is not None else "na"
        source_parts.append(f"{source_name}={info.get('status', 'unknown')}({age_text})")

    warn_count = 0
    critical_count = 0
    for item in machine.get("issues", []):
        if item.get("severity") == "warn":
            warn_count += 1
        elif item.get("severity") == "critical":
            critical_count += 1

    lines.append(
        f"{status} {host} [{' '.join(source_parts)}] alerts={warn_count}w/{critical_count}c"
    )

print("\n".join(lines))
sys.exit(worst)
PY
