# Security External QA Pending (Current)

**Date:** 2026-06-20  
**Software readiness:** 100% (all software-verifiable findings closed)  
**External evidence:** Not fabricated

---

## Pending physical / paired-device QA

| Gate | Finding | Status | Notes |
|------|---------|--------|-------|
| v3 envelope round-trip (all activities) | SEC-P2-001 | **PENDING** | Codecs tested; no paired hardware run |
| Tombstone propagation after delete | SEC-P2-001 | **PENDING** | Tombstone codecs PASS in XCTest |
| Large payload (>512 KB) file transfer | SEC-P2-001 | **PENDING** | Hash verification tested statically |
| Trust reset both sides | SEC-P2-001 | **PENDING** | `resetPeerTrust()` present; field not re-run |
| Offline pending queue drain | SEC-P2-005 | **PENDING** | Protected file store migrated; replay on device open |
| WC context bootstrap under cold start | SEC-P2-003 | **PENDING** | Bootstrap policy unit-tested |

---

## Pending external / compliance QA

| Gate | Status | Notes |
|------|--------|-------|
| Penetration test | **PENDING** | Not in scope of static remediation |
| App Store privacy review | **PENDING** | Manifests ship; Apple approval external |
| GDPR / legal privacy review | **PENDING** | Engineering docs only |
| Lost device / theft field QA | **PENDING** | Data Protection assumptions documented |

---

## Explicit non-claims

- No App Store security GO
- No certified dive-computer compliance
- No penetration-test clearance

Software validation: `./Scripts/validate_security_privacy_trust_readiness.sh` — **PASS**
