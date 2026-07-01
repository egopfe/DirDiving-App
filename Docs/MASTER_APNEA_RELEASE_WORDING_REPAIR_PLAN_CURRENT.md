# Master Apnea Release Wording Repair Plan — Current

**Audit:** Command 06 V1.5 — Apnea release-claim safety  
**Baseline:** `main` @ `2c30412`  
**Date:** 2026-07-01

Do **not** edit source docs in this audit pass.

---

## P0 — None

No P0 Apnea-specific unsupported certification claims found in primary safety/release docs @ `2c30412`. Audits 02/03/05 confirm mandatory negative checks **PASS**.

---

## P1 — INDEX verdict reconciliation

| File | Section | Exact change | Why | Audit rerun |
|------|---------|--------------|-----|-------------|
| `Docs/INDEX.md` | CONS-046 V1.5 block | Change **SOFTWARE_READY 100%** to **SOFTWARE_READY (code/tests)** · audits 01–05 **PARTIAL** · **PHYSICAL_QA_PENDING** | INDEX overstates release readiness vs upstream audit verdicts | 06 |
| `Docs/INDEX.md` | Apnea P1/P2/P3 block | Add **NOT certified coaching** · **NOT decompression** · link Apnea audit outputs | Apnea first-class truthfulness | 06 |

---

## P2 — Copy and matrix

| File | Section | Exact change | Why | Audit rerun |
|------|---------|--------------|-----|-------------|
| `APNEA_EXPERIMENTAL_SPEC.md` | Header | Add legacy banner pointing to `APNEA_ARCHITECTURE.md` | Filename implies experimental | 06 |
| `DIR_DIVING_Feature_Comparison.csv` | Rows 12–26 vs 430 | Mark codex experimental rows **SUPERSEDED by MAIN row 430** | Duplicate status confuses release posture | 06 |
| `APNEA_ARCHITECTURE.md` | Footer | Add links to `MASTER_APNEA_RELEASE_QA_EVIDENCE_AUDIT_CURRENT.md` and WAO boundary matrix | Discoverability | 06 |
| `TESTFLIGHT_REVIEW_NOTES.md` | Apnea bullet | Explicit: Apnea training aid · not medical · wet QA pending | Store review safety | 05 |

---

## P3 — Polish

| File | Section | Exact change | Why |
|------|---------|--------------|-----|
| `Docs/INDEX.md` | Apnea architecture table | Link `MASTER_APNEA_CLAIMS_EVIDENCE_MATRIX_CURRENT.csv` | Claims traceability |
| `MASTER_UI_UX_APNEA_FULL_DEEP_AUDIT_CURRENT.md` | Open findings | Cross-link P2 alarms editor gap in architecture doc | Single source of truth |

---

## Mandatory negative claims — preserve in all Apnea release copy

```text
No decompression wording in Apnea.
No GF/gas/MOD/PPO2/deco settings in Apnea.
No medical guarantee for recovery.
No claim that Apnea auto-detection or wet behavior is physically validated unless evidence exists.
No claim that water auto-open starts an Apnea session.
No cross-activity Apnea/Diving/Snorkeling logbook or settings leakage.
```

**Status @ 2c30412:** All six checks **PASS** in audited production paths.
