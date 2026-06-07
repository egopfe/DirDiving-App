# Watch TestFlight Sensor Source QA

**Scope:** Apple Watch MAIN (`DIRDiving Watch App`)  
**Policy:** Simulation depth is **QA-only** in DEBUG/TestFlight builds. App Store/release builds sanitize stored `.simulation` to `.automatic`.

## Preconditions

- TestFlight or DEBUG build with developer section unlocked (DEBUG only for unlock taps).
- Paired iPhone with DIR DIVING Companion installed (not required for sensor-source checks).

## Checklist

| # | Step | Expected |
|---|------|----------|
| 1 | Fresh install / cleared defaults | Sensor source = **Automatic** |
| 2 | Release build with stored `.simulation` | Migrated to **Automatic** on launch |
| 3 | Enable simulation (TestFlight/DEBUG only) | Live/Settings shows **Simulation depth source** copy |
| 4 | Mock fallback on non-submersion hardware | **Mock fallback (no real depth)** or **Depth sensor unavailable** — never silent real-depth UI |
| 5 | Simulation active | Cannot auto-start dive from 0 m mock stream |
| 6 | Switch back to Automatic | Simulation copy clears |

## Notes

- TestFlight builds may expose simulation for internal QA; document in release notes that simulation is not representative of production sensor behavior.
- Production App Store builds must not allow silent simulation persistence (`SensorSourceMode.applyReleaseSafeMigrationIfNeeded()`).

See also [`WATCH_SENSOR_SOURCE_RELEASE_POLICY.md`](WATCH_SENSOR_SOURCE_RELEASE_POLICY.md).
