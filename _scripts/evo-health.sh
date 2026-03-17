#!/usr/bin/env bash
# =============================================================================
# EVO-HEALTH — Evolution Station System Monitor
# Version: v1.0.0 | 2026-03-12
# Location: /home/evo/workspace/_scripts/evo-health.sh
#
# Checks:
#   - WSL2 RAM (real vs ghost/balloon)
#   - Swap usage
#   - C: drive (Windows OS) usage
#   - S: drive (scratch/NVMe) usage
#   - /home/evo workspace disk usage
#   - Docker memory footprint
#   - Key services (openclaw, mission control)
#   - Top memory consumers
# =============================================================================

set -euo pipefail

# --- Colour codes ---
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
BOLD='\033[1m'
DIM='\033[2m'
RESET='\033[0m'

# --- Thresholds ---
RAM_WARN=75
RAM_CRIT=90
DISK_WARN=75
DISK_CRIT=90

# --- Helpers ---
hr()      { printf "${DIM}%s${RESET}\n" "────────────────────────────────────────────────────"; }
section() { echo; printf "${BOLD}${CYAN}▸ %s${RESET}\n" "$1"; hr; }
ok()      { printf "  ${GREEN}✓${RESET}  %s\n" "$1"; }
warn()    { printf "  ${YELLOW}⚠${RESET}  %s\n" "$1"; }
crit()    { printf "  ${RED}✗${RESET}  %s\n" "$1"; }
info()    { printf "  ${DIM}·${RESET}  %s\n" "$1"; }

check_pct() {
  local label="$1" used="$2" total="$3" unit="${4:-GB}"
  local pct=0
  [[ "$total" -gt 0 ]] && pct=$(( used * 100 / total ))
  local bar=""
  local filled=$(( pct / 5 ))
  local i
  for (( i=0; i<20; i++ )); do
    [[ $i -lt $filled ]] && bar+="█" || bar+="░"
  done

  if   [[ $pct -ge $DISK_CRIT ]]; then
    printf "  ${RED}✗${RESET}  %-28s [%s] %d%% (%d/%d %s)\n" "$label" "$bar" "$pct" "$used" "$total" "$unit"
  elif [[ $pct -ge $DISK_WARN ]]; then
    printf "  ${YELLOW}⚠${RESET}  %-28s [%s] %d%% (%d/%d %s)\n" "$label" "$bar" "$pct" "$used" "$total" "$unit"
  else
    printf "  ${GREEN}✓${RESET}  %-28s [%s] %d%% (%d/%d %s)\n" "$label" "$bar" "$pct" "$used" "$total" "$unit"
  fi
}

# =============================================================================
printf "\n${BOLD}╔══════════════════════════════════════════════╗${RESET}\n"
printf   "${BOLD}║       EVO-STATION HEALTH MONITOR             ║${RESET}\n"
printf   "${BOLD}║       $(date '+%Y-%m-%d %H:%M:%S')                    ║${RESET}\n"
printf   "${BOLD}╚══════════════════════════════════════════════╝${RESET}\n"

# =============================================================================
section "MEMORY — WSL2 RAM (Real vs Ghost)"

# /proc/meminfo gives the real picture inside WSL2
MEM_TOTAL_KB=$(awk '/MemTotal/    {print $2}' /proc/meminfo)
MEM_FREE_KB=$(awk '/MemFree/     {print $2}' /proc/meminfo)
MEM_AVAIL_KB=$(awk '/MemAvailable/{print $2}' /proc/meminfo)
MEM_CACHED_KB=$(awk '/^Cached/    {print $2}' /proc/meminfo)
MEM_BUFFERS_KB=$(awk '/^Buffers/  {print $2}' /proc/meminfo)
SWAP_TOTAL_KB=$(awk '/SwapTotal/  {print $2}' /proc/meminfo)
SWAP_FREE_KB=$(awk '/SwapFree/   {print $2}' /proc/meminfo)

MEM_TOTAL_GB=$(( MEM_TOTAL_KB / 1024 / 1024 ))
MEM_AVAIL_GB=$(( MEM_AVAIL_KB / 1024 / 1024 ))
MEM_USED_GB=$(( (MEM_TOTAL_KB - MEM_AVAIL_KB) / 1024 / 1024 ))
MEM_CACHED_GB=$(( (MEM_CACHED_KB + MEM_BUFFERS_KB) / 1024 / 1024 ))
MEM_REAL_USED_GB=$(( MEM_USED_GB - MEM_CACHED_GB ))
[[ $MEM_REAL_USED_GB -lt 0 ]] && MEM_REAL_USED_GB=0

SWAP_USED_GB=0
SWAP_TOTAL_GB=0
if [[ "$SWAP_TOTAL_KB" -gt 0 ]]; then
  SWAP_TOTAL_GB=$(( SWAP_TOTAL_KB / 1024 / 1024 ))
  SWAP_USED_GB=$(( (SWAP_TOTAL_KB - SWAP_FREE_KB) / 1024 / 1024 ))
fi

check_pct "RAM (reported used)"  "$MEM_USED_GB"      "$MEM_TOTAL_GB"  "GB"
check_pct "RAM (real processes)" "$MEM_REAL_USED_GB" "$MEM_TOTAL_GB"  "GB"
info "Cache/buffers (reclaimable): ${MEM_CACHED_GB}GB — this is the 'ghost' WSL reports as used"

if [[ "$SWAP_TOTAL_GB" -gt 0 ]]; then
  check_pct "Swap" "$SWAP_USED_GB" "$SWAP_TOTAL_GB" "GB"
else
  info "Swap: not configured"
fi

# Ghost RAM explanation
GHOST_GB=$(( MEM_USED_GB - MEM_REAL_USED_GB ))
if [[ $GHOST_GB -gt 2 ]]; then
  warn "Ghost RAM detected: ~${GHOST_GB}GB held by kernel cache (safe to reclaim)"
  info "To reclaim: echo 3 | sudo tee /proc/sys/vm/drop_caches"
fi

# =============================================================================
section "DISK — Drives"

# WSL internal
WSL_DISK=$(df -BG /home/evo/workspace 2>/dev/null | awk 'NR==2{gsub("G","",$2); gsub("G","",$3); print $3" "$2}')
WSL_USED=$(echo "$WSL_DISK" | awk '{print $1}')
WSL_TOTAL=$(echo "$WSL_DISK" | awk '{print $2}')
check_pct "/home/evo/workspace (WSL)" "$WSL_USED" "$WSL_TOTAL" "GB"

# C: drive (Windows OS)
if [[ -d /mnt/c ]]; then
  C_DISK=$(df -BG /mnt/c 2>/dev/null | awk 'NR==2{gsub("G","",$2); gsub("G","",$3); print $3" "$2}')
  C_USED=$(echo "$C_DISK" | awk '{print $1}')
  C_TOTAL=$(echo "$C_DISK" | awk '{print $2}')
  check_pct "C:\\ (Windows OS)" "$C_USED" "$C_TOTAL" "GB"
else
  warn "C:\\ not mounted at /mnt/c"
fi

# S: drive (scratch NVMe)
if [[ -d /mnt/s ]]; then
  S_DISK=$(df -BG /mnt/s 2>/dev/null | awk 'NR==2{gsub("G","",$2); gsub("G","",$3); print $3" "$2}')
  S_USED=$(echo "$S_DISK" | awk '{print $1}')
  S_TOTAL=$(echo "$S_DISK" | awk '{print $2}')
  check_pct "S:\\ (scratch NVMe)" "$S_USED" "$S_TOTAL" "GB"
  # Check WSL vhd location
  if [[ -d /mnt/s/evo ]]; then
    ok "WSL data on S:\\ confirmed (/mnt/s/evo exists)"
  else
    warn "WSL data not found on S:\\ — may be on C:\\ (check .wslconfig)"
  fi
else
  warn "S:\\ not mounted at /mnt/s — scratch NVMe may be offline"
fi

# =============================================================================
section "SERVICES — Key Processes"

# OpenClaw gateway
if systemctl --user is-active openclaw-gateway.service >/dev/null 2>&1; then
  ok "openclaw-gateway.service (active)"
else
  crit "openclaw-gateway.service (NOT active)"
fi

# OpenClaw port
if ss -tlnp 2>/dev/null | grep -q ':18789'; then
  ok "OpenClaw listening on :18789"
else
  warn "OpenClaw not listening on :18789"
fi

# Mission Control (Docker)
if docker ps --format '{{.Names}}' 2>/dev/null | grep -qi "mission.control\\|mission-control"; then
  ok "Mission Control container running"
elif curl -sf http://localhost:13000 >/dev/null 2>&1; then
  ok "Mission Control UI responding on :13000"
else
  warn "Mission Control not detected (may be stopped)"
fi

# Docker overall
if command -v docker >/dev/null 2>&1; then
  DOCKER_CONTAINERS=$(docker ps -q 2>/dev/null | wc -l)
  DOCKER_MEM=$(docker stats --no-stream --format "{{.MemUsage}}" 2>/dev/null \
    | awk -F'/' '{gsub(/[^0-9.]/,"",$1); sum+=$1} END{printf "%.0f", sum}' || echo "0")
  info "Docker: ${DOCKER_CONTAINERS} container(s) running, ~${DOCKER_MEM}MiB total memory"
else
  info "Docker: not available in this context"
fi

# =============================================================================
section "TOP MEMORY CONSUMERS"

ps aux --sort=-%mem 2>/dev/null | awk 'NR>1 && NR<=11 {
  printf "  %5s%%  %-10s  %s\n", $4, $1, substr($11,1,50)
}' | head -10

# =============================================================================
section "WORKSPACE SNAPSHOT"

# Key dirs sizes
for dir in \
  "/home/evo/workspace/projects" \
  "/home/evo/workspace/DNA" \
  "/home/evo/workspace/_docs" \
  "/home/evo/workspace/_logs" \
  "/home/evo/workspace/gateways" \
  "/home/evo/workspace/models"
do
  if [[ -d "$dir" ]]; then
    SIZE=$(du -sh "$dir" 2>/dev/null | awk '{print $1}')
    info "$(printf '%-45s %s' "$dir" "$SIZE")"
  fi
done

# =============================================================================
section "SUMMARY"

# Re-check for overall status
RAM_PCT=$(( MEM_USED_GB * 100 / MEM_TOTAL_GB ))
REAL_PCT=$(( MEM_REAL_USED_GB * 100 / MEM_TOTAL_GB ))

if   [[ $REAL_PCT -ge $RAM_CRIT ]]; then
  crit "RAM pressure HIGH — real usage at ${REAL_PCT}% (${MEM_REAL_USED_GB}/${MEM_TOTAL_GB}GB)"
elif [[ $RAM_PCT  -ge $RAM_CRIT ]]; then
  warn "RAM reported high (${RAM_PCT}%) but real usage only ${REAL_PCT}% — likely ghost/cache"
  ok  "System is healthy — safe to continue"
elif [[ $REAL_PCT -ge $RAM_WARN ]]; then
  warn "RAM usage elevated at ${REAL_PCT}% real — monitor closely"
else
  ok  "System healthy — RAM ${REAL_PCT}% real usage"
fi

echo
info "Run with: /home/evo/workspace/_scripts/evo-health.sh"
info "Log output: /home/evo/workspace/_scripts/evo-health.sh >> /home/evo/workspace/_logs/health.log 2>&1"
echo
