# Readiness Roadmap — 7 / 14 / 30 Days — CURRENT

**Anchor date:** 2026-07-01  
**Baseline:** `main` @ `2c30412`  
**Overall verdict:** PARTIAL

---

## 7-day plan

**Goal:** Close remaining **software** gaps; establish non-regression gates; repair **P0 documentation** contradictions.

| Day | Action | Findings | Gate |
|-----|--------|----------|------|
| 1–2 | R09: Align WAO routing tests (CONS-050) + Snorkeling progress (CONS-051) | WFC-P2-005 | G-009 1152/1152 Watch PASS |
| 2 | Rerun audits 01; 03; 04; 05 @ HEAD | — | Upstream coherence |
| 3 | Repair P0 legacy claim docs (CONS-053) | DOC-P0-001; DOC-P0-002 | G-025 no P0 contradictions |
| 4 | Refresh INDEX/README baseline to 2c30412 (CONS-054) | INDEX ad1c836 drift | G-025 |
| 5 | Verify all Batch-0 gates G-001..G-009 | CONS-046; CONS-049 | CI green |
| 6–7 | Scaffold physical QA packs (templates → assigned owners) | CONS-048; CONS-010 | No false PASS marks |

**Out of scope for 7 days:** UI polish (P3/P4), external Bühlmann campaign execution, App Store legal sign-off.

---

## 14-day plan

**Goal:** Reduce **P1 physical scaffolding**; prepare **internal TestFlight evidence** with honest disclosure.

| Week | Action | Findings |
|------|--------|----------|
| 1 | Complete 7-day software + doc truth plan | CONS-050; CONS-053; CONS-054 |
| 2a | Execute paired-device sync QA pilot (CONS-011) | Paired Watch+iPhone |
| 2b | Begin Watch FC shallow wet QA planning (CONS-042) | Safe test setup |
| 2c | Begin WAO preferred-destination wet QA (CONS-021) | Water Lock setup |
| 2d | Start Snorkeling open-water QA (first 4/12 CONS-048) | Field GPS |
| 2e | Apnea wet auto-detection pilot (APNEA-PHY-001) | Apnea boundary |
| 2f | Manual accessibility session (CONS-012) | VoiceOver notes |

**Target @ day 14:** Internal TestFlight build with **READY** software + **signed partial physical evidence** (not 100%).

---

## 30-day plan

**Goal:** **External TestFlight / professional beta readiness** trajectory — not App Store certification.

| Week | Action | Findings |
|------|--------|----------|
| 3 | Complete Snorkeling 12/12 field QA (CONS-048) | SNORKELING_* |
| 3 | Watch FC wet depth + CMAltimeter (CONS-010) | Physical FC |
| 3 | Underwater Crown/AB Water Lock (CONS-022) | HW matrix |
| 4 | External Bühlmann spot-check campaign start (CONS-009) | Third-party reviewer |
| 4 | GF preset external comparison (CONS-043) | GF narrative |
| 4 | Legal/marketing review scheduling (CONS-044) | Counsel |
| 4 | Pixel-diff baseline capture (CONS-032) | 59 mockups |
| 4 | Subsurface CSV round-trip (CONS-030) | Desktop validation |

**Target @ day 30:** External TestFlight **CONDITIONAL** — physical evidence >50%; external validation in progress; App Store still **NOT READY**.

---

## Readiness trajectory

| Milestone | Target date | Expected status |
|-----------|-------------|-----------------|
| Watch CI fully green | Day 2 | 1152/1152 |
| P0 docs repaired | Day 3 | CONS-053 closed |
| Internal TF software | Day 5 | **READY** (disclosure) |
| First physical artifacts | Day 14 | Partial signed packs |
| External TF candidate | Day 30 | **CONDITIONAL** |
| App Store | Day 30+ | **NOT READY** (legal + external) |

---

## Explicit non-goals (30 days)

- No certification or EN13319 compliance claims
- No "100% release readiness" without audit 07 post-remediation
- No Command 10/11 re-execution from orchestrator 00
- No conversion of simulator evidence to physical PASS
