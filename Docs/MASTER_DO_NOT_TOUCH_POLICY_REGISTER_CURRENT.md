# Do-Not-Touch Policy Register — CURRENT

**Baseline:** `main` @ `7ae527b`  
**Orchestrator:** V1.7 @ 2026-07-02

---

## Hard rules

1. Do not change Buhlmann constants without independent reference and tests.
2. Do not change Schreiner equation without oracle vectors.
3. Do not change live Watch Full Computer timing without actual-dt tests.
4. Do not let Planner cards mutate live Watch runtime state.
5. Do not merge Gauge and Full Computer semantics.
6. Do not show Gauge TTV as Full Computer TTS.
7. Do not show CCR reference data as live CCR controller authority.
8. Do not route Apnea/Snorkeling data into Diving stores.
9. Do not create a mixed global logbook as default activity logbook.
10. Do not weaken HMAC replay and payload safety for convenience.
11. Do not claim physical QA from simulator evidence.
12. Do not claim external validation from internal tests only.
13. Do not claim certification without signed external evidence.
14. Do not update release docs before verified technical state.
15. Do not mark pending physical gates as software-closed.
16. Do not mark software-ready as physically-validated.
17. Do not run 07/10/11/12 from orchestrator 00.
18. Do not close DG-EXT-001 without third-party Buhlmann evidence.
19. Do not reopen verified demo logbook fix (`f90b671`) without evidence.
20. Do not overstate Snorkeling remediation completion while manual QA is pending.

---

## Early remediation forbidden areas

| Area | Forbidden early change | Reason |
|---|---|---|
| `Shared/BuhlmannCore/*` | constants and algorithm timing edits | highest safety priority |
| sync security transport | ACK/HMAC relaxation | trust/integrity protection |
| activity ownership routes | cross-activity merges | architecture isolation policy |
| release claims docs | optimistic readiness language | truthfulness gate |
| command boundary docs | enabling 07/10/11/12 from orchestrator 00 | policy violation |

---

## Protected verified artifacts

- Snorkeling software remediation consumed at `7c459cb`.
- Demo logbook contamination fix verified at `f90b671`.
- Consolidation baseline for this run is `7ae527b`.
