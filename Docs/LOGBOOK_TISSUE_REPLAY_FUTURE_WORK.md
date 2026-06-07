# Logbook tissue analytics — Bühlmann replay (partial implementation)

**Status:** Partial · **Planner:** full planned Bühlmann replay · **Logbook:** recorded single-gas replay or simulated fallback

## Implemented @ post-V3 remediation

| Source | When | Behavior |
|--------|------|----------|
| `planned` | Planner tissue tab | Real `tissueHistory` from Bühlmann engine |
| `recorded` | Watch/logbook session with ≥2 samples, not manual, non-trimix | Schreiner Bühlmann replay between depth samples, single gas from `gasLabel`, default GF 30/85 |
| `simulated` | Manual dives, trimix without switch history, or incomplete gas data | Minute-step estimate; trapezoidal depth for manual |
| `insufficientData` | &lt;2 depth samples | No presentation (empty state) |

UI labels and footnotes distinguish all sources (EN/IT). Logbook entry subtitle is dynamic per session.

## Still future work (multigas / repetitive)

1. **Gas switch history** on logged dives — required for trimix/deco replay
2. **Surface interval / repetitive state** before dive
3. **User GF settings** persisted per logbook replay (today: default 30/85)
4. **Golden fixtures** — logged profile vs planner on identical synthetic traces
5. **Imported CSV** partial metadata edge cases

See [`BUHLMANN_EXTERNAL_VALIDATION_FIXTURES_TEMPLATE.md`](BUHLMANN_EXTERNAL_VALIDATION_FIXTURES_TEMPLATE.md) for external validation evidence (campaign **PENDING**).

Implement full multigas replay only with fixture-backed tests and without weakening reference-only disclaimers.
