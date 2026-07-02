# Finding Dependency Graph — CURRENT

**Baseline:** `main` @ `7ae527b`  
**Orchestrator:** V1.7 @ 2026-07-02

---

## Critical dependencies

- `CF-002` must be fixed before `CF-007` can be fully validated because localization parity failures currently break regression confidence in Snorkeling release readiness.
- `CF-008` and `CF-009` must be fixed before `CF-011` can close because release claims and readiness language cannot be trusted while docs are stale or unsupported.
- `CF-001` must be fixed before `CF-011` can close because external/App Store decompression claims depend on independent Buhlmann validation.
- `CF-003` and `CF-004` must be fixed before `CF-011` can close because physical/manual QA evidence is a hard gate for external readiness claims.
- `CF-006` must be fixed before `CF-012` can close because command inventory integrity is required for clean post-remediation lifecycle governance.
- `CF-005` is verified and supports `CF-010`; however `CF-010` still requires manual QA completion before unified-logbook truthfulness can be considered fully closed.

---

## Mermaid graph

```mermaid
graph TD
  CF002[CF-002 DG-LOC-001 localization parity] --> CF007[CF-007 rollback gate]
  CF008[CF-008 stale INDEX/README] --> CF011[CF-011 external and App Store not ready]
  CF009[CF-009 unsupported CCR claim doc] --> CF011
  CF001[CF-001 DG-EXT-001 external Buhlmann validation] --> CF011
  CF003[CF-003 DG-PHY-001 physical QA backlog] --> CF011
  CF004[CF-004 DG-SNORK-001 snorkeling field QA pending] --> CF011

  CF006[CF-006 DG-CMD-001 command chain gap] --> CF012[CF-012 manual continuation required]

  CF005[CF-005 DG-DEMO-001 demo fix verified] --> CF010[CF-010 unified logbook manual QA pending]
```

---

## Batch ordering constraints

| Finding cluster | Must fix before | Because |
|---|---|---|
| `DG-LOC-001` (`CF-002`) | Internal TestFlight confidence uplift | current test parity failures |
| `DG-DOC-001` + `DG-DOC-002` (`CF-008`,`CF-009`) | any release-claim refresh | truthfulness/legal baseline |
| `DG-EXT-001` (`CF-001`) | external TestFlight and App Store claims | independent validation missing |
| `DG-PHY-001` + `DG-SNORK-001` (`CF-003`,`CF-004`) | external readiness | physical/manual evidence absent |
| `DG-CMD-001` (`CF-006`,`CF-012`) | post-remediation lifecycle continuity | missing command path integrity |

---

## Non-dependencies (keep separate)

- `CF-005` is already verified (`f90b671`) and should not be reopened while unrelated physical QA work proceeds.
- `CF-014` (docs alignment debt) should not block Batch-1 quick wins.
