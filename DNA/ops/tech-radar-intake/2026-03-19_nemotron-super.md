# Tech Radar Intake - NVIDIA Nemotron 3 Super

Tool: NVIDIA Nemotron 3 Super
Discovered: 2026-03-19
Source: NVIDIA Nemotron research page, NVIDIA NIM model page, and Ollama library
Links:
- https://research.nvidia.com/labs/nemotron/Nemotron-3-Super/
- https://build.nvidia.com/nvidia/nemotron-3-super-120b-a12b
- https://ollama.com/library/nemotron-3-super
Status: Trial

## Problem It Solves

Provides a high-capability local or self-hosted reasoning model for worker-tier
agent tasks, reducing dependence on paid API inference for OpenClaw-style runs.

## Summary

- NVIDIA describes Nemotron 3 Super as a 120B total, 12B active hybrid
  Mamba-Transformer MoE model for agentic reasoning, coding, planning, and
  tool use.
- NVIDIA's official research page says the model supports context lengths of up
  to 1M tokens and that open checkpoints are available, including quantized
  variants.
- NVIDIA's NIM page confirms the open-model license and positions the model as
  downloadable for self-hosted use.
- Ollama now exposes `nemotron-3-super` directly and explicitly shows OpenClaw
  as one of the supported application launch paths.
- Important caveat: the current Ollama library entry shows a `256K` context
  window for the local model listing, so the practical first trial should treat
  local Ollama as `256K` until proven otherwise even though NVIDIA advertises
  up to `1M` context for the model family.

## Workspace Fit

- Strong fit for the worker tier because the stack already treats worker models
  as interchangeable by cost, speed, and capability.
- Natural fit for `gateways/openclaw/` because Ollama can stay isolated inside
  the island and provide a private local reasoning path.
- Complements `OpenClaw Free Integration` and `Lossless Claw` rather than
  replacing them.
- The tradeoff is hardware cost and footprint: the Ollama listing is currently
  large at roughly `87GB`, so the first trial should stay quantized and bounded.

## Hot Take

This is strong enough for `TRIAL` now because the model, license path, and
local Ollama route are all durable and primary-sourced. The right framing is
not "free 1M local context by default," but "serious local worker-brain trial
with a likely 256K Ollama ceiling on day one."

## Next Step

Trial Nemotron 3 Super inside `gateways/openclaw/` only. Start with the local
Ollama path, keep expectations at the currently published `256K` Ollama
context window, and compare one bounded research or coding loop against the
current worker-model mix on quality, speed, and operational cost.

## Context Chain
<- inherits from: /home/evo/workspace/DNA/ops/TECH_RADAR.md
-> overrides by: none
-> live map: /home/evo/workspace/AI_SESSION_BOOTSTRAP.md
-> conventions: /home/evo/workspace/DNA/ops/CONVENTIONS.md
