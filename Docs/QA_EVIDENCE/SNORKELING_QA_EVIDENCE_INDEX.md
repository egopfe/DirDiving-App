# Snorkeling QA Evidence Index

**Catalog:** `Utils/SnorkelingQAEvidenceCatalog.swift` (21 entries)  
**Validator:** `Scripts/validate_snorkeling_qa_evidence.py`  
**Default status:** **PENDING** (do not fabricate PASS)

## Command category mapping

| Command category | Evidence folder(s) | QA ID |
|------------------|-------------------|-------|
| SNORKELING_IOS_WATCH_SYNC | `SNORKELING_IOS_WATCH_SYNC`, `SNORKELING_KEYCHAIN` | SNK-QA-001, SNK-QA-021 |
| SNORKELING_ROUTE_PUSH | `SNORKELING_ROUTE_PUSH` | SNK-QA-002 |
| SNORKELING_SESSION_PULL | `SNORKELING_SESSION_PULL` | SNK-QA-003 |
| SNORKELING_WATER_LOCK | `SNORKELING_WATER_LOCK`, `SNORKELING_WET_GLOVE` | SNK-QA-004, SNK-QA-020 |
| SNORKELING_WATCH_UI | `SNORKELING_WATCH_UI`, `SNORKELING_HAPTICS` | SNK-QA-005, SNK-QA-019 |
| SNORKELING_IOS_MAPS | `SNORKELING_IOS_MAPS` | SNK-QA-006 |
| SNORKELING_SAFETY_REVIEW | `SNORKELING_SAFETY_REVIEW` | SNK-QA-007 |
| SNORKELING_VOICEOVER | `SNORKELING_VOICEOVER` (+ `PROCEDURE.md`) | SNK-QA-008 |
| SNORKELING_BATTERY / THERMAL | `SNORKELING_BATTERY_THERMAL` (+ `PROCEDURE.md`) | SNK-QA-009 |
| SNORKELING_GPS_ACCURACY | `SNORKELING_GPS` | SNK-QA-010 |
| SNORKELING_RETURN_TO_ENTRY | Covered in `SNORKELING_WATCH_UI` matrix | SNK-QA-005 |
| SNORKELING_MARKERS | Covered in `SNORKELING_WATCH_UI` / `SNORKELING_HAPTICS` | SNK-QA-005, SNK-QA-019 |
| SNORKELING_DIP_DETECTION | Covered in `SNORKELING_WATCH_UI` | SNK-QA-005 |
| SNORKELING_RECOVERY_RELAUNCH | `SNORKELING_RECOVERY`, `SNORKELING_RELAUNCH` | SNK-QA-011, SNK-QA-012 |
| SNORKELING_OFFLINE | `SNORKELING_OFFLINE_ONLINE`, `SNORKELING_AIRPLANE_MODE` | SNK-QA-013, SNK-QA-014 |
| SNORKELING_PRIVACY_REDACTION | `SNORKELING_PHOTO_PRIVACY` | SNK-QA-015 |
| SNORKELING_EXPORT | `SNORKELING_EXPORT` | SNK-QA-016 |
| SNORKELING_SMALL_WATCH_LAYOUT / ULTRA | `SNORKELING_WATCH_LAYOUTS` | SNK-QA-017 |
| SNORKELING_PAIRED_DEVICE_MATRIX | `SNORKELING_PAIR_UNPAIR` | SNK-QA-018 |

## Validation modes

| Mode | Command | Expectation |
|------|---------|-------------|
| Internal | `python3 Scripts/validate_snorkeling_qa_evidence.py --internal` | All folders present; templates complete; **PENDING** |
| Release | `python3 Scripts/validate_snorkeling_qa_evidence.py --release` | Every folder **PASS** with tester, reviewer, devices, artifacts |

Integrated in `Scripts/validate_snorkeling_release_readiness.sh`.
