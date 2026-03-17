# Storage Policy

This document defines how `C:` and `S:` should be used on EVO-STATION.

## Intent

Use `C:` for Windows itself and lightweight system-managed assets.

Use `S:` for heavy, mutable, high-I/O workloads:

- WSL distro storage
- Docker storage
- local AI models
- datasets
- caches
- scratch space
- large project artifacts

## Current Validated Placement

As of 2026-03-12, the machine is aligned with the intended layout:

- Windows OS: `C:`
- pagefile: `C:\pagefile.sys`
- Ubuntu WSL distro: `S:\WSL_Ubuntu`
- Docker Desktop WSL storage: `S:\WSL\Docker_Storage`
- WSL workspace path: `/home/evo/workspace`
  This lives inside the Ubuntu distro VHDX, so it is effectively `S:`-backed.
- Windows-side monitor assets: `C:\evo\system-health`
  This is small control-plane data and is fine on `C:`.

## Rules

### Put on `C:`

- Windows itself
- pagefile
- normal application binaries where the installer expects the OS drive
- small control-plane scripts and configs
- startup/task-scheduler support files
- lightweight user-profile data that is not performance-sensitive

### Put on `S:`

- WSL distro storage
- Docker images, layers, and volumes
- model weights and large AI assets
- training/inference datasets
- large caches
- scratch workspaces
- temp render/export directories
- large downloads before install/unpack
- Windows-native projects that generate heavy build or media output

### Avoid

- Running hot Linux dev workloads from `/mnt/c/...`
- Putting Docker or WSL VHDX files on `C:`
- Storing large mutable AI/model data on `C:`
- Letting temporary scratch output quietly accumulate on `C:`

## Practical Guidance

### Linux / WSL work

- Prefer `/home/evo/...`
- Prefer `/home/evo/workspace/...`
- Avoid active builds, containers, or model work from `/mnt/c/...`

### Windows installs

- Small normal apps: `C:` is fine
- Large tools with substantial data roots: install binaries where needed, but move the data/cache/model store to `S:` if the app supports it

### Docker

- Keep Docker Desktop storage on `S:`
- Keep large volumes and bind-mounted bulk data on `S:`-backed paths

### Models

- If models are used from WSL, keep them in WSL paths backed by the `S:` distro
- If models are used from Windows-native apps, prefer an `S:` path for the model store

### Archives and media

- Large archives, exports, renders, and datasets belong on `S:`
- `C:` should not become a bulk-storage dumping ground

## Decision Rule

If something is:

- boot-critical
- OS-managed
- small
- low-churn

then `C:` is acceptable.

If something is:

- large
- write-heavy
- cache-like
- model/data oriented
- container or WSL related

then it belongs on `S:`.

## Quick Checks

- `Ubuntu` base path should stay on `S:`
- Docker storage should stay on `S:`
- Pagefile on `C:` is acceptable
- Active WSL development should stay under `/home/evo/...`

Quick policy command:

- `/_scripts/storage-check.sh`

Examples:

```bash
/home/evo/workspace/_scripts/storage-check.sh
/home/evo/workspace/_scripts/storage-check.sh "C:\\Models" --kind model
/home/evo/workspace/_scripts/storage-check.sh "/mnt/c/Users/Evo/Downloads/big-cache" --kind cache
```

## If Installing Something New

Ask:

1. Is this mostly binaries and OS integration?
   If yes, `C:` is usually fine.
2. Is this mostly data, cache, models, containers, or scratch output?
   If yes, put it on `S:`.
3. Is this Linux-side work?
   If yes, keep it inside WSL paths, not `/mnt/c/...`.
