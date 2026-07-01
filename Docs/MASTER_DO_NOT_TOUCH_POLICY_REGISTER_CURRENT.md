# Do-Not-Touch Policy Register — CURRENT

**Baseline:** `main` @ `2c30412`  
**Orchestrator:** V1.5 @ 2026-07-01

---

## Hard rules (non-regressive)

1. **Do not change Bühlmann constants** without independent reference and oracle tests.
2. **Do not change Schreiner equation** without oracle vectors (`Audit15*`, `SCHREINER_TEST_VECTOR_MATRIX`).
3. **Do not change live Watch Full Computer timing** without actual-dt tests (`FullComputerTimingFaultTests`).
4. **Do not let Planner briefing cards mutate live Watch state** — reference-only payload routing.
5. **Do not merge Gauge and Full Computer semantics** — no NDL/TTS/ceiling on Gauge.
6. **Do not show Gauge TTV as Full Computer TTS.**
7. **Do not show CCR reference data as live CCR controller data.**
8. **Do not route Apnea/Snorkeling data into Diving stores** — strict activity discriminators.
9. **Do not create a global mixed Logbook** as normal activity Logbook.
10. **Do not weaken HMAC/replay/security** for performance or convenience.
11. **Do not claim physical QA from simulator** evidence.
12. **Do not claim external validation from self-tests** or internal oracle only.
13. **Do not claim certification** without signed external evidence.
14. **Do not update release docs before technical state is known** (INDEX/README after audits).
15. **Do not embed decompression/GF/gas/MOD/PPO2 in Apnea** — Apnea first-class isolation.
16. **Do not claim Apnea auto-detection or WAO starts Apnea session** without physical evidence.
17. **Do not claim water auto-open starts a dive** — routing to predive/ready only.
18. **Do not downgrade physical pending gates into software issues** — preserve `SOFTWARE_READY` vs `PENDING_PHYSICAL`.
19. **Do not upgrade software readiness into physical validation.**
20. **Do not modify sync schemas or persistence** without migration tests and namespace matrix review.
21. **Do not change Gradient Factor preset triplets** without iOS↔Watch interop tests (`CONS-002` regression).
22. **Do not remove developer shallow-depth toggles default-OFF** without release gate script review.
23. **Do not change `resolveAutomaticStep` routing** without rerunning WAO tests and audits 01/03/04/05.
24. **Do not execute Command 07 or 10/11** from orchestrator 00 — remediation is a separate launch.
25. **Do not close WFC-P1-001** without third-party Bühlmann evidence in `QA_EVIDENCE/BUHLMANN_EXTERNAL/`.
26. **Do not mark Watch test suite green** while WFC-P2-005 has 13 routing failures (unless tests aligned to intentional policy).
27. **Do not touch `commands_for_cursor/OOLD/`** bodies when fixing integrity — update script paths only.
28. **Do not force-push `main`** during remediation batches.

---

## Early remediation forbidden areas

Until Batch-6 WAO test alignment and Batch-8 physical scaffolding are planned:

| Area | Forbidden early change | Reason |
|------|------------------------|--------|
| `Shared/BuhlmannCore/*` | GF/tissue/timing tweaks for UI polish | Algorithmic safety priority |
| `FullComputerRuntimeEngine` | Performance shortcuts | Live FC authority |
| `ActivitySyncSignedTransport` | ACK/HMAC relaxation | Data integrity |
| Apnea/Diving payload keys | Namespace merge | Activity isolation |
| `Docs/INDEX.md` release claims | SOFTWARE_READY 100% | Contradicts PARTIAL audits |

---

## Protected remediations already verified @ 2c30412

Do not regress without full audit rerun 01+03+04+05:

- CONS-002 GF preset iOS↔Watch parity
- CONS-003/004/005 sync ACK and tombstone HMAC
- CONS-006/007 shallow depth capability gating
- CONS-019 WAO FC DepthCapabilityPolicy gate
- CONS-027 PlannerStore deinit cancellation
- CONS-046 V1.5 command integrity script
- CONS-049 / IOS-P1-001 iOS test lane (1655 PASS)
