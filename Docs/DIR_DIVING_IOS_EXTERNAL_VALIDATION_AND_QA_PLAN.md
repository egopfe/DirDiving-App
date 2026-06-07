# DIR DIVING iOS — External Validation and QA Plan

**Scope:** Companion MAIN (`DIRDiving iOS`)  
**Honesty policy:** Items below are **required evidence** — not marked complete until executed.

---

## External Bühlmann validation

| ID | Activity | Pass criteria | Status |
|---|---|---|---|
| EV-001 | Run decotengu (or chosen tool) on air-30m, trimix-ean50 fixtures | Documented diff within fixture tolerance | **Pending** |
| EV-002 | Capture reference TTS/stop tables in fixture metadata | `validationStatus` updated with source + version | **Pending** |
| EV-003 | Sign-off review | No certified equivalence claim in product copy | **Pending** |

---

## Simulator QA

| ID | Activity | Pass criteria | Status |
|---|---|---|---|
| SIM-001 | Planner Base/Deco/Technical result screenshots EN | Matches mode gating docs | **Pending** |
| SIM-002 | CURVA tissue chart + NDL secondary (Technical) | Primary = tissue history | **Pending** |
| SIM-003 | PIANO briefing order footnote visible | EN/IT | **Pending** |

---

## Accessibility QA

| ID | Activity | Pass criteria | Status |
|---|---|---|---|
| A11Y-001 | Dynamic Type largest on Planner result | No clipped CNS/OTU tiles | **Pending** |
| A11Y-002 | VoiceOver on CNS/OTU warnings | Labels + hints spoken | **Pending** |

---

## Paired-device sync QA

| ID | Activity | Pass criteria | Status |
|---|---|---|---|
| SYNC-001 | Watch record → iOS import | Depth profile ±ε | **Pending** |
| SYNC-002 | iOS manual dive tombstone | No resurrection | **Pending** |
| SYNC-003 | Cloud KVS merge divergent profile | Documented whole-profile winner | **Pending** |

---

## CSV regression

| ID | Activity | Pass criteria | Status |
|---|---|---|---|
| CSV-001 | Subsurface third-party sample import | Bounded errors, no corrupt session | **Pending** |
| CSV-002 | DIR export round-trip | Metadata preserved | **Automated** (XCTest) |

---

*See also:* [`DIR_DIVING_IOS_TESTFLIGHT_READINESS_CHECKLIST.md`](DIR_DIVING_IOS_TESTFLIGHT_READINESS_CHECKLIST.md)
