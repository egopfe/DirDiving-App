# Smallest Watch layout — software coverage (current)

**Command 14 — simulator/layout contracts**

## Smallest supported simulator profile

Primary CI profile: **Apple Watch Series 11 (42mm)** (smallest available in current Xcode simulator lineup).

Physical **41 mm** verification remains **PENDING_PHYSICAL_QA** (`Docs/QA_EVIDENCE/SNORKELING_WATCH_LAYOUTS/`).

## Software-covered surfaces

| Activity | Surfaces | Test suite |
|----------|----------|------------|
| Diving FC | Live panels, settings activity default, gas switch, deco states | `FullComputerUIStateMatrixTests`, `SmallestWatchLayoutContractTests` |
| Apnea | Watch stages (ready → summary) | `ApneaWatchUIViewContractTests`, `ApneaMockupReferenceMatrixTests` |
| Snorkeling | Watch stages (ready → summary) | `SnorkelingWatchLayoutContractTests`, `SnorkelingWatchUIViewContractTests` |

## Contracts verified (simulator)

- Primary metric / hero value non-empty
- Critical warning / GPS status non-empty where applicable
- Deterministic presentation for repeated fixture input
- Dynamic Type long strings remain non-empty (Snorkeling navigation)
- Settings activity-default fixture (`FC_UI_04`) registered

## Limitations

Simulator layout does not replace physical 41 mm clipping checks, haptics, or Always-On behavior.

**Status:** PENDING_PHYSICAL_QA for smallest physical Watch hardware.
