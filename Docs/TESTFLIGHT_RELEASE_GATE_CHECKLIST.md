# TestFlight Release Gate Checklist (MAIN)

Owner: ________  Date: ________  Build: ________  Commit: ________

## Code/doc/static gates (must be complete)

- [ ] `./Scripts/validate_main_release_readiness.sh` PASS
- [ ] `Docs/MAIN_READINESS_100_EXCLUDING_PHYSICAL_QA.md` updated
- [ ] `Docs/SECURITY_PRIVACY_RELEASE_EVIDENCE.md` updated

## External QA gates (required, not closable by code alone)

- [ ] Watch Ultra physical matrix complete (`Docs/WATCH_ULTRA_PHYSICAL_QA_MATRIX.md`) — evidence in `Docs/QA_EVIDENCE/WATCH_ULTRA/` (**PENDING** until files attached; includes mock fallback banner screenshot)
- [ ] iOS Dynamic Type + VoiceOver matrix complete (`Docs/IOS_DYNAMIC_TYPE_VOICEOVER_QA_MATRIX.md`)
- [ ] Watch-iOS sync matrix complete (`Docs/WATCH_IOS_SYNC_QA_MATRIX.md`) — evidence in `Docs/QA_EVIDENCE/WATCH_IOS_SYNC/` (**PENDING**)
- [ ] iCloud two-device matrix complete (`Docs/ICLOUD_TWO_DEVICE_QA_MATRIX.md`)
- [ ] CSV/Subsurface external matrix complete (`Docs/CSV_SUBSURFACE_QA_MATRIX.md`)
- [ ] Planner golden validation matrix complete (`Docs/PLANNER_GOLDEN_VALIDATION_QA_MATRIX.md`)

Final verdict: PASS / FAIL
