# Master UI/UX External & Physical QA Pending — Current

**Audit:** `03-MASTER_UI_UX_FULL_DEEP_COMPREHENSIVE_AUDIT_COMMAND_V2.1.md`  
**Date:** 2026-06-27  
**Commit:** `83f884e` on `main`

No physical, paired-device, external validation, or App Store review evidence was executed during this audit. All items below remain **PENDING** unless a folder contains completed evidence.

---

## Physical Apple Watch UI/UX

| ID | Area | Evidence path | Status |
|----|------|---------------|--------|
| PHY-WATCH-001 | Water Lock + Crown paging | `Docs/QA_EVIDENCE/WATCH_UNDERWATER_FAST_CONTROLS_WATER_LOCK/` | PENDING_PHYSICAL |
| PHY-WATCH-002 | Action Button primary action | `Docs/QA_EVIDENCE/WATCH_UNDERWATER_FAST_CONTROLS_ACTION_BUTTON/` | PENDING_PHYSICAL |
| PHY-WATCH-003 | Underwater navigation blocks | `Docs/QA_EVIDENCE/WATCH_UNDERWATER_FAST_CONTROLS_NAVIGATION/` | PENDING_PHYSICAL |
| PHY-WATCH-004 | Stopwatch via Action Button | `Docs/QA_EVIDENCE/WATCH_UNDERWATER_FAST_CONTROLS_STOPWATCH/` | PENDING_PHYSICAL |
| PHY-WATCH-005 | Compass bearing via Action Button | `Docs/QA_EVIDENCE/WATCH_UNDERWATER_FAST_CONTROLS_COMPASS/` | PENDING_PHYSICAL |
| PHY-WATCH-006 | User Images via Action Button | `Docs/QA_EVIDENCE/WATCH_UNDERWATER_FAST_CONTROLS_IMAGES/` | PENDING_PHYSICAL |
| PHY-WATCH-007 | Settings limits underwater | `Docs/QA_EVIDENCE/WATCH_UNDERWATER_FAST_CONTROLS_SETTINGS_LIMITS/` | PENDING_PHYSICAL |
| PHY-WATCH-008 | Water auto-open preferred | `Docs/QA_EVIDENCE/WATCH_WATER_AUTO_OPEN_PREFERRED/` | PENDING_PHYSICAL |
| PHY-WATCH-009 | Water auto-open last selected | `Docs/QA_EVIDENCE/WATCH_WATER_AUTO_OPEN_LAST_SELECTED/` | PENDING_PHYSICAL |
| PHY-WATCH-010 | System Auto-Launch listing | `Docs/QA_EVIDENCE/WATCH_WATER_AUTO_OPEN_SYSTEM_LISTING/` | PENDING_PHYSICAL |
| PHY-WATCH-011 | FC predive on water auto-open | `Docs/QA_EVIDENCE/WATCH_WATER_AUTO_OPEN_FULL_COMPUTER_CONFIRMATION/` | PENDING_PHYSICAL |
| PHY-WATCH-012 | Active session block water auto-open | `Docs/QA_EVIDENCE/WATCH_WATER_AUTO_OPEN_ACTIVE_SESSION_BLOCK/` | PENDING_PHYSICAL |
| PHY-WATCH-013 | Smallest Watch layout (41 mm) | `Docs/QA_EVIDENCE/WATCH_ULTRA/` + layout contracts | PENDING_PHYSICAL |
| PHY-WATCH-014 | Mockup pixel baselines | `Docs/QA_EVIDENCE/WATCH_MOCKUP_PIXEL_BASELINES/` | PENDING_PHYSICAL |
| PHY-WATCH-015 | CMAltimeter physical | `Docs/QA_EVIDENCE/WATCH_CMALTIMETER_PHYSICAL/` | PENDING_PHYSICAL |

---

## Physical iPhone UI/UX

| ID | Area | Status |
|----|------|--------|
| PHY-IOS-001 | VoiceOver manual pass (Planner, CCR, Logbook) | PENDING_PHYSICAL |
| PHY-IOS-002 | Dynamic Type XL Planner layout | PENDING_PHYSICAL |
| PHY-IOS-003 | PDF render fidelity (Planner, Checklist, Dive Pack) | PENDING_PHYSICAL |
| PHY-IOS-004 | Manual visual fidelity scoring (59 mockups) | PENDING_PHYSICAL |

---

## Paired Watch ↔ iOS

| ID | Area | Evidence path | Status |
|----|------|---------------|--------|
| PHY-PAIR-001 | Watch ↔ iOS sync UI | `Docs/QA_EVIDENCE/WATCH_IOS_SYNC/` | PENDING_PAIRED_DEVICE_QA |
| PHY-PAIR-002 | Briefing card transfer states | QA templates | PENDING_PAIRED_DEVICE_QA |
| PHY-PAIR-003 | Image transfer/delete ACK | QA templates | PENDING_PAIRED_DEVICE_QA |
| PHY-PAIR-004 | Conflict resolution UI | QA templates | PENDING_PAIRED_DEVICE_QA |

---

## External validation

| ID | Area | Status |
|----|------|--------|
| EXT-001 | External Bühlmann / decompression validation | PENDING_EXTERNAL_VALIDATION |
| EXT-002 | Subsurface export validation | PENDING_EXTERNAL_VALIDATION |
| EXT-003 | CCR planning external review | PENDING_EXTERNAL_VALIDATION |
| EXT-004 | App Store review / legal asset approval | PENDING_EXTERNAL_VALIDATION |

---

## Accessibility manual QA

| ID | Area | Status |
|----|------|--------|
| A11Y-001 | Watch VoiceOver underwater flows | PENDING_PHYSICAL |
| A11Y-002 | iOS chart VoiceOver summaries | PENDING_PHYSICAL |
| A11Y-003 | Settings mode switch VoiceOver | NOT_EXECUTED (software labels present) |

---

## Build / test environment notes @ audit

| Check | Result |
|-------|--------|
| `xcodegen generate` | PASS |
| Watch App build | PASS |
| iOS App build | PASS |
| Watch Algorithm Tests (named simulator) | NOT_EXECUTED — simulator device name unavailable |
| Physical Watch available | Detected (`Apple Watch di Federico`) — not used in this read-only audit |

---

## Release impact

Internal TestFlight UI/UX may proceed **conditionally** on software gates. External TestFlight and App Store UI/UX readiness require closing P1 truthfulness gaps (water auto-open wiring/copy) and executing physical QA matrices above.
