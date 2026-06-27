# Sensor Source Policy

## Principles

1. **Watch is runtime source of truth** for depth samples during activities.
2. **Simulation is never real data** — samples are tagged `.simulation` and labeled in UI.
3. **No silent fallback** — release builds do not substitute mock provider when Apple sensor is unavailable.
4. **Capability ≠ selection** — user may choose Automatic/Apple Sensor/Simulation; resolver determines shallow vs full vs none.

## User-facing modes (Developer Settings)

| UI label | Internal modes | Behavior |
|----------|----------------|----------|
| Automatic | `.automatic` | Best available: full → shallow → dev simulation → unavailable |
| Apple Sensor | `.appleSensor` → resolved | Maps to `.appleShallow` or `.appleFull` from hardware capability |
| Simulation | `.simulation` | Mock provider; developer-only |

Release builds hide Simulation unless developer unlock is active.

## Provider outcomes

| Selection | Condition | Provider | Sample source |
|-----------|-----------|----------|---------------|
| Automatic | Full entitlement + API | `AppleDepthSensorProvider(.full)` | `.appleFull` |
| Automatic | Shallow only + API | `AppleDepthSensorProvider(.shallow)` | `.appleShallow` |
| Automatic | Dev simulation allowed, no Apple | `MockDepthSensorProvider` | `.simulation` |
| Automatic | Otherwise | `UnavailableDepthSensorProvider` | `.unavailable` |
| Apple Shallow | Entitlement missing | Unavailable | `.unavailable` |
| Apple Full | Only shallow exists | Unavailable | `.unavailable` |
| Simulation | Release / no dev mode | Unavailable | `.unavailable` |

## Persistence

- Dive / Apnea / Snorkeling sessions store optional `depthSampleSource` and `depthCapabilityMode` strings.
- Relaunch recovery uses persisted tags; shallow sessions must not become simulation without explicit developer action.

## Sync

Optional metadata fields sync on Apnea/Snorkeling session payloads. iOS must not upgrade `.appleShallow` to `.appleFull`. Malformed values are rejected or ignored conservatively.

## Safeguards preserved

- Hidden Developer Settings unlock
- `DeveloperSettings.allowsSimulationSensorSelection` gate
- WatchConnectivity trust model unchanged
- Mission Mode semantics unchanged
