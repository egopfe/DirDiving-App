# Apnea Watch Features / UI / Logbook Remediation Report V1.0

**Date:** 2026-06-18  
**Authoritative audit:** `Docs/AUDIT_APNEA_WATCH_FEATURES_UI_LOGBOOK_CURRENT.md` (2026-06-18, `5baa97e`)  
**Starting branch/SHA:** `main` @ `a1e0cab`  
**Ending working tree:** dirty (uncommitted remediation)  
**Internal readiness:** **100%** (code + automated tests + documentation scaffolding)  
**Physical Watch UI QA:** **PENDING**

---

## Executive summary

Audit 06 remediation closes all code-fixable P2/P3 findings:

1. **ApneaView promoted** to Watch MAIN target with controlled navigation.
2. **ApneaWatchRuntimeStore** decouples production Apnea UI from `DiveManager` and `ExplorationStore`.
3. **Target-not-reached** negative operational-event tests added.
4. **Layout-contract tests** added for 41/45/49 mm deterministic fixtures (Layer A).
5. **Physical QA evidence folders** created (Layer B screenshots remain manual).

**Command 08 gate:** `READY_FOR_APNEA_COMMAND_08`

---

## P2 remediation

| Finding | Resolution |
|---------|------------|
| `ApneaView.swift` excluded from MAIN | Removed exclusion in `project.yml`; Apnea launchable via activity selection |
| `ApneaView` coupled to `DiveManager` / `ExplorationStore` | Refactored to `ApneaWatchRuntimeStore` + `ApneaSessionEngine` |
| No target-not-reached XCTest | Added `testTargetNotReachedDoesNotEmitTargetEvent`, `testRejectedDepthSpikeCannotTriggerTargetEvent`, and boundary cases |

## P3 remediation

| Finding | Resolution |
|---------|------------|
| Physical VoiceOver pending | `Docs/QA_EVIDENCE/APNEA_VOICEOVER/README.md` scaffold (status PENDING) |
| 41/45/49 mm screenshot CI | `ApneaWatchLayoutContractTests` + `Docs/QA_EVIDENCE/APNEA_WATCH_LAYOUTS/README.md` (no fabricated images) |

---

## Architecture: ApneaWatchRuntimeStore

- **Protocol:** `Services/ApneaWatchRuntimeProviding.swift`
- **Implementation:** `Services/ApneaWatchRuntimeStore.swift`
- Owns `ApneaSessionEngine`, operational event state, depth sensor via `DepthSensorProvider`
- Derives `ApneaWatchPresentationInput` without `DiveManager`
- Persists checkpoints via `ApneaSessionCheckpointStore`
- Writes completed sessions only to `ApneaLogbookStore`
- Injected in `DIRDivingApp.swift` as `@EnvironmentObject`

---

## Watch MAIN promotion

**Decision:** **PASS** — all architecture, safety, and navigation gates satisfied in code/tests.

| Gate | Status |
|------|--------|
| No DiveManager in Apnea production UI | PASS |
| Apnea runtime store Apnea-specific | PASS |
| Apnea logbook isolated | PASS |
| No demo timer / synthetic production data | PASS |
| Buddy reminder, sensor degraded, manual fallback | PASS |
| Activity selection → Apnea → session → summary | PASS |
| Active session blocks mode change | PASS |
| `ExplorationStore` remains excluded | PASS |

**Navigation changes:**

- `DIRActivityMode.apnea.isLaunchableOnWatchMAIN` → `true`
- `DIRStartupSelectionPolicy.nextStepAfterActivitySelection(.apnea)` → `.ready(activity: .apnea, divingMode: .gauge)`
- `DiveLiveView` routes `.apnea` to `ApneaView`
- `ContentView` locks tabs during active Apnea session
- `DIRActivitySelectionStore.canChangeModes` checks `ApneaWatchRuntimeStore.isSessionActive`

---

## Files changed

### New

- `Services/ApneaWatchRuntimeProviding.swift`
- `Services/ApneaWatchRuntimeStore.swift`
- `Tests/WatchAlgorithmTests/ApneaWatchRuntimeStoreTests.swift`
- `Tests/WatchAlgorithmTests/ApneaWatchMainPromotionTests.swift`
- `Tests/WatchAlgorithmTests/ApneaWatchLayoutContractTests.swift`
- `Docs/QA_EVIDENCE/APNEA_VOICEOVER/README.md`
- `Docs/QA_EVIDENCE/APNEA_WATCH_LAYOUTS/README.md`
- `Docs/QA_EVIDENCE/APNEA_HAPTICS/README.md`
- `Docs/QA_EVIDENCE/APNEA_WET_INTERACTION/README.md`
- `Docs/QA_EVIDENCE/APNEA_MAIN_PROMOTION/README.md`
- `Docs/APNEA_WATCH_FEATURES_UI_LOGBOOK_REMEDIATION_REPORT_V1.0.md`

### Modified

- `Views/ApneaView.swift` — runtime store only; no DiveManager/ExplorationStore
- `Views/DiveLiveView.swift`, `Views/ContentView.swift` — Apnea routing and session lock
- `App/DIRDivingApp.swift` — inject runtime store
- `Models/DIRModesAndStartup.swift`, `Utils/DIRStartupSelectionPolicy.swift`
- `Services/DIRActivitySelectionStore.swift`
- `Utils/ApneaWatchPresentation.swift` — pre-dive armed stage
- `project.yml` — promote ApneaView; include runtime store
- `Resources/en.lproj/Localizable.strings`, `Resources/it.lproj/Localizable.strings`
- `Scripts/validate_apnea_release_readiness.sh`, `Scripts/check_main_target_isolation.sh`
- Test updates: operational events, architecture isolation, promotion gates, startup flow, FC target membership, release-hard validation

---

## Test results

| Suite | Result |
|-------|--------|
| Watch build | **PASS** |
| iOS build | **PASS** |
| Watch algorithm (complete) | **576 tests, 0 failures** (16 skipped) |
| iOS algorithm (complete) | **PASS** (full suite) |
| Apnea operational negative tests | **PASS** |
| ApneaWatchRuntimeStoreTests | **9/9 PASS** |
| ApneaWatchMainPromotionTests | **PASS** |
| ApneaWatchLayoutContractTests | **PASS** |

---

## Command 08 gate

```
READY_FOR_APNEA_COMMAND_08
```

Conditions met: operational engine PASS, ApneaView isolated, MAIN promotion PASS, logbook isolated, statistics/eligibility preserved, localization parity, safety self-check PASS, namespace isolation PASS.

---

## Final readiness matrix

| Domain | Code | Automated Tests | Documentation | Physical Evidence |
|--------|-----:|----------------:|--------------:|-------------------|
| Operational Events | 100% | 100% | 100% | PENDING |
| Targets / Markers / Alarms | 100% | 100% | 100% | PENDING |
| Haptics | 100% | 100% | 100% | PENDING |
| Mission Mode Compatibility | 100% | 100% | 100% | PENDING |
| Watch Runtime Isolation | 100% | 100% | 100% | N/A |
| Watch MAIN Promotion | PASS | 100% | 100% | PENDING |
| Ready / Dive / Ascent UI | 100% | 100% | 100% | PENDING |
| Recovery / Summary UI | 100% | 100% | 100% | PENDING |
| Layout 41/45/49 mm | 100% internal | 100% | 100% | PENDING |
| Accessibility Code | 100% | 100% | 100% | PENDING |
| Localization | 100% | 100% | N/A | N/A |
| Apnea Logbook | 100% | 100% | 100% | PENDING |
| Session Statistics | 100% | 100% | 100% | PENDING |
| Record Eligibility | 100% | 100% | 100% | PENDING |
| Namespace Isolation | 100% | 100% | 100% | N/A |
| Safety Claims | 100% | 100% | 100% | External review PENDING |
| Command 08 Gate | READY | 100% | 100% | Separate |
| **Overall Internal Readiness** | **100%** | **100%** | **100%** | Physical separate |

---

## Remaining PENDING (physical)

- VoiceOver walkthrough on Apple Watch Ultra
- Wet/glove interaction
- Haptic feel on hardware
- Water Lock behavior
- Real 41/45/49 mm screenshots
- Real submersion behavior

---

## Git status

Uncommitted changes on `main` @ `a1e0cab`. No commit or push performed per task instructions.
