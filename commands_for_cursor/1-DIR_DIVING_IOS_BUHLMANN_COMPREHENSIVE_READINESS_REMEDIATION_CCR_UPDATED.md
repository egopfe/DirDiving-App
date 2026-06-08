# 1-DIR_DIVING_IOS_BUHLMANN_COMPREHENSIVE_READINESS_REMEDIATION_CCR_UPDATED

## CURSOR / CODEX COMMAND — DIR DIVING iOS BÜHLMANN COMPREHENSIVE READINESS REMEDIATION (CCR UPDATED)

You are working on the DIR DIVING repository.

---

## POSITION IN AUDIT / REMEDIATION SEQUENCE

This command runs **immediately after**:

```text
commands_for_cursor/1-DIR_DIVING_IOS_BUHLMANN_COMPREHENSIVE_READINESS_AUDIT_CCR_UPDATED.md
```

and its output report:

```text
Docs/1-DIR_DIVING_IOS_BUHLMANN_COMPREHENSIVE_READINESS_AUDIT_CCR_CURRENT.md
```

It must run **after** any prior math remediation already merged on `main` (see **Already closed — do not redo** below).

After this remediation completes, re-run the audit command to refresh readiness percentages.

---

## CORE OBJECTIVE

Execute **all repository-completable remediations** identified in the Bühlmann comprehensive readiness audit (CCR updated), raising readiness from the audited **91% overall** baseline toward **internal TestFlight hardening** without faking external validation or physical QA.

This command covers:

- code fixes and hardening
- automated tests and fixtures
- documentation, review notes, and evidence templates
- QA matrix preparation and evidence folder scaffolding

It does **not** claim completion of physical device QA, third-party Bühlmann sign-off, or App Store legal review unless real evidence is attached.

---

# TARGET

| Item | Value |
|---|---|
| Branch | `main` only |
| Primary app target | `DIRDiving iOS` |
| Watch target | Build verification only unless a change explicitly requires Watch sync payload review |
| Experimental branches | Do not modify |
| Experimental runtime surfaces | Do not add to MAIN targets |

**STOP** if branch is not `main`.

---

# TASK TYPE

**FULL REMEDIATION** — implement, test, document.

## DO

- fix identified gaps that are code- or repo-completable
- add meaningful XCTest coverage
- add or update documentation and QA evidence templates
- localize user-facing strings (EN + IT parity)
- preserve non-certified / reference-only posture
- preserve Bühlmann as primary OC decompression model
- preserve Ratio Deco as comparative heuristic only
- preserve CCR as reference planner only (not loop controller)
- keep CCR isolated from OC Bühlmann core unless fixing shared utilities (units, MOD, export)

## DO NOT

- claim certified decompression or CCR controller certification
- claim live loop PPO₂ monitoring unless real validated sensor integration exists
- mark external Bühlmann validation **PASS** without evidence files
- mark CCR external validation **PASS** without evidence files
- mark iCloud two-device QA **PASS** without recorded matrix results
- mark Watch Ultra physical QA **PASS** without recorded matrix results
- redesign unrelated UI
- refactor unrelated modules
- change experimental branches
- silently convert OC Bühlmann logic into CCR logic
- remove safety disclaimers
- introduce `try!`, `as!`, or hardcoded secrets
- push unless explicitly requested by the user

---

# SOURCE AUDIT REPORT (AUTHORITATIVE INPUT)

Read fully before editing:

```text
Docs/1-DIR_DIVING_IOS_BUHLMANN_COMPREHENSIVE_READINESS_AUDIT_CCR_CURRENT.md
```

Also integrate context from:

| Document | Purpose |
|---|---|
| `Docs/IOS_MAIN_ALGORITHM_MATH_AUDIT_REMEDIATION_REPORT.md` | Closed math/CCR P1–P3 items @ `cc4d783` |
| `Docs/DIR_DIVING_IOS_BUHLMANN_COMPREHENSIVE_READINESS_REMEDIATION_V3_REPORT.md` | Prior OC comprehensive remediation patterns |
| `Docs/CCR_REBREATHER_VALIDATION_PLAN.md` | CCR external validation slots |
| `Docs/DIR_DIVING_IOS_BUHLMANN_EXTERNAL_VALIDATION_PLAN.md` | Bühlmann external validation |
| `Docs/ICLOUD_TWO_DEVICE_QA_MATRIX.md` | iCloud manual QA |
| `Docs/WATCH_IOS_SYNC_QA_MATRIX.md` | Watch sync manual QA |
| `Docs/CSV_SUBSURFACE_QA_MATRIX.md` | CSV manual QA |
| `Docs/SUBSURFACE_CSV_ROUNDTRIP.md` | CSV policy |
| `Docs/TESTFLIGHT_REVIEW_NOTES.md` | Review posture |
| `Docs/SAFETY_DISCLAIMER.md` | Legal/safety posture |
| `Docs/QA_EVIDENCE_PACK_TEMPLATE.md` | Evidence pack format |
| `Docs/RELEASE_CHECKLIST.md` | Release gates |
| `Scripts/validate_main_release_readiness.sh` | Release gate script |

If the audit report HEAD differs from current `main`, note both SHAs in the remediation report.

---

# ALREADY CLOSED — DO NOT REDO

The following were closed in **math remediation @ `cc4d783`**. Verify still green; do not re-implement unless regressed:

| ID | Summary |
|---|---|
| P1-001 | `CCRTissueHistorySampler` engine-aligned tissue trace |
| P1-002 | `runtimeSegments` quarantine documented + test |
| P1-003 | Bailout heuristic labeling (not Bühlmann schedule) |
| P1-004 | Water vapor in `CCRInspiredGasModel` |
| P1-005 | Imperial CCR switch depth in manual dive |
| P1-006 | Ratio Deco rejects `.ccr` |
| P2-002…P2-012 | Export gate, PDF localization, CSV, checklist CCR roles, persistence, service limits |
| P3-001…P3-002 | GF validation label, IT CCR strings |

If any regression is found, fix it under a **new remediation ID** (e.g. `CCR-REM-P0-REG-001`) and document in the report.

---

# OUTPUT FILE (MANDATORY)

Create:

```text
Docs/1-DIR_DIVING_IOS_BUHLMANN_COMPREHENSIVE_READINESS_REMEDIATION_CCR_CURRENT.md
```

The remediation report must include:

1. Executive summary with **before/after readiness %** per Release Hard Matrix row
2. Scope confirmation (branch, SHAs, build/test commands, results)
3. Issue matrix: ID → fix → files → tests → status
4. Files changed (grouped: app / tests / docs / scripts)
5. Tests added/modified and full test run results
6. Static checks (no certified claims, EN/IT parity, no experimental leakage)
7. Remaining **PENDING** external/physical gates (explicitly not faked)
8. Confirmations (Bühlmann unchanged unless documented, Ratio Deco heuristic, CCR reference-only)
9. Recommended next command: re-run audit `1-DIR_DIVING_IOS_BUHLMANN_COMPREHENSIVE_READINESS_AUDIT_CCR_UPDATED.md`

Optional evidence directories (create if missing, `.gitkeep` only — no fake screenshots):

```text
Docs/QA_EVIDENCE/BUHLMANN_EXTERNAL/
Docs/QA_EVIDENCE/CCR_EXTERNAL/
Docs/QA_EVIDENCE/ICLOUD_TWO_DEVICE/
Docs/QA_EVIDENCE/SUBSURFACE_CSV/
Docs/QA_EVIDENCE/RATIO_DECO_SIMULATOR/
Docs/QA_EVIDENCE/CCR_DIVE_PACK_PDF/
```

---

# PHASE 0 — PREFLIGHT

Run and record:

```bash
git branch --show-current
git status
git rev-parse HEAD
git rev-parse --short HEAD
git log -1 --oneline
```

Then:

```bash
xcodegen generate
xcodebuild -scheme "DIRDiving iOS" -destination 'platform=iOS Simulator,name=iPhone 17' build
xcodebuild -scheme "DIRDiving iOS Algorithm Tests" -destination 'platform=iOS Simulator,name=iPhone 17' test
```

Record baseline test count (expect **≥526 passed**, 13 skipped, 0 failures @ audit time).

If iPhone 17 unavailable, use nearest iOS 26 simulator and document substitution.

Optional baseline readiness script:

```bash
./Scripts/validate_main_release_readiness.sh
```

Record pass/fail; fix script failures only if they block release gates and are in scope.

---

# PHASE 1 — ISSUE INTake FROM AUDIT

Build an internal working matrix from audit sections **S, T, D–R**. Map each open gap to a remediation ID:

| Remediation prefix | Audit source |
|---|---|
| `CCR-REM-P1-*` | Audit P1 (external gates + disclosure) |
| `CCR-REM-P2-*` | Audit P2 (code + test hardening) |
| `CCR-REM-P3-*` | Audit P3 (polish) |
| `CCR-REM-P4-*` | Audit P4 (optional / defer with rationale) |

Every implemented fix must reference at least one audit gap or audit action-plan ID.

---

# PHASE 2 — P1 REMEDIATIONS (HIGH — RELEASE DISCLOSURE & EVIDENCE SCAFFOLDING)

These items are **process-heavy** but the repo must prepare honest artifacts — not fake passes.

## CCR-REM-P1-EXT-BM — Bühlmann external validation scaffold

**Audit refs:** P1-EXT-BM, Bühlmann 94% / external 60%

**Goal:** Make external comparison **executable** without claiming completion.

**Actions:**

1. Update `Docs/DIR_DIVING_IOS_BUHLMANN_EXTERNAL_VALIDATION_PLAN.md` with CCR-aware note (OC profiles only for third-party compare).
2. Ensure `Docs/BUHLMANN_EXTERNAL_VALIDATION_FIXTURES_TEMPLATE.md` exists; extend with 3–5 representative OC profiles (air NDL, nitrox deco, trimix technical, altitude, freshwater if supported).
3. Add `Docs/QA_EVIDENCE/BUHLMANN_EXTERNAL/README.md` explaining required evidence (screenshots, delta table, tool versions).
4. Optional: add `Tests/iOSAlgorithmTests/BuhlmannExternalValidationFixtureTests.swift` that loads fixture JSON and asserts **internal** schedule invariants (monotonic stops, GF bounds) — **not** external pass.

**Acceptance:**

- All template slots remain ☐ until human fills them
- No doc says "externally validated" or "certified"
- Fixture tests pass internally

---

## CCR-REM-P1-EXT-CCR — CCR external validation scaffold

**Audit refs:** P1-EXT-CCR, CCR 88%, bailout 72%

**Goal:** Structure CCR-01…04 execution without faking manufacturer sign-off.

**Actions:**

1. Update `Docs/CCR_REBREATHER_VALIDATION_PLAN.md` with explicit **heuristic bailout** column (SAC estimate vs external SAC — not Bühlmann OC switch).
2. Add `Docs/QA_EVIDENCE/CCR_EXTERNAL/README.md` with capture instructions (setpoint, diluent, GF, delta tolerances).
3. Add internal reference tests in `Tests/iOSAlgorithmTests/CCRComprehensiveReadinessRemediationTests.swift`:
   - CCR-01 profile (30 m / 25 min, air diluent, 0.7/1.3 @ 20 m) — schedule non-empty, stops ascending
   - CCR-02 trimix diluent — validator accepts valid mix
   - CCR-03 shallow setpoint edge — validator behavior documented
   - CCR-04 bailout heuristic returns finite SAC volumes; PDF/UI strings contain "heuristic" or localized equivalent

**Acceptance:**

- External slots still ☐
- Bailout never labeled as Bühlmann OC schedule in tests (grep assertions)

---

## CCR-REM-P1-ICLOUD — iCloud two-device QA preparation

**Audit refs:** P1-ICLOUD, Cloud 86%

**Goal:** Repo-ready matrix + any automatable persistence tests.

**Actions:**

1. Update `Docs/ICLOUD_TWO_DEVICE_QA_MATRIX.md` with CCR plan persistence cases (export planner → sync → verify diluent/bailout/setpoint).
2. Add/extend tests for CCR JSON round-trip + conflict policy if gaps found (`CloudSyncService`, `CCRPlanInput` encoding).
3. Add `Docs/QA_EVIDENCE/ICLOUD_TWO_DEVICE/README.md`.

**Acceptance:**

- Matrix includes CCR rows
- Automated tests pass; manual matrix still **PENDING**

---

## CCR-REM-P1-BAILOUT-DOC — TestFlight / safety disclosure alignment

**Audit refs:** P1-BAILOUT-DOC, TestFlight blockers

**Goal:** Review notes and disclaimers explicitly state CCR bailout heuristic.

**Actions:**

1. Update `Docs/TESTFLIGHT_REVIEW_NOTES.md` — CCR reference-only, bailout SAC heuristic, no loop monitoring.
2. Cross-check `Docs/SAFETY_DISCLAIMER.md` and `Docs/APP_STORE_REVIEW_NOTES.md` for consistent wording.
3. Add test or string audit in remediation suite: EN/IT keys for bailout heuristic present (`ccr.bailout.*` or equivalent).

**Acceptance:**

- No "engine-simulated bailout" or "certified decompression" wording
- EN/IT parity maintained

---

# PHASE 3 — P2 REMEDIATIONS (MEDIUM — CODE + TEST HARDENING)

## CCR-REM-P2-CCR-PDF — CCR Dive Pack PDF parity

**Audit refs:** P2-CCR-PDF, PDF 90%, CCR export 88%

**Primary files:**

- `iOSApp/Services/PDF/DivePackPDFBuilder.swift`
- `iOSApp/Services/PDF/PDFExportService.swift`
- `iOSApp/Services/PDF/CCRPlannerPDFBuilder.swift` (if separate)
- `Tests/iOSAlgorithmTests/PDFExportServiceTests.swift`

**Actions:**

1. Audit OC Dive Pack sections vs CCR — identify missing sections (setpoint summary, diluent, bailout heuristic block, disclaimer).
2. Implement missing CCR fields in Dive Pack PDF using same unit/formatters as OC (`Formatters`, `IOSUnitPreference`).
3. Add tests:
   - `testDivePackPDFIncludesCCRSetpointAndDiluent` — PDF bytes contain localized markers or structured field asserts
   - `testDivePackPDFCCRIncludesBailoutHeuristicDisclaimer`
   - `testDivePackPDFCCRMetricAndImperialSwitchDepth` if applicable
4. Ensure `PDFExportService.canExportCCRPlan` still gates `.unavailable` plans.

**Acceptance:**

- CCR Dive Pack PDF tests pass
- No certified-plan wording

---

## CCR-REM-P2-SUBSURFACE — CSV / Subsurface harness

**Audit refs:** P2-SUBSURFACE, CSV 85%, Subsurface external 50%

**Primary files:**

- `iOSApp/Services/DiveImportService.swift`
- Export services for Subsurface CSV
- `Tests/iOSAlgorithmTests/CSVMetadataRoundTripTests.swift`

**Actions:**

1. Read `Docs/SUBSURFACE_CSV_ROUNDTRIP.md` and `Docs/CSV_IMPORT_EXPORT_POLICY.md`.
2. Extend round-trip tests for CCR metadata columns (setpoint, diluent, bailout) if policy claims support.
3. Update `Docs/CSV_SUBSURFACE_QA_MATRIX.md` with CCR rows.
4. Add `Docs/QA_EVIDENCE/SUBSURFACE_CSV/README.md`.

**Acceptance:**

- Internal round-trip tests pass
- External Subsurface validation remains **PENDING**

---

## CCR-REM-P2-RUNTIME — `runtimeSegments` fate

**Audit refs:** P2-RUNTIME, quarantined `runtimeSegments`

**Primary files:**

- `iOSApp/Services/CCR/CCRPlannerEngine.swift`
- `iOSApp/Models/CCRModels.swift` (or equivalent)
- `Tests/iOSAlgorithmTests/CCRMathRemediationTests.swift`

**Policy decision (pick one and document in report):**

| Option | Action |
|---|---|
| **A — Implement** | Wire `runtimeSegments` for debug/export-only trace; must not change deco schedule output; add convergence tests |
| **B — Permanent quarantine** | Mark API `@available` internal or rename to `debugSegments`; strengthen docs + test that mutating segments does not affect schedule/stops/tissue |

Default if uncertain: **Option B** (lower regression risk).

**Acceptance:**

- Decision recorded in remediation report
- Tests prove schedule invariants

---

## CCR-REM-P2-WATCH-QA — Watch sync documentation (no Watch runtime CCR)

**Audit refs:** P2-WATCH-QA

**Actions:**

1. Update `Docs/WATCH_IOS_SYNC_QA_MATRIX.md` — confirm Watch does not expose CCR planner; sync must not corrupt iOS CCR fields.
2. Add test if missing: Watch payload encoding/decoding preserves CCR-agnostic iOS algorithm fields.

**Acceptance:**

- Manual matrix updated; physical QA **PENDING**

---

## CCR-REM-P2-TEST-COVERAGE — Comprehensive readiness test suite

**Create:**

```text
Tests/iOSAlgorithmTests/BuhlmannComprehensiveReadinessCCRRemediationTests.swift
```

**Minimum test categories (implement all that apply):**

| Category | Example tests |
|---|---|
| Planner mode projection | Base ignores hidden technical gases; Deco max one deco; Technical includes bailout in ledger not schedule |
| MOD autoclamp edge | Switch depth clamps to MOD; exactly-at-MOD switch allowed/rejected per policy |
| Ratio Deco | Comparison mode unavailable in CCR; overlay data non-empty for OC |
| Gas roles | `ccrDiluent` / `ccrBailout` checklist sync; OC bailout excluded from Bühlmann |
| Tissue | `.ccrPlanned` source; logbook simulated footnote keys resolve EN/IT |
| Narcosis | CCR planner presentation non-nil; footnote key for estimator limit |
| Checklist | Role inference improvement tests if code changed |
| PDF | Briefing + Dive Pack CCR sections (bytes or builder API) |
| CSV | CCR metadata round-trip |
| Cloud | CCR plan encoding round-trip |

Register file in `project.yml` if needed.

**Acceptance:**

- New suite green; total iOS tests **>526** unless skips added with rationale

---

# PHASE 4 — P3 REMEDIATIONS (POLISH)

## CCR-REM-P3-VISUAL — QA matrices (no fake completion)

**Audit refs:** P3-VISUAL, Planner 92%, Ratio Deco 86%

**Actions:**

1. Cross-link `Docs/RATIO_DECO_SIMULATOR_QA_CHECKLIST.md`, `Docs/IOS_DYNAMIC_TYPE_VOICEOVER_QA_MATRIX.md`, `Docs/IOS_UI_QA_MATRIX.md` from remediation report.
2. Add planner CCR screen rows to `Docs/IOS_UI_QA_MATRIX.md` if missing.
3. Ensure evidence folders exist under `Docs/QA_EVIDENCE/RATIO_DECO_SIMULATOR/`.

**Acceptance:** matrices updated; evidence slots empty ☐

---

## CCR-REM-P3-CHECKLIST — Checklist role inference hardening

**Audit refs:** P3-CHECKLIST, Checklist 84%

**Primary files:**

- `iOSApp/Utils/ChecklistPlannerSyncMapper.swift`
- `iOSApp/Views/EquipmentView.swift` (sync sheet if present)
- `Tests/iOSAlgorithmTests/ChecklistPlannerSyncMapperTests.swift`

**Actions:**

1. Improve inference for ambiguous titles (diluent/bailout/travel/deco) using ordered rules + explicit CCR export path first.
2. When inference ambiguous, prefer **no silent wrong role** — surface default or require user confirmation in sync UI if already present; do not add heavy new UI — minimal hint strings OK.
3. Add regression tests for known mis-classification edge cases from audit.

**Acceptance:**

- Tests for diluent/bailout/travel/deco inference
- CCR `applyCCRExport` still authoritative for CCR mode

---

## CCR-REM-P3-NARCOSIS — CCR density estimator disclosure

**Audit refs:** P3-NARCOSIS, Narcosis 88%

**Primary files:**

- `iOSApp/Services/CCR/CCRGasDensityEstimator.swift`
- `iOSApp/Views/TissueAnalytics/TissueNarcosisAnalyticsView.swift` (or equivalent)
- `iOSApp/Resources/en.lproj/Localizable.strings`
- `iOSApp/Resources/it.lproj/Localizable.strings`

**Actions:**

1. Add concise footnote when source is `.ccrPlanned` — simplified loop density estimator, not full physics.
2. Test EN/IT key resolution.

**Acceptance:**

- Footnote visible in CCR planner analytics path
- No change to OC narcosis math

---

## CCR-REM-P3-MOD-VISUAL — MOD / switch-depth edge documentation

**Audit refs:** MOD 93%, Switch clamp 91%

**Actions:**

1. Add/modify `Docs/IOS_PLANNER_MOD_SWITCH_DEPTH_AUTOCLAMP_REPORT.md` with CCR setpoint note (PPO₂ bar not converted as tank psi).
2. Add unit tests for edge cases: switch depth > MOD clamps; hypoxic gas rejected.

**Acceptance:** tests pass; doc updated

---

## CCR-REM-P3-TISSUE-LOGBOOK — Logbook simulated segment clarity

**Audit refs:** Tissue 90%, Manual dive 88%

**Actions:**

1. Verify `TissueAnalyticsLogbookReplay` / footnotes from V3 remediation still correct for CCR logbook entries.
2. If CCR manual dives show tissue analytics, ensure source is `.simulated` or `.ccrPlanned` appropriately — never `.planned` Bühlmann OC for CCR manual unless explicitly documented.
3. Add tests for CCR manual dive session tissue source labeling.

**Acceptance:**

- Tests pass; no fake "full Bühlmann replay" for unsupported logbook paths

---

# PHASE 5 — P4 OPTIONAL (DOCUMENT DEFERRAL UNLESS USER SCOPE EXPANDS)

## CCR-REM-P4-BAILOUT-ENGINE — Bühlmann OC bailout switch simulation

**Audit refs:** P4-BAILOUT-ENGINE, bailout 72%

**Default:** **Do not implement** in this pass unless explicitly justified in report.

If deferred, document:

- architecture needed (handoff from CCR setpoint to OC Bühlmann at switch depth)
- regression risk
- alternative: keep heuristic with strengthened disclosure (current policy)

---

## CCR-REM-P4-GOLDEN — Golden Bühlmann fixture expansion

**Actions (optional):**

- Add golden JSON fixtures under `Tests/Fixtures/Buhlmann/` for 2–3 profiles
- Tests compare stop depths/times within tolerance

---

## CCR-REM-P4-PERF — Long-profile performance

**Actions (optional):**

- Add performance test boundary (e.g. 120 min bottom, 6 deco gases) — assert completes < N seconds on simulator

---

# PHASE 6 — LOCALIZATION & COPY AUDIT

For every new user-facing string:

1. Add EN key in `iOSApp/Resources/en.lproj/Localizable.strings`
2. Add IT key in `iOSApp/Resources/it.lproj/Localizable.strings`
3. Verify parity (same keys both files)

Forbidden wording (grep before finish):

- "certified decompression"
- "CCR controller"
- "guaranteed safe"
- "manufacturer approved"
- "engine-simulated bailout" (unless Option A actually implemented)

Required wording where applicable:

- "reference only"
- "heuristic" / "stima euristica" for Ratio Deco and CCR bailout
- "not a dive computer" where Watch mentioned

---

# PHASE 7 — REGRESSION GUARDRAILS

Before finishing, confirm unchanged unless explicitly fixed:

| Area | Guard |
|---|---|
| Bühlmann ZH-L16C constants | No coefficient changes without fixture update |
| OC `BuhlmannEngine` schedule | Golden/smoke tests still pass |
| Ratio Deco | Still heuristic; no CCR path |
| CCR isolation | `PlannerMode.ccr` uses `CCRPlannerEngine` only |
| Watch runtime | No CCR loop features added |
| Experimental targets | No new experimental files in MAIN |

Run:

```bash
./Scripts/check_main_target_isolation.sh
./Scripts/check_secrets.sh
```

Fix violations if introduced.

---

# PHASE 8 — BUILD & TEST VALIDATION

Required commands:

```bash
xcodegen generate
xcodebuild -scheme "DIRDiving iOS" -destination 'platform=iOS Simulator,name=iPhone 17' build
xcodebuild -scheme "DIRDiving iOS Algorithm Tests" -destination 'platform=iOS Simulator,name=iPhone 17' test
xcodebuild -scheme "DIRDiving Watch App" -destination 'platform=watchOS Simulator,name=Apple Watch Series 11 (46mm)' build
```

Record exact counts: executed, skipped, failures.

If Ultra 2 unavailable, document simulator substitution.

Re-run if feasible:

```bash
./Scripts/validate_main_release_readiness.sh
```

---

# PHASE 9 — REMEDIATION REPORT

Write `Docs/1-DIR_DIVING_IOS_BUHLMANN_COMPREHENSIVE_READINESS_REMEDIATION_CCR_CURRENT.md` with:

## 1. Executive summary

- starting HEAD / ending HEAD
- overall readiness before → after (target **≥93%** repo-completable scope; do not inflate external gates)
- bullet list of closed IDs

## 2. Issue matrix

| ID | Severity | Audit ref | Fix summary | Files | Tests | Status |
|---|---|---|---|---|---|---|

## 3. Updated Release Hard Matrix

Copy audit section S table with updated % and remaining blockers.

## 4. Files changed

Grouped lists.

## 5. Validation table

Build + test commands and results.

## 6. Remaining PENDING (must not be marked done)

- External Bühlmann validation
- External CCR validation
- iCloud two-device QA
- Watch physical QA
- Subsurface external validation
- App Store legal review

## 7. Confirmations

Same checklist as math remediation report.

---

# PHASE 10 — POST-REMEDIATION RE-AUDIT

Tell the user to run:

```text
commands_for_cursor/1-DIR_DIVING_IOS_BUHLMANN_COMPREHENSIVE_READINESS_AUDIT_CCR_UPDATED.md
```

to regenerate `Docs/1-DIR_DIVING_IOS_BUHLMANN_COMPREHENSIVE_READINESS_AUDIT_CCR_CURRENT.md` at the new HEAD.

---

# SUCCESS CRITERIA

Task complete only if:

| Criterion | Required |
|---|---|
| Branch | `main` only |
| P1 evidence scaffolding | Done without fake PASS |
| P2 code items | Implemented or explicitly deferred with rationale |
| P2 CCR Dive Pack PDF | Tests added or documented blocker |
| P2 `runtimeSegments` | Decision A or B implemented |
| New test suite | `BuhlmannComprehensiveReadinessCCRRemediationTests` (or equivalent) green |
| iOS tests | 0 failures |
| iOS build | SUCCEEDED |
| Watch build | SUCCEEDED (if iOS touched shared headers, verify) |
| EN/IT parity | Maintained |
| Remediation report | Created and non-empty |
| No false certification claims | Verified |
| Experimental isolation | Preserved |

---

# IMPLEMENTATION ORDER (RECOMMENDED)

1. Phase 0 preflight + read audit report
2. Phase 1 issue matrix
3. Phase 2 P1 docs/scaffold (no fake passes)
4. Phase 3 P2 CCR PDF + CSV tests
5. Phase 3 P2 runtimeSegments decision
6. Phase 3 P2 comprehensive test suite
7. Phase 4 P3 polish (checklist, narcosis footnote, tissue labeling)
8. Phase 6 localization
9. Phase 7 guardrails
10. Phase 8 build/test
11. Phase 9 remediation report
12. Phase 10 re-audit instruction

---

# ESTIMATED READINESS DELTAS (TARGETS — VERIFY IN REPORT)

| Feature | Audit @ 91% scope | Realistic post-remediation target |
|---|---:|---:|
| Overall | 91% | **93–94%** (repo-completable) |
| CCR / Rebreather | 88% | **90–91%** |
| Checklist Sync | 84% | **87–88%** |
| PDF Export | 90% | **92–93%** |
| CSV/Subsurface | 85% | **87–88%** (internal only) |
| Test Coverage | 89% | **91–92%** |
| External validation | 45% | **45%** until human evidence |
| Manual QA | 55% | **55%** until matrices executed |

Do not mark external validation or manual QA higher without evidence files.

---

# NOTES FOR EXECUTOR

- Prefer **minimal diffs** — match existing code style in touched files.
- Reuse patterns from `BuhlmannComprehensiveReadinessV3RemediationTests.swift` and `CCRMathRemediationTests.swift`.
- When audit gap is already closed @ `cc4d783`, write **Verified — no change** in report.
- If a P2 item is blocked (e.g. Subsurface app not installed), document blocker and add harness tests only.
- Commit only when user asks; default end state may be uncommitted working tree with clean test run.

---

*End of command — Bühlmann Comprehensive Readiness Remediation (CCR Updated)*
