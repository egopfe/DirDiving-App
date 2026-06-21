# DIR DIVING — UI/UX Remediation Plan (Current)

**Command:** 14 — Mockup visual regression audit follow-up  
**Date:** 2026-06-20  
**Source audit:** [`MOCKUP_VISUAL_REGRESSION_AUDIT_CURRENT.md`](MOCKUP_VISUAL_REGRESSION_AUDIT_CURRENT.md)  
**Baseline HEAD:** `ba14d17`  
**Scope:** Ordered remediation — **do not implement in this audit pass**

Prior Command 15 software remediation is **complete** (`validate_ui_ux_readiness.sh` PASS). This plan addresses **remaining mockup visual-regression gaps** only.

---

## Readiness targets

| Layer | Current | Target |
|-------|--------:|-------:|
| Path / hash validation | 100% | 100% |
| Implementation traceability | 98% | 100% |
| Deterministic fixtures | 97% | 100% |
| iOS raster snapshot regression | 0% | 80%+ |
| Physical pixel-diff baselines | 0% | 100% evidence |
| Manual visual fidelity scoring | 40% | 90%+ |
| **Overall mockup visual regression** | **82%** | **95%+ software / 100% with physical evidence** |

---

## Phase 0 — Documentation alignment (P3, no runtime risk)

| Order | ID | Action | Effort |
|-------|-----|--------|--------|
| 0.1 | MVR-P3-001 | Update `mockups/README.md` — local 59 PNGs present; design archive is optional mirror | S |
| 0.2 | MVR-P3-002 | Archive or relink 2 legacy `Docs/ReferenceUI/` PNGs to `Docs/ReferenceUI/archive/` | S |
| 0.3 | — | Cross-link Command 14 matrices from `Docs/INDEX.md` | S |

---

## Phase 1 — Close fixture gaps (P2, software)

| Order | ID | Action | Effort |
|-------|-----|--------|--------|
| 1.1 | MVR-P2-001 | Add presentation fixtures for `FC_UI_04` (settings activity default) and `FC_UI_07` (iOS plan transfer) | M |
| 1.2 | — | Extend `FullComputerMockupReferenceMatrixTests` to require 25/25 `hasExecutableFixture` | S |

---

## Phase 2 — iOS snapshot regression (P1, software)

| Order | ID | Action | Effort |
|-------|-----|--------|--------|
| 2.1 | MVR-P1-001 | Add optional iOS snapshot tests for companion selection + 3 Snorkeling screens (deterministic fixtures) | L |
| 2.2 | — | Add iOS snapshot subset for Apnea dashboard + logbook (5 screens) | L |
| 2.3 | — | Wire subset into `validate_ui_ux_readiness.sh` | M |

**Note:** Snapshots must use `IOSMockupPreviewFixtures` fixed dates/locale — not production data.

---

## Phase 3 — Physical visual QA (P1/P2, external evidence)

| Order | ID | Action | Devices | Effort |
|-------|-----|--------|---------|--------|
| 3.1 | MVR-P1-002 | Capture side-by-side mockup vs runtime screenshots for FC NDL green/yellow/red | Ultra | M |
| 3.2 | MVR-P2-002 | Score visual fidelity column in implementation matrix (WORKING / PARTIAL / GAP) | Ultra + iPhone | L |
| 3.3 | MVR-P2-004 | 41 mm Watch layout pass — `QA_EVIDENCE/SNORKELING_WATCH_LAYOUTS/` | 41 mm | M |
| 3.4 | MVR-P3-003 | Dynamic Type XL planner visual pass — `QA_EVIDENCE/IOS_ACCESSIBILITY/` | Smallest iPhone | M |
| 3.5 | MVR-P2-003 | Re-verify Apnea/Snorkeling dashboard cards after pixel-diff | iPhone | S |

**Rule:** No PASS without artifacts in evidence folders.

---

## Phase 4 — Accessibility visual journey (P2, ties Command 13/14)

| Order | ID | Action | Effort |
|-------|-----|--------|--------|
| 4.1 | — | Execute `QA_EVIDENCE/DYNAMIC_TYPE_VOICEOVER/LEGAL_JOURNEY_TEMPLATE.md` on device | L |
| 4.2 | — | VoiceOver pass on Watch Apnea/Snorkeling mockup-aligned stages | M |

---

## Phase 5 — Release gate integration

| Order | Action | Effort |
|-------|--------|--------|
| 5.1 | Add mockup path hash check to CI (compare CSV SHA-256 vs disk) | M |
| 5.2 | Fail release gate if `embedded_in_live_ui=yes` ever appears in matrix | S |
| 5.3 | Block App Store screenshot submission until `APP_STORE_MARKETING` evidence PASS | S |

---

## Non-goals (this plan)

- Embedding mockup PNGs in app bundles
- Using mockups as App Store marketing without legal/marketing sign-off
- Claiming visual PASS from simulator tests alone
- Redesigning unrelated screens

---

## Acceptance criteria (remediation complete)

- [ ] 59/59 paths VALID with CI hash check
- [ ] 59/59 `fixture_exists=yes` OR documented N/A with alternate test
- [ ] iOS snapshot subset ≥ 8 screens in CI
- [ ] Physical pixel-diff evidence for FC + Apnea + Snorkeling primary flows
- [ ] Visual fidelity column scored for all 59 rows
- [ ] `validate_ui_ux_readiness.sh` includes mockup hash gate
- [ ] Overall mockup visual regression ≥ 95% software / physical evidence attached

---

## Related

- [`MOCKUP_VISUAL_REGRESSION_AUDIT_CURRENT.md`](MOCKUP_VISUAL_REGRESSION_AUDIT_CURRENT.md)
- [`DIR_DIVING_UI_UX_PHYSICAL_QA_PENDING_CURRENT.md`](DIR_DIVING_UI_UX_PHYSICAL_QA_PENDING_CURRENT.md)
- [`DIR_DIVING_UI_UX_REMEDIATION_REPORT_CURRENT.md`](DIR_DIVING_UI_UX_REMEDIATION_REPORT_CURRENT.md)
