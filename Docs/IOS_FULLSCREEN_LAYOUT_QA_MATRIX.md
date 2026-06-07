# iOS Fullscreen Layout QA Matrix

Owner: ________  Date: 2026-06-07  Build: ________  Commit: ________

## Scope

Verify iOS Companion MAIN root chrome on cold launch, tab switches, modals, onboarding, and planner result without letterboxing/black bands above/below content.

**Code inspected (no redesign):** `IOSWindowChromeConfigurator`, `DIRBackground`, `ContentView` tab root, `DIRScreenContainer`, scroll surfaces.

## Device / simulator matrix

| Device | Runtime | Cold launch | Tab switch | Modal/sheet | Onboarding | Planner result | Evidence | Status |
|---|---|---|---|---|---|---|---|---|
| iPhone 17 (simulator) | iOS 26.x |  |  |  |  |  | Pending screenshot | **Pending QA** |
| iPhone 17 Pro (simulator) | iOS 26.x |  |  |  |  |  | Pending screenshot | **Pending QA** |
| iPhone 15 Pro | Physical / legacy sim |  |  |  |  |  | Not installed on audit Mac | **Pending manual QA** |
| iPhone 15 Pro Max | Physical / legacy sim |  |  |  |  |  | Not installed on audit Mac | **Pending manual QA** |
| iPhone 14 Pro | Physical / legacy sim |  |  |  |  |  | Not installed on audit Mac | **Pending manual QA** |
| iPhone 14 Pro Max | Physical / legacy sim |  |  |  |  |  | Not installed on audit Mac | **Pending manual QA** |

## Checks per session

- [ ] Status bar / home indicator regions show DIR background, not solid black bands
- [ ] Logbook scroll fills width; cards not clipped horizontally
- [ ] Planner input + result scroll under navigation chrome
- [ ] Legal onboarding pages fill safe area
- [ ] Share sheet / PDF export sheet do not expose broken root layout underneath

## Notes

- Fullscreen chrome fix remains **code-complete**; this matrix documents **visual verification gap**.
- Do **not** claim device-specific black-band resolution without hardware or matching simulator evidence.
