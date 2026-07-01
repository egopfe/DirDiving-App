# DIR DIVING — Master Security Remediation Plan (Current)

**Audit:** 04 @ `2c30412` | **Date:** 2026-07-01

## Software posture

Static security controls **PASS** at `451f8fb`: HMAC v3 envelopes, activity routing guards, signed tombstones, peer secret pinning, path-sanitized file transfers, Privacy Manifests, App Intent legal gates, simulation release blocks.

## Open remediation (by priority)

### P1

| ID | Gap | Remediation | Tests |
|----|-----|-------------|-------|
| MAIN-P1-001 | Command integrity script stale | Update script paths (process gate) | `validate_commands_for_cursor_integrity.sh` PASS |

### P2 — field validation (no fake evidence)

| ID | Gap | Remediation | Tests |
|----|-----|-------------|-------|
| MAIN-SEC-001 | Paired sync security not field-verified | Execute paired QA matrix | SEC-NEG field cases |
| MAIN-SYNC-001 | Large payload file transfer not field-verified | 5MB round-trip on hardware | ActivitySyncLargePayloadTransfer + field |

### P3 — accepted architectural boundaries

| ID | Gap | Posture |
|----|-----|---------|
| MAIN-SEC-002 | WC TOFU peer secret bootstrap | DOCUMENTED_ACCEPTED_RISK — pinning + reset epoch |
| MAIN-SYNC-004 | Legacy diving tombstone UUID mirror at bootstrap | DOCUMENTED_ACCEPTED_RISK — signed path primary |

## Do not weaken

- HMAC verification or constant-time compare
- Activity envelope `activityType` discriminator
- Cross-decode rejection in `ActivitySyncRoutingGuard`
- Briefing card reference-only policy on Watch
- Cloud backup opt-in truthfulness per activity
