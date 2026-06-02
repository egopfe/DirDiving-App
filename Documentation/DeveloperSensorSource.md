# Developer Sensor Source

## Purpose

Hidden **Developer → Sensor Source** settings let internal testers choose how depth samples are acquired on Apple Watch (and record the same preference locally on the iOS companion). This does not change dive algorithms, Bühlmann, planner, gas logic, GPS, mission mode, or UI styling.

## Modes

### Automatic

Uses `AppleDepthSensorProvider` when `CMWaterSubmersionManager.waterSubmersionAvailable` is true; otherwise `MockDepthSensorProvider`. Does not persist a fallback when Apple hardware is unavailable.

### Apple Sensor

Uses `AppleDepthSensorProvider` only when available. If unavailable, shows a developer warning, persists **Simulation**, and continues with `MockDepthSensorProvider`.

### Simulation (default)

Uses `MockDepthSensorProvider` only. Works without the Submerged Depth and Pressure entitlement. Real underwater depth is not acquired.

## Visibility

The Developer section is hidden from normal users unless:

- **DEBUG** build, or
- **TestFlight** (sandbox App Store receipt), or
- **Hidden gesture:** tap the app version row **7 times** (Watch: Settings → Info → Version; iOS: More → About → Version).

Unlock state: `developer.settings.unlocked` in `UserDefaults`.

## Persistence

| Key | Value | Default |
|-----|--------|---------|
| `developer.sensorSource` | `automatic` \| `appleSensor` \| `simulation` | `simulation` |
| `developer.settings.unlocked` | Bool | false (release) |

Watch and iPhone store preferences **independently** (no sync).

## Entitlement-safe implementation

- `CMWaterSubmersionManager` is **never** created at app launch.
- `AppleDepthSensorProvider` is created only when mode is **Apple Sensor** or **Automatic** and availability is true.
- `SensorProviderFactory` centralizes provider selection.
- Default mode **Simulation** ensures compile, install, launch, and dive flows without entitlement.

## Apple Watch testing without entitlement

Build and run with default **Simulation**. Depth updates come from `MockDepthSensorProvider` (surface-level simulation). Manual dive, logging, runtime/TTV, ascent rate, averages, GPS, and mission mode behave as before; only real Apple depth is missing.

## Limitations

Without the Submerged Depth and Pressure entitlement (and compatible hardware), **Apple Sensor** and **Automatic** (when Apple is unavailable) cannot provide real depth. Use **Simulation** for entitlement-free device testing.
