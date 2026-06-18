# Snorkeling Persistence & Recovery Contract (Command 07)

**Status:** **Implemented**  
**Date:** 2026-06-18  
**Scope:** Disk persistence and relaunch recovery for `SnorkelingSessionEngine` + Watch logbook  
**Report:** [`DIR_DIVING_SNORKELING_PERSISTENCE_RECOVERY_LOGBOOK_IMPLEMENTATION_REPORT_CURRENT.md`](DIR_DIVING_SNORKELING_PERSISTENCE_RECOVERY_LOGBOOK_IMPLEMENTATION_REPORT_CURRENT.md)

---

## Implemented

- Versioned envelope namespace `dirdiving_snorkeling_session`
- SHA-256 checksum over canonical checkpoint payload
- Atomic write with previous-checkpoint retention
- Corruption quarantine (no silent reset)
- Relaunch restore in `SnorkelingWatchRuntimeStore`
- Recovered-session UI banner
- Dedicated `SnorkelingLogbookStore` with retention policy

---

## Gate

Command 07 complete — automated tests verify atomic write, checksum, quarantine, migration tolerance, relaunch restore, and logbook persistence.
