# DIR DIVING Watch UI Text Visibility Audit - Current

Date: 2026-06-04  
Branch audited: `main`  
Target audited: `DIRDiving Watch App` only  
Audit mode: static SwiftUI inspection, report-only  
Benchmark: Oceanic+-style dive glanceability, Garmin Descent-style readability, Apple watchOS-native density/readability principles

## 1. Executive Summary

Overall Apple Watch UI text/readability readiness: 78%

The user-reported Settings issue is confirmed. `SettingsView` uses a dense scroll layout with many rows, 9-11 pt text, 8 pt informational badges, 10 pt subtitles, 35-38 pt row minimum heights, and multiple `minimumScaleFactor` values. On a real Apple Watch this is very likely to feel small, especially in underwater/stress contexts or with larger text settings.

The issue is not limited to Settings, but it is strongest there. The main Live Dive screen is much more coherent with the premium underwater benchmark because the primary depth value, runtime/TTV, stopwatch, and controls use strong hierarchy and large values. Similar small-text risks appear in secondary/detail surfaces: Dive Detail GPS rows, log rows, Compass in-dive mini metrics, Info diagnostics, User Images captions, shortcut help, and legal/settings copy.

Main risks:
- P1: Settings is too dense and uses micro-text for multiple user-facing rows.
- P1: Some safety/warning labels use 10-11 pt text with scaling rather than true larger hierarchy.
- P2: Secondary Watch screens rely heavily on 9-10 pt labels, which is fragile on-device.
- P2: Several controls are 31-36 pt tall, usable but below the best glove-friendly target for important actions.
- P2: `minimumScaleFactor` is used as a layout pressure valve in many places, which can create visually compressed text on real hardware.

No P0 visual blockers were found in the static inspection. The primary Dive screen remains readable and aligned with the premium black/neon design language, but Settings and secondary screens need a Watch-native text pass before the next real-device test.

Build/tests: not run. This was a report-only static UI/UX audit and no code changes were required or allowed.

## 2. Scope Confirmed

Included in Watch MAIN target according to `project.yml`:
- `Views/ContentView.swift`
- `Views/ModeSelectionView.swift` only if multiple stable modes are enabled
- `Views/DiveLiveView.swift`
- `Views/CompassView.swift`
- `Views/SettingsView.swift`
- `Views/UserImagesView.swift`
- `Views/DiveLogListView.swift`
- `Views/DiveDetailView.swift`
- `Views/ExportView.swift`
- `Views/InfoView.swift`
- `Views/DeveloperSettingsView.swift`
- `Views/AlarmSettingsView.swift`
- `Views/AscentRateSettingsView.swift`
- `Views/WatchLegalOnboardingView.swift`
- `Views/AscentGaugeView.swift`
- `Views/AscentWarningBannerView.swift`
- `Views/DepthSafetyLiveViews.swift`
- shared visual components in `Views/DiveUIComponents.swift`

Excluded from Watch MAIN runtime by `project.yml` and not treated as stable MAIN UI:
- `Views/ApneaView.swift`
- `Views/SnorkelingView.swift`
- `Views/BuddyAssistView.swift`
- `Views/ExperimentalConceptsView.swift`

## 3. Screen-by-Screen Audit

### Home / Mode Selection

Files/components:
- `Views/ContentView.swift`
- `Views/ModeSelectionView.swift`
- `Views/DiveUIComponents.swift`

Current status: mostly acceptable, but normally hidden in MAIN because `WatchModeSelectionPreferences.hasMultipleStableModes` gates the page.

Typography findings:
- Header uses shared `DiveScreenHeader`, with `caption.bold()` title and 9 pt subtitle.
- Selector hero uses 17 pt title and 10 pt subtitle.
- Stable mode card uses 15 pt title and 10 pt description.

Visibility findings:
- The hero card is readable enough.
- The experimental notice is 10 pt and could be borderline if this screen becomes user-facing again.

Color/contrast findings:
- Black background, cyan/yellow accents, and white text are coherent.
- Secondary text uses `DiveUI.secondaryText` at 70% white opacity; acceptable for helper copy but not for essential instructions.

UX fluidity findings:
- Uses `ScrollView`; safe for small screens.
- No immediate overlap risk found.

Severity: P3  
Recommended fix:
- If Mode Selection becomes visible again, raise secondary text from 10 pt to 11-12 pt and keep only one short helper sentence per card.

### Live Dive Screen

Files/components:
- `Views/DiveLiveView.swift`
- `Views/AscentGaugeView.swift`
- `Views/AscentWarningBannerView.swift`
- `Views/DepthSafetyLiveViews.swift`
- `Views/MissionModeIndicatorView.swift`
- `Views/DiveUIComponents.swift`

Current status: strongest screen in the app; aligned with the premium underwater benchmark.

Typography findings:
- Main depth uses `DiveUI.Typography.metricValueHero` at 72 pt and unit at 31 pt.
- TTV/runtime panel uses 13 pt labels and 34 pt values.
- Stopwatch uses 39 pt value and 13 pt label.
- Depth summary cards use 10 pt labels, 25 pt values, and 12 pt units.
- Ascent gauge uses 9-10 pt labels.
- GPS and sync compact banners use 9-10 pt details.
- Generic warning banners use `.caption2.bold()`.

Visibility findings:
- Depth is clearly dominant and glanceable.
- Runtime/TTV and stopwatch are readable.
- When many banners are active, spacing compresses from 7 pt to 3 pt, which may increase density during stress.
- Active dive content scrolls, so some lower content can move off-screen when several warnings are active.
- The ascent gauge label area is compact, but still visually recognizable because color and bar geometry carry the message.

Color/contrast findings:
- Strong black/neon palette is coherent.
- Red/yellow/green safety colors are clear.
- Some warning states rely heavily on color but also use icons/text, so not color-only.

UX fluidity findings:
- `ScrollView` prevents clipping but may reduce glanceability when warning count is high.
- Live values use monospaced digits in key places, reducing jitter.
- Animations are disabled or softened by Mission Mode profile, which supports underwater stability.

Severity: P2  
Recommended fix:
- Keep the primary hierarchy intact.
- Raise compact warning/GPS text to at least 11 pt where possible.
- Ensure depth, runtime, ascent gauge, and active warnings remain visible without scrolling on the largest supported Watch Ultra display during active dive states.

### Settings

Files/components:
- `Views/SettingsView.swift`
- `Views/AlarmSettingsView.swift`
- `Views/AscentRateSettingsView.swift`
- `Views/DeveloperSettingsView.swift`
- `Views/InfoView.swift`
- `Views/WatchLegalOnboardingView.swift`
- `Utils/WatchDetailBackButton.swift`
- `Utils/WatchSubscreenBackToolbar.swift`

Current status: user-reported issue confirmed.

Typography findings:
- Main section title uses `DiveUI.Typography.settingsSection` at 10 pt.
- `settingsRow` title uses 11 pt semibold.
- `settingsRow` subtitle uses 10 pt regular/medium.
- Informational badge uses 8 pt.
- Language/unit notes use 9 pt.
- Mission Mode explanatory text uses repeated 9 pt lines.
- Sync activity section title and details use 9-10 pt.
- Shortcut help title/body uses 12/10 pt.
- Back affordance uses 10 pt label and 11 pt chevron.

Visibility findings:
- Rows are dense: `settingsRow` minimum height is 35 pt or 38 pt for informational rows.
- The screen contains many rows, many informational labels, and multiple status sections, which makes the Settings page feel like a compressed iPhone list.
- Long localized Italian strings can truncate or scale down, especially sync statuses and Mission Mode explanations.
- `minimumScaleFactor(0.68)` on subtitles means text may shrink below a comfortable watchOS reading size.
- Toggle rows have 11/10 pt text next to native switches; the text column can become cramped.

Color/contrast findings:
- Contrast is generally high.
- Informational rows are intentionally dimmer with lower stroke opacity and 0.88 opacity, but that worsens readability for already small text.
- Disabled/informational states risk looking less readable than necessary on OLED in bright conditions.

UX fluidity findings:
- Scrolling is necessary and expected.
- Tap targets are usable but compact for Settings: 35-38 pt rows are below an ideal large Watch-native row target.
- Multiple settings look informational rather than actionable, but visual density makes it hard to parse quickly.

Severity: P1  
Recommended fix:
- Redesign Settings typography only, not logic: 13-14 pt row titles, 11-12 pt subtitles, 44 pt minimum interactive rows, 40 pt minimum informational rows.
- Remove 8 pt badges or replace them with icon-only/status color affordances.
- Split Settings into clearer grouped subsections: Safety, Units/Language, Sync, Hardware, Legal, Advanced.
- Promote important status values into larger two-line cards.
- Reduce explanatory copy on Watch; keep long text in Legal/Info detail screens.

### Alarm Settings

Files/components:
- `Views/AlarmSettingsView.swift`

Current status: readable but still compact.

Typography findings:
- Header title 10 pt; explanatory scope note 9 pt.
- Alarm row title 11 pt, threshold 10 pt.
- Stepper title 10 pt, value 12 pt.
- +/- buttons are 40 x 34 pt.

Visibility findings:
- Controls are clearer than Settings main because rows are fewer and structured.
- 9 pt scope text is small and should not contain essential safety information.

Color/contrast findings:
- Green/yellow/red threshold colors are coherent.

UX fluidity findings:
- Digital Crown support for threshold steppers is good Watch-native behavior.
- Plus/minus controls are reasonably large but could be taller.

Severity: P2  
Recommended fix:
- Raise note text to 10.5-11 pt and title to 12 pt.
- Increase row height to 44 pt where switches are present.

### Ascent Rate Settings

Files/components:
- `Views/AscentRateSettingsView.swift`

Current status: visually stronger than Settings main.

Typography findings:
- Depth band title 11 pt.
- Main speed value 32 pt.
- Unit uses `.caption2.bold()`.
- Step buttons use `.headline.bold()`.

Visibility findings:
- Main values are readable and premium.
- Unit labels are small but acceptable because values are dominant.

Color/contrast findings:
- Band colors red/orange/yellow/green/blue match ascent semantics.

UX fluidity findings:
- Digital Crown rotation support is strong.
- Layout is simple enough for real Watch use.

Severity: P3  
Recommended fix:
- Minor: use 12 pt band titles and avoid `.caption2` units if localization expands.

### Compass / Bearing

Files/components:
- `Views/CompassView.swift`

Current status: good primary compass hierarchy with compact secondary data.

Typography findings:
- Heading uses 36 pt, cardinal 17 pt, degree symbol 18 pt.
- Status banner uses 9 pt.
- In-dive metric title uses 8 pt, value 20 pt, unit 9 pt.
- Bearing delta and button labels use 10-11 pt.

Visibility findings:
- Compass heading is clear.
- In-dive depth/runtime mini metrics are small; title labels at 8 pt are micro-text.
- Buttons are 31 pt high, acceptable in calm use but below ideal glove-friendly action height.

Color/contrast findings:
- Strong red N marker, white cardinal markers, and green/cardinal status are clear.
- Disabled clear bearing uses white opacity 0.34, which may be low contrast but semantically disabled.

UX fluidity findings:
- Animations may be visually smooth but could be excessive if compass updates jitter; Mission Mode disables some animation.
- No obvious overlap risk.

Severity: P2  
Recommended fix:
- Raise in-dive metric labels from 8 pt to 10-11 pt.
- Raise action button minimum height to at least 36-40 pt.
- Keep the 36 pt heading as the dominant object.

### Image Viewer / Pre-Dive Images

Files/components:
- `Views/UserImagesView.swift`

Current status: usable but captions are compact.

Typography findings:
- List title 11 pt.
- Row label 11 pt and caption 10 pt with `minimumScaleFactor(0.65)`.
- Empty state title/body 12/10 pt.
- Detail caption 10 pt with scaling; back/list button 9 pt.

Visibility findings:
- Image detail reserves up to 168 pt, good for visual inspection.
- Captions can become too small if file-derived names are long.
- The bottom "list" button at 9 pt is small.

Color/contrast findings:
- Cyan/yellow accents and black background are coherent.

UX fluidity findings:
- Uses local image loading directly in view; large images could affect responsiveness, but no source change is allowed here.
- Tap gesture on rows is okay but less button-like than native Watch controls.

Severity: P2  
Recommended fix:
- Keep image area large.
- Raise row/caption text to 11-12 pt and use visible button affordance for rows.
- Keep captions short or derive user-friendly display names.

### Logs / Last Dive / Dive Detail

Files/components:
- `Views/DiveLogListView.swift`
- `Views/DiveDetailView.swift`
- `Views/ExportView.swift`

Current status: useful, but dense details contain micro-text.

Typography findings:
- Logbook title 13 pt.
- Empty state title/body/status 12/10/9 pt.
- Log rows use 10 pt date/time, 14 pt depth, 13 pt duration.
- Dive detail summary labels use 7 pt, values 18 pt.
- GPS row title/status uses 9/8 pt, coordinate line 10 pt with `minimumScaleFactor(0.58)`.
- Export completion has 62 pt icon, 16 pt title, 12 pt details.

Visibility findings:
- Log rows are readable for common values.
- Dive detail summary labels at 7 pt are too small.
- Coordinates can shrink aggressively and become unreadable.
- Delete/export actions are visible, but some labels are 9-10 pt.

Color/contrast findings:
- Good use of green/export, red/delete, blue/share, yellow warning.

UX fluidity findings:
- NavigationLink rows and separate trash buttons can be tight in the same row.
- Export completion screen is clear and uncluttered.

Severity: P2  
Recommended fix:
- Raise detail metric labels from 7 pt to at least 9.5-10 pt.
- Replace full coordinate micro-lines with shorter status-first text on Watch, leaving full coordinate detail to export/iPhone.
- Increase row heights in Dive Detail GPS and log action rows.

### Info / Battery / Diagnostics

Files/components:
- `Views/InfoView.swift`

Current status: functional but dense.

Typography findings:
- Row title/value 11 pt.
- Low Power detail 10 pt and note 9 pt.
- Diagnostics use 10 pt labels/values and 9 pt note.

Visibility findings:
- Information is readable in calm conditions.
- Diagnostic rows are dense and include technical wording that can feel developer-oriented on a Watch.

Color/contrast findings:
- Battery bar uses green/yellow/red correctly.
- Secondary notes at 70% opacity are acceptable but small.

UX fluidity findings:
- ScrollView handles density.
- Developer unlock via tapping version is visually hidden by design; no issue for normal users.

Severity: P2  
Recommended fix:
- Raise diagnostics note to 10.5-11 pt.
- Use larger status cards for battery, depth entitlement, and sensor status.

### Legal Onboarding / Legal & Safety

Files/components:
- `Views/WatchLegalOnboardingView.swift`
- `Utils/LegalDisclaimerScrollGate.swift`

Current status: legally complete but text-heavy for Watch.

Typography findings:
- Welcome title/body 17/12 pt.
- Safety title 16 pt; warning rows 11 pt.
- Full disclaimer in onboarding uses 11 pt inside a 118 pt scroll gate.
- Legal & Safety full disclaimer uses 10 pt.
- Acceptance toggles use 11 pt.

Visibility findings:
- Safety warning is readable enough.
- Long legal disclaimer is necessarily dense; 10 pt in Settings Legal view is small but acceptable only because it is not an underwater operational screen.
- Acceptance checkbox text can wrap; hit area is padded 6 pt, usable but could be taller.

Color/contrast findings:
- Red/yellow/green semantic colors are strong.

UX fluidity findings:
- Scroll gate prevents bypass and is appropriate.
- Long text on Watch is inherently less fluid; keep as legal reference, not daily-use screen.

Severity: P2  
Recommended fix:
- Keep legal flow, but raise full disclaimer text to 11 pt minimum everywhere and use larger section titles.
- Consider shorter Watch summary plus full text on iPhone/GitHub, while preserving mandatory acceptance.

### Warning Banners / Safety Visuals

Files/components:
- `Views/AscentWarningBannerView.swift`
- `Views/DepthSafetyLiveViews.swift`
- `Views/DiveLiveView.swift`
- `Views/DiveUIComponents.swift`

Current status: visually coherent but compact.

Typography findings:
- Ascent warning title uses shared 11 pt.
- Ascent speed/instruction use 10 pt.
- Depth safety title/subtitle use 11/10 pt.
- Generic warning banner uses `.caption2.bold()`.

Visibility findings:
- Strong color, icon, and border make warnings noticeable.
- Text itself is compact for real-world diving stress.
- Active dive warnings are inline and non-blocking, which matches product safety philosophy.

Color/contrast findings:
- Red/yellow/orange semantics are consistent.
- Critical states do not rely only on color because icons/text are present.

UX fluidity findings:
- Inline banners preserve live metrics.
- Too many simultaneous banners can force scrolling.

Severity: P1 for critical warning text size, P2 for layout density  
Recommended fix:
- Use 12-13 pt warning title and 11 pt body/instruction.
- Reserve a fixed warning area that does not hide depth/runtime/ascent gauge.

## 4. Settings Deep Dive

The Settings small-text issue is confirmed.

Specific current problems:
- Section header at 10 pt does not create enough hierarchy.
- Row title at 11 pt and subtitle at 10 pt are marginal on real Watch hardware.
- Informational badge at 8 pt is micro-text.
- Informational rows have lower opacity and smaller perceived contrast.
- Row minimum heights of 35-38 pt create a dense list with many rows.
- Long localized Italian strings are likely to wrap, truncate, or scale down.
- `minimumScaleFactor(0.68)` means already-small 10 pt subtitles can visually compress to about 6.8 pt.
- Mission Mode and sync sections contain too much explanatory copy for a single Watch Settings page.
- Picker sections for language/units add 9 pt notes around native wheel pickers.
- Toggle rows visually compete with text because the switch consumes horizontal space.

Suggested target hierarchy:
- Screen title: 14-16 pt bold/black.
- Group heading: 12-13 pt semibold.
- Row title: 13-14 pt semibold/black.
- Row subtitle: 11-12 pt medium, max 2 lines.
- Status value: 12-14 pt, color-coded and visually separate.
- Informational badge: icon-only or 10-11 pt minimum if text remains.
- Interactive row height: 44 pt minimum.
- Informational row height: 40 pt minimum.
- Critical/legal/safety row: 44-50 pt minimum.

Recommended Settings remediation:
1. Create Watch-native grouped settings cards: Safety, Dive Limits, Units & Language, Sync, Hardware, Legal, Advanced.
2. Promote current `settingsRow` typography from 11/10 pt to 13/11.5 pt.
3. Remove or enlarge the 8 pt `INFO` badge.
4. Reduce low-value explanatory copy; move long copy to Info/Legal detail screens.
5. Increase row minimum heights and vertical spacing.
6. Keep the current premium black/neon visual language, but let rows breathe more.

## 5. Typography Inventory

Shared typography in `Views/DiveUIComponents.swift`:
- `brandTitle`: 15 pt black rounded.
- `brandTitleCompact`: 11 pt black rounded.
- `clock`: 14 pt semibold rounded.
- `clockLarge`: 20 pt semibold rounded.
- `metricLabel`: 9 pt bold rounded.
- `metricValue`: 24 pt regular rounded.
- `metricValueHero`: 72 pt black rounded.
- `metricUnitHero`: 31 pt black rounded.
- `metricUnit`: `.caption2.bold()`.
- `dashboardLabel`: 13 pt semibold rounded.
- `dashboardValue`: 34 pt black rounded.
- `dashboardUnit`: 12 pt semibold rounded.
- `depthCaption`: 15 pt black rounded.
- `statusTitle`: 15 pt black rounded.
- `bannerTitle`: 11 pt black rounded.
- `bannerSubtitle`: 10 pt bold rounded.
- `bannerDetail`: 9 pt semibold rounded.
- `settingsSection`: 10 pt semibold rounded.
- `commandButton`: `.caption.bold()`.
- `readyTitle`: 18 pt black rounded.

Fixed font sizes found:
- Very large: 72, 62, 39, 36, 35, 34, 32, 31, 25, 24 pt.
- Medium: 20, 18, 17, 16, 15, 14, 13, 12 pt.
- Small/micro: 11, 10, 9, 8, 7 pt.

`.caption2` / `.caption` / `.footnote` usage:
- `.caption2.bold()` appears in sync strip, warning acknowledgement, metric units, and some excluded experimental files.
- `.caption.bold()` is used for command buttons and headers.
- `.footnote` was not found in the audited stable Watch files.

`.minimumScaleFactor` usage:
- Used across `DiveLiveView`, `DiveUIComponents`, `CompassView`, `DiveDetailView`, `DiveLogListView`, `UserImagesView`, `SettingsView`, `AlarmSettingsView`, `AscentGaugeView`, `AscentWarningBannerView`, `DepthSafetyLiveViews`, and `ModeSelectionView`.
- The most concerning values are:
  - `0.42` on the 72 pt depth hero, acceptable as overflow protection for large values.
  - `0.54` on dashboard values, acceptable but should be visually tested.
  - `0.58` on GPS coordinates in Dive Detail, high readability risk.
  - `0.62-0.68` on small labels/subtitles, high risk because the base text is already small.

Text hierarchy inconsistencies:
- Live Dive has a clear hierarchy.
- Settings and secondary screens compress many concepts into 9-11 pt rows.
- Detail cards use 7-8 pt labels in places, which breaks the premium readability standard.

## 6. Color and Contrast Inventory

Core palette in `DiveUI`:
- Background: black to near-black marine gradient.
- Primary accent blue: RGB 0.00, 0.56, 1.00.
- Cyan: RGB 0.02, 0.92, 0.96.
- Green: RGB 0.16, 0.90, 0.36.
- Yellow: RGB 1.00, 0.84, 0.04.
- Red: RGB 1.00, 0.22, 0.18.
- Orange: RGB 1.00, 0.56, 0.00.
- Primary text: white.
- Secondary text: white at 70% opacity.
- Muted text: white at 52% opacity.
- Hairline/strokes: white at 16-28% opacity.
- Alarm fill: very dark red.
- Alarm text: white at 96% opacity.

Contrast concerns:
- Primary text on black is strong.
- Yellow/green/cyan/red on black is coherent and premium.
- `mutedText` at 52% opacity is weak for any essential copy.
- Disabled text at 34-42% white opacity is expected but should not be used for critical states.
- Informational settings rows use lower opacity and can become visually weak because text is already small.

Warning colors:
- Green: normal/near/success.
- Yellow: caution/fallback/haptics disabled/manual caveat.
- Orange: critical depth progression.
- Red: stop/delete/exceeded/critical warnings.

Color-only risk:
- Most critical states include icons/text, not color alone.
- Some status rows depend heavily on icon color plus small text; this is acceptable for secondary status but not for critical dive warnings.

## 7. UX Fluidity Assessment

Navigation:
- MAIN runtime is vertical-page `TabView`: Live, Compass, Settings, User Images, Dive Log.
- During active dive, navigation is restricted to Live and Compass, which supports underwater safety.
- Back affordance exists in pushed subviews through `WatchDetailBackButton` and `watchSubscreenBackToolbar`.

Scroll:
- Live Dive active content scrolls, preventing clipping but allowing secondary controls to move off-screen.
- Settings, Info, Logs, Legal, and sub-settings rely heavily on ScrollView.
- Dense Settings content can feel slow to scan on real Watch hardware.

Touch targets:
- `DiveCommandButton` min height is 36 pt.
- Compass action buttons are 31 pt.
- Settings row min heights are 35/38 pt.
- Alarm stepper buttons are 40 x 34 pt.
- These are generally usable but below an ideal glove-friendly target for important controls.

Potential performance issues:
- User image detail loads local images in SwiftUI view (`UIImage(contentsOfFile:)` for absolute paths), which could stutter if images are large.
- Live view uses frequent updates and several animations, but Mission Mode can suppress decorative effects.
- No obvious heavy computation in view code was found during this visual audit.

Live value update risks:
- Key values use monospaced digits in several places, reducing jitter.
- Depth hero has aggressive scale fallback, so extreme values may shrink rather than wrap.
- Multiple banners can alter spacing and scroll position during active dives.

## 8. Benchmark Comparison

### Oceanic+-style Apple Watch dive UI principles

DIR Diving matches:
- Black background.
- Large central depth.
- High contrast.
- Clear warning colors.
- Non-blocking warnings.

DIR Diving diverges:
- Settings is denser than expected for a Watch-first diving interface.
- Several secondary labels are micro-text.
- Some operational warnings use compact banner text that should be larger under stress.

### Garmin Descent-style readability principles

DIR Diving matches:
- Primary metric dominance on the dive screen.
- Strong color coding for ascent/depth safety.
- Clear separation of primary and secondary dive metrics.

DIR Diving diverges:
- Secondary data screens present many details at once.
- Logs/details use coordinate strings and labels that are too dense for quick wrist reading.
- Settings should favor fewer, larger rows.

### Apple watchOS native readability principles

DIR Diving matches:
- Uses ScrollView for overflow.
- Uses native toggles and wheel pickers.
- Provides back affordances in pushed screens.
- Uses high contrast and large key controls in the main screen.

DIR Diving diverges:
- Many rows are below the ideal perceived row height.
- 8-10 pt text appears in user-facing settings and detail screens.
- Heavy reliance on fixed fonts and `minimumScaleFactor` limits Dynamic Type friendliness.

## 9. Prioritized Remediation Plan

### P0 - Must fix before real-world testing

No P0 visual/readability blockers found in static inspection. The main Live Dive screen remains readable enough for controlled real-device testing.

### P1 - Should fix before next TestFlight/internal testing

1. Restyle Settings typography and row density.
   - Files: `Views/SettingsView.swift`, `Views/DiveUIComponents.swift`.
   - Raise Settings row title/subtitle sizes and minimum row heights.

2. Increase critical warning text hierarchy.
   - Files: `Views/AscentWarningBannerView.swift`, `Views/DepthSafetyLiveViews.swift`, `Views/DiveLiveView.swift`.
   - Keep inline warnings but make warning title/body more readable.

3. Reduce Settings copy density.
   - Files: `Views/SettingsView.swift`, `Views/InfoView.swift`, `Views/WatchLegalOnboardingView.swift`.
   - Move long explanatory copy into grouped detail screens; preserve all legal/safety copy.

### P2 - Improve for polish

4. Enlarge secondary screen labels.
   - Files: `Views/DiveDetailView.swift`, `Views\DiveLogListView.swift`, `Views\CompassView.swift`, `Views\UserImagesView.swift`, `Views\InfoView.swift`.
   - Eliminate 7-8 pt labels and reduce aggressive scale factors.

5. Improve tap target consistency.
   - Files: `Views/DiveUIComponents.swift`, `Views\CompassView.swift`, `Views\SettingsView.swift`, `Views\AlarmSettingsView.swift`.
   - Move important buttons toward 40-44 pt minimum height.

6. Make coordinate/log details Watch-native.
   - Files: `Views/DiveDetailView.swift`, `Views\DiveLogListView.swift`.
   - Shorten visible coordinate text or show confidence/status first.

### P3 - Optional refinements

7. Normalize header sizes across secondary screens.
8. Reduce decorative strokes where they crowd text.
9. Audit all localized Italian strings for Watch length.
10. Add a future visual QA matrix for default, large, and accessibility text sizes on Apple Watch Ultra.

## 10. Acceptance Criteria for Future Fix Task

A future fix can be considered successful when:
- Settings text is readable at arm's length on real Apple Watch Ultra.
- No Settings row uses micro-text below an effective 10.5-11 pt visual size.
- Interactive Settings rows are at least 44 pt tall unless intentionally compact and non-critical.
- Informational rows are at least 40 pt tall.
- Critical warning title/body text is not clipped and remains readable during active dive.
- Primary dive depth remains visually dominant.
- Runtime, TTV, ascent gauge, and active warning are visible without losing critical hierarchy.
- No critical label relies only on color.
- No important text is hidden at default Watch text size.
- Larger accessibility text sizes degrade gracefully by scrolling rather than clipping/overlap.
- No user-facing label uses `minimumScaleFactor` to shrink below a readable size.
- Compass heading remains 36 pt or larger equivalent.
- Dive Detail no longer uses 7-8 pt labels for operational values.
- User Images captions and back/list controls are readable without aggressive scaling.

## 11. No-Code-Change Confirmation

Confirmed:
- No source code files were changed.
- No SwiftUI files were changed.
- No assets were changed.
- No logic was changed.
- No iOS Companion files were changed.
- No Apple Watch files were changed.
- Only this audit report file was created/updated: `DIR_DIVING_WATCH_UI_TEXT_VISIBILITY_AUDIT_CURRENT.md`.

## 12. Final Verdict

Settings small-text issue confirmed: yes.  
Issue isolated: no, but strongest in Settings and secondary/detail screens.  
Primary Live Dive readability: strong.  
Overall Watch text/visibility readiness: 78%.  
Recommended next action: perform a strict UI-only typography and spacing remediation pass focused first on Settings, then warning banners, then secondary detail screens.
