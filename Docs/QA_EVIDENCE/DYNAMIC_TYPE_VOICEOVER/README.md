# Dynamic Type / VoiceOver — Evidence Folder

**Status: PENDING** — Do not mark PASS without attached files.

**Matrix:** [`Docs/IOS_DYNAMIC_TYPE_VOICEOVER_QA_MATRIX.md`](../../IOS_DYNAMIC_TYPE_VOICEOVER_QA_MATRIX.md)  
**Related:** [`Docs/ACCESSIBILITY_QA_MATRIX.md`](../../ACCESSIBILITY_QA_MATRIX.md)

---

## Scope

Manual iOS accessibility verification: Dynamic Type scaling (including AX5 / Large) and VoiceOver labels/hints on Planner, CCR, checklist, logbook, onboarding, and share flows. Automated static tests do not substitute for this folder.

---

## Required device / simulator matrix

| Device class | iOS version | Dynamic Type | VoiceOver |
|--------------|-------------|--------------|-----------|
| iPhone SE (compact) | Current release target | AX1 + AX5 minimum | On |
| iPhone 17 / 6.7" (large) | Current release target | AX1 + AX5 minimum | On |

Locales: EN and IT where localized copy is under test.

---

## Required evidence files

Attach screenshots, screen recordings, or VoiceOver rotor logs:

- [ ] Planner Base / Deco / Technical / CCR tabs
- [ ] Gas editor; CCR setpoint / diluent / bailout UI
- [ ] Checklist sync sheets (OC + CCR export)
- [ ] Manual dive editor (CCR fields)
- [ ] PDF / share actions
- [ ] Logbook analytics
- [ ] Disclaimers / legal onboarding (non-certified posture readable)

Naming: `<screen>_<locale>_<dynamicType>_<date>.png` or `.mov`

---

## Sign-off

| Field | Value |
|-------|-------|
| Device model | |
| iOS version | |
| Build / commit SHA | |
| Dynamic Type settings tested | e.g. Default, AX5 |
| VoiceOver | on / off per scenario |
| Tester | |
| Date | |
| Pass/Fail | **PENDING** |

**Accessibility QA remains pending until evidence files are attached here.**
