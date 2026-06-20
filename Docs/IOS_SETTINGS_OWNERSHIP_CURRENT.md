# iOS Settings Ownership — CURRENT

## Canonical shared settings

`SharedIOSSettingsStore` is the single write path for cross-activity preferences:

| Setting | Storage key | Diving UI | Apnea UI | Snorkeling UI |
|---|---|---|---|---|
| Language | `DIRIOSAppLanguage.storageKey` | `MoreView` | `IOSCompanionSharedSettingsSection` | `IOSCompanionSharedSettingsSection` |
| Depth units | `dirdiving_ios_units` | `MoreView` | shared section | shared section |
| Pressure units | `IOSPressureUnitPreference.storageKey` | `MoreView` | shared section (optional) | shared section |
| Diving cloud backup | `CloudBackupSettings.enabledKey` | `MoreView` | — | — |

## Activity-isolated settings

- **Diving-only:** GF, ascent speeds, CNS descent/bottom, planner safety — `MoreView` / `PlannerAscentSpeedSettingsStore`
- **Apnea-only:** `IOSApneaSettingsStore` / `dirdiving_ios_apnea_settings_v1`
- **Snorkeling-only:** `IOSSnorkelingSettingsStore` / snorkeling namespace

## Migration (IOS-ALG-006)

`MoreView` no longer uses duplicate `@AppStorage` bindings; it reads/writes via `@EnvironmentObject SharedIOSSettingsStore`.

## Tests

- `IOSActivitySettingsCoherenceTests`
- `PlannerPressureUnitPreferenceTests` (MoreView source wiring)
