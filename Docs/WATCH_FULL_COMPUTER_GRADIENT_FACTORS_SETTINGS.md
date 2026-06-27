# Watch Full Computer — Gradient Factors Settings

## Scope

Gradient Factors (GF) preset selection is **Full Computer only**. It does not appear in Gauge, Apnea, or Snorkeling.

## Supported presets (Watch)

| Preset | GF Low/High | Default |
|--------|-------------|---------|
| Conservative | 20/80 | |
| Standard | 30/70 | Yes |
| Moderate | 40/85 | |

There is **no Custom GF** on Apple Watch: no sliders, no manual GF Low/High fields, and no values outside the three presets.

## Source precedence

1. **iOS Plan** — when an imported dive plan is activated (`FullComputerImportedPlanStore.activatedPlanID`), GF comes from the plan and the Watch preset menu is locked.
2. **Watch Settings** — fallback when no active iOS plan; stored in UserDefaults key `dirdiving.fullComputer.gradientFactorPreset.watchDefault`.

iOS plans must use GF pairs that map exactly to a supported preset (20/80, 30/70, 40/85). Non-matching pairs are rejected at import with `invalidGradientFactors`.

## Lock rules

GF cannot be changed when:

- Any dive/apnea/snorkeling session is active
- Full Computer predive is confirmed / runtime is configured
- An active imported iOS plan controls GF

## Where GF appears

- Settings → Diving → Full Computer → Conservatism → Gradient Factors
- Full Computer predive settings and confirmation
- Full Computer runtime (via frozen predive snapshot)
- Diving logbook metadata (`gradientFactorPreset`, `gradientFactorSource`, low/high)

## Where GF does **not** appear

- Gauge, Apnea, Snorkeling settings and logbooks
- Underwater fast controls / Action Button / Digital Crown shortcuts

## Predive snapshot

At predive confirmation, `FullComputerPrediveConfigurationStore` freezes `FullComputerResolvedGradientFactors`. Runtime and logbook use this snapshot—not live UserDefaults reads.

## Physical QA

Requires real Apple Watch verification. See `Docs/QA_EVIDENCE/WATCH_FULL_COMPUTER_GF_*` templates (default **PENDING**).
