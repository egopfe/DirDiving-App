# Full Computer release checklist

**Branch:** `integration/full-computer` only — do **not** merge to `main` without explicit review.

| Campo | Valore |
|-------|--------|
| Data | __________ |
| Commit `HEAD` | __________ |
| Esecutore | __________ |

## Pre-build

- [ ] `git branch --show-current` → `integration/full-computer`
- [ ] `xcodegen generate` (no drift in `DIRDiving.xcodeproj`)
- [ ] `./Scripts/check_secrets.sh` PASS

## Automated release-hard gate

- [ ] `./Scripts/validate_full_computer_release_readiness.sh` PASS
- [ ] Review [`DIR_DIVING_FULL_COMPUTER_RELEASE_HARD_VALIDATION_REPORT.md`](DIR_DIVING_FULL_COMPUTER_RELEASE_HARD_VALIDATION_REPORT.md)

## Safety (code review)

- [ ] [`SAFETY_DISCLAIMER.md`](SAFETY_DISCLAIMER.md) unchanged intent — FC is **not** a certified dive computer
- [ ] Invalid predive profile cannot start FC runtime
- [ ] No `sessionDivingMode = .gauge` assignment during active FC session
- [ ] Corrupt checkpoint quarantine path reviewed

## Visual / mockup

- [ ] All 25 `FC_UI_*` mockups mapped in [`FullComputerMockupReferenceMatrix.swift`](../Utils/FullComputerMockupReferenceMatrix.swift)
- [ ] No `FC_UI_*.png` embedded in app bundle
- [ ] EN/IT localization parity for new FC keys
- [ ] Screenshot evidence **PENDING** — [`ReferenceUI/README.md`](ReferenceUI/README.md)

## Physical QA (BLOCKING for production)

- [ ] [`WATCH_ULTRA_PHYSICAL_QA_MATRIX.md`](WATCH_ULTRA_PHYSICAL_QA_MATRIX.md)
- [ ] [`WATCH_IOS_SYNC_QA_MATRIX.md`](WATCH_IOS_SYNC_QA_MATRIX.md)
- [ ] Pool / controlled-depth validation **not signed off**

## Rollback

1. Stop distributing FC TestFlight build.
2. Reset Watch default diving mode to **Gauge** via settings.
3. Merge revert or stay on `main` (`origin/main`) for production users.
4. Active FC drafts: allow recovery banner path or discard draft after user confirmation.

## Entitlement / deployment

- [ ] Watch app entitlement unchanged unless FC-specific capability added
- [ ] TestFlight review notes updated if FC build is uploaded
- [ ] App Store listing must **not** claim certification

**External release:** **BLOCKED** until physical QA evidence packs are signed.
