# Watch ↔ iPhone Sync Security Threat Model

Date: 2026-06-20 (Command 10 update)  
Scope: MAIN branch WatchConnectivity peer-secret bootstrap and trust lifecycle

## Trust model

- Dive payloads and import ACKs use HMAC-SHA256 derived from a pairwise peer secret.
- First-trust-on-use (TOFU) pinning: once a peer secret is stored, replacements are rejected and surfaced as a trust mismatch.
- Nonces on schema v2/v3 dive envelopes are tracked in a bounded replay cache (persisted with complete file protection).
- WC `sendMessage` reply handlers treat transport hints as non-authoritative; signed ACK tokens gate pending queue drain (`WatchSyncReplyHandlerPolicy`).

## Why `applicationContext` carries the peer secret

WatchConnectivity encrypts payloads between paired devices. `applicationContext` is used so the companion can discover the peer secret when direct messages are unavailable during cold start. This trades broader persistence (last context snapshot on both sides) for reliable pairing without a backend.

**Status:** DOCUMENTED_ACCEPTED_RISK (`SEC-P2-003`).

## Bootstrap policy (Command 10)

`WatchSyncTrustBootstrapPolicy` constrains initial secret exchange:

| Control | Behavior |
|---------|----------|
| Bootstrap version | `dirdiving_watch_sync_bootstrap_version` — future versions rejected |
| Issued-at TTL | 24 h maximum age; rejects stale or far-future timestamps |
| Trust epoch | `dirdiving_watch_sync_bootstrap_epoch` must match local trust epoch |
| Publish gate | Secret published only when no peer secret stored (`shouldAcceptSecretBootstrap`) |
| Context sanitization | After trust established, secret and bootstrap keys removed from merged context |
| Legacy grace | Missing metadata accepted once for backward compatibility with older builds |

Integrated with `WatchSyncAuth.ingestSharedSecretFromContext` and `resetPeerTrust()` on both platforms.

## Risks

- Anyone with a paired-device backup or jailbroken access to WC storage could read the last published secret.
- Re-publishing the local secret on every context merge increases exposure surface (mitigated: publish-only-when-needed).

## Mitigations (MAIN-DCA-013 + Command 10)

- Publish local secret only when no peer secret is stored yet (`publishSharedSecretIfNeeded`).
- Bootstrap metadata TTL and trust epoch validation (SEC-NEG-14).
- Do not auto-inject secrets into unrelated `mergeApplicationContext` updates.
- Sanitize secret from context after trust established.
- Never log secret material.
- `resetPeerTrust()` clears peer secret, mismatch flags, and increments trust epoch on both platforms.
- Signed payload nonces persisted across relaunch to reduce replay after restart.
- Pending sync/conflict payloads stored in `ProtectedSensitiveFileStore` (not plain UserDefaults).

## Reset / recovery

Users must reset sync trust on both devices if a companion is replaced or trust mismatch is reported. After reset, pairing re-establishes TOFU on next successful context exchange with fresh bootstrap metadata.

## Test evidence

| Control | Test |
|---------|------|
| TOFU mismatch | SEC-NEG-03 |
| Fingerprint ≠ secret | SEC-NEG-09 |
| Stale bootstrap rejected | SEC-NEG-14 |
| Forged reply blocked | SEC-NEG-15 |
| Transport hint no dequeue | SEC-NEG-20 |

## Out of scope

- This is not a certified dive-computer or certified controller security model.
- Physical device theft QA remains **PENDING** (`SECURITY_EXTERNAL_QA_PENDING_CURRENT.md`).
