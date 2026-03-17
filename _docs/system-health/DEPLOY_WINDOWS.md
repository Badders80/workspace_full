# Windows Deployment

This monitor uses the same Windows collector for:

- EVO-STATION
- Windows 365 Cloud PC
- any other Windows host you want to observe

Each Windows host writes host-tagged snapshots, so they do not overwrite each other.

## EVO-STATION

EVO-STATION is already installed locally with:

- `C:\evo\system-health\bin\collect-windows.ps1`
- scheduled task: `EVO-System-Health-Collector`
- output path: `C:\evo\system-health\logs`

## Cloud PC

The Cloud PC is a separate Windows host. It needs its own local install.

Use the standalone installer generated at:

- `/_scripts/system-health/dist/install-windows-monitor-standalone.ps1`

Run that script on the Cloud PC in PowerShell:

```powershell
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
.\install-windows-monitor-standalone.ps1
```

That will:

- write `collect-windows.ps1` into `C:\evo\system-health\bin\`
- create `C:\evo\system-health\logs\`
- register the `EVO-System-Health-Collector` task

## Feeding Cloud PC Data Back Into The Summary

The central WSL summary only sees files available to this workspace.

To merge Cloud PC snapshots into the same summary on EVO-STATION:

1. Copy the Cloud PC latest snapshot from:
   `C:\evo\system-health\logs\latest\windows-<hostname>.json`
2. Place it into:
   `/_logs/system-health/import/latest/`
3. Run:
   `/_scripts/system-health/summarize-health.py`

Imported snapshots are treated like any other host snapshot and will appear under their own machine key.

## Notes

- The Cloud PC will not be monitored automatically from EVO-STATION unless its snapshots are copied or synced back here.
- If you later choose a shared folder or OneDrive sync path, we can wire that into the import path as a cleaner bridge.
