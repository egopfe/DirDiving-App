# Watch Full Computer Apnea Boundary Audit (V1.7)

## Boundary verdict
`PASS` in software scope.

## Verified constraints
- Apnea path does not expose Full Computer decompression authority.
- No GF/gas/MOD/PPO2/deco controls are introduced into Apnea runtime.
- Apnea logbook/sync remain activity-owned and isolated.
- Water auto-open boundary remains policy/routing-gated; no auto-start of FC without explicit mode path.

## Pending items
Physical in-water behavior and UX traversal evidence remain `PENDING_PHYSICAL`.

Baseline refresh: 7ae527b (target baseline 7ae527b254dcd536fe20fb05c1863ad50b4e4dde).
