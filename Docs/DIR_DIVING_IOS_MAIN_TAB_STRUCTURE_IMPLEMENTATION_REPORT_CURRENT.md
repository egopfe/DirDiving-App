# DIR DIVING iOS — Main Tab Structure Implementation Report

**Date:** 2026-06-10  
**Branch:** `main`  
**Scope:** UI/navigation/information-architecture only.

---

## 1. Executive summary

The iOS Companion exposes six first-level tabs: **Pianifica | LogBook | Analisi | Attrezzatura | Checklist | Settings**. Checklist and Settings are no longer hidden behind “Altro”. A custom `DIRCompanionTabBar` replaces `TabView` because UIKit collapses the sixth tab into the system **More / Altro** overflow on iPhone.

---

## 2. Goal implemented

Main tab bar: **Pianifica | LogBook | Analisi | Attrezzatura | Checklist | Settings**

---

## 3. Previous structure

- Combined **Attrezzatura + Checklist** in one equipment screen (pre–tab split).
- Later interim: **Altro** tab with submenu rows (Lista controllo / Impostazioni) before promotion to six tabs.

---

## 4. Final structure

| Tab label (IT) | Tab label (EN) | `IOSTab` case | Root view |
|----------------|----------------|---------------|-----------|
| Pianifica | Planner | `.planner` | `PlannerRootView` |
| LogBook | LogBook | `.logbook` | `LogbookView` |
| Analisi | Analysis | `.analysis` | `AnalysisView` |
| Attrezzatura | Equipment | `.gear` | `EquipmentView` |
| Checklist | Checklist | `.checklist` | `ChecklistView` |
| Settings | Settings | `.settings` | `MoreView` (settings content) |

Default tab: **Planner**. Lazy tab mounting via `mountedTab(_:)`.

---

## 5. Files (primary)

| File | Role |
|------|------|
| `iOSApp/Views/ContentView.swift` | `IOSTab` enum + six lazy-mounted roots + custom tab bar |
| `iOSApp/Views/Components/DIRCompanionTabBar.swift` | Six visible tabs (avoids UIKit More overflow) |
| `iOSApp/Views/ChecklistView.swift` | Checklist root |
| `iOSApp/Views/MoreView.swift` | Settings root (`settings.title`) |
| `iOSApp/Views/EquipmentView.swift` | Attrezzatura + images |
| `iOSApp/Resources/en.lproj/Localizable.strings` | Tab labels EN |
| `iOSApp/Resources/it.lproj/Localizable.strings` | Tab labels IT |
| `Tests/iOSAlgorithmTests/IOSEquipmentChecklistTabSplitTests.swift` | Tab structure guardrails |

Related: `Docs/DIR_DIVING_IOS_EQUIPMENT_CHECKLIST_TAB_SPLIT_IMPLEMENTATION_REPORT_CURRENT.md`

---

## 6. Tab enum / navigation

```swift
enum IOSTab {
    case planner, logbook, analysis, gear, checklist, settings
}
```

- No `.more` in `TabView`.
- `tab.more` key retained in catalogs (legacy/unused in tab bar).
- Settings badge: `settingsTabBadge` (sync conflicts / queue).

---

## 7. Checklist promotion

- Direct mount: `mountedTab(.checklist) { ChecklistView() }`
- Setup selection card, GAS/BAR/PSI, PDF export, empty state → Attrezzatura preserved.
- No Checklist inside Settings or Altro.

---

## 8. Settings promotion

- Direct mount: `mountedTab(.settings) { MoreView() }`
- Screen title: `settings.title` → **Impostazioni** (IT) / **Settings** (EN)
- Tab label: **Settings** (both locales per product style)
- Preferences, sync, legal, developer, cloud backup, CSV import — unchanged.

---

## 9. Attrezzatura preservation

- `EquipmentView`: planning, templates, image transfer panel.
- Checklist reads setups via `EquipmentStore.selectedChecklistTemplateID`.

---

## 10. Localization

| Key | EN | IT |
|-----|----|----|
| `tab.planner` | Planner | Pianifica |
| `tab.logbook` | LogBook | LogBook |
| `tab.analysis` | Analysis | Analisi |
| `tab.gear` | Equipment | Attrezzatura |
| `tab.checklist` | Checklist | Checklist |
| `tab.settings` | Settings | Settings |
| `settings.title` | Settings | Impostazioni |

`tab.more` = More / Altro — not exposed in tab bar.

---

## 11. Accessibility

- Tab `Label("tab.*", systemImage:)` — SwiftUI localized keys.
- Checklist progress, setup card, GAS toggles — `a11y.checklist.*`.
- Settings tab badge for sync conflicts.

---

## 12. Layout

- `dirCompanionTabRoot`, `dirCompanionTabSlot`, `DIRBackground` — unchanged.
- Six tabs use concise product labels to limit truncation.
- **UIKit constraint:** `TabView` with six items on iPhone shows only four custom tabs plus system **More** (localized **Altro**), hiding overflow tabs inside a list. `DIRCompanionTabBar` is required for six visible tabs.

---

## 13. Build / test results

| Step | Result |
|------|--------|
| `xcodegen generate` | OK |
| `xcodebuild -list` | Schemes: DIRDiving iOS, DIRDiving iOS Algorithm Tests, DIRDiving Watch App |
| `xcodebuild -scheme "DIRDiving iOS" -destination 'platform=iOS Simulator,name=iPhone 15 Pro' build` | **SUCCEEDED** |
| `IOSEquipmentChecklistTabSplitTests` (3 tests) | **PASSED** |

Simulator: **iPhone 15 Pro** (iOS Simulator).

---

## 14. Manual QA checklist

- [ ] Six tabs visible; no Altro
- [ ] Checklist opens directly
- [ ] Settings opens directly (title Impostazioni in IT)
- [ ] Attrezzatura + images reachable
- [ ] Planner default after legal onboarding
- [ ] No blank tabs

---

## 15. Follow-up

- Optional: rename `MoreView` → `CompanionSettingsView` (cosmetic).
- `tab.more` orphan key cleanup when safe.

---

## 16. Confirmations

- Apple Watch files: **not changed**
- Algorithms / Bühlmann / gas / CNS/OTU / planner math: **not changed**
- WatchConnectivity / sync codecs / persistence: **not changed**
- Checklist, Attrezzatura, Settings features: **preserved**
- GPS POI: **not introduced**
- Change type: **UI/navigation/information-architecture only**
