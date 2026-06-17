# DIR Diving Watch Complete Algorithm / Safety / Runtime Audit — CCR Updated V2.0

**Audit date:** 2026-06-14  
**Repository:** `https://github.com/egopfe/DirDiving-App.git`  
**Audited branch:** `main`  
**Audited HEAD:** `c0b5cd9` (`Complete iOS Bühlmann/CCR comprehensive readiness remediation to internal 100%`)  
**Scope:** Apple Watch MAIN target (`DIRDiving Watch App`) only  
**Execution mode:** Read-only static analysis + macOS `xcodegen` / `xcodebuild` validation  
**Source command:** `commands_for_cursor/2-DIR_DIVING_WATCH_COMPLETE_ALGORITHM_AUDIT_CCR_UPDATED_V2.0.md`  
**Command version:** 2.0  
**Prior audit superseded:** this document replaces the 2026-06-08 report @ `d756a89`

**Integrated context (read, not re-executed):**

| Document | Role |
|---|---|
| `Docs/1-DIR_DIVING_IOS_BUHLMANN_COMPREHENSIVE_READINESS_AUDIT_CCR_CURRENT.md` | iOS Bühlmann/CCR audit @ `fedf4eb` + remediation @ `8147b3f`/`c0b5cd9` |
| `Docs/1-DIR_DIVING_IOS_BUHLMANN_COMPREHENSIVE_READINESS_REMEDIATION_REPORT_V1.0.md` | iOS internal 100% code readiness evidence |
| `Docs/WATCH_MAIN_ALGORITHM_MATH_AUDIT_CURRENT.md` | Prior Watch math audit |
| `Docs/WATCH_ULTRA_PHYSICAL_QA_MATRIX.md` | Physical gate (pending) |
| `Docs/WATCH_IOS_SYNC_QA_MATRIX.md` | Paired sync gate (pending) |
| `Docs/WATCH_CSV_EXPORT_POLICY.md` | Watch vs iOS CSV policy |
| `Docs/DIR_DIVING_IOS_WATCH_PLANNER_BRIEFING_CARDS.md` | Briefing-card feature spec |

**Actions in this audit pass:**

- Created/updated this report only (read-only audit).
- No Swift, UI, algorithm, sync, security, or test production code modified.
- No commit or push performed by this audit command.

### Post-audit remediation status (2026-06-14)

| Item | Audit baseline (`c0b5cd9`) | Code after remediation |
|---|---|---|
| WATCH-BRIEF-001 CCR briefing export | Open | **Fixed** — `CCRPlannerBriefingExportSupport` + `CCRPlanResultView` |
| WATCH-BRIEF-002 planner session ID | Open | **Fixed** — `PlannerStore.plannerBriefingSessionId` |
| WATCH-BRIEF-003 incomplete package UX | Open | **Fixed** — Watch incomplete warning |
| WATCH-BRIEF-004 orphan staging | Open | **Fixed** — 24h staging cleanup |
| WATCH-PHY-001 / WATCH-PHY-002 | Open | **PENDING** — physical QA |

See [`2-DIR_DIVING_WATCH_COMPLETE_ALGORITHM_AUDIT_CCR_REMEDIATION_REPORT_V1.0.md`](2-DIR_DIVING_WATCH_COMPLETE_ALGORITHM_AUDIT_CCR_REMEDIATION_REPORT_V1.0.md).

---

## Indice

| Sezione | Contenuto |
|---|---|
| [A. Executive Summary](#a-executive-summary) | Verdetto, readiness, blocker TestFlight/App Store |
| [B. Scope Confirmation](#b-scope-confirmation) | Preflight, build/test, exclusions |
| [C. Architecture Analysis](#c-architecture-analysis) | Target membership, shared models, drift |
| [D. Core Runtime Analysis](#d-apple-watch-core-runtime-analysis) | Depth, lifecycle, TTV, ascent, GPS |
| [E–O. Area Verdicts](#e-dive-start-verdict) | Dive start, reminders, images, briefing, Mission Mode, CCR |
| [P. Test Coverage](#p-test-coverage-analysis) | XCTest inventory, gaps |
| [Q. Issue Matrix](#q-issue-matrix) | ID, severity, fix, effort |
| [R. Action Plan](#r-detailed-action-plan) | P0–P4 |
| [S–W. QA Plans](#s-physical-watch-ultra-qa-plan) | Physical, paired sync, CCR compatibility |
| [X. Final Verdict](#x-final-verdict) | Release gates |

---

## A. Executive Summary

### Overall verdict

Status: **Almost ready (non-certified companion)**

MAIN @ `c0b5cd9` delivers a mature Watch dive lifecycle (auto/manual start, depth validation, ascent/depth safety, TTV informational index, reminders, images, compass/GPS, signed-ACK dive sync, App Intent legal gates, OC planner briefing-card reception). **Watch has zero Bühlmann / Ratio Deco / CCR live runtime** — iOS planner advances (including CCR P1 density/CNS/OTU remediation @ `8147b3f`) do not turn Watch into a decompression or CCR controller.

macOS validation on this machine:

- **Watch build:** SUCCEEDED  
- **Watch Algorithm Tests:** **215 executed, 16 skipped, 0 failed** (Apple Watch Ultra 3 49mm simulator)

Remaining gates are **physical Ultra QA**, **paired iPhone sync evidence**, **CCR briefing-card product gap**, and **documented Watch/iOS CSV export divergence**.

### Readiness estimates

| Dimension | Readiness | Confidence | Primary blockers |
|---:|---:|---|---|
| **Overall Watch MAIN** | **93%** | High on code/tests | Physical Ultra QA; CCR briefing gap |
| **Mathematical / runtime robustness** | **95%** | High | Ultra entitlement field validation |
| **Safety algorithm confidence** | **94%** | High | Physical depth/ascent/haptic QA |
| **Lifecycle confidence** | **95%** | High | Underwater start/stop evidence |
| **Sync / data confidence** | **86%** | Medium-high | Paired-device QA pending |
| **Security readiness** | **86%** | Medium-high | Unsigned tombstone/photo ACK paths |
| **Performance / battery** | **91%** | Medium | Long-dive profiling open |
| **CCR / iOS planner compatibility** | **97%** | High | No CCR on Watch — isolation verified; briefing export OC-only |
| **Planner briefing cards** | **76%** | Medium-high | No CCR export; staleness/version weak |
| **Test coverage** | **91%** | High | 215 XCTest; hardware gaps |
| **Physical QA evidence** | **45%** | — | Matrices exist, slots empty |

### Release posture

| Gate | Verdict |
|---|---|
| Compile / internal use | **PASS** |
| Internal TestFlight (Watch algorithm) | **Conditional yes** — tests green; mock-fallback UX disclosed |
| External TestFlight | **Not yet** — Ultra physical + paired sync QA + CCR briefing policy |
| App Store (Watch scope) | **Not yet** — same + legal/marketing review |
| Certified dive computer claim | **Never** — TTV informational; no Bühlmann/CCR on Watch |

### Severity summary

| Severity | Count | Notes |
|---:|---:|---|
| CRITICAL | 0 | No live decompression authority on Watch |
| HIGH | 1 | No CCR planner briefing export path to Watch |
| MEDIUM | 8 | Physical QA pending; briefing staleness; sync unsigned aux channels |
| LOW | 6 | GPS restart, draft edge cases, orphan staging, dead notification hook |
| INFO | 3 | TTV naming, sample timestamp source, Mission Mode Low Power wording |

### Most urgent issues

1. **WATCH-BRIEF-001** — CCR plans cannot send briefing cards to Watch (OC-only export).
2. **WATCH-PHY-001 / WATCH-PHY-002** — Physical Ultra and paired sync matrices still empty.
3. **WATCH-BRIEF-002** — `plannerSessionId` unused; stale cards indistinguishable except by timestamp.

---

## B. Scope Confirmation

| Check | Result |
|---|---|
| Branch | `main` |
| HEAD | `c0b5cd9` |
| Working tree at audit start | Clean |
| Remote | `origin/main` aligned @ `c0b5cd9` |
| Watch target | `DIRDiving Watch App` |
| Test target | `DIRDiving Watch Algorithm Tests` |
| iOS scope | Referenced for sync/briefing codec parity — not re-audited in depth |

### Experimental exclusions (`project.yml`)

Confirmed excluded from Watch MAIN:

| Category | Excluded paths |
|---|---|
| Views | `ApneaView.swift`, `SnorkelingView.swift`, `BuddyAssistView.swift`, `ExperimentalConceptsView.swift` |
| Utils | `ExperimentalFeatures.swift` |
| Models | `ExplorationModels.swift`, `BuddyAssistMessage.swift`, `BuddyPairingHandshake.swift` |
| Services | `ExplorationStore.swift`, `BuddyAssistService.swift`, `BuddyAssistPeripheralService.swift`, `BuddyPairingKeyAgreement.swift`, `SecureBuddyStore.swift` |

No experimental references found in compiled Watch MAIN runtime paths.

### Build / test commands and results

```bash
xcodegen generate
# OK

xcodebuild -project DIRDiving.xcodeproj -scheme "DIRDiving Watch App" \
  -destination 'generic/platform=watchOS Simulator' \
  CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO build
# ** BUILD SUCCEEDED **

xcodebuild -project DIRDiving.xcodeproj -scheme "DIRDiving Watch Algorithm Tests" \
  -destination 'platform=watchOS Simulator,name=Apple Watch Ultra 3 (49mm)' test
# ** TEST SUCCEEDED ** — 215 executed, 16 skipped, 0 failures
```

**Simulator substitution:** Command template references Apple Watch Series 11 (46mm); this environment used **Apple Watch Ultra 3 (49mm)** — closest available Ultra-class simulator.

### Static scan highlights

| Scan | Result |
|---|---|
| `CCR|Buhlmann|RatioDeco|setpoint|diluent` in `Services/DiveManager.swift` | **No matches** |
| Briefing card reads in dive algorithms | **None** — isolation confirmed |
| `cnsFull = 0` failure paths on Watch | N/A — no CCR exposure on Watch |

---

## C. Architecture Analysis

### Target membership

| Layer | Location | Notes |
|---|---|---|
| Watch app entry | `App/DIRDivingApp.swift` | Wires `DiveManager`, `WatchSyncService`, `PlannerBriefingCardStore` |
| Runtime core | `Services/DiveManager.swift`, depth providers, haptics | Single orchestrator |
| Sync | `Services/WatchSyncService.swift`, `WatchDiveSyncCodec.swift`, `WatchSyncAuth.swift` | HMAC v2 dive payloads |
| Briefing cards | `Services/PlannerBriefingCardStore.swift`, `PlannerBriefingWatchReceiver.swift` | Reference-only PNG store |
| Shared models | `Models/PlannerBriefingCard.swift`, `Models/DiveSession.swift` | Compiled on both targets |
| iOS-only planner | `iOSApp/**` | Bühlmann, CCR, PDF — **not** in Watch target |

### Shared vs duplicated

- **Shared:** dive session models, briefing card manifest/codec, unit formatters where linked, sync auth constants.
- **Watch-only:** lifecycle, depth safety, TTV, reminders, images, live UI.
- **iOS-only:** Bühlmann engine, CCR planner, gas ledger, Rock Bottom, checklist generation.

### Documentation drift

| Doc | Drift |
|---|---|
| iOS comprehensive audit | Correctly states Watch briefing @ ~80%; CCR cards not exported |
| Feature comparison CSV | May imply cross-mode briefing parity — Watch UI is OC-export only today |
| Prior `WATCH_COMPLETE_ALGORITHM_AUDIT_CURRENT.md` @ `d756a89` | Superseded by this report @ `c0b5cd9` |

### Build risks

- `project.yml` explicit file list prevents stale-xcodeproj omissions — **low risk** after `xcodegen`.
- Watch embeds in iOS app bundle — Watch build validated independently.

**Architecture readiness: 94%**

---

## D. Apple Watch Core Runtime Analysis

### Depth lifecycle

`DiveManager` → `DepthSampleValidationState` → `DiveLifecycleAlgorithm` → sample ingest → `DiveAlgorithm` (TTV, ascent, depth safety).

| Parameter | Value |
|---|---|
| Auto-start depth | `> 1.0 m`, 2 consecutive valid samples |
| Auto-stop | `≤ 0.3 m` for 8 s dwell |
| Depth safety bands | 35 m caution / 38 m critical / 40 m exceeded |
| TTV | `avgDepth + runtimeMinutes` (informational only) |
| Ascent rate | 5 s window; depth-band limits; conservative above 40 m |

### Manual / automatic start

- Manual: `startManualDive()` — truthful no-depth sessions when automation unavailable.
- Handoff: manual → automatic when depth `> 1.0 m` or Apple submersion `.submerged`.
- Collision: auto-start blocked while manual dive active.
- Draft restore: `.active` / `.finalizing` paths tested.

### GPS, haptics, timers

- GPS: 6 s best-effort at dive start/end; auth lifecycle documented (battery P3).
- Haptics: depth-limit and ascent coordinators; global toggle respected.
- Depth silence watchdog: 8 s without callback → stale state.

### Canonical classification (planner sync)

| Data on Watch | Classification |
|---|---|
| Live depth / runtime / ascent / TTV | **1 — canonical live Watch measurement** |
| Dive log samples | **1 — canonical Watch** |
| Planner briefing PNG + manifest | **4 — rendered briefing image + 3/6 synced metadata** |
| iOS dive session import | **3 — synced structured metadata** (HMAC v2) |
| CCR setpoint/diluent/bailout on Watch live UI | **7 — unsupported/ignored** (not displayed live) |

**Core runtime readiness: 95%**

---

## E. Dive Start Verdict

| Question | Answer |
|---|---|
| Manual start reachable? | **Yes** — Live screen + App Intents (after legal gate) |
| Automatic start works? | **Yes** in code/tests; physical Ultra pending |
| Duplicate prevention works? | **Yes** — blocked when `isDiveActive` |
| Manual + automatic collision safe? | **Yes** — handoff + submersion observation gates |
| Restore after relaunch safe? | **Yes** — draft JSON + finalizing completion |

**Dive Start readiness: 95%**

---

## F. Reminder Verdict

| Question | Answer |
|---|---|
| Multiple reminders implemented? | **Yes** — engine supports configured set |
| Recurring reminders reliable? | **Yes** in unit/integration tests |
| Haptics/overlays safe? | **Yes** — priority policy defers reminders under critical alarms |
| Safety alerts take priority? | **Yes** — depth/ascent banners supersede reminder overlay |

**Reminder readiness: 92%**

---

## G. Image Subsystem Verdict

| Question | Answer |
|---|---|
| Image transfer works? | **Yes** — `WCSession.transferFile` + validator |
| Inventory sync truthful? | **Yes** — Watch filesystem source of truth; signed inventory HMAC |
| Deletion from Watch safe? | **Yes** — prefix check; bundled assets protected |
| Deletion from iOS requires Watch ACK? | **Yes** — signed delete ACK before iOS marks deleted |
| Bundled images protected? | **Yes** — `UserImageStorePolicyTests` |
| No effect on dive metrics? | **Confirmed** — no coupling to `DiveManager` |

**Image subsystem readiness: 93%**

---

## H. Planner Briefing Card Verdict

| Question | Answer |
|---|---|
| Card transfer works? | **Yes** for OC planner — file + manifest + signed ACK to iOS |
| Numerical values match iOS canonical plan? | **Yes at export time** — PNG rendered from same presentation rows |
| PNG and metadata agree? | **Yes** — SHA256 validated on import |
| Stale cards handled safely? | **Partial** — latest package replaces all; weak session binding |
| Clearly reference-only? | **Yes** — PNG footers + Watch UI caption |
| Cannot affect live Watch calculations? | **Confirmed** — zero algorithm coupling |
| Unsupported CCR fields fail safely? | **N/A export** — CCR cannot export cards today |

### Briefing card architecture

```
iOS PlanResultView (OC only) → PlannerBriefingImageExportService → transferFile
  → WatchSyncService → PlannerBriefingWatchReceiver → PlannerBriefingCardStore
  → PlannerBriefingCardsView (Settings, disabled during active dive)
```

### Gaps

| ID | Issue |
|---|---|
| WATCH-BRIEF-001 | **HIGH** — `CCRPlanResultView` has no send-to-Watch action |
| WATCH-BRIEF-002 | **MED** — `plannerSessionId` always `nil` on send |
| WATCH-BRIEF-003 | **MED** — `reload()` silently drops missing PNGs |
| WATCH-BRIEF-004 | **MED** — orphan staging if manifest never arrives |
| WATCH-BRIEF-005 | **LOW** — `gasEmergency` card kind defined but never exported |

**Briefing card readiness: 76%**  
**Numerical fidelity (OC path): 90%**  
**Transfer/persistence: 85%**  
**Reference-only safety: 98%**

---

## I. Small-Screen Safety Visibility Verdict

| Question | Answer |
|---|---|
| Depth hero remains visible? | **Yes** — `LiveDiveBannerPresentationPolicy` tested |
| Critical banners remain visible? | **Yes** — depth/ascent take priority |
| Non-critical banners collapse? | **Yes** — sync/GPS/photo states defer |
| VoiceOver order logical? | **Yes** — static sweep + live a11y tests |

**Small-screen safety visibility readiness: 91%**

---

## J. Reminder Dismiss / Suppression Verdict

| Question | Answer |
|---|---|
| Manual dismiss works? | **Yes** — tap on `DiveReminderOverlayView` |
| Auto-dismiss remains? | **Yes** — engine timer (3 s) |
| Critical alarms cannot be dismissed via reminder overlay? | **Yes** — separate presentation paths |
| Suppression deterministic? | **Yes** — tested in reminder integration suite |

**Reminder dismiss readiness: 90%**

---

## K. Mission Mode Verdict

| Question | Answer |
|---|---|
| Affects depth sampling? | **No** |
| Affects depth display values? | **No** — UI animation profile only |
| Affects reminders? | **No** |
| Affects haptics? | **No** |
| Affects GPS? | **No** |
| Affects alarms? | **No** |
| Affects sync/export? | **No** |
| Apple Low Power Mode wording truthful? | **Yes** — does not claim system Low Power Mode control |

**Mission Mode readiness: 96%**

---

## L. Sensor Source Verdict

| Question | Answer |
|---|---|
| Developer unlock protected? | **Yes** |
| Automatic default safe? | **Yes** — Apple when entitled, else mock with banner |
| Simulation clearly identified? | **Yes** — resolution label + warning |
| Release path safe? | **Yes** — simulation forced off in App Store builds |

**Sensor Source readiness: 94%**

---

## M. Branding Verdict

| Question | Answer |
|---|---|
| Icon updated? | **Yes** — asset catalog present |
| Octopus visible? | **Yes** — top-left branding |
| Consistent underwater? | **Code yes** — physical visual QA pending |
| No safety overlay conflicts? | **Yes** — policy tests |

**Branding readiness: 90%**

---

## N. Unit / Date Localization Verdict

| Question | Answer |
|---|---|
| Metric/imperial consistent? | **Yes** — shared formatters + unit preference sync |
| Export policy clear? | **Yes** — `WATCH_CSV_EXPORT_POLICY.md` |
| Units correct in alarms/reminders/logbook? | **Yes** — tested |
| Locale-adaptive logbook dates? | **Yes** — `DiveLogListView` uses `@Environment(\.locale)` |

**Unit consistency readiness: 93%**

---

## O. CCR / Rebreather Compatibility Verdict

| Question | Answer |
|---|---|
| Watch implements CCR/Rebreather logic? | **No** |
| Avoids implying live CCR control? | **Yes** |
| Displays CCR metadata on live dive screen? | **No** |
| CCR fields affect Watch calculations? | **No** — grep clean on `DiveManager` |
| Unsupported CCR payloads safe? | **Yes** — no live parser; briefing path OC-only |
| Bailout/diluent/setpoint on Watch? | **Only if future OC-style briefing export added** — not today for CCR |

### iOS CCR remediation context (@ `8147b3f` / `c0b5cd9`)

iOS now pressure-scales CCR gas density and uses unavailable (not zero) CCR CNS/OTU states. **These fixes do not change Watch runtime** — they improve iOS reference data that could theoretically appear on future CCR briefing cards.

**CCR Watch compatibility readiness: 97%** (isolation excellent; product gap on CCR briefing export)

---

## P. App Intents / Action Button Verdict

| Question | Answer |
|---|---|
| Legal gate enforced? | **Yes** — `LegalAcceptanceGateTests`, `ActionButtonIntentsSafetyTests` |
| Unsafe shortcuts blocked? | **Yes** — pre-acceptance failure |
| Localized IT/EN? | **Yes** |
| Cannot execute briefing as live plan? | **Yes** — no such intent |

**App Intents readiness: 95%**

---

## Q. Sync / Security / Payload Validation

### Trust model summary

- TOFU peer secret via `applicationContext`
- Dive payloads: HMAC v2 + nonce replay cache (persisted)
- Dive import ACK: signed; legacy ACK rejected
- Photo inventory/delete: signed request/response/ACK
- Photo file transfer + import ACK: **unsigned** (WC pairing trust)
- Tombstones: **unsigned** cumulative delete IDs in context

**Sync/security readiness: 86%**

---

## R. Performance / Battery / Memory

- SwiftUI live view uses bounded banner policy — no unbounded stack growth observed in code review.
- 1 Hz mock / Apple callback-driven sampling — appropriate for Watch.
- GPS best-effort windows limited to dive boundaries.
- Long-dive battery profiling: **not executed** (P4).

**Performance readiness: 91%**

---

## P. Test Coverage Analysis

### Inventory

| Area | Representative tests | Status |
|---|---|---|
| Dive lifecycle | `DiveManagerAlgorithmIntegrationTests`, `DiveAlgorithmTests` | Strong |
| Draft restore | `WatchMainAlgorithmAuditRemediationTests` | Strong |
| Sync HMAC/ACK | `WatchSyncServiceIntegrationTests`, `WatchAckVerifierSecurityTests` | Strong |
| Peer pinning | `WatchSyncPeerSecretPinningTests` | Strong |
| Mission Mode | `MissionModeAlgorithmInvariantTests` | Strong |
| Reminders | `DiveReminderEngineTests`, `DiveReminderIntegrationTests` | Strong |
| Images | `UserImageStorePolicyTests`, `WatchPhotoTransferPipelineTests` | Strong |
| Briefing cards | `PlannerBriefingCardStoreTests`, `PlannerBriefingReceiverTests` (+ iOS transfer tests) | Moderate — 13 focused tests |
| App Intents | `ActionButtonIntentsSafetyTests` | Strong |
| Localization/a11y | `WatchMainUILocalizationTests`, `WatchLocalizationStaticSweepTests` | Strong |

### Execution summary (@ `c0b5cd9`)

| Metric | Value |
|---|---|
| Executed | 215 |
| Passed | 215 |
| Failed | 0 |
| Skipped | 16 (pairing/hardware-dependent) |

### Missing / weak

| Gap | Priority |
|---|---|
| Apple Watch Ultra underwater entitlement | P1 physical |
| Paired iPhone ACK path E2E | P1 physical |
| CCR briefing export (feature absent) | P2 product |
| Briefing hash mismatch E2E on device | P2 |
| Reminder + alarm overlay on wrist | P2 physical |
| Long-dive battery profile | P4 |

**Test coverage readiness: 91%**

---

## Q. Issue Matrix

| ID | Sev | Pri | Area | Location | Title | Safety | Proposed fix | Effort |
|---|---|---|---|---|---|---|---|---|
| WATCH-BRIEF-001 | HIGH | P2 | Briefing | `CCRPlanResultView` / iOS export | No CCR briefing export to Watch | User confusion; CCR diver lacks wrist reference | Add CCR PNG export with unavailable-state labels + ref-only footers | L |
| WATCH-PHY-001 | MED | P1 | Physical QA | Ultra hardware | Underwater depth + haptics not recorded | External TestFlight blocked | Execute `WATCH_ULTRA_PHYSICAL_QA_MATRIX.md` | Manual |
| WATCH-PHY-002 | MED | P1 | Physical QA | Paired devices | Watch↔iPhone sync not recorded | External TestFlight blocked | Execute `WATCH_IOS_SYNC_QA_MATRIX.md` | Manual |
| WATCH-BRIEF-002 | MED | P2 | Briefing | `PlannerBriefingWatchTransferService` | `plannerSessionId` always nil | Stale plan ambiguity | Pass planner session/generation ID | S |
| WATCH-BRIEF-003 | MED | P2 | Briefing | `PlannerBriefingCardStore.reload()` | Silent partial card display | Incomplete package looks valid | Surface incomplete-package warning | S |
| WATCH-BRIEF-004 | MED | P3 | Briefing | Staging dirs | Orphan staging on failed manifest | Disk clutter; confusing retry | TTL cleanup for staging | S |
| WATCH-SYNC-001 | MED | P2 | Sync | Tombstones | Unsigned delete IDs in context | Trust-model limitation | Document or HMAC-wrap tombstones | M |
| WATCH-SYNC-002 | MED | P2 | Sync | Photo ACK | Unsigned `companionPhotoAck` | Paired-channel spoof risk | Sign photo import ACK | M |
| WATCH-EXP-001 | MED | P2 | CSV export | `SubsurfaceExportService.swift` | Watch vs iOS CSV metadata divergence | Import parity confusion | Document only or future alignment | M |
| WATCH-SENSOR-001 | MED | P2 | Sensor | Mock fallback | Automation flag true on mock fallback | User expects auto-start | UX review on non-entitled hardware | S |
| WATCH-GPS-001 | LOW | P3 | GPS | `GPSManager.swift` | Auth restart outside dive | Battery | Policy doc | XS |
| WATCH-LC-001 | LOW | P3 | Persistence | Draft decode | Legacy schema edge | Rare corrupt draft | Harden decode | S |
| WATCH-BRIEF-005 | LOW | P4 | Briefing | Model | `gasEmergency` kind unused | Dead API surface | Export or remove kind | S |
| WATCH-S2-003 | INFO | P4 | Samples | Timestamp | Receipt-time semantics | Debug clarity | Doc only | XS |

**No P0 issues.**

---

## R. Detailed Action Plan

### P0 — Critical

**None.**

### P1 — Before external TestFlight

| Action | IDs | Acceptance |
|---|---|---|
| Execute Ultra physical QA matrix | WATCH-PHY-001 | Evidence in `Docs/QA_EVIDENCE/WATCH_ULTRA/` |
| Execute paired Watch/iPhone sync matrix | WATCH-PHY-002 | Evidence in `Docs/QA_EVIDENCE/WATCH_IOS_SYNC/` |
| Confirm mock-fallback banner on non-entitled device | WATCH-SENSOR-001 | Screenshot in evidence pack |

### P2 — Product / internal TestFlight hardening

| Action | IDs | Files likely involved |
|---|---|---|
| Add CCR briefing export (reference-only PNGs) | WATCH-BRIEF-001 | `CCRPlanResultView`, `PlannerBriefingImageExportService`, CCR presentation rows |
| Pass planner session ID in manifest | WATCH-BRIEF-002 | iOS transfer service, shared manifest model |
| Incomplete-package UX on Watch | WATCH-BRIEF-003 | `PlannerBriefingCardStore`, `PlannerBriefingCardsView` |
| Keep CSV policy linked in release checklist | WATCH-EXP-001 | Docs only |
| Reminder overlay physical cases | Reminders | QA matrix |

### P3 — Polish

| Action | IDs |
|---|---|
| Staging dir TTL cleanup | WATCH-BRIEF-004 |
| GPS auth restart policy | WATCH-GPS-001 |
| Legacy draft migration note | WATCH-LC-001 |

### P4 — Future

| Action | IDs |
|---|---|
| Sign tombstones / photo import ACK | WATCH-SYNC-001, WATCH-SYNC-002 |
| `gasEmergency` card export or removal | WATCH-BRIEF-005 |
| Long-dive battery profiling | Performance |
| Watch/iOS CSV metadata alignment | WATCH-EXP-001 |

---

## S. Physical Watch Ultra QA Plan

Execute `Docs/WATCH_ULTRA_PHYSICAL_QA_MATRIX.md` and attach evidence to `Docs/QA_EVIDENCE/WATCH_ULTRA/`:

- [ ] Real depth sensor auto-start `> 1 m` and auto-stop `≤ 0.3 m` + 8 s dwell
- [ ] Manual start on surface → handoff when submerged
- [ ] Ascent warnings + haptics at band limits
- [ ] 35 / 38 / 40 m depth safety states + haptics
- [ ] GPS capture at start/end
- [ ] Reminders during dive + tap-to-dismiss
- [ ] Mission Mode UI-only verification (metrics unchanged)
- [ ] Mock-fallback banner on non-entitled hardware
- [ ] App Intent / Action Button after legal acceptance
- [ ] Smallest Watch display banner density
- [ ] VoiceOver traversal on Live screen under alarm stack
- [ ] Locale-adaptive logbook dates (EN/IT)

**Status: PENDING**

---

## T. Paired Watch / iPhone QA Plan

Execute `Docs/WATCH_IOS_SYNC_QA_MATRIX.md` and attach evidence to `Docs/QA_EVIDENCE/WATCH_IOS_SYNC/`:

- [ ] Dive session Watch → iOS with signed ACK dequeue
- [ ] Offline queue flush when companion returns
- [ ] Tombstone idempotency both directions
- [ ] Photo transfer + inventory signed round-trip
- [ ] Photo delete request → Watch ACK → iOS state
- [ ] Trust reset / changed peer handling
- [ ] OC planner briefing card transfer + ACK + replace + delete
- [ ] Malformed briefing rejection (hash mismatch, oversize)
- [ ] Briefing navigation disabled during active dive

**Status: PENDING**

---

## U. CCR / Rebreather Compatibility QA Plan

| Scenario | Expected | Status |
|---|---|---|
| iOS CCR plan → Watch briefing | Reference-only PNGs with CCR labels, unavailable density/exposure not shown as zero | **Not implemented** — WATCH-BRIEF-001 |
| Unsupported CCR live payload on Watch | Ignored; no live UI | **Pass** (code review) |
| Watch live dive during CCR briefing stored | Briefing does not alter depth/runtime/ascent/TTV | **Pass** (code review) |
| Bailout heuristic on future CCR card | Must say "heuristic reference estimate" | Pending feature |
| User cannot start dive from briefing card | No intent/path | **Pass** |
| Export/log CCR fields on Watch | Watch CSV policy — no fabricated CCR deco | **Pass** (documented divergence) |

**Status: PENDING** for CCR briefing scenarios; **PASS** for live-runtime isolation.

---

## V. Readiness Matrix (Internal vs External)

| Feature | Code | Automated Tests | Documentation | External/Physical |
|---|---:|---:|---:|---|
| Dive lifecycle / depth / ascent | 95% | 95% | 95% | PENDING |
| Dive start (auto/manual) | 95% | 95% | 95% | PENDING |
| Reminders | 92% | 92% | 90% | PENDING |
| User images | 93% | 93% | 90% | PENDING |
| Mission Mode | 96% | 96% | 95% | PENDING |
| Sensor source | 94% | 94% | 95% | PENDING |
| Branding | 90% | 85% | 90% | PENDING |
| Units / localization | 93% | 90% | 93% | PENDING |
| App Intents | 95% | 95% | 95% | PENDING |
| Sync / security | 86% | 88% | 90% | PENDING |
| Planner briefing cards | 76% | 65% | 85% | PENDING |
| CCR compatibility (isolation) | 97% | 95% | 95% | PENDING |
| CSV export | 88% | 85% | 90% | PENDING |
| **Overall Watch MAIN** | **93%** | **91%** | **92%** | **PENDING** |

Internal percentages reflect code + XCTest evidence on `c0b5cd9`. External column remains **PENDING** until physical/paired evidence is attached.

---

## W. Recommended Cursor Remediation Commands (next)

1. Implement CCR briefing-card export (reference-only) — product follow-up to iOS `@ c0b5cd9` CCR remediation.
2. Execute physical QA matrices — no code; evidence only.
3. Briefing staleness/session ID hardening — small iOS+Watch patch set.

---

## X. Final Verdict

| Question | Answer |
|---|---|
| Is Watch algorithm/runtime ready? | **Yes for internal/code use @ 93%** |
| Safe for internal TestFlight? | **Conditional yes** — disclose mock fallback |
| Safe for external TestFlight? | **Not yet** — physical + paired QA + CCR briefing policy |
| App Store ready? | **Not yet** |
| Blocks 100% Watch readiness? | Physical QA; CCR briefing export; briefing staleness UX |
| Blocks 100% security readiness? | Unsigned tombstones/photo ACK; paired QA |
| Blocks 100% performance readiness? | Long-dive field profiling |
| Briefing cards numerically faithful? | **Yes for OC export path** at generation time |
| Briefing cards safely reference-only? | **Yes** |
| Stale/malformed cards affect live state? | **No** — isolation confirmed |
| Small-screen critical visibility preserved? | **Yes in code/tests** — physical confirm pending |
| Reminder dismiss/suppression safe? | **Yes in code/tests** |
| Date localization and accessibility complete? | **Largely yes** — physical VoiceOver confirm pending |
| Fix first? | **WATCH-PHY-001**, **WATCH-PHY-002**, then **WATCH-BRIEF-001** |

---

*End of audit report. No production source modified.*
