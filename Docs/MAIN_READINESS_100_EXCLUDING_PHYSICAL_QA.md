# MAIN Readiness 100% (Excluding Physical QA)

## Issue classification buckets

Legend: A code-fixable, B documentation-fixable, C automated-test/CI-fixable, D static/security-fixable, E process/physical QA, F App Store process/assets, G external validation campaign.

| ID | Bucket | Closure mode |
|---|---|---|
| ARCH-001 | C | closed now (CI/script/docs) |
| W-FUNC-001 | E | external physical QA required |
| W-FUNC-002 | B | closed now (doc + explicit dormant guard comments) |
| W-FUNC-003 | A | closed now (localized copy/a11y alignment) |
| I-FUNC-001 | G | external validation campaign required |
| I-FUNC-002 | E | two-device physical/process QA required |
| UX-001 | E | physical/simulator QA evidence required |
| UX-002 | E | Dynamic Type/VoiceOver execution required |
| UX-003 | E | VoiceOver journey execution required |
| UX-004 | F | App Store screenshot/process gate |
| SEC-001 | E | runtime evidence pack execution required |
| SEC-002 | A | closed now (CSV preflight hardening) |
| SEC-003 | D | closed now (secret scanning static check) |
| ALG-001 | G | external golden campaign required |
| ALG-002 | B | closed now (policy wording sync) |
| SYNC-001 | E | paired/two-device runtime QA required |
| SYNC-002 | C | closed now (drift-prevention policy + checks) |
| REL-001 | B | closed now (release gate consolidation docs) |

## Closed in-repo readiness items

- ARCH-001: xcodegen workflow clarified and validated by script/CI.
- W-FUNC-002: ModeSelectionView explicitly kept dormant in MAIN single-mode runtime.
- W-FUNC-003: Settings export copy/hint/accessibility aligned with Logbook-only export path.
- SEC-002: CSV import preflight hardened (size, binary, row-length, field/column limits) with tests.
- SEC-003: static secret scanning added (`Scripts/check_secrets.sh`) and wired into CI.
- ALG-002: policy wording synchronized across safety/release docs.
- SYNC-002: branch/target isolation policy and automation added.
- UX-004: reference screenshots still missing, documented as external App Store gate.
- REL-001: release gates consolidated into TestFlight/App Store checklists.

## External/process gates (intentionally pending)

- W-FUNC-001, I-FUNC-001, I-FUNC-002
- UX-001, UX-002, UX-003
- SEC-001 runtime evidence execution
- ALG-001 external golden validation
- SYNC-001 paired/two-device sync execution
- App Store screenshot capture and submission workflow

Status: code/static/docs complete; physical/process evidence pending by design.
