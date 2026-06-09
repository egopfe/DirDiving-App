# Watch Ultra Physical QA Matrix

Owner: ________  Date: ________  Build: ________  Commit: ________

**Gate note (2026-06-07):** Automated audit remediation complete; **physical matrix still required** before external TestFlight. Prioritize: submersion depth entitlement, ascent/depth-limit haptics underwater, paired sync ACK path.

| Scenario | Pass/Fail | Evidence | Notes |
|---|---|---|---|
| **Mock fallback banner (no entitlement)** | **PENDING** | Screenshot in [`QA_EVIDENCE/WATCH_ULTRA/`](QA_EVIDENCE/WATCH_ULTRA/README.md) | Must show `watch.depth_source.mock_fallback` or badge copy; do not mark PASS without file |
| Auto-depth lifecycle (start/stop) |  |  | Mock fallback must show unavailable copy if no entitlement |
| Underwater callback availability |  |  |  |
| Stale-depth behavior and warning |  |  |  |
| GPS surface entry/exit policy |  |  | See [`WATCH_GPS_LIFECYCLE_POLICY.md`](WATCH_GPS_LIFECYCLE_POLICY.md) |
| Haptics behavior (ascent red zone repeat ~1.75 s) |  |  | Regression covered in unit tests; verify on wrist |
| Alarms visibility/acknowledge |  |  |  |
| Mission Mode invariant (internal profile only) |  |  | No algorithm change |
| Watch 41/45/49 clipping/readability |  |  |  |
| Underwater readability |  |  |  |
| Sync pending queue — offline then ACK |  |  | See [`WATCH_IOS_SYNC_QA_MATRIX.md`](WATCH_IOS_SYNC_QA_MATRIX.md) |
