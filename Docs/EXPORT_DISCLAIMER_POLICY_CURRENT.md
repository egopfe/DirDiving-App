# Export Disclaimer Policy (Current)

**Date:** 2026-06-20

---

## Scope

| Export | Builder / service | Required disclaimers |
|--------|-------------------|----------------------|
| Planner PDF (OC) | `PDFExportService` | Reference-only; not certified; mode disclaimer |
| CCR plan PDF | CCR PDF export path | CCR reference-only; heuristic bailout; no loop monitor |
| Ratio Deco PDF overlay | `pdf.export.ratio_deco.disclaimer` | Comparative heuristic; not certified DC |
| Subsurface CSV | `SubsurfaceExportService` | Profile data only; GPS optional/redacted; no deco authority |
| Watch briefing cards | Briefing export | `briefing.reference_only.footer` |
| Checklist PDF | Equipment export | Operational checklist — not life-support verification |

---

## Mode-specific rules

- **Base planner export:** single-gas reference view disclaimer.
- **Technical export:** full multigas reference; still non-certified.
- **CCR export:** separate from OC Dive Pack; never imply OC bailout schedule authority.

---

## GPS and simulation

- Default diving export omits GPS unless user selects approximate/precise (Command 9 policy).
- Exports must not claim underwater GPS track validity.
- Simulation/test depth sources must not appear as validated field measurements in export metadata.

---

## Tests

- `CSVMetadataRoundTripTests`
- `PDFExportServiceTests` / CCR PDF remediation tests
- `ReleaseLegalClaimsRemediationTests.testExportDisclaimerKeysExist`

---

## External validation

Subsurface external round-trip remains **PENDING** — software round-trip tests do not substitute.
