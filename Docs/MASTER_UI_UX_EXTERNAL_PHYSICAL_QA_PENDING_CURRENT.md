# Master UI/UX External & Physical QA Pending — Current

**Audit:** `03-MASTER_UI_UX_FULL_DEEP_COMPREHENSIVE_AUDIT_COMMAND_V2.1.md`  
**Date:** 2026-06-28  
**Commit:** `7dfefe2` on `main`

Software UI/UX gates pass at `7dfefe2`. No physical, paired-device, external validation, or App Store review evidence was executed during this audit rerun. All items below remain **PENDING** unless a folder contains completed evidence.

---

## SOFTWARE_READY (no physical execution required)

| Area | Status |
|------|--------|
| Water auto-open policy, Settings, routing logic | SOFTWARE_READY |
| Crown underwater page clamp + toast | SOFTWARE_READY |
| Action Button / App Intents router + legacy intent safety | SOFTWARE_READY |
| Cold-launch modal sequencing | SOFTWARE_READY |
| Shallow depth capability UI + developer toggles | SOFTWARE_READY |
| GF preset selection UI + lock states | SOFTWARE_READY |
| iOS Settings mode switch + activity ownership | SOFTWARE_READY |
| Mockup path validity (59/59) | SOFTWARE_READY |
| Accessibility contract scripts | SOFTWARE_READY |

---

## Physical Apple Watch UI/UX

| ID | Area | Evidence path | Status |
|----|------|---------------|--------|
| PHY-WATCH-001 | Water Lock + Crown paging | `Docs/QA_EVIDENCE/WATCH_UNDERWATER_FAST_CONTROLS_WATER_LOCK/` | PENDING_PHYSICAL |
| PHY-WATCH-002 | Action Button Ultra | `Docs/QA_EVIDENCE/WATCH_UNDERWATER_FAST_CONTROLS_ACTION_BUTTON/` | PENDING_PHYSICAL |
| PHY-WATCH-003 | Crown navigation underwater | `Docs/QA_EVIDENCE/WATCH_UNDERWATER_FAST_CONTROLS_NAVIGATION/` | PENDING_PHYSICAL |
| PHY-WATCH-004 | Water auto-open preferred mode | `Docs/QA_EVIDENCE/WATCH_WATER_AUTO_OPEN_PREFERRED/` | PENDING_PHYSICAL |
| PHY-WATCH-005 | System Auto-Launch listing | `Docs/QA_EVIDENCE/WATCH_WATER_AUTO_OPEN_SYSTEM_LISTING/` | PENDING_PHYSICAL |
| PHY-WATCH-006 | Active session water-auto-open block | `Docs/QA_EVIDENCE/WATCH_WATER_AUTO_OPEN_ACTIVE_SESSION_BLOCK/` | PENDING_PHYSICAL |
| PHY-WATCH-007 | Apnea underwater session UI | `Docs/QA_EVIDENCE/WATCH_UNDERWATER_APNEA/` | PENDING_PHYSICAL |
| PHY-WATCH-008 | Snorkeling GPS/dip UI | `Docs/QA_EVIDENCE/WATCH_SNORKELING_GPS/` | PENDING_PHYSICAL |
| PHY-WATCH-009 | 41 mm smallest layout | `Docs/QA_EVIDENCE/PHYSICAL_41MM_WATCH_VISUAL_QA_TEMPLATE.md` | PENDING_PHYSICAL |
| PHY-WATCH-010 | Full Computer deco UI physical | `Docs/QA_EVIDENCE/WATCH_FULL_COMPUTER_PHYSICAL/` | PENDING_PHYSICAL |

---

## Physical iPhone UI/UX

| ID | Area | Evidence path | Status |
|----|------|---------------|--------|
| PHY-IOS-001 | PDF Planner render | `Docs/QA_EVIDENCE/PDF_PHYSICAL_RENDER_QA_TEMPLATE.md` | PENDING_PHYSICAL |
| PHY-IOS-002 | PDF Checklist render | `Docs/QA_EVIDENCE/PDF_PHYSICAL_RENDER_QA_TEMPLATE.md` | PENDING_PHYSICAL |

---

## Paired Watch ↔ iOS

| ID | Area | Evidence path | Status |
|----|------|---------------|--------|
| PAIR-001 | Sync/conflict UI | `Docs/QA_EVIDENCE/PAIRED_WATCH_IOS_UI_QA_TEMPLATE.md` | PENDING_PAIRED_DEVICE_QA |
| PAIR-002 | Briefing card transfer UI | `Docs/QA_EVIDENCE/WATCH_BRIEFING_CARD_TRANSFER/` | PENDING_PAIRED_DEVICE_QA |
| PAIR-003 | Image transfer/delete ACK UI | `Docs/QA_EVIDENCE/WATCH_IMAGE_TRANSFER/` | PENDING_PAIRED_DEVICE_QA |

---

## Manual accessibility

| ID | Area | Evidence path | Status |
|----|------|---------------|--------|
| A11Y-001 | VoiceOver critical flows | `Docs/QA_EVIDENCE/ACCESSIBILITY_MANUAL_QA_TEMPLATE.md` | PENDING_PHYSICAL |

---

## Visual regression (pixel execution)

| ID | Area | Evidence path | Status |
|----|------|---------------|--------|
| MVR-001 | Pixel diff 59 mockups | `Docs/QA_EVIDENCE/PHYSICAL_PIXEL_DIFF/` | PENDING_MANUAL |
| MVR-002 | Manual fidelity scoring | `Docs/QA_EVIDENCE/MANUAL_VISUAL_FIDELITY/` | PENDING_MANUAL |

---

## External validation

| ID | Area | Status |
|----|------|--------|
| EXT-001 | Watch Full Computer Bühlmann | PENDING_EXTERNAL_VALIDATION |
| EXT-002 | iOS Planner CCR reference | PENDING_EXTERNAL_VALIDATION |
| EXT-003 | App Store review / legal assets | PENDING_EXTERNAL_VALIDATION |

---

## Claim restrictions (must not claim until evidence exists)

- Physical Apple Watch / Water Lock / Action Button QA  
- Paired-device QA  
- Underwater QA with real hardware  
- System submerged Auto-Launch listing without provisioning + physical evidence  
- External decompression / Bühlmann validation  
- App Store approval readiness  
- Pixel-perfect mockup fidelity (0/59 scored on device)
