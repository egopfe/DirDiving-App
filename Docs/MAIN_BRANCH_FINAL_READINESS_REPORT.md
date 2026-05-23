# DIR DIVING — MAIN Branch Final Readiness Report

**Date:** 2026-05-23  
**Branch:** `main`  
**Pass:** TestFlight-readiness fixes (Phases 0–10) — UI/i18n/discoverability only  
**Baseline:** [`MAIN_BRANCH_COMPLETE_READINESS_AUDIT_20260523.md`](MAIN_BRANCH_COMPLETE_READINESS_AUDIT_20260523.md), [`MAIN_BRANCH_UX_INTERACTION_ACCESSIBILITY_AUDIT_20260523.md`](MAIN_BRANCH_UX_INTERACTION_ACCESSIBILITY_AUDIT_20260523.md)

---

## 1. Branch confirmed

| Check | Result |
|-------|--------|
| Branch | `main` |
| Experimental branches/files | **Not modified** |
| `project.yml` experimental excludes | **Unchanged** |

---

## 2. Files modified

| File | Phase | Summary |
|------|-------|---------|
| `iOSApp/Views/CSVImportPanel.swift` | 2 | Shared CSV import button + `fileImporter` |
| `iOSApp/Views/LogbookView.swift` | 2, 5 | Import panel always visible; localized strings |
| `iOSApp/Views/MoreView.swift` | 2, 5, 6 | Import in EXPORT card; units honesty section; i18n |
| `iOSApp/Views/PlannerView.swift` | 3, 4, 5 | Result tabs switch content; mode picker disabled/planned; i18n |
| `iOSApp/Views/AnalysisView.swift` | 2, 5 | Empty-state import hint |
| `iOSApp/Views/DiveDetailView.swift` | 5 | Localized salinity label |
| `iOSApp/Views/IOSLegalOnboardingView.swift` | 9 | Scroll-to-bottom gate for disclaimer |
| `Views/SettingsView.swift` | 5, 7 | Informational export/TTV rows; Settings i18n |
| `Views/DiveLogListView.swift` | 5, 8 | Trash button + confirm; no `contextMenu`; i18n |
| `Views/WatchLegalOnboardingView.swift` | 9 | Scroll-to-bottom gate (Watch) |
| `Resources/en.lproj/Localizable.strings` | 5, 7, 8 | Watch keys |
| `Resources/it.lproj/Localizable.strings` | 5, 7, 8 | Watch keys |
| `iOSApp/Resources/en.lproj/Localizable.strings` | 2–6, 9 | iOS keys |
| `iOSApp/Resources/it.lproj/Localizable.strings` | 2–6, 9 | iOS keys |
| `Docs/TESTFLIGHT_ENTITLEMENT_AND_DEVICE_QA_20260523.md` | 1 | External QA checklist |
| `Docs/INTERNAL_TESTING_PLAYBOOK_20260520.md` | 1 | Link to entitlement QA doc |
| `Docs/MAIN_BRANCH_FINAL_READINESS_REPORT.md` | 10 | This report |

**Not modified:** `DiveManager`, `PlannerService`, `BuhlmannPlanner`, `GasPlanningService`, TTV math, sync crypto, depth/ascent algorithms, visual theme assets.

---

## 3. Issues fixed

| Issue | Fix |
|-------|-----|
| CSV import hidden when logbook non-empty | **Importa CSV** in Logbook + More (`CSVImportPanel`) |
| Planner result tabs non-functional | Tabs filter **PLAN / BUHLMANN / CHARTS** sections |
| Planner mode misleading | Only **Avanzato** active; others disabled + footer note |
| Watch Settings export row looks tappable | `informational: true` + subtitle points to Dive Log |
| iOS units unclear | Metric-only picker (disabled) + explanatory footer in More |
| Residual IT strings (primary flows) | Localized Watch Settings, log, More, Planner, legal prompt |
| Legal honor-system scroll | ScrollView + bottom sentinel before Continue |
| Watch log `contextMenu` | Replaced with trash button + confirmation dialog |
| TestFlight external blockers undocumented | New entitlement + device QA checklist |

---

## 4. Issues intentionally left open

| Item | Reason |
|------|--------|
| Apple **water submersion** entitlement approval | Apple Developer portal + physical Ultra |
| **Underwater depth** validation | Device-only |
| **Physical Watch↔iPhone** sync/tombstone QA | Device-only |
| **App Store** listing / screenshots | Out of scope |
| iOS PlanResult **share** toolbar | Still display-only (low priority) |
| Settings **cross-sync** Watch↔iOS | Post-release product decision |
| **Imperial** units | Not implemented; honestly labeled metric-only |
| Generic `xcodebuild` unified project | Named simulators preferred (known AppIcon arch quirk) |

---

## 5. Business logic unchanged

Confirmed: no edits to dive start/stop logic, depth safety thresholds, ascent calculations, TTV derivation, planner/Bühlmann/gas algorithms, CSV parser schema, or sync HMAC protocol.

---

## 6. UI / UX style preserved

- Dark + cyan/yellow identity unchanged  
- Reference layouts: `Docs/ReferenceUI/Watch_LIVE_reference.png`, `Docs/ReferenceUI/iOS_Companion_reference.png`  
- No new experimental screens or mode tabs enabled  

---

## 7. Experimental untouched

`project.yml` excludes remain: Apnea, Snorkeling, Buddy, Exploration sources.

---

## 8. Build results

| Command | Result |
|---------|--------|
| `xcodegen generate` | **PASS** |
| `xcodebuild` **DIRDiving Watch App** (Apple Watch Ultra 3 sim) | **BUILD SUCCEEDED** |
| `xcodebuild` **DIRDiving iOS** (iPhone 17 sim) | **BUILD SUCCEEDED** |
| `xcodebuild` generic iOS Simulator | Not re-run this pass (named sim OK) |

### Phase 1 — Bundle / entitlements (verified in repo)

| Item | Value |
|------|--------|
| Watch `PRODUCT_BUNDLE_IDENTIFIER` | `com.egopfe.dirdiving.ios.watch` |
| iOS `PRODUCT_BUNDLE_IDENTIFIER` | `com.egopfe.dirdiving.ios` |
| `WKCompanionAppBundleIdentifier` | `com.egopfe.dirdiving.ios` |
| Watch entitlements | iCloud KVS + `com.apple.developer.coremotion.water-submersion` |
| iOS entitlements | iCloud KVS |

**Entitlement approval on Apple Developer portal:** **not verified in this pass** (see checklist).

---

## 9. Remaining blockers

### TestFlight (internal)

- [ ] Enable water submersion on `com.egopfe.dirdiving.ios.watch` (Developer portal)  
- [ ] Physical Ultra underwater depth QA  
- [ ] Physical sync QA per playbook  
- [ ] Internal tester run through [`TESTFLIGHT_ENTITLEMENT_AND_DEVICE_QA_20260523.md`](TESTFLIGHT_ENTITLEMENT_AND_DEVICE_QA_20260523.md)

### App Store

- All TestFlight items above  
- Store assets, privacy labels, marketing review  
- Field evidence for depth-limit disclaimers  

---

## 10. Readiness estimates (post-pass)

| Dimension | Estimate |
|-----------|----------|
| **Internal / TestFlight readiness (code)** | **~96%** |
| **Internal / TestFlight readiness (overall)** | **~88%** (device + entitlement external) |
| **UX completeness** | **~92%** |
| **i18n (EN primary flows)** | **~90%** |
| **App Store readiness** | **No** |

---

## Mandatory final check

| Criterion | Status |
|-----------|--------|
| Both targets build (named simulators) | **YES** |
| No experimental dependencies in MAIN | **YES** |
| UI matches references (no redesign) | **YES** |
| No business logic changed | **YES** |
| i18n obvious gaps closed | **Mostly YES** (shortcut help / some chrome IT remains LOW) |
| Planner UI truthful | **YES** |
| CSV import discoverable | **YES** |
| TestFlight/depth docs complete | **YES** ([`TESTFLIGHT_ENTITLEMENT_AND_DEVICE_QA_20260523.md`](TESTFLIGHT_ENTITLEMENT_AND_DEVICE_QA_20260523.md)) |

**Verdict:** MAIN is **ready for internal TestFlight build upload** once Apple entitlement + physical QA checklists are signed off. **Not** ready for App Store or “100% consumer ready” without device validation.

---

*Report generated 2026-05-23 after Phases 0–10 implementation pass.*
