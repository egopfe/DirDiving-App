# DIR DIVING iOS — External Bühlmann Validation Plan

**Scope:** `DIRDiving iOS` (Companion MAIN) only  
**Positioning:** Non-certified Bühlmann ZHL-16C **reference** planner — not dive-computer equivalence. **Ratio Deco is out of scope** for external Bühlmann validation (comparative heuristic only — see [`RATIO_DECO_COMPARATIVE_HEURISTIC.md`](RATIO_DECO_COMPARATIVE_HEURISTIC.md)).
**Status:** Internal regression **active**; external reference campaign **pending**  
**Evidence matrix:** [`DIR_DIVING_IOS_BUHLMANN_EXTERNAL_VALIDATION_EVIDENCE.md`](DIR_DIVING_IOS_BUHLMANN_EXTERNAL_VALIDATION_EVIDENCE.md)

---

## Goal

Establish a repeatable, documented path to compare DIR Diving iOS planner output against independent reference tools **without** claiming certified decompression equivalence.

---

## Phases

| Phase | Status | Deliverable |
|---|---|---|
| 1 Internal regression | **Active** | JSON fixtures + XCTest ranges (`Tests/iOSAlgorithmTests/Fixtures/`) |
| 2 Metadata hardening | **Active** | `validationStatus`, `referenceSource`, `toleranceMinutes`, notes |
| 3 External reference capture | **Pending** | Fixture rows with `pending_external_validation` until values recorded |
| 4 Comparison campaign | **Pending** | Spreadsheet/tool diff — use [`BUHLMANN_EXTERNAL_VALIDATION_FIXTURES_TEMPLATE.md`](BUHLMANN_EXTERNAL_VALIDATION_FIXTURES_TEMPLATE.md) |
| 5 Release gate | **Pending** | Sign-off checklist in `DIR_DIVING_IOS_TESTFLIGHT_READINESS_CHECKLIST.md` |

---

## Fixture metadata (required)

Each fixture JSON (or manifest entry) must declare:

| Field | Required | Notes |
|---|---|---|
| `validationStatus` | Yes | `internal_regression` \| `pending_external_validation` \| `external_reference_validated` (future only) |
| `referenceSource` | Yes | Tool name + version or `internal-ios-buhlmann-suite` |
| `validationNotes` | Yes | Must not claim certified equivalence |
| `toleranceMinutes` | Yes | Range envelope for TTS/stops |
| `gfLow` / `gfHigh` | Yes | |
| `gases[]` | Yes | O₂/He fractions, roles, switch depths |
| `environment` | If non-default | Altitude, salinity |
| `expectedTTSRangeMinutes` | Recommended | min/max |
| `expectedNDLRangeMinutes` | If NDL profile | min/max |
| `expectedFirstStopDepthMeters` | If deco | |
| `ascentDescentAssumptions` | Recommended | Schreiner / segment model note |

**Machine checks:** `BuhlmannExternalValidationMetadataTests.swift`

---

## Reference tool candidates (non-binding)

- **decotengu** (CLI envelopes — document version)
- **Subsurface planner export** (manual CSV — not automated XML equivalence)
- **Spreadsheet / manual Bühlmann worksheets** (document source PDF)

No fixture may use fabricated third-party stop lists labeled as certified.

---

## Acceptance criteria

- [ ] All fixtures parse with metadata defaults or explicit fields
- [ ] No fixture sets `validationStatus = external_reference_validated` without signed external campaign
- [ ] Docs separate internal regression from external validation
- [ ] Product copy remains reference-only

---

*See also:* [`DIR_DIVING_IOS_BUHLMANN_VALIDATION_FIXTURES.md`](DIR_DIVING_IOS_BUHLMANN_VALIDATION_FIXTURES.md), [`IOS_MAIN_ALGORITHM_MATH_AUDIT_CURRENT.md`](IOS_MAIN_ALGORITHM_MATH_AUDIT_CURRENT.md)
