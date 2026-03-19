#!/bin/bash
# ═══════════════════════════════════════════════════════════
# Evo Docker - Docker Management for Evolution Stables
# ═══════════════════════════════════════════════════════════

WORKSPACE_ROOT="/home/evo/workspace"
GATEWAY_ROOT="$WORKSPACE_ROOT/gateways"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

show_help() {
    cat << 'EOF'
🐳 Evo Docker

Usage: evo docker [command]

Commands:
  status              Show what's running
  start [service]     Start a service
  stop [service]      Stop a service
  stop-all            Stop ALL containers
  clean               Remove stopped containers and free disk space
  help                Show this help

Services:
  openclaw    - OpenClaw gateway (port 18789)

Examples:
  evo docker status
  evo docker start openclaw
  evo docker stop openclaw
  evo docker stop-all

EOF
}

check_docker() {
    if ! command -v docker &> /dev/null; then
        echo -e "${YELLOW}⚠ Docker not available in WSL${NC}"
        echo "  1. Open Docker Desktop"
        echo "  2. Settings → Resources → WSL Integration"
        echo "  3. Toggle ON Ubuntu → Apply & Restart"
        return 1
    fi
    return 0
}

show_status() {
    if ! check_docker; then return; fi

    echo "🐳 Docker Status"
    echo "═══════════════════════════════════════════════════════════"

    local running=$(docker ps --format "{{.Names}}" 2>/dev/null | wc -l)

    if [[ $running -eq 0 ]]; then
        echo -e "${GREEN}✅ No containers running${NC}"
    else
        echo -e "${YELLOW}$running container(s) running${NC}"
        echo ""
        docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" 2>/dev/null
        echo ""
        echo "Resource Usage:"
        docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}" 2>/dev/null
    fi

    echo ""
    echo "Disk Usage:"
    docker system df 2>/dev/null | grep -E "(Images|Containers|Volumes)" | sed 's/^/  /'
}

start_service() {
    if ! check_docker; then return; fi

    local service=$1
    if [[ -z "$service" ]]; then
        echo "Usage: evo docker start [service]"
        echo "Services: openclaw"
        return 1
    fi

    case $service in
        openclaw)
            echo "Starting OpenClaw gateway..."
            cd "$GATEWAY_ROOT/openclaw" && docker compose up -d
            ;;
        *)
            echo "Unknown service: $service"
            echo "Services: openclaw"
            return 1
            ;;
    esac
}

stop_service() {
    if ! check_docker; then return; fi

    local service=$1
    if [[ -z "$service" ]]; then
        echo "Usage: evo docker stop [service]"
        echo "Services: openclaw"
        return 1
    fi

    case $service in
        openclaw)
            echo "Stopping OpenClaw gateway..."
            cd "$GATEWAY_ROOT/openclaw" && docker compose down
            ;;
        *)
            echo "Unknown service: $service"
            echo "Services: openclaw"
            return 1
            ;;
    esac
}

stop_all() {
    if ! check_docker; then return; fi

    echo -e "${RED}⚠ Stopping ALL containers${NC}"
    local running=$(docker ps -q 2>/dev/null | wc -l)

    if [[ $running -eq 0 ]]; then
        echo "No containers running."
        return 0
    fi

    echo "Stopping $running container(s):"
    docker ps --format "  {{.Names}}" 2>/dev/null
    echo ""
    read -p "Are you sure? (yes/no): " confirm

    if [[ $confirm == "yes" ]]; then
        docker stop $(docker ps -q) 2>/dev/null
        echo -e "${GREEN}✅ All containers stopped${NC}"
    else
        echo "Cancelled."
    fi
}

clean_docker() {
    if ! check_docker; then return; fi

    echo "🧹 Cleaning up Docker..."
    local stopped=$(docker ps -aq -f status=exited 2>/dev/null | wc -l)
    if [[ $stopped -gt 0 ]]; then
        echo "Removing $stopped stopped containers..."
        docker container prune -f 2>/dev/null
    fi

    echo ""
    echo "Disk usage:"
    docker system df 2>/dev/null | grep -E "RECLAIMABLE|Images|Containers|Volumes"
    echo ""
    echo "To free more space:"
    echo "  docker image prune -f"
    echo "  docker system prune -f"
}

case "${1:-help}" in
    status)         show_status ;;
    start|up)       start_service "$2" ;;
    stop|down)      stop_service "$2" ;;
    stop-all)       stop_all ;;
    clean|prune)    clean_docker ;;
    help|--help|-h) show_help ;;
    *)
        echo "Unknown command: $1"
        echo "Run 'evo docker help' for usage"
        exit 1
        ;;
esac
