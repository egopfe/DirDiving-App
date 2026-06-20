# DIR DIVING — Readiness to 100% Plan (Current)

**Command:** 12 — Test & QA Evidence Audit  
**Date:** 2026-06-20  
**Branch:** `main` @ `817d1b1`  
**Current overall test/QA evidence readiness:** **78%**  
**Target:** **100% evidence readiness** (including physical and external packs)

---

## Readiness layers

| Layer | Current | Target | Gap |
|-------|--------:|-------:|----:|
| Automated unit/integration | 92% | 100% | 8% |
| Simulator validation scripts | 88% | 100% | 12% |
| Physical Watch evidence | 35% | 100% | 65% |
| Physical iPhone evidence | 40% | 100% | 60% |
| Paired-device evidence | 30% | 100% | 70% |
| External reference validation | 45% | 100% | 55% |
| App Store / compliance | 70% | 100% | 30% |

Software-only readiness (Commands 7–11) is already **~100%** on `817d1b1`. The path to **100% overall evidence** is dominated by **physical and external packs**, not new unit tests.

---

## Phase 1 — Close remaining software gaps (estimated 1–2 weeks)

| Step | Action | Owner | Exit criteria |
|------|--------|-------|---------------|
| 1.1 | Run full `validate_watch_math_readiness.sh` on CI hardware after simulator bootstrap fix | Eng | Script PASS in CI log |
| 1.2 | Add UI snapshot tests for planner MOD/ratio-deco visual contracts (optional P3) | Eng | Snapshot tests in iOS suite |
| 1.3 | Wire Command 12 traceability CSV into release checklist cross-links | Eng | `RELEASE_CHECKLIST.md` references matrix |

**No production code changes required** unless new gaps discovered.

---

## Phase 2 — Physical Watch evidence (estimated 2–4 weeks)

| Step | Action | Devices | Exit criteria |
|------|--------|---------|---------------|
| 2.1 | Execute `WATCH_ULTRA_PHYSICAL_QA_MATRIX.md` rows | Ultra + 41 mm | `QA_EVIDENCE/WATCH_ULTRA/` PASS artifacts |
| 2.2 | Apnea wet/battery/thermal procedures | Ultra | `APNEA_BATTERY_THERMAL`, `APNEA_WET_INTERACTION` PASS |
| 2.3 | Snorkeling GPS + battery/thermal + water lock | Ultra | SNK-QA-009, SNK-QA-010, SNK-QA-004 PASS |
| 2.4 | Full Computer 2–4 h field session (battery/thermal log) | Ultra | `PHYSICAL_PERFORMANCE_QA_PLAN_CURRENT.md` evidence |
| 2.5 | Underwater entitlement depth capture (signed build) | Ultra | `HARDWARE_QA_MATRIX` QA-002 artifact |

---

## Phase 3 — Physical iPhone + accessibility (estimated 1–2 weeks)

| Step | Action | Devices | Exit criteria |
|------|--------|---------|---------------|
| 3.1 | `IOS_PLANNER_VISUAL_QA_MATRIX.md` at Dynamic Type XL | Smallest supported iPhone | Screenshots in `IOS_ACCESSIBILITY/` |
| 3.2 | VoiceOver journeys per `IOS_DYNAMIC_TYPE_VOICEOVER_QA_MATRIX.md` | iPhone | `DYNAMIC_TYPE_VOICEOVER/` PASS |
| 3.3 | 500+ logbook scroll profiling | iPhone | Performance external QA folder evidence |
| 3.4 | PDF render/share checklist | iPhone | `PDF_RENDER/` PASS |

---

## Phase 4 — Paired-device + cloud (estimated 1–2 weeks)

| Step | Action | Setup | Exit criteria |
|------|--------|-------|---------------|
| 4.1 | `WATCH_IOS_SYNC_QA_MATRIX.md` full matrix | Paired Watch + iPhone | `WATCH_IOS_SYNC/` PASS |
| 4.2 | Low-battery + intermittent connection scenarios | Paired devices | Logs in sync evidence folder |
| 4.3 | `ICLOUD_TWO_DEVICE_QA_MATRIX.md` tombstone test | Two iPhones | `ICLOUD_TWO_DEVICE/` PASS |
| 4.4 | Apnea + Snorkeling sync evidence packs | Paired devices | Activity-specific folders PASS |

---

## Phase 5 — External reference validation (estimated 4–8 weeks, parallel)

| Step | Action | Exit criteria |
|------|--------|---------------|
| 5.1 | Bühlmann external golden campaign | `BUHLMANN_EXTERNAL/` signed report |
| 5.2 | CCR external rebreather validation | `CCR_EXTERNAL/` signed report |
| 5.3 | Subsurface CSV round-trip with external tool | `SUBSURFACE_EXTERNAL/` PASS |
| 5.4 | Optional ratio deco external reference | `RATIO_DECO_EXTERNAL/` if marketed |

---

## Phase 6 — App Store release gate (estimated 1 week)

| Step | Action | Exit criteria |
|------|--------|---------------|
| 6.1 | Capture App Store screenshots per activity | `APP_STORE_MARKETING/` complete |
| 6.2 | TestFlight sensor-source disclosure evidence | `WATCH_TESTFLIGHT_SENSOR_SOURCE_QA.md` |
| 6.3 | Final release checklist sign-off | All `RELEASE_CHECKLIST.md` rows PASS or accepted risk |

---

## Tracking metrics

Update after each evidence pack closes:

```
Evidence readiness = (PASS rows in PHYSICAL_DEVICE_QA_MATRIX + PASS external gaps + PASS traceability rows) / (total required rows)
```

Current counts (Command 12 baseline):

- Traceability matrix: **52 rows** — **38 PASS**, **14 NOT PASSED**
- Physical device matrix: **32 rows** — **0 PASS**, **32 NOT PASSED**
- External gaps: **32 open**

---

## Non-negotiable rules

1. **No evidence = not passed** — do not upgrade status from simulator tests alone.
2. Do not fabricate tester/reviewer names, device serials, or underwater measurements.
3. Software regression gates (Commands 7–11) must remain green while executing physical QA.
4. Accepted residual risks require product sign-off documented in `RELEASE_CHECKLIST.md`.

---

## Verdict path

| Milestone | Expected readiness |
|-----------|-------------------|
| After Phase 1 (software only) | ~82% |
| After Phases 2–3 (physical) | ~92% |
| After Phases 4–5 (paired + external) | ~98% |
| After Phase 6 (App Store) | **100%** |
