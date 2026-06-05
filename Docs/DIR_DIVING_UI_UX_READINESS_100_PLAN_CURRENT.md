# DIR Diving — UI/UX Readiness 100% Plan

Date: 2026-06-05  
Repository: `egopfe/DirDiving-App`  
Branch: `main`  
Scope: Apple Watch app + iOS Companion app  
Report type: UI/UX readiness plan and remediation roadmap  
Target readiness: 100%

## 1. Executive summary

The current DIR Diving codebase already contains a strong UI/UX foundation for both apps.

Current estimated readiness:

| App | Current readiness | Target readiness | Main blocker |
|---|---:|---:|---|
| Apple Watch app | 90% | 100% | Real-device UX validation, Settings density, Compass validation, accessibility |
| iOS Companion app | 84% | 100% | Fullscreen/adaptive layout, Planner result polish, chart/table readability |
| Shared design system | 86% | 100% | Cross-platform consistency, documentation, screenshot QA |

Top priorities:

1. Fix iOS full-screen/adaptive layout on iPhone 14+ devices.
2. Polish iOS Planner result screen.
3. Validate Apple Watch Settings, Compass, warnings and Mission Mode on real device.
4. Align Watch `DiveUI` and iOS `DIRTheme`.
5. Add a repeatable QA matrix for screenshots, devices and text sizes.

## 2. Apple Watch app — current state

### Strengths

- Dive-first vertical navigation.
- Active-dive navigation restriction.
- Strong dark/neon underwater identity.
- Shared `DiveUI` tokens.
- Improved Watch typography and row heights.
- Live dive screen structurally aligned with glanceability.
- Mission Mode visually integrated.
- Compass, Images and Dive Log available.

### Remaining gaps

| ID | Priority | Area | Issue | Target |
|---|---|---|---|---|
| W-P1-01 | P1 | Settings | Still information-heavy | Scannable, grouped, readable |
| W-P1-02 | P1 | Compass | Cardinal rotation must be validated | N/E/S/W rotate with ring |
| W-P1-03 | P1 | Warnings | Stress readability needs validation | Critical warnings readable |
| W-P2-01 | P2 | Images | Captions may crowd | Readable captions |
| W-P2-02 | P2 | Logbook | Dense detail views | Summary-first layout |
| W-P2-03 | P2 | Accessibility | VoiceOver/Dynamic Type pass needed | Accessible Watch UI |

## 3. iOS Companion app — current state

### Strengths

- Tab structure: Planner, Logbook, Analysis, Gear, More.
- Planner is first tab.
- Planner has safety acknowledgment, gas/cylinder config, MOD validation, warnings.
- Plan result has `plan / curve / charts`.
- Ascent table exists with depth/time/gas/PPO₂.
- Bühlmann chart exists using `store.plan.tissueHistory.groupedPoints`.
- Tissue groups exist: `1-4`, `5-8`, `9-12`, `13-16`.

### Remaining gaps

| ID | Priority | Area | Issue | Target |
|---|---|---|---|---|
| I-P0-01 | P0 | Fullscreen | Black bands on iPhone 15 Pro / 17 Pro sim | Edge-to-edge background |
| I-P1-01 | P1 | Planner result | Too dense / not dashboard-like | Premium dashboard result |
| I-P1-02 | P1 | Bühlmann chart | Exists but may not be discoverable | Clear tab and readable graph |
| I-P1-03 | P1 | Ascent table | Needs premium readable layout | Clear deco table |
| I-P2-01 | P2 | Warnings | Too many disclaimers | Better severity hierarchy |
| I-P2-02 | P2 | Accessibility | Charts/forms need pass | VoiceOver + Dynamic Type |

## 4. Apple Watch development plan to 100%

### Phase W1 — Safety/readability blockers

Target readiness after phase: 94%

Tasks:

- Validate Compass cardinal rotation on real Apple Watch.
- Re-test Watch Settings readability.
- Validate ascent/depth/sensor/GPS warnings.
- Confirm warnings do not hide depth/runtime.

Files:

- `Views/CompassView.swift`
- `Views/SettingsView.swift`
- `Views/DiveLiveView.swift`
- `Views/AscentWarningBannerView.swift`
- `Views/DepthSafetyLiveViews.swift`
- `Views/DiveUIComponents.swift`

### Phase W2 — Navigation/settings/compass polish

Target readiness after phase: 97%

Tasks:

- Reduce Settings cognitive density.
- Move low-value diagnostics into Info/Diagnostics subpage.
- Improve Crown hint and blocked-navigation toast.
- Confirm bearing set/clear flow.

### Phase W3 — Logbook/images/export polish

Target readiness after phase: 99%

Tasks:

- Improve image captions.
- Improve dive detail hierarchy.
- Improve export success/empty/error states.

### Phase W4 — Accessibility/localization polish

Target readiness after phase: 100%

Tasks:

- VoiceOver audit.
- Dynamic Type audit.
- Italian/English string length audit.
- Color-only warning audit.
- Reduced Motion / Mission Mode review.

## 5. iOS Companion development plan to 100%

### Phase I1 — Fullscreen/adaptive root layout

Target readiness after phase: 90%

Tasks:

- Audit `ContentView`, `DIRScreenContainer`, `dirCompanionTabRoot`, `dirCompanionTabSlot`, `dirCompanionScrollSurface`.
- Fix top/bottom black bands.
- Background must ignore safe area.
- Content must respect Dynamic Island, notch and home indicator.
- No device-specific hacks.
- Validate iPhone 14+ sizes.

### Phase I2 — Planner result UX and chart/table polish

Target readiness after phase: 95%

Tasks:

- Refine `PlanResultView` dashboard hierarchy.
- Keep key summary above the fold.
- Polish ascent table columns:
  - Profondità
  - Tempo
  - Gas
  - PPO₂
- Polish Bühlmann chart:
  - confirm `store.plan.tissueHistory.groupedPoints`;
  - improve legend;
  - improve axes;
  - keep Y scale 0–100%;
  - show groups 1–4, 5–8, 9–12, 13–16;
  - add clear empty state.

Files:

- `iOSApp/Views/PlannerView.swift`
- `iOSApp/Services/BuhlmannPlanner.swift`
- `iOSApp/Algorithms/Buhlmann/BuhlmannTissueHistory.swift`
- `iOSApp/Services/PlannerAscentTableBuilder.swift`

### Phase I3 — Logbook, Analysis, Equipment, More polish

Target readiness after phase: 98%

Tasks:

- Logbook: improve list/detail/profile chart.
- Analysis: improve metric hierarchy and empty states.
- Equipment: validate GAS/BAR/PSI conditional UI.
- More: group sync/legal/units/language/developer settings.

### Phase I4 — Accessibility, Dynamic Type, localization

Target readiness after phase: 100%

Tasks:

- VoiceOver labels for charts and tables.
- Dynamic Type QA.
- Keyboard behavior in forms.
- Contrast review.
- Italian/English layout review.

## 6. Shared design system plan

### Phase S1 — Token alignment

- Compare Watch `DiveUI` and iOS `DIRTheme`.
- Align semantic colors:
  - cyan/blue = action/water;
  - green = normal/safe;
  - yellow/orange = caution;
  - red = critical;
  - muted gray = secondary only.

### Phase S2 — Component documentation

Document:

- Watch rows/cards/buttons.
- iOS cards/metric tiles/warnings.
- Planner table pattern.
- Chart pattern.
- Empty state pattern.
- Legal/disclaimer pattern.

### Phase S3 — Screenshot QA matrix

Apple Watch:

- pre-dive live screen;
- active dive live screen;
- compass;
- settings;
- images;
- logbook;
- warnings.

iOS:

- planner input;
- planner result plan tab;
- Bühlmann curve tab;
- charts tab;
- logbook;
- analysis;
- equipment;
- more/settings;
- onboarding/legal.

## 7. Prioritized backlog — Apple Watch

| ID | Priority | Area | Issue | Recommended fix | Effort |
|---|---|---|---|---|---|
| W-01 | P1 | Compass | Cardinal rotation validation | Test/fix `CompassView` | S |
| W-02 | P1 | Settings | High density | Move diagnostics to subpage | M |
| W-03 | P1 | Warnings | Stress readability | QA active warning combinations | M |
| W-04 | P2 | Images | Captions crowd | Short labels/readable rows | S |
| W-05 | P2 | Logbook | Detail density | Summary-first layout | M |
| W-06 | P2 | Accessibility | VoiceOver/Dynamic Type | Add labels/hints and test | M |
| W-07 | P3 | Visual polish | Header/button consistency | Normalize components | S |

## 8. Prioritized backlog — iOS Companion

| ID | Priority | Area | Issue | Recommended fix | Effort |
|---|---|---|---|---|---|
| I-01 | P0 | Root layout | Black bands | Edge-to-edge background | M |
| I-02 | P1 | Planner result | Too dense | Dashboard hierarchy | M |
| I-03 | P1 | Bühlmann chart | Discoverability/readability | Polish tab/legend/axes | M |
| I-04 | P1 | Ascent table | Compact layout | Premium readable table | M |
| I-05 | P2 | Warnings | Cognitive overload | Severity hierarchy | M |
| I-06 | P2 | Equipment | GAS/BAR/PSI validation | Audit conditional UI | S |
| I-07 | P2 | Logbook/Analysis | Secondary charts | Chart polish | M |
| I-08 | P2 | Accessibility | Charts/forms | Labels + Dynamic Type | M |

## 9. Validation commands

```bash
xcodebuild -list
```

Apple Watch:

```bash
xcodebuild -scheme "DIRDiving Watch App" -destination 'platform=watchOS Simulator,name=Apple Watch Ultra 2 (49mm)' build
xcodebuild -scheme "DIRDiving Watch App" -destination 'platform=watchOS Simulator,name=Apple Watch Ultra 2 (49mm)' test
```

iOS:

```bash
xcodebuild -scheme "DIRDiving iOS" -destination 'platform=iOS Simulator,name=iPhone 15 Pro' build
xcodebuild -scheme "DIRDiving iOS" -destination 'platform=iOS Simulator,name=iPhone 15 Pro' test
xcodebuild -scheme "DIRDiving iOS" -destination 'platform=iOS Simulator,name=iPhone 15 Pro Max' build
xcodebuild -scheme "DIRDiving iOS" -destination 'platform=iOS Simulator,name=iPhone 14 Pro' build
xcodebuild -scheme "DIRDiving iOS" -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build
```

## 10. Manual QA matrix

### Apple Watch

| Scenario | Required result |
|---|---|
| Pre-dive Live | Start dive visible |
| Active dive Live | Depth/runtime/warnings visible |
| Mission Mode ON | Reduced animation and clear status |
| Compass | Degrees update and N/E/S/W rotate |
| Settings | Readable rows |
| Images | Captions readable |
| Logbook | Summary readable |
| Warnings | Not color-only |
| Larger text | Scrolls, no overlap |

### iOS

| Scenario | Required result |
|---|---|
| iPhone 15 Pro | No black top/bottom bands |
| iPhone 17 Pro simulator | No letterboxing |
| Planner input | Readable form |
| Plan tab | Summary + ascent table clear |
| Curva Bühlmann | Tissue chart visible |
| Grafici | Depth/timeline charts readable |
| Equipment | GAS/BAR/PSI conditional UI correct |
| Logbook | List/detail/profile readable |
| Analysis | Metrics readable |
| More/Settings | Well grouped |
| VoiceOver | Useful chart/table summaries |

## 11. Final verdict

The app is close to strong internal testing readiness, but not yet at 100% UI/UX readiness.

Current estimate:

- Apple Watch app: 90%
- iOS Companion app: 84%
- Shared design system: 86%

Fastest path to 100%:

1. Fix iOS fullscreen/adaptive layout.
2. Polish Planner result/dashboard, ascent table and Bühlmann chart visibility.
3. Finalize Watch compass/settings/warning validation.
4. Complete accessibility and localization QA.
5. Document shared UI rules and screenshot QA matrix.
