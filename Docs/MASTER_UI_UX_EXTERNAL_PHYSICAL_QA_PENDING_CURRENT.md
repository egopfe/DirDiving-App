# Master UI/UX External & Physical QA Pending — CURRENT

**Audit date:** 2026-07-01  
**Baseline:** `main` @ `2c30412`  
**Command:** `03-MASTER_UI_UX_FULL_DEEP_COMPREHENSIVE_AUDIT_COMMAND_V1.5.md`

---

## Summary

Software UI/UX gates pass at `2c30412` (0 P0 software UI). **No physical Apple Watch wet QA, paired-device manual runs, pixel-diff capture, or external validation was executed during this audit session.** iOS Algorithm Tests **1655/1655 PASS**; Watch tests **1139/1152 PASS** per Audit 01 session (13 non-FC failures).

| Category | Count | Status |
|----------|------:|--------|
| PENDING_PHYSICAL | 8 | OPEN |
| PENDING_PAIRED_DEVICE_QA | 1 | OPEN |
| PENDING_EXTERNAL_VALIDATION | 3 | OPEN |

---

## PENDING_PHYSICAL Gates

| ID | Area | Requirement | Template / Matrix | Finding |
|----|------|-------------|-------------------|---------|
| PHY-001 | Water auto-open | End-to-end wet routing + system listing | `Docs/QA_EVIDENCE/WATCH_WATER_AUTO_OPEN_*` | MUIUX-P1-001 |
| PHY-002 | Underwater hardware | Water Lock + Crown + Action Button | `WATCH_UNDERWATER_FAST_CONTROLS_*` | MUIUX-P1-002 |
| PHY-003 | Shallow depth | Wet shallow vs full-depth separation | `MASTER_SHALLOW_DEPTH_RELEASE_GATE_MATRIX` | MUIUX-P1-005 |
| PHY-004 | Full Computer | Ultra wet depth + CMAltimeter | `MASTER_WATCH_FULL_COMPUTER_PHYSICAL_QA_MATRIX` | WFC-P2-002 |
| PHY-005 | Snorkeling | 12 SNORKELING_* field procedures | `Docs/QA_EVIDENCE/SNORKELING_*` | MUIUX-P2-003 |
| PHY-006 | Visual regression | 59/59 pixel-diff baselines | `capture_visual_regression_baselines.sh` | MUIUX-P2-001 |
| PHY-007 | Accessibility | VoiceOver + Dynamic Type manual matrix | `ACCESSIBILITY_MANUAL_QA_TEMPLATE.md` | MUIUX-P1-003 |
| PHY-008 | Performance | Long-session FC battery/thermal | `PHYSICAL_PERFORMANCE_QA_PLAN_CURRENT.md` | CONS-023 |

---

## PENDING_PAIRED_DEVICE_QA

| ID | Area | Requirement | Finding |
|----|------|-------------|---------|
| PAIR-001 | Sync UI | Tombstone HMAC, briefing transfer, large payload | MUIUX-P1-004 |

---

## PENDING_EXTERNAL_VALIDATION

| ID | Area | Requirement | Finding |
|----|------|-------------|---------|
| EXT-001 | Bühlmann | Third-party decompression comparison | WFC-P1-001 / CONS-009 |
| EXT-002 | GF presets | External preset spot-check | CONS-043 |
| EXT-003 | Release legal | Counsel + marketing sign-off | CONS-044 |

---

## Software Evidence @ `2c30412`

- iOS Algorithm Tests: **1655/1655 PASS** (this session)
- Watch Algorithm Tests: **1139/1152 PASS** (Audit 01); FC tests all PASS
- `Scripts/audit_accessibility_contracts.sh` — PASS (prior)
- Router/page policy: `WatchUnderwaterActionRouterTests`, `WatchUnderwaterPagePolicyTests` — PASS
- WAO copy: `WatchWaterAutoOpenSettingsCopyTests` — PASS
- WAO routing: `WatchWaterAutoOpenPolicyTests` — **11 FAIL** (MUIUX-P2-005)
- Settings ownership: `IOSActivitySettingsModeSwitchTests`, `WatchActivitySettingsOwnershipTests` — PASS
- Logbook isolation: `IOSActivityLogbookDataIsolationTests` — PASS
- Apnea isolation: `ApneaArchitectureIsolationTests` — PASS

---

## Labels Required in UI Until Evidence Exists

```text
PENDING_PHYSICAL_WATER_LOCK_QA
PENDING_PHYSICAL_WATER_AUTO_OPEN_QA
PENDING_PHYSICAL_ACTION_BUTTON_QA
PENDING_WATCHOS_SYSTEM_AUTO_LAUNCH_LISTING_QA
PENDING_PHYSICAL
PENDING_PAIRED_DEVICE_QA
PENDING_EXTERNAL_VALIDATION
NOT_EXECUTED
```

Do not convert simulator/unit-test PASS into physical readiness claims.
