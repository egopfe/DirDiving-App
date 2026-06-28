# Master Release Blocker Burndown Plan — Current

**Baseline:** `main` @ `7dfefe2`  
**Orchestrator:** V1.2 · 2026-06-28  
**Overall release readiness:** ~**71%** · Verdict **PARTIAL**

---

## Release gate status

| Gate | Status | Primary blockers | Est. closure batch |
|------|--------|------------------|-------------------|
| Internal TestFlight | **CONDITIONAL** | CONS-014 (2 Watch test fails); CONS-002..008 P1 software | Batch 0 + 2 + 4 |
| External TestFlight | **NOT READY** | All physical QA 0%; CONS-009 external; CONS-002 GF | Batch 8 |
| App Store | **NOT READY** | External TF blockers + CONS-044 legal + shallow/FC claims | Batch 8 + 9 |

**P0 software safety (Watch FC forensic): 0** · **P0 doc/process: 1** (CONS-001 command permutation)

---

## Blocker inventory by category

### P0 — Process (1)

| ID | Blocker | Burndown action | Owner batch | Target |
|----|---------|-----------------|-------------|--------|
| CONS-001 | `commands_for_cursor/01`–`04` permuted | Restore bodies; orchestrator STOP guard | Batch-9 | Day 1–2 |

### P1 — Software (8)

| ID | Blocker | Burndown action | Owner batch | Target |
|----|---------|-----------------|-------------|--------|
| CONS-002 | GF iOS 20/70,30/80 ≠ Watch 20/80,30/70 | Align presets + import field | Batch-4 | Week 1 |
| CONS-003 | Sync in-flight stuck | Clear inFlight on ACK failure paths | Batch-2 | Week 1 |
| CONS-004 | userInfo ACK gap | Symmetric diveImportAck | Batch-2 | Week 1 |
| CONS-005 | Legacy unsigned tombstones | Require HMAC when signed path available | Batch-2 | Week 1 |
| CONS-006 | Shallow FC dev toggle exposure | Default OFF + internal labeling + process | Batch-7 | Week 1–2 |
| CONS-007 | Depth tier plist vs signing | CI manifest parity test | Batch-7 | Week 1–2 |
| CONS-008 | Oracle uses production projection | Independent simulator or tolerance doc | Batch-1 | Week 2 |

### P1 — Evidence / physical (8)

| ID | Blocker | Burndown action | Owner batch | Target |
|----|---------|-----------------|-------------|--------|
| CONS-009 | External Bühlmann 0% | Execute external validation plan | Batch-8 | Week 3–4 |
| CONS-010 | Watch Ultra wet depth 0% | Physical QA matrix | Batch-8 | Week 2 |
| CONS-011 | Paired sync 0% | Paired device campaign | Batch-8 | Week 2 |
| CONS-012 | Manual a11y 0% | VoiceOver/Dynamic Type matrix | Batch-6/8 | Week 2 |
| CONS-013 | PDF render evidence | Device golden PDFs | Batch-9 | Week 3 |
| CONS-021 | WAO physical 0% | WAO-G-008..015 execution | Batch-8 | Week 2 |
| CONS-022 | Underwater HW 0% | Crown/Action Button/Water Lock | Batch-8 | Week 2 |
| CONS-042 | Shallow wet QA 0% | Shallow depth gate matrix | Batch-8 | Week 2 |
| CONS-044 | Legal/marketing unsigned | Counsel + marketing sign-off | Batch-9 | Week 4 |

---

## Burndown phases

### Phase A — Unblock software + audit integrity (Days 1–7)

- [ ] Batch 0: CONS-014 → 1091 Watch tests PASS
- [ ] Batch 9: CONS-001 command repair
- [ ] Batch 4: CONS-002 GF alignment
- [ ] Batch 2: CONS-003..005 sync fixes
- [ ] Batch 6: CONS-019 WAO policy gate

**Exit criteria:** Internal TestFlight **CONDITIONAL → READY (software)**; trustworthy audit re-run enabled

### Phase B — Physical campaigns (Days 8–14)

- [ ] CONS-010 Ultra depth/CMAltimeter
- [ ] CONS-042 shallow wet QA
- [ ] CONS-021 water auto-open physical
- [ ] CONS-022 underwater hardware
- [ ] CONS-011 paired sync + security
- [ ] CONS-012 accessibility spot checks

**Exit criteria:** ≥1 signed artifact per P1 physical gate; physical readiness **0% → 40%**

### Phase C — External + release (Days 15–30)

- [ ] CONS-009 external Bühlmann
- [ ] CONS-043 GF preset external spot-check
- [ ] CONS-030 Subsurface round-trip
- [ ] CONS-013 PDF + CONS-044 legal
- [ ] CONS-034 documentation INDEX
- [ ] Rerun orchestrator 00 @ new HEAD

**Exit criteria:** External TestFlight **CONDITIONAL**; App Store **CONDITIONAL** pending Apple review

---

## Metrics tracker

| Metric | Current @ 7dfefe2 | Phase A target | Phase B target | Phase C target |
|--------|------------------:|---------------:|---------------:|---------------:|
| Overall release readiness | 71% | 78% | 85% | 92% |
| Watch FC software | 87% | 92% | 92% | 95% |
| Physical QA execution | 0% | 0% | 40% | 75% |
| External validation | 0% | 0% | 10% | 60% |
| Open P1 software | 8 | 0 | 0 | 0 |
| Open P1 evidence | 9 | 9 | 3 | 0 |

---

## SOFTWARE_READY vs PENDING_PHYSICAL (preserve in burndown)

| Area | Software status | Physical status | Do not conflate |
|------|-----------------|-----------------|-----------------|
| Water auto-open | PASS @ 7dfefe2 | NOT_EXECUTED | CONS-021 |
| Crown / Action Button | PASS | NOT_EXECUTED | CONS-022 |
| GF presets (Watch) | PASS | External pending | CONS-043 |
| Shallow depth UI | PASS | Wet QA pending | CONS-042 |

---

**BURNDOWN_PLAN_STATUS: ACTIVE @ 7dfefe2**
