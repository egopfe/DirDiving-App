# Audit Rerun Plan — CURRENT

**Baseline:** `main` @ `2c30412`  
**Policy:** Map remediation batches to required audit reruns

---

## Default batch → audit mapping

| Batch | Name | Audits to rerun |
|-------|------|-----------------|
| **Batch 0** | Baseline protection | 05 (evidence snapshot) |
| **Batch 1** | Watch Full Computer safety-critical | **01, 03, 04, 05** |
| **Batch 2** | Data integrity / sync / persistence | **02, 04, 05, 06** |
| **Batch 3** | Activity architecture / Settings / Logbooks | **02, 03, 04, 06** |
| **Batch 4** | iOS Planner / companion math | **02, 03, 04, 05** |
| **Batch 5** | Performance / concurrency / stale async | **01, 02, 03, 04** |
| **Batch 6** | UI/UX truthfulness / accessibility / WAO tests | **03, 05, 06** (+ **01** if WAO routing policy changes) |
| **Batch 7** | Security / privacy / Apple platform | **04, 05, 06** |
| **Batch 8** | Tests / QA / evidence / physical | **01, 02, 04, 05** |
| **Batch 9** | Release / legal / documentation | **05, 06** |

---

## Finding-specific rerun triggers

| Finding / change | Mandatory reruns | Reason |
|------------------|------------------|--------|
| **CONS-050 / WFC-P2-005** test or routing fix | 01, 03, 04, 05 | WAO crosses Watch/UI/Main/Release |
| **Any FC math / timing / GF change** | 01, 03, 04, 05 | Algorithmic safety priority |
| **Apnea sync/schema change** | 02, 04, 05, 06 | Activity isolation + release claims |
| **Snorkeling route/GPS change** | 02, 03, 05 | Field + UI truthfulness |
| **CONS-053/054 doc repair** | 06 (+ 05 if claims touched) | Documentation truthfulness |
| **Physical QA evidence added** | 01, 03, 05 | Evidence matrices and claims |
| **External Bühlmann campaign** | 01, 02, 05 | CONS-009 closure |

---

## Post-remediation audit 07

**Not part of orchestrator 00.** Launch **07** only after remediation batches complete and before claiming 100% software readiness.

```text
07 → verify CONS-050 closed; iOS 1655 + Watch 1152 green; physical gates still honestly PENDING
```

---

## Current baseline — reruns already complete

| Audit | Last verified HEAD | Status |
|-------|-------------------|--------|
| 01 Watch FC | `2c30412` | CURRENT — PARTIAL |
| 02 iOS | `2c30412` | CURRENT — PARTIAL |
| 03 UI/UX | `2c30412` | CURRENT — PARTIAL |
| 04 Main | `2c30412` | CURRENT — PARTIAL |
| 05 Release | `2c30412` | CURRENT — PARTIAL |
| 06 Docs | `2c30412` | CURRENT — PARTIAL |
| 07 Post-remediation | Prior @ 451f8fb | **STALE** — rerun after next remediation wave |

**CONS-047:** VERIFIED CLOSED — audits 01–06 refreshed @ `2c30412`.

---

## Next rerun after recommended R09

1. **01** Watch FC Forensic — confirm 0 FC regressions; WFC-P2-005 status
2. **03** UI/UX — WAO matrix truthfulness
3. **04** Main — routing policy cross-read
4. **05** Release — Watch suite evidence row update

Do **not** rerun 07 until remediation batch completes.
