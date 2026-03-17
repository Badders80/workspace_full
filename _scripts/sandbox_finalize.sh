#!/bin/bash
# ═══════════════════════════════════════════════════════════
# FINALIZE SANDBOX STRUCTURE
# Run with: sudo bash /home/evo/_scripts/sandbox_finalize.sh
# ═══════════════════════════════════════════════════════════

cd /home/evo/_sandbox

echo "═══════════════════════════════════════════════════════"
echo "  FINALIZING SANDBOX STRUCTURE"
echo "═══════════════════════════════════════════════════════"
echo ""

# Fix permissions
chown -R evo:evo .

echo "✓ Fixed permissions"

# Flatten structure
if [ -d "Sandbox" ]; then
    mv Sandbox/* . 2>/dev/null
    rmdir Sandbox 2>/dev/null
    echo "✓ Flattened: moved contents from Sandbox/ to root"
fi

# Create README
cat > README.md << 'EOF'
# _sandbox/ — The Free Trade Zone

**Quick prototyping without guardrails.**

See: `00_DNA/build-philosophy/SANDBOX_PHILOSOPHY.md`

---

## Current Experiments

| Folder | Purpose | Status |
|--------|---------|--------|
| `Evolution_Pitch_Deck_Builder/` | Pitch deck generator | Review for graduation? |

---

## How to Use

```bash
# Start a new experiment
cd /evo/_sandbox
mkdir my-experiment
cd my-experiment

# ... hack away, no rules ...

# When done: Graduate or Delete
```

---

## Graduation Checklist

When moving to `projects/`:
- [ ] Rename to Proper_Case
- [ ] Add CLAUDE.md
- [ ] Wire to `/evo/.env`
- [ ] Follow DNA standards
- [ ] Delete from here

---

**No rules. No standards. Just build.**
EOF

echo "✓ Created README.md"

echo ""
echo "═══════════════════════════════════════════════════════"
echo "  FINAL STRUCTURE"
echo "═══════════════════════════════════════════════════════"
ls -la

echo ""
echo "═══════════════════════════════════════════════════════"
echo "  SANDBOX READY"
echo "═══════════════════════════════════════════════════════"
echo ""
echo "Philosophy: 00_DNA/build-philosophy/SANDBOX_PHILOSOPHY.md"
echo "Location:   /evo/_sandbox/"
echo "Rules:      NONE (free trade zone)"
echo ""
