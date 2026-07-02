# Release Blocker Burndown Plan — CURRENT

**Baseline:** `main` @ `7ae527b`  
**Date:** 2026-07-02  
**Orchestrator:** V1.7

---

## Summary

| Category | Open blockers |
|---|---:|
| Internal TestFlight | 4 |
| External TestFlight | 8 |
| App Store | 9 |
| Physical QA blockers | 7 |
| External validation blockers | 4 |
| Legal/claims blockers | 3 |

Core blockers are `CF-001`, `CF-002`, `CF-003`, `CF-004`, `CF-007`, `CF-008`, `CF-009`, `CF-011`.

---

## Internal TestFlight blockers

| Blocker_ID | Finding_ID | Severity | Why it blocks release | Current evidence | Required remediation | Required tests | Required physical QA | Required external validation | Expected command | Expected batch | Exit criteria |
|---|---|---|---|---|---|---|---|---|---|---|---|
| ITF-001 | CF-002 | P1 | failing localization parity tests | 1189/1191 and 1830/1832 | repair key namespace parity | Watch+iOS algorithm tests | No | No | R09 | Batch-1 | parity failures zero |
| ITF-002 | CF-007 | P1 | SUPPORT_ROLLBACK gate fail | release audit marked FAIL | rollback evidence rehearsal | release rollback checks | No | No | R11 | Batch-2 | rollback gate PASS |
| ITF-003 | CF-008 | P0 | stale docs baseline can misstate release posture | stale INDEX/README noted | truthfulness refresh | docs truthfulness checks | No | No | R12 | Batch-1 | baseline aligned to 7ae527b |
| ITF-004 | CF-009 | P0 | unsupported CCR claim wording | claim doc unsupported | claim demotion/repair | release claims check | No | Yes | R12 | Batch-1 | no unsupported claims |

---

## External TestFlight blockers

| Blocker_ID | Finding_ID | Severity | Why it blocks release | Current evidence | Required remediation | Required tests | Required physical QA | Required external validation | Expected command | Expected batch | Exit criteria |
|---|---|---|---|---|---|---|---|---|---|---|---|
| ETF-001 | CF-001 | P1 | no independent Buhlmann evidence | DG-EXT-001 open | execute external validation campaign | FC/planner comparison suite | Controlled | Yes | R13 | Batch-4 | signed external evidence |
| ETF-002 | CF-003 | P1 | physical Watch/iOS QA backlog | multiple pending matrices | execute physical campaigns | QA matrix checks | Yes | No | R10 | Batch-3 | signed physical artifacts |
| ETF-003 | CF-004 | P1 | Snorkeling field QA incomplete after software fixes | 7c459cb consumed but pending | close snorkeling QA procedures | snorkeling protocol checks | Yes | No | R10 | Batch-3 | pending rows cleared |
| ETF-004 | CF-010 | P2 | unified logbook manual QA pending | presentation-only audits partial | execute manual QA set | unified logbook checklist | Yes | No | R10 | Batch-3 | manual QA evidence attached |
| ETF-005 | CF-013 | P2 | remediation consumed without closure evidence | status still PARTIAL | close remediation pending matrix | remediation closure checks | Yes | No | R10 | Batch-3 | closure matrix complete |
| ETF-006 | CF-011 | P1 | aggregate readiness remains NOT_READY | release matrix unresolved | close dependency blockers | release gate checks | Yes | Yes | R11 | Batch-4 | external readiness READY |
| ETF-007 | CF-006 | P1 | command-chain integrity unresolved | missing 07 path | command inventory repair | command integrity check | No | No | R01 | Batch-2 | command map aligned |
| ETF-008 | CF-012 | P2 | continuation path unclear | manual continuation needed | explicit continuation policy | orchestrator continuity checks | No | No | R01 | Batch-2 | manual continuation reproducible |

---

## App Store blockers

App Store is blocked by all external TestFlight blockers plus explicit claims/legal blockers (`CF-008`, `CF-009`, `CF-011`).

---

## Burndown phases

### Phase A (Batch-1) quick software wins
- Close `CF-002`, `CF-008`, `CF-009`.

### Phase B (Batch-2) governance and rollback
- Close `CF-007`, `CF-006`, `CF-012`.

### Phase C (Batch-3) physical/manual evidence
- Close `CF-003`, `CF-004`, `CF-010`, `CF-013`.

### Phase D (Batch-4) external and release closure
- Close `CF-001`, then `CF-011`.
