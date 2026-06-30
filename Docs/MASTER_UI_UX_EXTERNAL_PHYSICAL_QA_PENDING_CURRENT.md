# Master UI/UX External & Physical QA Pending — Current

**Audit date:** 2026-06-30  
**Baseline:** `main` @ `451f8fb`  
**Related command:** `03-MASTER_UI_UX_FULL_DEEP_COMPREHENSIVE_AUDIT_COMMAND_V2.3.md`

---

## Summary

Software UI/UX gates pass at `451f8fb`. **No physical Apple Watch, paired-device, manual accessibility, pixel-diff, PDF render, or external validation evidence was executed during this audit session.** All items below remain open until signed artifacts exist under `Docs/QA_EVIDENCE/`.

| Category | Count | Status |
|----------|------:|--------|
| PENDING_PHYSICAL | 8 | OPEN |
| PENDING_PAIRED_DEVICE_QA | 1 | OPEN |
| PENDING_EXTERNAL_VALIDATION | 3 | OPEN |
| NOT_EXECUTED (this session) | 1 | Watch xcodebuild test bootstrap |

---

## PENDING_PHYSICAL Gates

| ID | Area | Requirement | Template / Matrix | Finding |
|----|------|-------------|-------------------|---------|
| PHY-001 | Water auto-open | End-to-end wet routing + system listing | `Docs/QA_EVIDENCE/WATCH_WATER_AUTO_OPEN_*` | MUIUX-P1-001 |
| PHY-002 | Underwater hardware | Water Lock + Crown + Action Button | `WATCH_UNDERWATER_FAST_CONTROLS_*` | MUIUX-P1-002 |
| PHY-003 | Shallow depth | Wet shallow vs full-depth separation | `MASTER_SHALLOW_DEPTH_RELEASE_GATE_MATRIX` | MUIUX-P1-005 |
| PHY-004 | Full Computer | Ultra wet depth + CMAltimeter | `MASTER_WATCH_FULL_COMPUTER_PHYSICAL_QA_MATRIX` | CONS-010 |
| PHY-005 | Snorkeling | 12 SNORKELING_* field procedures | `Docs/QA_EVIDENCE/SNORKELING_*` | MUIUX-P2-003 |
| PHY-006 | Visual regression | 59/59 pixel-diff baselines | `capture_visual_regression_baselines.sh` | MUIUX-P2-001 |
| PHY-007 | Accessibility | VoiceOver + Dynamic Type manual matrix | `ACCESSIBILITY_MANUAL_QA_TEMPLATE.md` | MUIUX-P1-003 |
| PHY-008 | Performance | Long-session FC battery/thermal | `PHYSICAL_PERFORMANCE_QA_PLAN_CURRENT.md` | CONS-023 |

---

## PENDING_PAIRED_DEVICE_QA

| ID | Area | Requirement | Finding |
|----|------|-------------|---------|
| PAIR-001 | Sync UI | Tombstone HMAC, briefing transfer, large payload | MUIUX-P1-004 / CONS-011 |

---

## PENDING_EXTERNAL_VALIDATION

| ID | Area | Requirement | Finding |
|----|------|-------------|---------|
| EXT-001 | Bühlmann | Third-party decompression comparison | CONS-009 |
| EXT-002 | GF presets | External preset spot-check | CONS-043 |
| EXT-003 | Release legal | Counsel + marketing sign-off | CONS-044 |

---

## What Software Evidence DOES Exist (@ `451f8fb`)

- `Scripts/audit_accessibility_contracts.sh` — PASS
- Unit tests: `WatchUnderwaterPagePolicyTests`, `WatchUnderwaterNavigationClampPolicyTests`, `WatchUnderwaterActionRouterTests`, `WatchWaterAutoOpenPolicyTests`, `WatchWaterAutoOpenSettingsCopyTests`
- Settings ownership: `WatchActivitySettingsOwnershipTests`, `IOSActivitySettingsModeSwitchTests`
- Logbook isolation: `IOSActivityLogbookDataIsolationTests`, `WatchActivityLogbookRoutingTests`
- Mockup structural mapping: 59 PNG paths validated; `MockupAntiEmbeddingTests`, `IOSMockupRasterSnapshotTests` (structural)

---

## Do Not Claim Without Evidence

- Physical Apple Watch / Water Lock / Action Button QA passed
- System submerged auto-launch listing verified on watchOS
- Shallow-depth testing equals production full-depth decompression guidance
- App Store / EN13319 / ISO 6425 / certified dive-computer status
- Paired sync UI verified on two devices
- Pixel-diff visual regression baselines captured

---

## Final Status

```text
PHYSICAL_WATCH_UI_QA: PENDING_PHYSICAL
PHYSICAL_IOS_UI_QA: PENDING_PHYSICAL
PAIRED_WATCH_IOS_UI_QA: PENDING_PHYSICAL
ACCESSIBILITY_MANUAL_QA: PENDING_PHYSICAL
APP_STORE_REVIEW_READINESS: PENDING_EXTERNAL_VALIDATION
UI_UX_PHYSICAL_QA_STATUS: PENDING_PHYSICAL
```
