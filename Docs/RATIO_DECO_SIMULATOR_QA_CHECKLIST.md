# Ratio Deco simulator visual QA checklist

**Status:** **PENDING** — automated model tests pass in CI; **visual QA not complete** unless evidence exists under `Docs/QA_EVIDENCE/RATIO_DECO_SIMULATOR/`.

Ratio Deco remains a **comparative heuristic only** — not a decompression algorithm.

## Device / simulator matrix

| Setting | Value |
|---------|-------|
| Simulators | iPhone 17 Pro (portrait); optional landscape |
| Locales | English, Italian |
| Dynamic Type | Default + Accessibility Extra Large |

## Scenarios

| # | Mode | Deco method | Preset | Schedule | Capture | Status |
|---|------|-------------|--------|----------|---------|--------|
| 1 | Technical | Bühlmann only | — | N/A | `ratio_deco_buhlmann_only_en.png` | PENDING |
| 2 | Technical | Ratio Deco | 1:1 | Compatible | `ratio_deco_1_1_compatible_en.png` | PENDING |
| 3 | Technical | Ratio Deco | 2:1 | Compatible | `ratio_deco_2_1_compatible_en.png` | PENDING |
| 4 | Technical | Ratio Deco | Custom | User preset saved | `ratio_deco_custom_en.png` | PENDING |
| 5 | Technical | Comparison | 1:1 | Side-by-side tables | `ratio_deco_comparison_en.png` | PENDING |
| 6 | Technical | Comparison | 1:1 | Bühlmann incompatible | `ratio_deco_incompatible_en.png` | PENDING |
| 7 | Technical | Ratio Deco | 1:1 | MOD violation warning | `ratio_deco_mod_violation_en.png` | PENDING |
| 8 | Technical | Ratio Deco | 1:1 | No deco gas warning | `ratio_deco_no_deco_gas_en.png` | PENDING |
| 9 | Technical | Comparison | 1:1 | Italian locale | `ratio_deco_comparison_it.png` | PENDING |
| 10 | Technical | Comparison | 1:1 | Dynamic Type XL | `ratio_deco_dynamic_type_xl_en.png` | PENDING |

## Overlay chart checks

- Overlay card visible in comparison mode
- Depth profile and stop markers readable
- Disclaimer/heuristic copy visible (no decompression-algorithm claim)

## Evidence naming

`Docs/QA_EVIDENCE/RATIO_DECO_SIMULATOR/<scenario>_<locale>_<date>.png`

## Automated coverage (repository)

- `RatioDecoPlannerTests`
- `IOSMainAlgorithmPostAuditTests` (MOD violation)
