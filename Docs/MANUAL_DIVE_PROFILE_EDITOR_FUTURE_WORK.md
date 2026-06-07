# Manual dive profile editor — future work

**Status:** Not implemented · **Current behavior:** trapezoidal synthetic profile from max/avg depth (`ManualDiveSampleBuilder`)

## Current mitigation (implemented)

- UI disclosure: `manual_dive.synthetic_profile.disclosure` (EN/IT)
- Logbook tissue/narcosis uses `simulated` source for manual dives
- Entry subtitle: `tissue_analytics.logbook.entry.subtitle.manual_synthetic`

## Future editor scope (not in MAIN today)

1. **Point-by-point depth editor** — user-drawn or imported depth/time points with validation
2. **Gas switch history** — depth + mix per segment (required for multigas Bühlmann replay)
3. **Import from dive computer** — Subsurface/UDCF/CSV with metadata preservation
4. **Validation constraints** — monotonic time, max depth caps, gas fraction bounds
5. **Bühlmann replay prerequisites** — documented in [`LOGBOOK_TISSUE_REPLAY_FUTURE_WORK.md`](LOGBOOK_TISSUE_REPLAY_FUTURE_WORK.md)
6. **Safety copy** — reference-only; never certified decompression validation

## Non-goals

- Full profile editor in this pass (too high risk for MAIN readiness)
- Presenting manual synthetic profiles as recorded Bühlmann validation
