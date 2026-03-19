#!/usr/bin/env bash
# =============================================================================
# evo-audit.sh — Holistic Evolution Workspace Audit
# Evolution Stables | Run in tmux or terminal
# Usage: bash /home/evo/workspace/_scripts/evo-audit.sh
# =============================================================================
# NOTE: No set -e so errors are logged and we continue through all phases

EVO_HOME="/home/evo"
WORKSPACE_ROOT="/home/evo/workspace"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
AUDIT_DIR="$WORKSPACE_ROOT/_logs/audit_runs/$TIMESTAMP"
RAW_DIR="$AUDIT_DIR/raw"
REPORT="$WORKSPACE_ROOT/_docs/HOLISTIC_EVO_AUDIT_${TIMESTAMP}.md"
PROGRESS="$AUDIT_DIR/progress.log"
FINDINGS="$AUDIT_DIR/findings.tsv"

mkdir -p "$RAW_DIR" "$WORKSPACE_ROOT/_docs"
echo -e "SEVERITY\tCATEGORY\tFINDING\tDETAIL" > "$FINDINGS"

log()      { echo "[$(date '+%H:%M:%S')] $*" | tee -a "$PROGRESS"; }
done_chk() { touch "$AUDIT_DIR/phase_${1}.done"; log "✓ Phase $1 complete"; }
finding()  { echo -e "${1}\t${2}\t${3}\t${4:-}" >> "$FINDINGS"; }

# Report helpers
H()    { echo -e "\n## $1\n" >> "$REPORT"; }
body() { echo "$1" >> "$REPORT"; }
code() { echo -e "\`\`\`\n$1\n\`\`\`" >> "$REPORT"; }

# ── Init report ───────────────────────────────────────────────────────────────
cat > "$REPORT" <<EOF
# Holistic Evolution Workspace Audit
**Generated:** $(date '+%A %d %B %Y %H:%M:%S')
**Run ID:** $TIMESTAMP

---

EOF

log "════════════════════════════════════════"
log "  EVO AUDIT STARTING — $TIMESTAMP"
log "  Report → $REPORT"
log "════════════════════════════════════════"

# =============================================================================
# PHASE 1 — Top-level disk usage
# =============================================================================
log "Phase 1 — Disk usage"
H "Phase 1 — Top-Level Disk Usage"

OUT="$RAW_DIR/p1_disk.txt"
{
  echo "=== /home/evo items (sorted by size) ==="
  du -sh "$EVO_HOME"/.[!.]* "$EVO_HOME"/* 2>/dev/null | sort -rh

  echo ""
  echo "=== Total ==="
  du -sh "$EVO_HOME" 2>/dev/null

  echo ""
  echo "=== Disk available ==="
  df -h "$EVO_HOME" 2>/dev/null
} > "$OUT" 2>&1

code "$(cat "$OUT")"
done_chk 1

# =============================================================================
# PHASE 2 — Broken symlinks
# =============================================================================
log "Phase 2 — Broken symlinks"
H "Phase 2 — Broken Symlinks"

OUT="$RAW_DIR/p2_symlinks.txt"
find "$EVO_HOME" -xtype l 2>/dev/null > "$OUT"

COUNT=$(wc -l < "$OUT")
body "**$COUNT broken symlinks found.**"

if [ "$COUNT" -gt 0 ]; then
  GEMINI=$(grep -c '\.gemini' "$OUT" 2>/dev/null || echo 0)
  CODEX=$(grep -c '\.codex' "$OUT" 2>/dev/null || echo 0)
  PNPM=$(grep -c 'pnpm' "$OUT" 2>/dev/null || echo 0)
  ARCHIVE=$(grep -c '_archive' "$OUT" 2>/dev/null || echo 0)
  OTHER=$(grep -vE '\.gemini|\.codex|pnpm|_archive' "$OUT" 2>/dev/null | wc -l)

  body ""
  body "| Category | Count | Action |"
  body "| -------- | ----- | ------ |"
  body "| .gemini node_modules/.bin | $GEMINI | Ignore (npm artifacts) |"
  body "| .codex/tmp | $CODEX | Safe to delete |"
  body "| pnpm store | $PNPM | Ignore (pnpm internal) |"
  body "| _archive | $ARCHIVE | Review |"
  body "| Other | $OTHER | Review |"

  body ""
  body "### Non-trivial broken symlinks:"
  code "$(grep -vE '\.gemini|\.codex|pnpm' "$OUT" 2>/dev/null || echo 'none')"

  grep -vE '\.gemini|\.codex|pnpm' "$OUT" 2>/dev/null | while read -r link; do
    finding "MEDIUM" "Broken Symlink" "$link" "→ $(readlink "$link" 2>/dev/null)"
  done
fi

done_chk 2

# =============================================================================
# PHASE 3 — Missing referenced paths in active workspace docs/scripts
# =============================================================================
log "Phase 3 — Dead workspace path references"
H "Phase 3 — Dead Path References in Active Workspace Docs & Scripts"

OUT="$RAW_DIR/p3_dead_refs.txt"
SCAN_FILES=()
for f in \
  "$WORKSPACE_ROOT/_scripts" \
  "$WORKSPACE_ROOT/DNA" \
  "$WORKSPACE_ROOT/Justfile" \
  "$WORKSPACE_ROOT/CONTEXT.md" \
  "$WORKSPACE_ROOT/AI_SESSION_BOOTSTRAP.md" \
  "$WORKSPACE_ROOT/AGENTS.md" \
  "$WORKSPACE_ROOT/MANIFEST.md"; do
  [ -e "$f" ] && SCAN_FILES+=("$f")
done

if [ ${#SCAN_FILES[@]} -eq 0 ]; then
  body "No files to scan."
else
  TMP=$(mktemp)
  grep -rho '/home/evo/[A-Za-z0-9_./-]*' "${SCAN_FILES[@]}" 2>/dev/null | sort -u > "$TMP" || true
  TOTAL=$(wc -l < "$TMP")
  body "**$TOTAL unique absolute paths referenced.**"
  body ""

  MISSING=()
  while read -r p; do
    [ -e "$p" ] || MISSING+=("$p")
  done < "$TMP"
  rm -f "$TMP"

  MISS_COUNT=${#MISSING[@]}
  if [ "$MISS_COUNT" -eq 0 ]; then
    body "✅ All referenced paths exist."
  else
    body "**$MISS_COUNT missing paths:**"
    printf '%s\n' "${MISSING[@]}" > "$OUT"
    code "$(cat "$OUT")"
    for p in "${MISSING[@]}"; do
      finding "HIGH" "Dead Ref" "$p" "Referenced but missing"
    done
  fi
fi

done_chk 3

# =============================================================================
# PHASE 4 — Git repo inventory
# =============================================================================
log "Phase 4 — Git repos"
H "Phase 4 — Git Repo Inventory"

OUT="$RAW_DIR/p4_git.txt"
{
  printf '%-60s %-15s %-12s %-12s %s\n' "REPO" "BRANCH" "UNCOMMITTED" "LAST DATE" "LAST MSG"
  printf '%-60s %-15s %-12s %-12s %s\n' "----" "------" "-----------" "---------" "--------"

  find "$EVO_HOME" -name .git -type d -prune 2>/dev/null | sed 's|/\.git$||' | sort | while read -r repo; do
    branch=$(git -C "$repo" rev-parse --abbrev-ref HEAD 2>/dev/null || echo "ERR")
    dirty=$(git -C "$repo" status --porcelain 2>/dev/null | wc -l)
    last_date=$(git -C "$repo" log -1 --date=short --pretty=format:'%ad' 2>/dev/null || echo "no commits")
    last_msg=$(git -C "$repo" log -1 --pretty=format:'%s' 2>/dev/null | cut -c1-50 || echo "")
    printf '%-60s %-15s %-12s %-12s %s\n' "$repo" "$branch" "$dirty" "$last_date" "$last_msg"
  done
} > "$OUT" 2>&1

code "$(cat "$OUT")"

NOW=$(date +%s)
find "$EVO_HOME" -name .git -type d -prune 2>/dev/null | sed 's|/\.git$||' | while read -r repo; do
  last_ts=$(git -C "$repo" log -1 --date=unix --pretty=format:'%ad' 2>/dev/null || echo "")
  if [ -n "$last_ts" ]; then
    days=$(( (NOW - last_ts) / 86400 ))
    [ "$days" -gt 90 ] && finding "INFO" "Stale Repo" "$repo" "No commits in $days days"
  fi
done

done_chk 4

# =============================================================================
# PHASE 5 — workspace DNA integrity
# =============================================================================
log "Phase 5 — workspace DNA check"
H "Phase 5 — /workspace DNA Structure & Integrity"

DNA="$WORKSPACE_ROOT/DNA"
OUT="$RAW_DIR/p5_dna.txt"

if [ ! -d "$DNA" ]; then
  body "❌ /workspace DNA does not exist!"
  finding "CRITICAL" "Workspace DNA" "/workspace DNA missing" ""
else
  {
    echo "=== Tree (3 levels) ==="
    find "$DNA" -maxdepth 3 -not -path '*/.git/*' | sort

    echo ""
    echo "=== Key file check ==="
    for f in \
      "AGENTS.md" \
      "agents/AI_CONTEXT.md" \
      "ops/CONVENTIONS.md" \
      "ops/STACK.md" \
      "ops/TRANSITION.md" \
      "ops/DECISION_LOG.md" \
      "INBOX.md"; do
      full="$DNA/$f"
      if [ -e "$full" ]; then
        lines=$(wc -l < "$full" 2>/dev/null || echo "?")
        echo "  ✅ $f ($lines lines)"
      else
        echo "  ❌ MISSING: $f"
        finding "MEDIUM" "Workspace DNA" "Missing: $f" "$DNA/$f"
      fi
    done

    echo ""
    echo "=== Git status ==="
    git -C "$DNA" status --short 2>/dev/null || echo "Not a git repo"

    echo ""
    echo "=== Recent commits ==="
    git -C "$DNA" log --oneline -10 2>/dev/null || echo "No commits"
  } > "$OUT" 2>&1

  code "$(cat "$OUT")"
fi

done_chk 5

# =============================================================================
# PHASE 6 — workspace projects inventory
# =============================================================================
log "Phase 6 — Workspace projects"
H "Phase 6 — /workspace/projects Inventory"

PROJ="$WORKSPACE_ROOT/projects"
OUT="$RAW_DIR/p6_projects.txt"

if [ ! -d "$PROJ" ]; then
  body "❌ /workspace/projects missing!"
  finding "CRITICAL" "Projects" "/workspace/projects missing" ""
else
  {
    echo "=== Projects listing ==="
    ls -la "$PROJ" 2>/dev/null

    echo ""
    echo "=== Per-project details ==="
    for p in "$PROJ"/*/; do
      [ -d "$p" ] || continue
      name=$(basename "$p")
      size=$(du -sh "$p" 2>/dev/null | cut -f1)

      if [ -L "$p/.env" ]; then
        target=$(readlink "$p/.env")
        exists=$( [ -e "$p/.env" ] && echo "✅" || echo "❌ BROKEN" )
        env_status=".env symlink → $target $exists"
      elif [ -f "$p/.env" ]; then
        env_status=".env direct file"
        finding "INFO" "Projects" "$name .env is direct file" "Consider symlinking"
      else
        env_status="NO .env"
        finding "MEDIUM" "Projects" "$name has no .env" "$p"
      fi

      stack=""
      [ -f "$p/package.json" ] && stack="${stack}node "
      [ -f "$p/next.config.js" ] || [ -f "$p/next.config.ts" ] && stack="${stack}next.js "
      [ -f "$p/pyproject.toml" ] || [ -f "$p/requirements.txt" ] && stack="${stack}python "
      [ -f "$p/Cargo.toml" ] && stack="${stack}rust "
      [ -z "$stack" ] && stack="unknown"

      echo "  [$name] size=$size stack=${stack} $env_status"
    done

    echo ""
    echo "=== Project sizes ==="
    du -sh "$PROJ"/*/ 2>/dev/null | sort -rh
  } > "$OUT" 2>&1

  code "$(cat "$OUT")"
fi

done_chk 6

# =============================================================================
# PHASE 7 — Root-level clutter
# =============================================================================
log "Phase 7 — Root clutter"
H "Phase 7 — Root-Level Clutter & Loose Files"

OUT="$RAW_DIR/p7_clutter.txt"
{
  echo "=== Files directly in /home/evo (non-hidden) ==="
  find "$EVO_HOME" -maxdepth 1 -type f -not -name '.*' | sort

  echo ""
  echo "=== Non-hidden dirs at root ==="
  find "$EVO_HOME" -maxdepth 1 -type d -not -name '.*' | sort

  echo ""
  echo "=== .bashrc backups ==="
  ls -la "$EVO_HOME"/.bashrc* 2>/dev/null

  echo ""
  echo "=== overnight/audit loose files ==="
  ls -la "$EVO_HOME"/overnight_*.* "$EVO_HOME"/audit_log_*.txt "$EVO_HOME"/start_overnight.sh 2>/dev/null || echo "none"
} > "$OUT" 2>&1

code "$(cat "$OUT")"

find "$EVO_HOME" -maxdepth 1 -type f -not -name '.*' 2>/dev/null | while read -r f; do
  finding "INFO" "Root Clutter" "Loose file: $(basename "$f")" "Consider moving to _docs/_scripts"
done

done_chk 7

# =============================================================================
# PHASE 8 — Duplication & shadow repos
# =============================================================================
log "Phase 8 — Duplication"
H "Phase 8 — Duplication & Shadow Repos"

OUT="$RAW_DIR/p8_duplication.txt"
{
  echo "=== All repos and their remotes ==="
  find "$EVO_HOME" -name .git -type d -prune 2>/dev/null | sed 's|/\.git$||' | sort | while read -r repo; do
    remote=$(git -C "$repo" remote get-url origin 2>/dev/null || echo "no remote")
    echo "  $repo → $remote"
  done

  echo ""
  echo "=== Root dirs duplicating /projects names ==="
  for p in "$WORKSPACE_ROOT"/projects/*/; do
    name=$(basename "$p")
    [ -d "$EVO_HOME/$name" ] && echo "  ⚠️  $name at BOTH /projects/ and /home/evo/"
  done

  echo ""
  echo "=== _archive contents ==="
  ls -la "$EVO_HOME/_archive/" 2>/dev/null || echo "_archive missing"
} > "$OUT" 2>&1

code "$(cat "$OUT")"
done_chk 8

# =============================================================================
# PHASE 9 — Shell & tooling health
# =============================================================================
log "Phase 9 — Shell health"
H "Phase 9 — Shell & Tooling Health"

OUT="$RAW_DIR/p9_shell.txt"
{
  echo "=== Key tools ==="
  for tool in just tmux docker git node python3 bun pnpm npm rg fzf; do
    path=$(command -v "$tool" 2>/dev/null || echo "NOT FOUND")
    ver=$("$tool" --version 2>/dev/null | head -1 || echo "")
    printf '  %-12s %-30s %s\n' "$tool" "$path" "$ver"
  done

  echo ""
  echo "=== evo command ==="
  command -v evo 2>/dev/null || echo "evo not in PATH"

  echo ""
  echo "=== Justfile targets ==="
  [ -f "$WORKSPACE_ROOT/Justfile" ] && grep -E '^[a-z][a-z_-]+:' "$WORKSPACE_ROOT/Justfile" | cut -d: -f1 | sort || echo "No Justfile"

  echo ""
  echo "=== Docker containers ==="
  docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}" 2>/dev/null || echo "Docker not available"

  echo ""
  echo "=== Listening ports ==="
  ss -tuln 2>/dev/null | grep LISTEN | head -20 || echo "none"

  echo ""
  echo "=== PATH additions in .bashrc ==="
  grep 'PATH' "$EVO_HOME/.bashrc" 2>/dev/null || echo "none"
} > "$OUT" 2>&1

code "$(cat "$OUT")"
done_chk 9

# =============================================================================
# PHASE 10 — Activity: active vs stale
# =============================================================================
log "Phase 10 — Activity"
H "Phase 10 — Active vs Stale"

OUT="$RAW_DIR/p10_activity.txt"
NOW=$(date +%s)
{
  echo "=== Files modified in last 7 days ==="
  find "$EVO_HOME" \
    -not -path '*/.git/*' \
    -not -path '*/node_modules/*' \
    -not -path '*/__pycache__/*' \
    -not -path '*/.vscode-server/*' \
    -not -path '*/.npm*' \
    -not -path '*/.antigravity-server/*' \
    -mtime -7 -type f 2>/dev/null | sort | head -60

  echo ""
  echo "=== Top-level dirs not touched in 90+ days ==="
  find "$EVO_HOME" -maxdepth 2 -type d 2>/dev/null | while read -r d; do
    last=$(stat -c '%Y' "$d" 2>/dev/null || echo 0)
    days=$(( (NOW - last) / 86400 ))
    [ "$days" -gt 90 ] && printf '%5d days  %s\n' "$days" "$d"
  done | sort -rn | head -30

  echo ""
  echo "=== Archive/legacy directories ==="
  find "$EVO_HOME" -maxdepth 3 -type d \( \
    -iname '*archive*' -o -iname '*_old' -o -iname '*backup*' \
    -o -iname '*deprecated*' -o -iname '*legacy*' \
  \) 2>/dev/null
} > "$OUT" 2>&1

code "$(cat "$OUT")"
done_chk 10

# =============================================================================
# PHASE 11 — .env audit (keys only)
# =============================================================================
log "Phase 11 — .env audit"
H "Phase 11 — .env Audit (Keys Only, No Values)"

OUT="$RAW_DIR/p11_env.txt"
{
  echo "=== Root .env keys ==="
  [ -f "$EVO_HOME/.env" ] && grep -E '^[A-Z_]+=' "$EVO_HOME/.env" | cut -d= -f1 | sort || echo "No root .env"

  echo ""
  echo "=== /evo/.env keys ==="
  [ -f "/evo/.env" ] && grep -E '^[A-Z_]+=' /evo/.env | cut -d= -f1 | sort || echo "No /evo/.env"

  echo ""
  echo "=== Key diff (root vs /evo) ==="
  if [ -f "$EVO_HOME/.env" ] && [ -f "/evo/.env" ]; then
    diff \
      <(grep -E '^[A-Z_]+=' "$EVO_HOME/.env" | cut -d= -f1 | sort) \
      <(grep -E '^[A-Z_]+=' /evo/.env | cut -d= -f1 | sort) \
      && echo "(no diff)" || true
  else
    echo "One or both .env files missing — skipping diff"
  fi

  echo ""
  echo "=== Per-project .env key counts ==="
  for p in "$WORKSPACE_ROOT"/projects/*/; do
    [ -d "$p" ] || continue
    name=$(basename "$p")
    if [ -f "$p/.env" ]; then
      count=$(grep -c '^[A-Z_]*=' "$p/.env" 2>/dev/null || echo 0)
      echo "  $name: $count keys"
    else
      echo "  $name: no .env"
    fi
  done
} > "$OUT" 2>&1

code "$(cat "$OUT")"
done_chk 11

# =============================================================================
# PHASE 12 — Hidden tool directories
# =============================================================================
log "Phase 12 — Hidden tool dirs"
H "Phase 12 — Hidden Tool Directories"

OUT="$RAW_DIR/p12_hidden.txt"
{
  echo "=== All hidden dirs at root (sorted by size) ==="
  du -sh "$EVO_HOME"/.[!.]* 2>/dev/null | sort -rh

  echo ""
  echo "=== Known AI tool dirs ==="
  for d in .openclaw .gemini .codex .aider .claude .copilot .jules .kimi .openfang .antigravity-server .kombai; do
    full="$EVO_HOME/$d"
    if [ -d "$full" ]; then
      size=$(du -sh "$full" 2>/dev/null | cut -f1)
      modified=$(stat -c '%y' "$full" 2>/dev/null | cut -d' ' -f1)
      echo "  ✅ $d  size=$size  modified=$modified"
    else
      echo "  —  $d  not present"
    fi
  done

  echo ""
  echo "=== .bashrc backup files ==="
  ls -lh "$EVO_HOME"/.bashrc* 2>/dev/null
} > "$OUT" 2>&1

code "$(cat "$OUT")"
done_chk 12

# =============================================================================
# PHASE 13 — Consolidate findings & action plan
# =============================================================================
log "Phase 13 — Consolidating"
H "Phase 13 — Consolidated Findings & Action Plan"

CRITICAL=$(grep -c '^CRITICAL' "$FINDINGS" 2>/dev/null || echo 0)
HIGH=$(grep -c '^HIGH' "$FINDINGS" 2>/dev/null || echo 0)
MEDIUM=$(grep -c '^MEDIUM' "$FINDINGS" 2>/dev/null || echo 0)
INFO=$(grep -c '^INFO' "$FINDINGS" 2>/dev/null || echo 0)

body "### Summary"
body ""
body "| Severity | Count |"
body "| -------- | ----- |"
body "| 🔴 CRITICAL | $CRITICAL |"
body "| 🟠 HIGH | $HIGH |"
body "| 🟡 MEDIUM | $MEDIUM |"
body "| 🔵 INFO | $INFO |"
body ""
body "### All Findings"
body ""
body "| Severity | Category | Finding | Detail |"
body "| -------- | -------- | ------- | ------ |"

for sev in CRITICAL HIGH MEDIUM INFO; do
  grep "^$sev" "$FINDINGS" 2>/dev/null | while IFS=$'\t' read -r s c m d; do
    body "| $s | $c | $m | $d |"
  done
done

body ""
body "### Fix Now (CRITICAL + HIGH)"
body ""
for sev in CRITICAL HIGH; do
  grep "^$sev" "$FINDINGS" 2>/dev/null | while IFS=$'\t' read -r s c m d; do
    body "- [ ] **[$s]** $c — $m"
    [ -n "$d" ] && body "  - $d"
  done
done

body ""
body "### Fix Soon (MEDIUM)"
body ""
grep "^MEDIUM" "$FINDINGS" 2>/dev/null | while IFS=$'\t' read -r s c m d; do
  body "- [ ] $c — $m"
  [ -n "$d" ] && body "  - $d"
done

body ""
body "### Review Later (INFO)"
body ""
grep "^INFO" "$FINDINGS" 2>/dev/null | while IFS=$'\t' read -r s c m d; do
  body "- [ ] $c — $m"
  [ -n "$d" ] && body "  - $d"
done

done_chk 13

# =============================================================================
log "════════════════════════════════════════"
log "  AUDIT COMPLETE"
log "  Report: $REPORT"
log "  Raw:    $RAW_DIR"
log "════════════════════════════════════════"
echo ""
echo "════════════════════════════════════════"
echo "  Report ready:"
echo "  $REPORT"
echo "════════════════════════════════════════"
