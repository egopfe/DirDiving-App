# iOS MAIN algorithm math remediation report (current)

**Source audit:** [`IOS_MAIN_ALGORITHM_MATH_AUDIT_CURRENT.md`](IOS_MAIN_ALGORITHM_MATH_AUDIT_CURRENT.md)  
**Branch:** `main`  
**Baseline commit (pre-remediation):** `a6ccd8d`  
**Remediation commit:** *uncommitted working tree @ `a6ccd8d` + changes below*  
**Date:** 2026-06-07

---

## Executive summary

All **non-physical** audit items P1–P4 from `IOS_MAIN_ALGORITHM_MATH_AUDIT_CURRENT.md` were addressed in code, automated tests, localization, and documentation. **Bühlmann ZHL-16C math was not weakened.** **Ratio Deco remains heuristic/comparative only.** **DIR DIVING remains non-certified/reference-only.**

**Physical/external/App Store gates remain PENDING** — see [Remaining manual tasks](#remaining-manual-tasks-pending).

---

## Readiness verdict

| Gate | Status |
|------|--------|
| Code / static fixes | **Complete** (this pass) |
| Automated tests (sim) | **Pass** — see [Validation](#validation) |
| Documentation (non-physical) | **Complete** (this pass) |
| Physical QA | **PENDING** |
| External Bühlmann validation | **PENDING** |
| Legal review | **PENDING** |
| App Store readiness | **NOT claimed** |

---

## Issues fixed by priority

### P1 — Release-hard

| ID | Fix |
|----|-----|
| **P1-001** | Docs baseline updated in README/INDEX/RELEASE_CHECKLIST/MAIN_BRANCH_FINAL_READINESS_REPORT; Ratio Deco in feature matrix; FIELD badge removed; non-certified positioning |
| **P1-004** | Watch depth validation + photo sync + units picker localized (EN/IT); semantic keys in `DiveManager`, `WatchSyncService`, `SettingsView` |
| **P1-005** | Incompatible Ratio Deco marked **NOT validated plan** in UI + Plan/Briefing/Dive Pack PDF; Bühlmann output unchanged |

### P2 — Correctness / data integrity

| ID | Fix |
|----|-----|
| **P2-001** | Distinct **Balanced** (even) vs **Linear** (shallow ramp) distribution |
| **P2-002** | Ceiling violation deterministic test @ 60 m / 50 min |
| **P2-003** | Dive Pack PDF includes Ratio Deco section + disclaimer + incompatibility warning |
| **P2-004** | Checklist `gasText` + `switchDepthMeters` UI/sync/PDF |
| **P2-005** | Checklist PDF/export uses `migratedChecklistItems`; legacy profile exportable after migration |
| **P2-006** | Logbook tissue source footnote (simulated); planner footnote (planned Bühlmann) |
| **P2-007** | Bailout schedule-only note in Dive Pack/planner (existing hint retained) |
| **P2-008** | NDL `NDLPoint.depthBand` + depth-band chart note (not controlling compartment) |
| **P2-009** | Max-depth alarm default-off hint + 30 m preset (Watch) |
| **P2-010** | Subsurface iOS/Watch export divergence documented in file headers |

### P3 — Documentation / polish

| ID | Fix |
|----|-----|
| **P3-001** | Removed dead `equipment.badge.field` strings |
| **P3-002** | Created [`RATIO_DECO_COMPARATIVE_HEURISTIC.md`](RATIO_DECO_COMPARATIVE_HEURISTIC.md) |
| **P3-003** | Export duplicate default `.replace` aligned with import; documented in mapper |
| **P3-004** | Equipment planning card labeled informational only |
| **P3-005** | Fixed hardcoded `"Unità"` Watch settings picker |
| **P3-006** | Wired `RatioDecoWarning.noDecoGases` when no deco cylinder |

### P4 — Readiness improvements

| ID | Fix |
|----|-----|
| **P4-001** | 30 m depth alarm preset button |
| **P4-002** | Bühlmann comparison table runtime from full `ascentTableRows` |
| **P4-003** | Weekly OTU tile already implemented in planner — no fake data added |
| **P4-004** | `EquipmentProfile` CloudSyncStore round-trip test |

---

## Files changed

### iOS app
- `iOSApp/Models/DivePlan.swift` — `NDLPoint.depthBand`
- `iOSApp/Models/EquipmentProfile.swift` — `switchDepthMeters`, backward-compatible decode
- `iOSApp/Models/RatioDecoModels.swift` — incompatible status copy
- `iOSApp/Services/RatioDecoPlanner.swift` — balanced/linear, noDecoGases
- `iOSApp/Services/BuhlmannPlanner.swift` — depthBand on NDL curve
- `iOSApp/Services/PDF/*` — migrated checklist, Ratio Deco Dive Pack, incompatibility warnings
- `iOSApp/Utils/ChecklistPlannerSyncMapper.swift` — switch depth, export duplicate default
- `iOSApp/Views/*` — Ratio Deco UX, equipment, tissue footnotes, NDL note, comparison runtime
- `iOSApp/Resources/*/Localizable.strings` — new keys, removed FIELD badge

### Watch
- `Services/DiveManager.swift`, `Services/WatchSyncService.swift`
- `Views/SettingsView.swift`, `Views/AlarmSettingsView.swift`
- `Resources/*/Localizable.strings`
- `Services/SubsurfaceExportService.swift`, `iOSApp/Services/SubsurfaceExportService.swift` — divergence docs

### Tests
- `Tests/iOSAlgorithmTests/IOSMainAlgorithmMathRemediationTests.swift` *(new)*
- `Tests/iOSAlgorithmTests/ChecklistPlannerSyncMapperTests.swift`
- `Tests/iOSAlgorithmTests/PDFExportServiceTests.swift`
- `Tests/iOSAlgorithmTests/IOSMainAlgorithmReadinessTests.swift`
- `Tests/WatchAlgorithmTests/WatchMainUILocalizationTests.swift`

### Documentation
- `Docs/RATIO_DECO_COMPARATIVE_HEURISTIC.md` *(new)*
- `Docs/README.md`, `Docs/INDEX.md`, `Docs/RELEASE_CHECKLIST.md`
- `Docs/MAIN_BRANCH_FINAL_READINESS_REPORT.md`
- `Docs/MAIN_PHYSICAL_EXTERNAL_QA_CHECKLIST.md`
- `Docs/DIR_DIVING_IOS_BUHLMANN_EXTERNAL_VALIDATION_PLAN.md`

---

## Tests added / modified

**New:** `IOSMainAlgorithmMathRemediationTests` (20 tests) — balanced/linear, ceiling violation, Ratio Deco PDF, checklist migration, tissue labels, bailout exclusion, NDL depthBand, noDecoGases, cloud round-trip, Dive Pack size, comparison runtime.

**Modified:** `ChecklistPlannerSyncMapperTests`, `PDFExportServiceTests`, `IOSMainAlgorithmReadinessTests`, `WatchMainUILocalizationTests`.

---

## Validation

### Pre-flight @ `a6ccd8d`

```
git branch --show-current  → main
git status -sb             → clean
git rev-parse --short HEAD → a6ccd8d
xcodegen generate          → OK
```

### Post-remediation (2026-06-07)

| Command | Result |
|---------|--------|
| `xcodegen generate` | **PASS** |
| `xcodebuild -scheme "DIRDiving iOS" -destination 'generic/platform=iOS Simulator' CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO build` | **PASS** |
| `xcodebuild -scheme "DIRDiving iOS Algorithm Tests" -destination 'platform=iOS Simulator,name=iPhone 17 Pro' test` | **PASS** — **455** executed, **13** skipped, **0** failures |
| `xcodebuild -scheme "DIRDiving Watch App" -destination 'generic/platform=watchOS Simulator' CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO build` | **PASS** |
| `xcodebuild -scheme "DIRDiving Watch Algorithm Tests" -destination 'platform=watchOS Simulator,name=Apple Watch Ultra 3 (49mm)' test` | **PASS** |

**Simulator substitution:** none — iPhone 17 Pro and Apple Watch Ultra 3 (49mm) available as specified.

---

## Confirmations

- **Bühlmann math:** not modified except `NDLPoint` label field rename (`compartmentGroup` → `depthBand` on NDL reference curve only)
- **Ratio Deco:** heuristic/comparative only; validator does not alter Bühlmann engine
- **CNS/OTU formulas:** unchanged
- **Physical QA:** not falsely marked complete
- **App Store readiness:** not claimed

---

## Remaining manual tasks (PENDING)

| Task | Status |
|------|--------|
| Apple Watch Ultra underwater / depth sensor QA | **PENDING** |
| Real underwater haptic QA | **PENDING** |
| Real GPS entry/exit lifecycle QA | **PENDING** |
| Paired iPhone + Apple Watch QA | **PENDING** |
| iCloud two-device QA | **PENDING** |
| Subsurface external import/export validation | **PENDING** |
| Legal review | **PENDING** |
| App Store review | **PENDING** |
| External Bühlmann reference validation | **PENDING** — [`DIR_DIVING_IOS_BUHLMANN_EXTERNAL_VALIDATION_PLAN.md`](DIR_DIVING_IOS_BUHLMANN_EXTERNAL_VALIDATION_PLAN.md) |

---

## Related documents

- [`IOS_MAIN_ALGORITHM_MATH_AUDIT_CURRENT.md`](IOS_MAIN_ALGORITHM_MATH_AUDIT_CURRENT.md)
- [`RATIO_DECO_COMPARATIVE_HEURISTIC.md`](RATIO_DECO_COMPARATIVE_HEURISTIC.md)
- [`MAIN_PHYSICAL_EXTERNAL_QA_CHECKLIST.md`](MAIN_PHYSICAL_EXTERNAL_QA_CHECKLIST.md)
