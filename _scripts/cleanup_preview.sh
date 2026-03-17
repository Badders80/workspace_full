#!/bin/bash
# ═══════════════════════════════════════════════════════════
# PREVIEW WHAT CLEANUP WILL DO
# Run: bash /home/evo/_scripts/cleanup_preview.sh (no sudo needed)
# ═══════════════════════════════════════════════════════════

echo "═══════════════════════════════════════════════════════"
echo "  CLEANUP PREVIEW (dry run)"
echo "═══════════════════════════════════════════════════════"
echo ""

echo "STEP 1: Will DELETE these orphaned folders:"
echo "  - projects/Evolution_Content_Engine"
echo "  - projects/Evolution_Content_Factory"
[ -d "/home/evo/projects/Evolution_Content_Engine" ] && echo "    (exists - will delete)" || echo "    (not found - already cleaned)"
[ -d "/home/evo/projects/Evolution_Content_Factory" ] && echo "    (exists - will delete)" || echo "    (not found - already cleaned)"
echo ""

echo "STEP 2: Local_LLM check:"
if [ -d "/home/evo/projects/Local_LLM" ] && [ -d "/home/evo/projects/Infrastructure/Local_LLM" ]; then
    echo "  ⚠️  Both exist:"
    echo "    - projects/Local_LLM: $(du -sh /home/evo/projects/Local_LLM 2>/dev/null | cut -f1)"
    echo "    - Infrastructure/Local_LLM: $(du -sh /home/evo/projects/Infrastructure/Local_LLM 2>/dev/null | cut -f1)"
    echo "  Will ask which to keep"
elif [ -d "/home/evo/projects/Local_LLM" ]; then
    echo "  Will MOVE projects/Local_LLM → Infrastructure/Local_LLM_2"
else
    echo "  ✅ Only Infrastructure/Local_LLM exists"
fi
echo ""

echo "STEP 3: Will MOVE to proper locations:"
[ -d "/home/evo/projects/References" ] && echo "  - References → _docs/references" || echo "  - References (already moved)"
[ -d "/home/evo/projects/Sandbox" ] && echo "  - Sandbox → _sandbox/Sandbox" || echo "  - Sandbox (already moved)"
echo ""

echo "STEP 4: Will ORGANIZE into folders:"
[ -d "/home/evo/projects/ComfyUI" ] && echo "  - ComfyUI → Infrastructure/ComfyUI" || echo "  - ComfyUI (already moved)"
[ -d "/home/evo/projects/Firecrawl" ] && echo "  - Firecrawl → External/Firecrawl" || echo "  - Firecrawl (already moved)"
[ -d "/home/evo/projects/N8N" ] && echo "  - N8N → External/N8N" || echo "  - N8N (already moved)"
echo ""

echo "═══════════════════════════════════════════════════════"
echo "To execute cleanup, run:"
echo "  sudo bash /home/evo/_scripts/cleanup_phase6.sh"
echo "═══════════════════════════════════════════════════════"
