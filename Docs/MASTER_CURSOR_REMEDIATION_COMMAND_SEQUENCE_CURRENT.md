# Master Cursor Remediation Command Sequence — Current

**Baseline:** `main` @ `bb204f5` (Snorkeling @ `dbe5d8b`; remediation @ `5d757cc`)  
**Orchestrator:** `00-MASTER_SUPER_ORCHESTRATOR...V1.3`  
**Date:** 2026-06-30

**Command 10 consolidated software remediation: COMPLETE @ `5d757cc`.** Snorkeling P1/P2/P3 software: **COMPLETE @ `dbe5d8b`.** Next work: script fix, audit reruns, physical QA — without regressing closed findings.

---

## Sequence

| Step | Command / action | Batch | Findings | Status |
|------|------------------|-------|----------|--------|
| 0 | **Batch 0:** Full `xcodebuild` iOS + Watch | Batch-0 | CONS-014 | **COMPLETE** @ bb204f5 build PASS |
| 1 | **Batch 9 (doc P0):** Restore command bodies 01–04 | Batch-9 | CONS-001 | **COMPLETE** @ 5d757cc; upgraded V2.2/V1.2 @ bb204f5 |
| 2 | **Batch 4:** iOS GF presets | Batch-4 | CONS-002, CONS-038 | **COMPLETE** @ 5d757cc |
| 3 | **Batch 2:** Sync ACK/tombstone | Batch-2 | CONS-003..005 | **COMPLETE** @ 5d757cc |
| 4 | **Batch 6:** WAO depth gate | Batch-6 | CONS-019, CONS-018 | **COMPLETE** @ 5d757cc |
| 5 | **Batch 1:** Oracle independence | Batch-1 | CONS-008 | **COMPLETE** @ 5d757cc |
| 6 | **Batch 5:** PlannerStore deinit | Batch-5 | CONS-027 | **COMPLETE** @ 5d757cc |
| 7 | **Snorkeling P1/P2/P3 software** | Snorkeling | — | **COMPLETE** @ dbe5d8b |
| 8 | **Script fix:** `validate_commands_for_cursor_integrity.sh` | Script | CONS-046 | **NEXT — P1** |
| 9 | **Audit reruns 01–06** post-Snorkeling | Rerun | CONS-047 | **NEXT — P2** |
| 10 | **Physical QA:** Snorkeling 12 templates | Batch-8 | CONS-048 | **NEXT** |
| 11 | **Physical QA:** Ultra depth/CMAltimeter | Batch-8 | CONS-010 | **NEXT** |
| 12 | **Physical QA:** Shallow wet + WAO + HW | Batch-8 | CONS-042, CONS-021, CONS-022 | **NEXT** |
| 13 | **Paired device QA** | Batch-8 | CONS-011 | **NEXT** |
| 14 | **Accessibility field matrix** | Batch-6/8 | CONS-012 | **NEXT** |
| 15 | **External validation:** Bühlmann + GF | Batch-8 | CONS-009, CONS-043 | **NEXT** |
| 16 | **Release/legal:** PDF + counsel | Batch-9 | CONS-013, CONS-044 | **NEXT** |
| 17 | Re-run **07** post-remediation verification | — | — | **DONE** @ bb204f5 (this wave) |
| 18 | Re-run **00 orchestrator V1.3** | — | All | **DONE** @ bb204f5 |

---

## Do-not-run / do-not-regress

- Do not revert CONS-001..008, CONS-019, CONS-027 fixes without audit rerun
- Do not fabricate physical/external evidence
- Do not convert Snorkeling SOFTWARE_READY into physical PASS (CONS-048)
- Do not weaken HMAC/ACK/tombstone paths
- Do not route Snorkeling data into Diving stores

---

## Recommended next commands

```text
1. Fix Scripts/validate_commands_for_cursor_integrity.sh (CONS-046) — software P1
2. Rerun audits 01–06 in order @ HEAD (CONS-047)
3. Batch 8 — Snorkeling physical QA (12 templates) + Diving physical campaigns
```

Parallel optional:

```text
Batch 9 (doc-only) — README + feature matrix after audit 06 rerun
Batch 8 — External Bühlmann + GF spot-check planning
```

---

## Batch status (@ bb204f5)

| Batch | Scope | Status |
|-------|-------|--------|
| 0 | Baseline protection | **COMPLETE** |
| 1–7 | Software remediation | **COMPLETE** |
| Snorkeling | P1/P2/P3 software | **COMPLETE** @ dbe5d8b |
| Script | Command integrity gate | **OPEN** (CONS-046) |
| 8 | Physical/external QA | **ACTIVE** (+ Snorkeling 12) |
| 9 | Release/legal/docs | **PARTIAL** |

---

## Audit rerun triggers

See `MASTER_AUDIT_RERUN_PLAN_CURRENT.md`. **01–06 STALE** after Snorkeling — rerun before external release claims.
