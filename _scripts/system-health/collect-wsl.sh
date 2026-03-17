#!/usr/bin/env bash

set -euo pipefail

python3 <<'PY'
import datetime as dt
import json
import os
import pathlib
import platform
import pwd
import re
import shutil
import socket
import subprocess
import sys

WORKSPACE_ROOT = pathlib.Path("/home/evo/workspace")
LOG_DIR = WORKSPACE_ROOT / "_logs" / "system-health"
LATEST_DIR = LOG_DIR / "latest"
for path in (LOG_DIR, LATEST_DIR):
    path.mkdir(parents=True, exist_ok=True)


def run_command(args: list[str], env: dict[str, str] | None = None) -> tuple[int, str, str]:
    result = subprocess.run(args, capture_output=True, text=True, env=env)
    return result.returncode, result.stdout.strip(), result.stderr.strip()


def machine_key(value: str) -> str:
    key = re.sub(r"[^a-z0-9]+", "-", value.lower()).strip("-")
    return key or "unknown"


def to_mb(kb_value: int) -> int:
    return int(round(kb_value / 1024))


def bytes_to_gb(byte_value: int) -> float:
    return round(byte_value / (1024 ** 3), 2)


def percent(part: float, whole: float) -> float:
    if whole <= 0:
        return 0.0
    return round((part / whole) * 100, 1)


def parse_pressure(path: pathlib.Path) -> dict[str, dict[str, float | int]]:
    metrics: dict[str, dict[str, float | int]] = {}
    if not path.exists():
        return metrics

    for line in path.read_text().splitlines():
        fields = line.split()
        if not fields:
            continue
        mode = fields[0]
        values: dict[str, float | int] = {}
        for item in fields[1:]:
            key, raw_value = item.split("=", 1)
            if key == "total":
                values[key] = int(raw_value)
            else:
                values[key] = float(raw_value)
        metrics[mode] = values
    return metrics


def parse_size_to_mib(value: str) -> float:
    raw = value.strip()
    if not raw:
        return 0.0

    match = re.match(r"^([0-9]+(?:\.[0-9]+)?)\s*([A-Za-z]+)?$", raw)
    if not match:
        return 0.0

    amount = float(match.group(1))
    unit = (match.group(2) or "B").lower()
    factors = {
        "b": 1 / (1024 ** 2),
        "kib": 1 / 1024,
        "kb": 1000 / (1024 ** 2),
        "mib": 1,
        "mb": (1000 ** 2) / (1024 ** 2),
        "gib": 1024,
        "gb": (1000 ** 3) / (1024 ** 2),
        "tib": 1024 ** 2,
        "tb": (1000 ** 4) / (1024 ** 2),
    }
    return amount * factors.get(unit, 0.0)


def read_meminfo() -> dict[str, int]:
    meminfo: dict[str, int] = {}
    for line in pathlib.Path("/proc/meminfo").read_text().splitlines():
        key, value = line.split(":", 1)
        meminfo[key] = int(value.strip().split()[0])
    return meminfo


def disk_snapshot(path_value: str, label: str) -> dict[str, object] | None:
    path = pathlib.Path(path_value)
    if not path.exists():
        return None

    usage = shutil.disk_usage(path)
    used_bytes = usage.total - usage.free
    return {
        "label": label,
        "path": path_value,
        "total_gb": bytes_to_gb(usage.total),
        "used_gb": bytes_to_gb(used_bytes),
        "free_gb": bytes_to_gb(usage.free),
        "used_pct": percent(used_bytes, usage.total),
    }


def top_processes() -> list[dict[str, object]]:
    rc, stdout, _ = run_command(
        ["ps", "-eo", "pid=,user=,%mem=,%cpu=,rss=,args=", "--sort=-rss"]
    )
    if rc != 0 or not stdout:
        return []

    lines = stdout.splitlines()[:10]
    processes: list[dict[str, object]] = []
    for line in lines:
        parts = line.split(None, 5)
        if len(parts) != 6:
            continue
        pid, user, mem_pct, cpu_pct, rss_kb, command = parts
        processes.append(
            {
                "pid": int(pid),
                "user": user,
                "command": command,
                "mem_pct": float(mem_pct),
                "cpu_pct": float(cpu_pct),
                "rss_mb": round(int(rss_kb) / 1024, 1),
            }
        )
    return processes


def docker_snapshot() -> dict[str, object]:
    if shutil.which("docker") is None:
        return {
            "available": False,
            "reason": "docker_not_installed",
            "running_containers": 0,
            "total_memory_mib": 0.0,
            "containers": [],
            "mission_control_detected": False,
        }

    rc_ps, stdout_ps, stderr_ps = run_command(["docker", "ps", "--format", "{{.Names}}"])
    if rc_ps != 0:
        return {
            "available": False,
            "reason": "docker_unavailable",
            "error": stderr_ps,
            "running_containers": 0,
            "total_memory_mib": 0.0,
            "containers": [],
            "mission_control_detected": False,
        }

    container_names = [line for line in stdout_ps.splitlines() if line.strip()]
    rc_stats, stdout_stats, stderr_stats = run_command(
        ["docker", "stats", "--no-stream", "--format", "{{json .}}"]
    )
    containers: list[dict[str, object]] = []
    total_memory_mib = 0.0
    if rc_stats == 0 and stdout_stats:
        for line in stdout_stats.splitlines():
            try:
                item = json.loads(line)
            except json.JSONDecodeError:
                continue
            current_usage = item.get("MemUsage", "").split("/", 1)[0].strip()
            memory_mib = round(parse_size_to_mib(current_usage), 2)
            total_memory_mib += memory_mib
            containers.append(
                {
                    "name": item.get("Name"),
                    "id": item.get("ID"),
                    "mem_usage_raw": item.get("MemUsage"),
                    "mem_usage_mib": memory_mib,
                    "mem_pct": item.get("MemPerc"),
                    "cpu_pct": item.get("CPUPerc"),
                }
            )

    mission_control_detected = any(
        "mission-control" in name.lower() or "mission.control" in name.lower()
        for name in container_names
    )
    return {
        "available": True,
        "running_containers": len(container_names),
        "container_names": container_names,
        "total_memory_mib": round(total_memory_mib, 2),
        "containers": containers,
        "mission_control_detected": mission_control_detected,
        "stats_error": stderr_stats if rc_stats != 0 else "",
    }


def service_snapshot() -> dict[str, object]:
    services: dict[str, object] = {}
    user_env = os.environ.copy()
    runtime_dir = user_env.get("XDG_RUNTIME_DIR") or f"/run/user/{os.getuid()}"
    if pathlib.Path(runtime_dir).exists():
        user_env.setdefault("XDG_RUNTIME_DIR", runtime_dir)
        user_env.setdefault("DBUS_SESSION_BUS_ADDRESS", f"unix:path={runtime_dir}/bus")

    for service_name in ("openclaw-gateway.service",):
        rc, stdout, stderr = run_command(["systemctl", "--user", "is-active", service_name], env=user_env)
        proc_rc, _, _ = run_command(["pgrep", "-x", "openclaw-gateway"])
        active = rc == 0 and stdout == "active"
        if not active and proc_rc == 0:
            active = True
        services[service_name] = {
            "active": active,
            "state": stdout or "unknown",
            "systemctl_rc": rc,
            "systemctl_error": stderr,
            "process_detected": proc_rc == 0,
        }

    rc_port, stdout_port, _ = run_command(["ss", "-tln"])
    services["openclaw_port_18789"] = {
        "listening": rc_port == 0 and ":18789" in stdout_port,
    }
    return services
timestamp = dt.datetime.now(dt.timezone.utc).replace(microsecond=0).isoformat().replace(
    "+00:00", "Z"
)
hostname = socket.gethostname()
key = machine_key(hostname)
username = os.environ.get("USER") or pwd.getpwuid(os.getuid()).pw_name
distro_name = os.environ.get("WSL_DISTRO_NAME", "")
if not distro_name:
    os_release = pathlib.Path("/etc/os-release")
    if os_release.exists():
        for line in os_release.read_text().splitlines():
            if line.startswith("NAME="):
                distro_name = line.split("=", 1)[1].strip().strip('"')
                break
meminfo = read_meminfo()
mem_total_kb = meminfo.get("MemTotal", 0)
mem_available_kb = meminfo.get("MemAvailable", meminfo.get("MemFree", 0))
mem_used_kb = max(mem_total_kb - mem_available_kb, 0)
swap_total_kb = meminfo.get("SwapTotal", 0)
swap_free_kb = meminfo.get("SwapFree", 0)
swap_used_kb = max(swap_total_kb - swap_free_kb, 0)
reclaimable_kb = (
    meminfo.get("Cached", 0) + meminfo.get("Buffers", 0) + meminfo.get("SReclaimable", 0)
)

disks: list[dict[str, object]] = []
for path_value, label in (
    ("/", "root"),
    ("/home/evo/workspace", "workspace"),
    ("/mnt/c", "windows_c_mount"),
    ("/mnt/s", "windows_s_mount"),
):
    snapshot = disk_snapshot(path_value, label)
    if snapshot is not None:
        disks.append(snapshot)

docker = docker_snapshot()
services = service_snapshot()
pressure = {
    "memory": parse_pressure(pathlib.Path("/proc/pressure/memory")),
    "cpu": parse_pressure(pathlib.Path("/proc/pressure/cpu")),
    "io": parse_pressure(pathlib.Path("/proc/pressure/io")),
}

issues: list[dict[str, str]] = []


def add_issue(severity: str, code: str, message: str) -> None:
    issues.append({"severity": severity, "code": code, "message": message})


memory_used_pct = percent(mem_used_kb, mem_total_kb)
swap_used_pct = percent(swap_used_kb, swap_total_kb)
workspace_disk = next((item for item in disks if item["label"] == "workspace"), None)

if memory_used_pct >= 90:
    add_issue("critical", "wsl_memory_high", f"WSL memory used is {memory_used_pct}%.")
elif memory_used_pct >= 80:
    add_issue("warn", "wsl_memory_elevated", f"WSL memory used is {memory_used_pct}%.")

if swap_total_kb > 0:
    if swap_used_pct >= 80:
        add_issue("critical", "wsl_swap_high", f"Swap used is {swap_used_pct}%.")
    elif swap_used_pct >= 50:
        add_issue("warn", "wsl_swap_elevated", f"Swap used is {swap_used_pct}%.")

if workspace_disk is not None:
    if workspace_disk["used_pct"] >= 90:
        add_issue(
            "critical",
            "workspace_disk_high",
            f"Workspace disk used is {workspace_disk['used_pct']}%.",
        )
    elif workspace_disk["used_pct"] >= 80:
        add_issue(
            "warn",
            "workspace_disk_elevated",
            f"Workspace disk used is {workspace_disk['used_pct']}%.",
        )

openclaw_service = services.get("openclaw-gateway.service", {})
openclaw_port = services.get("openclaw_port_18789", {})
if not openclaw_service.get("active", False) and not openclaw_port.get("listening", False):
    add_issue("critical", "openclaw_inactive", "openclaw-gateway.service is not active.")
elif not openclaw_service.get("active", False) and openclaw_port.get("listening", False):
    add_issue(
        "warn",
        "openclaw_service_unconfirmed",
        "OpenClaw port is listening, but the user service manager did not confirm service state.",
    )

severity_rank = {"ok": 0, "warn": 1, "critical": 2}
overall_status = "ok"
for issue in issues:
    if severity_rank[issue["severity"]] > severity_rank[overall_status]:
        overall_status = issue["severity"]

snapshot = {
    "ts": timestamp,
    "source": "wsl",
    "collector": {
        "name": "collect-wsl.sh",
        "version": "0.1.0",
    },
    "host": {
        "hostname": hostname,
        "machine_key": key,
        "user": username,
        "distro": distro_name,
        "kernel_release": platform.release(),
        "platform": platform.platform(),
    },
    "memory": {
        "total_mb": to_mb(mem_total_kb),
        "available_mb": to_mb(mem_available_kb),
        "used_mb": to_mb(mem_used_kb),
        "used_pct": memory_used_pct,
        "reclaimable_mb": to_mb(reclaimable_kb),
        "swap_total_mb": to_mb(swap_total_kb),
        "swap_used_mb": to_mb(swap_used_kb),
        "swap_used_pct": swap_used_pct,
    },
    "pressure": pressure,
    "disks": disks,
    "docker": docker,
    "services": services,
    "processes": {
        "top_rss": top_processes(),
    },
    "health": {
        "status": overall_status,
        "issues": issues,
    },
}

jsonl_path = LOG_DIR / f"wsl-{key}.jsonl"
latest_json_path = LATEST_DIR / f"wsl-{key}.json"
json_line = json.dumps(snapshot, sort_keys=True)
with jsonl_path.open("a", encoding="utf-8") as handle:
    handle.write(json_line + "\n")
latest_json_path.write_text(json.dumps(snapshot, indent=2, sort_keys=True) + "\n", encoding="utf-8")

print(
    json.dumps(
        {
            "status": overall_status,
            "jsonl": str(jsonl_path),
            "latest_json": str(latest_json_path),
        }
    )
)
PY
