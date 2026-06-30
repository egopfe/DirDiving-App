# Apnea Recovery Timer Policy

**Training aid only.** Recovery reminders do not authorize the next breath-hold. User must follow buddy, instructor, and local safety procedures.

## Policy model

`ApneaRecoveryPolicy` (`Shared/Models/ApneaRecoveryPolicy.swift`) defines how long surface recovery is suggested after each hold.

| Mode | Behavior |
|------|----------|
| `informationalOnly` | No enforced target (display only) |
| `ratio1to1` | Target = last hold duration |
| `ratio2to1` | Target = 2× last hold (default) |
| `fixedDuration` | Target = `fixedDurationSeconds` or `recommendedSurfaceSeconds` |
| `customRatio` | Target = last hold × `customRatio` |

Minimum floor: `minimumSurfaceSeconds` (default 60 s). Computation: `ApneaRecoveryComputation.requiredRecoverySeconds`.

Default profile policy: **2× last hold** via `ApneaRecoveryPolicy.default` (`mode: .ratio2to1`).

## Target calculation

`ApneaRecoveryTargetCalculator` wraps the policy:

- `targetSeconds(policy:lastHoldSeconds:)` — planned recovery duration
- `remainingSeconds(target:elapsed:)` — countdown value
- `isTargetReached(target:elapsed:)` — haptic trigger condition

Example: last hold 1:45 → target 3:30 at 2× ratio; UI shows elapsed / target and remaining.

## Watch runtime behavior

1. **Hold ends** → recovery interval starts automatically (`ApneaRecoveryInterval`).
2. **Target computed** from active profile's `minimumRecoveryPolicy`.
3. **Countdown** shows elapsed vs target (e.g. `01:20 / 04:28`).
4. **Target reached** → single haptic (`WKInterfaceDevice.current().play(.notification)`), UI shows localized "Recovery target reached".
5. **Latch** — one haptic per recovery cycle; reset when a new hold starts.

## Edge cases

| Case | Handling |
|------|----------|
| Zero-length hold | Target uses `max(0, hold)`; no crash |
| Recovery interrupted | Record partial `completedSeconds` or `wasSkipped` |
| New hold before target | Latch resets; new recovery cycle on next hold end |
| Session stop | Recovery state cleared with session end |

## iOS configuration (P2)

Settings expose recovery rule: Fixed, 2× last hold, 3× last hold, custom ratio where UI supports it. Configured policy syncs to Watch with the session plan.

## Prohibited wording

Do not use: "safe to dive", "safe to hold", "blackout prevention", "ready to dive". Use: "recovery reminder", "recovery target reached", "training aid".

## Tests

- `Tests/iOSAlgorithmTests/ApneaRecoveryTargetCalculatorTests.swift` (when present)
- `Tests/WatchAlgorithmTests/ApneaRecoveryPolicyLifecycleTests.swift`
- `Tests/WatchAlgorithmTests/ApneaWatchRecoveryRuntimeTests.swift`

## QA

- `Docs/QA_EVIDENCE/APNEA_WATCH_RECOVERY_TIMER/README.md`
- `Docs/QA_EVIDENCE/APNEA_WATCH_RECOVERY_HAPTIC/README.md`

Both **PENDING** until physical device evidence is recorded.
