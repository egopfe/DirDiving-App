# Watch Ultra Physical QA — Evidence Folder

**Status: PENDING** — Do not mark PASS without attached files.

**Matrix:** [`Docs/WATCH_ULTRA_PHYSICAL_QA_MATRIX.md`](../../WATCH_ULTRA_PHYSICAL_QA_MATRIX.md)

Place screenshots, videos, sysdiagnose excerpts, and notes here after executing the physical matrix on a real Apple Watch Ultra (or supported Watch hardware per matrix).

---

## Evidence checklist (copy per test session)

| Field | Value |
|---|---|
| Device model | e.g. Apple Watch Ultra 2 |
| watchOS version | |
| iOS companion version (if paired) | |
| Build number | |
| Commit SHA | |
| Entitlement status | water submersion approved / mock fallback |
| Tester | |
| Date | |
| Pass/Fail | **leave blank until evidence attached** |

### Required attachments

- [ ] Auto-depth lifecycle (start/stop) — screenshot or screen recording
- [ ] Underwater callback / stale-depth behavior
- [ ] GPS surface entry/exit (6 s capture windows)
- [ ] Ascent / depth-limit haptics on wrist
- [ ] Mission Mode UI-only verification (no algorithm change)
- [ ] Watch face size readability (41/45/49 mm as applicable)
- [ ] **Mock fallback banner screenshot** — device/build **without** depth entitlement showing `watch.depth_source.mock_fallback` or `live.depth_mock_fallback.badge` copy (see matrix row)
- [ ] Logs (optional): relevant Console filter, no PII beyond test dive

### Notes

- Automated unit tests do **not** substitute for this folder.
- Mark matrix rows PASS only when corresponding files exist in this directory or are linked below.

**Session notes:**

```
(paste pass/fail notes per scenario)
```
