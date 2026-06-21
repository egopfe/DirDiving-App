# DIR DIVING — External Validation Gaps (Current)

**Command:** 12 — Test & QA Evidence Audit  
**Date:** 2026-06-20  
**Branch:** `main` @ `817d1b1`

This document consolidates **external** and **physical** validation gaps. Software gates may PASS while these remain **NOT PASSED** because no signed evidence pack exists.

---

## Gap summary

| Category | Open gaps | Software substitute allowed? |
|----------|----------:|------------------------------|
| Physical Watch Ultra | 12 | **No** |
| Physical iPhone | 7 | **No** |
| Paired-device | 8 | **No** |
| Underwater entitlement | 1 | **No** |
| External algorithm reference | 3 | **No** |
| App Store / legal | 1 | **No** |
| **Total NOT PASSED** | **32** | — |

---

## Physical Watch gaps

| Gap ID | Description | Evidence folder | Blocking |
|--------|-------------|-----------------|----------|
| EXT-GAP-W-01 | Ultra mock-fallback banner screenshot | `QA_EVIDENCE/WATCH_ULTRA/` | TestFlight |
| EXT-GAP-W-02 | Underwater depth entitlement session | `QA_EVIDENCE/WATCH_ULTRA/` | Production depth |
| EXT-GAP-W-03 | Ascent/depth haptics on wrist | `QA_EVIDENCE/WATCH_ULTRA/` | Safety UX |
| EXT-GAP-W-04 | Full Computer 2–4 h battery/thermal | `PERFORMANCE_EXTERNAL_QA_PENDING_CURRENT.md` | Field claim |
| EXT-GAP-W-05 | Apnea wet/battery/thermal | `QA_EVIDENCE/APNEA_BATTERY_THERMAL/` | Apnea release |
| EXT-GAP-W-06 | Snorkeling GPS accuracy field | `QA_EVIDENCE/SNORKELING_GPS/` | Navigation trust |
| EXT-GAP-W-07 | Snorkeling battery/thermal long route | `QA_EVIDENCE/SNORKELING_BATTERY_THERMAL/` | Field claim |
| EXT-GAP-W-08 | 41 mm layout clipping | `QA_EVIDENCE/SNORKELING_WATCH_LAYOUTS/` | Smallest Watch |

---

## Physical iPhone gaps

| Gap ID | Description | Evidence folder | Blocking |
|--------|-------------|-----------------|----------|
| EXT-GAP-I-01 | Planner visual QA Dynamic Type XL | `QA_EVIDENCE/IOS_ACCESSIBILITY/` | App Store UX |
| EXT-GAP-I-02 | 500+ logbook scroll latency | Performance external QA | Large logbook UX |
| EXT-GAP-I-03 | Snorkeling map long-route interaction | `QA_EVIDENCE/SNORKELING_IOS_MAPS/` | Snorkeling iOS |
| EXT-GAP-I-04 | VoiceOver full journey | `QA_EVIDENCE/DYNAMIC_TYPE_VOICEOVER/` | Accessibility |
| EXT-GAP-I-05 | PDF render/share manual pass | `QA_EVIDENCE/PDF_RENDER/` | Export UX |

---

## Paired-device gaps

| Gap ID | Description | Evidence folder | Blocking |
|--------|-------------|-----------------|----------|
| EXT-GAP-P-01 | Watch↔iPhone signed ACK under load | `QA_EVIDENCE/WATCH_IOS_SYNC/` | Sync trust |
| EXT-GAP-P-02 | Offline queue flush reconnect | `QA_EVIDENCE/WATCH_IOS_SYNC/` | Sync reliability |
| EXT-GAP-P-03 | iCloud two-device tombstones | `QA_EVIDENCE/ICLOUD_TWO_DEVICE/` | Cloud delete |
| EXT-GAP-P-04 | Apnea/Snorkeling activity sync matrices | `QA_EVIDENCE/APNEA_IOS_WATCH_SYNC/`, `SNORKELING_IOS_WATCH_SYNC/` | Multi-activity |
| EXT-GAP-P-05 | Low-battery paired sync | Performance external QA | Battery policy |

---

## External reference gaps

| Gap ID | Description | Evidence folder | Blocking |
|--------|-------------|-----------------|----------|
| EXT-GAP-E-01 | Bühlmann external golden validation | `QA_EVIDENCE/BUHLMANN_EXTERNAL/` | Algorithm marketing claim |
| EXT-GAP-E-02 | CCR external rebreather validation | `QA_EVIDENCE/CCR_EXTERNAL/` | CCR release |
| EXT-GAP-E-03 | Subsurface CSV external round-trip | `QA_EVIDENCE/SUBSURFACE_EXTERNAL/` | Import compatibility |
| EXT-GAP-E-04 | Ratio deco external reference | `QA_EVIDENCE/RATIO_DECO_EXTERNAL/` | Optional planner mode |

---

## App Store / compliance gaps

| Gap ID | Description | Evidence folder | Blocking |
|--------|-------------|-----------------|----------|
| EXT-GAP-A-01 | App Store screenshots and marketing copy | `QA_EVIDENCE/APP_STORE_MARKETING/` | Submission |
| EXT-GAP-A-02 | TestFlight sensor-source disclosure evidence | `WATCH_TESTFLIGHT_SENSOR_SOURCE_QA.md` | TestFlight |

---

## What software gates already cover (not gaps)

These domains have **automated/simulator PASS** on `817d1b1` and must not be reclassified as external gaps:

- Command 7 activity architecture / settings / logbook isolation
- Command 8 sync schema / signed ACK / tombstone codec
- Command 9 security / privacy / trust software readiness
- Command 10 performance / concurrency software readiness
- Command 11 localization catalog parity (physical a11y still gap)
- Watch Bühlmann/Full Computer simulator oracle tests (Audit 15, timing faults)
- Snorkeling/Apnea release-hard software validation suites

---

## Closure rule

A gap moves from **NOT PASSED** to **PASS** only when the corresponding `QA_EVIDENCE/<folder>/` contains:

1. Completed README template fields (tester, reviewer, device IDs, build/commit)
2. Required artifacts (screenshots, logs, videos per procedure)
3. Validator PASS for release mode where applicable (`validate_snorkeling_qa_evidence.py --release`, etc.)

**Do not** mark PASS from simulator test output alone.
