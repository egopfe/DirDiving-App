# Master Readiness Roadmap — 7 / 14 / 30 Days

**Baseline:** `main` @ `0126699` (code-bearing audit baseline @ `4d415c0`; remediation @ `5d757cc`)
**Orchestrator:** V1.2 refresh · 2026-06-29  
**Overall consolidated readiness:** **~72%** (software **100%**; physical **0%**)  
**Verdict:** PARTIAL · Internal TestFlight software **READY** · External TF / App Store **NOT READY**

---

## Starting point (@ 0126699)

- Command 10 software remediation **COMPLETE**
- Post-remediation audits 01/02/04/05/06 **COMPLETE** @ 5d757cc
- Orchestrator 00 refresh **COMPLETE** @ 0126699
- Audit 03 software refresh **COMPLETE** @ 4d415c0; optional rerun only for a fresh banner
- P0=0 · P1 software open=0 · Physical/external 0% executed

---

## 7-day plan (from 2026-06-29)

| Day | Focus | Deliverable | Findings |
|-----|-------|-------------|----------|
| 1–2 | **Batch 8 planning** | Schedule Ultra, paired-device, WAO/HW/shallow sessions | CONS-010..013, CONS-021..022, CONS-042 |
| 2–3 | **Physical QA start** | Ultra depth/CMAltimeter first artifacts | CONS-010 |
| 3–4 | **Shallow + WAO** | Shallow wet + water auto-open dry/wet routing | CONS-042, CONS-021 |
| 4–5 | **Underwater HW** | Crown/Action Button under Water Lock | CONS-022 |
| 5–7 | **Paired sync** | Two-device sync + briefing round-trip pack | CONS-011 |

**7-day target readiness:** **~78%** — physical **~15%** executed; internal TF software remains **READY**

---

## 14-day plan

| Week | Focus | Deliverable |
|------|-------|-------------|
| 1 | As 7-day | Physical campaign kickoff; signed artifacts begin |
| 2 | **Batch 8 physical** | Complete P1 physical gates (Ultra, shallow, WAO, HW, paired sync, a11y spot checks) |
| 2 | **Batch 8 external planning** | Bühlmann tool selection; GF spot-check protocol |
| 2 | **Optional doc-only** | README + feature matrix repair (CONS-034 partial) |
| 2 | **Optional audit 03** | UI/UX rerun @ HEAD if freshness required |

**14-day target readiness:** **~85%** — physical **~40%** executed; external TestFlight still **NOT READY** unless partial evidence accepted

---

## 30-day plan

| Week | Focus | Deliverable |
|------|-------|-------------|
| 1–2 | Physical + paired QA | Signed artifacts in `Docs/QA_EVIDENCE/` |
| 2–3 | **Batch 8 external** | Bühlmann comparison (CONS-009); GF external (CONS-043); Subsurface (CONS-030) |
| 3 | **Batch 5 field perf** | Optional Instruments sampling (CONS-023..026) |
| 4 | **Batch 9 release** | PDF/legal/marketing (CONS-013, CONS-044); README/matrix; re-run orchestrator **00** |

**30-day target readiness:** **~92%** — external TestFlight **CONDITIONAL**; App Store **CONDITIONAL** pending counsel + Apple review

---

## Trajectory

```text
Prior audit @ 7dfefe2:     71% — P0 doc + P1 software open; physical 0%
Post-orchestrator @ 0126699: 72% — software 100%; physical 0%
+7 days:                    78% — physical campaign started
+14 days:                   85% — partial physical QA (WAO/HW/shallow/Ultra)
+30 days:                   92% — external validation + release packaging
```

100% requires: all P1 evidence closed, legal/marketing sign-off, App Store review, and no stale audit blockers (03 optional).

---

## June 2026 wave milestones

| Milestone | Status | Gate |
|-----------|--------|------|
| WAO software verified | **DONE** @ 5d757cc | SOFTWARE_READY |
| GF import parity | **DONE** @ 5d757cc | CONS-002 closed |
| Sync reliability | **DONE** @ 5d757cc | CONS-003..005 closed |
| Command integrity | **DONE** @ 5d757cc | CONS-001 closed |
| WAO physical signed | Day 3–7 | CONS-021 |
| Crown/HW physical signed | Day 4–10 | CONS-022 |
| Shallow wet QA signed | Day 2–7 | CONS-042 |
| GF external spot-check | Day 20–25 | CONS-043 |

---

## Risk flags

- Physical **0%** dominates external TestFlight — software readiness alone insufficient
- Audit **03 stale** — low risk (no layout changes); optional rerun before external TF polish gate
- Legal/marketing (CONS-044) cannot be closed by software remediation alone
- Do not fabricate QA_EVIDENCE artifacts
