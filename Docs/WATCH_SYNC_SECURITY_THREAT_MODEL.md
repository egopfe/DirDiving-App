# Watch ↔ iPhone Sync Security Threat Model

Date: 2026-06-09  
Scope: MAIN branch WatchConnectivity peer-secret bootstrap

## Trust model

- Dive payloads and import ACKs use HMAC-SHA256 derived from a pairwise peer secret.
- First-trust-on-use (TOFU) pinning: once a peer secret is stored, replacements are rejected and surfaced as a trust mismatch.
- Nonces on schema v2 dive envelopes are tracked in a bounded replay cache (persisted with complete file protection).

## Why `applicationContext` carries the peer secret

WatchConnectivity encrypts payloads between paired devices. `applicationContext` is used so the companion can discover the peer secret when direct messages are unavailable during cold start. This trades broader persistence (last context snapshot on both sides) for reliable pairing without a backend.

## Risks

- Anyone with a paired-device backup or jailbroken access to WC storage could read the last published secret.
- Re-publishing the local secret on every context merge increases exposure surface.

## Mitigations (MAIN-DCA-013)

- Publish local secret only when no peer secret is stored yet (`publishSharedSecretIfNeeded`).
- Do not auto-inject secrets into unrelated `mergeApplicationContext` updates.
- Never log secret material.
- `resetPeerTrust()` clears peer secret and mismatch flags on both platforms.
- Signed payload nonces persisted across relaunch to reduce replay after restart.

## Reset / recovery

Users must reset sync trust on both devices if a companion is replaced or trust mismatch is reported. After reset, pairing re-establishes TOFU on next successful context exchange.

## Out of scope

- This is not a certified dive-computer or certified controller security model.
- Physical device theft QA remains **PENDING**.
