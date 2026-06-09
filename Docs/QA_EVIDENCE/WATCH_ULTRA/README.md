# Watch Ultra Physical QA — Evidence Folder

**Status: PENDING** — Do not mark PASS without attached files.

**Matrix:** [`Docs/WATCH_ULTRA_PHYSICAL_QA_MATRIX.md`](../../WATCH_ULTRA_PHYSICAL_QA_MATRIX.md)  
**Hardware checklist:** [`Docs/WATCH_MAIN_HARDWARE_ALGORITHM_QA_CHECKLIST.md`](../../WATCH_MAIN_HARDWARE_ALGORITHM_QA_CHECKLIST.md)

---

## Scope

Physical Apple Watch Ultra (or supported Watch hardware per matrix) validation: submersion depth entitlement, auto-depth lifecycle, stale-depth behavior, GPS surface policy, ascent/depth-limit haptics, Mission Mode UI-only verification, and mock-fallback banner when entitlement is absent. Unit tests do not substitute for wrist evidence.

---

## Required device / simulator matrix

| Device | watchOS | Pairing | Entitlement |
|--------|---------|---------|-------------|
| Apple Watch Ultra 2 (preferred) | Release target | Paired iPhone with companion build | Water submersion approved **or** mock fallback documented |
| 41 / 45 / 49 mm readability | As applicable | — | Clipping pass with live badges |

---

## Required evidence files

- [ ] Auto-depth lifecycle (start/stop) — screenshot or screen recording
- [ ] Underwater callback / stale-depth behavior
- [ ] GPS surface entry/exit (6 s capture windows)
- [ ] Ascent / depth-limit haptics on wrist
- [ ] Mission Mode UI-only verification (no algorithm change)
- [ ] Watch face size readability (41/45/49 mm as applicable)
- [ ] **Mock fallback banner** — build without depth entitlement showing `watch.depth_source.mock_fallback` or badge copy
- [ ] Logs (optional): Console filter, no PII beyond test dive

---

## Sign-off

| Field | Value |
|-------|-------|
| Device model | e.g. Apple Watch Ultra 2 |
| watchOS version | |
| iOS companion version (if paired) | |
| Build number | |
| Commit SHA | |
| Entitlement status | submersion approved / mock fallback |
| Tester | |
| Date | |
| Pass/Fail | **PENDING** |

Mark matrix rows PASS only when corresponding files exist in this directory.

**Session notes:**

```
(paste pass/fail notes per scenario)
```
