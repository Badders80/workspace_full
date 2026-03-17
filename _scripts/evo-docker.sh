#!/bin/bash
# ═══════════════════════════════════════════════════════════
# Evo Docker - Simple Docker Management for Evolution Stables
# You don't need to know Docker. Just use these commands.
# ═══════════════════════════════════════════════════════════

EVO_ROOT="/home/evo"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

show_help() {
    cat << 'EOF'
🐳 Evo Docker - You don't need to learn Docker

Usage: evo docker [command]

Commands:
  status              Show what's running (and eating resources)
  list                List all your Docker projects
  start [project]     Start a project's containers
  stop [project]      Stop a project's containers  
  stop-all            Stop ALL containers (emergency brake)
  clean               Remove stopped containers and free disk space
  help                Show this help

Projects you can manage:
  n8n         - Workflow automation (usually always running)
  firecrawl   - Web scraping service
  studio      - Evolution Studio microservices
  command     - Evolution Command (frontend/backend)
  content     - Evolution Content services
  llm         - Local LLM infrastructure

Examples:
  evo docker status          # What's running right now?
  evo docker list            # What projects use Docker?
  evo docker start n8n       # Start N8N workflows
  evo docker stop studio     # Stop Evolution Studio to free up GPU
  evo docker stop-all        # EMERGENCY: Stop everything

Docker Desktop Alerts?
  If you're getting Windows notifications, use "evo docker status"
  to see what's actually running and consuming resources.

EOF
}

# Check if Docker is available (via WSL integration)
check_docker() {
    if ! command -v docker &> /dev/null; then
        echo -e "${YELLOW}⚠ Docker command not found in WSL${NC}"
        echo ""
        echo "Docker is probably running in Docker Desktop on Windows."
        echo "To enable WSL integration:"
        echo "  1. Open Docker Desktop"
        echo "  2. Settings → Resources → WSL Integration"
        echo "  3. Toggle ON for your Ubuntu distro"
        echo "  4. Click Apply & Restart"
        echo ""
        echo "Or manage containers directly in Docker Desktop GUI."
        return 1
    fi
    return 0
}

show_status() {
    if ! check_docker; then return; fi
    
    echo "🐳 Docker Status - What's Running Right Now"
    echo "═══════════════════════════════════════════════════════════"
    
    # Running containers
    local running=$(docker ps --format "{{.Names}}" 2>/dev/null | wc -l)
    
    if [[ $running -eq 0 ]]; then
        echo -e "${GREEN}✅ Nothing running${NC} - No containers consuming resources"
    else
        echo -e "${YELLOW}⚠ $running container(s) running${NC}"
        echo ""
        docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" 2>/dev/null
        
        echo ""
        echo "Resource Usage:"
        docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}" 2>/dev/null | head -10
    fi
    
    echo ""
    echo "Disk Usage:"
    docker system df 2>/dev/null | grep -E "(Images|Containers|Volumes)" | sed 's/^/  /'
}

list_projects() {
    echo "📦 Docker Projects in Evolution Stables"
    echo "═══════════════════════════════════════════════════════════"
    echo ""
    
    # External services
    echo -e "${BLUE}External Services (Third-party tools):${NC}"
    echo "  n8n         - Workflow automation (Zapier alternative)"
    echo "                Location: projects/External/N8N/"
    echo "                Usually: Keep running"
    echo ""
    echo "  firecrawl   - Web scraping service"
    echo "                Location: projects/External/Firecrawl/"
    echo "                Usually: Start when needed"
    echo ""
    
    # Your projects
    echo -e "${BLUE}Your Projects:${NC}"
    
    if [[ -f "$EVO_ROOT/projects/Evolution_Studio/docker-compose.yml" ]]; then
        echo "  studio      - Evolution Studio (microservices)"
        echo "                Services: orchestrator, transcriber, scraper, refiner"
        echo "                GPU: Uses GPU for transcription"
        echo "                Usually: Stop when not editing content"
        echo ""
    fi
    
    if [[ -f "$EVO_ROOT/projects/Evolution_Command/docker-compose.yml" ]] || \
       [[ -f "$EVO_ROOT/projects/Evolution_Command/backend/Dockerfile" ]]; then
        echo "  command     - Evolution Command (monitoring)"
        echo "                Services: frontend, backend"
        echo "                Usually: Keep running for monitoring"
        echo ""
    fi
    
    if [[ -d "$EVO_ROOT/projects/Evolution_Content" ]]; then
        echo "  content     - Evolution Content (content pipeline)"
        echo "                Services: clip-agent, editor, researcher"
        echo "                Usually: Start when generating content"
        echo ""
    fi
    
    # Infrastructure
    echo -e "${BLUE}Infrastructure (Heavy lifting):${NC}"
    if [[ -f "$EVO_ROOT/projects/Infrastructure/Local_LLM/docker-compose.yml" ]] || \
       [[ -f "$EVO_ROOT/projects/Infrastructure/Local_LLM_2/docker-compose.yml" ]]; then
        echo "  llm         - Local AI models (25GB+)"
        echo "                GPU: Heavy GPU usage"
        echo "                Usually: Stop when not actively using AI"
        echo ""
    fi
    
    echo "─────────────────────────────────────────────────────────────"
    echo "💡 Tip: Use 'evo docker status' to see what's actually running"
}

start_project() {
    if ! check_docker; then return; fi
    
    local project=$1
    if [[ -z "$project" ]]; then
        echo "Usage: evo docker start [project]"
        echo "Run 'evo docker list' to see available projects"
        return 1
    fi
    
    case $project in
        n8n)
            echo "Starting N8N..."
            cd "$EVO_ROOT/projects/External/N8N" && docker-compose up -d 2>/dev/null || docker compose up -d
            ;;
        firecrawl)
            echo "Starting Firecrawl..."
            cd "$EVO_ROOT/projects/External/Firecrawl" && docker-compose up -d 2>/dev/null || docker compose up -d
            ;;
        studio)
            echo "Starting Evolution Studio..."
            cd "$EVO_ROOT/projects/Evolution_Studio" && docker-compose up -d 2>/dev/null || docker compose up -d
            ;;
        command)
            echo "Starting Evolution Command..."
            cd "$EVO_ROOT/projects/Evolution_Command" && docker-compose up -d 2>/dev/null || docker compose up -d
            ;;
        content)
            echo "Starting Evolution Content..."
            cd "$EVO_ROOT/projects/Evolution_Content" && docker-compose up -d 2>/dev/null || docker compose up -d
            ;;
        llm|local-llm)
            if [[ -f "$EVO_ROOT/projects/Infrastructure/Local_LLM/docker-compose.yml" ]]; then
                cd "$EVO_ROOT/projects/Infrastructure/Local_LLM" && docker-compose up -d 2>/dev/null || docker compose up -d
            else
                cd "$EVO_ROOT/projects/Infrastructure/Local_LLM_2" && docker-compose up -d 2>/dev/null || docker compose up -d
            fi
            ;;
        *)
            echo "Unknown project: $project"
            echo "Run 'evo docker list' to see available projects"
            return 1
            ;;
    esac
}

stop_project() {
    if ! check_docker; then return; fi
    
    local project=$1
    if [[ -z "$project" ]]; then
        echo "Usage: evo docker stop [project]"
        echo "Run 'evo docker list' to see available projects"
        return 1
    fi
    
    case $project in
        n8n)
            echo "Stopping N8N..."
            cd "$EVO_ROOT/projects/External/N8N" && docker-compose down 2>/dev/null || docker compose down
            ;;
        firecrawl)
            echo "Stopping Firecrawl..."
            cd "$EVO_ROOT/projects/External/Firecrawl" && docker-compose down 2>/dev/null || docker compose down
            ;;
        studio)
            echo "Stopping Evolution Studio..."
            cd "$EVO_ROOT/projects/Evolution_Studio" && docker-compose down 2>/dev/null || docker compose down
            ;;
        command)
            echo "Stopping Evolution Command..."
            cd "$EVO_ROOT/projects/Evolution_Command" && docker-compose down 2>/dev/null || docker compose down
            ;;
        content)
            echo "Stopping Evolution Content..."
            cd "$EVO_ROOT/projects/Evolution_Content" && docker-compose down 2>/dev/null || docker compose down
            ;;
        llm|local-llm)
            if [[ -f "$EVO_ROOT/projects/Infrastructure/Local_LLM/docker-compose.yml" ]]; then
                cd "$EVO_ROOT/projects/Infrastructure/Local_LLM" && docker-compose down 2>/dev/null || docker compose down
            else
                cd "$EVO_ROOT/projects/Infrastructure/Local_LLM_2" && docker-compose down 2>/dev/null || docker compose down
            fi
            ;;
        *)
            echo "Unknown project: $project"
            echo "Run 'evo docker list' to see available projects"
            return 1
            ;;
    esac
}

stop_all() {
    if ! check_docker; then return; fi
    
    echo -e "${RED}⚠ EMERGENCY STOP - Stopping ALL containers${NC}"
    echo ""
    
    local running=$(docker ps -q 2>/dev/null | wc -l)
    if [[ $running -eq 0 ]]; then
        echo "No containers running."
        return 0
    fi
    
    echo "This will stop $running container(s):"
    docker ps --format "  {{.Names}}" 2>/dev/null
    echo ""
    read -p "Are you sure? (yes/no): " confirm
    
    if [[ $confirm == "yes" ]]; then
        echo "Stopping all containers..."
        docker stop $(docker ps -q) 2>/dev/null
        echo -e "${GREEN}✅ All containers stopped${NC}"
    else
        echo "Cancelled."
    fi
}

clean_docker() {
    if ! check_docker; then return; fi
    
    echo "🧹 Cleaning up Docker..."
    echo ""
    
    # Remove stopped containers
    local stopped=$(docker ps -aq -f status=exited 2>/dev/null | wc -l)
    if [[ $stopped -gt 0 ]]; then
        echo "Removing $stopped stopped containers..."
        docker container prune -f 2>/dev/null
    fi
    
    # Show what could be cleaned
    echo ""
    echo "Disk usage that could be freed:"
    docker system df 2>/dev/null | grep -E "RECLAIMABLE|Images|Containers|Volumes"
    
    echo ""
    echo "To free more space, run these (optional):"
    echo "  docker image prune -f        # Remove unused images"
    echo "  docker volume prune -f       # Remove unused volumes"
    echo "  docker system prune -f       # Remove everything unused"
}

# Main dispatcher
case "${1:-help}" in
    status)
        show_status
        ;;
    list|ls)
        list_projects
        ;;
    start|up)
        start_project "$2"
        ;;
    stop|down)
        stop_project "$2"
        ;;
    stop-all|kill-all)
        stop_all
        ;;
    clean|prune|cleanup)
        clean_docker
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        echo "Unknown command: $1"
        echo "Run 'evo docker help' for usage"
        exit 1
        ;;
esac
