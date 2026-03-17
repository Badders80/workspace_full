#!/usr/bin/env bash

set -euo pipefail

schedule="${1:-*/15 * * * *}"
collect_line="${schedule} /home/evo/workspace/_scripts/system-health/collect-wsl.sh >/dev/null 2>&1"

summary_schedule="$schedule"
if [[ "$schedule" =~ ^\*/([0-9]+)\ \*\ \*\ \*\ \*$ ]]; then
  interval="${BASH_REMATCH[1]}"
  if [[ "$interval" -gt 1 && "$interval" -lt 60 ]]; then
    summary_schedule="1-59/${interval} * * * *"
  fi
fi

summary_line="${summary_schedule} /home/evo/workspace/_scripts/system-health/summarize-health.py >/dev/null 2>&1"

tmp_file="$(mktemp)"
cleanup() {
  rm -f "$tmp_file"
}
trap cleanup EXIT

crontab -l 2>/dev/null | grep -v '/_scripts/system-health/collect-wsl.sh' | grep -v '/_scripts/system-health/summarize-health.py' > "$tmp_file" || true
{
  cat "$tmp_file"
  echo "$collect_line"
  echo "$summary_line"
} | crontab -

crontab -l
