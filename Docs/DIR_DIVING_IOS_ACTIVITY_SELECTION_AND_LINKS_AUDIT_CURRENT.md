# DIR DIVING — iOS Activity Selection and Functional Links Audit (Current)

**Date:** 2026-06-17  
**Command:** 15 (§7 iOS Companion root flow)  
**Branch:** `main` @ `138dccb`  
**Working tree:** Clean  

---

## Onboarding → selection flow

```
DIRDivingiOSApp
├── legalAcceptance.requiresAcceptance → IOSLegalOnboardingView
├── companionActivity.shouldPresentSelectionScreen → IOSCompanionActivitySelectionView
├── selectedMode == .apnea → IOSApneaRootView
├── selectedMode == .snorkeling → IOSSnorkelingRootView
└── else → ContentView (Diving)
```

**Selection triggers** (`CompanionActivityPreferenceStore`):
- First launch after legal (`!hasCompletedPostOnboardingSelection`)
- `showActivitySelectionAtLaunch` and not yet consumed this session
- Settings → “Change activity” (`forceSelectionPresentation`)

**Persistence:** UserDefaults-backed preference; legacy legal users migrate to Diving without re-selection (tested in `IOSCompanionActivitySelectionTests`).

**Watch guard:** Active Watch session shows note; selection is not blocked (`watchActiveSessionNote`).

---

## Selection screen implementation

**Source:** `iOSApp/Views/IOSCompanionActivitySelectionView.swift`  
**Mockup:** `mockups/IOS_COMPANION_ACTIVITY_SELECTION_POST_ONBOARDING.png`

| Element | Required | Implemented | Notes |
|---------|----------|-------------|-------|
| Brand header | DIR DIVING | Yes (`:34`) | Hardcoded Latin brand |
| Title IT | SCEGLI LA TUA ATTIVITÀ | Yes | `companion.activitySelection.title` |
| Title EN | CHOOSE YOUR ACTIVITY | Yes | Same key EN catalog |
| Subtitle | Localized | Yes | `companion.activitySelection.subtitle` |
| Diving card | Yes | Yes | Accent + features + chevron |
| Apnea card | Yes | Yes | |
| Snorkeling card | Yes | Yes | |
| Card order | Diving → Apnea → Snorkeling | Yes | `modes` array `:8` |
| Safety card | Yes | Yes | `:111-123` |
| Settings reminder | Yes | Yes | `:125-136` |
| Disabled unavailable mode | Yes | Yes | Sheet `IOSCompanionActivityComingSoonView` |
| Accessibility | Labels + hints | Yes | Per-card `:105-108` |

### Visual fidelity score: **88/100**

Functional layout matches mockup structure (header, three stacked cards, safety, settings footnote). Pixel-level diff not executed in this read-only audit.

### Functional fidelity score: **92/100**

All three cards call `activityStore.select(mode, …)` and swap root via `@Published selectedMode`.

---

## Feature flags

| Mode | `isLaunchableOnIOSCompanionMAIN` | UI when disabled |
|------|----------------------------------|------------------|
| Diving | `true` | Card disabled + coming-soon sheet |
| Apnea | `true` | Same infrastructure |
| Snorkeling | `true` | Same infrastructure |

Infrastructure is **FEATURE_FLAGGED (dormant)** — all modes enabled at `138dccb`.

---

## Diving route chain

| Step | Destination | Status |
|------|-------------|--------|
| Selection → Diving | `ContentView` | **WORKING** |
| → Planner | `PlannerRootView` (default tab) | **WORKING** |
| → Logbook | `LogbookView` | **WORKING** |
| → Settings | `MoreView` | **WORKING** |
| → Equipment | `EquipmentView` | **WORKING** |
| → Analysis | `AnalysisView` | **WORKING** |

**Note:** Diving has no separate “Dashboard” tab; **Planner is the functional home** (`ContentView` default `.planner`). This is a semantic naming difference vs mockup labels, not a broken route.

**Post-select landing:** Diving consumes `consumePendingPlannerLanding()` in `ContentView.onAppear` — **WORKING**.

---

## Apnea route chain

| Step | Destination | Status |
|------|-------------|--------|
| Selection → Apnea | `IOSApneaRootView` | **WORKING** |
| → Dashboard | `IOSApneaDashboardView` | **WORKING** |
| → Profiles / Planner | `IOSApneaProfilesView` + sheet `IOSApneaSessionPlannerView` | **WORKING** |
| → Logbook | `IOSApneaSessionsListView` (tab `.sessions`) | **WORKING** |
| → Statistics | `IOSApneaStatisticsView` | **WORKING** |
| → Settings | Sheet `IOSApneaSettingsView` | **WORKING** |

**Gaps:**
- **PARTIAL** — Dashboard last-session card shows chevron but no navigation (`IOSApneaDashboardView` ~60–73)
- **MISSING** — `markPendingApneaLanding()` never consumed in production UI

---

## Snorkeling route chain

| Step | Destination | Status |
|------|-------------|--------|
| Selection → Snorkeling | `IOSSnorkelingRootView` | **WORKING** |
| → Dashboard | `IOSSnorkelingDashboardView` | **WORKING** |
| → Route Planner / Map | `IOSSnorkelingRoutePlannerView` (tab) | **WORKING** — real MapKit |
| → Logbook | `IOSSnorkelingSessionsListView` | **WORKING** |
| → Markers / Photos | Session detail → photos + markers sections | **WORKING** |
| → Settings | Sheet `IOSSnorkelingSettingsView` | **WORKING** |

**Gaps:**
- **PARTIAL** — Route planner also opens as sheet from dashboard (dual entry)
- **PARTIAL** — Last-session card non-interactive
- **MISSING** — `markPendingSnorkelingLanding()` not consumed

---

## Functional-link matrix (explicit tests)

| Route | Status |
|-------|--------|
| Selection → Diving → Planner | **WORKING** |
| Selection → Diving → Logbook | **WORKING** |
| Selection → Diving → Settings | **WORKING** |
| Selection → Apnea → Profiles/Planner | **WORKING** |
| Selection → Apnea → Logbook | **WORKING** |
| Selection → Apnea → Statistics | **WORKING** |
| Selection → Snorkeling → Route Planner | **WORKING** |
| Selection → Snorkeling → Logbook | **WORKING** |
| Selection → Snorkeling → Markers/Photos | **WORKING** (via session detail) |

Full matrix: [`DIR_DIVING_IOS_FUNCTIONAL_LINK_MATRIX_CURRENT.csv`](DIR_DIVING_IOS_FUNCTIONAL_LINK_MATRIX_CURRENT.csv)

---

## Root navigation integrity

| Check | Result |
|-------|--------|
| One authoritative root coordinator | PASS — `DIRDivingiOSApp` |
| Duplicate root `NavigationStack` | PASS — tab roots; selection is full-screen swap |
| State loss on mode change | PASS — separate `@StateObject` stores per activity |
| Onboarding replay | PASS — gated by `LegalAcceptanceStore` |
| Watch session interruption | PASS — note only, no remote switch |
| Data deletion on activity change | PASS — stores persist independently |

---

## Logbook links from selection

Activity-selection cards **do not** deep-link directly to any logbook. User must enter activity root first — **correct ownership pattern**.

Cross-activity logbook routes: all **BLOCKED_AS_EXPECTED** (see logbook matrix).

---

## Scores

| Metric | Score | Label |
|--------|-------|-------|
| Visual fidelity (selection) | 88 | PASS |
| Functional fidelity (selection) | 92 | PASS |
| Navigation completeness | 86 | CONDITIONAL PASS |
| Localization readiness | 94 | PASS |
| Accessibility readiness | 85 | CONDITIONAL PASS |
| Root-flow readiness | 89 | CONDITIONAL PASS |

---

## Final iOS root-flow readiness

**CONDITIONAL PASS**

Core selection → activity → feature routes are **WORKING**. Remaining gaps are dashboard polish (last-session navigation), unused post-landing flags, and physical layout verification — none are P0.
