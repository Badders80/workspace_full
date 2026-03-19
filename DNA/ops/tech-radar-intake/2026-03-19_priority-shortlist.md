# Tech Radar Intake - Priority Trial Shortlist

Synthesis note from the processed March 2026 radar work. This is a founder
priority layer over existing tool entries rather than a new discovery.

## Top Recommended Shortlist

Ordered for solo-founder leverage:

1. `AlphaClaw`
2. `skills.sh`
3. `claude-mem`
4. `NVIDIA Nemotron 3 Super`

## Why This Order

- `AlphaClaw` goes first because it creates the operational shell around the
  OpenClaw island: browser UI, watchdog, Git sync, and live visibility.
- `skills.sh` and `claude-mem` follow as fast capability and memory upgrades
  once the management layer is in place.
- `NVIDIA Nemotron 3 Super` comes last because it is the heaviest swap and is
  best trialed after the OpenClaw management, skill, and memory surfaces are
  stable.

## Fit Summary

- All four live cleanly in the current OpenClaw island strategy.
- `AlphaClaw` handles management.
- `skills.sh` handles worker capability.
- `claude-mem` handles local fast memory.
- `NVIDIA Nemotron 3 Super` handles local reasoning cost reduction.

## Execution Rule

Trial one branch at a time and keep all changes inside
`/home/evo/workspace/gateways/openclaw/`.

## Context Chain
<- inherits from: /home/evo/workspace/DNA/ops/TECH_RADAR.md
-> overrides by: none
-> live map: /home/evo/workspace/AI_SESSION_BOOTSTRAP.md
-> conventions: /home/evo/workspace/DNA/ops/CONVENTIONS.md
