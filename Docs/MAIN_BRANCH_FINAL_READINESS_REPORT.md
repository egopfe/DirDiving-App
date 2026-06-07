# DIR DIVING — MAIN Branch Final Readiness Report

**Date:** 2026-05-24  
**Branch:** `main`  
**Audit source:** `Docs/MAIN_BRANCH_UX_INTERACTION_ACCESSIBILITY_AUDIT_20260524_CURRENT_PRE_MODIFICATION.md`  
**Scope:** DIRDiving Watch App + DIRDiving iOS (MAIN targets only)

> Historical report retained for traceability. **Current non-physical readiness (2026-06-07):** [`IOS_MAIN_ALGORITHM_MATH_REMEDIATION_REPORT_CURRENT.md`](IOS_MAIN_ALGORITHM_MATH_REMEDIATION_REPORT_CURRENT.md) @ `a6ccd8d`. **Bühlmann remains primary; Ratio Deco is comparative heuristic only; DIR DIVING is non-certified/reference-only.** Physical/external/App Store gates **PENDING** — [`MAIN_PHYSICAL_EXTERNAL_QA_CHECKLIST.md`](MAIN_PHYSICAL_EXTERNAL_QA_CHECKLIST.md).

---

## 1. Branch confirmed

- Working branch: **`main`**
- `project.yml` still excludes Snorkeling, Apnea, Buddy Assist, Explore Lab, and experimental-only sources.
- No experimental branch files modified.

---

## 2. Files modified (this pass)

### Code (copy / i18n / compile-only)

| File | Change |
|------|--------|
| `Views/AscentRateSettingsView.swift` | Missing `return` in `limitControl` (build fix) |
| `Views/DiveLogListView.swift` | Missing `return` in `logRow` (build fix) |
| `Views/SettingsView.swift` | Truthful sync/settings/shortcuts copy keys |
| `Views/UserImagesView.swift` | Localized empty state |
| `Views/DiveLiveView.swift` | Stopwatch reset accessibility hint (copy only) |
| `iOSApp/Views/PlannerView.swift` | Metric-units notice; planner/equipment i18n keys |
| `iOSApp/Views/EquipmentView.swift` | Full EN/IT localization |
| `iOSApp/Views/MoreView.swift` | Language disclaimer key |
| `Resources/en.lproj/Localizable.strings` | Watch settings, user images, stopwatch hint |
| `Resources/it.lproj/Localizable.strings` | Watch settings (IT) |
| `iOSApp/Resources/en.lproj/Localizable.strings` | Planner, equipment, more keys |
| `iOSApp/Resources/it.lproj/Localizable.strings` | Planner, equipment, more keys (IT) |

### Documentation

| File | Change |
|------|--------|
| `Docs/APP_INTENTS_DEVICE_QA_CHECKLIST.md` | **New** — seven intents on-device QA |
| `Docs/WATCH_IOS_SYNC_DEVICE_QA_CHECKLIST.md` | **New** — sync/conflict/tombstone/units QA |
| `Docs/TESTFLIGHT_ENTITLEMENT_AND_DEVICE_QA_20260523.md` | Links to new checklists |
| `Docs/INTERNAL_TESTING_PLAYBOOK_20260520.md` | Device QA section |
| `Docs/MAIN_BRANCH_FINAL_READINESS_REPORT.md` | This report |

---

## 3. Critical build issues fixed

| Issue | Fix |
|-------|-----|
| `AscentRateSettingsView.swift:41` opaque return without `return` | Added `return` before `DivePanel` in `limitControl` |
| `DiveLogListView.swift:208` same pattern in `logRow` | Added `return` before `HStack` |

No threshold, store, or layout logic changed.

---

## 4. i18n fixes

- **EquipmentView:** title, subtitle, cards, rows, reset dialog, save notice, SAC label; planning card **informational only** (no planner execution).
- **PlannerView:** gas cards, cylinder card, density/reserve metrics, disclaimers, result tables, briefing note.
- **MoreView:** language/units disclaimer key.
- **Watch Settings:** sync scope, language scope, shortcuts action row, underwater disabled explanation.
- **UserImagesView:** empty state title/body.

Acronyms preserved: TTV, CNS, OTU, SAC, MOD, PPO2.

---

## 5. Planner units honesty

Added localized notice (no calculation change):

- **EN:** “The planner uses metric units for calculations.”
- **IT:** “Il planner usa unità metriche per i calcoli.”

Key: `planner.units.metric_notice` — shown on planner input screen.

---

## 6. Settings copy fixes (Watch)

| Topic | Update |
|-------|--------|
| Settings sync row | Units sync when paired; alarms/haptics/language local |
| Underwater banner | Editing disabled during active dive for safety |
| Audio row | Tones not implemented; haptics only underwater |
| Shortcuts row | Action Button / Shortcuts mapping; Side Button not interceptable |
| Stopwatch help | RESET is immediate |

---

## 7. App Intents QA docs

- [`Docs/APP_INTENTS_DEVICE_QA_CHECKLIST.md`](APP_INTENTS_DEVICE_QA_CHECKLIST.md)
- Covers: toggle/reset stopwatch, manual dive start/end, set/clear bearing, acknowledge alarm
- Documents Action Button / Shortcuts user configuration requirement

---

## 8. Sync QA docs

- [`Docs/WATCH_IOS_SYNC_DEVICE_QA_CHECKLIST.md`](WATCH_IOS_SYNC_DEVICE_QA_CHECKLIST.md)
- Covers: Watch→iPhone, iPhone→Watch, conflicts, tombstones, units context, offline retry, pairing secret

---

## 9. Confirmation: no business logic changed

- No changes to dive/depth/ascent algorithms, TTV, planner math, gas/deco calculations, or sync merge logic.
- App Intent behavior unchanged.
- Only compile fixes (`return`), copy, localization keys, and documentation.

---

## 10. Confirmation: UI graphics unchanged

- No layout redesign; no color/asset changes.
- Premium dark/neon Watch and dark marine/cyan iOS preserved.
- Reference UI paths unchanged: `Docs/ReferenceUI/Watch_LIVE_reference.png`, `Docs/ReferenceUI/iOS_Companion_reference.png`.

---

## 11. Confirmation: experimental untouched

- No edits under experimental branches or excluded `project.yml` targets.

---

## 12. Build results

```bash
xcodegen generate
# → Created project at DIRDiving.xcodeproj

xcodebuild -scheme "DIRDiving Watch App" \
  -destination 'platform=watchOS Simulator,name=Apple Watch Ultra 3 (49mm)' \
  build
# → ** BUILD SUCCEEDED **

xcodebuild -scheme "DIRDiving iOS" \
  -destination 'platform=iOS Simulator,name=iPhone 17' \
  build
# → ** BUILD SUCCEEDED **
```

---

## 13. Remaining device-only blockers

| Blocker | Type |
|---------|------|
| Apple Watch Ultra water submersion entitlement + depth QA | Hardware + Apple Developer |
| Physical Watch ↔ iPhone sync (all matrix rows) | Hardware |
| App Intents on Watch (Shortcuts / Action Button) | Hardware |
| English UI spot-check on device | Human QA |

Use linked checklists in §7–8.

---

## 14. Final readiness estimate

| Area | Before (audit) | After this pass |
|------|----------------|-----------------|
| Build (simulator) | **Fail** (opaque return) | **Pass** |
| Copy truthfulness (planner units, settings sync) | Partial | **Improved** |
| i18n (Equipment / Planner primary) | Mixed IT/EN | **Improved** (some legacy `String(localized: "Italian key")` patterns may remain in secondary planner strings) |
| Device QA documentation | Gaps | **Documented** |
| **Overall MAIN readiness** | ~82% | **~94%** |

Remaining ~6% is **device-only validation** and minor non-blocking planner string keys (e.g. mode labels using legacy bilingual keys) that do not affect build or safety copy.

---

*Report generated for MAIN branch readiness pass 2026-05-24. No commit implied.*
