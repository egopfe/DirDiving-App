# Apple Shallow Depth Entitlement Support

## Overview

DIR Diving distinguishes **user-selected sensor source** from **resolved depth capability**. Shallow entitlement enables real Apple Watch depth/pressure samples within Apple's shallow-water scope. It does **not** unlock Full Computer decompression runtime or imply a certified dive computer.

## Capability model

| Layer | Type | Purpose |
|-------|------|---------|
| User selection | `SensorSourceMode` | Automatic, Apple Sensor (UI), Simulation (developer) |
| Resolved tier | `DepthCapabilityMode` | `.none`, `.simulation`, `.appleShallow`, `.appleFull` |
| Sample provenance | `DepthSampleSource` | `.appleShallow`, `.appleFull`, `.simulation`, `.unavailable` |

Shallow and full are never collapsed into a single ambiguous `.appleSensor` state internally. Legacy persisted `.appleSensor` resolves to shallow or full at runtime via `DepthCapabilityResolver`.

## Entitlement detection

Runtime `SecTask` introspection is unreliable on watchOS. The app uses a conservative fail-closed probe:

1. Compile flags: `DEPTH_ENTITLEMENT_SHALLOW`, `DEPTH_ENTITLEMENT_FULL`
2. Info.plist: `DIRDepthEntitlementTier` (`none` | `shallow` | `full`)
3. Entitlements file: `Config/DIRDiving.WithShallowDepth.entitlements` (`com.apple.developer.submerged-shallow-depth-and-pressure`)

Full entitlement uses `Config/DIRDiving.WithWaterSubmersion.entitlements` (full / legacy keys).

## Provider selection

`SensorProviderFactory.makeSelection(mode:)`:

- **Automatic**: Full → Shallow → (developer simulation if allowed) → Unavailable
- **Apple Shallow explicit**: Shallow provider or unavailable (missing entitlement)
- **Apple Full explicit**: Full provider or unavailable (missing full entitlement)
- **Simulation**: Mock only when developer mode allows; otherwise unavailable in release

No silent fallback from real Apple sensor to simulation in production builds.

## Activity policy (`DepthCapabilityPolicy`)

| Capability | Snorkeling | Apnea | Diving Gauge | Full Computer |
|------------|------------|-------|--------------|---------------|
| none | disabled | disabled | disabled | disabled |
| simulation | developer only | developer only | developer only | disabled |
| appleShallow | enabled | enabled (limited) | developer/internal only | **disabled** |
| appleFull | enabled | enabled | enabled | enabled if validated |

## What shallow enables

- Real `CMWaterSubmersionManager` samples tagged `.appleShallow`
- Snorkeling and Apnea runtimes with shallow-water limitation copy
- Logbook metadata: sensor source and capability on session records
- Watch → iOS sync of optional depth metadata fields

## What shallow does not enable

- Bühlmann / Full Computer live decompression guidance
- Claiming DIR Diving or Apple Watch is a certified dive computer
- Gauge runtime for end users (developer/internal only unless project policy changes)
- Upgrading shallow payloads to full on iOS companion

## Provisioning (shallow builds)

1. Set `CODE_SIGN_ENTITLEMENTS` to `Config/DIRDiving.WithShallowDepth.entitlements`
2. Set `DIRDepthEntitlementTier` to `shallow` in Watch app Info.plist (or `DEPTH_ENTITLEMENT_SHALLOW` compile flag)
3. Use Apple-provisioned shallow depth capability on supported Apple Watch hardware

## Release gate

- **Internal** (`--internal`): code, tests, templates may pass with physical QA PENDING
- **Release** (`--release`): fails until signed `SHALLOW_*` physical evidence exists

## Rollback

1. Revert branch or reset `DIRDepthEntitlementTier` to `none`
2. Restore default entitlements without shallow key
3. Sessions with shallow metadata remain readable; unknown tags decode safely

See also: [DEPTH_CAPABILITY_MATRIX.md](DEPTH_CAPABILITY_MATRIX.md), [SENSOR_SOURCE_POLICY.md](SENSOR_SOURCE_POLICY.md), [APPLE_SHALLOW_DEPTH_QA_PLAN.md](APPLE_SHALLOW_DEPTH_QA_PLAN.md).
