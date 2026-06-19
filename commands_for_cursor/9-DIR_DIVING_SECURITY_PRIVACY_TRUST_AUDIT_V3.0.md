# 9-DIR_DIVING_SECURITY_PRIVACY_TRUST_AUDIT_V3.0

**Command version:** 3.0  
**Updated for MAIN:** 2026-06-19  
**Repository:** `egopfe/DirDiving-App`  
**Required branch:** `main`  
**Task type:** audit-only

## ABSOLUTE EXECUTION RULE

This is a read-only audit. Do not modify production code, tests, project configuration, assets, mockups, localization resources or runtime documentation. Generate only the requested audit reports. Do not commit or push.

Run preflight:

```bash
git branch --show-current
git rev-parse --short HEAD
git status
git fetch origin
git status -sb
```

STOP if the branch is not `main`. Record environmental limitations. Do not fix failures.


# OBJECTIVE

Perform a vertical security/privacy audit of the complete professional product.

# SCOPE

Audit:

- WatchConnectivity authentication;
- peer secret lifecycle;
- HMAC;
- nonce/replay;
- signed ACK;
- trust reset;
- malformed payload rejection;
- path traversal;
- file import/export;
- image/card storage;
- temporary files;
- cloud backup opt-in;
- GPS privacy;
- photo metadata;
- exact-coordinate redaction;
- logs and diagnostics;
- sensitive equipment/gas data;
- App Intents;
- feature flags/developer mode;
- simulation release safety;
- deep links;
- activity cross-routing;
- data deletion;
- backup encryption assumptions;
- privacy manifests and usage descriptions;
- least privilege;
- third-party dependencies.

Activity-specific risks:

- Diving plan/gas/tissue data;
- Apnea session/health-like data;
- Snorkeling location routes/photos;
- wrong activity data exposure.

# OUTPUT

Create:

- `Docs/SECURITY_PRIVACY_TRUST_AUDIT_CURRENT.md`
- `Docs/THREAT_MODEL_CURRENT.md`
- `Docs/PRIVACY_DATA_FLOW_MATRIX_CURRENT.csv`
- `Docs/SECURITY_REMEDIATION_PLAN_CURRENT.md`

Do not claim penetration testing or compliance certification without evidence.
