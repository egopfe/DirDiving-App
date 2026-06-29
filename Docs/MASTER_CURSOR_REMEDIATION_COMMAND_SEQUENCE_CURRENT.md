# Master Cursor Remediation Command Sequence — Current

**Baseline:** `main` @ `0126699` (code-bearing audit baseline @ `4d415c0`; remediation @ `5d757cc`)
**Orchestrator:** `00-MASTER_SUPER_ORCHESTRATOR...V1.2` refresh  
**Date:** 2026-06-29

**Command 10 consolidated software remediation: COMPLETE @ `5d757cc`.** Steps 0–8 below are **DONE**. Execute remaining steps without regressing closed findings.

---

## Sequence

| Step | Command / action | Batch | Findings | Status |
|------|------------------|-------|----------|--------|
| 0 | **Batch 0:** Full `xcodebuild` iOS + Watch targeted remediation tests | Batch-0 | CONS-014 | **COMPLETE** @ 5d757cc |
| 1 | **Batch 9 (doc P0):** Restore `commands_for_cursor/01`–`04` bodies | Batch-9 | CONS-001 | **COMPLETE** @ 5d757cc |
| 2 | **Batch 4:** Align iOS GF presets; emit `gradientFactorPreset` | Batch-4 | CONS-002, CONS-038 | **COMPLETE** @ 5d757cc |
| 3 | **Batch 2:** Sync in-flight, userInfo ACK, tombstone HMAC | Batch-2 | CONS-003..005 | **COMPLETE** @ 5d757cc |
| 4 | **Batch 6:** DepthCapabilityPolicy on water auto-open; WAO tests | Batch-6 | CONS-019, CONS-018 | **COMPLETE** @ 5d757cc |
| 5 | **Batch 1:** Oracle independence verified | Batch-1 | CONS-008 | **COMPLETE** @ 5d757cc |
| 6 | **Batch 5:** PlannerStore deinit task cancellation | Batch-5 | CONS-027 | **COMPLETE** @ 5d757cc |
| 7 | **Batch 3:** iOS navigation / settings (deferred) | Batch-3 | CONS-028, CONS-040 | **OPEN** (P3) |
| 8 | **Batch 7:** Shallow toggles + entitlement authority | Batch-7 | CONS-006, CONS-007 | **COMPLETE** @ 5d757cc |
| 9 | **Physical QA:** Watch Ultra depth/CMAltimeter matrix | Batch-8 | CONS-010 | **NEXT** |
| 10 | **Physical QA:** Shallow wet + entitlement separation | Batch-8 | CONS-042 | **NEXT** |
| 11 | **Physical QA:** Water auto-open end-to-end + Water Lock | Batch-8 | CONS-021 | **NEXT** |
| 12 | **Physical QA:** Crown / Action Button underwater | Batch-8 | CONS-022 | **NEXT** |
| 13 | **Paired device QA:** sync + briefing + large payload | Batch-8 | CONS-011 | **NEXT** |
| 14 | **Accessibility field matrix:** VoiceOver + Dynamic Type | Batch-6/8 | CONS-012 | **NEXT** |
| 15 | **External validation:** Bühlmann reference comparison | Batch-8 | CONS-009, CONS-043 | **NEXT** |
| 16 | **Subsurface desktop round-trip** on exported CSV | Batch-8 | CONS-030 | **NEXT** |
| 17 | Pixel-diff baseline capture (59 mockups) | Batch-6/8 | CONS-032 | **NEXT** |
| 18 | **Release/legal:** PDF golden renders + counsel review | Batch-9 | CONS-013, CONS-044 | **NEXT** |
| 19 | Documentation README/feature matrix repair (doc-only) | Batch-9 | CONS-034 partial | **OPTIONAL** |
| 20 | Optional audit **03** UI/UX rerun @ HEAD | — | Fresh banner only; audit 03 software rerun @ 4d415c0 | **OPTIONAL** |
| 21 | Re-run **00 orchestrator V1.2** after evidence milestones | — | All | **DONE** @ 0126699 |

---

## Do-not-run / do-not-regress

- Do not revert CONS-001..008, CONS-019, CONS-027 fixes without audit rerun
- Do not fabricate physical/external evidence (Batch 8 policy)
- Do not convert `SOFTWARE_READY` WAO/Crown/GF into physical PASS
- Do not weaken HMAC/ACK/tombstone paths (Batch 2 closed)
- UI polish-only before evidence campaigns is **deprioritized** — software P1 closed

---

## Recommended next commands

```text
Batch 8 — Physical QA campaign (Ultra depth, shallow wet, WAO, underwater HW, paired sync)
```

Parallel optional track:

```text
Batch 9 (doc-only) — README + DIR_DIVING_Feature_Comparison.csv repair (CONS-034 partial)
Batch 8 — External Bühlmann + GF spot-check planning
Optional — Audit 03 UI/UX rerun @ HEAD (fresh banner; not blocking internal TF software)
```

---

## Batch 0–9 reference (V1.2)

| Batch | Scope | @ 0126699 |
|-------|-------|-----------|
| 0 | Baseline protection | **COMPLETE** |
| 1 | Watch FC safety, oracle, altitude | **COMPLETE** (software) |
| 2 | Sync, persistence, HMAC | **COMPLETE** |
| 3 | Activity architecture | P3 backlog |
| 4 | iOS Planner, GF presets | **COMPLETE** |
| 5 | Performance, concurrency | **COMPLETE** (CONS-027) |
| 6 | UI/UX truthfulness, WAO, a11y | **COMPLETE** (software) |
| 7 | Security, depth entitlements | **COMPLETE** |
| 8 | Physical QA, external validation | **ACTIVE** |
| 9 | Release, legal, documentation | **PARTIAL** |

---

## Audit rerun triggers

Post-remediation reruns **01, 02, 04, 05, 06** complete @ `5d757cc`. After Batch 8 physical QA: rerun **01, 03, 05**; update physical register. See `MASTER_AUDIT_RERUN_PLAN_CURRENT.md`.
