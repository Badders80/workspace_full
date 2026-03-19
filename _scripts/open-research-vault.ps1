$obsidianExe = Join-Path $env:LOCALAPPDATA "Programs\\Obsidian\\Obsidian.exe"
$vaultPath = "C:\\Users\\Evo\\Research_Vault"

if (-not (Test-Path $obsidianExe)) {
    Write-Error "Obsidian is not installed at $obsidianExe"
    exit 1
}

if (-not (Test-Path $vaultPath)) {
    Write-Error "Local research vault not found at $vaultPath"
    exit 1
}

Start-Process -FilePath $obsidianExe

Write-Output "Obsidian launch requested."
Write-Output "Registered research vault: $vaultPath"
