# MOD Validation / Presentation Policy — CURRENT

## Canonical MOD

`MODPresentationPolicy.canonicalMODMeters(for:mode:environment:)` is the single classification source:

| Mode / role | MOD basis |
|---|---|
| Base + bottom gas | `PlannerModePolicy.baseDerivedMODMeters` (PPO₂ 1.4) |
| All other cases | `PlannerMODValidator.modMeters(for:environment:)` |

## Presentation

- Live validator: `PlannerMODValidator` (tolerance +0.05 m)
- PDF export: `MODPresentationPolicy.displayMOD` → `Formatters.depth` (rounding is display-only)
- Classification always uses unrounded canonical meters

## Tests

- `MODPresentationPolicyTests`
- `PlannerBaseGasDepthCompatibilityTests`
- `AuditRemediationTests` (environment-aware MOD)
