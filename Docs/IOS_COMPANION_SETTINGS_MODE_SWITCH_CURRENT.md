# iOS Companion Settings Mode Switch

`IOSCompanionSettingsScopeStore` holds `displayedMode` for Settings UI only.

Surfaces:
- `MoreView` (Diving tab)
- `IOSCompanionSettingsRootView` (Apnea/Snorkeling sheets)

Does **not** call `CompanionActivityPreferenceStore.select(_:)` or mutate Watch runtime.
