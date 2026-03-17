param(
    [string]$OutputRoot = "C:\evo\system-health\logs"
)

$ErrorActionPreference = "Stop"

function ConvertTo-MachineKey {
    param([string]$Value)
    $key = [regex]::Replace($Value.ToLowerInvariant(), "[^a-z0-9]+", "-")
    return $key.Trim("-")
}

function Get-Percent {
    param(
        [double]$Part,
        [double]$Whole
    )
    if ($Whole -le 0) {
        return 0
    }
    return [math]::Round(($Part / $Whole) * 100, 1)
}

function Read-WslConfig {
    $path = Join-Path $env:USERPROFILE ".wslconfig"
    if (-not (Test-Path $path)) {
        return @{
            present = $false
            path = $path
            settings = @{}
        }
    }

    $settings = @{}
    $section = ""
    foreach ($rawLine in Get-Content $path) {
        $line = $rawLine.Trim()
        if (-not $line -or $line.StartsWith("#") -or $line.StartsWith(";")) {
            continue
        }
        if ($line.StartsWith("[") -and $line.EndsWith("]")) {
            $section = $line.Trim("[", "]")
            continue
        }
        if ($line -match "=") {
            $parts = $line.Split("=", 2)
            $key = $parts[0].Trim()
            $value = $parts[1].Trim()
            if ($section) {
                $settings["$section.$key"] = $value
            }
            else {
                $settings[$key] = $value
            }
        }
    }

    return @{
        present = $true
        path = $path
        settings = $settings
    }
}

function Get-VhdxInventory {
    param(
        [string]$CachePath
    )

    if (Test-Path $CachePath) {
        $age = (Get-Date) - (Get-Item $CachePath).LastWriteTime
        if ($age.TotalHours -lt 24) {
            return Get-Content $CachePath -Raw | ConvertFrom-Json
        }
    }

    $roots = @(
        (Join-Path $env:LOCALAPPDATA "Packages"),
        (Join-Path $env:LOCALAPPDATA "Docker\wsl"),
        "C:\wsl",
        "S:\wsl",
        "S:\evo",
        (Join-Path $env:USERPROFILE "AppData\Local\Docker")
    ) | Where-Object { Test-Path $_ } | Select-Object -Unique

    $items = @()
    foreach ($root in $roots) {
        try {
            Get-ChildItem -Path $root -Recurse -Filter "*.vhdx" -File -ErrorAction SilentlyContinue | ForEach-Object {
                $items += [pscustomobject]@{
                    full_name = $_.FullName
                    size_gb = [math]::Round($_.Length / 1GB, 2)
                    drive = $_.PSDrive.Name + ":"
                }
            }
        }
        catch {
        }
    }

    $deduped = $items | Sort-Object full_name -Unique
    $deduped | ConvertTo-Json -Depth 6 | Set-Content -Path $CachePath -Encoding UTF8
    return $deduped
}

function Add-Issue {
    param(
        [System.Collections.Generic.List[object]]$Issues,
        [string]$Severity,
        [string]$Code,
        [string]$Message
    )
    $Issues.Add([pscustomobject]@{
        severity = $Severity
        code = $Code
        message = $Message
    }) | Out-Null
}

$LatestDir = Join-Path $OutputRoot "latest"
$CacheDir = Join-Path $OutputRoot "cache"
New-Item -ItemType Directory -Path $OutputRoot -Force | Out-Null
New-Item -ItemType Directory -Path $LatestDir -Force | Out-Null
New-Item -ItemType Directory -Path $CacheDir -Force | Out-Null

$hostname = $env:COMPUTERNAME
$machineKey = ConvertTo-MachineKey $hostname
$timestamp = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")

$osInfo = Get-CimInstance Win32_OperatingSystem
$physicalTotalMb = [math]::Round($osInfo.TotalVisibleMemorySize / 1024, 0)
$physicalFreeMb = [math]::Round($osInfo.FreePhysicalMemory / 1024, 0)
$physicalUsedMb = [math]::Max($physicalTotalMb - $physicalFreeMb, 0)
$physicalUsedPct = Get-Percent $physicalUsedMb $physicalTotalMb

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

$vmmemProcess = Get-Process -ErrorAction SilentlyContinue | Where-Object {
    $_.ProcessName -match "^Vmmem(WSL)?$"
}
$vmmemWorkingSetGb = 0
if ($vmmemProcess) {
    $vmmemWorkingSetGb = [math]::Round((($vmmemProcess | Measure-Object -Property WorkingSet64 -Sum).Sum) / 1GB, 2)
}

$drives = @()
Get-CimInstance Win32_LogicalDisk | Where-Object { $_.DeviceID -in @("C:", "S:") } | ForEach-Object {
    $used = [double]$_.Size - [double]$_.FreeSpace
    $drives += [pscustomobject]@{
        device = $_.DeviceID
        label = $_.VolumeName
        total_gb = [math]::Round($_.Size / 1GB, 2)
        used_gb = [math]::Round($used / 1GB, 2)
        free_gb = [math]::Round($_.FreeSpace / 1GB, 2)
        used_pct = Get-Percent $used $_.Size
    }
}

$topProcesses = Get-Process -ErrorAction SilentlyContinue |
    Sort-Object -Property WorkingSet64 -Descending |
    Select-Object -First 10 |
    ForEach-Object {
        [pscustomobject]@{
            name = $_.ProcessName
            id = $_.Id
            working_set_gb = [math]::Round($_.WorkingSet64 / 1GB, 2)
            private_memory_gb = [math]::Round($_.PrivateMemorySize64 / 1GB, 2)
            cpu = [math]::Round($_.CPU, 2)
        }
    }

$wslList = ((wsl.exe --list --verbose) 2>$null | Out-String) -replace [char]0, ""
$wslConfig = Read-WslConfig
$vhdxInventory = Get-VhdxInventory -CachePath (Join-Path $CacheDir "vhdx-$machineKey.json")
$normalizedVhdxInventory = @(
    $vhdxInventory | ForEach-Object {
        [pscustomobject]@{
            full_name = $_.full_name
            size_gb = $_.size_gb
            drive = $_.drive
        }
    }
)

$issues = New-Object 'System.Collections.Generic.List[object]'
if ($physicalUsedPct -ge 90) {
    Add-Issue -Issues $issues -Severity "critical" -Code "windows_memory_high" -Message "Windows physical memory used is $physicalUsedPct%."
}
elseif ($physicalUsedPct -ge 80) {
    Add-Issue -Issues $issues -Severity "warn" -Code "windows_memory_elevated" -Message "Windows physical memory used is $physicalUsedPct%."
}

$commitUsedPct = Get-Percent $committedBytes $commitLimitBytes
if ($commitUsedPct -ge 90) {
    Add-Issue -Issues $issues -Severity "critical" -Code "windows_commit_high" -Message "Windows commit used is $commitUsedPct%."
}
elseif ($commitUsedPct -ge 80) {
    Add-Issue -Issues $issues -Severity "warn" -Code "windows_commit_elevated" -Message "Windows commit used is $commitUsedPct%."
}

foreach ($drive in $drives) {
    if ($drive.used_pct -ge 90) {
        Add-Issue -Issues $issues -Severity "critical" -Code "windows_drive_high" -Message "$($drive.device) used is $($drive.used_pct)%."
    }
    elseif ($drive.used_pct -ge 80) {
        Add-Issue -Issues $issues -Severity "warn" -Code "windows_drive_elevated" -Message "$($drive.device) used is $($drive.used_pct)%."
    }
}

if (-not $wslConfig.present) {
    Add-Issue -Issues $issues -Severity "warn" -Code "wslconfig_missing" -Message ".wslconfig was not found on this Windows host."
}

if ($vhdxInventory | Where-Object { $_.full_name.ToLowerInvariant().StartsWith("c:\") }) {
    Add-Issue -Issues $issues -Severity "warn" -Code "vhdx_on_c" -Message "At least one WSL VHDX file is located on C:."
}

$status = "ok"
foreach ($issue in $issues) {
    if ($issue.severity -eq "critical") {
        $status = "critical"
        break
    }
    elseif ($issue.severity -eq "warn" -and $status -eq "ok") {
        $status = "warn"
    }
}

$snapshot = [ordered]@{
    ts = $timestamp
    source = "windows"
    collector = @{
        name = "collect-windows.ps1"
        version = "0.1.0"
    }
    host = @{
        hostname = $hostname
        machine_key = $machineKey
        user = $env:USERNAME
        os_caption = $osInfo.Caption
        os_version = $osInfo.Version
    }
    memory = @{
        physical_total_mb = $physicalTotalMb
        physical_free_mb = $physicalFreeMb
        physical_used_mb = $physicalUsedMb
        physical_used_pct = $physicalUsedPct
        commit_used_gb = [math]::Round($committedBytes / 1GB, 2)
        commit_limit_gb = [math]::Round($commitLimitBytes / 1GB, 2)
        commit_used_pct = $commitUsedPct
    }
    drives = $drives
    processes = @{
        top_working_set = $topProcesses
    }
    wsl = @{
        vmmem_working_set_gb = $vmmemWorkingSetGb
        distributions = $wslList.Trim()
        config = $wslConfig
        vhdx = $normalizedVhdxInventory
    }
    health = @{
        status = $status
        issues = $issues
    }
}

$jsonlPath = Join-Path $OutputRoot "windows-$machineKey.jsonl"
$latestJsonPath = Join-Path $LatestDir "windows-$machineKey.json"
$jsonLine = $snapshot | ConvertTo-Json -Depth 8 -Compress
Add-Content -Path $jsonlPath -Value $jsonLine
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText(
    $latestJsonPath,
    (($snapshot | ConvertTo-Json -Depth 8) + [Environment]::NewLine),
    $utf8NoBom
)

[pscustomobject]@{
    status = $status
    jsonl = $jsonlPath
    latest_json = $latestJsonPath
} | ConvertTo-Json -Compress
