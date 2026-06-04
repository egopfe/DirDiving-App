# Watch / iOS Sensor Source Release Policy

- Default persisted mode: **automatic**
- **Simulation** selectable only in `DEBUG` or TestFlight (sandbox receipt) builds
- App Store / release builds force effective runtime mode away from simulation
- Hidden developer unlock gesture is **DEBUG-only**
- When mock depth is active in allowed builds, Live Dive shows a red **SIMULATION** badge

Mock depth must never be mistaken for certified or Apple sensor depth in public release.
