#!/bin/bash
# Fix _sandbox structure

cd /home/evo/_sandbox

# Move contents out of nested Sandbox folder
if [ -d "Sandbox" ]; then
    mv Sandbox/* . 2>/dev/null || sudo mv Sandbox/* .
    rmdir Sandbox 2>/dev/null || sudo rmdir Sandbox
    echo "✓ Flattened _sandbox/ structure"
fi

# Create README if doesn't exist
if [ ! -f "README.md" ]; then
cat > README.md << 'EOF'
# _sandbox/ — The Free Trade Zone

**Quick prototyping without guardrails.**

See: `00_DNA/build-philosophy/SANDBOX_PHILOSOPHY.md`

---

## Current Experiments

| Folder | Purpose | Status |
|--------|---------|--------|
| `Evolution_Pitch_Deck_Builder/` | Pitch deck generator | Active? |

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

**No rules. No standards. Just build.**
EOF
    echo "✓ Created README.md"
fi

echo ""
echo "═══════════════════════════════════════════════════"
echo "  SANDBOX STRUCTURE"
echo "═══════════════════════════════════════════════════"
ls -la
