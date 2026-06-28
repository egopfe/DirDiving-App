# Master Main Code Remediation Plan (Current)

**Audit command:** 04 — MASTER MAIN CODE / SYNC / SECURITY / PERFORMANCE AUDIT V1.0  
**Branch:** `main` @ `7dfefe2`  
**Date:** 2026-06-28

---

## Executive summary

Re-audit of `main` @ `7dfefe2` consolidates five merged audit scopes plus 4A (GF presets, shallow depth, water auto-open, developer settings).

**Five open P1 software findings** require remediation before internal TestFlight confidence. **Nine P2** findings (six physical QA + three software). Architecture, activity isolation, and release simulation safety remain strong.

| Category | Software readiness | Blocker for internal TestFlight |
|----------|-------------------|--------------------------------|
| Architecture / isolation | 97% | No |
| Sync / schema | 90% | P1 ACK + tombstone + in-flight |
| Security / privacy | 94% | P1 tombstone compat |
| Performance (software) | 86% | P1 sync stuck + planner lifecycle |
| Depth / developer gates | 92% | P1 shallow FC process risk |
| Test coverage (automated) | 95% | Physical matrices |

---

## Priority 0 — None open

No cross-activity corruption, HMAC bypass, water-auto-open live-runtime bypass, or simulation-in-release defects at `7dfefe2`.

---

## Priority 1 — Open (software)

| ID | Finding | Remediation | Tests |
|----|---------|-------------|-------|
| MASTER-PERF-006 | iOS sync in-flight stuck | Clear `inFlightOutboundSessionIDs` on ACK failure, encode error, userInfo fallback | Negative ACK failure test |
| MASTER-SYNC-002 | Watch→iOS userInfo ACK gap | Send `diveImportAck` from iOS `didReceiveUserInfo` import path | Round-trip userInfo test |
| MASTER-SYNC-003 | Legacy unsigned tombstones | Reject `dirdiving_deleted_session_ids` when signed path available | Tombstone negative test |
| MASTER-DEPTH-001 | Shallow FC internal exposure | Enforce TestFlight process; strengthen internal-only labeling; optional hard block without toggle | Manual QA gate |
| MASTER-DEPTH-002 | Tier metadata trust | CI manifest check: entitlements file ↔ Info.plist tier | Signing manifest test |

---

## Priority 2 — Open

| ID | Finding | Remediation |
|----|---------|-------------|
| MASTER-PERF-001..004 | Physical battery/sync/scroll/map | Execute `MASTER_PHYSICAL_PERFORMANCE_QA_PLAN_CURRENT.md` |
| MASTER-SEC-001 | Field sync security | Paired-device SEC-NEG matrix |
| MASTER-SYNC-001 | Large payload field | Paired 5MB round-trip |
| MASTER-WAO-001 | Water FC policy skip | Apply `DepthCapabilityPolicy` before FC water routing |
| MASTER-WAO-002 | Probe timeout | Physical submerged launch QA; evaluate adaptive timeout |
| MASTER-PERF-007 | Planner lifecycle | Cancel tasks in `deinit`; move `refreshAnalysis` off main |

---

## Priority 3 — Monitor / profiling

- MASTER-IOS-001/002 — Instruments startup and map profiling
- MASTER-PERF-005, MASTER-SEC-002, MASTER-DEPTH-003, MASTER-WAO-DOC — documented accepted risks

---

## Priority 4 — Positive controls (maintain)

INFO-01..10 — no action; regression tests on touch.

---

## Sequencing

1. **Week 1:** P1 sync fixes (PERF-006, SYNC-002, SYNC-003).
2. **Week 1–2:** WAO policy alignment (WAO-001); planner lifecycle (PERF-007).
3. **Week 2–3:** Physical QA plan execution; depth signing CI check (DEPTH-002).
4. **Ongoing:** Instruments profiling; external validation per roadmap.

---

**No production changes in this audit pass.** Remediation requires separate implementation command.
