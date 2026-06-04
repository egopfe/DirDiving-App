# Security Static Checklist (MAIN)

## Automated checks

- [ ] Run `./Scripts/check_secrets.sh`
- [ ] Confirm no potential secrets were reported
- [ ] Confirm `DIRDiving.xcodeproj` drift check passes after `xcodegen generate`
- [ ] Confirm no private Apple API references for system Low Power Mode

## Security remediation 2026-06-04 (SEC-P1–P3)

- [ ] App Intents blocked before legal acceptance (`LegalAcceptanceGate`)
- [ ] Sensor default `.automatic`; simulation DEBUG/TestFlight-only; SIMULATION badge when mock active
- [ ] iOS cloud logbook backup opt-in default OFF (`CloudBackupSettings`)
- [ ] Watch/iOS peer secret TOFU pinning; reset pairing trust documented
- [ ] Watch photo import decode/re-encode before storage
- [ ] No tracked `*.zip` branch snapshots in source (see `.gitignore`)
- [ ] GitHub Actions `permissions: contents: read`
- [ ] Evidence: `Docs/DIR_DIVING_SECURITY_REMEDIATION_REPORT_20260604.md`

## Manual static review

- [ ] No Apple credentials, signing material, API tokens, test passwords in tracked files
- [ ] Mission Mode wording stays "internal runtime/UI profile", not Apple system Low Power Mode
- [ ] Watch/iOS sync signing/trust docs remain aligned with code
- [ ] CSV import safeguards remain bounded (`maxImportBytes`, malformed file rejection)

## Release evidence

- [ ] Record scanner command and date in `Docs/SECURITY_PRIVACY_RELEASE_EVIDENCE.md`
- [ ] Record reviewer name and commit hash
