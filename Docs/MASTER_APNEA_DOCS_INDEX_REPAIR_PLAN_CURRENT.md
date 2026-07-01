# Master Apnea Docs Index Repair Plan — Current

**Audit:** Command 06 V1.5 — Apnea first-class documentation alignment  
**Target:** `Docs/INDEX.md` Apnea sections  
**Baseline:** `main` @ `2c30412`  
**Date:** 2026-07-01

Do **not** edit INDEX in this audit pass. Exact planned additions below.

---

## 1. Apnea first-class audit block (P1 — add near top after orchestrator)

```markdown
## Aggiornamento indice 2026-07-01 — Apnea first-class audit wave @ `2c30412`

Audits 01–05 V1.5 Apnea scope verified: no decompression/GF leakage; strict logbook/settings ownership; WAO does not auto-start session; **PHYSICAL_QA_PENDING**.

| Campo | Valore |
|-------|--------|
| **iOS Apnea audit** | [`MASTER_IOS_APNEA_FULL_DEEP_AUDIT_CURRENT.md`](MASTER_IOS_APNEA_FULL_DEEP_AUDIT_CURRENT.md) |
| **UI/UX Apnea audit** | [`MASTER_UI_UX_APNEA_FULL_DEEP_AUDIT_CURRENT.md`](MASTER_UI_UX_APNEA_FULL_DEEP_AUDIT_CURRENT.md) |
| **Apnea release/QA** | [`MASTER_APNEA_RELEASE_QA_EVIDENCE_AUDIT_CURRENT.md`](MASTER_APNEA_RELEASE_QA_EVIDENCE_AUDIT_CURRENT.md) |
| **Apnea doc alignment** | [`MASTER_APNEA_DOCUMENTATION_ALIGNMENT_CURRENT.csv`](MASTER_APNEA_DOCUMENTATION_ALIGNMENT_CURRENT.csv) |
| **Apnea truthfulness** | [`MASTER_APNEA_DOCUMENTATION_TRUTHFULNESS_MATRIX_CURRENT.csv`](MASTER_APNEA_DOCUMENTATION_TRUTHFULNESS_MATRIX_CURRENT.csv) |
| **WAO Apnea boundary** | [`MASTER_WATCH_APNEA_WATER_AUTO_OPEN_BOUNDARY_MATRIX_CURRENT.csv`](MASTER_WATCH_APNEA_WATER_AUTO_OPEN_BOUNDARY_MATRIX_CURRENT.csv) |
| **Verdict** | **INTERNAL_READY** · **PHYSICAL_QA_PENDING** · **NOT certified coaching** |
```

---

## 2. Apnea architecture cross-links (P2)

Add to existing Apnea architecture table (~line 1004):

- [`MASTER_IOS_APNEA_SETTINGS_OWNERSHIP_MATRIX_CURRENT.csv`](MASTER_IOS_APNEA_SETTINGS_OWNERSHIP_MATRIX_CURRENT.csv)
- [`MASTER_IOS_APNEA_LOGBOOK_OWNERSHIP_MATRIX_CURRENT.csv`](MASTER_IOS_APNEA_LOGBOOK_OWNERSHIP_MATRIX_CURRENT.csv)
- [`MASTER_IOS_APNEA_SYNC_SCHEMA_MATRIX_CURRENT.csv`](MASTER_IOS_APNEA_SYNC_SCHEMA_MATRIX_CURRENT.csv)
- [`MASTER_UI_UX_APNEA_FEATURE_IMPLEMENTATION_MATRIX_CURRENT.csv`](MASTER_UI_UX_APNEA_FEATURE_IMPLEMENTATION_MATRIX_CURRENT.csv)
- [`MASTER_APNEA_PHYSICAL_WET_QA_MATRIX_CURRENT.csv`](MASTER_APNEA_PHYSICAL_WET_QA_MATRIX_CURRENT.csv)

---

## 3. Legacy filename banner (P2)

Add planned banner to `APNEA_EXPERIMENTAL_SPEC.md` header:

```markdown
> **Legacy filename.** Apnea is production on `main`. See [`APNEA_ARCHITECTURE.md`](APNEA_ARCHITECTURE.md). Buddy-only experimental scope remains in [`EXPERIMENTAL_FEATURES.md`](EXPERIMENTAL_FEATURES.md).
```

---

## 4. Reconcile Apnea P1/P2/P3 block SHA (P1)

Update existing block @ `ad1c836` → `2c30412` and add cross-link to audits 02/03/05 Apnea outputs.

---

## 5. Negative claim preservation (P1 — no edit required if labels kept)

Ensure INDEX Apnea blocks never claim:

- Apnea auto-detection physically validated
- Water auto-open starts Apnea session
- Recovery countdown is medical advice
- Apnea is certified coaching or decompression guidance

Current posture: **PASS** when PENDING labels retained.
