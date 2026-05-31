# DIR DIVING — MAIN Branch UI/UX Readiness Audit (Current)

> **Nota (2026-05-31):** Audit read-only **pre-fix** (83% / 86% / 81%). Remediation completa P0–P3 su `main` @ `c8f91f6`. Per lo stato corrente usare [`MAIN_UI_UX_READINESS_AUDIT_POST_FIX.md`](MAIN_UI_UX_READINESS_AUDIT_POST_FIX.md) e [`MAIN_UI_UX_READINESS_QA_ANALYSIS.md`](MAIN_UI_UX_READINESS_QA_ANALYSIS.md).

**Date:** 2026-05-31  
**Branch:** `main` @ `02eb9d8` (baseline audit; superseded by post-fix @ `c8f91f6`)  
**Scope:** Apple Watch MAIN (`DIRDiving Watch App`) + iOS Companion MAIN (`DIRDiving iOS`)  
**Audit type:** Read-only — no code modified  
**Visual benchmarks:** `Docs/ReferenceUI/Watch_LIVE_reference.png`, `Docs/ReferenceUI/iOS_Companion_reference.png` (both present)

---

## A. Executive Summary

| Metric | Score | Notes |
|--------|-------|-------|
| **Apple Watch UI/UX readiness** | **83%** | Core Live Dive safety philosophy is strong; layout overflow risk, Crown discoverability, and mixed IT/EN legal onboarding reduce score |
| **iOS Companion UI/UX readiness** | **86%** | Tab navigation complete; planner truthfulness good; demo labeling, iCloud conflict visibility, and GPS-only manual edit are gaps |
| **Cross-app consistency** | **81%** | Manual/no-depth policy mostly aligned; Watch↔iOS GPS copy consistent; edit-path on iOS breaks Policy A |
| **Internal TestFlight (UI/UX)** | **Conditional** | Usable for team QA with documented caveats; not “clean” without P0 fixes |
| **External TestFlight (UI/UX)** | **Not ready** | P0 issues + physical device QA required |
| **App Store review (UI/UX)** | **Not ready** | Localization gaps, misleading planner team preview, demo log labeling, physical QA |

**Headline:** Both MAIN apps are **functionally reachable** and **mostly usable** for an informed diver who reads disclaimers. They are **not yet at 100% UI/UX readiness** for external TestFlight or App Store without addressing safety-adjacent layout risk (Watch), Policy A edit regression (iOS), demo-data labeling, and multi-locale polish.

---

## B. Scope Confirmation

### Branch & tree

| Check | Result |
|-------|--------|
| Branch | `main` |
| Working tree | Clean @ `3ad40d6` |
| Experimental branches | Not touched |

### Targets (`project.yml`)

| Target | Platform | Role |
|--------|----------|------|
| `DIRDiving Watch App` | watchOS 10+ | Watch MAIN |
| `DIRDiving iOS` | iOS 17+ | iOS Companion MAIN |
| `DIRDiving Watch Algorithm Tests` | watchOS | Test only |
| `DIRDiving iOS Algorithm Tests` | iOS | Test only |

### Experimental exclusion (MAIN)

**Watch excluded:** `ApneaView`, `SnorkelingView`, `BuddyAssistView`, `ExperimentalConceptsView`, exploration/buddy services and models.

**iOS excluded:** `ExplorationCenterView`, `BuddyExperimentalView`, `ExperimentalFutureConceptsView`, exploration/buddy stores/models.

Experimental Swift files may exist in the repo but are **not compiled into MAIN binaries**.

### Visual references

| File | Status |
|------|--------|
| `Docs/ReferenceUI/Watch_LIVE_reference.png` | Present (101 KB) |
| `Docs/ReferenceUI/iOS_Companion_reference.png` | Present (146 KB) |

### Build validation (local, 2026-05-31)

| Step | Result |
|------|--------|
| `xcodegen generate` | OK |
| `xcodebuild` Watch (`Apple Watch Ultra 3 (49mm)` sim) | **BUILD SUCCEEDED** |
| `xcodebuild` iOS (`iPhone 17` sim) | **BUILD SUCCEEDED** |

---

## C. Apple Watch Feature Inventory

| Feature | Implemented | Reachable | Usable | Complete | Severity | Notes |
|---------|-------------|-----------|--------|----------|----------|-------|
| Legal onboarding (4-step) | Yes | Yes | Yes | Partial | HIGH | Steps 0–1 mostly hardcoded EN; disclaimer step localized |
| Launch companion disclaimer | Yes | Every cold launch | Yes | Yes | INFO | Session-scoped dismiss |
| Mode selection | Yes | **No** | N/A | Dormant | LOW | `hasMultipleStableModes = false`; auto-skips to Live |
| Live Dive dashboard | Yes | Yes | Yes | Partial | HIGH | Fixed VStack; multi-banner overflow on small watches |
| Auto / manual dive | Yes | Yes | Yes | Yes | INFO | Manual fallback when depth automation unavailable |
| TTV / runtime / depth hero | Yes | Yes | Yes | Yes | INFO | Remain visible during ascent alarms |
| Ascent gauge + banner | Yes | Yes (underwater) | Yes | Yes | INFO | Non-blocking inline banner |
| Depth safety 35/38/40 m | Yes | Yes | Yes | Yes | INFO | Max/avg cards hidden only at `.exceeded` |
| Stopwatch START/STOP/RESET | Yes | Yes | Partial | MEDIUM | UI reset confirms; Action Button reset does not |
| GPS fix/fallback/no-fix banners | Yes | Yes | Yes | Yes | INFO | No green “success” for no-fix |
| Depth stale banner | Yes | Yes | Yes | Yes | INFO | Implemented in Live |
| Compass + SET/CLEAR bearing | Yes | Yes (underwater) | Yes | Partial | MEDIUM | Missing VoiceOver labels; “CLEAR” hardcoded EN |
| Settings hub | Yes | Surface only | Yes | Partial | MEDIUM | Underwater lock banner never seen (TabView blocks access) |
| Ascent rate limits | Yes | Surface | Yes | Partial | MEDIUM | Band labels metric-only in imperial mode |
| Alarm thresholds | Yes | Surface | Yes | Partial | MEDIUM | Mixed hardcoded IT strings |
| Units / language | Yes | Surface | Yes | Yes | LOW | Wheel pickers; units sync to iPhone |
| Haptics toggle + visual fallback | Yes | Anytime | Yes | Yes | INFO | Yellow “visual only” badge on Live |
| Mission mode indicator | Yes | Active dive | Yes | Partial | LOW | 7.5pt bolt; EN-only a11y |
| Logbook list / detail | Yes | Surface | Yes | Partial | MEDIUM | Delete dialog hardcoded IT |
| CSV export + ShareLink | Yes | Surface | Partial | MEDIUM | Share on list/detail; ExportView lacks ShareLink |
| User images gallery | Yes | Surface | Yes | Partial | LOW | No VoiceOver on images |
| Info / diagnostics | Yes | Surface | Yes | Partial | MEDIUM | Battery bar always green |
| Watch ↔ iPhone sync UI | Yes | Settings | Yes | Yes | INFO | Retry / clear queue present |
| Action Button / App Intents | Yes | When mapped | Yes | Partial | MEDIUM | All 7 intents present; reset bypasses confirmation |
| Shortcuts help | Yes | Settings | Yes | Yes | INFO | Documents Crown + underwater limits |

---

## D. Apple Watch Navigation Map

```
DIRDivingApp
└─ [gate] WatchLegalOnboardingView (requiresAcceptance)
└─ ContentView — TabView(.verticalPage, Digital Crown)
     ├─ [hidden] ModeSelectionView          (hasMultipleStableModes = false)
     ├─ DiveLiveView                        ← default landing (.live)
     ├─ CompassView                         ← reachable underwater
     ├─ SettingsView
     │    ├─ AscentRateSettingsView
     │    ├─ AlarmSettingsView
     │    ├─ WatchLegalSafetyView
     │    ├─ WatchShortcutHelpView
     │    └─ InfoView
     ├─ UserImagesView (list ↔ detail)
     └─ DiveLogListView
          ├─ DiveDetailView
          └─ ExportView

Overlays: LaunchCompanionDisclaimerOverlay (cold launch)
Underwater guard: only .live + .compass; other pages snap back to .live
Active dive start: auto-select .live
```

**Dead ends / hidden features**

| Path | Issue |
|------|-------|
| Mode Selection | Implemented but omitted from TabView when single stable mode |
| Settings → Export row | Informational only; no NavigationLink to Logbook |
| ExportView | Success screen without ShareLink (share on prior screen only) |
| Settings underwater banner | Only renders if `isDiveActive`, but Settings unreachable during dive |

**Underwater restrictions**

- Crown swipe to Settings / Logbook / Images blocked by `ContentView.onChange(selectedPage)`.
- Documented in `WatchShortcutHelpView`; not surfaced in-context on Live when redirect occurs (**W-UX-002**).

---

## E. Apple Watch UI/UX Issues

### Live Dive

| ID | Sev | File | Description | Impact | Fix class |
|----|-----|------|-------------|--------|-----------|
| W-UX-001 | **HIGH** | `Views/DiveLiveView.swift` | Active dive uses fixed `VStack` in `GeometryReader` without scroll. Sync strip + TTV + ascent banner + depth-stale + depth safety (×2) + 72pt depth hero + 154pt gauge + stopwatch + controls + GPS/alarm banners can exceed 41–45mm viewport. | Bottom controls may clip during stacked alarms | UI-only (scroll or collapse priority) |
| W-UX-004 | INFO | `DiveLiveView`, `AscentWarningBannerView` | Depth, TTV, runtime, gauge remain visible during ascent alarm — verified. | Safety philosophy preserved | — |

### Alarms / warnings

| ID | Sev | File | Description | Impact | Fix class |
|----|-----|------|-------------|--------|-----------|
| W-UX-011 | MEDIUM | `Views/AscentGaugeView.swift` | Scale ticks use orange at 75%; zone pointer uses green/yellow/red only. | Zone color may not match tick user reads | UI-only |
| W-UX-015 | LOW | `Views/DepthSafetyLiveViews.swift` | Banner uses `.combine` without explicit alarm summary label. | VoiceOver severity unclear | copy-only / a11y |

### GPS

| ID | Sev | File | Description | Impact | Fix class |
|----|-----|------|-------------|--------|-----------|
| — | INFO | `DiveLiveView`, `Resources/*.lproj` | No-fix uses yellow/warning semantics, not green success — verified. | Correct | — |

### Settings

| ID | Sev | File | Description | Impact | Fix class |
|----|-----|------|-------------|--------|-----------|
| W-UX-002 | **HIGH** | `SettingsView.swift`, `ContentView.swift` | Underwater settings lock banner never visible because TabView blocks Settings during dive. | Users discover lock only via help or trial-and-error | copy-only / UI-only |
| W-UX-007 | MEDIUM | `SettingsView.swift` | Export row is informational; no link to Logbook export flow. | Export path unclear | navigation / copy-only |
| W-UX-020 | MEDIUM | `AlarmSettingsView.swift` | Header, footnote, row titles hardcoded IT; nav title `"Allarmi"`. | EN locale inconsistent | localization |
| W-UX-021 | MEDIUM | `AscentRateSettingsView.swift` | Depth bands always metric (`40-30 m`) in imperial mode. | Imperial users misread bands | localization / UI-only |

### Hardware controls

| ID | Sev | File | Description | Impact | Fix class |
|----|-----|------|-------------|--------|-----------|
| W-UX-003 | MEDIUM | `ActionButtonIntents.swift` | `ResetStopwatchIntent` calls `resetStopwatch()` without confirmation; Live UI requires dialog when time > 0. | Accidental data loss via shortcut | small functional |
| W-UX-024 | INFO | `HapticService.swift` | Haptics respect global toggle; Live shows visual-only badge. | Good | — |
| W-UX-025 | INFO | `WatchShortcutHelpView` | Side button cannot be overridden — honestly documented. | Good | — |

### Logbook / export

| ID | Sev | File | Description | Impact | Fix class |
|----|-----|------|-------------|--------|-----------|
| W-UX-009 | MEDIUM | `ExportView.swift` | Post-export screen lacks ShareLink; user must navigate back to list/detail. | Extra steps; easy to miss share | UI-only |
| W-UX-018 | MEDIUM | `DiveDetailView.swift` | Delete confirmation hardcoded IT (`"Eliminare immersione?"`). | EN users see Italian | localization |
| W-UX-019 | MEDIUM | `ExportView.swift` | Success copy hardcoded IT (`"ESPORTAZIONE COMPLETATA"`). | EN users see Italian | localization |

### Navigation / discoverability

| ID | Sev | File | Description | Impact | Fix class |
|----|-----|------|-------------|--------|-----------|
| W-UX-006 | **HIGH** | `ContentView.swift` | Vertical TabView has no page indicator or first-run Crown hint on main screens. | Logbook/Settings/Images undiscoverable | UI-only |
| W-UX-008 | LOW | `ModeSelectionView.swift` | Mode selection scaffolding unreachable. | Future-mode dead UI | architectural (flag) |

### Accessibility

| ID | Sev | File | Description | Impact | Fix class |
|----|-----|------|-------------|--------|-----------|
| W-UX-012 | MEDIUM | `CompassView.swift` | No accessibility labels on dial, heading, SET/CLEAR. | VoiceOver unusable on compass | UI-only |
| W-UX-013 | LOW | `MissionModeIndicatorView.swift` | Hardcoded EN a11y `"Mission Mode Active"`. | Non-EN VoiceOver | localization |
| W-UX-014 | LOW | `UserImagesView.swift` | Image rows lack accessibility labels. | Gallery unusable with VoiceOver | UI-only |
| W-UX-016 | INFO | `DiveLiveView`, `AscentGaugeView` | Core metrics, gauge, stopwatch have solid a11y — verified. | Good baseline | — |

### Localization

| ID | Sev | File | Description | Impact | Fix class |
|----|-----|------|-------------|--------|-----------|
| W-UX-017 | **HIGH** | `WatchLegalOnboardingView.swift` | Welcome, safety, acceptance toggles, exit alert largely hardcoded EN; disclaimer step localized. | IT users see mixed-language safety gate | localization |
| W-UX-022 | LOW | `ModeSelectionView.swift` | Experimental notice hardcoded IT (unreachable today). | Future leak | localization |
| W-UX-023 | LOW | `CompassView.swift` | `"CLEAR"` hardcoded EN. | Minor inconsistency | localization |

### Visual consistency / diagnostics

| ID | Sev | File | Description | Impact | Fix class |
|----|-----|------|-------------|--------|-----------|
| W-UX-005 | MEDIUM | `InfoView.swift` | Battery progress bar always `DiveUI.green` regardless of level. | Misleading “healthy” color | UI-only |

---

## F. Apple Watch Priority Plan

### APPLE WATCH P0 — Must fix before internal TestFlight

| ID | Title | Screen/file | User impact | Safety | Solution | Effort | Dependency | Acceptance |
|----|-------|-------------|-------------|--------|----------|--------|------------|------------|
| W-UX-001 | Live layout overflow under stacked alarms | `DiveLiveView.swift` | Controls clipped on 41–45mm | Metrics/controls may become unreachable underwater | Add scroll or priority collapse for non-critical panels | M | — | All alarm combinations fit on 41mm sim without clipping START/STOP/acknowledge |
| W-UX-017 | Legal onboarding localization | `WatchLegalOnboardingView.swift` | Mixed EN/IT safety gate | Trust / App Store review | Localize all onboarding strings IT+EN | M | `Resources/*.lproj` | Full IT+EN walkthrough with no hardcoded strings |

### APPLE WATCH P1 — Must fix before external TestFlight

| ID | Title | Screen/file | User impact | Safety | Solution | Effort | Dependency | Acceptance |
|----|-------|-------------|-------------|--------|----------|--------|------------|------------|
| W-UX-006 | Crown navigation discoverability | `ContentView.swift` | Hidden Logbook/Settings | — | First-run coach mark or page dots | S | — | New user finds Logbook within 60s unaided |
| W-UX-002 | Underwater lock explanation | `ContentView`, `DiveLiveView` | Confusion when Crown snaps back | — | Toast on redirect or Live hint | S | — | User sees reason when blocked from Settings |
| W-UX-003 | Reset stopwatch intent parity | `ActionButtonIntents.swift` | Accidental reset | Data loss | Gate intent like UI confirmation | S | — | Intent matches UI policy |
| W-UX-018–019 | Export/delete localization | `ExportView`, `DiveDetailView` | EN users see IT dialogs | — | Move strings to Localizable | S | — | EN locale shows EN only |

### APPLE WATCH P2 — Must fix before App Store

| ID | Title | Solution | Effort |
|----|-------|----------|--------|
| W-UX-007 | Settings export dead row | Link to Logbook or remove row | S |
| W-UX-009 | ExportView ShareLink | Add ShareLink on completion | S |
| W-UX-011 | Ascent gauge color alignment | Align zone colors to ticks | S |
| W-UX-012–014 | Compass / images a11y | Add labels and hints | M |
| W-UX-020–021 | Alarm/ascent settings i18n + units | Localize + imperial bands | M |
| W-UX-005 | Battery bar semantics | Tiered colors by level | S |

### APPLE WATCH P3 — Post-release

| ID | Title |
|----|-------|
| W-UX-008 | Mode selection scaffolding cleanup |
| W-UX-013 | Mission mode a11y localization |
| W-UX-022–023 | Minor string cleanup |

---

## G. iOS Feature Inventory

| Feature | Implemented | Reachable | Usable | Complete | Severity | Notes |
|---------|-------------|-----------|--------|----------|----------|-------|
| Legal onboarding | Yes | Yes | Yes | Yes | INFO | Gate before tabs |
| Launch companion disclaimer | Yes | Cold launch | Yes | Yes | INFO | Session-scoped |
| Tab: Planner | Yes | Yes | Yes | Partial | MEDIUM | Team preview misleading |
| Tab: Logbook | Yes | Yes | Yes | Partial | HIGH | Demo dives unlabeled on cards |
| Tab: Analysis | Yes | Yes | Yes | Partial | MEDIUM | Empty-state actions hardcoded IT |
| Tab: Equipment | Yes | Yes | Yes | Partial | MEDIUM | Pickers missing a11y labels |
| Tab: More/Settings | Yes | Yes | Yes | Partial | MEDIUM | Mixed IT hardcoded chrome |
| Manual dive add/edit | Yes | Yes | Partial | **HIGH** | Edit GPS-only Watch session fabricates profile |
| Dive detail (3 tabs) | Yes | Yes | Yes | Partial | MEDIUM | Custom tabs weak a11y |
| CSV import | Yes | Logbook/More/Analysis | Yes | Yes | INFO | Multiple entry points |
| CSV export | Yes | Detail | Yes | Yes | INFO | Blocked for no-depth — correct |
| Planner calculate → result | Yes | Yes | Yes | Yes | INFO | Strong disclaimers |
| Watch sync UI | Yes | More | Yes | Partial | MEDIUM | No queue counts / last success time |
| iCloud sync UI | Yes | More | Partial | **HIGH** | `sessionMergeConflicts` never shown |
| Watch conflict resolution | Yes | More | Yes | Yes | INFO | When Watch sends conflict |
| Demo toggle | Yes | More | Yes | Partial | HIGH | Demo cards lack DEMO badge |
| Experimental views | Yes (repo) | **No** (MAIN build) | N/A | N/A | INFO | Excluded from `project.yml` |

---

## H. iOS Navigation Map

```
DIRDivingiOSApp
└─ [gate] IOSLegalOnboardingView
└─ ContentView TabView
     ├─ PlannerView → PlanResultView (plan / Bühlmann / charts tabs)
     ├─ LogbookView → DiveDetailView → ManualDiveEditorView
     │              → ManualDiveEditorView (+)
     │              → CSVImportPanel (inline)
     ├─ AnalysisView → CSVImportPanel / empty actions
     ├─ EquipmentView → EquipmentTemplatesSheet
     └─ MoreView → IOSLegalSafetyView, Watch sync, iCloud, CSVImportPanel, WatchPhotoTransferPanel

Not in MAIN binary: ExplorationCenterView, BuddyExperimentalView (project.yml excludes)
```

**Dead ends / affordances**

| Element | Issue |
|---------|-------|
| Logbook `ellipsis.circle` | Visible, no action, `accessibilityHidden(true)` — decorative (**I-UX-002**) |
| Planner mode picker | Single non-switchable “Advanced” segment (**I-UX-003**) |
| CSV import | Up to 3 entry points (redundant, not broken) |

---

## I. iOS UI/UX Issues

### Logbook

| ID | Sev | File | Description | Impact | Fix class |
|----|-----|------|-------------|--------|-----------|
| I-UX-021 | **HIGH** | `LogbookView.swift` | Demo dives (`isDemoDive`) have no DEMO badge on card. | Users/reviewers treat sample dives as real | UI-only / copy-only |
| I-UX-022 | MEDIUM | `DiveLogStore.swift` | Demo rows can remain mixed after user adds real dives. | Mixed log integrity | UI-only |
| I-UX-002 | LOW | `LogbookView.swift` | Header ellipsis icon non-functional. | False affordance | UI-only |
| I-UX-035 | LOW | `LogbookView.swift` | Search filters site name only. | Weak discoverability | UI-only |
| I-UX-036 | LOW | `LogbookView.swift` | Inline trash beside NavigationLink. | Accidental delete risk | UI-only |

### Dive detail

| ID | Sev | File | Description | Impact | Fix class |
|----|-----|------|-------------|--------|-----------|
| I-UX-012 | INFO | `DiveDetailView.swift` | No-depth: badge, banner, chart placeholder, export guard — aligned with Policy A. | Good | — |
| I-UX-019 | LOW | `DiveDetailView.swift` | Export button enabled; error after tap for no-depth. | Minor friction | UI-only |
| I-UX-027 | MEDIUM | `DiveDetailView.swift` | Custom tab strip lacks selected trait for VoiceOver. | A11y gap | UI-only |
| I-UX-034 | LOW | `DiveDetailView.swift` | Salinity always shown as salt. | Misleading for fresh water | copy-only |

### Manual dive editor

| ID | Sev | File | Description | Impact | Fix class |
|----|-----|------|-------------|--------|-----------|
| I-UX-009 | **CRITICAL** | `ManualDiveEditorView.swift` | Editing Watch GPS-only session (`hasDepthProfile == false`) always runs `ManualDiveSampleBuilder`; save sets `hasDepthProfile` true via non-empty samples. Breaks [`WATCH_MANUAL_NODEPTH_SYNC_POLICY.md`](WATCH_MANUAL_NODEPTH_SYNC_POLICY.md). | Data integrity; export/analysis truthfulness | small functional + UI |
| I-UX-010 | MEDIUM | `ManualDiveEditorView.swift` | iOS manual dives always get synthetic 4-point profile without disclosure. | Users may treat as measured | copy-only |
| I-UX-011 | LOW | `ManualDiveEditorView.swift` | Stepper +/- lack a11y labels. | VoiceOver friction | UI-only |

### Analysis

| ID | Sev | File | Description | Impact | Fix class |
|----|-----|------|-------------|--------|-----------|
| I-UX-023 | INFO | `AnalysisView.swift` | Demo excluded by default; include toggle present. | Good | — |
| I-UX-025 | MEDIUM | `AnalysisView.swift` | Empty-state buttons hardcoded IT (`"Importa CSV"`, etc.). | EN locale broken | localization |
| I-UX-026 | LOW | `AnalysisView.swift` | Duplicate dead `fileImporter` path. | Maintenance | medium refactor |

### Planner

| ID | Sev | File | Description | Impact | Fix class |
|----|-----|------|-------------|--------|-----------|
| I-UX-005 | **HIGH** | `PlannerView.swift` | Team preview shows hardcoded Diver A/B; `updateTeamMember` never wired. Footer says “V2”. | Misleading team gas matching | copy-only or UI-only |
| I-UX-003 | MEDIUM | `PlannerView.swift` | Single-segment mode picker implies unshipped modes. | Confusing positioning | copy-only |
| I-UX-006 | MEDIUM | `PlannerView.swift` | Live reserve tiles update before Calculate. | Preview vs result confusion | copy-only |
| I-UX-007 | LOW | `PlannerView.swift` | Metric gas notice easy to miss for imperial users. | Misread bar/L | copy-only |
| I-UX-008 | INFO | `PlanResultView` | Reference-only header, incomplete calc banner, MOD section — strong. | Good | — |
| I-UX-028 | MEDIUM | `PlanResultView` | Result tabs lack selected a11y trait. | VoiceOver gap | UI-only |
| I-UX-030 | LOW | `PlannerGasMixCard.swift` | O₂/He steppers lack a11y names. | A11y | UI-only |

### Equipment

| ID | Sev | File | Description | Impact | Fix class |
|----|-----|------|-------------|--------|-----------|
| I-UX-029 | MEDIUM | `EquipmentView.swift`, `EquipmentChecklistGasSection.swift` | Pickers use `.labelsHidden()` without container a11y label. | Unlabeled for VoiceOver | UI-only |

### More / settings

| ID | Sev | File | Description | Impact | Fix class |
|----|-----|------|-------------|--------|-----------|
| I-UX-013 | **HIGH** | `DiveLogStore.swift`, `MoreView.swift` | `sessionMergeConflicts` populated but never surfaced; merge uses `preferred` silently. | iCloud divergences invisible | UI-only |
| I-UX-014 | MEDIUM | `MoreView.swift` | Watch card lacks pending queue count / last success time. | Sync state vague | UI-only |
| I-UX-015 | MEDIUM | `MoreView.swift` | iCloud rows partly static marketing copy. | Overstates backup clarity | copy-only |
| I-UX-016 | LOW | `CloudSyncStore.swift` | Manual sync no spinner/progress. | Ambiguous completion | UI-only |
| I-UX-017 | INFO | `MoreView.swift` | Watch conflict resolution UI well structured. | Good | — |
| I-UX-033 | MEDIUM | `MoreView.swift` | Mixed hardcoded IT (`"Altro"`, section headers) with localized keys. | EN chrome shows IT | localization |

### Sync

| ID | Sev | File | Description | Impact | Fix class |
|----|-----|------|-------------|--------|-----------|
| I-UX-018 | INFO | `WatchDiveSyncCodec.swift`, detail views | No-depth sync accepted; export blocked — consistent. | Good | — |

### Import / export

| ID | Sev | File | Description | Impact | Fix class |
|----|-----|------|-------------|--------|-----------|
| I-UX-020 | INFO | `CSVImportPanel`, `DiveImportService` | Requires depth columns; rejects empty profile. | Consistent | — |

### Accessibility

| ID | Sev | File | Description | Impact | Fix class |
|----|-----|------|-------------|--------|-----------|
| I-UX-031 | LOW | `LogbookView.swift` | Dive cards lack consolidated a11y label. | Screen reader efficiency | UI-only |
| I-UX-032 | INFO | Charts in Analysis/Detail | Partial good `accessibilityLabel` coverage. | Baseline OK | — |

### Repository-only (not in MAIN binary)

| ID | Sev | File | Description | Impact | Fix class |
|----|-----|------|-------------|--------|-----------|
| I-UX-001 | INFO | `ExplorationCenterView.swift` | Experimental views excluded from MAIN target. | No shipped UX impact | — |

---

## J. iOS Priority Plan

### iOS P0 — Must fix before internal TestFlight

| ID | Title | Screen/file | User impact | Safety | Solution | Effort | Acceptance |
|----|-------|-------------|-------------|--------|----------|--------|------------|
| I-UX-009 | GPS-only manual edit fabricates profile | `ManualDiveEditorView.swift` | Breaks Policy A; enables export of fake profile | Data truthfulness | Block edit or GPS-only editor mode preserving `hasDepthProfile: false` | M | Edit Watch no-depth session never adds samples |
| I-UX-021 | Demo dive card labeling | `LogbookView.swift` | Reviewer/user confusion | App Store trust | DEMO badge on `isDemoDive` cards | S | Demo rows visually distinct |

### iOS P1 — Must fix before external TestFlight

| ID | Title | Solution | Effort |
|----|-------|----------|--------|
| I-UX-013 | iCloud merge conflicts invisible | Surface `sessionMergeConflicts` in More with resolve actions | M |
| I-UX-005 | Planner team preview misleading | Mark preview-only or wire editing | S–M |
| I-UX-025, I-UX-033 | Hardcoded IT in Analysis empty / More chrome | Localize strings | S |
| I-UX-027–029 | Custom tabs / equipment pickers a11y | Add traits and labels | M |

### iOS P2 — Must fix before App Store

| ID | Title | Solution | Effort |
|----|-------|----------|--------|
| I-UX-003 | Planner mode picker stub | Clear “Advanced only” framing | S |
| I-UX-010 | Synthetic manual profile disclosure | In-form notice | S |
| I-UX-014–016 | Sync status clarity | Queue counts, progress, timestamps | M |
| I-UX-022 | Mixed demo + real logbook | Banner when demo rows present | S |
| I-UX-034 | Salinity display | Reflect session data | S |

### iOS P3 — Post-release

| ID | Title |
|----|-------|
| I-UX-002 | Remove dead ellipsis |
| I-UX-026 | Consolidate CSV import paths |
| I-UX-035–036 | Search scope / delete UX polish |

---

## K. Cross-App Consistency Issues

| ID | Sev | Area | Description | Watch | iOS | Fix class |
|----|-----|------|-------------|-------|-----|-----------|
| X-UX-001 | **CRITICAL** | Manual/no-depth | Watch preserves GPS-only sessions; iOS edit path fabricates depth profile (**I-UX-009**). | Policy A OK | Policy A broken on edit | small functional |
| X-UX-002 | INFO | GPS no-fix copy | Aligned terminology (`RUNTIME/GPS`, no-fix banners, surface-only disclaimers). | OK | OK | — |
| X-UX-003 | INFO | Export policy | Both block CSV export without depth profile. | OK | OK | — |
| X-UX-004 | MEDIUM | Units | Watch units sync to iPhone; both support metric/imperial display. Ascent bands on Watch stay metric in imperial. | Partial | OK | localization |
| X-UX-005 | MEDIUM | Legal onboarding | Watch onboarding mixed EN; iOS onboarding more complete. Revision alignment unclear to user. | Partial | Better | localization |
| X-UX-006 | INFO | TTV / non-deco | Watch shows TTV; neither app claims NDL/TTS/deco computer authority. | OK | OK | — |
| X-UX-007 | MEDIUM | Sync conflicts | Watch conflicts surfaced in iOS More; iCloud field conflicts silent. | N/A | Gap | UI-only |
| X-UX-008 | INFO | Demo data | Analysis excludes demo; logbook cards do not label demo. | N/A | Gap | UI-only |
| X-UX-009 | INFO | Visual system | Both use dark/neon marine aesthetic per reference PNGs. | OK | OK | — |
| X-UX-010 | LOW | Shortcut errors | `DIRDivingShortcutError` message hardcoded IT. | IT only | N/A | localization |

---

## L. Cross-App Priority Plan

### CROSS-APP P0

| ID | Title | Apps | Action |
|----|-------|------|--------|
| X-UX-001 | Manual/no-depth edit regression | iOS (+ policy doc) | Fix `ManualDiveEditorView` before any external TestFlight |

### CROSS-APP P1

| ID | Title | Action |
|----|-------|--------|
| X-UX-005 | Legal onboarding locale parity | Align Watch onboarding localization with iOS |
| X-UX-007 | Conflict visibility symmetry | Surface iCloud conflicts like Watch conflicts |
| X-UX-004 | Imperial ascent band labels | Unit-aware Watch ascent settings |

### CROSS-APP P2

| ID | Title | Action |
|----|-------|--------|
| X-UX-008 | Demo labeling | DEMO badge on iOS logbook; document Watch has no demo dives |
| X-UX-010 | Shortcut error strings | Localize App Intent errors |

### CROSS-APP P3

| ID | Title |
|----|-------|
| — | Terminology harmonization pass (minor string audit) |

---

## M. App Store / TestFlight Risks

### Internal TestFlight blockers (UI/UX)

| App | Blocker | ID |
|-----|---------|-----|
| Watch | Live layout overflow under multi-alarm stacks | W-UX-001 |
| Watch | Legal onboarding mixed locale | W-UX-017 |
| iOS | GPS-only manual edit fabricates profile | I-UX-009 |
| iOS | Demo dives look like user data | I-UX-021 |

### External TestFlight blockers (UI/UX)

All P0 above, plus:

| App | Blocker | ID |
|-----|---------|-----|
| Watch | Crown navigation undiscoverable | W-UX-006 |
| Watch | Underwater settings lock invisible | W-UX-002 |
| iOS | iCloud merge conflicts silent | I-UX-013 |
| iOS | Planner team preview misleading | I-UX-005 |
| Both | Physical device QA not executed | § Physical QA |

### App Store blockers (UI/UX)

All external blockers, plus:

| Risk | ID |
|------|-----|
| Accessibility gaps on primary flows | W-UX-012, I-UX-027–029 |
| Localization incomplete EN/IT on safety surfaces | W-UX-017–019, I-UX-025, I-UX-033 |
| Misleading diagnostic colors | W-UX-005 |
| Non-certified positioning must remain clear | Verified OK on planner + onboarding |

### Physical device QA required (process — not code)

| Area | Watch | iOS |
|------|-------|-----|
| Underwater Crown navigation + readability | Required | — |
| Haptics with global toggle off | Required | — |
| Action Button intents | Required | — |
| WatchConnectivity sync + conflict | — | Required |
| iCloud KVS multi-device | — | Required |
| VoiceOver walkthrough primary tabs | Required | Required |
| CSV round-trip with real files | — | Required |

---

## N. Remediation Roadmap

Ordered fixes for a follow-up **implementation** command (not executed in this audit):

| # | Theme | App | Priority | Likely files | Risk | Business logic? | UI graphics? | Device QA? |
|---|-------|-----|----------|--------------|------|-----------------|--------------|------------|
| 1 | Safety-critical Live layout | Watch | P0 | `DiveLiveView.swift` | Medium | No | Layout only | Sim + Ultra |
| 2 | Policy A edit guard | iOS | P0 | `ManualDiveEditorView.swift` | Medium | Small | UI copy | Sync test |
| 3 | Demo labeling | iOS | P0 | `LogbookView.swift` | Low | No | Badge | Reviewer path |
| 4 | Legal onboarding i18n | Watch | P0 | `WatchLegalOnboardingView.swift`, `Resources/` | Low | No | Copy | Locale switch |
| 5 | Crown discoverability | Watch | P1 | `ContentView.swift` | Low | No | Coach mark | Usability test |
| 6 | Underwater lock hint | Watch | P1 | `ContentView.swift`, `DiveLiveView.swift` | Low | No | Copy | Underwater |
| 7 | iCloud conflict UI | iOS | P1 | `MoreView.swift`, `DiveLogStore.swift` | Medium | No | UI-only | Multi-device |
| 8 | Planner team preview truth | iOS | P1 | `PlannerView.swift` | Low | No | Copy/UI | — |
| 9 | Stopwatch intent parity | Watch | P1 | `ActionButtonIntents.swift` | Low | Small | — | Action Button |
| 10 | Export flow polish | Watch | P2 | `ExportView.swift`, `SettingsView.swift` | Low | No | Navigation | — |
| 11 | Accessibility pass | Both | P2 | Compass, tabs, equipment pickers | Low | No | A11y | VoiceOver |
| 12 | Localization sweep | Both | P2 | Alarm/Export/Analysis/More strings | Low | No | Copy | EN+IT |
| 13 | Sync status clarity | iOS | P2 | `MoreView.swift` | Low | No | UI | WC + iCloud |
| 14 | App Store polish | Both | P2 | Info battery bar, salinity, search | Low | No | Minor UI | — |
| 15 | Post-release cleanup | Both | P3 | Mode selection, CSV dedup | Low | No | — | — |

**Estimated aggregate effort:** P0 ≈ 3–5 dev days; P1 ≈ 4–6 days; P2 ≈ 5–8 days; physical QA ≈ 2–4 days parallel.

---

## O. Final Verdict

| Question | Answer |
|----------|--------|
| **Is Watch UI/UX ready?** | **Mostly — 83%.** Core Live Dive is strong and safety-preserving (inline alarms, metrics stay visible). Not ready for external release without layout and localization fixes. |
| **Is iOS UI/UX ready?** | **Mostly — 86%.** Navigation complete; planner disclaimers honest. Blocked by Policy A edit regression and demo labeling for reviewer trust. |
| **Ready for internal TestFlight?** | **Conditional yes** — team can test with a known-issues list covering P0 items above. |
| **Ready for external TestFlight?** | **No** — P0 + P1 UX issues and no physical device QA sign-off. |
| **Ready for App Store?** | **No** — external blockers plus accessibility/localization polish and physical QA. |
| **What blocks 100% UI/UX readiness?** | (1) Watch Live overflow + Crown discoverability + onboarding i18n; (2) iOS GPS-only edit regression + demo labeling + silent iCloud conflicts; (3) cross-app locale parity; (4) accessibility on compass/custom tabs/equipment; (5) physical device QA on Ultra + paired iPhone. |

---

## Appendix — Issue index

| Range | Count | App |
|-------|-------|-----|
| W-UX-001 – W-UX-025 | 25 | Apple Watch |
| I-UX-001 – I-UX-036 | 36 | iOS Companion |
| X-UX-001 – X-UX-010 | 10 | Cross-app |

**Severity totals (unique issues):** CRITICAL 1 · HIGH 8 · MEDIUM 22 · LOW 14 · INFO 16

---

## Appendix — DOCX

No dedicated generator exists for this audit file. Optional Word export can follow the pattern in `Docs/generate_main_branch_ux_interaction_accessibility_audit_current_docx.py` if needed later. **Markdown is authoritative.**

---

*Audit performed read-only on `main` @ `3ad40d6`. Algorithmic readiness (separate reports) is higher than UI/UX readiness; combined product readiness requires both passes plus § M physical QA.*
