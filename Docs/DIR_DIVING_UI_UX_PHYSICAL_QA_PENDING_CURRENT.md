# DIR DIVING — Physical / Manual UI/UX QA (Pending)

**Date:** 2026-06-19  
**Software gate:** PASS (`./Scripts/validate_ui_ux_readiness.sh`)  
**Physical gate:** **PENDING**

---

## Explicitly pending (do not mark PASS without evidence)

| Gate | Scope | Status |
|------|-------|--------|
| Physical-device layout QA | Smallest/largest iPhone, smallest Watch, Ultra class | **PENDING** |
| Manual VoiceOver walkthrough | Activity selection, roots, last-session cards, Watch Settings | **PENDING** |
| Physical Watch interaction QA | Crown, haptics, underwater-adjacent scenarios | **PENDING** |
| Real-device pixel comparison | Mockup raster diff on hardware | **PENDING** |
| Underwater / field testing | All activities | **PENDING** |
| External UI sign-off | Design/product stakeholder review | **PENDING_PHYSICAL_QA** |

---

## Software-verifiable substitutes (automated)

| Area | Evidence |
|------|----------|
| Root flow + activity selection | `IOSCompanionActivitySelectionTests`, `IOSUIUXRemediationTests` |
| Post-selection landing | `IOSUIUXRemediationTests` |
| Last-session navigation | `IOSUIUXRemediationTests` |
| Logbook ownership | `IOSUIUXRemediationTests`, existing isolation suites |
| Watch Settings ownership | `WatchActivitySettingsOwnershipTests` |
| Mockup path integrity | `validate_mockup_paths.py` |
| Localization parity | `audit_localization.sh` |
| Accessibility contracts | UI contract tests (simulator) |

---

## Recommended manual checklist (when hardware available)

1. Select each activity from Companion; confirm landing tab matches intent.
2. Tap Apnea/Snorkeling last-session cards; confirm detail opens in-activity.
3. Switch Watch activity; confirm Settings shows only relevant sections.
4. Snorkeling: open Route Planner from tab only (no duplicate sheet).
5. VoiceOver: activity cards, tab bar, last-session hints.
6. Dynamic Type (AX5): activity selection titles do not clip.
7. Capture reference PNGs per `Docs/ReferenceUI/README.md` if external sign-off required.

---

**EXTERNAL_UI_SIGN_OFF:** CONDITIONAL_ON_PHYSICAL_QA
