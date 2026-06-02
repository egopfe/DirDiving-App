# Security and Privacy Release Evidence (Static)

Updated: 2026-06-02

## WatchConnectivity signed payload summary

- Sync payloads are signed and validated on both sides.
- Trust reset flow exists and requires explicit user action.

## HMAC/trust model summary

- Shared trust material is managed by watch/phone trust stores.
- Signature validation and stale/replay checks are enforced.

## Replay/skew validation summary

- Issued-at skew validation is bounded in sync codec paths.

## Trust reset behavior

- Reset path clears trust and requires fresh handshake.

## iCloud data flow

- iCloud KVS mirroring/merge paths are present; two-device runtime evidence still required.

## GPS storage and export behavior

- GPS remains surface-oriented metadata.
- Missing underwater GPS is handled as unavailable/fallback, not success.

## CSV import safeguards

- 10 MB file cap before parse.
- Binary payload rejection.
- Maximum row length, field length, and column count guards.
- Malformed rows fail gracefully with import error reporting.

## Export temp file and protection behavior

- Security hardening docs and code reference protected writes for export/sync artifacts.

## Secret scan status

- `./Scripts/check_secrets.sh` configured for local and CI checks.
- Result at this commit: no obvious secrets detected.

## Privacy-sensitive data list

- Dive timestamps, depths, temperatures.
- GPS surface entry/exit points.
- Sync metadata and import/export content.

## App Store privacy preparation

- Ensure App Privacy questionnaire reflects collected/stored data categories above.
- Keep non-certified positioning and safety limitations explicit.

## Remaining runtime evidence required

- Real Watch Ultra depth lifecycle logs.
- Two-device iCloud conflict/tombstone evidence.
- End-to-end privacy evidence pack with attached screenshots/logs.
