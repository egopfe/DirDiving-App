# DIR DIVING — Security Remediation Plan (Current)

**Command:** 9 — Security/Privacy/Trust Audit V3.0  
**Date:** 2026-06-17  
**Branch:** `main`  
**Baseline audit:** [`SECURITY_PRIVACY_TRUST_AUDIT_CURRENT.md`](SECURITY_PRIVACY_TRUST_AUDIT_CURRENT.md)  
**Overall static readiness:** 83/100  
**Open P0:** 0 | **Open P1:** 1 | **Open P2:** 5 | **Open P3:** 4

This plan prioritizes remaining findings. It is not a penetration-test report or compliance certification.

---

## Severity model

| Level | Definition |
|-------|------------|
| P0 | Active exploitable remote vulnerability or critical safety bypass — ship stop |
| P1 | App Store / privacy release blocker |
| P2 | Important hardening before broad public testing |
| P3 | Lower-risk hygiene and maintainability |

---

## P1 — Release blockers

### REM-P1-001 — Add Apple Privacy Manifests (Watch + iOS)

**Finding:** SEC-P1-001  
**Owner:** iOS/Watch platform  
**Effort:** Small (1–2 days)

**Actions:**

1. Create `PrivacyInfo.xcprivacy` for **DIRDiving Watch App** and **DIRDiving iOS** targets.
2. Declare `NSPrivacyTracking` = false.
3. List collected data types aligned with App Store privacy labels: fitness/dive logs, location (session GPS), photos (snorkeling reference), user content (notes), not used for tracking.
4. Document **Required Reason APIs** actually used (e.g. UserDefaults access, file timestamp APIs if applicable) with Apple reason codes.
5. Wire manifests in `project.yml` / XcodeGen resource phases.
6. Validate with App Store Connect privacy report preview before submission.

**Acceptance criteria:**

- Both MAIN targets include valid manifests; build succeeds.
- No undeclared required-reason API warnings in Xcode 15+ analyze step.
- Privacy label questionnaire answers match manifest + [`PRIVACY_DATA_FLOW_MATRIX_CURRENT.csv`](PRIVACY_DATA_FLOW_MATRIX_CURRENT.csv).

---

## P2 — Pre–broad public testing

### REM-P2-001 — Physical two-device sync QA matrix

**Finding:** SEC-P2-001  
**Owner:** QA  
**Effort:** Medium (field session)

Execute on paired Watch + iPhone:

| Case | Pass criteria |
|------|---------------|
| v3 envelope round-trip (all three activities) | Sessions appear on companion with matching IDs |
| Delete tombstone propagation | Deleted session does not resurrect after re-sync |
| Large payload (>512KB profile) | File transfer fallback succeeds; hash verified |
| Trust reset both sides | Re-pair succeeds; no mismatch loop |
| Offline queue drain | Pending sessions import after reconnect |

Record results in `Docs/MAIN_EXTERNAL_QA_PENDING_CURRENT.md` or successor evidence doc.

---

### REM-P2-002 — Diving export GPS redaction parity

**Finding:** SEC-P2-002  
**Owner:** iOS + Watch  
**Effort:** Small–medium

**Actions:**

1. Introduce `DivingExportPrivacyOptions` mirroring Apnea/Snorkeling (default: redact or round coordinates).
2. Apply in `SubsurfaceExportService` (Watch + iOS) before CSV write.
3. Settings or export sheet toggle: "Include exact GPS" (default off for share sheet).
4. Add unit tests for redacted vs exact modes.

**Acceptance criteria:**

- Default export omits or rounds GPS unless user explicitly opts in.
- Subsurface round-trip QA doc updated.

---

### REM-P2-003 — Document TOFU / peer-secret residual risk

**Finding:** SEC-P2-003  
**Owner:** Docs  
**Effort:** Small

**Actions:**

1. Keep [`WATCH_SYNC_SECURITY_THREAT_MODEL.md`](WATCH_SYNC_SECURITY_THREAT_MODEL.md) aligned with v3 envelope.
2. Add user-facing More → Sync help: when to reset trust, what data is not sent to servers.
3. Optional: rotate local secret on `resetPeerTrust()` (evaluate UX impact).

**Acceptance criteria:**

- Support copy exists EN/IT; no secret material in UI.

---

### REM-P2-004 — TestFlight simulation policy

**Finding:** SEC-P2-004  
**Owner:** Release management  
**Effort:** Small

**Actions:**

1. Document in TestFlight release notes: simulation depth available; not for real diving.
2. Consider gating simulation behind explicit beta acknowledgment toggle.
3. Confirm App Store archive build disables `allowsSimulationSensorSelection` (existing `#if` + receipt check).

**Acceptance criteria:**

- App Store build: simulation not selectable (existing tests pass).
- TestFlight notes published per build.

---

### REM-P2-005 — Migrate pending sync/conflict off plain UserDefaults

**Finding:** SEC-P2-005  
**Owner:** Sync team  
**Effort:** Medium

**Actions:**

1. Move `dirdiving_watch_pending_sync_sessions` and iOS conflict payloads to protected Application Support files (same pattern as logbooks).
2. Strip GPS from pending queue if full session not required for retry (store session ID + revision only where possible).
3. Add migration on first launch; test FIFO cap behavior preserved.

**Acceptance criteria:**

- No full `DiveSession` JSON with GPS in UserDefaults after migration.
- Pending queue replay tests green.

---

## P3 — Hardening backlog

### REM-P3-001 — Legacy `dirmotion` Keychain/notification rename

**Finding:** SEC-P3-001  
**Effort:** Small  
Migrate with backward-compatible read of old Keychain entries if any users affected.

### REM-P3-002 — Watch photo decode hardening

**Finding:** SEC-P3-002  
**Effort:** Small  
Cap decoded pixel dimensions; reject non-image magic bytes before write.

### REM-P3-003 — CSV import streaming / size ceiling UX

**Finding:** SEC-P3-003  
**Effort:** Small  
User-visible error when import exceeds cap; avoid silent OOM.

### REM-P3-004 — WC reply handler hardening (optional)

**Finding:** SEC-P3-004  
**Effort:** Medium  
Include signed ack token in reply payload for pending queue drain (defense in depth).

---

## Closed / delivered in Command 8 (same release pass)

| ID | Item | Evidence |
|----|------|----------|
| CLOSED | Multi-activity signed envelope v3 | `ActivitySyncSignedTransport`, routing guard |
| CLOSED | Apnea/Snorkeling tombstones | `ActivitySyncTombstone*`, WC keys |
| CLOSED | Cloud backup diving-only truthfulness | `CloudBackupCapability`, SEC-NEG-07/08 |
| CLOSED | Large payload transfer + 512KB fail-closed | `ActivitySyncLargePayloadTransfer` |
| CLOSED | Cross-decode rejection tests | `ActivitySyncCrossDecodeRejection*Tests` |

---

## Suggested execution order

```text
1. REM-P1-001  Privacy manifests          ← App Store blocker
2. REM-P2-001  Physical QA                ← field validation
3. REM-P2-002  Diving GPS export          ← privacy parity
4. REM-P2-005  UserDefaults migration     ← data-at-rest
5. REM-P2-004  TestFlight documentation   ← release hygiene
6. REM-P3-*    Backlog as capacity allows
```

---

## Validation gates

| Gate | Script / matrix |
|------|-----------------|
| Security negative | `./Scripts/validate_main_deep_code_readiness.sh` + SEC-NEG matrix |
| Multi-activity sync | `./Scripts/validate_multi_activity_sync_persistence_schema_readiness.sh` |
| Privacy file protection | `MAIN_PRIVACY_FILE_PROTECTION_MATRIX_CURRENT.csv` |

Re-run full validation after each P1/P2 software remediation PR.

---

## Traceability

| Plan ID | Audit finding | Threat model section |
|---------|---------------|----------------------|
| REM-P1-001 | SEC-P1-001 | §8 Privacy surface |
| REM-P2-001 | SEC-P2-001 | §6 WC sync |
| REM-P2-002 | SEC-P2-002 | §7.4 Export |
| REM-P2-003 | SEC-P2-003 | §6.1 Authentication |
| REM-P2-004 | SEC-P2-004 | §3 Trust boundaries |
| REM-P2-005 | SEC-P2-005 | §7.1 At rest |
