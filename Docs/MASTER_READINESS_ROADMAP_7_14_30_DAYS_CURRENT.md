# Master Readiness Roadmap — 7 / 14 / 30 Days

**Baseline:** `main` @ `1f62235`  
**Overall consolidated readiness:** **72%** (software strong; physical/external gates open)

---

## 7-day plan

| Day | Focus | Deliverable |
|-----|-------|-------------|
| 1–2 | **Batch 0** | Full iOS + Watch build/test @ HEAD; fix CONS-007 |
| 3–4 | **Batch 5/3 software** | CONS-013 perf test; CONS-008 state restoration spike |
| 5–7 | **Evidence planning** | Schedule Ultra + paired-device QA sessions; populate QA_EVIDENCE folder templates |

**7-day target readiness:** **78%** — internal TestFlight **CONDITIONAL** if Batch 0 passes

---

## 14-day plan

| Week | Focus | Deliverable |
|------|-------|-------------|
| 1 | As 7-day | Software gates green |
| 2 | **Batch 8 physical** | Execute Watch Ultra matrix (CONS-003); paired sync (CONS-004); accessibility spot checks (CONS-005) |
| 2 | **Batch 6 visual** | Begin pixel baseline capture (CONS-009) |

**14-day target readiness:** **85%** — internal TestFlight **READY** if physical partial; external **NOT READY**

---

## 30-day plan

| Week | Focus | Deliverable |
|------|-------|-------------|
| 1–2 | Physical + paired QA | Signed artifacts in QA_EVIDENCE |
| 3 | **External validation** | Bühlmann reference comparison (CONS-002); Subsurface round-trip (CONS-011) |
| 4 | **Batch 9 release** | PDF/legal/marketing (CONS-006); documentation repair (CONS-012); re-run orchestrator 00 |

**30-day target readiness:** **92%** — external TestFlight **CONDITIONAL**; App Store **CONDITIONAL** pending legal sign-off

---

## Trajectory

```text
Today (audit):     72% — software remediation largely complete; evidence gaps dominate
+7 days:           78% — verified build/test + software fixes
+14 days:          85% — partial physical QA
+30 days:          92% — external validation + release packaging (not 100% without counsel/chamber)
```

100% requires: all P1 evidence closed, legal/marketing sign-off, App Store review (external).
