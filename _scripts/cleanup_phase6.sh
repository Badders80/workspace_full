#!/bin/bash
# ═══════════════════════════════════════════════════════════
# PHASE 6 CLEANUP SCRIPT
# Run with: sudo bash /home/evo/_scripts/cleanup_phase6.sh
# ═══════════════════════════════════════════════════════════

set -e  # Exit on error

echo "═══════════════════════════════════════════════════════"
echo "  EVOLUTION STABLES - PHASE 6 FINAL CLEANUP"
echo "═══════════════════════════════════════════════════════"
echo ""
echo "This script will:"
echo "  1. Delete orphaned root-owned folders"
echo "  2. Check for Local_LLM duplication"
echo "  3. Move References/Sandbox to proper locations"
echo "  4. Organize Infrastructure and External folders"
echo ""
read -p "Continue? (yes/no): " CONFIRM

if [ "$CONFIRM" != "yes" ]; then
    echo "Aborted."
    exit 1
fi

echo ""
echo "═══════════════════════════════════════════════════════"
echo "  STEP 1: DELETE ORPHANED ROOT-OWNED FOLDERS"
echo "═══════════════════════════════════════════════════════"

if [ -d "/home/evo/projects/Evolution_Content_Engine" ]; then
    echo "Deleting Evolution_Content_Engine..."
    rm -rf /home/evo/projects/Evolution_Content_Engine
    echo "  ✅ Deleted"
else
    echo "  ℹ️  Already deleted"
fi

if [ -d "/home/evo/projects/Evolution_Content_Factory" ]; then
    echo "Deleting Evolution_Content_Factory..."
    rm -rf /home/evo/projects/Evolution_Content_Factory
    echo "  ✅ Deleted"
else
    echo "  ℹ️  Already deleted"
fi

echo ""
echo "═══════════════════════════════════════════════════════"
echo "  STEP 2: CHECK Local_LLM DUPLICATION"
echo "═══════════════════════════════════════════════════════"

if [ -d "/home/evo/projects/Local_LLM" ] && [ -d "/home/evo/projects/Infrastructure/Local_LLM" ]; then
    echo "Both Local_LLM folders exist. Comparing..."
    
    # Quick size comparison
    SIZE1=$(du -sb /home/evo/projects/Local_LLM 2>/dev/null | cut -f1)
    SIZE2=$(du -sb /home/evo/projects/Infrastructure/Local_LLM 2>/dev/null | cut -f1)
    
    echo "  Local_LLM: $(du -sh /home/evo/projects/Local_LLM | cut -f1)"
    echo "  Infrastructure/Local_LLM: $(du -sh /home/evo/projects/Infrastructure/Local_LLM | cut -f1)"
    
    read -p "Delete projects/Local_LLM (keep Infrastructure/Local_LLM)? (yes/no): " DEL_LLM
    if [ "$DEL_LLM" = "yes" ]; then
        rm -rf /home/evo/projects/Local_LLM
        echo "  ✅ Deleted projects/Local_LLM"
    else
        echo "  ℹ️  Kept both (review manually later)"
    fi
elif [ -d "/home/evo/projects/Local_LLM" ]; then
    echo "Only projects/Local_LLM exists. Moving to Infrastructure/..."
    mv /home/evo/projects/Local_LLM /home/evo/projects/Infrastructure/Local_LLM_2
    echo "  ✅ Moved to Infrastructure/Local_LLM_2 (review for merge)"
else
    echo "  ℹ️  Only Infrastructure/Local_LLM exists - good"
fi

echo ""
echo "═══════════════════════════════════════════════════════"
echo "  STEP 3: MOVE REFERENCES & SANDBOX"
echo "═══════════════════════════════════════════════════════"

if [ -d "/home/evo/projects/References" ]; then
    echo "Moving References to _docs/..."
    mkdir -p /home/evo/_docs
    mv /home/evo/projects/References /home/evo/_docs/references
    echo "  ✅ Moved to _docs/references"
else
    echo "  ℹ️  References already moved"
fi

if [ -d "/home/evo/projects/Sandbox" ]; then
    echo "Moving Sandbox to _sandbox/..."
    mkdir -p /home/evo/_sandbox
    mv /home/evo/projects/Sandbox /home/evo/_sandbox/
    echo "  ✅ Moved to _sandbox/Sandbox"
else
    echo "  ℹ️  Sandbox already moved"
fi

echo ""
echo "═══════════════════════════════════════════════════════"
echo "  STEP 4: ORGANIZE INFRASTRUCTURE & EXTERNAL"
echo "═══════════════════════════════════════════════════════"

# Create External folder
mkdir -p /home/evo/projects/External

if [ -d "/home/evo/projects/ComfyUI" ]; then
    echo "Moving ComfyUI to Infrastructure/..."
    mv /home/evo/projects/ComfyUI /home/evo/projects/Infrastructure/ComfyUI
    echo "  ✅ Moved to Infrastructure/ComfyUI"
else
    echo "  ℹ️  ComfyUI already moved"
fi

if [ -d "/home/evo/projects/Firecrawl" ]; then
    echo "Moving Firecrawl to External/..."
    mv /home/evo/projects/Firecrawl /home/evo/projects/External/Firecrawl
    echo "  ✅ Moved to External/Firecrawl"
else
    echo "  ℹ️  Firecrawl already moved"
fi

if [ -d "/home/evo/projects/N8N" ]; then
    echo "Moving N8N to External/..."
    mv /home/evo/projects/N8N /home/evo/projects/External/N8N
    echo "  ✅ Moved to External/N8N"
else
    echo "  ℹ️  N8N already moved"
fi

echo ""
echo "═══════════════════════════════════════════════════════"
echo "  CLEANUP COMPLETE!"
echo "══════════════════════════════════════════════════════="
echo ""
echo "Final structure:"
echo ""
echo "projects/"
echo "├── Evolution_Platform/"
echo "├── Evolution_Content/        ✅ Rock Solid"
echo "├── Evolution_Intelligence/   ✅ Done"
echo "├── Evolution_Command/        ✅ Done"
echo "├── Evolution_Studio/         ✅ Done"
echo "├── Brand_Voice/"
echo "├── Infrastructure/"
echo "│   ├── Local_LLM/           # 25GB models"
echo "│   └── ComfyUI/             # 13GB image gen"
echo "└── External/"
echo "    ├── N8N/"
echo "    └── Firecrawl/"
echo ""
echo "_docs/references/  (moved from projects)"
echo "_sandbox/Sandbox/  (moved from projects)"
echo ""
echo "═══════════════════════════════════════════════════════"
