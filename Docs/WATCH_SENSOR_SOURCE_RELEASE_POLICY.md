# Watch Sensor Source Release Policy

**Scope:** Apple Watch MAIN (`DIRDiving Watch App`)  
**Updated:** 2026-06-07 (audit remediation)

---

## Effective modes

| Mode | Release / App Store | DEBUG | TestFlight |
|---|---|---|---|
| **Automatic** (default) | Yes | Yes | Yes |
| **Simulation** | **No** — sanitized to Automatic on launch | Yes (with visible copy) | Yes (QA-only, visible copy) |
| Apple depth sensor | When hardware + entitlement available | When available | When available |
| Mock fallback | When Apple sensor unavailable; **never presented as real** | Same | Same |

---

## Release sanitization

- Persisted `.simulation` is migrated to `.automatic` via `SensorSourceMode.applyReleaseSafeMigrationIfNeeded()` in App Store/release builds.
- Developer unlock gesture (`DeveloperVersionUnlock`) is **DEBUG-only**; unavailable in release.
- Fresh install default: **Automatic**.

---

## User-visible copy (EN / IT)

| State | EN | IT |
|---|---|---|
| Apple sensor unavailable / mock fallback | Depth sensor unavailable | Sensore profondità non disponibile |
| Simulation active (allowed builds) | Simulation depth source | Sorgente profondità simulata |

Simulation and mock fallback must never be mistaken for certified or Apple sensor depth in public release.

---

## Safety invariants

- Mock/simulation **cannot auto-start** a dive from a 0 m stream.
- Simulation depth is **not** real submersion depth.
- TestFlight simulation is **QA-only** — document in release notes; see [`WATCH_TESTFLIGHT_SENSOR_SOURCE_QA.md`](WATCH_TESTFLIGHT_SENSOR_SOURCE_QA.md).

---

## TTV / Mission Mode

- **TTV** remains an informational live index — not NDL, TTS, decompression, or Bühlmann output.
- **Mission Mode** does not alter sensor source resolution or depth ingestion.

---

## Manual QA

- DEBUG: developer section unlock + simulation toggle.
- TestFlight: simulation visible copy + release-note warning.
- App Store: confirm stored simulation migrates to automatic.
