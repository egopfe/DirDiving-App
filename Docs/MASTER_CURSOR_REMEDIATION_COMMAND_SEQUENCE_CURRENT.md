# Master Cursor Remediation Command Sequence — Current

**Baseline:** `main` @ `451f8fb` (Snorkeling @ `dbe5d8b`; remediation @ `5d757cc`)  
**Orchestrator:** `00-MASTER_SUPER_ORCHESTRATOR...V1.3`  
**Date:** 2026-06-30

**Command 10 consolidated software remediation: COMPLETE @ `5d757cc`.** Snorkeling P1/P2/P3 software: **COMPLETE @ `dbe5d8b`.** Domain audits **01–06: COMPLETE @ `451f8fb` (CONS-047 closed).** Next: test compile fix, script fix, physical QA.

---

## Sequence

| Step | Command / action | Batch | Findings | Status |
|------|------------------|-------|----------|--------|
| 0 | **Batch 0:** Full `xcodebuild` iOS + Watch build | Batch-0 | CONS-014 | **PARTIAL** — builds PASS; iOS tests FAIL |
| 1 | **Batch 9 (doc P0):** Restore command bodies 01–04 | Batch-9 | CONS-001 | **COMPLETE** @ 5d757cc |
| 2 | **Batch 4:** iOS GF presets | Batch-4 | CONS-002, CONS-038 | **COMPLETE** @ 5d757cc |
| 3 | **Batch 2:** Sync ACK/tombstone | Batch-2 | CONS-003..005 | **COMPLETE** @ 5d757cc |
| 4 | **Batch 6:** WAO depth gate | Batch-6 | CONS-019, CONS-018 | **COMPLETE** @ 5d757cc |
| 5 | **Batch 1:** Oracle independence | Batch-1 | CONS-008 | **COMPLETE** @ 5d757cc |
| 6 | **Batch 5:** PlannerStore deinit | Batch-5 | CONS-027 | **COMPLETE** @ 5d757cc |
| 7 | **Snorkeling P1/P2/P3 software** | Snorkeling | — | **COMPLETE** @ dbe5d8b |
| 8 | **Audit reruns 01–06** @ HEAD | Rerun | CONS-047 | **COMPLETE** @ 451f8fb |
| 9 | **Audit 07 + orchestrator 00** | Verification | — | **COMPLETE** @ 451f8fb |
| 10 | **Test fix:** Snorkeling iOS Algorithm Tests compile | Batch-0 | CONS-049 | **NEXT — P1** |
| 11 | **Script fix:** `validate_commands_for_cursor_integrity.sh` | Script | CONS-046 | **NEXT — P1** |
| 12 | **Physical QA:** Snorkeling 12 templates | Batch-8 | CONS-048 | **NEXT** |
| 13 | **Physical QA:** Ultra depth/CMAltimeter | Batch-8 | CONS-010 | **NEXT** |
| 14 | **Physical QA:** Shallow wet + WAO + HW | Batch-8 | CONS-042, CONS-021, CONS-022 | **NEXT** |
| 15 | **Paired device QA** | Batch-8 | CONS-011 | **NEXT** |
| 16 | **Accessibility field matrix** | Batch-6/8 | CONS-012 | **NEXT** |
| 17 | **External validation:** Bühlmann + GF | Batch-8 | CONS-009, CONS-043 | **NEXT** |
| 18 | **Release/legal:** PDF + counsel | Batch-9 | CONS-013, CONS-044 | **NEXT** |

---

## Recommended next commands

```text
1. Fix Snorkeling test compile — disambiguate distanceMeters; unify SnorkelingRoutePlannerDraft types (CONS-049)
2. Fix Scripts/validate_commands_for_cursor_integrity.sh to V2.2/V1.2/V2.3 (CONS-046)
3. Batch 8 — Snorkeling physical QA (12 templates) + Diving physical campaigns
```

---

## Batch status (@ 451f8fb)

| Batch | Scope | Status |
|-------|-------|--------|
| 0 | Baseline protection | **PARTIAL** — iOS tests blocked |
| 1–7 | Software remediation | **COMPLETE** |
| Snorkeling | P1/P2/P3 software | **COMPLETE** @ dbe5d8b |
| Rerun | Audits 01–06 | **COMPLETE** @ 451f8fb |
| Script | Command integrity gate | **OPEN** (CONS-046) |
| 8 | Physical/external QA | **ACTIVE** (+ Snorkeling 12) |
| 9 | Release/legal/docs | **PARTIAL** |

---

## Audit rerun triggers

See `MASTER_AUDIT_RERUN_PLAN_CURRENT.md`. **01–06 CURRENT @ 451f8fb.** Rerun **02, 05, 07** after CONS-049 fix.
