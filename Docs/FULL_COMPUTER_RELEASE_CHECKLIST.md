# Full Computer release checklist

**Branch:** `main` (Full Computer on Watch MAIN — experimental, not certified)

| Campo | Valore |
|-------|--------|
| Data | 2026-06-17 |
| Commit `HEAD` | `50633bf` (aggiornare a ogni upload TestFlight) |
| Esecutore | Automated release-hard + Audit 04 (`validate_full_computer_release_readiness.sh`) |
| Audit gate | [`AUDIT_FULL_COMPUTER_RELEASE_GATE_CURRENT.md`](AUDIT_FULL_COMPUTER_RELEASE_GATE_CURRENT.md) — **GO WITH CONDITIONS** |

## Platform scope

- [x] **Watch MAIN** — live FC runtime, deco UI, stop machine (`DiveLiveView` + `FullComputerLivePanels`)
- [x] **iOS Companion** — planner + plan import + logbook only (**no** in-water FC NDL/TTS/ceiling UI)
- [x] Stop timer QA uses **model-synchronized** remaining time (`timerAccruing` / projection), not wall-clock stopwatch — documented Audit 02

## Pre-build

- [x] `git branch --show-current` → `main`
- [x] `xcodegen generate` (no drift in `DIRDiving.xcodeproj`) — verified by release-hard script
- [x] `./Scripts/check_secrets.sh` PASS

## Automated release-hard gate

- [x] `./Scripts/validate_full_computer_release_readiness.sh` PASS @ Audit 04
- [x] Review [`DIR_DIVING_FULL_COMPUTER_RELEASE_HARD_VALIDATION_REPORT.md`](DIR_DIVING_FULL_COMPUTER_RELEASE_HARD_VALIDATION_REPORT.md)

## Safety (code review)

- [x] [`SAFETY_DISCLAIMER.md`](SAFETY_DISCLAIMER.md) unchanged intent — FC is **not** a certified dive computer
- [x] Invalid predive profile cannot start FC runtime — `FullComputerGasProfileTests`, predive readiness tests
- [x] No `sessionDivingMode = .gauge` assignment during active FC session — `DiveManagerAlgorithmIntegrationTests`
- [x] Corrupt checkpoint quarantine path reviewed — `FullComputerRecoveryCheckpointTests`

## Visual / mockup

- [x] All 25 `FC_UI_*` mockups mapped in [`FullComputerMockupReferenceMatrix.swift`](../Utils/FullComputerMockupReferenceMatrix.swift)
- [x] No `FC_UI_*.png` embedded in app bundle — `FullComputerMockupReferenceMatrixTests`
- [x] EN/IT localization parity for FC keys — `audit_localization.sh` PASS
- [x] **Automated visual regression substitute** — `FullComputerUIStateMatrixTests` (20 states) + mockup matrix fixture mapping
- [ ] **Optional PNG evidence pack** for App Store visual gate — [`ReferenceUI/README.md`](ReferenceUI/README.md) (manual capture; not blocking internal TestFlight experimental)

## Physical QA (BLOCKING for production)

- [ ] [`WATCH_ULTRA_PHYSICAL_QA_MATRIX.md`](WATCH_ULTRA_PHYSICAL_QA_MATRIX.md)
- [ ] [`WATCH_IOS_SYNC_QA_MATRIX.md`](WATCH_IOS_SYNC_QA_MATRIX.md)
- [ ] Pool / controlled-depth validation **not signed off**
- [ ] Water Lock + glove usability — manual only

## Rollback

1. Stop distributing FC TestFlight build.
2. Reset Watch default diving mode to **Gauge** via settings.
3. Merge revert or stay on `main` (`origin/main`) for production users.
4. Active FC drafts: allow recovery banner path or discard draft after user confirmation.

## Entitlement / deployment

- [ ] Watch app entitlement unchanged unless FC-specific capability added — verify at upload time
- [ ] TestFlight review notes updated if FC build is uploaded
- [ ] App Store listing must **not** claim certification

**External release:** **BLOCKED** until physical QA evidence packs are signed.  
**Internal experimental TestFlight:** allowed per Audit 04 **GO WITH CONDITIONS**.
