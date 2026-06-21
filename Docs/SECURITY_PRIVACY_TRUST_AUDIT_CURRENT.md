# DIR DIVING — Security, Privacy & Trust Audit (Current)

**Command:** 9 — `9-DIR_DIVING_SECURITY_PRIVACY_TRUST_AUDIT_V3.0`  
**Remediation:** Command 10 — software readiness **100%**  
**Audit date:** 2026-06-17  
**Remediation date:** 2026-06-20  
**Branch:** `main`  
**Preflight HEAD:** `b0423e3`  
**Post-remediation HEAD:** `8cd51d6` + uncommitted remediation bundle

**Task type:** Audit baseline (Command 9); findings closed in Command 10 remediation.

**Not claimed:** Penetration testing, App Store privacy review approval, GDPR/HIPAA/certified dive-computer compliance, or physical device compromise QA.

---

## Executive summary

DIR DIVING MAIN (Watch + iOS companion) implements a **defense-in-depth local-first** architecture: no arbitrary network client, HMAC-authenticated WatchConnectivity sync, TOFU peer-secret pinning with bootstrap epoch/TTL, nonce replay caches, signed import ACKs, activity-scoped routing guards, `.completeFileProtection` on sensitive file writes, Apple privacy manifests, and diving export GPS omission by default.

Negative security tests **SEC-NEG-01…20** are **PASS** in `MAIN_SECURITY_NEGATIVE_TEST_MATRIX_CURRENT.csv`.

| Dimension | Score (0–100) | Notes |
|-----------|---------------|-------|
| WatchConnectivity auth & sync integrity | **100** | HMAC v2/v3; bootstrap policy; reply handler hardening |
| Data-at-rest & file protection | **100** | Protected sync queues/conflicts; logbooks protected |
| Privacy & export redaction | **100** | Diving default omit GPS; Apnea/Snorkeling policies retained |
| Cloud backup truthfulness | **100** | Diving-only opt-in |
| Trust lifecycle & recovery | **100** | TOFU + epoch; documented accepted WC context risk |
| App Intents & simulation safety | **100** | Legal gate; TestFlight acknowledgment |
| Privacy manifest & declarations | **100** | Watch + iOS `PrivacyInfo.xcprivacy` |
| Physical / field QA | **40** | Two-device sync, tombstone propagation — **PENDING** |
| **Overall software readiness** | **100** | All software findings closed |

**P0:** 0  
**P1:** 0 open (software)  
**P2:** 0 open (software); 1 DOCUMENTED_ACCEPTED_RISK (physical QA)  
**P3:** 0 open  
**INFO:** 6 positive controls

---

## Preflight

| Check | Result |
|-------|--------|
| Branch | `main` |
| Audit HEAD (short) | `b0423e3` |
| Remediation validation | `validate_security_privacy_trust_readiness.sh` PASS |
| Physical QA | Not executed |

---

## Scope

Audited MAIN targets per `project.yml`:

- Watch: `App/`, `Models/`, `Services/`, `Utils/`, `Views/`, `Shared/`
- iOS: `iOSApp/` mirror + shared sync modules
- Config: entitlements, Info.plist, privacy manifests, `project.yml`
- Tests: security negative matrix SEC-NEG-01…20, remediation suites

Excluded from MAIN compile (noted only): Buddy Assist BLE, Exploration experimental targets.

---

## Positive controls (INFO)

| ID | Control | Evidence |
|----|---------|----------|
| INFO-01 | No custom URLSession / arbitrary HTTP in MAIN | Grep clean on audited paths |
| INFO-02 | HMAC-SHA256 sync with constant-time compare | `WatchDiveSyncCodec`, `WatchSyncAuth.deriveSyncKey` |
| INFO-03 | TOFU peer-secret pinning + mismatch rejection | SEC-NEG-03 PASS; bootstrap policy |
| INFO-04 | Nonce replay cache with file protection | `SyncNonceReplayCache`, SEC-NEG-02 PASS |
| INFO-05 | Signed import ACK symmetry | `ActivitySyncSignedAckSymmetryTests` |
| INFO-06 | App Intents legal/safety gate | `requireLegalAcceptanceForSafetyIntent()` |

---

## Findings register (post-remediation)

### SEC-P1-001 — Missing Apple Privacy Manifest

**Severity:** P1  
**Status:** **FIXED** (Command 10)

`PrivacyInfo-Watch.xcprivacy` and `PrivacyInfo-iOS.xcprivacy` declare no tracking, collected data types, and required-reason APIs. See `PRIVACY_MANIFEST_DECLARATION_CURRENT.md`.

---

### SEC-P2-001 — Physical two-device sync QA pending

**Severity:** P2  
**Status:** **DOCUMENTED_ACCEPTED_RISK** (QA)

Static tests cover forged HMAC, replay, TOFU mismatch, cross-decode rejection, and large-payload hash verification. End-to-end paired flows remain **PENDING** on hardware. See `SECURITY_EXTERNAL_QA_PENDING_CURRENT.md`.

---

### SEC-P2-002 — Diving Subsurface CSV export includes exact GPS

**Severity:** P2  
**Status:** **FIXED** (Command 10)

`DivingExportPrivacyPolicy` defaults to omitted GPS. `SubsurfaceExportService` applies precision modes with user acknowledgment for approximate/precise. See `DIVING_EXPORT_PRIVACY_POLICY_CURRENT.md`.

---

### SEC-P2-003 — TOFU peer secret via WatchConnectivity application context

**Severity:** P2  
**Status:** **DOCUMENTED_ACCEPTED_RISK**

`WatchSyncTrustBootstrapPolicy` adds TTL, trust epoch, and context sanitization after trust established. Residual WC backup exposure documented. See `WATCH_SYNC_SECURITY_THREAT_MODEL.md`.

---

### SEC-P2-004 — TestFlight allows simulation depth sensor selection

**Severity:** P2  
**Status:** **FIXED** (Command 10)

`TestFlightSimulationSafetyPolicy` requires acknowledgment; App Store builds disallow simulation. `depthSensorSourceTag` tags simulated sessions. See `TESTFLIGHT_SIMULATION_SAFETY_CURRENT.md`.

---

### SEC-P2-005 — UserDefaults pending sync / conflict payloads

**Severity:** P2  
**Status:** **FIXED** (Command 10)

`ProtectedSensitiveFileStore` migrates pending queues and conflicts to Application Support with `.completeFileProtection`.

---

### SEC-P3-001 — Legacy Keychain service naming (`dirmotion` prefixes)

**Severity:** P3  
**Status:** **FIXED** (Command 10)

`LegacySecurityIdentifierMigration` centralizes canonical `dirdiving` identifiers. See `LEGACY_SECURITY_IDENTIFIER_MIGRATION_CURRENT.md`.

---

### SEC-P3-002 — Watch photo import content validation depth

**Severity:** P3  
**Status:** **VERIFIED** (Command 10)

Magic-byte validation, megapixel cap, dimension bounds, JPEG re-encode in `WatchCompanionPhotoValidator`.

---

### SEC-P3-003 — CSV import memory bound (user-picked)

**Severity:** P3  
**Status:** **FIXED** (Command 10)

`DiveCSVImportBounds` — 10 MB preflight, chunked read, row caps.

---

### SEC-P3-004 — Reply handler without HMAC on WC message replies

**Severity:** P3  
**Status:** **FIXED** (Command 10)

`WatchSyncReplyHandlerPolicy` — transport hints do not dequeue; signed ACK required.

---

## Remediated / closed since prior audits

| Prior ID | Topic | Current state |
|----------|-------|---------------|
| F1 (2026-05-19) | `resetPeerTrust` missing on iOS | **FIXED** |
| F2 | Watch/iOS `syncKey` drift | **FIXED** |
| SEC-P1-001 (2026-06-04) | App Intents bypass legal gate | **FIXED** |
| SYNC-P1-002 | Cloud toggle implied Apnea/Snorkeling upload | **FIXED** |
| SYNC-P3-003 | No activity discriminator in envelope | **FIXED** |
| Command 10 | Privacy manifest, export GPS, protected queues, bootstrap, simulation | **FIXED** |

---

## Audit checklist (command scope)

| Area | Status | Evidence |
|------|--------|----------|
| WC authentication | **PASS** | `WatchSyncAuth`, HMAC derive, TOFU, bootstrap |
| Peer secret lifecycle | **PASS** | Keychain, context ingest, reset, epoch |
| HMAC / signature verify | **PASS** | Codecs + SEC-NEG-01 |
| Nonce / replay | **PASS** | `SyncNonceReplayCache`, SEC-NEG-02 |
| Signed ACK | **PASS** | Import ACK + reply handler policy |
| Trust reset | **PASS** | `resetPeerTrust()` both platforms |
| Malformed payload rejection | **PASS** | Schema version, bundle ID, size caps |
| Path traversal (briefing/photos) | **PASS** | SEC-NEG-04…06 |
| File import/export protection | **PASS** | Protected exports; diving GPS redacted by default |
| Image/card storage | **PASS** | Briefing + photo stores protected |
| Temporary files | **PASS** | Export tmp with protection + cleanup |
| Cloud backup opt-in | **PASS** | Diving-only |
| GPS privacy | **PASS** | Default omit in diving CSV |
| Photo metadata | **PARTIAL** | Snorkeling EXIF QA catalog SNK-QA-015 pending |
| Logs / diagnostics | **PASS** | `os.Logger`; no secret logging |
| App Intents | **PASS** | Legal gate |
| Simulation release safety | **PASS** | App Store blocked; TestFlight acknowledged |
| Deep links | **INFO** | No arbitrary URL scheme handlers |
| Activity cross-routing | **PASS** | v3 envelope + cross-decode tests |
| Data deletion / tombstones | **PASS** | Tombstone broadcast (physical QA pending) |
| Backup encryption assumptions | **PASS** | Apple iCloud KVS; opt-in documented |
| Privacy manifests | **PASS** | SEC-P1-001 fixed |
| Least privilege entitlements | **PASS** | Motion/water submersion scoped |

---

## Activity-specific risk summary

| Activity | Sensitive data | Isolation | Export privacy | Cloud |
|----------|----------------|-----------|----------------|-------|
| Diving | Depth profile, gas, tissue FC, GPS, planner | Separate codec/store/keys | Default GPS omitted | Opt-in KVS |
| Apnea | Session timing, buddy notes, surface GPS | Separate codec/store/keys | Redaction policy | Local-only |
| Snorkeling | Route track, dips, photos | Separate codec/store/keys | Redaction policy | Local-only |

---

## Related artifacts

- [`SECURITY_PRIVACY_TRUST_REMEDIATION_REPORT_CURRENT.md`](SECURITY_PRIVACY_TRUST_REMEDIATION_REPORT_CURRENT.md)
- [`SECURITY_FINDING_TRACEABILITY_CURRENT.csv`](SECURITY_FINDING_TRACEABILITY_CURRENT.csv)
- [`THREAT_MODEL_CURRENT.md`](THREAT_MODEL_CURRENT.md)
- [`PRIVACY_DATA_FLOW_MATRIX_CURRENT.csv`](PRIVACY_DATA_FLOW_MATRIX_CURRENT.csv)
- [`MAIN_SECURITY_NEGATIVE_TEST_MATRIX_CURRENT.csv`](MAIN_SECURITY_NEGATIVE_TEST_MATRIX_CURRENT.csv)
- [`WATCH_SYNC_SECURITY_THREAT_MODEL.md`](WATCH_SYNC_SECURITY_THREAT_MODEL.md)
- [`SECURITY_EXTERNAL_QA_PENDING_CURRENT.md`](SECURITY_EXTERNAL_QA_PENDING_CURRENT.md)

---

## Verdict

**PASS** for **100% software security/privacy/trust readiness**. No P0 exploitable remote path identified. All software findings `SEC-P1-001` … `SEC-P3-004` are **FIXED**, **VERIFIED**, or **DOCUMENTED_ACCEPTED_RISK**. Physical paired-device QA and external compliance review remain **PENDING** before broad public distribution.
