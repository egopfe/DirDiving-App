# Apnea Session Check

Pre-session readiness review on iOS. **Informational training aid** — warnings do not block training except for technically impossible configurations.

## Model

`ApneaSessionCheckResult` (`Shared/Models/ApneaSessionCheckResult.swift`):

| Status | Meaning |
|--------|---------|
| `ready` | No issues |
| `warning` | Non-blocking advisories (buddy, sensors, short recovery) |
| `incomplete` | Missing required configuration (e.g. no profile) |
| `blocked` | Reserved for impossible technical states |

`isReadyForTraining` is true for `ready` or `warning`.

## Evaluator

`ApneaSessionCheckEvaluator.evaluate(_:)` (`Shared/Utils/ApneaSessionCheckEvaluator.swift`) inputs:

- Selected `ApneaSessionProfile`
- `ApneaRecoveryPolicy`
- Recovery alerts enabled
- Buddy reminder shown / checklist confirmed
- Optional: Watch battery low, depth sensor, heart rate availability

### Checks performed

| Check | Warning when |
|-------|--------------|
| Profile selected | Missing → `incomplete` |
| Buddy checklist | Not confirmed |
| Recovery policy | `minimumSurfaceSeconds < 30` |
| Depth profile | Depth sensor unavailable for `depthConstantWeight` |
| Sensors | Heart rate reported unavailable |
| Watch battery | Low, if known |

Issues carry localization keys (e.g. `apnea.session_check.buddy_not_confirmed`).

## iOS UI

`IOSApneaSessionCheckView.swift` displays:

- Profile name and kind
- Recovery alerts ON/OFF
- Buddy reminder status
- Aggregate status: Ready / Warning / Incomplete
- Issue list from `ApneaSessionCheckResult.issues`

Checklist unchecked items may surface as warnings via `buddyChecklistConfirmed: false` — checklist itself does not block session start.

## Integration

Session check runs before Watch session start in the iOS Apnea flow. Profile and recovery policy come from `ApneaSessionProfile` / companion settings.

## Localization

Keys under `apnea.session_check.*` in iOS `Localizable.strings` (EN/IT).

## Tests

`Tests/iOSAlgorithmTests/ApneaSessionCheckEvaluatorTests.swift` — ready with valid profile; warning when buddy not confirmed; incomplete without profile.

## QA

`Docs/QA_EVIDENCE/APNEA_IOS_SESSION_CHECK/README.md` — **PENDING**.
