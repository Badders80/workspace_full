# promptfoo Intake

Date: 2026-03-17
Category: LLM Evaluation & Red Teaming Framework
Source:
- https://www.promptfoo.dev/
- https://github.com/promptfoo/promptfoo

## Summary

promptfoo is an open-source CLI and library for structured LLM evaluation. It supports YAML-defined test cases, prompt and model comparisons, assertions, caching, CI integration, side-by-side result review, and automated red-teaming for prompt injection, jailbreaks, unsafe tool use, and related failure modes.

## Quick-Start Notes

- Install: `npm install -g promptfoo`
- Initialize: `npx promptfoo init`
- Configure providers and tests in `promptfooconfig.yaml`
- Run evals with `promptfoo eval`
- Optional red-team path: `npx promptfoo@latest redteam setup`

## Notable Fit Notes

- Strong fit for local or CI-based eval loops with no daemon or new hosted dependency
- High leverage for validating DNA-chain fidelity, prompt regressions, and agent behavior
- Supports the current multi-provider pattern across Gemini, Groq, OpenRouter, and local models
- Complements current manual prompt review rather than replacing it

## Recommendation

Status recommendation: `TRIAL`

Run one bounded eval suite against the DNA chain or a small agent workflow and log the results before widening usage.

## Context Chain
<- inherits from: /home/evo/workspace/DNA/AGENTS.md
-> overrides by: none
-> live map: /home/evo/workspace/AI_SESSION_BOOTSTRAP.md
-> conventions: /home/evo/workspace/DNA/ops/CONVENTIONS.md
