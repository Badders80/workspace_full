# Evo2 Build vs Adopt Policy

**Version:** 2026.1  
**Status:** Canonical  
**Scope:** All tools, repos, skills, workflows, integrations, and automation used in evo2.

---

## 1) Policy Statement

Default decision is `Adopt`, not `Build`.

Required order of preference:
1. Reuse an existing internal asset (DNA docs, existing services, existing components).
2. Adopt from approved Tier 1 partners/systems.
3. Adapt/fork a Tier 2 source with guardrails.
4. Build custom only when required by the criteria below.

If this sequence is skipped, the work is out of policy.

---

## 2) Build Is Allowed Only If

Custom build is allowed only when at least one condition is true:
- No viable candidate reaches pilot threshold (`>= 60`) in the scorecard.
- License or compliance blocks otherwise viable options.
- Security/privacy requirements require in-house implementation.
- Integration cost is materially higher than custom build and rollback is safe.
- The capability is a strategic differentiator where ownership is required.

Any custom build must be logged in `ops/DECISION_LOG.md` with rationale and exit criteria.

---

## 3) Trusted Knowledge Base Order (Database At Hand)

Before proposing or building anything new, search in this order:
1. `skills/registry/approved_sources.md`
2. `skills/registry/starred_repo_registry.json` (canonical) and `.md` snapshot
3. `ops/STACK.md`
4. `ops/TECH_RADAR.md` on demand only when checking prior research or evaluation notes
5. `ops/TIER_REGISTRY.md`

If a relevant item exists in `STACK.md`, do not propose alternatives unless `STACK.md` and `ops/DECISION_LOG.md` are updated together. If prior evaluation notes exist in `TECH_RADAR.md`, use them to inform the decision instead of restarting research from scratch.

---

## 4) Complexity Lanes (Basic vs Complex)

| Lane | When To Use | Strategy | Required Approval |
|------|-------------|----------|-------------------|
| `basic` | Small change in mature systems (copy, style, layout, small automation) | Existing stack and templates only | Feature owner |
| `structured` | New module/integration with external systems | Tier 1 first, then Tier 2 pilot | Feature owner + system owner |
| `platform` | Architecture shifts, new runtime, core dependency changes | Formal spike, rollback, and scorecard gates | Architecture review |

Promote to a higher lane immediately if risk increases during implementation.

---

## 5) Mature Website Facelift Guardrails

For mature production sites, default to `basic` lane unless there is a clear reason not to.

Required rules:
- Prefer design-token, spacing, typography, and composition changes over framework swaps.
- Do not add large UI/runtime dependencies for cosmetic updates.
- Preserve or improve performance budgets:
  - Critical-route JS delta: `<= +25KB` gzip
  - CLS: `<= 0.10`
  - LCP target: `<= 2.5s` on representative mobile profile
- Include before/after performance evidence in the PR/change log.
- Include rollback notes for visual changes with broad blast radius.

Escalate from `basic` to `structured` or `platform` when:
- A new rendering/state/runtime layer is introduced.
- More than 10 components have behavior changes.
- Performance budget is exceeded.
- Accessibility regressions are detected.

---

## 6) License Guardrails

Default-allowed for production acceleration:
- MIT
- Apache-2.0
- BSD variants
- ISC

Conditional (review before production):
- MPL-2.0
- LGPL variants

Restricted for core runtime usage without explicit approval:
- GPL/AGPL
- `NOASSERTION` or missing license

Restricted sources can still be used for research/reference and sandbox learning.

---

## 7) Operational Process

1. Fill `ops/ADOPTION_SCORECARD.yaml` for each candidate.
2. Assign lane (`basic`, `structured`, `platform`).
3. Run a time-boxed pilot (default: 2 weeks).
4. Record tier placement in `ops/TIER_REGISTRY.md`.
5. Update `ops/STACK.md` and `ops/DECISION_LOG.md` when a tool becomes live, adopted, or locked.
6. Update `ops/TECH_RADAR.md` when evaluation notes are worth preserving for later on-demand lookup.

---

## 8) Ownership and Debt Controls

Every adopted dependency/workflow must have:
- Named owner
- Review cadence
- Upgrade path
- Rollback plan
- Replacement trigger (when to retire/swap)

No owner means it cannot enter Tier 1.

---

## 9) Review Cadence

- Tier 1: monthly health checks
- Tier 2: bi-weekly during pilot
- Tier 3: quarterly sweep

This policy is enforced for all evo2 migration and new build work.
