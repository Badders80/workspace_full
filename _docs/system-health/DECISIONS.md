# System Health Decisions

## 2026-03-12

- Created a fresh `system-health` monitor namespace instead of extending the old `evo-health.sh` script in place.
- Chosen architecture is two collectors plus one summary layer:
  - WSL collector for guest metrics
  - Windows collector for host metrics
  - Shared structured logs and a merged summary view
- New monitor assets live under dedicated `system-health` folders in `_scripts`, `_logs`, and `_docs`.
- Existing `/_scripts/evo-health.sh` is retained as a legacy reference, not the long-term design.
- `README.md` and `DECISIONS.md` are the primary project docs.
- `AGENTS.md` is intentionally not added at this stage because the project does not yet need agent-specific operating rules.
- Windows snapshots are host-tagged so the same collector can run on EVO-STATION and the Windows 365 Cloud PC without file collisions.
- Windows collectors write to `C:\evo\system-health\logs` by default, and WSL reads those snapshots via `/mnt/c/evo/system-health/logs`.
- Retired the old hourly `evo-health.sh` cron entry in favor of the new `system-health` collectors.
- Installed WSL scheduling at 15-minute intervals for `collect-wsl.sh`.
- Installed the WSL summary job on a one-minute offset from the collector to avoid same-minute races.
- Installed the Windows scheduled task `EVO-System-Health-Collector` on EVO-STATION, writing to `C:\evo\system-health\logs`.
- Added a standalone Windows installer build so the same collector can be deployed onto a Windows 365 Cloud PC without depending on WSL paths.
- Added an import path under `/_logs/system-health/import/latest/` so external host snapshots can be merged into the central summary when copied back into this workspace.
- Added `health-alerts.txt`, `trends.json`, and `trends.txt` outputs so the monitor provides active alerts and short-term trend analytics instead of only a point-in-time snapshot.
- Fixed the WSL collector so cron runs do not falsely mark OpenClaw as down when `systemctl --user` lacks a usable user bus.
- Added a lightweight `health-check.sh` command for fast terminal status checks with meaningful exit codes.
- Added a `browser-drain-check.sh` command to validate whether Chrome/Comet memory comes back after the windows are closed.
- Added stateful desktop notification support so merged status escalations to `warn` or `critical` attempt a Windows desktop alert without repeating every cycle.
- Added remediation suggestions to the text alert outputs so alerts explain the next action instead of only naming the problem.
- Added a `storage-check.sh` command so new install or data paths can be checked against the `C:` vs `S:` placement policy.
