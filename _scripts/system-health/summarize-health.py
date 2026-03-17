#!/usr/bin/env python3

from __future__ import annotations

import datetime as dt
import json
import re
import subprocess
from pathlib import Path


WORKSPACE_LOG_DIR = Path("/home/evo/workspace/_logs/system-health")
WORKSPACE_LATEST_DIR = WORKSPACE_LOG_DIR / "latest"
WORKSPACE_IMPORT_DIR = WORKSPACE_LOG_DIR / "import"
WINDOWS_LOG_DIR = Path("/mnt/c/evo/system-health/logs")
WINDOWS_LATEST_DIR = WINDOWS_LOG_DIR / "latest"
NOTIFY_STATE_PATH = WORKSPACE_LOG_DIR / "notification-state.json"
NOTIFY_LOG_PATH = WORKSPACE_LOG_DIR / "notification-log.jsonl"

METRIC_DEFS: dict[str, dict[str, tuple[str, str]]] = {
    "windows": {
        "physical_used_pct": ("Host RAM", "%"),
        "commit_used_pct": ("Commit", "%"),
        "vmmem_working_set_gb": ("VmmemWSL", "GiB"),
        "c_drive_used_pct": ("C drive", "%"),
        "s_drive_used_pct": ("S drive", "%"),
    },
    "wsl": {
        "used_pct": ("WSL RAM", "%"),
        "swap_used_pct": ("WSL swap", "%"),
        "workspace_used_pct": ("Workspace disk", "%"),
        "docker_total_memory_mib": ("Docker memory", "MiB"),
        "memory_pressure_avg10": ("PSI memory avg10", "%"),
    },
}

HIGHLIGHT_METRICS: dict[str, list[str]] = {
    "windows": ["physical_used_pct", "vmmem_working_set_gb", "commit_used_pct"],
    "wsl": ["used_pct", "workspace_used_pct", "docker_total_memory_mib"],
}

REMEDIATIONS: dict[str, str] = {
    "windows_memory_high": "Close large browser/app workloads first, then re-run /home/evo/workspace/_scripts/health-check.sh to confirm host RAM fell.",
    "windows_memory_elevated": "Check Chrome/Comet and other desktop apps before changing WSL limits; host-side apps are usually the fastest win.",
    "windows_commit_high": "Reduce heavy host apps or memory-hungry local models; sustained high commit means the box is leaning on virtual memory.",
    "windows_commit_elevated": "Watch commit alongside host RAM; if both keep climbing, trim desktop workloads before opening more local AI jobs.",
    "windows_drive_high": "Move large mutable stores, caches, or model data off the pressured drive and keep fast scratch workloads on S: where possible.",
    "windows_drive_elevated": "Review large folders and caches on the affected drive before it becomes a bottleneck.",
    "wsl_memory_high": "Inspect active WSL jobs and local models; if the load is intentional, keep watching VmmemWSL and commit on the Windows side too.",
    "wsl_memory_elevated": "Check recent WSL workloads and consider stopping idle model servers or long-running jobs.",
    "wsl_swap_high": "Reduce WSL memory pressure immediately; heavy swap usually means real guest pressure, not harmless cache.",
    "wsl_swap_elevated": "WSL has started leaning on swap; stop nonessential guest workloads before latency rises.",
    "workspace_disk_high": "Clean large work artifacts or move bulky datasets/models to S-backed storage before workspace writes slow down.",
    "workspace_disk_elevated": "Review large project, cache, and model directories before the workspace disk becomes constrained.",
    "openclaw_inactive": "Restart or inspect openclaw-gateway.service and confirm port 18789 is listening again.",
    "openclaw_service_unconfirmed": "If this came from cron, verify the OpenClaw port and service interactively; the user service bus may be unavailable even when the process is healthy.",
    "snapshot_stale": "Check whether the collector schedule is still installed and whether the relevant task or cron job is running.",
    "snapshot_aging": "Watch the next scheduled run; if freshness keeps slipping, inspect the scheduler before trusting the alerts.",
    "wslconfig_missing": "Create C:\\Users\\<user>\\.wslconfig with explicit memory and processor limits so WSL stays predictable under load.",
    "vhdx_on_c": "Move heavy WSL storage off C: if possible so Linux and Docker I/O do not compete with the OS drive.",
}


def machine_key(value: str) -> str:
    key = re.sub(r"[^a-z0-9]+", "-", value.lower()).strip("-")
    return key or "unknown"


def parse_ts(raw_value: str | None) -> dt.datetime | None:
    if not raw_value:
        return None
    try:
        return dt.datetime.fromisoformat(raw_value.replace("Z", "+00:00"))
    except ValueError:
        return None


def load_json(path: Path) -> dict | None:
    try:
        return json.loads(path.read_text(encoding="utf-8-sig"))
    except (json.JSONDecodeError, OSError):
        return None


def load_latest_snapshots() -> list[dict]:
    snapshots: list[dict] = []
    seen_paths: set[Path] = set()

    for directory in (WORKSPACE_LATEST_DIR, WINDOWS_LATEST_DIR):
        if not directory.exists():
            continue
        for path in sorted(directory.glob("*.json")):
            if path in seen_paths:
                continue
            seen_paths.add(path)
            data = load_json(path)
            if data is not None:
                snapshots.append(data)

    if WORKSPACE_IMPORT_DIR.exists():
        for path in sorted(WORKSPACE_IMPORT_DIR.rglob("*.json")):
            if path in seen_paths:
                continue
            seen_paths.add(path)
            data = load_json(path)
            if data is not None:
                snapshots.append(data)

    return snapshots


def load_history_snapshots() -> list[dict]:
    snapshots: list[dict] = []
    for directory in (WORKSPACE_LOG_DIR, WINDOWS_LOG_DIR):
        if not directory.exists():
            continue
        for path in sorted(directory.glob("*.jsonl")):
            try:
                with path.open(encoding="utf-8-sig") as handle:
                    for line in handle:
                        line = line.strip()
                        if not line:
                            continue
                        try:
                            snapshots.append(json.loads(line))
                        except json.JSONDecodeError:
                            continue
            except OSError:
                continue

    if WORKSPACE_IMPORT_DIR.exists():
        for path in sorted(WORKSPACE_IMPORT_DIR.rglob("*.jsonl")):
            try:
                with path.open(encoding="utf-8-sig") as handle:
                    for line in handle:
                        line = line.strip()
                        if not line:
                            continue
                        try:
                            snapshots.append(json.loads(line))
                        except json.JSONDecodeError:
                            continue
            except OSError:
                continue

    return snapshots


def severity_rank(value: str) -> int:
    return {"ok": 0, "warn": 1, "critical": 2}.get(value, 0)


def issue(severity: str, code: str, message: str) -> dict[str, str]:
    return {"severity": severity, "code": code, "message": message}


def enrich_issue(item: dict[str, str]) -> dict[str, str]:
    enriched = dict(item)
    enriched["suggestion"] = REMEDIATIONS.get(item["code"], "Inspect the affected metric and rerun the health check after the change.")
    return enriched


def get_drive(snapshot: dict, device: str) -> dict:
    for item in snapshot.get("drives", []):
        label = item.get("device", item.get("label"))
        if label == device:
            return item
    return {}


def get_workspace_disk(snapshot: dict) -> dict:
    for item in snapshot.get("disks", []):
        if item.get("label") == "workspace":
            return item
    return {}


def collector_issues(snapshot: dict) -> list[dict[str, str]]:
    raw_issues = snapshot.get("health", {}).get("issues", [])
    issues: list[dict[str, str]] = []
    for item in raw_issues:
        if not isinstance(item, dict):
            continue
        severity = item.get("severity")
        code = item.get("code")
        message = item.get("message")
        if not severity or not code or not message:
            continue
        issues.append(enrich_issue({"severity": str(severity), "code": str(code), "message": str(message)}))
    return issues


def fallback_windows_issues(snapshot: dict) -> list[dict[str, str]]:
    issues: list[dict[str, str]] = []
    memory = snapshot.get("memory", {})
    physical_pct = float(memory.get("physical_used_pct", 0))
    commit_pct = float(memory.get("commit_used_pct", 0))
    if physical_pct >= 90:
        issues.append(enrich_issue(issue("critical", "windows_memory_high", f"Windows memory used is {physical_pct}%.")))
    elif physical_pct >= 80:
        issues.append(enrich_issue(issue("warn", "windows_memory_elevated", f"Windows memory used is {physical_pct}%.")))
    if commit_pct >= 90:
        issues.append(enrich_issue(issue("critical", "windows_commit_high", f"Commit used is {commit_pct}%.")))
    elif commit_pct >= 80:
        issues.append(enrich_issue(issue("warn", "windows_commit_elevated", f"Commit used is {commit_pct}%.")))
    return issues


def fallback_wsl_issues(snapshot: dict) -> list[dict[str, str]]:
    issues: list[dict[str, str]] = []
    memory = snapshot.get("memory", {})
    mem_pct = float(memory.get("used_pct", 0))
    swap_pct = float(memory.get("swap_used_pct", 0))
    if mem_pct >= 90:
        issues.append(enrich_issue(issue("critical", "wsl_memory_high", f"WSL memory used is {mem_pct}%.")))
    elif mem_pct >= 80:
        issues.append(enrich_issue(issue("warn", "wsl_memory_elevated", f"WSL memory used is {mem_pct}%.")))
    if swap_pct >= 80:
        issues.append(enrich_issue(issue("critical", "wsl_swap_high", f"WSL swap used is {swap_pct}%.")))
    elif swap_pct >= 50:
        issues.append(enrich_issue(issue("warn", "wsl_swap_elevated", f"WSL swap used is {swap_pct}%.")))
    return issues


def snapshot_summary(snapshot: dict, generated_at: dt.datetime) -> dict:
    issues = collector_issues(snapshot)
    if not issues:
        source = snapshot.get("source", "unknown")
        issues = fallback_windows_issues(snapshot) if source == "windows" else fallback_wsl_issues(snapshot)

    age_minutes: int | None = None
    ts = parse_ts(snapshot.get("ts"))
    if ts is not None:
        age_minutes = int((generated_at - ts).total_seconds() // 60)
        if age_minutes >= 90:
            issues.append(
                enrich_issue(
                    issue(
                    "critical",
                    "snapshot_stale",
                    f"{snapshot.get('source', 'snapshot')} snapshot is {age_minutes} minutes old.",
                    )
                )
            )
        elif age_minutes >= 30:
            issues.append(
                enrich_issue(
                    issue(
                    "warn",
                    "snapshot_aging",
                    f"{snapshot.get('source', 'snapshot')} snapshot is {age_minutes} minutes old.",
                    )
                )
            )

    status = "ok"
    for item in issues:
        if severity_rank(item["severity"]) > severity_rank(status):
            status = item["severity"]

    return {"status": status, "issues": issues, "age_minutes": age_minutes}


def history_index(snapshots: list[dict]) -> dict[str, dict[str, list[dict]]]:
    grouped: dict[str, dict[str, list[dict]]] = {}
    for snapshot in snapshots:
        host = snapshot.get("host", {})
        key = host.get("machine_key") or machine_key(host.get("hostname", "unknown"))
        source = snapshot.get("source", "unknown")
        grouped.setdefault(key, {}).setdefault(source, []).append(snapshot)

    for sources in grouped.values():
        for items in sources.values():
            items.sort(key=lambda item: parse_ts(item.get("ts")) or dt.datetime.min.replace(tzinfo=dt.timezone.utc))
    return grouped


def extract_metrics(snapshot: dict) -> dict[str, float]:
    source = snapshot.get("source")
    if source == "windows":
        memory = snapshot.get("memory", {})
        c_drive = get_drive(snapshot, "C:")
        s_drive = get_drive(snapshot, "S:")
        return {
            "physical_used_pct": float(memory.get("physical_used_pct", 0)),
            "commit_used_pct": float(memory.get("commit_used_pct", 0)),
            "vmmem_working_set_gb": float(snapshot.get("wsl", {}).get("vmmem_working_set_gb", 0)),
            "c_drive_used_pct": float(c_drive.get("used_pct", 0)),
            "s_drive_used_pct": float(s_drive.get("used_pct", 0)),
        }

    if source == "wsl":
        memory = snapshot.get("memory", {})
        pressure = snapshot.get("pressure", {}).get("memory", {}).get("some", {})
        workspace = get_workspace_disk(snapshot)
        docker = snapshot.get("docker", {})
        return {
            "used_pct": float(memory.get("used_pct", 0)),
            "swap_used_pct": float(memory.get("swap_used_pct", 0)),
            "workspace_used_pct": float(workspace.get("used_pct", 0)),
            "docker_total_memory_mib": float(docker.get("total_memory_mib", 0)),
            "memory_pressure_avg10": float(pressure.get("avg10", 0)),
        }

    return {}


def metric_precision(metric_name: str) -> int:
    if metric_name.endswith("_mib"):
        return 2
    if metric_name.endswith("_gb"):
        return 2
    return 1


def metric_tolerance(metric_name: str) -> float:
    if metric_name.endswith("_mib"):
        return 10.0
    if metric_name.endswith("_gb"):
        return 0.1
    return 1.0


def round_metric(metric_name: str, value: float) -> float:
    return round(value, metric_precision(metric_name))


def format_metric(metric_name: str, value: float) -> str:
    source = "windows" if metric_name in METRIC_DEFS["windows"] else "wsl"
    _, unit = METRIC_DEFS[source][metric_name]
    rounded = round_metric(metric_name, value)
    return f"{rounded}{unit}"


def summarize_metric(metric_name: str, values: list[float]) -> dict[str, object]:
    latest = values[-1]
    first = values[0]
    minimum = min(values)
    maximum = max(values)
    average = sum(values) / len(values)
    delta = latest - first
    tolerance = metric_tolerance(metric_name)
    if abs(delta) < tolerance:
        trend = "flat"
    elif delta > 0:
        trend = "up"
    else:
        trend = "down"

    return {
        "latest": round_metric(metric_name, latest),
        "avg": round_metric(metric_name, average),
        "min": round_metric(metric_name, minimum),
        "max": round_metric(metric_name, maximum),
        "delta": round_metric(metric_name, delta),
        "trend": trend,
    }


def build_source_trends(source: str, history: list[dict], generated_at: dt.datetime) -> dict[str, dict]:
    windows = {
        "last_hour": generated_at - dt.timedelta(hours=1),
        "last_day": generated_at - dt.timedelta(days=1),
    }
    trends: dict[str, dict] = {}

    for window_name, start in windows.items():
        records: list[tuple[dt.datetime, dict[str, float]]] = []
        for snapshot in history:
            ts = parse_ts(snapshot.get("ts"))
            if ts is None or ts < start:
                continue
            records.append((ts, extract_metrics(snapshot)))

        metrics: dict[str, dict] = {}
        for metric_name in METRIC_DEFS.get(source, {}):
            values = [record[1][metric_name] for record in records if metric_name in record[1]]
            if not values:
                continue
            metrics[metric_name] = summarize_metric(metric_name, values)

        trends[window_name] = {
            "samples": len(records),
            "metrics": metrics,
            "start": start.replace(microsecond=0).isoformat().replace("+00:00", "Z"),
        }
        if records:
            trends[window_name]["latest_ts"] = (
                records[-1][0].replace(microsecond=0).isoformat().replace("+00:00", "Z")
            )

    return trends


def format_trend_line(source: str, metric_name: str, data: dict[str, object]) -> str:
    label, _ = METRIC_DEFS[source][metric_name]
    return (
        f"{label}: latest={format_metric(metric_name, float(data['latest']))} "
        f"avg={format_metric(metric_name, float(data['avg']))} "
        f"max={format_metric(metric_name, float(data['max']))} "
        f"delta={format_metric(metric_name, float(data['delta']))} "
        f"trend={data['trend']}"
    )


def build_machine_summaries(latest_snapshots: list[dict], history: list[dict], generated_at: dt.datetime) -> list[dict]:
    grouped: dict[str, dict] = {}
    for snapshot in latest_snapshots:
        host = snapshot.get("host", {})
        key = host.get("machine_key") or machine_key(host.get("hostname", "unknown"))
        machine = grouped.setdefault(
            key,
            {
                "machine_key": key,
                "hostnames": [],
                "sources": {},
            },
        )
        hostname = host.get("hostname")
        if hostname and hostname not in machine["hostnames"]:
            machine["hostnames"].append(hostname)
        machine["sources"][snapshot.get("source", "unknown")] = snapshot

    history_by_machine = history_index(history)
    machine_summaries: list[dict] = []

    for key in sorted(grouped):
        machine = grouped[key]
        combined_issues: list[dict[str, str]] = []
        source_status: dict[str, dict] = {}
        status = "ok"

        for source_name, snapshot in machine["sources"].items():
            source_result = snapshot_summary(snapshot, generated_at)
            source_issues = [{**item, "source": source_name} for item in source_result["issues"]]
            combined_issues.extend(source_issues)
            source_status[source_name] = {
                "status": source_result["status"],
                "ts": snapshot.get("ts"),
                "age_minutes": source_result["age_minutes"],
                "trends": build_source_trends(
                    source_name,
                    history_by_machine.get(key, {}).get(source_name, []),
                    generated_at,
                ),
            }
            if severity_rank(source_result["status"]) > severity_rank(status):
                status = source_result["status"]

        machine_summaries.append(
            {
                "machine_key": key,
                "hostnames": machine["hostnames"],
                "sources_present": sorted(machine["sources"].keys()),
                "status": status,
                "issues": combined_issues,
                "source_status": source_status,
                "snapshots": machine["sources"],
            }
        )

    return machine_summaries


def build_alert_lines(machine_summaries: list[dict]) -> list[str]:
    lines = ["System health alerts"]
    if not machine_summaries:
        lines.extend(["", "No snapshots found."])
        return lines

    alerts: list[str] = []
    for machine in machine_summaries:
        name = ", ".join(machine["hostnames"]) or machine["machine_key"]
        for item in machine["issues"]:
            alerts.append(f"- {item['severity']} {name} [{item['source']}]: {item['message']}")
            alerts.append(f"  suggest: {item['suggestion']}")

    lines.append("")
    if alerts:
        lines.extend(alerts)
    else:
        lines.append("No active alerts.")
    return lines


def build_latest_text(output: dict) -> str:
    machine_summaries = output["machines"]
    lines = ["System health summary", f"Generated: {output['generated_at']}", ""]

    alert_lines = build_alert_lines(machine_summaries)
    lines.extend(alert_lines[1:])
    lines.append("")

    if not machine_summaries:
        lines.append("No snapshots found.")
        return "\n".join(lines).rstrip() + "\n"

    for machine in machine_summaries:
        hostnames = ", ".join(machine["hostnames"]) or machine["machine_key"]
        sources = ", ".join(machine["sources_present"])
        lines.append(f"{hostnames} [{sources}] status={machine['status']}")

        for source_name in machine["sources_present"]:
            snapshot = machine["snapshots"][source_name]
            age = machine["source_status"][source_name].get("age_minutes")
            age_text = f" age={age}m" if age is not None else ""
            if source_name == "wsl":
                memory = snapshot.get("memory", {})
                workspace_disk = get_workspace_disk(snapshot)
                docker = snapshot.get("docker", {})
                lines.append(
                    "  WSL: "
                    f"mem={memory.get('used_pct', 0)}% "
                    f"swap={memory.get('swap_used_pct', 0)}% "
                    f"workspace={workspace_disk.get('used_pct', 0)}% "
                    f"docker={docker.get('running_containers', 0)} "
                    f"containers/{docker.get('total_memory_mib', 0)} MiB"
                    f"{age_text}"
                )
            elif source_name == "windows":
                memory = snapshot.get("memory", {})
                c_drive = get_drive(snapshot, "C:")
                s_drive = get_drive(snapshot, "S:")
                lines.append(
                    "  Windows: "
                    f"mem={memory.get('physical_used_pct', 0)}% "
                    f"commit={memory.get('commit_used_pct', 0)}% "
                    f"vmmem={snapshot.get('wsl', {}).get('vmmem_working_set_gb', 0)} GiB "
                    f"C={c_drive.get('used_pct', 'n/a')}% "
                    f"S={s_drive.get('used_pct', 'n/a')}%"
                    f"{age_text}"
                )

            trend_window = machine["source_status"][source_name]["trends"].get("last_hour", {})
            trend_metrics = trend_window.get("metrics", {})
            highlight_keys = [key for key in HIGHLIGHT_METRICS.get(source_name, []) if key in trend_metrics]
            for metric_name in highlight_keys[:2]:
                lines.append(f"    1h {format_trend_line(source_name, metric_name, trend_metrics[metric_name])}")

        if machine["issues"]:
            for item in machine["issues"]:
                lines.append(f"  - {item['severity']} [{item['source']}]: {item['message']}")
                lines.append(f"    suggest: {item['suggestion']}")
        else:
            lines.append("  - ok: no issues detected")
        lines.append("")

    return "\n".join(lines).rstrip() + "\n"


def build_trends_text(output: dict) -> str:
    lines = ["System health trends", f"Generated: {output['generated_at']}", ""]
    if not output["machines"]:
        lines.append("No snapshots found.")
        return "\n".join(lines).rstrip() + "\n"

    for machine in output["machines"]:
        hostnames = ", ".join(machine["hostnames"]) or machine["machine_key"]
        lines.append(hostnames)
        for source_name in machine["sources_present"]:
            source_trends = machine["source_status"][source_name]["trends"]
            for window_name in ("last_hour", "last_day"):
                window = source_trends.get(window_name, {})
                lines.append(f"  {source_name} {window_name}: samples={window.get('samples', 0)}")
                metrics = window.get("metrics", {})
                if not metrics:
                    lines.append("    - insufficient data")
                    continue
                for metric_name in METRIC_DEFS.get(source_name, {}):
                    if metric_name in metrics:
                        lines.append(
                            f"    - {format_trend_line(source_name, metric_name, metrics[metric_name])}"
                        )
        lines.append("")

    return "\n".join(lines).rstrip() + "\n"


def load_notification_state() -> dict:
    if not NOTIFY_STATE_PATH.exists():
        return {"machines": {}}
    data = load_json(NOTIFY_STATE_PATH)
    if isinstance(data, dict):
        data.setdefault("machines", {})
        return data
    return {"machines": {}}


def save_notification_state(state: dict) -> None:
    NOTIFY_STATE_PATH.write_text(json.dumps(state, indent=2, sort_keys=True) + "\n", encoding="utf-8")


def powershell_escape(value: str) -> str:
    return value.replace("'", "''")


def notify_desktop(title: str, message: str, severity: str) -> bool:
    script = f"""
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
$title = '{powershell_escape(title)}'
$message = '{powershell_escape(message)}'
$severity = '{powershell_escape(severity)}'
try {{
    $notify = New-Object System.Windows.Forms.NotifyIcon
    switch ($severity) {{
        'critical' {{ $notify.Icon = [System.Drawing.SystemIcons]::Error }}
        'warn' {{ $notify.Icon = [System.Drawing.SystemIcons]::Warning }}
        default {{ $notify.Icon = [System.Drawing.SystemIcons]::Information }}
    }}
    $notify.BalloonTipIcon = if ($severity -eq 'critical') {{ 'Error' }} elseif ($severity -eq 'warn') {{ 'Warning' }} else {{ 'Info' }}
    $notify.BalloonTipTitle = $title
    $notify.BalloonTipText = $message
    $notify.Visible = $true
    $notify.ShowBalloonTip(12000)
    Start-Sleep -Seconds 8
    $notify.Dispose()
}}
catch {{
    $msg = "$title`n$message"
    & msg.exe $env:USERNAME /TIME:30 $msg | Out-Null
}}
"""
    try:
        subprocess.run(
            ["powershell.exe", "-NoProfile", "-ExecutionPolicy", "Bypass", "-Command", script],
            check=True,
            capture_output=True,
            text=True,
            timeout=20,
        )
        return True
    except (subprocess.SubprocessError, OSError):
        return False


def process_notifications(output: dict) -> None:
    state = load_notification_state()
    previous = state.get("machines", {})
    new_state = {"machines": {}}
    log_lines: list[str] = []

    for machine in output["machines"]:
        key = machine["machine_key"]
        current_status = machine["status"]
        prev_status = previous.get(key, {}).get("status", "ok")
        new_state["machines"][key] = {
            "status": current_status,
            "generated_at": output["generated_at"],
        }
        if severity_rank(current_status) < 1:
            continue
        if severity_rank(current_status) <= severity_rank(prev_status):
            continue

        hostnames = ", ".join(machine["hostnames"]) or key
        top_issues = machine["issues"][:2]
        message_parts = [f"{item['source']}: {item['message']}" for item in top_issues]
        title = f"System health {current_status}: {hostnames}"
        message = " | ".join(message_parts)[:240]
        delivered = notify_desktop(title, message, current_status)
        log_lines.append(
            json.dumps(
                {
                    "ts": output["generated_at"],
                    "machine_key": key,
                    "status": current_status,
                    "previous_status": prev_status,
                    "delivered": delivered,
                    "title": title,
                    "message": message,
                },
                sort_keys=True,
            )
        )

    save_notification_state(new_state)
    if log_lines:
        with NOTIFY_LOG_PATH.open("a", encoding="utf-8") as handle:
            for line in log_lines:
                handle.write(line + "\n")


def main() -> None:
    generated_at = dt.datetime.now(dt.timezone.utc).replace(microsecond=0)
    WORKSPACE_LOG_DIR.mkdir(parents=True, exist_ok=True)
    WORKSPACE_LATEST_DIR.mkdir(parents=True, exist_ok=True)
    (WORKSPACE_IMPORT_DIR / "latest").mkdir(parents=True, exist_ok=True)

    latest_snapshots = load_latest_snapshots()
    history_snapshots = load_history_snapshots()
    machine_summaries = build_machine_summaries(latest_snapshots, history_snapshots, generated_at)

    output = {
        "generated_at": generated_at.isoformat().replace("+00:00", "Z"),
        "machines": machine_summaries,
    }

    latest_json_path = WORKSPACE_LOG_DIR / "latest.json"
    latest_txt_path = WORKSPACE_LOG_DIR / "latest.txt"
    alerts_txt_path = WORKSPACE_LOG_DIR / "health-alerts.txt"
    trends_json_path = WORKSPACE_LOG_DIR / "trends.json"
    trends_txt_path = WORKSPACE_LOG_DIR / "trends.txt"

    latest_json_path.write_text(json.dumps(output, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    latest_txt_path.write_text(build_latest_text(output), encoding="utf-8")
    alerts_txt_path.write_text("\n".join(build_alert_lines(machine_summaries)).rstrip() + "\n", encoding="utf-8")
    trends_json_path.write_text(json.dumps(output, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    trends_txt_path.write_text(build_trends_text(output), encoding="utf-8")
    process_notifications(output)

    print(
        json.dumps(
            {
                "latest_json": str(latest_json_path),
                "latest_txt": str(latest_txt_path),
                "alerts_txt": str(alerts_txt_path),
                "trends_json": str(trends_json_path),
                "trends_txt": str(trends_txt_path),
                "notify_state": str(NOTIFY_STATE_PATH),
            }
        )
    )


if __name__ == "__main__":
    main()
