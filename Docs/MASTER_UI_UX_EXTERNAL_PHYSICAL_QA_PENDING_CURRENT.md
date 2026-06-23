# Master UI/UX External and Physical QA Pending — Current

**Audit:** Command 03 — Master UI/UX Full Deep Comprehensive Audit V2.0  
**Date:** 2026-06-22  
**Branch:** `main`  
**Commit:** `1f62235`  
**Policy:** No physical, paired-device, underwater, external validation, or App Store approval is claimed unless signed evidence exists in `Docs/QA_EVIDENCE/`.

---

## Summary

Software/source UI/UX gates largely pass at commit `1f62235`. All external and physical release gates remain **PENDING**. This document lists every pending gate referenced by the master audit.

| Gate category | Status | Blocking release tier |
|---------------|--------|----------------------|
| Physical Apple Watch UI QA | **PENDING_PHYSICAL** | External TestFlight, App Store |
| Physical iPhone UI QA | **PENDING_PHYSICAL** | External TestFlight, App Store |
| Paired Watch↔iOS sync UI QA | **PENDING_PAIRED_DEVICE_QA** | External TestFlight |
| Accessibility manual QA (VoiceOver, Dynamic Type) | **PENDING_PHYSICAL** | External TestFlight |
| Physical pixel-diff / visual fidelity | **NOT_EXECUTED** | External TestFlight |
| PDF render on device | **NOT_EXECUTED** | External TestFlight |
| Underwater / wet / glove interaction | **NOT_EXECUTED** | App Store |
| External Bühlmann / CCR / Subsurface validation | **PENDING_EXTERNAL_VALIDATION** | App Store marketing claims |
| Legal counsel / App Store marketing sign-off | **PENDING_EXTERNAL_VALIDATION** | App Store |

---

## Physical Apple Watch UI QA — PENDING

**Finding:** MUIUX-P1-001  
**Evidence folders (scaffolding only):**

| Folder | Scenarios |
|--------|-----------|
| `Docs/QA_EVIDENCE/WATCH_ULTRA/` | Full Computer live/deco, multi-banner density, smallest Watch 41 mm |
| `Docs/QA_EVIDENCE/APNEA_WATCH_ULTRA/` | Apnea wet session, recovery, alarms |
| `Docs/QA_EVIDENCE/SNORKELING_WATCH_LAYOUTS/` | Snorkeling GPS, waypoints, return-to-entry, 41 mm clipping |
| `Docs/QA_EVIDENCE/HARDWARE_ENTITLEMENT/` | Depth entitlement, Water Lock, underwater depth |

**Required before external TestFlight:** signed screenshots, screen recordings, or checklists per `EVIDENCE_TEMPLATE.md` for Gauge live, Full Computer deco states, Apnea live, Snorkeling navigation, reminders overlay vs safety data, Mission Mode, haptics-off badge, image paging/delete.

---

## Physical iPhone UI QA — PENDING

**Finding:** MUIUX-P1-001, MUIUX-P1-004  
**Evidence folders:**

| Folder | Scenarios |
|--------|-----------|
| `Docs/QA_EVIDENCE/IOS_ACCESSIBILITY/` | Dynamic Type XL, VoiceOver on Planner/CCR/gas ledger/checklist |
| `Docs/QA_EVIDENCE/PDF_RENDER/` | Planner PDF, checklist PDF, dive pack, briefing card PNG |
| `Docs/QA_EVIDENCE/IOS_PLANNER/` | Planner modes, runtime table, emergency/Rock Bottom layout |

**Required:** device captures for Settings mode switch, Apnea/Snorkeling gear sheets, dashboard cards, route planner map, manual dive editor, export/share sheets.

---

## Paired Watch↔iOS Sync UI QA — PENDING

**Finding:** MUIUX-P1-002  
**Evidence folders:**

| Folder | Scenarios |
|--------|-----------|
| `Docs/QA_EVIDENCE/WATCH_IOS_SYNC/` | Briefing card transfer, image inventory/delete ACK, sync conflict UI, activity namespace isolation |
| `Docs/QA_EVIDENCE/ICLOUD_TWO_DEVICE/` | Diving iCloud backup/restore UI truthfulness |

**Required:** paired-device journeys for briefing card pending→transferred→stale, image delete ACK before iOS success, conflict resolution UI, altitude plan import→predive→live continuity.

---

## Accessibility Manual QA — PENDING

**Finding:** MUIUX-P1-003  
Software semantic contracts exist (`SnorkelingAccessibilityContractTests`, planner/chart summaries, Watch live safety overlays). Physical VoiceOver traversal, Dynamic Type at largest sizes, and reduced-motion behavior on real devices are **NOT_EXECUTED**.

---

## Visual Regression / Pixel QA — NOT_EXECUTED

**Findings:** MUIUX-P2-001, MUIUX-P2-002  
Software registry: 59/59 mockups indexed; 59/59 executable fixtures; 20/59 iOS raster snapshot contracts; 0/59 physical pixel-diff baselines captured.

---

## External Validation — PENDING

| Domain | Folder | Status |
|--------|--------|--------|
| Bühlmann external | `Docs/QA_EVIDENCE/BUHLMANN_EXTERNAL/` | PENDING_EXTERNAL_VALIDATION |
| CCR external | `Docs/QA_EVIDENCE/CCR_EXTERNAL/` | PENDING_EXTERNAL_VALIDATION |
| Subsurface CSV | `Docs/QA_EVIDENCE/SUBSURFACE/` | NOT_EXECUTED |
| Legal review | `Docs/QA_EVIDENCE/LEGAL_REVIEW/` | PENDING_EXTERNAL_VALIDATION |
| App Store marketing | `Docs/QA_EVIDENCE/APP_STORE_MARKETING/` | PENDING_EXTERNAL_VALIDATION |

---

## Build/Test Evidence @ Audit Time

| Step | Result |
|------|--------|
| `git branch` | `main` @ `1f62235` |
| `git status` | Clean vs `origin/main` (0/0) |
| `xcodegen generate` | **OK** |
| Concurrent `xcodebuild` iOS + Watch | **FAILED** — DerivedData DB locked |
| Isolated DerivedData build (audit pass) | **INCONCLUSIVE** — long-running at report time (MUIUX-P1-005) |
| Algorithm test schemes | **NOT_EXECUTED** in this audit pass |

Prior macOS evidence on earlier commits does not substitute for `1f62235` sign-off.

---

## Acceptance Criteria to Close Pending Gates

1. Populate each `Docs/QA_EVIDENCE/*` folder with signed artifacts per template.
2. Re-run `./Scripts/validate_ui_ux_readiness.sh` and full algorithm schemes on macOS @ HEAD.
3. Execute manual visual-fidelity scoring for all 59 mockups on smallest Watch + representative iPhone.
4. Record paired-device briefing-card and image-delete round-trips with UI screenshots.
5. Obtain legal/marketing sign-off before any App Store readiness claim.

No production code was modified by this audit.
