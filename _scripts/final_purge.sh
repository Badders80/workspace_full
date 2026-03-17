#!/bin/bash
# 🧹 Evolution Stables - Final Ghost Purge
# Run with: sudo bash /home/evo/_scripts/final_purge.sh

echo "⚠️  This will permanently delete redundant legacy folders."
read -p "Continue? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    exit 1
fi

echo "Removing Evolution-Content-Factory..."
rm -rf /home/evo/projects/Evolution-Content-Factory

echo "Removing evolution-content-engine..."
rm -rf /home/evo/projects/evolution-content-engine

echo "Removing redundant n8n shell..."
rm -rf /home/evo/projects/n8n

echo "✅ Purge complete. Your workspace is now aligned."
