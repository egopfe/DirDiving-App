# Readiness to 100 Plan — CURRENT

**Command:** 05 — `05-MASTER_RELEASE_QA_EVIDENCE_COMPLIANCE_AUDIT_COMMAND_V1.5.md` §13  
**Baseline:** `main` @ `2c30412`  
**Audit date:** 2026-07-01

---

## Current Scores

| Dimension | Score | Target 100 Blocker |
|---|---:|---|
| Software QA evidence | 94 | WFC-P2-005 Watch routing tests |
| Physical QA | 0 | All field matrices |
| External validation | 0 | WFC-P1-001 |
| Claims compliance (software) | 96 | Legal review |
| Release readiness (overall) | 72 | Physical + external + legal |

**Policy:** Software-ready may reach **100** for code/tests/docs truthfulness. Release-ready **cannot** reach 100 until physical, external, and legal gates close.

---

## P0 — Before Any Safety-Critical TestFlight

| Item | Status | Action |
|---|---|---|
| Unsupported certification claims | **PASS** | Maintain |
| False physical QA claims | **PASS** | Maintain |
| False external validation claims | **PASS** | Maintain |
| Missing safety-critical test evidence (FC) | **PASS** | 0 P0 FC @ audit 01 |
| Missing entitlement for required feature | **PASS** | Shallow signing aligned |
| Missing privacy manifest | **PASS** | Static review complete |

**P0 open:** **NONE**

---

## P1 — Before Internal TestFlight

| Item | Status @2c30412 | Action |
|---|---|---|
| iOS automated test lane | **CLOSED** | 1655 PASS |
| Command integrity script | **CLOSED** | CONS-046 V1.5 PASS |
| Watch FC dry-run evidence | **PASS** | Software fail-closed |
| Settings/Logbook ownership | **PASS** | Isolation tests |
| Privacy policy alignment | **PASS** | Manifests + strings |
| TestFlight metadata wording | **PASS** | Verify TF notes for shallow dev |
| Basic physical install | **PENDING** | Execute PDQ-W-001 |
| Paired sync smoke | **PENDING** | Execute PDQ-W-016 |

**Internal TestFlight software: READY @2c30412**

---

## P2 — Before External TestFlight

| Item | Status | Action |
|---|---|---|
| Watch test suite fully green | **OPEN** | Fix WFC-P2-005 + Snorkeling progress |
| Full physical matrix | **OPEN** | Batch-8 execution |
| CMAltimeter physical | **OPEN** | WATCH_CMALTIMETER_PHYSICAL |
| WAO / Water Lock / Crown / AB physical | **OPEN** | HWC + WAO gates |
| Shallow wet Gauge/FC | **OPEN** | CONS-042 |
| Snorkeling 12 field QA | **OPEN** | CONS-048 |
| External Bühlmann campaign | **OPEN** | WFC-P1-001 |
| Instruments profiling | **OPEN** | Physical devices |
| App Store metadata draft | **OPEN** | Marketing pack |

---

## P3 — Before App Store

| Item | Status | Action |
|---|---|---|
| Final legal review | **OPEN** | CONS-044 |
| Accessibility manual QA | **OPEN** | VoiceOver field |
| Localization manual QA | **OPEN** | Native speaker review |
| Final release notes | **OPEN** | ASC submission |
| Incident/rollback drill | **OPEN** | Execute drill |
| Full-depth entitlement | **OPEN** | Apple provisioning if claimed |

---

## Workstreams

### Stream A — Software to 100 (est. 1–3 days)

1. Update `WatchWaterAutoOpenPolicyTests` for post-Apnea `divingModeSelection` routing
2. Update `WatchLaunchRoutingPolicyTests` FC predive expectations
3. Fix `SnorkelingRouteProgressCalculatorTests/testProgressAtStartIsNearZero`
4. Re-run Watch suite → target 1152/1152

### Stream B — Physical QA Batch-8 (est. 2–4 weeks)

Execute templates in `Docs/QA_EVIDENCE/` — CMAltimeter, WAO, shallow wet, paired sync, Apnea wet, Snorkeling 12.

### Stream C — External Validation (est. 2–6 weeks)

Execute Bühlmann external plan; optional Subsurface round-trip.

### Stream D — Legal / App Store (est. 2–4 weeks)

Counsel review, screenshots, ASC metadata, full-depth entitlement decision.

---

## Milestones

| Milestone | Criteria | ETA class |
|---|---|---|
| Software 100% | 1152/1152 Watch + 1655 iOS + scripts PASS | Days |
| Internal TF field-ready | Stream A + basic install smoke | 1 week |
| External TF candidate | Streams B partial + external plan start | 4–6 weeks |
| App Store candidate | All streams complete | 8–12 weeks |

---

## Non-Regression Rule

Any remediation touching FC math, timing, gases, GF, decompression, pressure/depth, checkpoint/restore, or schedule generation **must rerun audits 01, 03, 04, 05, 07** before claiming readiness improvement.
