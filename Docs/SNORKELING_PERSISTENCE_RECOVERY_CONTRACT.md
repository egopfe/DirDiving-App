# Snorkeling Persistence & Recovery Contract (Command 07)

**Status:** Contract only — **not implemented**  
**Date:** 2026-06-18  
**Scope:** Disk persistence and relaunch recovery for `SnorkelingSessionEngine`  
**Prerequisite:** Commands 01–03 in-memory `SnorkelingSessionCheckpoint` export/restore (complete)

---

## Current foundation (Commands 01–03)

- `SnorkelingSessionCheckpoint` preserves session ID, lifecycle phase, clocks, active dip buffers, committed dips, depth/GPS feed bridge state, metrics inputs, manual fallback, sensor-degraded state, navigation/return phase, and raw audit trails per current caps.
- Export/restore is **in-memory only** — no disk write, checksum, or relaunch restore.
- Tests: `SnorkelingCheckpointFoundationTests`, `SnorkelingDepthOnlyLifecycleTests.testNoGPSSessionCheckpointRoundTrip`.

---

## Command 07 requirements

### Envelope

- Versioned persistence envelope distinct from Diving (`dirdiving_dive_session`), Apnea (`dirdiving_apnea_session`), and Full Computer namespaces.
- Proposed key namespace: `dirdiving_snorkeling_session` (must not collide with existing sync keys).

### Integrity

- SHA-256 (or equivalent) checksum over canonical serialized checkpoint payload.
- Corrupt or checksum-mismatch files quarantined — **no silent reset** of an active session.

### Atomic write

1. Serialize checkpoint to staging file with file protection appropriate for session data.
2. Verify checksum of staged bytes.
3. Atomic replace of last-valid checkpoint.
4. Preserve previous last-valid checkpoint until new write succeeds.

### Schema

- Reuse `SnorkelingSession.schemaVersion` and `SnorkelingSchemaMigration` for domain evolution.
- Persistence envelope version independent from domain schema version.
- Future-schema tolerant decode with explicit warning (current policy).

### Relaunch recovery

- On app launch, attempt restore from last-valid checkpoint.
- If restore fails, surface degraded state; do not fabricate GPS or depth.
- Do not route restored state through `DiveManager`, Apnea persistence, or Full Computer stores.

### Retention

- Raw audit trails remain capped (2048 depth, 2048 GPS) per current feed policy unless a future command documents expanded retention.

---

## Explicit non-goals (Command 07)

- No change to lifecycle semantics (debounce, dwell, minimum dip duration, sensor-degraded behavior).
- No navigation bearing, waypoint completion, or return advisor (Command 04).
- No Watch MAIN UI promotion.

---

## Gate

Command 07 is complete only when automated tests verify atomic write, checksum, corruption quarantine, migration, and relaunch restore without weakening Commands 01–03 invariants.
