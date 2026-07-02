# Audit Rerun Plan — CURRENT

**Baseline:** `main` @ `7ae527b`  
**Policy:** Map remediation batches to required audit reruns per orchestrator V1.7

---

## Batch to audit mapping

| Batch | Name | Audits to rerun |
|---|---|---|
| Batch-0 | Baseline protection | 05 |
| Batch-1 | Localization parity + docs truthfulness repair | 01, 02, 03, 04, 05, 06 |
| Batch-2 | Rollback and command governance | 04, 05, 06 |
| Batch-3 | Physical and manual QA campaigns | 01, 02, 03, 05 |
| Batch-4 | External validation and release closure | 01, 02, 05, 06 |

---

## Finding-specific rerun triggers

| Finding | Mandatory reruns | Why |
|---|---|---|
| `CF-002` (`DG-LOC-001`) | 01, 02, 03, 04 | localization failures observed across lanes |
| `CF-008`, `CF-009` | 05, 06 | release claims and doc truthfulness are coupled |
| `CF-007` | 05, 06 | rollback is release compliance evidence |
| `CF-003`, `CF-004`, `CF-010`, `CF-013` | 01, 02, 03, 05 | physical/manual evidence gates affect release posture |
| `CF-001` | 01, 02, 05 | external Buhlmann evidence impacts FC+planner claims |
| `CF-006`, `CF-012` | 04, 06 | command lifecycle integrity is main/docs concern |

---

## Post-remediation command boundary

`00` orchestrator does not execute post-remediation command 07 and does not execute remediation commands 10/11/12.

If command 07 remains missing, record manual continuation and do not treat this as authorization to execute 07 from orchestrator 00.

---

## Immediate rerun plan after Batch-1

1. Rerun 01 and 02 to confirm localization parity closure.
2. Rerun 03 and 04 to validate UI/main consistency.
3. Rerun 05 and 06 to confirm truthfulness and release claims alignment.
