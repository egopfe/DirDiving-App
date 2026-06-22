# iOS Companion Settings Mode Switch

`IOSCompanionSettingsScopeStore` holds `displayedMode` for Settings UI only.

Surfaces:
- `MoreView` (Settings tab) — mode switcher + embeddable activity content below
- `IOSCompanionSettingsRootView` (Apnea/Snorkeling/Diving sheets)

Activity content:
- `IOSDivingSettingsEmbeddedContent`
- `IOSApneaSettingsContent` (DIRCard sections, not nested Form)
- `IOSSnorkelingSettingsContent` (DIRCard sections, not nested Form)

Does **not** call `CompanionActivityPreferenceStore.select(_:)` or mutate Watch runtime.
