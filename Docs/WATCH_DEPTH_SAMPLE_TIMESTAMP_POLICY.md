# Watch MAIN — Depth Sample Timestamp Policy (WATCH-S2-003)

**Updated:** 2026-06-02  
**Code:** `Models/DiveSample.swift`, `Utils/DepthSampleValidation.swift`, `Services/DiveManager.swift`, `Utils/MonotonicElapsedClock.swift`

---

## Sample `timestamp` (sensor / event time)

`DiveSample.timestamp` is the **measurement event time** attached to a depth reading:

| Source | `timestamp` origin |
|---|---|
| Apple depth sensor | Timestamp supplied by `DepthSensorProvider` callback (sensor/event time when available) |
| Mock / simulation providers | Injected test clock or `Date()` from the provider callback |
| Manual restore / draft | Persisted ISO8601 value from draft JSON |
| Test hooks | Explicit `Date` passed to `testHook_ingestDepthForTests` |

`timestamp` drives:

- Profile ordering and export `time_seconds` (relative to first sample)
- Time-weighted average depth (TWAD)
- Ascent rate (delta depth / delta `timestamp`)
- Frozen / stale sample validation windows

---

## `receivedAt` (ingestion wall clock)

`DepthSampleValidation.validate` accepts both `timestamp` and `receivedAt` (defaults to `Date()` at ingestion).

Stale checks compare the two:

- Reject if `timestamp` is too far **in the future** vs `receivedAt` (`maximumFutureDepthSampleSkewSeconds`)
- Reject if `receivedAt` is too far **after** `timestamp` (`staleDepthSampleSeconds`)

This catches delayed delivery, clock skew, and buffered sensor batches without changing accepted depth math for valid samples.

---

## Dive **runtime** elapsed (not sample timestamps)

Displayed dive runtime and stopwatch use `MonotonicElapsedClock`, anchored at session start:

- Uses `ProcessInfo.processInfo.systemUptime` reconciled with wall-clock anchor
- **Does not** use raw `Date()` deltas alone — prevents runtime jumping backward on system clock adjustments or jumping forward on large skew
- Independent from per-sample `timestamp` (samples may share coarse sensor timing; runtime must remain monotonic for UI and alarms)

---

## Test mock guidance

- Provide coherent `(timestamp, receivedAt)` pairs in unit tests
- For stale rejection tests, offset `receivedAt` beyond configured thresholds while holding `timestamp` fixed
- For runtime tests, inject uptime via `MonotonicElapsedClock` test seams rather than manipulating system `Date` globally
- Mock surface frozen-sample exemption (`exemptMockSurfaceFrozenSamples`) applies only to mock fallback at surface band during active dive — not to real sensor frozen detection

---

## Related tests

- `DepthSampleValidationTests` / frozen and stale cases in `WatchMainAlgorithmRemediationPhaseTests`
- `DiveAlgorithmTests.testDraftRestoreAverageDepthTailCapReducesOfflineSkew`
- `WatchCompleteAlgorithmAuditRemediationTests` (documentation regression guard)
