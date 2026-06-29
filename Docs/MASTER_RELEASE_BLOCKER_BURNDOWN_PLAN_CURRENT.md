# Master Release Blocker Burndown Plan — Current

**Baseline:** `main` @ `8ae1034` (remediation @ `5d757cc`)  
**Orchestrator:** V1.2 refresh · 2026-06-29  
**Overall release readiness:** ~**72%** · Verdict **PARTIAL** · **Software readiness 100%**

---

## Release gate status

| Gate | Status | Primary blockers | Est. closure batch |
|------|--------|------------------|-------------------|
| Internal TestFlight (software) | **READY** | None — P1 software closed @ 5d757cc | **DONE** |
| Internal TestFlight (full) | **CONDITIONAL** | Physical QA 0% | Batch-8 |
| External TestFlight | **NOT READY** | All physical QA 0%; CONS-009 external; CONS-044 legal | Batch-8 |
| App Store | **NOT READY** | External TF + legal + PDF assets | Batch-8 + 9 |

**P0 open: 0** · **P1 software open: 0** · **P1 physical/external/legal pending: 9**

---

## Phase status

### Phase A — Software + audit integrity — **COMPLETE @ 5d757cc**

- [x] Batch 0: CONS-014 VERIFIED — targeted tests PASS
- [x] Batch 9: CONS-001 command repair
- [x] Batch 4: CONS-002 GF alignment
- [x] Batch 2: CONS-003..005 sync fixes
- [x] Batch 6: CONS-019 WAO policy gate
- [x] Batch 7: CONS-006..007 depth authority
- [x] Post-remediation reruns: 01, 02, 04, 05, 06
- [x] Orchestrator 00 refresh @ 8ae1034

**Exit criteria met:** Internal TestFlight software **READY**; trustworthy audit re-run enabled

### Phase B — Physical campaigns — **ACTIVE**

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
- [ ] CONS-030 Subsurface round-trip
- [ ] CONS-013 PDF + CONS-044 legal
- [ ] CONS-034 README/feature matrix (doc-only optional)
- [ ] Optional audit 03 rerun
- [ ] Rerun orchestrator 00 after evidence milestones

**Exit criteria:** External TestFlight **CONDITIONAL**; App Store **CONDITIONAL** pending Apple review

---

## Blocker inventory (remaining)

### P1 — Evidence / physical / legal (9)

| ID | Blocker | Burndown action | Owner batch |
|----|---------|-----------------|-------------|
| CONS-009 | External Bühlmann 0% | Execute external validation plan | Batch-8 |
| CONS-010 | Watch Ultra wet depth 0% | Physical QA matrix | Batch-8 |
| CONS-011 | Paired sync 0% | Paired device campaign | Batch-8 |
| CONS-012 | Manual a11y 0% | VoiceOver/Dynamic Type matrix | Batch-8 |
| CONS-013 | PDF render evidence | Device golden PDFs | Batch-9 |
| CONS-021 | WAO physical 0% | WAO-G-008..015 execution | Batch-8 |
| CONS-022 | Underwater HW 0% | Crown/Action Button/Water Lock | Batch-8 |
| CONS-042 | Shallow wet QA 0% | Shallow depth gate matrix | Batch-8 |
| CONS-044 | Legal/marketing unsigned | Counsel + marketing sign-off | Batch-9 |

---

## Metrics tracker

| Metric | @ 7dfefe2 | @ 8ae1034 | Phase B target | Phase C target |
|--------|----------:|----------:|---------------:|---------------:|
| Overall release readiness | 71% | **72%** | 85% | 92% |
| Software readiness | ~88% | **100%** | 100% | 100% |
| Physical QA execution | 0% | 0% | 40% | 75% |
| External validation | 0% | 0% | 10% | 60% |
| Open P1 software | 8 | **0** | 0 | 0 |
| Open P1 evidence | 9 | 9 | 3 | 0 |

---

## SOFTWARE_READY vs PENDING_PHYSICAL (preserve in burndown)

| Area | Software status | Physical status | Do not conflate |
|------|-----------------|-----------------|-----------------|
| Water auto-open | PASS @ 5d757cc | NOT_EXECUTED | CONS-021 |
| Crown / Action Button | PASS @ 5d757cc | NOT_EXECUTED | CONS-022 |
| GF presets (Watch+iOS) | PASS @ 5d757cc | External pending | CONS-043 |
| Shallow depth UI | PASS @ 5d757cc | Wet QA pending | CONS-042 |
| Sync codec/HMAC | PASS @ 5d757cc | Paired field pending | CONS-011 |

---

**BURNDOWN_PLAN_STATUS: ACTIVE @ 8ae1034 · Phase B next**
