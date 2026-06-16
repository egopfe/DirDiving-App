# DIR DIVING — iOS Companion Post-Onboarding Activity Selection

**Command:** `01_IOS_COMPANION_POST_ONBOARDING_ACTIVITY_SELECTION.md`  
**Date:** 2026-06-16  
**Branch:** `integration/full-computer`  
**Final result:** **PASS**

---

## Architecture discovered

| Area | Finding |
|------|---------|
| Legal gate | `LegalAcceptanceStore` in `iOSApp/App/LegalAcceptanceStore.swift` |
| Root shell | `DIRDivingiOSApp` gates: legal → activity selection → `ContentView` |
| Shared activity enum | `DIRActivityMode` in `Models/DIRModesAndStartup.swift` (Watch + iOS) |
| Feature availability | `DIRActivityMode.isLaunchableInMAIN` — only Diving is launchable in MAIN |
| Post-legal planner landing | `IOSCompanionPostLegalEntry` + `ContentView.applyPostLegalPlannerLandingIfNeeded()` |
| Design system | `DIRScreenContainer`, `DIRCard`, `DIRTheme`, `dirCompanionScrollSurface()` |

Companion activity preference is **separate** from Watch runtime startup state (`DIRStartupSelectionPolicy`).

---

## Files added

| File | Purpose |
|------|---------|
| `iOSApp/Models/CompanionActivityPreference.swift` | Codable preference model, availability + Watch session guard |
| `iOSApp/Services/CompanionActivityPreferenceStore.swift` | Persistence, migration, presentation policy |
| `iOSApp/Utils/CompanionActivityCopy.swift` | Foundation-only localized copy (testable) |
| `iOSApp/Utils/CompanionActivityPresentation.swift` | SwiftUI accents/icons delegating to copy |
| `iOSApp/Views/IOSCompanionActivitySelectionView.swift` | Post-onboarding selection UI + coming-soon sheet |
| `Tests/iOSAlgorithmTests/IOSCompanionActivitySelectionTests.swift` | Unit tests |

## Files modified

| File | Change |
|------|--------|
| `iOSApp/App/DIRDivingiOSApp.swift` | Activity selection gate in root flow |
| `iOSApp/App/LegalAcceptanceStore.swift` | Marks pending activity selection after legal accept |
| `iOSApp/Utils/IOSCompanionPostLegalEntry.swift` | Activity selection pending flags |
| `iOSApp/Views/MoreView.swift` | Settings → Activity section |
| `iOSApp/Resources/en.lproj/Localizable.strings` | 29 companion activity keys |
| `iOSApp/Resources/it.lproj/Localizable.strings` | 29 companion activity keys (parity) |
| `project.yml` | `DIRModesAndStartup.swift` in iOS target; test sources for preference store |

**Watch runtime, diving algorithms, decompression logic:** not modified.

---

## Navigation flow

### Before

```text
App launch → legal gate → ContentView (tabs) → optional post-legal planner mode sheet
```

### After

```text
App launch
→ legal gate (when required)
→ IOSCompanionActivitySelectionView (when no completed preference or show-at-launch)
→ ContentView (Diving Companion dashboard)
→ post-legal planner mode sheet (after Diving selection)
```

Settings → **Activity** → change activity reopens the selection screen without resetting legal onboarding.

---

## Persistence and migration

**Storage key:** `dirdiving_ios_companion_activity_preference_v1` (UserDefaults, JSON `Codable`)

**Schema fields:**

- `selectedMode: DIRActivityMode?`
- `showActivitySelectionAtLaunch: Bool` (default `false`)
- `hasCompletedPostOnboardingSelection: Bool`
- `schemaVersion: Int` (current `1`)

**Migration:** Users with existing `dirdiving_legal_acceptance_timestamp` but no preference record are migrated to Diving with `hasCompletedPostOnboardingSelection = true` (skip selection screen, preserve access).

**Corrupt data:** Decode failure falls back to the same migration path as a fresh install (no crash).

---

## Feature flags / availability

`CompanionActivityAvailability.isAvailable` uses `DIRActivityMode.isLaunchableInMAIN`:

| Mode | MAIN launchable | iOS Companion behaviour |
|------|-----------------|-------------------------|
| Diving | yes | Select → dashboard + planner landing |
| Apnea | no | Card disabled; tap → localized coming-soon sheet |
| Snorkeling | no | Card disabled; tap → localized coming-soon sheet |

---

## Watch active-session protection

When Watch reports an active dive session (`sync.status.watch_session_active`):

- iOS preference updates **locally** (selection not blocked)
- `watchActiveSessionNote` shown in selection flow and Settings
- `CompanionActivityWatchSessionGuard` defers preference sync semantics (no Watch session stop/switch)

---

## Localization

29 new keys under `companion.activity*` and `companion.settings.activity*`. EN/IT parity verified by:

- `DIRDivingCompleteLocalizationAuditTests`
- `Scripts/audit_localization.sh` → **PASS** (iOS EN=1970 IT=1970)

---

## Accessibility

- Each activity card: combined accessibility element with localized summary + hint
- Safety card: combined children
- Dynamic Type via existing typography; no fixed card heights
- Unavailable modes: explicit unavailable hint (not colour-only)

---

## Tests added

`IOSCompanionActivitySelectionTests` (11 cases):

- Initial preference requires selection
- Legacy legal-user migration to Diving
- Corrupt preference recovery
- Diving selection persistence + planner landing flag
- Unavailable Apnea/Snorkeling rejection
- Show-at-launch policy
- Settings reopen selection
- Watch active session note
- Watch session guard
- Legal accept pending flag
- Localization key presence

---

## Tests executed

| Suite | Result |
|-------|--------|
| `IOSCompanionActivitySelectionTests` | 11/11 PASS |
| `DIRDivingCompleteLocalizationAuditTests` | 4/4 PASS |
| `Scripts/audit_localization.sh` | PASS |

---

## Build results

| Target | Simulator | Result |
|--------|-----------|--------|
| DIRDiving iOS | iPhone 15 Pro (iOS 26.5) | **BUILD SUCCEEDED** |
| DIRDiving Watch App | Apple Watch Series 11 (46mm) | **BUILD SUCCEEDED** |

Run `xcodegen generate` before opening in Xcode to ensure `DIRDiving.xcodeproj` matches `project.yml`.

---

## Screenshot / state evidence

Visual hierarchy implemented per command mockup:

- Brand + title + subtitle header
- Three accent-bordered activity cards (blue / cyan / orange)
- Safety `DIRCard` with shield icon
- Settings reminder row with gear icon
- Dark `DIRScreenContainer` + scroll surface (no raster mockup assets)

---

## Unresolved risks

| Risk | Mitigation |
|------|------------|
| Apnea/Snorkeling dashboards not yet built | Unavailable sheet; no fake navigation |
| Watch preference sync not wired for activity mode | Documented as local-only; guard defers sync when session active |
| Post-upgrade one-time selection for legacy users | Skipped by design (Diving migration); product may revisit |

---

## Rollback

1. Revert commit on `integration/full-computer`
2. Run `xcodegen generate`
3. Delete UserDefaults key `dirdiving_ios_companion_activity_preference_v1` if testing clean install

---

## Confirmation

- No Watch session logic modified
- No diving/decompression algorithm modified
- No Apnea/Snorkeling Watch lifecycle modified

**Final result: PASS**
