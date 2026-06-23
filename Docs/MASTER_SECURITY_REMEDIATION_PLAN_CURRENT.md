# Master Security Remediation Plan (Current)

**Audit command:** 04 — MASTER MAIN CODE / SYNC / SECURITY / PERFORMANCE AUDIT V1.0  
**Branch:** `main` @ `1f62235`  
**Date:** 2026-06-22

---

## Executive summary

All **software-verifiable** security findings from merged audits (Commands 5, 8, 9) are **closed** at this baseline. Remaining work is **field QA** and **documented accepted architectural risks** — not code defects.

| Severity | Open (software) | Pending physical | Documented accepted |
|----------|-----------------|------------------|---------------------|
| P0 | 0 | 0 | 0 |
| P1 | 0 | 0 | 0 |
| P2 | 0 | 2 | 1 |
| P3 | 0 | 0 | 1 |

---

## Closed findings (verified at 1f62235)

| ID | Topic | Status | Evidence |
|----|-------|--------|----------|
| SEC-P1-001 | Privacy manifests | FIXED | PrivacyInfo-Watch/iOS.xcprivacy |
| SEC-P2-002 | Diving GPS export default | FIXED | DivingExportPrivacyPolicy |
| SEC-P2-004 | Simulation release safety | FIXED | TestFlightSimulationSafetyPolicy |
| SEC-P2-005 | Protected sync queues | FIXED | ProtectedSensitiveFileStore |
| SEC-P3-001..004 | Keychain, photo, CSV, reply handler | FIXED/VERIFIED | SecurityPrivacyTrustRemediationTests |
| SYNC-P1-001 | Activity tombstones | FIXED | ActivitySyncTombstoneBroadcast |
| SYNC-P1-002 | Cloud backup scope | FIXED | CloudBackupCapability |
| SYNC-P2-001 | Cross-decode tests | FIXED | ActivitySyncCrossDecodeRejectionTests |

---

## Open / pending items

### MASTER-SEC-001 (P2) — Field two-device sync QA

**Status:** PENDING_PHYSICAL  
**Remediation:** Execute `MASTER_PHYSICAL_PERFORMANCE_QA_PLAN` scenarios PHYS-PAIR-01..06 + SEC-NEG field matrix.  
**Acceptance:** Signed tombstone + HMAC + large-payload verified on paired hardware.  
**Owner:** QA / Product  
**Blocks:** External TestFlight confidence (not internal software gate)

### MASTER-SYNC-001 (P2) — Large payload file transfer field QA

**Status:** PENDING_PHYSICAL  
**Remediation:** PHYS-PAIR-03 with >512KB session on paired devices.  
**Acceptance:** File-transfer package round-trip with signed ACK.

### MASTER-SEC-002 (P3) — TOFU peer secret via applicationContext

**Status:** DOCUMENTED_ACCEPTED_RISK  
**Remediation:** Maintain bootstrap TTL/epoch; document in release notes; no bypass.  
**Acceptance:** SEC-NEG-14 continues PASS; threat model updated.

---

## Recommended future commands

1. **Physical paired-device security QA command** — execute SEC-NEG field matrix only (read-only evidence capture).
2. **App Store privacy pre-submission review** — human review of manifests and export dialogs.

---

## Validation gates (existing)

- `./Scripts/validate_security_privacy_trust_readiness.sh` — software PASS at prior baselines
- `./Scripts/validate_multi_activity_sync_persistence_schema_readiness.sh` — sync PASS

Re-run on remediation branches after any security-impacting change.

---

**No production code changes recommended** from this audit pass.
