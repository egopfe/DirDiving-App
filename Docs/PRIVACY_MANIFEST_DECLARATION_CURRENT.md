# Privacy Manifest Declaration (Current)

**Command:** 10 remediation  
**Date:** 2026-06-20  
**Branch:** `main`  
**Finding:** SEC-P1-001 — **FIXED**

---

## Artifacts

| Target | Path |
|--------|------|
| DIRDiving Watch App | `Config/PrivacyInfo-Watch.xcprivacy` |
| DIRDiving iOS | `iOSApp/Config/PrivacyInfo-iOS.xcprivacy` |

Both manifests are wired in `project.yml` resource build phases.

---

## Tracking

| Key | Value |
|-----|-------|
| `NSPrivacyTracking` | `false` |
| `NSPrivacyTrackingDomains` | empty |

No ATT SDKs or third-party analytics in MAIN targets.

---

## Collected data types

| Type | Linked | Tracking | Purpose |
|------|--------|----------|---------|
| Fitness (dive logs, depth profiles) | No | No | App functionality |
| Precise location (session GPS) | No | No | App functionality |
| Photos or videos (iOS only) | No | No | App functionality |

Data stays on-device except optional user-initiated export/share and opt-in Diving iCloud KVS backup.

---

## Required Reason APIs

| API category | Apple reason | Usage |
|--------------|--------------|-------|
| UserDefaults (`NSPrivacyAccessedAPICategoryUserDefaults`) | CA92.1 | App functionality preferences, non-tracking flags |
| File timestamp (`NSPrivacyAccessedAPICategoryFileTimestamp`) | C617.1 | Logbook file ordering and export staging |
| System boot time (`NSPrivacyAccessedAPICategorySystemBootTime`) | 35F9.1 | Nonce/replay skew and session timing |

---

## App Store alignment

Engineering declarations align with:

- [`PRIVACY_DATA_FLOW_MATRIX_CURRENT.csv`](PRIVACY_DATA_FLOW_MATRIX_CURRENT.csv)
- Info.plist usage descriptions (location, photos, motion)
- Diving-only cloud backup opt-in (`CloudBackupCapability`)

**External gate:** App Store Connect privacy report preview and Apple review — **PENDING**.

---

## Validation

| Test | Matrix ID |
|------|-----------|
| `testPrivacyManifestIOSExistsAndDeclaresNoTracking` | SEC-NEG-11 |
| `testPrivacyManifestWatchExistsAndDeclaresNoTracking` | SEC-NEG-12 |

Script: `./Scripts/validate_security_privacy_trust_readiness.sh`
