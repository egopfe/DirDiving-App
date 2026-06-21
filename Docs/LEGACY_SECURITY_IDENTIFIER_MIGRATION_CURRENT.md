# Legacy Security Identifier Migration (Current)

**Command:** 10 remediation  
**Date:** 2026-06-20  
**Finding:** SEC-P3-001 — **FIXED**

---

## Registry

`Shared/Utils/LegacySecurityIdentifierMigration.swift`

---

## Keychain services

| Legacy (`dirmotion`) | Canonical (`dirdiving`) |
|----------------------|-------------------------|
| `com.egopfe.dirmotion.watch-sync` | `com.egopfe.dirdiving.watch-sync` |

Peer sync secrets use canonical service on write; legacy entries read for migration where applicable.

---

## UserDefaults keys

| Legacy | Canonical |
|--------|-----------|
| `dirmotion_ascent_rate_limits` | `dirdiving_ascent_rate_limits` |

---

## Migration version

| Key | Value |
|-----|-------|
| `dirdiving_legacy_security_identifier_migration_v1` | `1` when complete |

`markCompletedIfNeeded()` records completion without destructive rename of in-use legacy values until read paths migrate.

---

## Scope

Identifier hygiene only — does not change Keychain isolation (per-app) or sync cryptography.

---

## Validation

`testLegacySecurityIdentifierMigrationRegistry` — SEC-NEG-18
