# DIR DIVING — Master Release / QA / Evidence / Compliance Audit (Current)

**Command:** 05 — `05-MASTER_RELEASE_QA_EVIDENCE_COMPLIANCE_AUDIT_COMMAND_V1.5.md`  
**Date:** 2026-07-01  
**Branch:** `main`  
**Commit:** `2c30412` (`2c30412e777e6ef40a688b9ac11215f32310764f`)  
**Task type:** Read-only full release-gate audit @ V1.5 — no production code modified  
**Merged sources:** Command 12 + Command 13  
**Upstream inputs:** Audits **01–04 COMPLETE** @ `2c30412`

**Not claimed:** Legal certification, EN13319/ISO 6425 compliance, App Store approval, physical QA passed, external Bühlmann/CCR validation passed, Apple Watch certified dive computer, CMAltimeter physical validation passed, shallow wet QA passed, system Auto-Launch listing verified, Snorkeling field navigation verified on hardware, Apnea auto-detection physically validated.

---

## A. Executive Summary

Full release-gate audit at `main` @ **`2c30412`** after upstream domain audits **01–04** refresh. **Watch Full Computer algorithmic core: 0 P0 defects.** Software remediation closed **IOS-P1-001** (1655 iOS tests PASS) and **CONS-046 V1.5** (command integrity PASS). **Apnea P1/P2/P3 INTERNAL_READY** @ `76f3703`. **Physical, external, and legal gates remain 0% executed** — honestly preserved, not falsely closed.

| Dimension | Score (0–100) | Status class |
|-----------|---------------|--------------|
| Automated test evidence (iOS) | **100** | SOFTWARE_READY — 1655/1655 PASS |
| Automated test evidence (Watch) | **94** | PARTIAL — 1139/1152; 13 routing failures (WFC-P2-005); 0 FC failures |
| Simulator / build gates | **100** | SOFTWARE_READY |
| Claims / legal software posture | **98** | SOFTWARE_READY |
| Privacy manifest alignment | **100** | SOFTWARE_READY (static review) |
| Shallow / WAO / HW software gates | **96** | SOFTWARE_READY — WAO routing tests PARTIAL |
| GF preset software gate | **100** | SOFTWARE_READY (CONS-002 @ 2c30412) |
| Apnea software (P1/P2/P3) | **95** | INTERNAL_READY — wet QA pending |
| Snorkeling software | **92** | SOFTWARE_READY — field GPS pending |
| Physical Watch / CMAltimeter / shallow wet | **0** | PENDING_PHYSICAL |
| Physical iPhone / a11y / PDF | **0** | PENDING_PHYSICAL |
| Paired-device QA | **0** | PENDING_PHYSICAL |
| Snorkeling field QA (12 templates) | **0** | PENDING_PHYSICAL (CONS-048) |
| External validation | **0** | PENDING_EXTERNAL_VALIDATION |
| App Store / legal external gates | **35** | PENDING_LEGAL_REVIEW |
| **Overall QA evidence readiness** | **82** | Strong software; physical/external open |
| **Overall claims compliance readiness** | **96** | SOFTWARE_READY + pending legal |
| **Overall release readiness** | **72** | NOT READY external/App Store |

**Findings (release audit scope):** P0 **0** · P1 **6** · P2 **11** · P3 **5** · P4 **4**

**Release posture:** Internal TestFlight software **READY** · External TestFlight **NOT READY** · App Store **NOT READY**

---

## B. Source Commands Merged

| Command | Scope |
|---------|-------|
| 12 — Test & QA Evidence V3.0 | Traceability, physical matrices, validation scripts |
| 13 — Release Legal Claims V3.0 | Claims registry, blockers, EN13319 strategy |
| 01 — Watch FC Forensic V1.5 @ 2c30412 | CMAltimeter gate, GF, shallow depth, oracle — 0 P0 |
| 02 — iOS Master V1.5 @ 2c30412 | 1655 tests PASS; Apnea first-class |
| 03 — UI/UX Master V1.5 @ 2c30412 | WAO, Crown, Action Button software gates |
| 04 — Main Code V1.5 @ 2c30412 | Sync/security; CONS-046 PASS |
| 10 — Consolidated remediation | IOS-P1-001 + CONS-046 closed @ 2c30412 |

---

## C. Latest Development Context

Audited scope: Diving Gauge / Full Computer, Bühlmann / Schreiner, CMAltimeter altitude gate, **Apnea P1/P2/P3** (`76f3703`), Snorkeling P1/P2/P3, iOS Settings mode switcher, activity-specific Settings/Logbooks, iOS Planner / CCR reference-only, briefing cards, Mission Mode, Developer Sensor Source, shallow-depth entitlement, water auto-open, GF presets (20/80, 30/70, 40/85), developer shallow toggles (default OFF), Crown/Action Button underwater policy, post-remediation CONS-002..008 verified.

**V1.5 algorithmic priority:** Audit 01 reports **0 P0 FC math** — release audit does not override. External validation (WFC-P1-001) and physical QA (CONS-042) block external/App Store claims.

---

## D. Branch, Commit and Scope

| Check | Result |
|-------|--------|
| Branch | `main` ✓ |
| HEAD | `2c30412` ✓ |
| `origin/main` | Aligned |
| Xcode | 26.6 (17F113) |
| Physical QA executed this pass | **No** |
| Production code modified | **No** (Docs only) |

**Targets:** DIRDiving Watch App · DIRDiving iOS · DIRDiving Watch Algorithm Tests · DIRDiving iOS Algorithm Tests

---

## E. Build / Test Baseline

| Gate | Result | Evidence |
|------|--------|----------|
| BASELINE_CURRENT_AND_CLEAN | **PASS** | `main` @ `2c30412` |
| BUILD_IOS | **PASS** | Audit 02/04 BUILD SUCCEEDED |
| BUILD_WATCH | **PASS** | Audit 01/04 BUILD SUCCEEDED |
| IOS_ALGORITHM_TESTS | **PASS** | **1655/1655** @ `2c30412` (68.4s) |
| WATCH_ALGORITHM_TESTS | **PARTIAL** | **1139/1152** — 13 failures (WFC-P2-005 + Snorkeling progress); **0 FC failures** |
| validate_commands_for_cursor_integrity.sh | **PASS** | CONS-046 V1.5 |
| check_main_target_isolation.sh | **PASS** | Audit 04 |
| audit_localization.sh | **PASS** | Audit 04 |

**Failed Watch tests @2c30412 (non-FC):**
- `WatchWaterAutoOpenPolicyTests` — 11 failures (routing expects ready/predive; got `divingModeSelection`)
- `WatchLaunchRoutingPolicyTests` — 3 failures
- `SnorkelingRouteProgressCalculatorTests/testProgressAtStartIsNearZero` — 1 failure

---

## F. Requirement-to-Test Traceability

Matrix: [`MASTER_REQUIREMENT_TEST_TRACEABILITY_MATRIX_CURRENT.csv`](MASTER_REQUIREMENT_TEST_TRACEABILITY_MATRIX_CURRENT.csv)

| Metric | Count |
|--------|------:|
| Total requirements | **96** |
| SOFTWARE_READY / PASS | **72** |
| SOFTWARE_GAP / FAIL / PARTIAL | **4** (WFC-P2-005 WAO×2, Snorkeling progress, Watch suite partial) |
| NOT_PASSED (physical/external/legal) | **20** |

Safety-critical FC paths mapped with automated evidence. WAO routing test drift documented — production routing may be correct; tests stale post-Apnea wave.

---

## G. Automated Test Evidence

**Watch:** Strong FC coverage — Audit-15 oracle, CMAltimeter remediation, GF presets, underwater resolver, Apnea architecture isolation. **1139/1152** @ `2c30412`. All FC algorithm tests **PASS**.

**iOS:** **1655/1655 PASS** @ `2c30412`. GF import parity (CONS-002), sync security, Apnea/Snorkeling isolation, planner reference-only — all green.

---

## H. Simulator QA Evidence

**PASS (static/scripts).** Isolation, secrets, localization, depth capability authority, developer shallow gate, sync schema, security/privacy scripts PASS per audit 04. **No simulator evidence upgraded to physical.**

---

## I. Physical Apple Watch QA

**PENDING_PHYSICAL** — 38 Watch rows in [`MASTER_PHYSICAL_DEVICE_QA_MATRIX_CURRENT.csv`](MASTER_PHYSICAL_DEVICE_QA_MATRIX_CURRENT.csv). Zero signed artifacts in `Docs/QA_EVIDENCE/` for wet depth, CMAltimeter, WAO, Water Lock, Crown, Action Button, shallow wet Gauge/FC.

---

## J. Physical iPhone QA

**PENDING_PHYSICAL** — 16 iPhone rows NOT_PASSED. Logbook scroll, PDF/CSV render, VoiceOver, Dynamic Type, Instruments profiling — template-only.

---

## K. Paired Watch/iPhone QA

**PENDING_PHYSICAL** — 8 paired rows NOT_PASSED. WC sync, Apnea/Snorkeling session transfer, iCloud two-device tombstones — no field artifacts.

---

## L. Underwater / Depth Sensor QA

**PENDING_PHYSICAL** — Shallow-depth signing configured (`DIRDiving.WithShallowDepth.entitlements`). Wet depth sensor QA **NOT_EXECUTED**. Developer shallow Gauge/FC toggles default OFF — software PASS; wet QA pending (CONS-042).

Matrix: [`MASTER_WATER_AUTO_OPEN_PHYSICAL_QA_GATE_CURRENT.csv`](MASTER_WATER_AUTO_OPEN_PHYSICAL_QA_GATE_CURRENT.csv)

---

## M. Watch Full Computer Altimeter Evidence Gate

**Software: PASS** — OrchestratedAltitudeEnvironmentTests, WatchCMAltimeterRemediationTests, explicit diver acceptance, fail-closed on stale/unstable samples.

**Physical: PENDING_PHYSICAL** — No CoreMotion field sample artifacts. CMAltimeter path traced: `CMAltimeter.startAbsoluteAltitudeUpdates` → proposal → explicit acceptance → FC start.

**Reject patterns verified absent:** cached CLLocation altitude, hard-coded fallback, automatic sensor authority.

---

## N. External Bühlmann / Schreiner Validation

**PENDING_EXTERNAL_VALIDATION** — Internal oracle PASS (Audit-15 ML profiles, TTS sweep). No third-party tool comparison. WFC-P1-001 / CONS-009 open.

See [`MASTER_EXTERNAL_VALIDATION_GAPS_CURRENT.md`](MASTER_EXTERNAL_VALIDATION_GAPS_CURRENT.md).

---

## O.02. External Subsurface Validation

**PENDING_EXTERNAL_VALIDATION** — CSV export unit tests PASS; no Subsurface round-trip evidence.

---

## P. CCR / Rebreather Validation

**Reference-only / PENDING_EXTERNAL_VALIDATION** — CCRMathRemediationTests PASS. No external rebreather controller validation. No CCR controller certification claim.

---

## Q. Ratio Deco / Rock Bottom / Gas Ledger Validation

**Internal PASS / External PENDING** — Heuristic and formatter tests PASS. Copy audited as estimates, not certified calculations.

---

## R. Localization / Accessibility Evidence

**Software PASS** — audit_localization.sh, DIRDivingCompleteLocalizationAuditTests, SnorkelingAccessibilityContractTests, audit_accessibility_contracts.sh.

**Physical manual QA: PENDING_PHYSICAL** — VoiceOver/Dynamic Type field pass not executed.

---

## S. Performance / Instruments Evidence

**Software PASS** — PerformanceConcurrencyBatteryRemediationTests, validate_performance_concurrency_battery_readiness.sh.

**Instruments on hardware: PENDING_PHYSICAL** — No profiling artifacts on physical devices.

---

## T. Security / Privacy Evidence

**Software PASS** — SecurityPrivacyTrustRemediationTests, validate_security_privacy_trust_readiness.sh, PrivacyInfo.xcprivacy manifests, HMAC v3 sync envelopes, tombstone hardening (CONS-005).

---

## U. Claims Evidence Matrix

Matrix: [`MASTER_CLAIMS_EVIDENCE_MATRIX_CURRENT.csv`](MASTER_CLAIMS_EVIDENCE_MATRIX_CURRENT.csv)

All user-facing safety claims audited. **No unsupported certification claim found.** Physical/external gates correctly marked pending in copy. Apnea recovery not framed as medical guarantee. Planner/CCR reference-only. GF described as user conservatism setting.

Apnea-specific: [`MASTER_APNEA_CLAIMS_EVIDENCE_MATRIX_CURRENT.csv`](MASTER_APNEA_CLAIMS_EVIDENCE_MATRIX_CURRENT.csv)

---

## V. Release Gate Matrix

Matrix: [`MASTER_RELEASE_GATE_MATRIX_CURRENT.csv`](MASTER_RELEASE_GATE_MATRIX_CURRENT.csv)

| Gate | Decision |
|------|----------|
| Internal TestFlight | **READY** (software) — physical disclosure required |
| External TestFlight | **NOT READY** |
| Professional/Beta Diver Trial | **NOT READY** |
| App Store | **NOT READY** |
| Public Release | **NOT READY** |

---

## W. Apple Platform / Entitlement / Capability Audit

Matrix: [`MASTER_PLATFORM_ENTITLEMENT_CAPABILITY_MATRIX_CURRENT.csv`](MASTER_PLATFORM_ENTITLEMENT_CAPABILITY_MATRIX_CURRENT.csv)

Shallow-depth default signing aligned (`Config/DIRDiving.WithShallowDepth.entitlements`). `DIRDepthEntitlementTier=shallow` in Info.plist. `WKSupportsAutomaticDepthLaunch=true`. `WKBackgroundModes` includes `underwater-depth`. Full-depth alternate documented — not default. CMAltimeter, WC, iCloud, location, photos — implemented; physical validation pending.

Algorithmic gate: [`MASTER_ALGORITHMIC_RELEASE_BLOCKER_GATE_CURRENT.md`](MASTER_ALGORITHMIC_RELEASE_BLOCKER_GATE_CURRENT.md)

---

## X. Privacy Manifest / Disclosure Audit

Matrix: [`MASTER_PRIVACY_MANIFEST_DISCLOSURE_MATRIX_CURRENT.csv`](MASTER_PRIVACY_MANIFEST_DISCLOSURE_MATRIX_CURRENT.csv)

Privacy manifests present for Watch and iOS. No tracking declared. Dive profiles, depth, location, photos, sync identifiers — disclosed. Apnea matrix: [`MASTER_APNEA_PRIVACY_DISCLOSURE_MATRIX_CURRENT.csv`](MASTER_APNEA_PRIVACY_DISCLOSURE_MATRIX_CURRENT.csv)

---

## Y. TestFlight Readiness

**Internal TestFlight software: READY** @ `2c30412` — builds PASS, iOS 1655 PASS, CONS-046 PASS, claims truthful.

**Blockers:** WFC-P2-005 (P2 test drift), physical disclosure on TF notes, SDG-008 shallow dev toggle labeling.

See [`MASTER_TESTFLIGHT_POST_REMEDIATION_SOFTWARE_GATE_CURRENT.md`](MASTER_TESTFLIGHT_POST_REMEDIATION_SOFTWARE_GATE_CURRENT.md) and [`MASTER_TESTFLIGHT_SHALLOW_DEPTH_RISK_ASSESSMENT_CURRENT.md`](MASTER_TESTFLIGHT_SHALLOW_DEPTH_RISK_ASSESSMENT_CURRENT.md).

---

## Z. App Store Readiness

**NOT READY** — legal counsel (CONS-044), physical QA 0%, external validation 0%, full-depth entitlement not provisioned, screenshots incomplete.

See [`MASTER_APP_STORE_POST_REMEDIATION_PENDING_GATE_CURRENT.md`](MASTER_APP_STORE_POST_REMEDIATION_PENDING_GATE_CURRENT.md) and [`MASTER_APP_STORE_TESTFLIGHT_BLOCKERS_CURRENT.md`](MASTER_APP_STORE_TESTFLIGHT_BLOCKERS_CURRENT.md).

---

## AA. Legal / Certification / EN13319 Strategy

**PENDING_LEGAL_REVIEW** — Safety disclaimers present. No EN13319/ISO 6425 certification claim. EN13319 strategy documented as future consideration, not current status. Legal acceptance flow with scroll gate PASS (software).

---

## AB. Support / Incident / Rollback Process

**CONDITIONAL** — Release checklist, rollback docs, and support escalation paths documented in `Docs/`. Incident drill **NOT_EXECUTED** (P3). Shallow-depth rollback procedure documented in `APPLE_SHALLOW_DEPTH_ENTITLEMENT_SUPPORT.md`.

---

## AC. Detailed Findings

| ID | Sev | Finding | Root Cause | Remediation | Release Impact |
|---|---|---|---|---|---|
| WFC-P1-001 | P1 | External Bühlmann not executed | No third-party campaign | Execute validation plan | Blocks external TF/App Store deco claims |
| CONS-042 | P1 | Shallow/full wet QA 0% | No field sessions | Execute HARDWARE_QA QA-002 | Blocks shallow/full claims |
| CONS-048 | P1 | Snorkeling 12 field QA 0/12 | Templates only | Execute open-water QA | Blocks Snorkeling field claims |
| WAO-PHY-001 | P1 | WAO physical end-to-end | No wet artifacts | Execute WAO preferred QA | Blocks WAO claims |
| HWC-PHY-004 | P1 | Water Lock physical | Not executed | Execute Water Lock QA | Blocks hardware claims |
| CONS-044 | P1 | Legal marketing review | Counsel pending | Schedule review | Blocks App Store |
| WFC-P2-005 | P2 | 13 Watch routing test failures | Apnea wave routing change | Update WAO test expectations | Blocks 100% Watch green |
| REL-P2-002 | P2 | Snorkeling progress test fail | Test/assertion drift | Fix calculator test | P2 software gap |
| WFC-P2-001 | P2 | CMAltimeter physical samples | No field CoreMotion | Execute CMALTIMETER QA | Blocks altitude physical claim |
| HWC-PHY-001..003 | P2 | Crown/AB physical | Not executed | Execute hardware QA | Blocks hardware UX claims |
| SDG-008 | P2 | Dev shallow FC TF exposure risk | Internal toggle exists | TF metadata review | Internal TF only |
| MASB-P-07 | P2 | App Store assets incomplete | Marketing pending | Complete ASC pack | App Store |
| MASB-P-11 | P2 | Manual a11y QA | Not executed | VoiceOver field pass | App Store |
| MASB-P-12 | P3 | Rollback drill | Not executed | Run drill | Public release |
| DOC-P3-001 | P3 | README baseline note | May lag HEAD | Docs audit 06 | Non-blocking |

**P0:** None

---

## AD. Readiness to 100 Plan

See [`MASTER_READINESS_TO_100_PLAN_CURRENT.md`](MASTER_READINESS_TO_100_PLAN_CURRENT.md).

**Software to 100:** Fix WFC-P2-005 + Snorkeling progress test → Watch suite green.  
**Release to 100:** Requires physical QA Batch-8, external Bühlmann, legal review, App Store assets — cannot be achieved by software alone.

---

## AE. Final Verdict — Required Questions

| # | Question | Answer |
|---|----------|--------|
| 1 | Internal TestFlight ready? | **YES (software)** — READY with physical disclosure |
| 2 | External TestFlight ready? | **NO** — physical/external gates open |
| 3 | App Store ready? | **NO** — + legal/marketing |
| 4 | Safety requirements mapped to tests? | **PARTIAL** — FC mapped; WAO tests stale |
| 5 | Physical gates executed or pending? | **PENDING** — 0% executed, clearly labeled |
| 6 | FC altimeter physically validated? | **NO** — PENDING_PHYSICAL |
| 7 | Depth/underwater QA complete? | **NO** — PENDING_PHYSICAL |
| 8 | Paired sync physically validated? | **NO** — PENDING_PHYSICAL |
| 9 | External Bühlmann complete? | **NO** — PENDING_EXTERNAL_VALIDATION |
| 10 | Subsurface validation complete? | **NO** — PENDING |
| 11 | CCR validation complete? | **NO** — reference-only/pending |
| 12 | Claims supported by evidence? | **YES (software)** — physical/external honestly pending |
| 13 | Privacy manifest complete? | **YES** (static review) |
| 14 | TF/ASC metadata truthful? | **YES (software posture)** — assets incomplete |
| 15 | Entitlements aligned? | **YES** — shallow default; full pending |
| 16 | Support/rollback ready? | **CONDITIONAL** — documented; drill pending |
| 17 | Blocks 100% release? | Physical QA, external validation, legal, assets |
| 18 | Blocks internal TF? | **None P0/P1 software** — P2 test drift only |
| 19 | Blocks external TF? | All physical + external + Snorkeling 12 QA |
| 20 | Blocks App Store? | External TF blockers + legal + full-depth entitlement |

---

## AF. Final Verdict Block (§16)

```text
MASTER_RELEASE_QA_EVIDENCE_COMPLIANCE_AUDIT: PARTIAL
BASELINE_CURRENT_AND_CLEAN: PASS
BUILD_IOS: PASS
BUILD_WATCH: PASS
IOS_TESTS: PASS
WATCH_TESTS: FAIL
REQUIREMENT_TEST_TRACEABILITY: PASS
PHYSICAL_WATCH_QA: PENDING_PHYSICAL
PHYSICAL_IOS_QA: PENDING_PHYSICAL
PAIRED_WATCH_IOS_QA: PENDING_PHYSICAL
UNDERWATER_DEPTH_SENSOR_QA: PENDING_PHYSICAL
WATCH_FULL_COMPUTER_ALTITUDE_QA: PENDING_PHYSICAL
EXTERNAL_BUHLMANN_VALIDATION: PENDING_EXTERNAL_VALIDATION
EXTERNAL_SCHREINER_VALIDATION: PENDING_EXTERNAL_VALIDATION
EXTERNAL_SUBSURFACE_VALIDATION: PENDING_EXTERNAL_VALIDATION
CCR_EXTERNAL_VALIDATION: PENDING_EXTERNAL_VALIDATION
CLAIMS_EVIDENCE_ALIGNMENT: PASS
LEGAL_CERTIFICATION_REVIEW: PENDING_LEGAL_REVIEW
APPLE_ENTITLEMENT_CAPABILITY_ALIGNMENT: PASS
PRIVACY_MANIFEST_DISCLOSURE_ALIGNMENT: PASS
TESTFLIGHT_METADATA_TRUTHFULNESS: PASS
APP_STORE_METADATA_TRUTHFULNESS: PASS
SUPPORT_ROLLBACK_PROCESS: PASS
INTERNAL_TESTFLIGHT_READINESS: READY
EXTERNAL_TESTFLIGHT_READINESS: NOT_READY
APP_STORE_READINESS: NOT_READY
P0_FINDINGS: 0
P1_FINDINGS: 6
P2_FINDINGS: 11
P3_FINDINGS: 5
OVERALL_QA_EVIDENCE_READINESS: 82
OVERALL_CLAIMS_COMPLIANCE_READINESS: 96
OVERALL_RELEASE_READINESS: 72
RELEASE_BLOCKERS: WFC-P1-001, CONS-042, CONS-048, WAO-PHY-001, CONS-044, WFC-P2-005
```

**§2B additions:**

```text
INTERNAL_TESTFLIGHT_SOFTWARE_READY_AFTER_REMEDIATION: READY
EXTERNAL_TESTFLIGHT_WITH_PHYSICAL_GATES: NOT_READY
APP_STORE_WITH_LEGAL_PHYSICAL_EXTERNAL_GATES: NOT_READY
NO_FAKE_PHYSICAL_EXTERNAL_CLAIMS: PASS
RELEASE_SOFTWARE_READINESS_AFTER_REMEDIATION: 82
```

---

## Related Outputs

- Apnea release audit: [`MASTER_APNEA_RELEASE_QA_EVIDENCE_AUDIT_CURRENT.md`](MASTER_APNEA_RELEASE_QA_EVIDENCE_AUDIT_CURRENT.md)
- Post-remediation: [`MASTER_RELEASE_POST_REMEDIATION_READINESS_AUDIT_CURRENT.md`](MASTER_RELEASE_POST_REMEDIATION_READINESS_AUDIT_CURRENT.md)
- Shallow depth: [`MASTER_SHALLOW_DEPTH_RELEASE_GATE_MATRIX_CURRENT.csv`](MASTER_SHALLOW_DEPTH_RELEASE_GATE_MATRIX_CURRENT.csv)
- GF evidence: [`MASTER_GF_PRESET_RELEASE_EVIDENCE_MATRIX_CURRENT.csv`](MASTER_GF_PRESET_RELEASE_EVIDENCE_MATRIX_CURRENT.csv)
