# Master UI/UX External & Physical QA Pending — Current

**Audit:** `03-MASTER_UI_UX_FULL_DEEP_COMPREHENSIVE_AUDIT_COMMAND_V2.2.md`  
**Date:** 2026-06-29  
**Commit:** `15c8068` on `main`

Software UI/UX gates pass at `15c8068`. Consolidated remediation (CONS-019, CONS-006/007, CONS-002) verified at software layer. No physical, paired-device, external validation, or App Store review evidence was executed during this audit rerun. All items below remain **PENDING** unless a folder contains completed evidence.

---

## SOFTWARE_READY (no physical execution required)

| Area | Status |
|------|--------|
| Water auto-open policy, Settings, routing logic + **depth gate (CONS-019)** | SOFTWARE_READY |
| Crown underwater page clamp + toast | SOFTWARE_READY |
| Action Button / App Intents router + legacy intent safety | SOFTWARE_READY |
| Cold-launch modal sequencing | SOFTWARE_READY |
| Shallow depth capability UI + developer toggles (**default OFF**, CONS-006) | SOFTWARE_READY |
| Depth entitlement compile authority (CONS-007) | SOFTWARE_READY |
| GF preset selection UI + iOS import parity (CONS-002) | SOFTWARE_READY |
| iOS Settings mode switch + activity ownership | SOFTWARE_READY |
| Mockup path validity (59/59) | SOFTWARE_READY |
| Accessibility contract scripts | SOFTWARE_READY (`audit_accessibility_contracts.sh` PASS) |

---

## Script results (@ `15c8068`)

| Script | Result | Notes |
|--------|--------|-------|
| `audit_accessibility_contracts.sh` | **PASS** | Watch underwater + water auto-open keys EN/IT |
| `capture_visual_regression_baselines.sh` | **PENDING_MANUAL_EXECUTION** | Scaffold at `Docs/QA_EVIDENCE/PHYSICAL_PIXEL_DIFF/captures`; 0/59 baselines captured |
| `validate_commands_for_cursor_integrity.sh` | **PASS** | Launch order 01–06 aligned |

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
| PHY-WATCH-011 | WAO depth gate on shallow hardware | `Docs/QA_EVIDENCE/WATCH_WATER_AUTO_OPEN_PREFERRED/` | PENDING_PHYSICAL — software CONS-019 PASS |

---

## Physical iPhone UI/UX

| ID | Area | Evidence path | Status |
|----|------|---------------|--------|
| PHY-IOS-001 | PDF Planner render | `Docs/QA_EVIDENCE/PDF_PHYSICAL_RENDER_QA_TEMPLATE.md` | PENDING_PHYSICAL |
| PHY-IOS-002 | PDF Checklist render | `Docs/QA_EVIDENCE/PDF_PHYSICAL_RENDER_QA_TEMPLATE.md` | PENDING_PHYSICAL |

---

## Paired-device QA

| ID | Area | Status |
|----|------|--------|
| PHY-PAIR-001 | Watch↔iOS sync UI flows | PENDING_PAIRED_DEVICE_QA |
| PHY-PAIR-002 | Briefing card transfer UI | PENDING_PAIRED_DEVICE_QA |
| PHY-PAIR-003 | Image delete ACK UI | PENDING_PAIRED_DEVICE_QA |

---

## Manual accessibility

| ID | Area | Status |
|----|------|--------|
| PHY-A11Y-001 | VoiceOver critical flows | PENDING_PHYSICAL |
| PHY-A11Y-002 | Dynamic Type largest sizes | PENDING_PHYSICAL |

---

## External validation

| ID | Area | Status |
|----|------|--------|
| EXT-001 | Bühlmann external validation | PENDING_EXTERNAL_VALIDATION |
| EXT-002 | GF preset spot-check (CONS-043) | PENDING_EXTERNAL_VALIDATION |
| EXT-003 | CCR reference-only review | PENDING_EXTERNAL_VALIDATION |
| EXT-004 | App Store legal/marketing review | PENDING_EXTERNAL_VALIDATION |

---

## Do not claim without evidence

- Physical Apple Watch / iPhone QA
- Paired-device QA
- Underwater / Water Lock QA
- watchOS system submerged Auto-Launch listing
- External decompression validation
- App Store approval readiness
- Pixel-perfect mockup fidelity (0/59 captured)

**Post-remediation audit @ `15c8068` — Docs only; no production changes.**
