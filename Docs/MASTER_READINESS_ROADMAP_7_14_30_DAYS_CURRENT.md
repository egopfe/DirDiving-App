# Master Readiness Roadmap — 7 / 14 / 30 Days

**Baseline:** `main` @ `bb204f5` (Snorkeling P1/P2/P3 @ `dbe5d8b`; prior remediation @ `5d757cc`; upstream audits stale @ `905692e`)  
**Orchestrator:** V1.3 · **Date anchor:** 2026-06-30  
**Overall consolidated readiness:** **~70%** (prior software **100%**; upstream **STALE**; physical **0%** + 12 Snorkeling QA pending)  
**Verdict:** PARTIAL · Internal TestFlight software **CONDITIONAL** (rerun 01–06) · External TF / App Store **NOT READY**

---

## Starting point (@ bb204f5)

- Command 10 software remediation **COMPLETE** @ `5d757cc`
- Snorkeling P1/P2/P3 software **DELIVERED** @ `dbe5d8b` — 14 test files; **not yet in domain audits 01–06**
- Orchestrator 00 V1.3 refresh **COMPLETE** @ `bb204f5`
- Audit 07 post-remediation verification **COMPLETE** @ `bb204f5`
- **CONS-046 OPEN** — `validate_commands_for_cursor_integrity.sh` FAIL (script drift)
- **CONS-047 STALE_UPSTREAM** — audits 01–06 pre-Snorkeling
- **CONS-048 PENDING_PHYSICAL** — 12 Snorkeling QA templates
- P0 software open=0 · P1 software open=1 (CONS-046) · Physical/external **0%** executed

---

## 7-day plan (from 2026-06-30)

| Day | Focus | Deliverable | Findings |
|-----|-------|-------------|----------|
| 1 | **Script fix batch** | Update `validate_commands_for_cursor_integrity.sh` to V2.2/V1.2/V2.3 | CONS-046 |
| 1–2 | **Audit reruns 04, 02** | Snorkeling sync + iOS surfaces @ HEAD | CONS-047 |
| 2–3 | **Audit reruns 03, 05** | UI/UX + release QA with Snorkeling templates | CONS-047, CONS-048 |
| 3–4 | **Audit reruns 01, 06** | Watch isolation + docs/command matrix | CONS-047 |
| 4–5 | **Snorkeling physical QA start** | First open-water / paired-device artifacts | CONS-048 |
| 5–7 | **Legacy physical QA planning** | Ultra depth, WAO, shallow sessions | CONS-010..013, CONS-021..022, CONS-042 |

**7-day target readiness:** **~75%** — upstream audits refreshed; Snorkeling physical **~10%**; script gate **PASS**

---

## 14-day plan

| Week | Focus | Deliverable |
|------|-------|-------------|
| 1 | As 7-day | Script fix + audit reruns 01–06 + Snorkeling QA kickoff |
| 2 | **Snorkeling physical** | Complete 12 SNORKELING_* template folders with signed artifacts |
| 2 | **Batch 8 physical (Diving)** | P1 gates: Ultra, shallow, WAO, HW, paired sync |
| 2 | **Orchestrator rerun** | 00 V1.3 + 07 after 01–06 fresh |

**14-day target readiness:** **~82%** — physical **~25%** (Snorkeling + partial Diving); external TestFlight still **NOT READY**

---

## 30-day plan

| Week | Focus | Deliverable |
|------|-------|-------------|
| 1–2 | Audit reruns + Snorkeling + Diving physical | Signed `Docs/QA_EVIDENCE/` |
| 2–3 | **Batch 8 external** | Bühlmann (CONS-009); GF (CONS-043); Subsurface (CONS-030) |
| 3 | **Field perf** | CONS-023..026; Snorkeling map/GPS battery |
| 4 | **Batch 9 release** | PDF/legal (CONS-013, CONS-044); re-run 00 + 07 |

**30-day target readiness:** **~90%** — external TestFlight **CONDITIONAL**; App Store **CONDITIONAL** pending counsel

---

## Trajectory

```text
Post-orchestrator @ 0126699:  72% — software 100%; physical 0%
Snorkeling wave @ dbe5d8b:    70% — upstream STALE; +12 QA pending
+7 days @ 2026-07-07:         75% — reruns + script fix + Snorkeling QA start
+14 days:                     82% — Snorkeling physical + partial Diving QA
+30 days:                     90% — external validation + release packaging
```

100% requires: all P1 evidence closed, 01–06 current @ HEAD, legal sign-off, App Store review.

---

## June 2026 / Snorkeling wave milestones

| Milestone | Status | Gate |
|-----------|--------|------|
| WAO software verified | **DONE** @ 5d757cc | SOFTWARE_READY |
| GF import parity | **DONE** @ 5d757cc | CONS-002 closed |
| Snorkeling P1/P2/P3 software | **DONE** @ dbe5d8b | SOFTWARE_READY — audits STALE |
| Command V1.2/V2.2/V2.3 upgrade | **DONE** @ bb204f5 | CONS-046 script fix pending |
| Snorkeling physical QA (12) | Day 4–14 | CONS-048 |
| Domain audits 01–06 refresh | Day 1–4 | CONS-047 |
| WAO physical signed | Day 5–14 | CONS-021 |
| GF external spot-check | Day 20–25 | CONS-043 |

---

## Risk flags

- **STALE upstream 01–06** — Snorkeling and command upgrade invisible to domain audits until rerun
- **CONS-046** — automated command integrity gate FAIL blocks trustworthy preflight
- Physical **0%** + 12 new Snorkeling templates dominate external TestFlight
- Do not fabricate QA_EVIDENCE artifacts or claim physical PASS
