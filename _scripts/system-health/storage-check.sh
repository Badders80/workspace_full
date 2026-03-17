#!/usr/bin/env bash

set -euo pipefail

python3 - "$@" <<'PY'
from __future__ import annotations

import json
import pathlib
import re
import shutil
import subprocess
import sys


def run_powershell(script: str) -> dict:
    result = subprocess.run(
        ["powershell.exe", "-NoProfile", "-Command", script],
        capture_output=True,
        text=True,
        check=False,
    )
    if result.returncode != 0:
        return {}
    try:
        return json.loads(result.stdout)
    except json.JSONDecodeError:
        return {}


def get_machine_facts() -> dict:
    windows = run_powershell(
        r"""
$ubuntu = Get-ChildItem 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Lxss' | ForEach-Object {
    $p = Get-ItemProperty $_.PSPath
    if ($p.DistributionName -eq 'Ubuntu') {
        [pscustomobject]@{
            Name = $p.DistributionName
            BasePath = $p.BasePath
        }
    }
}
$page = Get-CimInstance Win32_PageFileUsage | Select-Object Name, AllocatedBaseSize, CurrentUsage, PeakUsage
[pscustomobject]@{
    Ubuntu = $ubuntu
    PageFile = $page
} | ConvertTo-Json -Depth 6 -Compress
"""
    )

    docker_paths: list[str] = []
    windows_latest = pathlib.Path("/mnt/c/evo/system-health/logs/latest/windows-evo-station.json")
    if windows_latest.exists():
        try:
            latest_data = json.loads(windows_latest.read_text(encoding="utf-8-sig"))
            for item in latest_data.get("wsl", {}).get("vhdx", []):
                path_value = item.get("full_name")
                if path_value:
                    docker_paths.append(path_value)
        except json.JSONDecodeError:
            pass

    drive_usage: dict[str, dict[str, float]] = {}
    for mount, label in (("/mnt/c", "C:"), ("/mnt/s", "S:")):
        path = pathlib.Path(mount)
        if path.exists():
            usage = shutil.disk_usage(path)
            used = usage.total - usage.free
            drive_usage[label] = {
                "used_pct": round((used / usage.total) * 100, 1) if usage.total else 0.0,
                "free_gb": round(usage.free / (1024 ** 3), 2),
            }

    return {
        "ubuntu_base_path": (windows.get("Ubuntu") or {}).get("BasePath"),
        "pagefile_path": (windows.get("PageFile") or {}).get("Name"),
        "docker_paths": docker_paths,
        "drive_usage": drive_usage,
    }


HEAVY_KINDS = {"wsl", "docker", "model", "cache", "scratch", "data", "dataset", "project"}
LIGHT_KINDS = {"binary", "tooling", "control-plane"}


def infer_kind(path_value: str) -> str:
    lowered = path_value.lower()
    keyword_map = [
        ("docker", "docker"),
        ("wsl", "wsl"),
        ("model", "model"),
        ("cache", "cache"),
        ("scratch", "scratch"),
        ("dataset", "dataset"),
        ("data", "data"),
        ("pagefile", "pagefile"),
        ("workspace", "project"),
        ("/home/evo", "project"),
        ("program files", "binary"),
        ("system-health", "control-plane"),
    ]
    for needle, kind in keyword_map:
        if needle in lowered:
            return kind
    if re.match(r"^[A-Za-z]:\\", path_value):
        return "binary"
    return "project"


def classify_backing(path_value: str, ubuntu_base_path: str | None) -> tuple[str, str]:
    if path_value.startswith("/mnt/c") or re.match(r"^[cC]:\\", path_value):
        return "C:", "direct"
    if path_value.startswith("/mnt/s") or re.match(r"^[sS]:\\", path_value):
        return "S:", "direct"
    if path_value.startswith("/home/") or path_value.startswith("/root/"):
        if ubuntu_base_path and re.match(r"^[sS]:\\", ubuntu_base_path):
            return "S:", "via_wsl_distro"
        if ubuntu_base_path and re.match(r"^[cC]:\\", ubuntu_base_path):
            return "C:", "via_wsl_distro"
        return "unknown", "via_wsl_distro"
    return "unknown", "unknown"


def evaluate(path_value: str, kind: str, ubuntu_base_path: str | None) -> dict[str, str]:
    drive, mode = classify_backing(path_value, ubuntu_base_path)
    status = "ok"
    message = "Placement matches current policy."

    if kind in {"wsl", "docker"} and drive == "C:":
        status = "critical"
        message = "WSL/Docker on C: will compete with the OS drive and should be moved to S:."
    elif kind in HEAVY_KINDS and drive == "C:":
        status = "warn"
        message = "Heavy mutable data on C: is allowed but not preferred; S: is the better target."
    elif kind == "pagefile" and drive != "C:":
        status = "warn"
        message = "Current policy keeps the pagefile on C: unless there is a specific reason to move it."
    elif kind in LIGHT_KINDS and drive == "C:":
        status = "ok"
        message = "Small binaries/control-plane assets are fine on C:."
    elif kind in HEAVY_KINDS and drive == "S:":
        status = "ok"
        message = "This is the preferred placement for heavy mutable data."
    elif drive == "unknown":
        status = "warn"
        message = "Could not map this path to C:, S:, or WSL-backed storage."

    backing = drive if mode == "direct" else f"{drive} ({mode})"
    return {
        "status": status,
        "path": path_value,
        "kind": kind,
        "backing": backing,
        "message": message,
    }


def print_result(item: dict[str, str]) -> None:
    print(f"{item['status']} path={item['path']} kind={item['kind']} backing={item['backing']}")
    print(f"  {item['message']}")


args = sys.argv[1:]
json_mode = False
kind_override: str | None = None
paths: list[str] = []

idx = 0
while idx < len(args):
    arg = args[idx]
    if arg == "--json":
        json_mode = True
    elif arg == "--kind":
        idx += 1
        if idx >= len(args):
            print("missing value for --kind", file=sys.stderr)
            sys.exit(64)
        kind_override = args[idx]
    else:
        paths.append(arg)
    idx += 1

facts = get_machine_facts()
ubuntu_base_path = facts.get("ubuntu_base_path")

if not paths:
    results = [
        evaluate(ubuntu_base_path or "unknown", "wsl", ubuntu_base_path),
        evaluate("/home/evo/workspace", "project", ubuntu_base_path),
        evaluate(facts.get("pagefile_path") or "unknown", "pagefile", ubuntu_base_path),
    ]
    for docker_path in facts.get("docker_paths", []):
        results.append(evaluate(docker_path, "docker", ubuntu_base_path))

    if json_mode:
        print(
            json.dumps(
                {
                    "facts": facts,
                    "results": results,
                },
                indent=2,
                sort_keys=True,
            )
        )
        sys.exit(0)

    print("Storage policy check")
    print()
    for result in results:
        print_result(result)
    print()
    print("Drive usage")
    for drive_label in ("C:", "S:"):
        drive = facts.get("drive_usage", {}).get(drive_label)
        if drive:
            print(f"  {drive_label} used={drive['used_pct']}% free={drive['free_gb']}GB")
    print()
    print("Policy")
    print("  C: OS, pagefile, small binaries, control-plane files")
    print("  S: WSL, Docker, models, caches, datasets, scratch, heavy mutable data")
    sys.exit(0)

results = []
for path_value in paths:
    kind = kind_override or infer_kind(path_value)
    results.append(evaluate(path_value, kind, ubuntu_base_path))

worst = max({"ok": 0, "warn": 1, "critical": 2}[item["status"]] for item in results)
if json_mode:
    print(json.dumps({"facts": facts, "results": results}, indent=2, sort_keys=True))
else:
    for result in results:
        print_result(result)

sys.exit(worst)
PY
