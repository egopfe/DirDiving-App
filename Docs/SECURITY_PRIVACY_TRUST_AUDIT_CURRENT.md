# DIR DIVING — Security, Privacy & Trust Audit (Current)

**Command:** 9 — `9-DIR_DIVING_SECURITY_PRIVACY_TRUST_AUDIT_V3.0`  
**Date:** 2026-06-17  
**Branch:** `main`  
**Preflight HEAD:** `b0423e3`  
**Workspace note:** This audit evaluates the unified MAIN tree including in-flight Command 8 sync/persistence remediation (signed envelope v3, multi-activity tombstones, `CloudBackupCapability`, large-payload transfer) present in the working tree at audit time and committed in the same release pass as these reports.

**Task type:** Read-only audit (reports only; user requested commit/push of deliverables separately).

**Not claimed:** Penetration testing, App Store privacy review approval, GDPR/HIPAA/certified dive-computer compliance, or physical device compromise QA.

---

## Executive summary

DIR DIVING MAIN (Watch + iOS companion) implements a **defense-in-depth local-first** architecture: no arbitrary network client, HMAC-authenticated WatchConnectivity sync, TOFU peer-secret pinning, nonce replay caches, signed import ACKs, activity-scoped routing guards, and `.completeFileProtection` on sensitive file writes. Negative security tests **SEC-NEG-01…10** are **PASS** in `MAIN_SECURITY_NEGATIVE_TEST_MATRIX_CURRENT.csv`.

| Dimension | Score (0–100) | Notes |
|-----------|---------------|-------|
| WatchConnectivity auth & sync integrity | **88** | HMAC v2 + v3 envelope; cross-decode guards; tombstone broadcast (post-Command 8) |
| Data-at-rest & file protection | **86** | Logbooks, exports, replay cache protected; UserDefaults pending queues residual |
| Privacy & export redaction | **78** | Apnea/Snorkeling export policies; Diving Subsurface CSV emits raw GPS |
| Cloud backup truthfulness | **90** | Diving-only opt-in; Apnea/Snorkeling explicitly unavailable |
| Trust lifecycle & recovery | **82** | TOFU + reset; residual WC context exposure documented |
| App Intents & simulation safety | **80** | Legal gate on safety intents; simulation allowed in TestFlight |
| Privacy manifest & declarations | **55** | **No `PrivacyInfo.xcprivacy`**; usage strings present for location/photos |
| Physical / field QA | **40** | Two-device sync, tombstone propagation, large payload — **PENDING** |
| **Overall static readiness** | **83** | Software controls strong; P1 manifest gap; field QA open |

**P0:** 0  
**P1:** 1 open  
**P2:** 5 open  
**P3:** 4 open  
**INFO:** 6 positive controls

---

## Preflight

| Check | Result |
|-------|--------|
| Branch | `main` |
| HEAD (short) | `b0423e3` |
| `origin/main` | Aligned at preflight |
| Build tooling | macOS/Xcode available in maintainer environment; audit is static + referenced XCTest matrices |
| Physical QA | Not executed in this pass |

---

## Scope

Audited MAIN targets per `project.yml`:

- Watch: `App/`, `Models/`, `Services/`, `Utils/`, `Views/`, `Shared/`
- iOS: `iOSApp/` mirror + shared sync modules
- Config: entitlements, Info.plist, `project.yml`
- Tests: security negative matrix, activity sync tests (referenced, not re-run in audit host unless noted)

Excluded from MAIN compile (noted only): Buddy Assist BLE, Exploration experimental targets.

---

## Positive controls (INFO)

| ID | Control | Evidence |
|----|---------|----------|
| INFO-01 | No custom URLSession / arbitrary HTTP in MAIN | Grep clean on audited paths |
| INFO-02 | HMAC-SHA256 sync with constant-time compare | `WatchDiveSyncCodec`, `WatchSyncAuth.deriveSyncKey` |
| INFO-03 | TOFU peer-secret pinning + mismatch rejection | SEC-NEG-03 PASS; `WatchSyncAuth.ingestSharedSecretFromContext` |
| INFO-04 | Nonce replay cache with file protection | `SyncNonceReplayCache`, SEC-NEG-02 PASS |
| INFO-05 | Signed import ACK symmetry | `ActivitySyncSignedAckSymmetryTests`, dive plan ACK signer |
| INFO-06 | App Intents legal/safety gate | `requireLegalAcceptanceForSafetyIntent()` in `ActionButtonIntents.swift` |

---

## Findings register

### SEC-P1-001 — Missing Apple Privacy Manifest (`PrivacyInfo.xcprivacy`)

**Severity:** P1  
**Area:** App Store privacy requirements, required-reason API declarations  
**Status:** OPEN

No `PrivacyInfo.xcprivacy` resource exists for Watch or iOS targets. Apple requires privacy manifests for apps using certain APIs (UserDefaults, file timestamps, etc.) and for third-party SDK disclosure.

**Impact:** App Store Connect submission risk; incomplete transparency on data collection categories.

**Evidence:** Repository grep for `PrivacyInfo`, `xcprivacy`, `NSPrivacy` — no matches.

**Recommended fix:** Add target-specific manifests declaring: no tracking; on-device dive/log data; WC sync; optional iCloud KVS (diving-only); required-reason APIs actually used (UserDefaults, file access). See `SECURITY_REMEDIATION_PLAN_CURRENT.md`.

---

### SEC-P2-001 — Physical two-device sync QA pending

**Severity:** P2  
**Area:** Trust boundary validation  
**Status:** OPEN (QA)

Static tests cover forged HMAC, replay, TOFU mismatch, cross-decode rejection, and large-payload hash verification. End-to-end paired Watch+iPhone flows for v3 envelope, tombstone resurrection prevention, and file-transfer fallback are **PENDING** on hardware.

---

### SEC-P2-002 — Diving Subsurface CSV export includes exact GPS coordinates

**Severity:** P2  
**Area:** Export privacy  
**Status:** OPEN

`SubsurfaceExportService` (Watch and iOS) writes entry/exit latitude and longitude at six decimal places. Apnea and Snorkeling exports use `*ExportPrivacyPolicy` redaction gates; Diving has no equivalent opt-out for CSV share sheets.

**Impact:** User-initiated share may expose precise dive site location without an in-app redaction toggle.

---

### SEC-P2-003 — TOFU peer secret via WatchConnectivity application context

**Severity:** P2 (accepted architectural risk)  
**Area:** Peer secret lifecycle  
**Status:** DOCUMENTED / partially mitigated

Peer secrets bootstrap through WC `applicationContext` (encrypted by Apple between paired devices). Residual risk: backup extraction or compromised paired device could read last published context. Mitigations: publish-only-when-needed, no secret logging, `resetPeerTrust()`, fingerprint ≠ raw secret (SEC-NEG-09).

Reference: `Docs/WATCH_SYNC_SECURITY_THREAT_MODEL.md`.

---

### SEC-P2-004 — TestFlight allows simulation depth sensor selection

**Severity:** P2  
**Area:** Safety integrity / release hygiene  
**Status:** OPEN (by design for beta)

`DeveloperSettings.allowsSimulationSensorSelection` returns true for DEBUG and TestFlight (`sandboxReceipt`). App Store release builds disallow simulation selection. TestFlight testers can still run simulated depth — acceptable for internal beta but should be documented in TestFlight notes.

---

### SEC-P2-005 — UserDefaults pending sync / conflict payloads

**Severity:** P2  
**Area:** Data-at-rest  
**Status:** OPEN (low exploitability)

Pending dive sync sessions and conflict records may include GPS-enriched `DiveSession` JSON in UserDefaults without file protection. Mitigated by device encryption and no network exfiltration path in-app; jailbreak/backup extraction remains a concern.

---

### SEC-P3-001 — Legacy Keychain service naming (`dirmotion` prefixes)

**Severity:** P3  
**Area:** Maintainability  
**Status:** OPEN

Some iOS notification/key names retain legacy `dirmotion` strings. Does not break isolation (per-app Keychain) but complicates migration audits.

---

### SEC-P3-002 — Watch photo import content validation depth

**Severity:** P3  
**Area:** File import  
**Status:** PARTIAL

Filename sanitization and size caps present; decoded image bomb / malformed metadata handling relies on system decode failures. See `Docs/WATCH_PHOTO_IMPORT_SECURITY.md`.

---

### SEC-P3-003 — CSV import memory bound (user-picked)

**Severity:** P3  
**Area:** DoS resilience  
**Status:** MITIGATED

Import paths size-bound in current MAIN; extremely large user-picked files remain a UX/OOM edge case.

---

### SEC-P3-004 — Reply handler without HMAC on WC message replies

**Severity:** P3  
**Area:** WatchConnectivity  
**Status:** ACCEPTED

`sendMessage` reply handlers trust Apple pairing boundary; pending queue drain via forged reply requires companion compromise.

---

## Remediated / closed since prior audits

| Prior ID | Topic | Current state |
|----------|-------|---------------|
| F1 (2026-05-19) | `resetPeerTrust` missing on iOS | **FIXED** — present on both platforms |
| F2 | Watch/iOS `syncKey` drift | **FIXED** — unified v2 derivation on `main` |
| SEC-P1-001 (2026-06-04) | App Intents bypass legal gate | **FIXED** — `requireLegalAcceptanceForSafetyIntent` |
| SYNC-P1-002 | Cloud toggle implied Apnea/Snorkeling upload | **FIXED** — `CloudBackupCapability` diving-only |
| SYNC-P3-003 | No activity discriminator in envelope | **FIXED** — v3 `ActivitySyncSignedTransport` + routing guard |
| SYNC-P2 tombstones | Apnea/Snorkeling delete propagation | **FIXED** — tombstone codecs + WC keys (Command 8) |
| SYNC-P2 chunking | Oversized session rejection | **FIXED** — large-payload file transfer + 512KB fail-closed |

---

## Audit checklist (command scope)

| Area | Status | Evidence |
|------|--------|----------|
| WC authentication | **PASS** | `WatchSyncAuth`, HMAC derive, TOFU |
| Peer secret lifecycle | **PASS** | Keychain, context ingest, reset |
| HMAC / signature verify | **PASS** | Codecs + SEC-NEG-01 |
| Nonce / replay | **PASS** | `SyncNonceReplayCache`, SEC-NEG-02 |
| Signed ACK | **PASS** | Import ACK + plan package signer |
| Trust reset | **PASS** | `resetPeerTrust()` both platforms |
| Malformed payload rejection | **PASS** | Schema version, bundle ID, size caps |
| Path traversal (briefing/photos) | **PASS** | SEC-NEG-04…06 |
| File import/export protection | **PARTIAL** | `.completeFileProtection` on exports; Diving GPS not redacted |
| Image/card storage | **PASS** | Briefing + photo stores protected |
| Temporary files | **PASS** | Export tmp with protection + cleanup patterns |
| Cloud backup opt-in | **PASS** | Diving-only; Apnea/Snorkeling unavailable |
| GPS privacy | **PARTIAL** | Apnea/Snorkeling redaction; Diving CSV raw |
| Photo metadata | **PARTIAL** | Snorkeling privacy QA catalog SNK-QA-015 pending |
| Logs / diagnostics | **PASS** | `os.Logger`; no secret logging |
| App Intents | **PASS** | Legal gate on safety intents |
| Simulation release safety | **PARTIAL** | App Store blocked; TestFlight allowed |
| Deep links | **INFO** | No arbitrary URL scheme handlers in MAIN |
| Activity cross-routing | **PASS** | v3 envelope + cross-decode tests |
| Data deletion / tombstones | **PASS** | Multi-activity tombstone broadcast (Command 8) |
| Backup encryption assumptions | **PASS** | Apple iCloud KVS encryption; opt-in documented |
| Privacy manifests | **FAIL** | SEC-P1-001 |
| Least privilege entitlements | **PASS** | Motion/water submersion scoped correctly |
| Third-party dependencies | **INFO** | Swift stdlib/CryptoKit/Apple frameworks only in MAIN |

---

## Activity-specific risk summary

| Activity | Sensitive data | Isolation | Export privacy | Cloud |
|----------|----------------|-----------|----------------|-------|
| Diving | Depth profile, gas, tissue FC, GPS, planner | Separate codec/store/keys | CSV GPS exposed | Opt-in KVS |
| Apnea | Session timing, buddy notes, surface GPS | Separate codec/store/keys | Redaction policy | Local-only |
| Snorkeling | Route track, dips, photos | Separate codec/store/keys | Redaction policy | Local-only |

Wrong-activity exposure: guarded by payload keys + v3 `ActivitySyncRoutingGuard` + cross-decode rejection tests.

---

## Related artifacts

- [`THREAT_MODEL_CURRENT.md`](THREAT_MODEL_CURRENT.md)
- [`PRIVACY_DATA_FLOW_MATRIX_CURRENT.csv`](PRIVACY_DATA_FLOW_MATRIX_CURRENT.csv)
- [`SECURITY_REMEDIATION_PLAN_CURRENT.md`](SECURITY_REMEDIATION_PLAN_CURRENT.md)
- [`MAIN_SECURITY_NEGATIVE_TEST_MATRIX_CURRENT.csv`](MAIN_SECURITY_NEGATIVE_TEST_MATRIX_CURRENT.csv)
- [`MAIN_PRIVACY_FILE_PROTECTION_MATRIX_CURRENT.csv`](MAIN_PRIVACY_FILE_PROTECTION_MATRIX_CURRENT.csv)
- [`WATCH_SYNC_SECURITY_THREAT_MODEL.md`](WATCH_SYNC_SECURITY_THREAT_MODEL.md)

---

## Verdict

**CONDITIONAL PASS** for static software security readiness at **83/100**. No P0 exploitable remote path identified. **SEC-P1-001 (Privacy Manifest)** is the primary release blocker for App Store submission. Physical QA and Diving export GPS policy remain open P2 items before broad public distribution.
