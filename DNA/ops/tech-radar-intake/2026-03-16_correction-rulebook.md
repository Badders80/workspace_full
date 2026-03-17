# Tech Radar Intake - tasks/lessons.md Correction Rulebook

Tool: Permanent Correction Logging for Claude Code (`tasks/lessons.md` Rulebook)
Discovered: 2026-03-16
Source: Keshav Sukirya (@keshavsukirya) Instagram reel
Link: https://www.instagram.com/reel/DV4a43ZjkMa/
Status: Trial

## Problem It Solves

Corrections given to the agent disappear between sessions, so the same
mistakes get repeated and the founder keeps re-explaining rules.

## Summary

- Proposed workflow: every correction becomes a dated `mistake | new rule`
  entry in `tasks/lessons.md`.
- Session boot reads that file so fixes become sticky behavior rather than
  one-session memory.
- This is anti-pattern memory, not project-state memory.

## Workspace Fit

- Complements `AI_SESSION_BOOTSTRAP.md`: bootstrap carries current state,
  while `lessons.md` would carry "do not repeat this" rules.
- Fits the DNA stack with a tiny local markdown surface and no new tool or
  cloud dependency.
- Needs a hard size cap so the file does not become token drag.

## Hot Take

Worth a contained trial. The stack already has reheat memory, but it does
not yet have a dedicated correction ledger.

## Next Step

Trial a small `DNA/ops/lessons.md` experiment, keep it short, and verify
that a corrected mistake stays fixed across a reopen.

## Context Chain
<- inherits from: /home/evo/workspace/DNA/ops/TECH_RADAR.md
-> overrides by: none
-> live map: /home/evo/workspace/AI_SESSION_BOOTSTRAP.md
-> conventions: /home/evo/workspace/DNA/ops/CONVENTIONS.md
