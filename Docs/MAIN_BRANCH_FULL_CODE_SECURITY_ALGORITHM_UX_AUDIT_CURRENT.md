# DIR DIVING MAIN — Full Code / Function / UI-UX / Security / Algorithm Audit (Current)

**Audit date:** 2026-06-02  
**Repository:** `DirDiving-App`  
**Branch audited:** `main` @ `09473ca`  
**Scope:** `DIRDiving Watch App` + `DIRDiving iOS` MAIN targets only  
**Audit mode:** Read-only (no code changes during this audit)  

---

## A. Executive Summary

| Dimension | Readiness | Notes |
|---|---:|---|
| Overall readiness | **~96%** | Code quality and test posture are strong; remaining blockers are mostly physical QA/release process |
| Watch readiness | **~95%** | Simulator build/tests pass; underwater entitlement + real device behavior still external QA |
| iOS readiness | **~97%** | Build/tests pass; planner and sync paths broadly hardened |
| UI/UX readiness | **~95%** | MAIN text remediation landed; remaining clipping/dynamic-type/device validation is manual |
| Security readiness | **~95%** | HMAC + replay hardening + protected storage improvements present; residual risk mainly process/device |
| Algorithm readiness | **~98%** | Watch and iOS algorithm suites pass; latest iOS math audit issues were remediated |
| Data/sync readiness | **~95%** | Signed payload + conflict/tombstone handling in place; two-device cloud QA remains required |
| Internal TestFlight readiness | **Conditionally ready** | Code/build/tests OK; pending physical checklist completion |
| External TestFlight readiness | **Not yet fully ready** | Requires paired-device and accessibility walkthrough sign-off |
| App Store readiness | **Not yet fully ready** | Requires external QA evidence + screenshots/reference assets |

### Top findings

1. **No compile/test blockers** in this environment: `xcodegen`, Watch/iOS builds, Watch algorithm tests, iOS algorithm tests all passed.
2. **MAIN target isolation is correct** in `project.yml`; experimental Apnea/Snorkeling/Buddy/Exploration files are excluded from production targets.
3. **Security posture is good** (signed sync payloads, file protection on critical storage paths, replay skew reduced), but real-device and two-device cloud behaviors still need execution evidence.
4. **UI text/localization remediation is in place**; EN/IT parity remains zero-delta in both Watch and iOS catalogs.
5. **Primary remaining blockers are external QA/process**, not obvious source-level defects in MAIN runtime code.

---

## B. Scope Confirmation

### Preflight status

| Check | Result |
|---|---|
| Branch | `main` |
| Commit | `09473ca` |
| Working tree | Clean |
| Main targets | `DIRDiving Watch App`, `DIRDiving iOS` |
| Experimental exclusions | Confirmed in `project.yml` |

### Experimental exclusion verification

- **Watch excludes:** `ApneaView.swift`, `SnorkelingView.swift`, `BuddyAssistView.swift`, `ExperimentalConceptsView.swift`, `Utils/ExperimentalFeatures.swift`, exploration/buddy models/services.
- **iOS excludes:** `ExplorationModels.swift`, `BuddyExperimentalModels.swift`, `ExplorationPlanningStore.swift`, `BuddyExperimentalStore.swift`, `ExplorationCenterView.swift`, `ExperimentalFutureConceptsView.swift`, `BuddyExperimentalView.swift`.

### Baseline commands executed (this audit)

- `xcodegen generate` → PASS  
- `xcodebuild -scheme "DIRDiving Watch App" ... build` → PASS  
- `xcodebuild -scheme "DIRDiving iOS" ... build` → PASS  
- `xcodebuild -scheme "DIRDiving Watch Algorithm Tests" ... test` → PASS (62 tests, 0 failures)  
- `xcodebuild -scheme "DIRDiving iOS Algorithm Tests" ... test` → PASS (185 tests, 1 skipped, 0 failures)

---

## C. Architecture Audit

### Project structure and target boundaries

**Watch MAIN**
- Separate watch target with explicit include/exclude lists.
- Core algorithm/runtime sources explicitly pinned in `project.yml` to prevent stale project drift.
- Entitlements include iCloud KVS/CloudKit and `com.apple.developer.coremotion.water-submersion`.

**iOS MAIN**
- `iOSApp` is single source root with explicit experimental exclusions.
- Companion relationship is correct: iOS embeds Watch app and companion bundle ID points to iOS bundle.

**Shared model/codec**
- Shared sync/session models (`DiveSession`, `DiveSample`, codec/auth/sync helpers) are referenced across Watch/iOS + tests.
- No obvious duplicate competing implementations in MAIN targets.

### Build/project findings

| ID | Sev | Priority | Area | Finding | Evidence | Proposed fix |
|---|---|---|---|---|---|---|
| ARCH-001 | LOW | P3 | Build docs/process | Generated project dependence (`xcodegen generate`) can still be missed by contributors | project is generated, no committed `.xcodeproj` | Keep docs/CI enforcing xcodegen step |
| ARCH-002 | INFO | P4 | Target isolation | Experimental files correctly excluded from MAIN | `project.yml` excludes | Maintain as-is |

---

## D. Apple Watch Functional Audit

### Feature inventory verdict

All listed MAIN Watch features are present and reachable in code, including:
- legal onboarding and launch disclaimer
- live dashboard (depth/runtime/TTV/ascent gauge)
- auto dive + manual fallback
- stale-depth handling
- depth safety 35/38/40m
- GPS fix/fallback/no-fix banners
- BUSSOLA with set/clear bearing
- alarms + ascent-rate settings
- mission mode indicator/toggles
- dive log/detail/export flow
- user images
- sync queue/retry and app intents

### Watch issues detected

| ID | Sev | Priority | Area | File/screen | Description | User impact | Safety impact | Security impact | Proposed fix | Effort |
|---|---|---|---|---|---|---|---|---|---|---|
| W-FUNC-001 | MEDIUM | P2 | Hardware interaction | `DiveManager`, entitlement-driven paths | Auto-depth lifecycle cannot be fully validated in simulator | Medium | Medium | Low | Run real Apple Watch Ultra depth callback and lifecycle matrix | Process (external) |
| W-FUNC-002 | LOW | P3 | Feature reachability | `ModeSelectionView` | Dormant unless multiple stable modes; acceptable but potentially confusing if surfaced later | Low | None | None | Keep hidden in single-mode MAIN; document behavior | Small |
| W-FUNC-003 | LOW | P3 | UX discoverability | Settings export row now truthful, still a navigation shortcut | User may still expect immediate share sheet | Low | None | None | Optional secondary hint in QA docs/tutorial | Small |

---

## E. iOS Functional Audit

### Feature inventory verdict

iOS MAIN modules are fully wired in current source:
- legal onboarding/disclaimer
- planner + result states + warnings
- logbook + manual add/edit
- dive detail + CSV export
- analysis + charts + route summaries
- equipment/checklists
- more/settings (watch sync, iCloud sync, conflicts, reviewer toggle, legal)
- csv import panel and Subsurface-oriented export flow

### iOS issues detected

| ID | Sev | Priority | Area | File/screen | Description | User impact | Safety impact | Security impact | Proposed fix | Effort |
|---|---|---|---|---|---|---|---|---|---|---|
| I-FUNC-001 | LOW | P3 | UX/process | `MoreView`, `Logbook`, CSV flows | Import/export behavior is correct but still needs external interoperability sign-off | Low | Low | None | Execute Subsurface round-trip QA on release checklist | Process (external) |
| I-FUNC-002 | MEDIUM | P2 | Cloud integrity | `DiveLogStore`, `CloudSyncStore` | Session-level merge/conflict logic exists; two-device timing/tombstone behavior still needs field execution proof | Medium | Medium | Medium | Two-device iCloud conflict/tombstone test run | Process (external) |

---

## F. UI/UX Audit (Watch + iOS + Cross-app)

### Current status

- UI text remediation was already applied on `main` (semantic key cleanup, export row wording, legal copy localization, chart a11y labels).
- No evidence of UI redesign or visual-identity drift.
- BUSSOLA terminology preserved; no `COMPASSO` in compiled MAIN UI code paths.

### Open UX/a11y/process items

| ID | Sev | Priority | App | Area | Finding | Proposed fix |
|---|---|---|---|---|---|---|
| UX-001 | MEDIUM | P2 | Watch | Clipping/readability | 41/45/49 mm all-badge Live overlays require physical/simulator visual sign-off | Execute checklist in `Docs/MAIN_UI_TEXT_QA_CHECKLIST.md` |
| UX-002 | MEDIUM | P2 | iOS | Dynamic Type | Dense planner fields require AX-size walkthrough evidence | Run dynamic type matrix on small/large iPhones |
| UX-003 | MEDIUM | P2 | Both | Accessibility walkthrough | Code-level labels exist, but full VoiceOver journey remains unexecuted | Complete scripted VoiceOver pass and record evidence |
| UX-004 | LOW | P3 | Docs/process | Reference UI assets | `Docs/ReferenceUI/*.png` placeholders documented, actual screenshots missing | Capture and store canonical screenshots |

---

## G. Security / Privacy Audit

### Security controls observed in code

- Signed Watch/iOS payload transport (`WatchDiveSyncCodec` + auth key derivation).
- Replay skew tightened (`maxIssuedAtSkew` at 3600s on watch codec path).
- Protected file writes (`.atomic`, `.completeFileProtection`) in major log/sync/export paths.
- iCloud/Watch trust reset flows present with explicit user actions.
- Entitlements scoped reasonably (Watch has water-submersion; iOS does not).
- No broad network surface in runtime code paths (no app-level API client layer detected in MAIN app logic).

### Security findings

| ID | Sev | Priority | Area | File | Finding | Impact | Proposed fix |
|---|---|---|---|---|---|---|---|
| SEC-001 | MEDIUM | P2 | Privacy/process | Export/sync/cloud flows | Data handling is code-hardened, but no fresh runtime privacy evidence set (device logs/screenshots) attached in current state | Review/audit traceability risk | Produce release QA evidence pack with data-at-rest and export lifecycle checks |
| SEC-002 | LOW | P3 | Input hardening | `DiveImportService` | Import still reads full file into memory (bounded by size checks but full-string parse path remains) | Potential memory pressure on malformed edge files | Optional streaming parse refactor (post-release) |
| SEC-003 | INFO | P4 | Secrets | Repo-wide | No obvious committed API tokens/secrets in MAIN runtime code | Low | Continue secret scanning in CI |

---

## H. Algorithm / Mathematical Robustness Audit

### Watch
- Depth sampling, sanitization, stale detection, monotonic runtime, ascent calculations, and depth safety bands are implemented and tested.
- Mission Mode remains UI/runtime profile and does not alter dive math (test coverage present).

### iOS
- Bühlmann engine, planner validation, MOD/PPO2, gas scheduling, CNS/OTU, import/export boundaries, and sync model checks are present and extensively tested.
- Previous high-priority math audit items were remediated (per current docs and passing tests).

### Remaining algorithm findings

| ID | Sev | Priority | Area | Finding | Proposed fix |
|---|---|---|---|---|---|
| ALG-001 | MEDIUM | P2 | External validation | Mathematical correctness is strong in-code, but lacks fresh external “golden” comparison evidence for this exact HEAD in this audit | Run external planner/golden verification campaign and record deltas |
| ALG-002 | LOW | P3 | Policy clarity | Watch/iOS policy distinctions are documented but rely on docs for user/test interpretation | Keep docs synchronized with UI copy in each release |

---

## I. Data Integrity / Sync Audit

### Watch ↔ iPhone
- Signed payload and ACK paths present.
- Queue persistence and conflict paths exist.
- Tests cover sync conflict and codec behavior.

### iCloud + tombstones
- Cloud merge/conflict/tombstone machinery exists with tests.
- Field validation across real devices remains open.

### CSV round-trip
- Dedicated round-trip tests exist (`CSVMetadataRoundTripTests`, etc.).
- External tool compatibility sign-off is still process-gated.

| ID | Sev | Priority | Finding | Proposed fix |
|---|---|---|---|---|
| SYNC-001 | MEDIUM | P2 | Real two-device iCloud conflict/tombstone behavior not proven in this audit run | Execute two-device test matrix and archive result evidence |
| SYNC-002 | LOW | P3 | Cross-version behavior drift risk across branches (historically seen) | Keep branch policy: merge to `main` only after watch+iOS compatibility checks |

---

## J. Build / Release / TestFlight / App Store Audit

### Compile status (this run)

| Check | Result |
|---|---|
| `xcodegen generate` | PASS |
| Watch simulator build | PASS |
| iOS simulator build | PASS |
| Watch algorithm tests | PASS (62/62) |
| iOS algorithm tests | PASS (185 executed, 1 skipped, 0 failed) |

### Release readiness assessment

| Stage | Verdict | Blocking items |
|---|---|---|
| Compile readiness | **YES** | None |
| Internal TestFlight | **Mostly YES** | Complete physical QA checklist evidence |
| External TestFlight | **NOT YET** | Real-device clipping/VoiceOver/iCloud/sync/export matrix pending |
| App Store | **NOT YET** | External QA evidence + review assets + policy/documentation confirmation |

---

## K. Issue Matrix

| ID | Severity | Priority | App | Area | File/screen | Title | Impact | Proposed fix |
|---|---|---|---|---|---|---|---|---|
| ARCH-001 | LOW | P3 | Cross | Build | `project.yml`, docs | Generated project workflow dependency | Dev/process error risk | Enforce xcodegen in docs/CI |
| W-FUNC-001 | MEDIUM | P2 | Watch | Function/hardware | `DiveManager` runtime | Auto-depth lifecycle needs physical validation | Medium user/safety | Watch Ultra underwater QA |
| W-FUNC-002 | LOW | P3 | Watch | UX | `ModeSelectionView` | Dormant mode selector behavior | Low confusion risk | Keep hidden/documented |
| I-FUNC-002 | MEDIUM | P2 | iOS | Sync/cloud | `DiveLogStore`, `CloudSyncStore` | Two-device conflict/tombstone needs field evidence | Data integrity risk | Execute iCloud matrix |
| UX-001 | MEDIUM | P2 | Watch | UI/UX | Live overlays | 41/45/49 clipping not physically verified | Readability/safety presentation | Device/sim screenshot pass |
| UX-002 | MEDIUM | P2 | iOS | UI/UX | Planner views | Dynamic Type high-size evidence missing | Readability risk | AX-size walkthrough |
| UX-003 | MEDIUM | P2 | Cross | Accessibility | Multiple screens | Full VoiceOver flow not executed | Accessibility compliance risk | Run scripted VoiceOver QA |
| UX-004 | LOW | P3 | Cross | Release assets | `Docs/ReferenceUI` | Missing canonical screenshots | App Review/process risk | Capture references |
| SEC-001 | MEDIUM | P2 | Cross | Security/privacy | Export/sync evidence | Hardened code but evidence set incomplete for this cycle | Compliance/review risk | Produce security QA evidence pack |
| SEC-002 | LOW | P3 | iOS | Import/export | `DiveImportService` | Full-string CSV parse can stress memory in edge inputs | Stability risk | Optional streaming parser |
| ALG-001 | MEDIUM | P2 | iOS | Algorithm QA | Planner/math docs/tests | External golden validation not freshly executed | Confidence/release risk | Run golden comparison campaign |
| SYNC-001 | MEDIUM | P2 | Cross | Data integrity | Watch+iOS+iCloud | Real-world two-device sync not validated in this run | Merge/conflict risk | Execute paired-device matrix |
| REL-001 | MEDIUM | P2 | Cross | Release | TestFlight/App Store | External QA gates still open | Release blocker | Complete pre-TF/pre-store checklist |

---

## L. Action Plan (P0–P4 by area)

### A) Apple Watch

- **P0:** None detected.
- **P1:** None detected (code-level).
- **P2:** `W-FUNC-001`, `UX-001`, `UX-003` (hardware + clipping + VO).
- **P3:** `W-FUNC-002`.
- **P4:** Continuous regression checks.

### B) iOS Companion

- **P0:** None detected.
- **P1:** None detected (code-level).
- **P2:** `I-FUNC-002`, `UX-002`, `ALG-001`.
- **P3:** `SEC-002`.
- **P4:** Continuous data-shape monitoring.

### C) Cross-app

- **P0:** None.
- **P1:** None.
- **P2:** `SYNC-001`, `REL-001`, `SEC-001`, `UX-003`.
- **P3:** `ARCH-001`, `UX-004`.
- **P4:** Ongoing doc parity checks.

### D) Security

- **P0:** None.
- **P1:** None currently open.
- **P2:** `SEC-001` (evidence/validation).
- **P3:** `SEC-002`.
- **P4:** Secret scan + logging policy drift checks.

### E) Algorithm

- **P0:** None.
- **P1:** None currently open in source.
- **P2:** `ALG-001` external golden verification.
- **P3:** `ALG-002` policy wording/document sync.
- **P4:** Continued fixture expansion.

### F) Release / TestFlight / App Store

- **P0:** None.
- **P1:** None.
- **P2:** `REL-001` + all physical QA bundles.
- **P3:** `UX-004` screenshot/reference completion.
- **P4:** Post-release KPI/telemetry review (if added later).

### 7-day remediation plan

1. Day 1–2: Watch + iOS VoiceOver walkthrough and clipping matrix.
2. Day 2–3: Two-device iCloud conflict/tombstone and Watch↔iPhone sync matrix.
3. Day 3–4: External CSV/Subsurface round-trip validation.
4. Day 4–5: Planner golden comparison evidence.
5. Day 6–7: Consolidate evidence, finalize TestFlight package.

### 14-day plan

- Week 1: Complete all P2 external QA gates.
- Week 2: Address P3 process polish (`ARCH-001`, `UX-004`, optional `SEC-002`), freeze release notes, App Store submission prep.

### Pre-TestFlight checklist

- [ ] Build + tests pass on current `main`
- [ ] Watch clipping pass (41/45/49)
- [ ] iOS dynamic type pass
- [ ] VoiceOver walkthrough completed
- [ ] Paired Watch/iPhone sync pass
- [ ] Two-device iCloud merge/tombstone pass
- [ ] CSV/Subsurface round-trip pass

### Pre-App-Store checklist

- [ ] All pre-TestFlight checks done
- [ ] Reference screenshots captured and archived
- [ ] Safety/legal copy verification signed
- [ ] Privacy statement and data-flow evidence bundle complete
- [ ] Review notes updated with non-certified positioning

---

## M. Test Plan (required)

### Automated
- Keep running:
  - `DIRDiving Watch Algorithm Tests`
  - `DIRDiving iOS Algorithm Tests`
- Add/retain CI enforcement for both test schemes and build schemes.

### Simulator QA
- Watch 41/45/49 mm visual matrix.
- iOS small/large + Dynamic Type AX sizes.

### Physical QA
- Apple Watch Ultra underwater depth entitlement behavior.
- Paired Watch/iPhone sync (direct + queued).
- iCloud two-device conflicts and tombstones.

### Accessibility QA
- VoiceOver end-to-end on Watch and iOS key flows (live, planner, sync, logbook, legal).

### Localization QA
- EN/IT walkthrough of critical surfaces and warnings.
- Confirm BUSSOLA, Mission Mode, TTV, reference-only planner wording consistency.

---

## N. Final Verdict

| Question | Answer |
|---|---|
| Is the app ready to compile? | **Yes** |
| Is it ready for internal TestFlight? | **Conditionally yes** (pending physical QA evidence) |
| Is it ready for external TestFlight? | **No, not yet** |
| Is it ready for App Store? | **No, not yet** |
| What blocks 100% readiness? | Physical QA evidence (Watch clipping, VoiceOver, paired sync, two-device iCloud, external CSV/planner validation, reference screenshots) |
| What must be fixed first? | Execute **P2 external QA gates** (`W-FUNC-001`, `UX-001`, `UX-002`, `UX-003`, `I-FUNC-002`, `SYNC-001`, `REL-001`) |

---

## O. Cursor Remediation Command Draft (P0/P1/P2)

> **Draft only — do not execute from this audit report.**

```text
CURSOR / CODEX COMMAND — MAIN P2 EXTERNAL QA CLOSURE PACK

Target: main only, Watch MAIN + iOS MAIN.
Mode: QA + documentation only (no algorithm/business-logic changes unless defects discovered).

1) Run and record:
   - xcodegen generate
   - Watch/iOS builds
   - Watch/iOS algorithm tests

2) Execute physical/simulator matrix:
   - Watch 41/45/49 clipping with all live badges
   - iOS Dynamic Type AX sizes on planner and legal screens
   - VoiceOver walkthrough (Watch + iOS key flows)
   - Paired Watch↔iPhone sync (direct/queued)
   - iCloud two-device conflict+tombstone scenarios
   - CSV export/import round-trip with Subsurface
   - Optional planner golden comparison run

3) Produce/update:
   - Docs/ReferenceUI/Watch_LIVE_reference.png
   - Docs/ReferenceUI/iOS_Companion_reference.png
   - Docs/MAIN_UI_TEXT_QA_CHECKLIST.md (execution results)
   - Docs/MAIN_BRANCH_FULL_CODE_SECURITY_ALGORITHM_UX_AUDIT_CURRENT.md (status update)
   - Docs/TESTFLIGHT_REVIEW_NOTES.md (current commit evidence)

4) If defects found, open issue matrix with severity/priority and propose minimal safe fixes in a follow-up implementation command.
```

