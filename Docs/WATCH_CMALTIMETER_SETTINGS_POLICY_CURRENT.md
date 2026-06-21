# Watch-only Full Computer altitude sensor proposal settings

**Scope:** Apple Watch Diving → Full Computer only. Not on iPhone. Not synced via WatchConnectivity.

## Modes

| Mode | Automatic sampling | User confirmation before sample | Proposal still requires accept |
|------|-------------------|--------------------------------|-------------------------------|
| Automatic | Yes on predive surfaces | No | Yes |
| Manual only | No | N/A | N/A (manual/import only) |
| Ask before sampling | After prompt | Yes | Yes |

## Storage

`WatchFullComputerAltitudeSensorProposalSettingsStore` — UserDefaults key `dirdiving_watch_fc_altitude_sensor_proposal_mode_v1`

Default: **Automatic**

## UI

Settings → Diving → Full Computer → Altitude Sensor Proposal (`WatchFullComputerAltitudeSensorSettingsSection`)

Predive lifecycle: `FullComputerPrediveAltitudeSensorLifecycle` view modifier.

## Safety

No mode auto-accepts sensor data. No implicit sea-level fallback. Active-dive environment remains immutable.
