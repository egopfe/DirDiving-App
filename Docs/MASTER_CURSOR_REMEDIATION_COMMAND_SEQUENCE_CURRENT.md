# Cursor / Codex Remediation Command Sequence — CURRENT

**Baseline:** `main` @ `2c30412`  
**Orchestrator:** V1.5 — planning only; **does not launch Command 10/11**

---

## Recommended sequence

| Command | Name | Purpose | Input findings | Allowed files | Forbidden | Audits to rerun |
|---------|------|---------|----------------|---------------|-----------|-----------------|
| **R01** | Baseline and test-gate hardening | Lock clean main; verify gates G-001..G-009 | Batch-0 | Scripts/; CI configs | Production algorithms | 05 |
| **R09** | UI/UX truthfulness + WAO test alignment | Close CONS-050 WFC-P2-005; CONS-051; a11y contracts | CONS-050; CONS-051; CONS-012 | Tests/WatchAlgorithmTests/*WAO*; Utils/WatchLaunchRoutingPolicy.swift; Docs WAO policy | BühlmannCore; FC engine timing | 01;03;04;05 |
| **R10** | QA evidence + physical-test scaffolding | Execute physical/external matrices; no false closure | CONS-009; CONS-010; CONS-021; CONS-022; CONS-042; CONS-048; APNEA-PHY-001 | Docs/QA_EVIDENCE/**; templates only until field run | Production code unless blocker | 01;02;03;05 |
| **R11** | Release / legal / App Store wording | CONS-044; CONS-013; demote false claims | CONS-053; CONS-044; CONS-013 | Legal docs; TestFlight notes; marketing copy | Algorithm changes | 05;06 |
| **R12** | Documentation + feature-matrix alignment | CONS-054 INDEX/README; feature matrix rows | CONS-053; CONS-054 | Docs/INDEX.md; README.md; DIR_DIVING_Feature_Comparison.csv | Production code | 06 |
| **R02** | Watch FC P0/P1 remediation | Only if audit 01 finds new FC defects | None open @ 2c30412 | Watch FC paths per finding | Convenience refactors | 01;03;04;05 |
| **R03** | Watch FC oracle regression | Altitude oracle extension CONS-015 | CONS-015; WFC-P2-003 | Tests/WatchAlgorithmTests; BuhlmannCore tests | Constants without reference | 01;05 |
| **R05** | Activity Settings / Logbook isolation | CONS-028; CONS-040; Apnea cloud decision | P3 settings findings | iOSApp/Services/*Settings*; iOSApp/Views | Cross-activity stores | 02;03;04;06 |

---

## Next command (orchestrator recommendation)

**Do not launch Command 10/11 automatically.**

**Recommended next:** **R09 — WAO routing test alignment (CONS-050 / WFC-P2-005)**

### R09 scope outline

- **Purpose:** Align `WatchWaterAutoOpenPolicyTests` and `WatchLaunchRoutingPolicyTests` with intentional post-Apnea `divingModeSelection` routing **or** document and adjust policy if regression confirmed.
- **Input findings:** CONS-050; WFC-P2-005; MAIN-P2-003; MUIUX-P2-005; MAIN-APNEA-002; CONS-051 (Snorkeling progress test).
- **Allowed files:** `Tests/WatchAlgorithmTests/WatchWaterAutoOpenPolicyTests.swift`; `WatchLaunchRoutingPolicyTests.swift`; `Utils/DIRStartupSelectionPolicy.swift`; `Utils/WatchWaterAutoOpenPolicy.swift`; `Docs/WATCH_WATER_AUTO_OPEN_POLICY.md`.
- **Forbidden:** `Shared/BuhlmannCore/*`; `FullComputerRuntimeEngine`; sync schemas; Apnea store isolation logic without audit rerun.
- **Required safeguards:** Preserve DepthCapabilityPolicy gate (CONS-019); Apnea architecture isolation tests must remain PASS.
- **Validation:** G-009 Watch Algorithm Tests 1152/1152; G-028 WAO tests; G-010 FC oracle suites unchanged PASS.
- **Audits to rerun:** 01; 03; 04; 05.
- **Acceptance:** 1152/1152 Watch tests green; 0 FC test regressions; WAO policy documented.
- **Rollback:** Revert test-only changes; restore 1139/1152 baseline if policy change rejected.

---

## Deferred until after R09 + physical scaffolding

- **R10** physical QA campaigns (CONS-048 12 Snorkeling folders; CONS-010 wet FC).
- **R11** legal review (CONS-044) — after CONS-053 P0 doc repair.
- **R12** INDEX/README refresh @ `2c30412` — after technical truth stable.

---

## Explicitly excluded from orchestrator 00

```text
07 — Post-remediation verification (after remediation complete)
10/11 — Consolidated software remediation (already executed @ 7a429a7/6a0005b; do not re-launch from 00)
```
