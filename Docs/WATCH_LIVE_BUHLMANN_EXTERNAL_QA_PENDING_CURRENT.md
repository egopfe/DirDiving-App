# Watch Live Bühlmann External QA — Pending

**Updated:** 2026-06-21  
**Software readiness:** 100% (automated gates pass)  
**Release gates below remain PENDING by design**

| Gate | Status | Owner action |
|---|---|---|
| Physical Apple Watch Ultra underwater timing | PENDING | Shallow pool log + 1 Hz tick verification |
| External decompression tool parity (ML-01 CSV) | PENDING | Fill replay scaffolds; compare with normalized GF/rates |
| External Bühlmann constant cross-check | PENDING | Third-party ZH-L16C table spot check |
| External TestFlight Full Computer | PENDING_EXTERNAL_EVIDENCE | Requires physical + external tool |
| App Store Full Computer | PENDING_EXTERNAL_EVIDENCE | Requires external TestFlight gate |

Software artifacts ready for external comparison:

- `Docs/WATCH_LIVE_BUHLMANN_REPLAY_EXPORTS/*_REPLAY_SCAFFOLD_CURRENT.csv`
- `Docs/WATCH_SCHREINER_TEST_VECTOR_MATRIX_CURRENT.csv`
- `Docs/WATCH_MULTILEVEL_DECO_TRANSITION_MATRIX_CURRENT.csv`

See `Docs/WATCH_LIVE_DECO_EXTERNAL_VALIDATION_PLAN_CURRENT.md`.
