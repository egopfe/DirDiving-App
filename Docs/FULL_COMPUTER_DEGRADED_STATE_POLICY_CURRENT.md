# Full Computer Degraded Runtime State Policy — Current

**Updated:** 2026-06-21  
**Scope:** Watch Full Computer live Bühlmann runtime only

## Triggers

| Code | Cause | Engine state |
|---|---|---|
| `missed_tick:Ns` | Tick/sample gap > 2 s (warn) or > 120 s (long suspension) | `degraded` |
| `non_monotonic_timestamp` | Out-of-order depth sample | `degraded` (sample rejected) |
| `non_finite_depth` | Invalid depth | `unavailable` |
| `invalid_gas_switch` | Invalid gas composition | `degraded` |
| `solver_budget_exceeded` | Presentation solver budget fallback | conservative presentation |
| `timing_degraded` | Presentation diagnostic when engine degraded | NDL/TTS non-authoritative |

## Integration policy (P2-AUD15-003 remediated)

- Tissue integration uses **full elapsed** monotonic time (sub-stepped ≤30 s).
- Gaps > **120 s** mark `degraded` but **do not cap** tissue integration.
- No optimistic zero-deco solely due to timing gap.

## UI policy

- `DiveLiveView` shows yellow banner when `engineState == degraded|unavailable` or `usedConservativeFallback`.
- Degraded deco mode uses `live.fc.status.runtime_degraded` and suppresses authoritative NDL display.
- Ascent-between-stops disabled while timing degraded.

## Persistence

- Checkpoint preserves `previousEngineState` and diagnostics.
- Restore with degraded state sets `restored_degraded` diagnostic.

## External validation

Physical Watch Ultra timing under suspend/resume: **PENDING**.
