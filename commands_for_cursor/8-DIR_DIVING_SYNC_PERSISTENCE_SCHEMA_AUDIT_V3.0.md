# 8-DIR_DIVING_SYNC_PERSISTENCE_SCHEMA_AUDIT_V3.0

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

Audit all Watch ↔ iOS sync, persistence, schema versioning, migration, backup and restore for Diving, Apnea and Snorkeling.

# SCOPE

Audit:

- shared transport envelope;
- activity discriminator;
- separate codecs;
- separate stores;
- revision/checksum;
- HMAC/peer trust;
- ACK/retry/idempotency;
- payload chunking;
- large profile transfer;
- out-of-order delivery;
- tombstones;
- conflict resolution;
- corrupt/future schema;
- legacy Diving migration;
- Full Computer tissue checkpoints;
- Apnea session with multiple dives;
- Snorkeling surface track + dips;
- Settings payload namespaces;
- plan/card/photo payload route separation;
- backup/restore isolation.

Mandatory route checks:

```text
Diving payload → Diving store only
Apnea payload → Apnea store only
Snorkeling payload → Snorkeling store only
```

Reject all cross-decoding.

# OUTPUT

Create:

- `Docs/MULTI_ACTIVITY_SYNC_PERSISTENCE_SCHEMA_AUDIT_CURRENT.md`
- `Docs/SYNC_MESSAGE_NAMESPACE_MATRIX_CURRENT.csv`
- `Docs/SCHEMA_MIGRATION_COMPATIBILITY_MATRIX_CURRENT.csv`
- `Docs/BACKUP_RESTORE_ISOLATION_MATRIX_CURRENT.csv`

Provide 0–100 readiness and P0–P3 findings.
