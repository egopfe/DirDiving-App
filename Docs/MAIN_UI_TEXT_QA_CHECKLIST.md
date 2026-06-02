# MAIN UI Text — Manual QA Checklist

Use after code remediation on `main`. Simulator/device required.

## Watch (41 / 45 / 49 mm)

- [ ] Live Dive: depth, runtime, TTV, ascent gauge visible with mission + sync + GPS banners
- [ ] Ascent gauge title readable (single/two-line localized label)
- [ ] Settings: informational rows show INFO badge, no false “button” affordance
- [ ] Settings → Export opens Logbook (copy says open logbook to export)
- [ ] IT locale: Settings, Live, Alarms in Italian
- [ ] EN locale: same screens in English
- [ ] Shortcuts: intent titles localized when Watch language is IT
- [ ] VoiceOver: Live depth, stopwatch, log row, Mission Mode toggle

## iOS

- [ ] Legal onboarding IT: “Companion iOS”, exit alert IT
- [ ] Legal step VoiceOver: “Passaggio X di 4”
- [ ] Planner Bühlmann tab: chart summary mentions reference-only NDL
- [ ] More footer readable; IT/EN via `more.safety.footer`
- [ ] Dynamic Type Large: Planner fields do not overlap
- [ ] VoiceOver: logbook demo badge, dive detail tabs

## Reference assets

- [ ] Capture screenshots to `Docs/ReferenceUI/` per `Docs/ReferenceUI/README.md`
