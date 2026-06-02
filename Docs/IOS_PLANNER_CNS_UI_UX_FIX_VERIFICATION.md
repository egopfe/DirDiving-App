# iOS Planner CNS UI/UX Fix Verification

**Date:** 2026-06-02  
**Branch:** `main` (uncommitted at report generation)  
**Source audit:** [`IOS_PLANNER_CNS_UI_UX_AUDIT_CURRENT.md`](IOS_PLANNER_CNS_UI_UX_AUDIT_CURRENT.md)

---

## Files modified

| File | Change |
|------|--------|
| `iOSApp/Views/PlannerView.swift` | Preview CNS label/footnote; result CNS labels, footnotes, 15% warning+hint, ascent/deco row, accessibility |
| `iOSApp/Views/MoreView.swift` | Settings description copy key |
| `iOSApp/Models/GasPlan.swift` | `cnsAscentDecoEstimatePercent` presentation property |
| `iOSApp/Resources/en.lproj/Localizable.strings` | New/updated CNS UI keys |
| `iOSApp/Resources/it.lproj/Localizable.strings` | New/updated CNS UI keys |
| `Docs/DIR_DIVING_IOS_OXYGEN_EXPOSURE_MODEL.md` | UI section updated |
| `Docs/DIR_DIVING_IOS_PLANNER_LIMITATIONS.md` | CNS UI clarity section |
| `Docs/DIR_DIVING_IOS_ALGORITHM_RELEASE_HARDENING.md` | Planner CNS UI note |
| `Docs/IOS_DYNAMIC_TYPE_VOICEOVER_QA_MATRIX.md` | Planner CNS VoiceOver rows |

## Files created

| File | Purpose |
|------|---------|
| `Tests/iOSAlgorithmTests/PlannerCNSCopyTests.swift` | Localization + derived CNS estimate tests |
| `Docs/IOS_PLANNER_CNS_UI_UX_FIX_VERIFICATION.md` | This report |

---

## CNS UI/UX issues fixed

| Audit item | Status |
|------------|--------|
| P1 — Full-plan CNS label + footnote | **Fixed** |
| P1 — CNS Descent + Bottom footnote | **Fixed** |
| P1 — 15% warning + action hint | **Fixed** |
| P1 — Accessibility label/hint | **Fixed** |
| P2 — Pre-calculation CNS ambiguity (Option A) | **Fixed** |
| P2 — Ascent/deco derived estimate | **Implemented** |
| P3 — Settings description copy | **Fixed** |

---

## Localization keys added/updated

All required keys from the implementation spec are present in EN and IT, including:

- `planner.metric.cns_full_plan` / `.footnote`
- `planner.metric.cns_preview` / `.footnote`
- `planner.metric.cns_descent_bottom.footnote`
- `planner.cns_descent_bottom.warning.hint`
- `planner.metric.cns_ascent_deco_estimate` / `.footnote`
- `planner.settings.cns_descent_bottom_15_check.description`
- `planner.accessibility.cns_descent_bottom.warning.label` / `.hint`

---

## Result-screen CNS visibility

After **Calcola Piano**, **PLAN** tab `resultGrid` shows:

1. **CNS (full plan)** with inclusion footnote  
2. **CNS Descent + Bottom** with exclusion footnote  
3. **15% warning** (conditional) with hint  
4. **CNS ascent/deco (est.)** with derived footnote  
5. **OTU** (unchanged position in grid)  
6. Reference-only oxygen disclaimer block (unchanged)

---

## Pre-calculation preview behavior

**DENSITY / END** card uses **CNS (bottom preview)** + footnote; does not use full-plan wording.

---

## 15% warning behavior

- Red tile + triangle when `cnsDescentBottomPercent > 15` and toggle enabled.  
- Warning + muted action hint directly under descent+bottom row.  
- VoiceOver label and hint on banner; enhanced tile label when warning active.

---

## Ascent/deco CNS estimate

**Implemented** as `TechnicalGasAnalysis.cnsAscentDecoEstimatePercent` = `max(0, cnsPercent − cnsDescentBottomPercent)` with explicit non-certified footnote.

---

## Tests

- `PlannerCNSCopyTests` — EN/IT key presence, label wording, derived estimate math  
- Existing `CNSDescentBottomTests` — unchanged (math scope)

---

## macOS validation

| Command | Result |
|---------|--------|
| `xcodegen generate` | PASS |
| `xcodebuild` DIRDiving iOS (iPhone 17 sim) | PASS |
| `xcodebuild test` DIRDiving iOS Algorithm Tests | PASS (192 executed, 1 skipped, 0 failures) |

---

## Scope confirmation

- **Watch files:** not modified  
- **Experimental files:** not modified  
- **Bühlmann / CNS / gas math:** not modified (presentation-only derived difference)  
- **UI redesign:** not introduced (footnotes and copy only)

---

## Acceptance criteria

| Criterion | Met |
|-----------|-----|
| Total CNS visible as “CNS (full plan)” | Yes |
| Full plan includes decompression (footnote) | Yes |
| CNS Descent + Bottom visible | Yes |
| Descent+bottom excludes deco (footnote) | Yes |
| Preview not confused with full plan | Yes |
| >15% → red value | Yes |
| >15% → warning + hint nearby | Yes |
| EN/IT localization | Yes |
| Accessibility label/hint | Yes |
| OTU visible | Yes |
| Non-certified posture | Yes |
| No Watch/experimental changes | Yes |

---

## Final verdict

**READY** (code/static); physical VoiceOver walkthrough remains external QA per `IOS_DYNAMIC_TYPE_VOICEOVER_QA_MATRIX.md`.
