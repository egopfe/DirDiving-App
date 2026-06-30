# Master Readiness Roadmap — 7 / 14 / 30 Days

**Baseline:** `main` @ `451f8fb` (Snorkeling @ `dbe5d8b`; remediation @ `5d757cc`)  
**Orchestrator:** V1.3 · **Date anchor:** 2026-06-30  
**Overall consolidated readiness:** **~65%** (software remediations closed; physical **0%**; iOS test gate regression)  
**Verdict:** PARTIAL · Internal TestFlight software **CONDITIONAL** · External TF / App Store **NOT READY**

---

## Starting point (@ 451f8fb)

- Command 10 software remediation **COMPLETE** @ `5d757cc`
- Snorkeling P1/P2/P3 software **DELIVERED** @ `dbe5d8b` — reflected in audits 01–06 @ 451f8fb
- Domain audits **01–06 COMPLETE** @ `451f8fb` — **CONS-047 CLOSED**
- Audit **07 + orchestrator 00 COMPLETE** @ `451f8fb`
- **CONS-046 OPEN** — `validate_commands_for_cursor_integrity.sh` FAIL (script drift)
- **CONS-049 OPEN** — iOS Algorithm Tests BUILD FAILED (IOS-P1-001)
- **CONS-048 PENDING_PHYSICAL** — 12 Snorkeling QA templates
- P0 open=0 · P1 open software=2 · Physical/external **0%** executed

---

## 7-day plan (from 2026-06-30)

| Day | Focus | Deliverable | Findings |
|-----|-------|-------------|----------|
| 1 | **Test fix batch** | Snorkeling test compile — disambiguate `distanceMeters`; unify planner draft types | CONS-049 |
| 1–2 | **Script fix batch** | Update `validate_commands_for_cursor_integrity.sh` to V2.2/V1.2/V2.3 | CONS-046 |
| 2–3 | **Audit reruns 02, 05, 07** | Refresh after test fix | CONS-049 |
| 3–5 | **Snorkeling physical QA start** | First open-water / paired-device artifacts | CONS-048 |
| 5–7 | **Legacy physical QA planning** | Ultra depth, WAO, shallow sessions | CONS-010..013, CONS-021..022, CONS-042 |

**7-day target readiness:** **~72%** — iOS tests green; script gate PASS; Snorkeling physical **~10%**

---

## 14-day plan

| Week | Focus | Deliverable |
|------|-------|-------------|
| 1 | Test + script fixes; Snorkeling QA kickoff | CONS-049/046 closed; 2+ Snorkeling signed artifacts |
| 2 | Diving physical campaigns (Ultra, shallow, WAO, HW) | CONS-010, CONS-021, CONS-022, CONS-042 partial |

**14-day target:** Internal TestFlight software **READY**; physical **~25%**; External TF still **NOT READY**

---

## 30-day plan

| Week | Focus | Deliverable |
|------|-------|-------------|
| 1–2 | Software gates + Snorkeling field QA | CONS-048 ≥50% |
| 2–3 | **Batch 8 external** | Bühlmann (CONS-009); GF (CONS-043); Subsurface (CONS-030) |
| 3–4 | Paired sync + a11y + PDF | CONS-011, CONS-012, CONS-013 |
| 4 | **Batch 9 release** | PDF/legal (CONS-013, CONS-044); re-run 00 + 07 |

**30-day target:** External TestFlight **CONDITIONAL** (physical ≥40%); App Store **NOT READY** until legal signed

---

## Milestone checklist

| Milestone | Status | Finding |
|-----------|--------|---------|
| Command V1.2/V2.2/V2.3 upgrade | **DONE** @ bb204f5 | CONS-046 script fix pending |
| Software remediation Command 10 | **DONE** @ 5d757cc | — |
| Snorkeling P1/P2/P3 software | **DONE** @ dbe5d8b | — |
| Domain audits 01–06 refresh | **DONE** @ 451f8fb | CONS-047 closed |
| iOS full test suite green | **BLOCKED** | CONS-049 |
| GF external spot-check | Day 20–25 | CONS-043 |
| App Store legal sign-off | Day 25–30 | CONS-044 |

---

## Blockers that must not slip

- **CONS-049** — blocks trustworthy automated iOS regression
- **CONS-046** — blocks CI/orchestrator preflight
- **CONS-048** — blocks Snorkeling external claims
- **Physical 0%** — blocks External TF and App Store regardless of software PASS
