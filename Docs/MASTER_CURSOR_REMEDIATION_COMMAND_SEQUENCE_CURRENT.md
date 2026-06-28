# Master Cursor Remediation Command Sequence — Current

**Baseline:** `main` @ `7dfefe2`  
**Orchestrator:** `00-MASTER_SUPER_ORCHESTRATOR...V1.2`  
**Date:** 2026-06-28

Execute remediation **only after** Batch 0 gates pass. Do not skip batches without documenting dependency override in the consolidated plan.

---

## Sequence

| Step | Command / action | Batch | Findings |
|------|------------------|-------|----------|
| 0 | **Batch 0:** Clean DerivedData; full `xcodebuild` iOS + Watch test @ `7dfefe2` | Batch-0 | CONS-014 |
| 1 | **Batch 9 (doc P0):** Restore `commands_for_cursor/01`–`04` bodies from OOLD + V1.2 sources; add orchestrator STOP guard | Batch-9 | CONS-001 |
| 2 | **Batch 4:** Align iOS GF presets with Watch FC; emit `gradientFactorPreset` in `DivePlanPackageBuilder` | Batch-4 | CONS-002, CONS-038 |
| 3 | **Batch 2:** Fix sync in-flight stuck; symmetric userInfo ACK; harden tombstone HMAC | Batch-2 | CONS-003, CONS-004, CONS-005 |
| 4 | **Batch 6:** Apply `DepthCapabilityPolicy` to water auto-open FC routing; fix WAO startup tests | Batch-6 | CONS-019, CONS-018 |
| 5 | **Batch 1:** Oracle independence hardening OR documented external tolerance | Batch-1 | CONS-008 |
| 6 | **Batch 5:** PlannerStore deinit task cancellation | Batch-5 | CONS-027 |
| 7 | **Batch 3:** iOS navigation state restoration; settings store unification | Batch-3 | CONS-028, CONS-040 |
| 8 | **Batch 7:** Shallow FC toggle labeling; signing manifest CI check | Batch-7 | CONS-006, CONS-007 |
| 9 | **Physical QA:** Watch Ultra depth/CMAltimeter matrix | Batch-8 | CONS-010 |
| 10 | **Physical QA:** Shallow wet + entitlement separation | Batch-8 | CONS-042 |
| 11 | **Physical QA:** Water auto-open end-to-end + Water Lock | Batch-8 | CONS-021 |
| 12 | **Physical QA:** Crown / Action Button underwater | Batch-8 | CONS-022 |
| 13 | **Paired device QA:** sync + briefing + large payload + security | Batch-8 | CONS-011 |
| 14 | **Accessibility field matrix:** VoiceOver + Dynamic Type | Batch-6 | CONS-012 |
| 15 | **External validation:** Bühlmann reference tool comparison | Batch-8 | CONS-009, CONS-043 |
| 16 | **Subsurface desktop round-trip** on exported CSV | Batch-8 | CONS-030 |
| 17 | Pixel-diff baseline capture (59 mockups) | Batch-6 | CONS-032 |
| 18 | **Release/legal:** PDF golden renders + counsel/marketing review | Batch-9 | CONS-013, CONS-044 |
| 19 | Documentation INDEX/README/feature matrix repair | Batch-9 | CONS-034 |
| 20 | Re-run **00 orchestrator V1.2** to refresh consolidated plan | — | All |

---

## Do-not-run early

- Filename-based audits **01**–**04** until **CONS-001** repaired
- UI polish-only commands before Batch 2 sync and Batch 4 GF fixes
- Documentation claiming external validation before Batch 8 evidence exists
- Performance micro-optimizations that weaken HMAC/ACK/replay (Batch 7 policy)
- Converting `SOFTWARE_READY` water auto-open / Crown / GF UI into physical PASS

---

## Recommended first commands after orchestrator

```text
Batch 0 — Full build and test verification @ 7dfefe2 (clean DerivedData; fix 2 Watch test failures)
```

Then (parallel tracks):

```text
Batch 9 (doc) — Repair commands_for_cursor/01–04 permutation (CONS-001)
Batch 4 — iOS GF preset alignment (CONS-002)
Batch 2 — Sync reliability fixes (CONS-003..005)
```

Evidence track (no code unless blockers found):

```text
Batch 8 — Physical + external QA campaign planning and execution
```

---

## Batch 0–9 reference (V1.2)

| Batch | Scope |
|-------|-------|
| 0 | Baseline protection, build/test snapshot |
| 1 | Watch FC safety, oracle, altitude, TTS tolerance |
| 2 | Sync, persistence, HMAC, tombstones |
| 3 | Activity architecture, Settings, Logbooks |
| 4 | iOS Planner, GF presets, import parity |
| 5 | Performance, concurrency, planner lifecycle |
| 6 | UI/UX truthfulness, WAO policy, a11y, visual |
| 7 | Security, privacy, depth entitlements, shallow gating |
| 8 | Tests, physical QA, external validation, paired device |
| 9 | Release, legal, documentation, command repair |

---

## Audit rerun triggers

After any Batch 1/2/4/6/7 software change: rerun affected upstream audits per `MASTER_AUDIT_RERUN_PLAN_CURRENT.md` before updating release claims.
