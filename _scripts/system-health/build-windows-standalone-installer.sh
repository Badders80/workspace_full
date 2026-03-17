#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_SCRIPT="$SCRIPT_DIR/collect-windows.ps1"
DIST_DIR="$SCRIPT_DIR/dist"
OUTPUT_SCRIPT="$DIST_DIR/install-windows-monitor-standalone.ps1"

mkdir -p "$DIST_DIR"

{
  cat <<'EOF'
param(
    [string]$TaskName = "EVO-System-Health-Collector",
    [int]$IntervalMinutes = 15,
    [string]$WindowsRoot = "C:\evo\system-health"
)

$ErrorActionPreference = "Stop"

$collectorScript = @'
EOF
  cat "$SOURCE_SCRIPT"
  cat <<'EOF'
'@

$binDir = Join-Path $WindowsRoot "bin"
$logDir = Join-Path $WindowsRoot "logs"
$targetScript = Join-Path $binDir "collect-windows.ps1"

New-Item -ItemType Directory -Path $binDir -Force | Out-Null
New-Item -ItemType Directory -Path $logDir -Force | Out-Null

$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText(
    $targetScript,
    ($collectorScript.TrimStart("`r", "`n") + [Environment]::NewLine),
    $utf8NoBom
)

$action = New-ScheduledTaskAction `
    -Execute "powershell.exe" `
    -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$targetScript`" -OutputRoot `"$logDir`""

$trigger = New-ScheduledTaskTrigger `
    -Once `
    -At (Get-Date).AddMinutes(1) `
    -RepetitionInterval (New-TimeSpan -Minutes $IntervalMinutes) `
    -RepetitionDuration (New-TimeSpan -Days 3650)

$currentIdentity = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
$principal = New-ScheduledTaskPrincipal `
    -UserId $currentIdentity `
    -LogonType Interactive `
    -RunLevel Limited

$settings = New-ScheduledTaskSettingsSet `
    -AllowStartIfOnBatteries `
    -DontStopIfGoingOnBatteries `
    -StartWhenAvailable

$task = New-ScheduledTask `
    -Action $action `
    -Principal $principal `
    -Trigger $trigger `
    -Settings $settings

Register-ScheduledTask -TaskName $TaskName -InputObject $task -Force | Out-Null

[pscustomobject]@{
    task_name = $TaskName
    interval_minutes = $IntervalMinutes
    target_script = $targetScript
    log_dir = $logDir
    hostname = $env:COMPUTERNAME
} | ConvertTo-Json -Compress
EOF
} >"$OUTPUT_SCRIPT"

chmod +x "$OUTPUT_SCRIPT"
printf '%s\n' "$OUTPUT_SCRIPT"
