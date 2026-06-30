# Watch Full Computer — Post-Remediation Verification — CURRENT

**Audit command:** `01-MASTER_WATCH_FULL_COMPUTER_FORENSIC_AUDIT_COMMAND_V2.2.md`  
**Baseline:** `main` @ `451f8fb`  
**Audit date:** 2026-06-30  
**Scope:** CONS-002, CONS-006, CONS-007, CONS-008, CONS-016 (Watch FC impact)

---

## Summary

| Consolidated ID | Title | Software status | Watch FC verification | Verdict |
|---|---|---|---|---|
| CONS-002 | iOS ↔ Watch GF preset parity on import | FIXED_SOFTWARE | `FullComputerGradientFactorPreset.matching` + `DivePlanPackageBuilder.gradientFactorPreset` | **PASS** |
| CONS-006 | Shallow FC developer testing toggle exposure | FIXED_SOFTWARE | `DeveloperSettings.allowsShallowDepthDivingTesting` gated by developer unlock + shallow entitlement probe | **PASS** |
| CONS-007 | Depth tier authority vs Info.plist metadata | FIXED_SOFTWARE | `DepthCapabilityEntitlementProbe.runtimeAuthorityTier` compile-time first; plist metadata non-authoritative | **PASS** |
| CONS-008 | Independent TTS/schedule oracle | FIXED_SOFTWARE | `IndependentBuhlmannOracle.independentRuntimeProjectionOnOracleTissues` / `independentTTSMinutesOnOracleTissues` | **PASS** |
| CONS-016 | TTS 1-minute quantization | DOCUMENTED_LIMITATION | `BuhlmannEngine.runtimeProjection` forward sim uses 1-min steps | **PASS (documented)** |

---

## CONS-002 — GF Import Parity

**Evidence:**

- `Shared/Models/FullComputerGradientFactorPreset.swift` — Watch presets 20/80, 30/70, 40/85 with `matching(low:high:)`.
- `iOSApp/Services/DivePlanPackageBuilder.swift` — emits `gradientFactorPreset` on plan packages.
- `iOSApp/Utils/PlannerModePolicy.swift` — maps iOS planner modes to Watch preset raw values.
- `Tests/WatchAlgorithmTests/FullComputerImportedPlanStoreTests.swift` — 20 tests; invalid GF fail-closed.
- `Tests/WatchAlgorithmTests/FullComputerGradientFactorPresetTests.swift` — preset triplets verified.

**Result:** Imported iPhone plans with all three iOS GF presets resolve to locked Watch runtime GF at dive start. Mismatch rejects import with `invalidGradientFactors`.

---

## CONS-006 — Shallow FC Developer Toggle

**Evidence:**

- `Utils/DeveloperSettings.swift` — `allowsShallowDepthDivingTesting` requires `DepthCapabilityEntitlementProbe.hasShallowEntitlement`, developer section visibility, and explicit UserDefaults flag (default OFF).
- `Utils/DepthCapabilityPolicy.swift` — `supportsFullComputerRuntime` false for `.appleShallow` unless developer toggle ON.
- `Views/DeveloperSettingsView.swift` — internal-testing copy; not exposed in production settings without developer unlock.
- `Tests/WatchAlgorithmTests/DepthCapabilityTests.swift` — shallow FC blocked without toggle.

**Result:** Production users on shallow-signed builds cannot start Full Computer without developer unlock + explicit toggle. Copy labels ~6 m internal testing.

**Physical gate:** CONS-042 shallow wet QA remains **PENDING_PHYSICAL**.

---

## CONS-007 — Depth Capability Authority

**Evidence:**

- `Utils/DepthCapabilityEntitlementProbe.swift` L24-33 — `#if DEPTH_ENTITLEMENT_FULL/SHALLOW` compile flags take precedence.
- L41-48 — `infoPlistMetadataTier` documented as metadata-only, non-authoritative for safety.
- `Utils/DepthCapabilityResolver.swift` — resolves from probe, not plist alone.
- `Tests/WatchAlgorithmTests/DepthCapabilityTests.swift` — 9 tests on policy matrix.

**Result:** Runtime depth capability derives from compile-time signing authority; Info.plist `DIRDepthEntitlementTier` is fallback metadata only.

**Limitation:** watchOS cannot read live `SecTask` entitlements; CI signing manifest pairing remains process gate (not re-audited this session).

---

## CONS-008 — Independent Oracle

**Evidence:**

- `Tests/WatchAlgorithmTests/Support/IndependentBuhlmannOracle.swift` — separate ZH-L16C constants, Schreiner/Haldane, ceiling; does not call `BuhlmannTissueModel` or production tissue update.
- L459-529 — `independentTTSMinutesOnOracleTissues` and `independentRuntimeProjectionOnOracleTissues` implement schedule without `BuhlmannEngine.runtimeProjection`.
- L843+ — deprecated `productionProjectionOnOracleTissues` retained for regression detection only.
- `Tests/WatchAlgorithmTests/Audit15TTSScheduleOracleSweepTests.swift` — oracle sweep within tolerance.
- `Tests/WatchAlgorithmTests/Audit15MultilevelOracleProfilesTests.swift` — ML-02…ML-10 production vs oracle replay.

**Result:** Tissue-loading oracle is independent. Schedule/TTS oracle path on oracle-loaded tissues is independent per remediation.

**External gate:** CONS-009 third-party tool comparison remains **PENDING_EXTERNAL_VALIDATION**.

---

## CONS-016 — TTS Quantization (secondary)

**Evidence:** `BuhlmannEngine.runtimeProjection` forward schedule simulation uses 1-minute quanta (conservative direction). Documented in `FullComputerReleaseHardTolerances.plannerRuntimeTTSMinutes` = 3.0 min tolerance.

**Impact:** Safe (over-estimates TTS); not a release software blocker.

---

## Final Post-Remediation Verdicts

```text
WATCH_FC_GF_IMPORT_PARITY: PASS
WATCH_FC_DEPTH_CAPABILITY_AUTHORITY: PASS
WATCH_FC_INDEPENDENT_ORACLE: PARTIAL_PENDING_EXTERNAL
WATCH_FC_SOFTWARE_READINESS_AFTER_REMEDIATION: 92
WATCH_FC_PHYSICAL_QA_STATUS: PENDING_PHYSICAL
```

**Notes:** Software remediation items CONS-002/006/007/008 verified closed at `451f8fb`. External Bühlmann validation and physical Watch QA remain open gates preventing full PASS release verdict.
