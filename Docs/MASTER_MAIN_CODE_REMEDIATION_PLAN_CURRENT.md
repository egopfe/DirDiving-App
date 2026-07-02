# Master Main Code Remediation Plan (CURRENT)

## Prioritized backlog

1. **P1 - MAIN-CMD-001:** restore missing launch-order 07 command file; rerun command-integrity gate.
2. **P1 - MAIN-TEST-001/002:** resolve Snorkeling localization parity test failures and rerun iOS+Watch suites.
3. **P2 - MAIN-SYNC-001:** paired stress verification for large payload fallback and ACK cleanup.
4. **P2 - MAIN-PRIV-001:** execute physical location-permission QA matrix.
5. **P3 - MAIN-CONC-001:** tighten GPS confirmation task lifecycle guard if still reproducible.

## Non-negotiable constraints

- Keep Full Computer mathematical safety gate authoritative.
- Preserve activity isolation for Diving/Apnea/Snorkeling stores and sync.
- Do not promote pending physical/manual/external gates to PASS without artifacts.

## Exit criteria for this plan

- P1 queue empty
- automated suites green
- integrity scanner PASS on full command set
- physical/instruments/paired gates either evidenced or explicitly pending in release verdict
