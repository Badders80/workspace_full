param(
    [string]$SourceRoot = '\\wsl.localhost\Ubuntu\home\evo\workspace',
    [string]$DestinationRoot,
    [switch]$WhatIf
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Resolve-DestinationRoot {
    param([string]$RequestedRoot)

    if ($RequestedRoot) {
        return $RequestedRoot
    }

    $candidates = @(
        'G:\Evo\workspace-docs-mirror',
        'G:\My Drive\Evo\workspace-docs-mirror',
        'G:\Shared drives\Evo\workspace-docs-mirror',
        (Join-Path $env:USERPROFILE 'My Drive\Evo\workspace-docs-mirror'),
        (Join-Path $env:USERPROFILE 'Google Drive\Evo\workspace-docs-mirror')
    )

    foreach ($candidate in $candidates) {
        $parent = Split-Path -Parent $candidate
        if ($parent -and (Test-Path -LiteralPath $parent)) {
            return $candidate
        }
    }

    throw "No Google Drive mirror target was detected. Mount G: or pass -DestinationRoot explicitly."
}

function Get-RelativePath {
    param(
        [string]$BasePath,
        [string]$FullPath
    )

    $baseUri = [System.Uri]("$($BasePath.TrimEnd('\'))\")
    $fullUri = [System.Uri]$FullPath
    $relativeUri = $baseUri.MakeRelativeUri($fullUri)
    $relativePath = [System.Uri]::UnescapeDataString($relativeUri.ToString())

    return $relativePath.Replace('/', '\')
}

function Test-ExcludedRelativePath {
    param([string]$RelativePath)

    $normalized = $RelativePath.Replace('\', '/').ToLowerInvariant()
    $segments = $normalized -split '/'

    $blockedSegments = @(
        '.git',
        'node_modules',
        '.next',
        'dist',
        'build',
        'out',
        'coverage',
        '_archive',
        '_logs',
        '_locks',
        '_sandbox',
        'archive',
        'logs',
        'tmp',
        'temp',
        '.venv',
        'venv',
        '__pycache__',
        'secrets'
    )

    foreach ($segment in $blockedSegments) {
        if ($segments -contains $segment) {
            return $true
        }
    }

    if (
        $normalized -like '*/.env' -or
        $normalized -like '*/.env.*'
    ) {
        return $true
    }

    return $false
}

function Add-FileIfPresent {
    param(
        [string]$Path,
        [System.Collections.Generic.Dictionary[string, string]]$Manifest
    )

    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        return
    }

    $relativePath = Get-RelativePath -BasePath $SourceRoot -FullPath $Path
    if (Test-ExcludedRelativePath -RelativePath $relativePath) {
        return
    }

    $Manifest[$relativePath.ToLowerInvariant()] = $Path
}

function Add-MarkdownTree {
    param(
        [string]$RootPath,
        [System.Collections.Generic.Dictionary[string, string]]$Manifest
    )

    if (-not (Test-Path -LiteralPath $RootPath -PathType Container)) {
        return
    }

    Get-ChildItem -LiteralPath $RootPath -File -Recurse -Filter '*.md' -ErrorAction SilentlyContinue | ForEach-Object {
        $relativePath = Get-RelativePath -BasePath $SourceRoot -FullPath $_.FullName
        if (-not (Test-ExcludedRelativePath -RelativePath $relativePath)) {
            $Manifest[$relativePath.ToLowerInvariant()] = $_.FullName
        }
    }
}

function Add-RootMarkdownFiles {
    param(
        [string]$RootPath,
        [System.Collections.Generic.Dictionary[string, string]]$Manifest
    )

    if (-not (Test-Path -LiteralPath $RootPath -PathType Container)) {
        return
    }

    Get-ChildItem -LiteralPath $RootPath -File -Filter '*.md' | ForEach-Object {
        $relativePath = Get-RelativePath -BasePath $SourceRoot -FullPath $_.FullName
        if (-not (Test-ExcludedRelativePath -RelativePath $relativePath)) {
            $Manifest[$relativePath.ToLowerInvariant()] = $_.FullName
        }
    }
}

if (-not (Test-Path -LiteralPath $SourceRoot -PathType Container)) {
    throw "Source root not found: $SourceRoot"
}

$resolvedDestinationRoot = Resolve-DestinationRoot -RequestedRoot $DestinationRoot
$resolvedDestinationRoot = [System.IO.Path]::GetFullPath($resolvedDestinationRoot)

$manifest = [System.Collections.Generic.Dictionary[string, string]]::new()

Add-RootMarkdownFiles -RootPath $SourceRoot -Manifest $manifest
Add-MarkdownTree -RootPath (Join-Path $SourceRoot 'DNA') -Manifest $manifest
Add-MarkdownTree -RootPath (Join-Path $SourceRoot 'projects') -Manifest $manifest

if (-not (Test-Path -LiteralPath $resolvedDestinationRoot)) {
    if ($WhatIf) {
        Write-Host "[WhatIf] Create destination root $resolvedDestinationRoot"
    } else {
        New-Item -ItemType Directory -Path $resolvedDestinationRoot -Force | Out-Null
    }
}

$copiedFiles = New-Object System.Collections.Generic.List[string]

foreach ($entry in $manifest.GetEnumerator() | Sort-Object Name) {
    $relativePath = $entry.Value | ForEach-Object { Get-RelativePath -BasePath $SourceRoot -FullPath $_ }
    $sourcePath = $entry.Value
    $destinationPath = Join-Path $resolvedDestinationRoot $relativePath
    $destinationDir = Split-Path -Parent $destinationPath

    if (-not (Test-Path -LiteralPath $destinationDir)) {
        if ($WhatIf) {
            Write-Host "[WhatIf] Create directory $destinationDir"
        } else {
            New-Item -ItemType Directory -Path $destinationDir -Force | Out-Null
        }
    }

    if (
        -not (Test-Path -LiteralPath $destinationPath -PathType Leaf) -or
        (Get-Item -LiteralPath $sourcePath).LastWriteTimeUtc -gt (Get-Item -LiteralPath $destinationPath).LastWriteTimeUtc -or
        (Get-Item -LiteralPath $sourcePath).Length -ne (Get-Item -LiteralPath $destinationPath).Length
    ) {
        if ($WhatIf) {
            Write-Host "[WhatIf] Copy $relativePath"
        } else {
            Copy-Item -LiteralPath $sourcePath -Destination $destinationPath -Force
        }
    }

    $copiedFiles.Add($relativePath) | Out-Null
}

$managedFiles = $manifest.Keys
$mirrorManifestName = 'MIRROR_MANIFEST.md'
$deletedFiles = New-Object System.Collections.Generic.List[string]

if (Test-Path -LiteralPath $resolvedDestinationRoot -PathType Container) {
    Get-ChildItem -LiteralPath $resolvedDestinationRoot -File -Recurse | ForEach-Object {
        $destinationRelativePath = Get-RelativePath -BasePath $resolvedDestinationRoot -FullPath $_.FullName
        if ($destinationRelativePath -eq $mirrorManifestName) {
            return
        }

        if (-not $managedFiles.Contains($destinationRelativePath.ToLowerInvariant())) {
            if ($WhatIf) {
                Write-Host "[WhatIf] Remove stale file $destinationRelativePath"
            } else {
                Remove-Item -LiteralPath $_.FullName -Force
            }

            $deletedFiles.Add($destinationRelativePath) | Out-Null
        }
    }

    if (-not $WhatIf) {
        Get-ChildItem -LiteralPath $resolvedDestinationRoot -Directory -Recurse |
            Sort-Object FullName -Descending |
            ForEach-Object {
                if (-not (Get-ChildItem -LiteralPath $_.FullName -Force)) {
                    Remove-Item -LiteralPath $_.FullName -Force
                }
            }
    }
}

$generatedAt = (Get-Date).ToString('yyyy-MM-dd HH:mm:ss zzz')
$manifestLines = @(
    '# Workspace Docs Mirror',
    '',
    "- Generated: $generatedAt",
    "- Source: $SourceRoot",
    "- Destination: $resolvedDestinationRoot",
    "- Mode: one-way source authoritative sync",
    "- Included files: $($manifest.Count)",
    "- Pruned stale files: $($deletedFiles.Count)",
    '',
    '## Included Surface',
    '- Workspace root markdown: `/*.md`',
    '- `DNA/**/*.md`',
    '- `projects/**/*.md`',
    '',
    '## Hard Exclusions',
    '- `.git`, `node_modules`, `.next`, `dist`, `build`, `out`, `coverage`',
    '- `_archive`, `_logs`, `_locks`, `_sandbox`, `archive`, `logs`, `tmp`, `temp`',
    '- `.env*`, `secrets`, `intake`, generated/public runtime state',
    '',
    '## Managed Files',
    ''
)

foreach ($relativePath in ($copiedFiles | Sort-Object -Unique)) {
    $manifestLines += ('- `' + $relativePath + '`')
}

$mirrorManifestPath = Join-Path $resolvedDestinationRoot $mirrorManifestName
if ($WhatIf) {
    Write-Host "[WhatIf] Write manifest $mirrorManifestPath"
} else {
    $manifestLines | Set-Content -LiteralPath $mirrorManifestPath -Encoding UTF8
}

Write-Host "Mirror complete: $($manifest.Count) managed files -> $resolvedDestinationRoot"
if ($deletedFiles.Count -gt 0) {
    Write-Host "Pruned stale files: $($deletedFiles.Count)"
}
