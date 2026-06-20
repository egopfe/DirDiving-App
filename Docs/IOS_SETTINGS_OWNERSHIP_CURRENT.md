# iOS Settings Ownership (Current)

**Updated:** 2026-06-20  
**Branch:** `main` (post-remediation, uncommitted)

---

## Canonical naming map

| Audit / spec name | Implementation | Namespace / key |
|-------------------|----------------|-----------------|
| SharedSettingsStore | `SharedIOSSettingsStore` | `dirdiving.settings.shared.v1` |
| DivingSettingsStore | `IOSDivingSettingsStore` (facade) | `dirdiving.settings.diving.v1` |
| ApneaSettingsStore | `IOSApneaSettingsStore` | `dirdiving_ios_apnea_settings_v1` |
| SnorkelingSettingsStore | `IOSSnorkelingSettingsStore` | `dirdiving.settings.snorkeling.v1` |

Authoritative map: `iOSApp/Utils/ActivitySettingsNamingMap.swift`  
Registry: `iOSApp/Utils/ActivitySettingsVisibility.swift`

---

## Environment layers (iOS Companion)

```text
applyGlobalEnvironment
  → watchSync, cloudSync, legalAcceptance, companionActivity, sharedSettings

applyDivingEnvironment (= applySharedEnvironment alias)
  → global + logStore, plannerStore, equipmentStore, navigationStore,
     plannerAscentSpeedSettingsStore, divingSettingsStore, plannerBriefingTransfer,
     divePlanPackageTransfer

applyApneaEnvironment
  → global + IOSApneaStoreBundle (no DiveLogStore)

applySnorkelingEnvironment
  → global + IOSSnorkelingStoreBundle (no DiveLogStore)
```

---

## Diving settings facade

`IOSDivingSettingsStore` is a **non-duplicating facade** over:

- `SharedIOSSettingsStore` (language, units — also surfaced in Apnea/Snorkeling shared section)
- `PlannerAscentSpeedSettingsStore` (planner ascent speeds)

Additional diving-only keys remain in canonical sub-stores (`MoreView` @AppStorage, `PlannerCNSDescentBottomCheckSettings`, pressure unit keys). All are registered in `ActivitySettingsVisibility`.

---

## Negative exposure policy (verified in tests)

| Setting class | Diving | Apnea | Snorkeling |
|---------------|--------|-------|------------|
| GF / PPO2 / CNS / gas / deco | Yes | No | No |
| Apnea recovery / detection | No | Yes | No |
| Snorkeling GPS / route / return | No | No | Yes |

Tests: `IOSActivitySettingsCoherenceTests`, static view contracts in routing tests.
