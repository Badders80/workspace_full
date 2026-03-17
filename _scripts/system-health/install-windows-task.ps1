param(
    [string]$TaskName = "EVO-System-Health-Collector",
    [int]$IntervalMinutes = 15,
    [string]$WindowsRoot = "C:\evo\system-health"
)

$ErrorActionPreference = "Stop"

$sourceScript = "\\wsl.localhost\Ubuntu\home\evo\workspace\_scripts\system-health\collect-windows.ps1"
$binDir = Join-Path $WindowsRoot "bin"
$logDir = Join-Path $WindowsRoot "logs"
$targetScript = Join-Path $binDir "collect-windows.ps1"

if (-not (Test-Path $sourceScript)) {
    throw "Source script not found at $sourceScript"
}

New-Item -ItemType Directory -Path $binDir -Force | Out-Null
New-Item -ItemType Directory -Path $logDir -Force | Out-Null
Copy-Item -Path $sourceScript -Destination $targetScript -Force

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
} | ConvertTo-Json -Compress
