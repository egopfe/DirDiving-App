# Master Security Threat Model (CURRENT)

**Baseline:** `main` @ `7ae527b`  
**Scope:** Watch + iOS, Diving/Apnea/Snorkeling sync, storage, transfer, imports/exports, intents

## Assets

- Activity logbooks and checkpoints
- Full Computer runtime checkpoints and plan packages
- Sync envelopes, ACK metadata, tombstones, trust/bootstrap secrets
- Snorkeling route packages and presentation payloads
- Companion image/briefing-card files and metadata

## Threat Surface Summary

1. Cross-activity payload misrouting
2. Forged/altered sync payloads and ACK replay
3. Path traversal or unsafe file write/delete on transfer/import
4. Privacy overreach in GPS/location flows
5. Misuse of developer/testing/simulation paths in release contexts
6. Command/process integrity drift reducing audit reliability

## Existing Controls (software evidence)

- Signed transport envelope + activity discriminator (`ActivitySyncSignedTransport`, `ActivitySyncEnvelope`)
- Replay/nonce cache (`SyncNonceReplayCache`)
- Signed ACK pattern with per-feature ack signers
- Namespaced payload keys per activity/store
- Presentation-only unified logbook architecture with no merged canonical store
- Path sanitization and bounded import policies for files/assets
- App-intent safety/legal guard layering

## Open Threat Findings

- `MAIN-CMD-001`: command integrity chain incomplete (missing launch-order 07 file)
- `MAIN-PRIV-001`: location policy is scoped in manifests/plist, but full physical permission-path evidence is pending
- `MAIN-SYNC-001`: large payload stress not validated in paired field conditions

## Residual Risk Statements

- WC trust bootstrap remains an accepted risk boundary until stronger pre-shared trust provisioning is introduced.
- No penetration-test, certification, or external compliance claim is made in this audit.

## Verdict

`PARTIAL` - software controls remain strong, but process integrity and field evidence gates remain open.
