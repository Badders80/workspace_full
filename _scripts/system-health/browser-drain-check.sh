#!/usr/bin/env bash

set -euo pipefail

SECONDS_TO_WAIT=60

while [[ $# -gt 0 ]]; do
  case "$1" in
    --seconds)
      shift
      SECONDS_TO_WAIT="${1:?missing value for --seconds}"
      ;;
    *)
      echo "Usage: $0 [--seconds N]" >&2
      exit 64
      ;;
  esac
  shift
done

python3 - "$SECONDS_TO_WAIT" <<'PY'
import json
import subprocess
import sys
import time

WAIT_SECONDS = int(sys.argv[1])

POWERSHELL_SCRIPT = r"""
$browserNames = @("chrome", "comet", "msedge", "firefox", "brave", "arc", "opera")
$osInfo = Get-CimInstance Win32_OperatingSystem
$physicalTotalMb = [math]::Round($osInfo.TotalVisibleMemorySize / 1024, 0)
$physicalFreeMb = [math]::Round($osInfo.FreePhysicalMemory / 1024, 0)
$physicalUsedMb = [math]::Max($physicalTotalMb - $physicalFreeMb, 0)
$physicalUsedPct = if ($physicalTotalMb -gt 0) { [math]::Round(($physicalUsedMb / $physicalTotalMb) * 100, 1) } else { 0 }

$commitCounter = Get-Counter "\Memory\Committed Bytes", "\Memory\Commit Limit"
$committedBytes = 0
$commitLimitBytes = 0
foreach ($sample in $commitCounter.CounterSamples) {
    if ($sample.Path -like "*Committed Bytes") {
        $committedBytes = [double]$sample.CookedValue
    }
    elseif ($sample.Path -like "*Commit Limit") {
        $commitLimitBytes = [double]$sample.CookedValue
    }
}
$commitUsedPct = if ($commitLimitBytes -gt 0) { [math]::Round(($committedBytes / $commitLimitBytes) * 100, 1) } else { 0 }

$browserProcs = Get-Process -ErrorAction SilentlyContinue | Where-Object {
    $browserNames -contains $_.ProcessName.ToLowerInvariant()
}

$grouped = @()
foreach ($group in ($browserProcs | Group-Object -Property ProcessName)) {
    $grouped += [pscustomobject]@{
        name = $group.Name
        count = $group.Count
        working_set_gb = [math]::Round((($group.Group | Measure-Object -Property WorkingSet64 -Sum).Sum) / 1GB, 2)
        private_memory_gb = [math]::Round((($group.Group | Measure-Object -Property PrivateMemorySize64 -Sum).Sum) / 1GB, 2)
    }
}

[pscustomobject]@{
    ts = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
    physical_used_pct = $physicalUsedPct
    commit_used_pct = $commitUsedPct
    browser_process_count = @($browserProcs).Count
    browser_working_set_gb = [math]::Round((($browserProcs | Measure-Object -Property WorkingSet64 -Sum).Sum) / 1GB, 2)
    browser_private_memory_gb = [math]::Round((($browserProcs | Measure-Object -Property PrivateMemorySize64 -Sum).Sum) / 1GB, 2)
    grouped = $grouped
} | ConvertTo-Json -Depth 6 -Compress
"""


def collect_snapshot() -> dict:
    result = subprocess.run(
        ["powershell.exe", "-NoProfile", "-Command", POWERSHELL_SCRIPT],
        capture_output=True,
        text=True,
        check=True,
    )
    return json.loads(result.stdout)


def fmt_delta(value: float, unit: str) -> str:
    sign = "+" if value > 0 else ""
    return f"{sign}{round(value, 2)}{unit}"


baseline = collect_snapshot()
print(
    "Baseline: "
    f"host RAM {baseline['physical_used_pct']}%, "
    f"commit {baseline['commit_used_pct']}%, "
    f"browser family {baseline['browser_working_set_gb']} GiB "
    f"across {baseline['browser_process_count']} process(es)."
)

if baseline["grouped"]:
    grouped_parts = [
        f"{item['name']}={item['working_set_gb']}GiB/{item['count']}"
        for item in baseline["grouped"]
    ]
    print("Processes: " + ", ".join(grouped_parts))

print(f"Close the browser windows now. Waiting {WAIT_SECONDS} seconds...")
time.sleep(WAIT_SECONDS)

after = collect_snapshot()
ram_delta = after["physical_used_pct"] - baseline["physical_used_pct"]
commit_delta = after["commit_used_pct"] - baseline["commit_used_pct"]
browser_delta = after["browser_working_set_gb"] - baseline["browser_working_set_gb"]

print(
    "After: "
    f"host RAM {after['physical_used_pct']}%, "
    f"commit {after['commit_used_pct']}%, "
    f"browser family {after['browser_working_set_gb']} GiB "
    f"across {after['browser_process_count']} process(es)."
)
print(
    "Delta: "
    f"RAM {fmt_delta(ram_delta, ' pts')}, "
    f"commit {fmt_delta(commit_delta, ' pts')}, "
    f"browser family {fmt_delta(browser_delta, ' GiB')}."
)

if baseline["browser_process_count"] == 0:
    print("Result: no browser-family processes were present in the baseline sample.")
elif browser_delta <= -1.0 or ram_delta <= -5.0:
    print("Result: browser-family memory reclaimed quickly.")
elif browser_delta < 0 or ram_delta < 0:
    print("Result: browser-family memory reclaimed partially.")
else:
    print("Result: browser-family memory did not meaningfully fall during the wait window.")
PY
