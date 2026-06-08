# CCR Export Policy — DIR DIVING iOS MAIN

**Last updated:** 2026-06-08

## Supported exports

| Export | OC Planner | CCR Planner | Notes |
|---|---|---|---|
| Planner PDF | Yes | Yes (`CCRPlannerPDFBuilder`) | Reference-only disclaimer |
| Briefing PDF | Yes | No | OC only |
| Dive Pack PDF | Yes | **No** | Combines OC plan + checklist; CCR not supported |
| Checklist PDF | Yes | Yes (CCR checklist sync) | Unit-aware switch depths |
| Share sheet | Yes | Yes | System share targets |

## Gating

- `PDFExportService.canExportCCRPlan` requires safety acknowledgement + valid CCR validation state.
- Unavailable / invalid CCR plans **cannot** export (test-locked).

## PDF content (CCR Plan)

Includes: setpoint low/high, switch depth, diluent, bailout cylinders, schedule, CNS/OTU, narcosis reference + **estimator footnote**, **heuristic bailout analysis** block.

## Dive Pack limitation

Dive Pack remains **open-circuit Bühlmann** packaging. UI must not offer CCR Dive Pack until a dedicated builder exists. Document this in TestFlight review notes.

## CSV

CCR manual dive metadata uses `# dirdiving_ccr_*` comment keys where supported — see [`SUBSURFACE_CSV_ROUNDTRIP.md`](SUBSURFACE_CSV_ROUNDTRIP.md).
