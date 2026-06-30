# Snorkeling Watch — Return to Entry

**Scope:** Watch runtime orientation back to session entry point.  
**Limitation:** GPS-based orientation aid — not certified navigation or rescue guidance.

## Behavior

When a session has a captured or planned entry coordinate and a reliable surface GPS fix:

- **Distance** to entry in meters (`SnorkelingDomainSupport.distanceMeters`)
- **Bearing** to entry in degrees 0–360 (`SnorkelingBearingCalculator` / `SnorkelingDomainSupport.bearingDegrees`)
- **Turn guidance** gated by GPS and heading quality (`SnorkelingNavigationEngine.permitsPreciseTurnGuidance`)

When GPS is lost, stale, or underwater:

- Show degraded / unavailable presentation — **do not invent coordinates**
- Precise turn arrow suppressed; distance may be hidden or last-known per presentation policy

## Data sources

| Source | Entry coordinate |
|--------|------------------|
| Planned route from iOS | First routing point with entry role |
| Live session | Entry captured at session start (`entryPointCaptured`) |

## Return alert (related, not identical)

Planned **return alert** (50% time or distance) is separate from continuous return-to-entry display:

- Engine: `SnorkelingPlannedRouteReturnAlertEngine`
- Runtime integration: `SnorkelingRouteRuntimeEvaluator`
- Fires once per session; haptic pattern `.returnAdvised`

## Watch UX (recommended)

**RETURN screen:** large arrow or bearing hint, entry distance, GPS band indicator.

Strings: `snorkeling.watch.return`, `snorkeling.watch.entry`, `snorkeling.watch.time_to_return`.

## GPS quality interaction

Off-route warnings are **paused** when GPS band is `.poor` or `.lost` even if geometrically far from route — prevents false alarms without reliable fixes.

## Tests

- `SnorkelingNavigationReturnEngineTests`
- `SnorkelingReturnAlertPolicyTests`
- `SnorkelingReturnAlertRuntimeTests`
- `SnorkelingBearingCalculatorTests`

## Physical QA

- `Docs/QA_EVIDENCE/SNORKELING_WATCH_RETURN_TO_ENTRY_DISTANCE/`
- `Docs/QA_EVIDENCE/SNORKELING_WATCH_RETURN_ALERT/`
