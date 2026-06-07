# Logbook tissue analytics — future Bühlmann replay (not implemented)

**Status:** Future work · **Current behavior:** simulated estimate (`TissueAnalyticsService.buildFromSession`, `source: .simulated`)

DIR DIVING logbook tissue/narcosis analytics today uses a **fixed-GF informational estimate** from recorded/manual depth samples and gas labels. It is **not** a full Bühlmann ZHL-16C replay of the logged profile.

## What full replay would require

1. **Recorded profile fidelity**
   - High-resolution depth/time samples (not only max/avg)
   - Accurate gas switches with depths and mix fractions
   - Surface interval before the dive when modeling repetitive state

2. **Engine inputs**
   - GF Low / GF High configuration matching user expectation or logged metadata
   - Bühlmann gas schedule reconstruction (bottom, travel, deco roles)
   - Initial tissue state from prior dive snapshot when applicable

3. **Validation**
   - Golden fixtures for logged-profile replay vs planner replay on identical synthetic profiles
   - Edge cases: manual dives, imported CSV with partial metadata, missing gas switches

4. **UX / safety**
   - Clear labeling that replay remains **reference-only / non-certified**
   - No implication of decompression validation for logged dives

## Current mitigation (implemented)

- UI footnote on simulated traces (`tissue_analytics.source.simulated_footnote`)
- Logbook entry subtitle distinguishes estimate vs planner replay
- Planner path remains real Bühlmann tissue history replay

Implement replay only when the above can be tested without weakening existing logbook behavior.
