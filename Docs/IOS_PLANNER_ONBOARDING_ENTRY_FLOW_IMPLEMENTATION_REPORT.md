# iOS Planner Onboarding Entry Flow — Implementation Report

**Date:** 2026-06-09  
**Branch:** `main`  
**Scope:** UI/navigation flow only — no algorithm, Watch, sync, or legal semantics changes.

---

## PART 1 — Existing implementation (discovered)

| Component | Location | Role |
|-----------|----------|------|
| Planner mode selection UI | `iOSApp/Views/CCR/PlannerModeSelectionView.swift` | Full card layout matching reference screenshot |
| Planner routing | `iOSApp/Views/CCR/PlannerRootView.swift` | `plannerShowsModeSelection` → selection / CCR / OC planner |
| Mode state | `iOSApp/Services/PlannerStore.swift` | `plannerShowsModeSelection`, `selectPlannerMode`, persistence |
| Tab shell | `iOSApp/Views/ContentView.swift` | Planner tab first; lazy mount; `PlannerRootView()` |
| Legal gate | `iOSApp/App/DIRDivingiOSApp.swift` + `IOSLegalOnboardingView.swift` | Blocks `ContentView` until acceptance |
| Per-launch disclaimer | `LaunchCompanionDisclaimerOverlay` | Separate overlay; unchanged |

**Gap:** Mode selection UI existed but was **not guaranteed** as the first Planner experience after legal onboarding. Returning users with persisted `plannerShowsModeSelection == false` skipped directly to the planner form. Fresh installs already defaulted to `plannerShowsModeSelection = true`.

**CCR:** Fully implemented — `PlannerMode.ccr` → `CCRPlannerView` / `CCRPlannerEngine`. Reference-only disclaimers present in EN/IT.

---

## PART 2 — Flow after legal onboarding

| Step | Behavior |
|------|----------|
| User completes `IOSLegalOnboardingView` | `LegalAcceptanceStore.accept()` marks one-shot post-legal landing |
| `ContentView` appears | `onAppear` consumes flag → Planner tab + `preparePostLegalOnboardingEntry()` |
| Planner tab | `PlannerRootView` shows `PlannerModeSelectionView` |
| User picks mode | `selectPlannerMode` → detailed planner (OC or CCR) |
| Return visits | Persisted `plannerShowsModeSelection` respected; back affordance in planner toolbars unchanged |

**No change** to companion per-launch disclaimer overlay or legal copy.

---

## PART 3 — State model

- Reused `PlannerStore.plannerShowsModeSelection` (persisted in `PlannerState`).
- Added `preparePostLegalOnboardingEntry()` — sets selection visible after legal acceptance only.
- `IOSCompanionPostLegalEntry` — one-shot coordinator between legal accept and `ContentView` mount.
- Mode switching / calculations unchanged.

---

## PART 4–7 — UI / CCR / safety / accessibility

- Reused `DIRScreenContainer`, `DIRCard`, `DIRWarningBox`, `DIRTheme`.
- Technical card accent → amber (distinct from Deco yellow and CCR orange).
- Current/last-selected mode shows cyan border on selection screen.
- Added EN/IT a11y keys: `planner.mode_selection.card.a11y.hint`, `planner.mode_selection.safety.a11y`.
- VoiceOver sort priority: title → subtitle → safety pill → mode cards.

---

## Files changed

| File | Change |
|------|--------|
| `iOSApp/Utils/IOSCompanionPostLegalEntry.swift` | **New** — post-legal landing flag |
| `iOSApp/App/LegalAcceptanceStore.swift` | Mark pending planner landing on accept |
| `iOSApp/Services/PlannerStore.swift` | `preparePostLegalOnboardingEntry()` |
| `iOSApp/Views/ContentView.swift` | Apply post-legal planner landing |
| `iOSApp/Views/CCR/PlannerModeSelectionView.swift` | Accent/a11y polish |
| `iOSApp/Resources/*/Localizable.strings` | A11y strings |
| `Tests/iOSAlgorithmTests/IOSPlannerOnboardingEntryFlowTests.swift` | **New** — flow tests |

---

## Not changed

- Watch app, algorithms, Bühlmann, gas math, CNS/OTU, sync, persistence schema semantics, legal disclaimer text.
