# Watch manual / no-depth session sync policy

Date: 2026-05-31  
Scope: Watch MAIN → iOS companion sync (Policy A)

## Policy

Manual Watch sessions **without a depth profile** are valid logs. They sync to iPhone as **runtime/GPS-only** records.

| Field | Value |
|-------|--------|
| `isManual` | `true` when the user started a manual lifecycle session on Watch |
| `hasDepthProfile` | `false` when `samples` is empty after sanitization |
| `samples` | Empty array — **no fake depth values** |
| Sync | Allowed (signed `WatchDiveSyncCodec` payload) |
| CSV export | Not available on Watch or iOS |
| iOS display | Badge `RUNTIME/GPS`, banner, chart placeholder |

## When this applies

- Depth automation unavailable on the Watch (simulator or unsupported hardware), user taps manual start.
- Manual session ends with zero validated depth samples.

Sessions with depth samples use `hasDepthProfile: true` and normal export/sync rules.

## Sync queue cross-reference

Manual/no-depth sessions enqueue to the same signed outbound queue as depth sessions. Pending transfers dequeue only on verified signed companion ACK; see [`WATCH_IOS_SYNC_QA_MATRIX.md`](WATCH_IOS_SYNC_QA_MATRIX.md) and [`WATCH_MAIN_ALGORITHM_MATH_AUDIT_FIX_COMPLETION_REPORT.md`](WATCH_MAIN_ALGORITHM_MATH_AUDIT_FIX_COMPLETION_REPORT.md).

- **Watch:** `DiveSessionPersistenceClass.manualNoDepth` → save + sync.
- **Watch:** `DiveSessionAlgorithmValidator` allows empty samples when `isManual && !hasDepthProfile`.
- **iOS:** `WatchDiveSyncCodec.validateForSync` uses `allowEmptySamples: session.isManual && !session.hasDepthProfile`.

## User-facing copy

- Watch live: `live.manual.nodepth.*`
- Watch log detail: `log.manual.nodepth.banner`
- iOS logbook: `logbook.badge.manual.nodepth`

See [`WATCH_MAIN_ALGORITHM_READINESS_100_REPORT.md`](WATCH_MAIN_ALGORITHM_READINESS_100_REPORT.md) § H.
