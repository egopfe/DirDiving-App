# DIR DIVING iOS — Runtime Language Switch Fix Report

**Date:** 2026-06-10  
**Branch:** `main`  
**Scope:** iOS runtime localization / string resolution only.

---

## 1. Executive summary

Fixed the iOS Companion in-app language switch so Settings → Language updates tab labels, settings copy, planner/checklist/equipment UI, alerts, and accessibility text immediately without app restart.

---

## 2. Bug description

Changing language in Settings (Italian ↔ English) stored the preference but most UI remained in the previous/system language.

---

## 3. Root cause

- `DIRDivingiOSApp` applied `.environment(\.locale, …)` at the root.
- Settings writes `@AppStorage(DIRIOSAppLanguage.storageKey)`.
- Most shipped iOS UI used `String(localized:)`, which resolves against the **system/main bundle**, not the selected in-app locale.
- `DIRCompanionTabBar` and `MoreView` were primary examples.

---

## 4. Files modified (primary)

| File | Change |
|------|--------|
| `iOSApp/Utils/DIRIOSLocalizer.swift` | **New** runtime resolver |
| `iOSApp/App/DIRIOSAppLanguage.swift` | `localizedTitle` / `localizedDetail` |
| `iOSApp/App/DIRDivingiOSApp.swift` | `ContentView().id(appLanguage)` refresh |
| `iOSApp/Views/**` | `String(localized:)` → `DIRIOSLocalizer` |
| `iOSApp/Utils/**` | User-facing strings via localizer |
| `iOSApp/Services/**` | User-visible messages via localizer |
| `iOSApp/Services/PDF/**` | PDF user-facing strings |
| `iOSApp/Resources/en.lproj/Localizable.strings` | `language.option.*` keys |
| `iOSApp/Resources/it.lproj/Localizable.strings` | `language.option.*` keys |
| `Tests/iOSAlgorithmTests/IOSRuntimeLanguageSwitchTests.swift` | **New** guardrails |
| `project.yml` | Test target: localizer + language + resources |

---

## 5. Runtime localizer

`DIRIOSLocalizer` loads `en.lproj` / `it.lproj` from the selected `DIRIOSAppLanguage`, supports format strings, falls back to key when missing, and uses `Bundle.main` in release.

---

## 6. Settings language picker

`MoreView` uses `localizedTitle` / `localizedDetail` for picker options and summary text.

---

## 7. Tab bar

`DIRCompanionTabBar` uses `DIRIOSLocalizer.string` for labels and accessibility; `@AppStorage` + `.id(appLanguage)` ensures refresh.

---

## 8. String replacements

Bulk migration across `iOSApp/` shipped UI, utils, services (user-facing only). No `String(localized:)` remains in iOS shipped code except comments.

---

## 9. Catalog keys added

- `language.option.system`
- `language.option.italian`
- `language.option.english`
- `language.option.system.detail`
- `language.option.italian.detail`
- `language.option.english.detail`

---

## 10. Tests

`IOSRuntimeLanguageSwitchTests` (5 tests): EN/IT resolution, fallback, format args, language keys, static MoreView/TabBar guardrails.

---

## 11. Build / test

| Step | Result |
|------|--------|
| `DIRDiving iOS` build (iPhone 15 Pro) | **SUCCEEDED** |
| `IOSRuntimeLanguageSwitchTests` | **5/5 PASSED** |

---

## 12. Manual QA checklist

- [ ] Settings → Italian: tabs + settings + planner Italian
- [ ] Settings → English: tabs + settings + planner English
- [ ] No restart required
- [ ] No data loss / no Altro tab
- [ ] Legal onboarding language unchanged

---

## 13. Follow-up

- Optional: migrate any future iOS strings to `DIRIOSLocalizer` by convention.
- Release builds rely on embedded `.lproj` in app bundle (standard).

---

## 14. Confirmations

- Apple Watch files: **not changed**
- Algorithms / Bühlmann / gas / CNS/OTU / planner math: **not changed**
- WatchConnectivity / sync / persistence: **not changed**
- Features removed: **none**
- UI/UX readiness: **preserved**
- Change type: **iOS runtime localization only**
