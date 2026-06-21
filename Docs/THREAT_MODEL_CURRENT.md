# DIR DIVING — Threat Model (Current)

**Command:** 9 audit + Command 10 remediation  
**Date:** 2026-06-20  
**Branch:** `main` @ `8cd51d6` (+ uncommitted remediation)  
**Scope:** MAIN Watch app + iOS companion (unified `project.yml`)

This document describes trust boundaries, assets, adversaries, and mitigations. It is an engineering threat model, not a certified security assessment.

---

## 1. System overview

```text
┌─────────────────────┐         WatchConnectivity          ┌─────────────────────┐
│  Apple Watch MAIN   │◄──── HMAC-signed envelopes ───────►│  iPhone Companion   │
│  (depth, logbook)   │    (paired devices only)           │  (logbook, planner) │
└─────────┬───────────┘                                    └─────────┬───────────┘
          │                                                          │
          │ Keychain (peer secret)                                   │ Keychain + iCloud KVS (opt-in diving)
          ▼                                                          ▼
   Application Support                                         Application Support
   (.completeFileProtection)                                   (.completeFileProtection)
```

**Out of scope for MAIN:** Backend servers, third-party analytics SDKs, Buddy Assist BLE experimental stack.

---

## 2. Assets

| Asset | Sensitivity | Storage |
|-------|-------------|---------|
| Dive depth/time profiles | High (safety-adjacent) | Protected JSON logbooks |
| Gas mix / equipment / planner state | High | Protected files + optional iCloud KVS |
| GPS entry/exit / snorkel routes | High (location privacy) | Sessions, exports, sync payloads |
| Apnea buddy contact notes | Medium | Apnea sessions |
| Snorkeling photos | Medium–High | Photo store + WC transfer |
| Peer sync secret | **Critical** | Keychain + WC applicationContext snapshot (bootstrap TTL) |
| Nonce replay state | Medium | Protected replay cache file |
| Pending sync / conflict payloads | Medium–High | Protected Application Support queues |
| Legal acceptance flag | Medium (compliance) | UserDefaults |
| Developer/simulation flags | Medium (integrity) | UserDefaults |

---

## 3. Trust boundaries

| Boundary | Trust assumption | Failure mode |
|----------|------------------|--------------|
| Watch ↔ iPhone (WC) | Apple encrypts between paired devices; attacker needs paired compromise | Forged/tampered payloads → HMAC reject |
| Peer secret bootstrap | TOFU + bootstrap epoch/TTL metadata | Attacker with early MITM on pairing could pin wrong secret → mismatch surfaced |
| WC reply handlers | Pairing boundary only; hints not authoritative | Forged reply cannot dequeue without signed ACK |
| Local filesystem | iOS Data Protection + device passcode | Jailbreak/backup extraction reads protected files after first unlock |
| iCloud KVS | Apple account + opt-in (diving only) | Account compromise exposes backed-up dive logs |
| User share sheet (export) | User chooses recipient | Default diving CSV omits GPS; opt-in for precise |
| App Intents / Action Button | OS invokes intents | Mitigated by legal acceptance gate |
| App Store vs TestFlight | Receipt URL distinguishes build class | TestFlight requires simulation acknowledgment |

---

## 4. Adversary profiles

| Profile | Capability | Primary goals |
|---------|------------|---------------|
| A1 — Malicious paired app (hypothetical) | Sends WC messages on paired channel | Inject/delete sessions, drain queues |
| A2 — Local attacker with unlocked device | Read app container | Exfiltrate logs, peer secret, GPS |
| A3 — Backup / forensic extractor | Offline device backup | Read last WC context, logbook files |
| A4 — Malicious import file | User selects CSV/photo in app | Corrupt logbook, path traversal, DoS |
| A5 — Curious TestFlight tester | Developer settings unlocked | Run simulation depth (integrity, not secrecy) |
| A6 — Remote network attacker | Internet | **No MAIN attack surface** (no arbitrary network) |

---

## 5. STRIDE summary

| Threat | Examples | Mitigations | Residual |
|--------|----------|-------------|----------|
| **Spoofing** | Forged dive session without peer secret | HMAC-SHA256, `hasPeerSecret()` gate | None for unsigned payloads |
| **Tampering** | Modified depth samples in transit | Signed envelope + payload hash (v3) | Low — reply handler hardened |
| **Repudiation** | Deny sync delivery | Signed ACK; protected pending queues | No third-party audit log |
| **Information disclosure** | GPS in CSV export; secret in logs | Default omit GPS; no secret logging; protected queues | WC context backup extraction (accepted) |
| **Denial of service** | Oversized WC payload | 512KB cap; large-payload file path; CSV bounds | Huge import preflight blocked |
| **Elevation** | App Intent before disclaimer | `requireLegalAcceptanceForSafetyIntent` | N/A if gate holds |

---

## 6. WatchConnectivity sync threat detail

### 6.1 Authentication flow

1. Each app generates/stores local secret in Keychain (`kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly`).
2. Watch publishes local secret via `applicationContext` only when no peer secret stored, with bootstrap metadata (version, issued-at, trust epoch).
3. Companion ingests with TOFU pinning; mismatch → `rejectedMismatch` (SEC-NEG-03).
4. Sync key derived via v2 algorithm (ordered secrets + bundle IDs) — Watch/iOS aligned.
5. Payloads: schema v2 legacy + **v3 signed transport** with `activityType`, `messageType`, `messageID`, `payloadHash`, nonce, `issuedAt` skew window.

See [`WATCH_SYNC_SECURITY_THREAT_MODEL.md`](WATCH_SYNC_SECURITY_THREAT_MODEL.md) for bootstrap policy detail.

### 6.2 Replay

- Nonces registered in bounded persistent cache (`.completeFileProtection`).
- Second use rejected (SEC-NEG-02).
- `importedSessionIDs` FIFO cap adds session-level idempotency.

### 6.3 Cross-activity routing

- Distinct WC keys per activity.
- v3 `ActivitySyncRoutingGuard` rejects envelope activity ≠ payload key.
- Cross-decode rejection tests at codec layer.

### 6.4 Deletion / tombstones

- Signed tombstone broadcasts per activity prevent deleted sessions reappearing from stale payloads.
- **Physical QA pending** for multi-device tombstone convergence.

### 6.5 Reply handler policy

- `WatchSyncReplyHandlerPolicy`: `status: acknowledged` is transport hint only.
- Pending transfer dequeue requires signed ACK candidate with session ID and signature verification (SEC-NEG-15, SEC-NEG-20).

---

## 7. Data lifecycle threats

### 7.1 At rest

- **Mitigation:** `.completeFileProtection` on logbooks, exports, replay cache, photo staging, sync queues, conflicts (`ProtectedSensitiveFileStore`).
- UserDefaults: non-sensitive flags only; pending session payloads migrated off plain UD.

### 7.2 In transit (WC)

- Apple-provided encryption between paired devices.
- Application-layer HMAC prevents semantic tampering even within WC trust zone.

### 7.3 Cloud (iCloud KVS)

- Diving-only opt-in via `CloudBackupCapability`.
- Apnea/Snorkeling explicitly unavailable — prevents false user expectation (SEC-NEG-07/08).

### 7.4 Export / import

- **Import:** Size caps (`DiveCSVImportBounds`), row validation, GPS sanity, path traversal blocks, photo magic-byte validation.
- **Export:** Subsurface CSV default omits GPS (`DivingExportPrivacyPolicy`); protected temp files.

---

## 8. Privacy & compliance surface

| Requirement | Status |
|-------------|--------|
| Usage descriptions (location, photos, motion) | Present in Info.plist |
| Privacy Nutrition Labels (App Store) | Aligned with manifests — external review PENDING |
| **Privacy Manifest (`PrivacyInfo.xcprivacy`)** | **Present — Watch + iOS** |
| ATT / tracking | No tracking SDKs; `NSPrivacyTracking` false |
| HealthKit | Not used in MAIN |

See [`PRIVACY_MANIFEST_DECLARATION_CURRENT.md`](PRIVACY_MANIFEST_DECLARATION_CURRENT.md).

---

## 9. Recovery & incident response

| Event | User action | System behavior |
|-------|-------------|-----------------|
| Trust mismatch | Reset sync trust on **both** devices | `resetPeerTrust()` clears peer secret; epoch increments |
| Companion replaced | Same as above | TOFU re-establishment with fresh bootstrap |
| iCloud data concern | Disable diving cloud backup in More | Local logbook unaffected |
| Simulation misuse (beta) | Acknowledge disclosure or use App Store build | App Store disables simulation selection |

---

## 10. Test evidence mapping

| Control | Test / doc |
|---------|------------|
| Forged HMAC | SEC-NEG-01 |
| Replay | SEC-NEG-02 |
| TOFU mismatch | SEC-NEG-03 |
| Path traversal | SEC-NEG-04, SEC-NEG-05 |
| Legacy v1 blocked | SEC-NEG-06 |
| Cloud scope | SEC-NEG-07, SEC-NEG-08 |
| Fingerprint ≠ secret | SEC-NEG-09 |
| Oversized KVS ignored | SEC-NEG-10 |
| Privacy manifests | SEC-NEG-11, SEC-NEG-12 |
| Export GPS default omit | SEC-NEG-13 |
| Bootstrap stale reject | SEC-NEG-14 |
| Reply handler hardening | SEC-NEG-15, SEC-NEG-20 |
| CSV import bounds | SEC-NEG-16 |
| Protected queues | SEC-NEG-17 |
| v3 envelope / tombstone | `ActivitySync*Tests` |
| File protection | `MAIN_PRIVACY_FILE_PROTECTION_MATRIX_CURRENT.csv` |

---

## 11. Out of scope / explicit non-claims

- Certified dive computer or life-support device security model
- Penetration test or red-team engagement
- Regulatory compliance certification (GDPR DPIA, etc.)
- Physical theft/lost device QA (**PENDING**)
- Supply-chain compromise of Apple OS frameworks

---

## 12. Document maintenance

Update this model when:

- Sync schema version increments
- New activities or cloud scopes added
- Privacy manifest or entitlements change
- New external network integrations introduced
- Bootstrap or trust epoch policy changes
