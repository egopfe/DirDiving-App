# Build and run

This file documents the stable iOS Companion build path. The root `project.yml` also contains the watchOS app target.

## Generate the project

```bash
xcodegen generate
```

## Open in Xcode

```bash
open DIRDiving.xcodeproj
```

## Build

1. Select the `DIRDiving iOS` scheme.
2. Select an iPhone simulator or a physical iPhone.
3. Press **Run**.

Available schemes from `project.yml`:

- `DIRDiving iOS`
- `DIRDiving Watch App`

The iOS Companion stable branch includes Logbook, Dive Detail, Planner, Planner Result, Analysis, Export and WatchConnectivity surfaces. UI-only visual alignment must not change planner calculations, sync, persistence, models, managers or navigation flows.

## Signing

Configured values:

```text
Team ID: C6FKKPB6A9
Bundle ID: com.egopfe.dirdiving.ios
```

If automatic signing does not create a provisioning profile, press **Fix Issue** in Xcode.

The companion uses:

```text
Entitlements: iOSApp/Config/DIRDivingiOS.entitlements
Info.plist:   iOSApp/App/Info.plist
Sources:      iOSApp
```
