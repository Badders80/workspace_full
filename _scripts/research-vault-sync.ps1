param(
    [ValidateSet("pull", "push")]
    [string]$Direction = "pull"
)

$workspaceVault = "\\wsl.localhost\Ubuntu\home\evo\workspace\_sandbox\research_vault"
$localVault = "C:\Users\Evo\Research_Vault"

if ($Direction -eq "pull") {
    $source = $workspaceVault
    $destination = $localVault
} else {
    $source = $localVault
    $destination = $workspaceVault
}

if (-not (Test-Path $source)) {
    Write-Error "Source vault not found: $source"
    exit 1
}

New-Item -ItemType Directory -Force $destination | Out-Null

$robocopyArgs = @(
    $source,
    $destination,
    "/MIR",
    "/R:1",
    "/W:1",
    "/NFL",
    "/NDL",
    "/NJH",
    "/NJS",
    "/NP"
)

& robocopy @robocopyArgs | Out-Null
$code = $LASTEXITCODE

if ($code -ge 8) {
    Write-Error "Robocopy failed with exit code $code"
    exit $code
}

Write-Output "Research vault sync complete."
Write-Output "Direction: $Direction"
Write-Output "Source: $source"
Write-Output "Destination: $destination"
