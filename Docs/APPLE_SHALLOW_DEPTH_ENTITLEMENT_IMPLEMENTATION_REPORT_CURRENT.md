# Apple Shallow Depth Entitlement — Implementation Report (Current)

**Date:** 2026-06-17  
**Branch:** `feature/apple-shallow-depth-entitlement`  
**Baseline commit:** `4adf41d` (*fix(watch): harden UI text fitting*)  
**Working tree:** uncommitted local changes on feature branch  

## Verdict

| Gate | Status |
|------|--------|
| Internal implementation | **INTERNAL_IMPLEMENTATION_READY** |
| Physical shallow-water QA | **PHYSICAL_SHALLOW_QA_PENDING** |
| External release | **EXTERNAL_NO_GO** |

Do not claim external readiness or certified dive-computer behavior without signed shallow-water physical evidence.

---

## Architecture discovered (pre-change)

- Single `SensorSourceMode`: `automatic | appleSensor | simulation`
- `SensorProviderFactory` silently fell back to `MockDepthSensorProvider` when Apple sensor unavailable
- One undifferentiated `AppleDepthSensorProvider` wrapping `CMWaterSubmersionManager`
- No shallow vs full capability separation
- Default Watch entitlements: `Config/DIRDiving.entitlements` (no water-submersion keys)

## Architecture after change

```
User selection (SensorSourceMode)
        │
        ▼
DepthCapabilityResolver ──► DepthCapabilityMode (.none | .simulation | .appleShallow | .appleFull)
        │
        ▼
SensorProviderFactory.makeSelection()
        │
        ├── AppleDepthSensorProvider(.shallow | .full)
        ├── MockDepthSensorProvider (developer only)
        └── UnavailableDepthSensorProvider (explicit reason)
        │
        ▼
DepthSampleSource on samples / session metadata
        │
        ▼
DepthCapabilityPolicy ──► activity runtime gating
```

Watch remains runtime source of truth. iOS companion receives optional session metadata via existing Shared models (Codable fields on Apnea/Snorkeling sessions).

---

## New capability model

| Type | Values | Role |
|------|--------|------|
| `DepthCapabilityMode` | none, simulation, appleShallow, appleFull | Resolved entitlement tier |
| `SensorSourceMode` | automatic, appleShallow, appleFull, simulation, appleSensor (legacy) | User/developer selection |
| `DepthSampleSource` | appleShallow, appleFull, simulation, unavailable | Sample/session provenance |
| `DepthSampleQuality` | measured, degraded, unavailable | Sample health |
| `DepthSensorUnavailableReason` | shallow/full missing, simulation blocked, API unavailable, none | Fail-closed provider reasons |

Shallow and full are **not** conflated. Legacy `.appleSensor` resolves to shallow or full via `explicitAppleRequest(resolver:)`.

---

## Entitlement and project changes

| File | Change |
|------|--------|
| `Config/DIRDiving.WithShallowDepth.entitlements` | **New** — `com.apple.developer.submerged-shallow-depth-and-pressure` |
| `App/Info.plist` | `DIRDepthEntitlementTier` = `none` (default dev/simulator) |
| `Utils/DepthCapabilityEntitlementProbe.swift` | **New** — Info.plist tier + compile flags (`DEPTH_ENTITLEMENT_SHALLOW` / `FULL`); SecTask not used on watchOS |
| `project.yml` | Explicit Watch target membership for capability utils, providers, tests |

**Shallow provisioning:** set `CODE_SIGN_ENTITLEMENTS` to `Config/DIRDiving.WithShallowDepth.entitlements` and `DIRDepthEntitlementTier=shallow` (or compile flag).

---

## Provider selection behavior

| Mode | Condition | Provider | Sample source |
|------|-----------|----------|---------------|
| Automatic | Full + API | Apple `.full` | `.appleFull` |
| Automatic | Shallow + API | Apple `.shallow` | `.appleShallow` |
| Automatic | Dev simulation allowed, no Apple | Mock | `.simulation` |
| Automatic | Otherwise | Unavailable | `.unavailable` |
| appleShallow explicit | Entitlement missing | Unavailable | `.shallowEntitlementMissing` |
| appleFull explicit | Only shallow | Unavailable | `.fullEntitlementMissing` |
| simulation | Release / no dev | Unavailable | `.simulationDisabledInRelease` |

**No silent mock fallback in release** when Apple sensor is unavailable.

`AppleDepthSensorProvider` adds `OperatingMode` (`.shallow` / `.full`), shallow depth ceiling (~6 m), degraded state beyond shallow range, and `testHook_isAvailable` for deterministic tests.

---

## Activity gating matrix

Implemented in `DepthCapabilityPolicy` + `DIRActivitySelectionStore` + `DivingModeSelectionView`.

| Capability | Snorkeling | Apnea | Diving Gauge | Full Computer |
|------------|------------|-------|--------------|---------------|
| none | disabled | disabled | disabled | disabled |
| simulation | dev only | dev only | dev only | disabled |
| appleShallow | enabled | enabled (limited) | dev/internal only | **disabled** |
| appleFull | enabled | enabled | enabled | enabled if validated |

Full Computer selection with shallow shows localized block reason (IT/EN).

---

## UI / Settings changes

- **Watch Developer Settings:** capability status line (`developer.sensor_source.capability_status`) showing resolved capability + active resolution (e.g. Apple Sensor — Shallow)
- **Watch InfoView:** shallow disclaimer string
- **DivingModeSelectionView:** disabled states with reasons for Gauge / Full Computer under shallow
- **iOS Developer Settings:** enum sync; duplicate `displayName` removed (uses shared extension)

---

## Localization and accessibility

- EN/IT strings for shallow capability, disclaimers, Full Computer block reasons, logbook source labels, unavailable reasons
- VoiceOver: `watch.depth_capability.apple_shallow.a11y`, `watch.depth_source.apple_shallow.a11y`
- `./Scripts/audit_localization.sh` — **PASS**

---

## Sync / persistence impact

- `ApneaSession` / `SnorkelingSession`: optional `depthSampleSource`, `depthCapabilityMode` (Codable; schema migrations updated)
- `DepthSensorSessionMetadata` in Shared (fields only); Watch capture extension in `Services/DepthSensorSessionMetadata+Watch.swift`
- Apnea/Snorkeling runtime stores capture metadata at session start from `SensorProviderFactory.makeSelection`
- `DiveManager` persists `depthSensorSourceTag` for diving sessions
- Backward compatible: old payloads decode without new fields; iOS does not upgrade shallow → full

---

## Files changed

### New
- `Utils/DepthCapabilityMode.swift`, `DepthSampleSource.swift`, `DepthCapabilityEntitlementProbe.swift`, `DepthCapabilityResolver.swift`, `DepthCapabilityPolicy.swift`
- `Services/UnavailableDepthSensorProvider.swift`, `DepthSensorSessionMetadata+Watch.swift`
- `Shared/Utils/DepthSensorSessionMetadata.swift`
- `Config/DIRDiving.WithShallowDepth.entitlements`
- `Tests/WatchAlgorithmTests/DepthCapabilityTests.swift`
- `Scripts/validate_apple_shallow_depth_readiness.sh`
- `Docs/APPLE_SHALLOW_DEPTH_ENTITLEMENT_SUPPORT.md`, `APPLE_SHALLOW_DEPTH_QA_PLAN.md`, `SENSOR_SOURCE_POLICY.md`, `DEPTH_CAPABILITY_MATRIX.md`
- `Docs/QA_EVIDENCE/SHALLOW_*` (12 templates, all **PENDING**)

### Modified
- `SensorProviderFactory.swift`, `AppleDepthSensorProvider.swift`, `SensorSourceMode.swift`, `DepthSensorSourceResolution.swift`
- `DiveManager.swift`, `ApneaWatchRuntimeStore.swift`, `SnorkelingWatchRuntimeStore.swift`
- `DIRActivitySelectionStore.swift`, `DivingModeSelectionView.swift`, `DeveloperSettingsView.swift`, `InfoView.swift`
- Shared Apnea/Snorkeling models + migrations
- `Resources/en.lproj/Localizable.strings`, `Resources/it.lproj/Localizable.strings`
- `App/Info.plist`, `project.yml`, iOS `SensorSourceMode.swift`, iOS `DeveloperSettingsView.swift`
- `Tests/WatchAlgorithmTests/DeveloperSensorSourceTests.swift`

### Unchanged (per requirements)
- Bühlmann mathematics, Full Computer deco logic, Gauge algorithm, Apnea/Snorkeling lifecycles (except consuming real shallow samples), Mission Mode, WatchConnectivity trust, logbook ownership separation

---

## Tests added / updated

| Suite | Tests |
|-------|-------|
| `DepthCapabilityTests` | Shallow ≠ full, automatic shallow selection, explicit full fails on shallow only, no silent mock in release policy, metadata round-trip |
| `DeveloperSensorSourceTests` | Updated for explicit unavailable paths (no silent mock) |

---

## Tests executed

| Command | Result |
|---------|--------|
| Watch Algorithm Tests — `DepthCapabilityTests`, `DeveloperSensorSourceTests` | **PASS** |
| Watch App build (simulator, no signing) | **PASS** |
| iOS build (simulator, no signing) | **PASS** |
| iOS Algorithm Tests (full suite) | **PASS** |
| `./Scripts/check_main_target_isolation.sh` | **PASS** |
| `./Scripts/check_secrets.sh` | **PASS** |
| `./Scripts/audit_localization.sh` | **PASS** |
| `./Scripts/validate_apple_shallow_depth_readiness.sh --internal` | **PASS** (with this report present) |
| `./Scripts/validate_apple_shallow_depth_readiness.sh --release` | **FAIL by design** (physical QA pending) |

---

## QA evidence

Twelve `Docs/QA_EVIDENCE/SHALLOW_*` folders with README templates. All default **PENDING**. No PASS claims.

---

## Risks

1. **Entitlement introspection** — relies on build metadata (Info.plist / compile flags), not runtime SecTask on watchOS; mis-provisioned builds may report `.none` until tier is set correctly (fail-closed).
2. **Simulator** — `CMWaterSubmersionManager.waterSubmersionAvailable` is false; shallow builds on device still require physical QA.
3. **iOS logbook UI** — session fields sync via Shared models; dedicated iOS logbook display of “Apple Shallow” may need follow-up UI wiring if not already present in detail views.
4. **Gauge with shallow** — intentionally developer-only; policy may need product review before any public shallow Gauge path.

---

## Rollback plan

1. Revert branch `feature/apple-shallow-depth-entitlement` or reset to `4adf41d`
2. Restore default entitlements (`Config/DIRDiving.entitlements`) and `DIRDepthEntitlementTier=none`
3. Existing sessions with shallow metadata remain readable; unknown tags decode as optional nil

---

## Release verdict

**INTERNAL_IMPLEMENTATION_READY** — code compiles, deterministic tests pass, documentation and QA templates exist.  
**PHYSICAL_SHALLOW_QA_PENDING** — no signed shallow-water device evidence.  
**EXTERNAL_NO_GO** — release validation intentionally blocked until `SHALLOW_*` evidence is signed PASS.
