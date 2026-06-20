# DIR DIVING — Threat Model (Current)

**Command:** 9 — Security/Privacy/Trust Audit V3.0  
**Date:** 2026-06-17  
**Branch:** `main` @ `b0423e3` (+ Command 8 security remediation in same release pass)  
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
| Peer sync secret | **Critical** | Keychain + WC applicationContext snapshot |
| Nonce replay state | Medium | Protected replay cache file |
| Legal acceptance flag | Medium (compliance) | UserDefaults |
| Developer/simulation flags | Medium (integrity) | UserDefaults |

---

## 3. Trust boundaries

| Boundary | Trust assumption | Failure mode |
|----------|------------------|--------------|
| Watch ↔ iPhone (WC) | Apple encrypts between paired devices; attacker needs paired compromise | Forged/tampered payloads → HMAC reject |
| Peer secret bootstrap | TOFU on first context exchange | Attacker with early MITM on pairing could pin wrong secret → mismatch surfaced |
| Local filesystem | iOS Data Protection + device passcode | Jailbreak/backup extraction reads protected files after first unlock |
| iCloud KVS | Apple account + opt-in (diving only) | Account compromise exposes backed-up dive logs |
| User share sheet (export) | User chooses recipient | CSV/PDF may contain GPS unless redacted |
| App Intents / Action Button | OS invokes intents | Mitigated by legal acceptance gate |
| App Store vs TestFlight | Receipt URL distinguishes build class | TestFlight retains simulation sensor path |

---

## 4. Adversary profiles

| Profile | Capability | Primary goals |
|---------|------------|---------------|
| A1 — Malicious paired app (hypothetical) | Sends WC messages on paired channel | Inject/delete sessions, drain queues |
| A2 — Local attacker with unlocked device | Read app container, UserDefaults | Exfiltrate logs, peer secret, GPS |
| A3 — Backup / forensic extractor | Offline device backup | Read last WC context, logbook files |
| A4 — Malicious import file | User selects CSV/photo in app | Corrupt logbook, path traversal, DoS |
| A5 — Curious TestFlight tester | Developer settings unlocked | Run simulation depth (integrity, not secrecy) |
| A6 — Remote network attacker | Internet | **No MAIN attack surface** (no arbitrary network) |

---

## 5. STRIDE summary

| Threat | Examples | Mitigations | Residual |
|--------|----------|-------------|----------|
| **Spoofing** | Forged dive session without peer secret | HMAC-SHA256, `hasPeerSecret()` gate | None for unsigned payloads |
| **Tampering** | Modified depth samples in transit | Signed envelope + payload hash (v3) | WC reply ack without HMAC (low) |
| **Repudiation** | Deny sync delivery | Signed ACK; local pending queues | No third-party audit log |
| **Information disclosure** | GPS in CSV export; secret in logs | Export policies (partial); no secret logging | Diving CSV GPS; UserDefaults pending |
| **Denial of service** | Oversized WC payload | 512KB cap; large-payload file path | Huge user CSV import |
| **Elevation** | App Intent before disclaimer | `requireLegalAcceptanceForSafetyIntent` | N/A if gate holds |

---

## 6. WatchConnectivity sync threat detail

### 6.1 Authentication flow

1. Each app generates/stores local secret in Keychain (`kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly`).
2. Watch publishes local secret via `applicationContext` only when no peer secret stored.
3. Companion ingests with TOFU pinning; mismatch → `rejectedMismatch` (SEC-NEG-03).
4. Sync key derived via v2 algorithm (ordered secrets + bundle IDs) — Watch/iOS aligned.
5. Payloads: schema v2 legacy + **v3 signed transport** with `activityType`, `messageType`, `messageID`, `payloadHash`, nonce, `issuedAt` skew window.

### 6.2 Replay

- Nonces registered in bounded persistent cache (`.completeFileProtection`).
- Second use rejected (SEC-NEG-02).
- `importedSessionIDs` FIFO cap adds session-level idempotency.

### 6.3 Cross-activity routing

- Distinct WC keys per activity (`dirdiving_dive_session`, `dirdiving_apnea_session`, `dirdiving_snorkeling_session_sync`).
- v3 `ActivitySyncRoutingGuard` rejects envelope activity ≠ payload key.
- Cross-decode rejection tests at codec layer.

### 6.4 Deletion / tombstones

- Signed tombstone broadcasts per activity (Command 8) prevent deleted sessions reappearing from stale payloads.
- **Physical QA pending** for multi-device tombstone convergence.

---

## 7. Data lifecycle threats

### 7.1 At rest

- **Primary mitigation:** `.completeFileProtection` on logbooks, exports, replay cache, photo staging.
- **Gap:** UserDefaults queues for pending sync/conflicts (P2).

### 7.2 In transit (WC)

- Apple-provided encryption between paired devices.
- Application-layer HMAC prevents semantic tampering even within WC trust zone.

### 7.3 Cloud (iCloud KVS)

- Diving-only opt-in via `CloudBackupCapability`.
- Apnea/Snorkeling explicitly unavailable — prevents false user expectation (SEC-NEG-07/08).

### 7.4 Export / import

- **Import:** Size caps, row validation, GPS sanity, path traversal blocks on briefing filenames.
- **Export:** Subsurface CSV writes protected temp files; **GPS not redacted** for diving (P2).

---

## 8. Privacy & compliance surface

| Requirement | Status |
|-------------|--------|
| Usage descriptions (location, photos, motion) | Present in Info.plist |
| Privacy Nutrition Labels (App Store) | Engineering must align with manifest |
| **Privacy Manifest (`PrivacyInfo.xcprivacy`)** | **Missing — P1** |
| ATT / tracking | No tracking SDKs detected |
| HealthKit | Not used in MAIN |

---

## 9. Recovery & incident response

| Event | User action | System behavior |
|-------|-------------|-----------------|
| Trust mismatch | Reset sync trust on **both** devices | `resetPeerTrust()` clears peer secret |
| Companion replaced | Same as above | TOFU re-establishment |
| iCloud data concern | Disable diving cloud backup in More | Local logbook unaffected |
| Simulation misuse (beta) | Use App Store build | Simulation selection disabled |

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
| v3 envelope / tombstone | `ActivitySync*Tests`, `MultiActivitySequentialSyncTests` |
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
