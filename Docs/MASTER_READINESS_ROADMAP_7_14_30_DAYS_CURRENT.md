# Master Readiness Roadmap — 7 / 14 / 30 Days

**Baseline:** `main` @ `7dfefe2`  
**Orchestrator:** V1.2 · 2026-06-28  
**Overall consolidated readiness:** **~71%** (software FC ~87%; physical **0%**)  
**Verdict:** PARTIAL · Internal TestFlight **CONDITIONAL** · External TF / App Store **NOT READY**

---

## 7-day plan

| Day | Focus | Deliverable | Findings |
|-----|-------|-------------|----------|
| 1 | **Batch 0** | Full iOS 1526 + Watch 1091 PASS @ HEAD | CONS-014 |
| 1–2 | **Batch 9 doc** | Repair `commands_for_cursor/01`–`04` permutation | CONS-001 |
| 2–3 | **Batch 4** | GF preset alignment iOS↔Watch | CONS-002 |
| 3–4 | **Batch 2** | Sync in-flight, userInfo ACK, tombstone HMAC | CONS-003..005 |
| 4–5 | **Batch 6/7** | WAO DepthCapabilityPolicy gate; shallow toggle labeling | CONS-019, CONS-006 |
| 5–7 | **Evidence planning** | Schedule Ultra, paired-device, WAO/HW/shallow sessions | CONS-010..013, CONS-021..022, CONS-042 |

**7-day target readiness:** **~78%** — internal TestFlight **READY (software)** if Batch 0+2+4 pass

---

## 14-day plan

| Week | Focus | Deliverable |
|------|-------|-------------|
| 1 | As 7-day | P1 software closed; command integrity restored |
| 2 | **Batch 8 physical** | Watch Ultra matrix (CONS-010); shallow wet (CONS-042); WAO end-to-end (CONS-021); underwater HW (CONS-022); paired sync (CONS-011); a11y spot checks (CONS-012) |
| 2 | **Batch 1 oracle** | CONS-008 tolerance or independent path; altitude replay progress (CONS-015) |
| 2 | **Batch 6 visual** | Begin pixel baseline capture (CONS-032) |

**14-day target readiness:** **~85%** — physical **~40%** executed; external TestFlight still **NOT READY** unless partial evidence accepted for conditional build

---

## 30-day plan

| Week | Focus | Deliverable |
|------|-------|-------------|
| 1–2 | Physical + paired QA | Signed artifacts in `Docs/QA_EVIDENCE/` |
| 2–3 | **Batch 1/8 external** | Bühlmann reference comparison (CONS-009); GF preset external (CONS-043); Subsurface (CONS-030) |
| 3 | **Batch 5** | Planner lifecycle (CONS-027); field perf sampling (CONS-023..026) |
| 4 | **Batch 9 release** | PDF/legal/marketing (CONS-013, CONS-044); INDEX repair (CONS-034); re-run orchestrator **00** V1.2 |

**30-day target readiness:** **~92%** — external TestFlight **CONDITIONAL**; App Store **CONDITIONAL** pending counsel + Apple review

---

## Trajectory

```text
Today (audit @ 7dfefe2):  71% — P0 FC software 0; P1 software+evidence open; physical 0%
+7 days:                  78% — GF+sync fixed; command repair; verified tests
+14 days:                 85% — partial physical QA (WAO/HW/shallow/Ultra)
+30 days:                 92% — external validation + release packaging (not 100% without chamber/counsel)
```

100% requires: all P1 closed, legal/marketing sign-off, App Store review (external), and no open CONFLICTING command bodies.

---

## June 2026 wave milestones

| Milestone | Day | Gate |
|-----------|-----|------|
| WAO software verified | Done @ 7dfefe2 | SOFTWARE_READY |
| WAO physical signed | Day 10–12 | CONS-021 |
| Crown/HW physical signed | Day 10–14 | CONS-022 |
| Shallow wet QA signed | Day 8–12 | CONS-042 |
| GF import parity code | Day 3–4 | CONS-002 |
| GF external spot-check | Day 20–25 | CONS-043 |

---

## Risk flags

- **CONS-001** delays trustworthy audit re-run until Batch 9 doc repair
- **CONS-002** blocks GF release narrative even when Watch presets software PASS
- Physical **0%** dominates external TestFlight — software readiness alone insufficient
- 2 Watch test-maintenance failures (CONS-017) — quick Batch 0 win
