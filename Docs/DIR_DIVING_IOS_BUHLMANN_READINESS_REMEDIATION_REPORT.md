# DIR DIVING iOS Bühlmann Planner Readiness Remediation Report

**Date:** 2026-06-04  
**Branch:** `main`  
**Baseline commit (pre-remediation):** `63ee0b4`  
**Source audit:** [`DIR_DIVING_IOS_BUHLMANN_COMPREHENSIVE_READINESS_AUDIT_UPDATED.md`](DIR_DIVING_IOS_BUHLMANN_COMPREHENSIVE_READINESS_AUDIT_UPDATED.md)  
**Scope:** iOS Companion MAIN — `DIRDiving iOS` planner / Bühlmann / oxygen exposure only

---

## A. Branch confirmed

`main` (local validation on current tree).

## B. Commit confirmed

Remediation applied on top of `63ee0b4` (not yet committed at report generation).

## C. Target confirmed

| Item | Value |
|------|--------|
| Target | `DIRDiving iOS` |
| Sources | `iOSApp/` |
| Tests | `DIRDiving iOS Algorithm Tests` |

## D. Experimental exclusions confirmed

Experimental iOS files remain excluded in `project.yml` (Exploration, Buddy, etc.). No experimental Swift modified.

## E. Watch untouched confirmation

No changes under Watch runtime paths (`App/`, `Models/`, `Services/`, `Views/`, `Utils/`, `Resources/` for watchOS), `BuhlmannEngine` Watch targets, or Watch entitlements.

## F. Files modified

| Area | Files |
|------|--------|
| OTU fix | `iOSApp/Services/OxygenExposureModels.swift` |
| Bühlmann descent / bottom switch | `iOSApp/Algorithms/Buhlmann/BuhlmannEngine.swift`, `iOSApp/Services/BuhlmannPlanner.swift`, `iOSApp/Services/PlannerGasSchedule.swift` |
| Share / validation / UI copy | `iOSApp/Views/PlannerView.swift`, `iOSApp/Utils/PlannerInputValidator.swift`, `iOSApp/Resources/en.lproj/Localizable.strings`, `iOSApp/Resources/it.lproj/Localizable.strings` |
| Tests | `Tests/iOSAlgorithmTests/OTUCanonicalFixtureTests.swift` (new), `Tests/iOSAlgorithmTests/BottomGasSwitchDepthTests.swift` (new), `Tests/iOSAlgorithmTests/OxygenExposureDeepModelTests.swift` |
| Docs | `Docs/DIR_DIVING_IOS_OXYGEN_EXPOSURE_MODEL.md`, `Docs/DIR_DIVING_IOS_BUHLMANN_MATH_VERIFICATION.md`, `Docs/DIR_DIVING_IOS_PLANNER_LIMITATIONS.md`, `Docs/DIR_DIVING_IOS_BUHLMANN_ENGINE_DESIGN.md`, `Docs/DIR_DIVING_IOS_BUHLMANN_EXTERNAL_VALIDATION_PLAN.md`, `Docs/BUILD_VALIDATION.md`, `Docs/INDEX.md` |

## G. Issues fixed

| Issue | Status |
|-------|--------|
| OTU inverted constant-depth formula | **Fixed** — `((PPO2 − 0.5) / 0.5)^(5/6) × minutes` |
| OTU tests self-referential | **Fixed** — `OTUCanonicalFixtureTests` with hardcoded independent expected values |
| OTU documentation inverted formula | **Fixed** — oxygen exposure, math verification, planner limitations |
| Share/export generic CNS label | **Fixed** — localized full plan / descent+bottom / ascent-deco / OTU lines |
| Planner validation hardcoded Italian | **Fixed** — `PlannerInputValidator` uses localization keys (EN/IT) |
| Travel gas → bottom switch depth | **Implemented** — bottom cylinder switch depth drives schedule + engine; hypoxic+travel limitation warning |
| Stale build validation docs | **Updated** — `BUILD_VALIDATION.md` @ 2026-06-04 |

## H. Tests added

- `OTUCanonicalFixtureTests` — canonical PPO2 fixtures (0.5–1.6), monotonicity, guards, ramp bounds, multi-segment sum
- `BottomGasSwitchDepthTests` — switch depth resolution, descent points, hypoxic limitation warning

## I. Tests run

```bash
xcodegen generate
xcodebuild -scheme "DIRDiving iOS" -destination 'generic/platform=iOS Simulator' build
xcodebuild -scheme "DIRDiving iOS Algorithm Tests" -destination 'platform=iOS Simulator,name=iPhone 17 Pro' test
```

## J. Build results

| Step | Result |
|------|--------|
| `xcodegen generate` | **PASS** |
| `DIRDiving iOS` build | **PASS** |
| `DIRDiving iOS Algorithm Tests` | **PASS** — 247 executed, 4 skipped (keychain/sync), 0 failures |

Watch build/test not re-run (Watch code unchanged).

## K. External validation status

**Not complete.** Frozen fixture profiles F1–F7 added to [`DIR_DIVING_IOS_BUHLMANN_EXTERNAL_VALIDATION_PLAN.md`](DIR_DIVING_IOS_BUHLMANN_EXTERNAL_VALIDATION_PLAN.md); all campaign rows remain ☐ Pending. No certified-equivalence claim.

## L. Remaining limitations

- External Bühlmann validation campaign must be executed manually.
- Physical-device planner accessibility QA (Dynamic Type / VoiceOver) not run in this pass.
- OTU/CNS remain reference-only estimates; not certified oxygen exposure authority.
- Bailout cylinders remain schedule-only.
- Some internal `GasRole` / `PlannerMode` raw display strings remain Italian in model enums (not user-facing validation paths).

## M. Remaining physical / device QA

- Planner result screens under largest Dynamic Type on iPhone hardware.
- VoiceOver on CNS 15% warning and share sheet export text.
- Real-world trimix plan review with instructor / certified planner.

## N. Final readiness estimate

| Category | Verdict |
|----------|---------|
| OTU correctness (code + unit tests) | **Ready for internal validation** |
| CNS full-plan + descent+bottom 15% | **Unchanged — still covered by existing tests** |
| Bühlmann decompression core | **Unchanged in this pass** (travel/bottom switch alignment only) |
| External Bühlmann parity | **Not ready** — campaign pending |
| App Store “certified planner” | **Not applicable** — reference-only |

**Overall:** iOS Companion MAIN Bühlmann planner is **release-hard for internal validation** on OTU and documented planner hygiene, **excluding** external validation and physical QA above.

## O. Confirmation

- iOS MAIN only — **yes**
- Watch untouched — **yes**
- Experimental untouched — **yes**
- No UI redesign — **yes** (copy/export/validation strings only)
- No certified decompression claim — **yes**
- Planner remains reference-only — **yes**
- Legal/safety wording preserved — **yes**
- No fake external validation — **yes**
- macOS build/test actually run — **yes** (iPhone 17 Pro simulator)

---

*Report generated after implementation of audit `DIR_DIVING_IOS_BUHLMANN_COMPREHENSIVE_READINESS_AUDIT_UPDATED.md`.*
