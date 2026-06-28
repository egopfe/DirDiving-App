# DIR DIVING — TestFlight Shallow Depth Risk Assessment (Current)

**Command:** 05 — `05-MASTER_RELEASE_QA_EVIDENCE_COMPLIANCE_AUDIT_COMMAND_V1.1.md` §2A.3  
**Date:** 2026-06-28  
**Branch:** `main`  
**Commit:** `7dfefe2` (`7dfefe2cd7817780a903a64e51b890d901111ffd`)  
**Baseline:** Upstream audits 01–04 @ `7dfefe2`  
**Task type:** Read-only risk assessment — no production changes

**Not claimed:** Full-depth entitlement validated, shallow wet QA passed, certified decompression on shallow builds, Apple system auto-launch listing verified, App Store approval.

---

## Executive summary

At `7dfefe2`, the Watch app ships with **shallow-depth signing by default** (`Config/DIRDiving.WithShallowDepth.entitlements`, `DIRDepthEntitlementTier=shallow`). **Production Full Computer is fail-closed** unless the build has full-depth entitlement **or** the user enables developer shallow FC testing behind TestFlight developer settings (default OFF). **Software gates PASS**; **all shallow wet and system-listing evidence is PENDING_PHYSICAL**.

| Risk tier | Count | Release impact |
|-----------|------:|----------------|
| P0 (false claim / safety bypass) | **0** | None identified |
| P1 (internal TestFlight) | **3** | Shallow FC exposure labeling; GF import mismatch; metadata trust |
| P2 (external TestFlight) | **6** | Wet QA, system listing, WAO physical, hardware controls |
| P3 | **2** | Test maintenance, modal sequencing partial sim evidence |
| P4 | **4** | Documentation / positive controls |

**Internal TestFlight shallow-depth posture:** **CONDITIONAL** — allowed only with truthful TestFlight notes, developer toggles default OFF, and no public marketing of shallow FC as certified guidance.

**External TestFlight / App Store:** **NOT READY** until physical shallow-depth and full-depth entitlement evidence exists.

---

## Capability posture @ 7dfefe2

| Item | Software status | Physical status |
|------|-----------------|-----------------|
| Shallow-depth entitlement signed | **SOFTWARE_READY** | PENDING_PHYSICAL |
| Full-depth entitlement (alternate) | Documented archive path | PENDING_PHYSICAL |
| `WKSupportsAutomaticDepthLaunch` | **true** in Info.plist | System listing NOT_EXECUTED |
| `WKBackgroundModes` underwater-depth | Configured | Session field QA PENDING |
| Production FC without dev toggle | **Blocked** on shallow-only | N/A |
| Developer shallow Gauge toggle | Hidden App Store; TF opt-in | N/A |
| Developer shallow FC toggle | Hidden App Store; TF opt-in default OFF | Shallow wet FC PENDING |
| Depth degrades above ~6 m (shallow) | **SOFTWARE_READY** | Wet validation PENDING |

Evidence: [`MASTER_SHALLOW_DEPTH_RELEASE_GATE_MATRIX_CURRENT.csv`](MASTER_SHALLOW_DEPTH_RELEASE_GATE_MATRIX_CURRENT.csv), [`MASTER_WATCH_DEPTH_CAPABILITY_SHALLOW_TESTING_MATRIX_CURRENT.csv`](MASTER_WATCH_DEPTH_CAPABILITY_SHALLOW_TESTING_MATRIX_CURRENT.csv).

---

## Developer shallow testing release gate (§2A.3)

| Check | Result | Evidence |
|-------|--------|----------|
| Developer shallow Gauge hidden from public users | **PASS** | `DeveloperSettingsView`; App Store section hidden |
| Developer shallow FC hidden from public users | **PASS** (TestFlight gated) | `allowsShallowDepthDivingTesting`; default OFF on TF |
| TestFlight/internal flags labeled internal testing | **CONDITIONAL** | Toggle exists; copy must state internal-only in TF notes |
| App Store metadata/screenshots expose dev shallow testing | **NOT EXECUTED** | No ASC assets in repo — treat as PENDING |
| No claim shallow testing is certified decompression | **PASS** | CLM-FC-01 non-certified copy; no shallow-cert strings |

**Finding SDG-008 (P1):** TestFlight can opt into shallow FC testing — acceptable for internal QA if `TESTFLIGHT_REVIEW_NOTES.md` and ASC review notes disclose internal-only scope and ~6 m limitation. **Not acceptable** for external TF or App Store without full-depth entitlement evidence.

---

## Risk register

| ID | Severity | Risk | Mitigation | Status |
|----|----------|------|------------|--------|
| SDR-P0-001 | P0 | Public claim of full-depth or certified shallow FC | Prohibited-claims scan; CLM matrix | **CLEAR** |
| SDR-P1-001 | P1 | TestFlight user enables shallow FC without understanding ~6 m cap | TF review notes + in-app developer label + predive disclosure | **OPEN** |
| SDR-P1-002 | P1 | iOS GF presets rejected at Watch import (IOS-MASTER-F016) | Align preset pairs or document import limitation | **OPEN** |
| SDR-P1-003 | P1 | Info.plist tier vs runtime entitlement drift (MASTER-DEPTH-002) | CI signing alignment check | **OPEN** |
| SDR-P2-001 | P2 | Water auto-open routes to FC predive without depth policy parity (MASTER-WAO-001) | Align WAO with DepthCapabilityPolicy | **OPEN** |
| SDR-P2-002 | P2 | Shallow wet Gauge/FC not executed | Execute HARDWARE_QA_MATRIX QA-002 packs | **PENDING_PHYSICAL** |
| SDR-P2-003 | P2 | System Auto-Launch listing not verified on hardware | WAO-PHY-002 evidence folder | **PENDING_PHYSICAL** |
| SDR-P2-004 | P2 | CMAltimeter physical sample gate open | WATCH_CMALTIMETER_PHYSICAL | **PENDING_PHYSICAL** |
| SDR-P3-001 | P3 | Startup flow test drift after WAO routing | Update DIRModesAndStartupFlowTests | **OPEN** |
| SDR-P4-001 | P4 | Positive shallow signing documentation | BUILD_AND_XCODEGEN_WORKFLOW.md | **PASS** |

---

## TestFlight-specific recommendations

1. **Internal TestFlight build notes** must state: shallow-depth entitlement only; Full Computer limited to ~6 m unless full-depth provisioning; developer toggles are internal QA; not certified decompression guidance.
2. **Do not** enable external TestFlight until shallow wet QA (Gauge + optional dev FC) and CMAltimeter physical gate have signed artifacts.
3. **Do not** submit App Store build signed shallow-only if marketing implies full-depth recreational deco computer.
4. **Separate SOFTWARE_READY from PENDING_PHYSICAL** in all release communications — simulator and automated tests do not close wet gates.

---

## Cross-reference matrices

| Matrix | Purpose |
|--------|---------|
| `MASTER_SHALLOW_DEPTH_RELEASE_GATE_MATRIX_CURRENT.csv` | Entitlement + plist + policy gates |
| `MASTER_WATER_AUTO_OPEN_PHYSICAL_QA_GATE_CURRENT.csv` | Submerged auto-launch physical QA |
| `MASTER_WATCH_HARDWARE_CONTROLS_QA_GATE_CURRENT.csv` | Crown / Action Button / Water Lock |
| `MASTER_GF_PRESET_RELEASE_EVIDENCE_MATRIX_CURRENT.csv` | GF preset automated + physical evidence |
| `MASTER_PHYSICAL_DEVICE_QA_MATRIX_CURRENT.csv` | Full device QA inventory |

---

## Verdict

```text
TESTFLIGHT_SHALLOW_DEPTH_RISK: CONDITIONAL (internal TF only)
SHALLOW_DEPTH_SOFTWARE_GATE: PASS
SHALLOW_DEPTH_PHYSICAL_GATE: PENDING_PHYSICAL
FULL_DEPTH_ENTITLEMENT_EVIDENCE: PENDING_PHYSICAL
DEVELOPER_SHALLOW_TESTING_PUBLIC_EXPOSURE: CLEAR (software)
APP_STORE_SHALLOW_DEPTH_READINESS: NOT_READY
```
