# Master Release Blocker Burndown Plan — Current

**Baseline:** `main` @ `451f8fb` (remediation @ `5d757cc`; Snorkeling @ `dbe5d8b`)  
**Orchestrator:** V1.3 · **Date:** 2026-06-30  
**Overall release readiness:** ~**65%** · Verdict **PARTIAL**

---

## Release gate status

| Gate | Status | Primary blockers | Est. closure batch |
|------|--------|------------------|-------------------|
| Internal TestFlight (software) | **CONDITIONAL** | CONS-049 iOS tests; CONS-046 script | Batch-0 + Script |
| Internal TestFlight (full) | **NOT READY** | Physical QA 0% | Batch-8 |
| External TestFlight | **NOT READY** | Physical 0%; CONS-048 Snorkeling; CONS-009 external; CONS-044 legal | Batch-8 |
| App Store | **NOT READY** | External TF + legal + PDF assets | Batch-8 + 9 |

**P0 open: 0** · **P1 open software: 2** (CONS-046, CONS-049) · **P1 physical/external/legal pending: 10**

---

## Phase status

### Phase A — Software + audit integrity — **COMPLETE @ 5d757cc; audits refreshed @ 451f8fb**

- [x] Batch 0–7 software remediation
- [x] Snorkeling P1/P2/P3 software @ dbe5d8b
- [x] Domain audits 01–06 rerun @ 451f8fb (CONS-047 closed)
- [x] Audit 07 + orchestrator 00 @ 451f8fb
- [ ] CONS-049 iOS test compile fix
- [ ] CONS-046 script fix

**Exit criteria for unconditional internal TF software:** iOS tests green + script PASS

### Phase B — Physical campaigns — **ACTIVE**

- [ ] CONS-048 Snorkeling 12 QA templates
- [ ] CONS-010 Ultra depth/CMAltimeter
- [ ] CONS-042 shallow wet QA
- [ ] CONS-021 water auto-open physical
- [ ] CONS-022 underwater hardware
- [ ] CONS-011 paired sync + security
- [ ] CONS-012 accessibility spot checks

**Exit criteria:** ≥1 signed artifact per P1 physical gate; physical readiness **0% → 40%**

### Phase C — External + release — **PENDING**

- [ ] CONS-009 external Bühlmann
- [ ] CONS-043 GF preset external spot-check
- [ ] CONS-013 PDF + CONS-044 legal

---

## Burndown metrics

| Metric | Current | Target (30d) |
|--------|---------|--------------|
| P0 open | 0 | 0 |
| P1 open software | 2 | 0 |
| Physical QA executed | 0% | ≥40% P1 gates |
| External validation executed | 0% | Bühlmann + GF spot-check |
| iOS Algorithm Tests | BUILD FAIL | 0 failures |
| Command integrity script | FAIL | PASS |

---

## Do not regress

| Area | Status @ 451f8fb | Gate |
|------|------------------|------|
| GF presets (Watch+iOS) | PASS | CONS-002 verified |
| Sync ACK/tombstone | PASS | CONS-003..005 |
| Shallow depth UI | PASS (software) | Wet QA pending CONS-042 |
| WAO policy | PASS (software) | Physical pending CONS-021 |
| Snorkeling route safety | PASS (software) | Field QA pending CONS-048 |
