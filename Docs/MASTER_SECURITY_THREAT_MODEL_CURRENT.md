# DIR DIVING — Master Security Threat Model (Current)

**Audit command:** 04 — MASTER MAIN CODE / SYNC / SECURITY / PERFORMANCE AUDIT V1.0  
**Date:** 2026-06-22  
**Branch:** `main` @ `1f62235`  
**Scope:** Watch + iOS MAIN targets (Diving, Apnea, Snorkeling)

**Not claimed:** Penetration testing, App Store privacy approval, GDPR/HIPAA certification, physical device compromise QA.

---

## 1. System context

DIR DIVING is a **local-first** multi-activity dive companion:

- **Watch:** In-water runtime (Gauge, Full Computer), Apnea, Snorkeling; depth/GPS sensors; WatchConnectivity to iPhone.
- **iOS:** Planner, logbooks, settings, import/export, iCloud KVS (Diving opt-in only).
- **Trust boundary:** Paired Watch ↔ iPhone via WatchConnectivity (Apple-encrypted transport); no arbitrary network client.

```text
[User] → [Watch App] ←WC HMAC→ [iOS Companion] → [Local JSON / KVS / Exports]
                ↓                              ↓
         Depth/GPS sensors              File picker / Share sheet
```

---

## 2. Assets

| Asset | Sensitivity | Storage |
|-------|-------------|---------|
| Dive profiles / tissue checkpoints | Safety-critical | Protected Application Support |
| Apnea session / recovery data | Health-like | Activity-scoped logbooks |
| Snorkeling GPS tracks / photos | Location + PII | Activity-scoped; export policies |
| Peer sync secret | Cryptographic | Keychain + WC applicationContext (TOFU) |
| Planner briefing cards | Reference metadata | Sandboxed briefing store |
| User photos (companion) | PII | UserImageStore; validated import |
| Pending sync queues | Session payloads | ProtectedSensitiveFileStore |

---

## 3. Threat actors

| Actor | Capability | Relevance |
|-------|------------|-----------|
| Malicious paired app (wrong bundle) | WC messages | Mitigated: bundle ID + HMAC + TOFU pinning |
| Replay attacker on WC | Resend signed payloads | Mitigated: nonce replay cache + skew window |
| Local file attacker | Read/write app container | Mitigated: `.completeFileProtection`; path sanitization |
| User (CSV/import) | Pick malicious files | Mitigated: size caps, magic bytes, row limits |
| Backup extractor | iCloud/device backup | Residual: TOFU secret in WC context (documented) |
| App Intent caller | Start dive without consent | Mitigated: legal acceptance gate |

---

## 4. Attack surfaces

### 4.1 WatchConnectivity

- **Controls:** HMAC-SHA256 v3 envelope (`activityType`, `messageType` in signed body); constant-time compare; signed import ACK; reply handler policy (transport hints do not dequeue).
- **Residual:** TOFU bootstrap via `applicationContext` — `WatchSyncTrustBootstrapPolicy` TTL/epoch; documented in `MASTER-SEC-002`.
- **Tests:** SEC-NEG-01..20; `ActivitySyncCrossDecodeRejectionTests`; `ActivitySyncTombstoneTests`.

### 4.2 File import/export

- **Controls:** `DiveCSVImportBounds` (10 MB, row cap); `DivingExportPrivacyPolicy` (GPS omit default); temp files with file protection; Subsurface fidelity tests.
- **Tests:** SEC-NEG-13, SEC-NEG-16; `SecurityPrivacyTrustRemediationTests`.

### 4.3 Briefing cards / photos

- **Controls:** `PlannerBriefingFilenameSanitizer`; atomic card swap; `WatchCompanionPhotoValidator` (magic bytes, 16 MP cap, JPEG re-encode).
- **Tests:** `PlannerBriefingCardStoreTests`; `CompanionPhotoImportSupportTests`.

### 4.4 Cloud backup

- **Controls:** Diving-only opt-in (`CloudBackupCapability`); Apnea/Snorkeling explicitly unavailable; KVS budget policy; legacy migration.
- **Tests:** `CloudBackupCapabilityTests`; `CloudSyncBudgetPolicy` tests.

### 4.5 App Intents / simulation

- **Controls:** `requireLegalAcceptanceForSafetyIntent()`; `TestFlightSimulationSafetyPolicy`; App Store blocks simulation depth source.
- **Tests:** `SecurityPrivacyTrustRemediationTests`.

---

## 5. Activity isolation threats

| Threat | Impact | Control | Status |
|--------|--------|---------|--------|
| Dive payload → Apnea store | P0 data corruption | Distinct payload keys + envelope activity guard | **PASS** |
| Apnea settings → Diving runtime | P0 wrong thresholds | ActivitySettingsVisibility | **PASS** |
| Briefing card mutates live FC | P0 wrong deco state | Reference-only store; no DiveManager write | **PASS** |
| Cross-activity logbook merge | P1 wrong history | Separate filenames + isolation tests | **PASS** |

---

## 6. STRIDE summary

| Category | Primary risks | Mitigation status |
|----------|---------------|-------------------|
| Spoofing | Forged WC peer | HMAC + bundle ID + TOFU | **PASS** (static) |
| Tampering | Payload modification | HMAC verify; signed tombstones | **PASS** |
| Repudiation | N/A local app | Signed ACK symmetry | **PASS** |
| Information disclosure | GPS in export; backup | Export policies; file protection | **PASS** |
| Denial of service | Huge CSV/sync payload | Size caps; fail-closed; large-payload file transfer | **PASS** (software) |
| Elevation | App Intent bypass | Legal gate | **PASS** |

---

## 7. Pending field validation

| ID | Threat path | Status |
|----|-------------|--------|
| MASTER-SEC-001 | End-to-end paired tombstone + large-payload + replay | **PENDING_PHYSICAL** |
| MASTER-SYNC-001 | 5 MB file-transfer round-trip on hardware | **PENDING_PHYSICAL** |

---

## 8. Privacy manifest

Both MAIN targets include `PrivacyInfo.xcprivacy` (no tracking; required-reason APIs declared). See `PRIVACY_MANIFEST_DECLARATION_CURRENT.md`.

---

**Threat model audit completed:** 2026-06-22 on `main` @ `1f62235`.
