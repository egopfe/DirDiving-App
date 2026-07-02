# Cursor / Codex Remediation Command Sequence — CURRENT

**Baseline:** `main` @ `7ae527b`  
**Orchestrator scope:** V1.7 planning only; do not execute 07/10/11/12 from orchestrator 00

---

## Recommended sequence

| Command_Number | Command_Name | Purpose | Input findings | Allowed files | Forbidden files | Required safeguards | Implementation scope | Tests to add/update | Validation commands | Audits to rerun | Acceptance criteria | Rollback strategy |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| R01 | Baseline and command integrity hardening | Stabilize command-chain lifecycle and continuation rules | CF-006, CF-012 | `Scripts/`, `Docs/MASTER_ORCHESTRATOR_*`, command inventory docs | production runtime code | keep orchestrator boundaries explicit | docs/process only | command integrity checks | `./Scripts/validate_commands_for_cursor_integrity.sh` | 04,06 | command map complete and reproducible | revert docs-only patch |
| R09 | Snorkeling localization parity remediation | Close failing localization key parity tests | CF-002 | localization files, related tests, truthfulness docs | FC math core, decompression engine | keep no cross-activity contamination | focused software fixes | Watch+iOS localization parity tests | localization audit + algorithm tests | 01,02,03,04 | 0 parity test failures | revert localization/test edits |
| R12 | Docs truthfulness and claims repair | Close stale baseline and unsupported claim docs | CF-008, CF-009, CF-014 | `Docs/INDEX.md`, claims docs, alignment docs | production code and tests | claims must map to evidence | docs-only | docs truthfulness matrix checks | release claims/doc checks | 05,06 | no unsupported claims, baseline aligned | revert docs-only edits |
| R11 | Release rollback and readiness evidence repair | Resolve rollback fail and release evidence blockers | CF-007, CF-011 | release/legal evidence docs and matrices | algorithm/runtime code | preserve truthful partial status until closed | release docs/process | rollback rehearsal evidence | release gate checks | 05,06 | SUPPORT_ROLLBACK PASS + evidence | revert release docs |
| R10 | Physical/manual QA evidence campaigns | Close physical/manual pending gates | CF-003, CF-004, CF-010, CF-013 | `Docs/QA_EVIDENCE/**`, QA matrices | production code unless separately approved | no simulator-to-physical overclaims | evidence execution | QA procedures and completion logs | QA matrix validations | 01,02,03,05 | signed artifacts for pending gates | retain pending status if incomplete |
| R13 | External validation closure | Complete third-party Buhlmann and legal external closure | CF-001, CF-011 | external validation and legal evidence docs | runtime code and test rewrites | independent evidence required | external evidence only | external comparison protocol updates | external evidence verification | 01,02,05,06 | external validation marked complete | revert claims status if evidence rejected |

---

## Orchestrator boundary note

The orchestrator `00` must not run:

```text
07-MASTER_POST_REMEDIATION_CODE_READINESS_VERIFICATION_AUDIT_COMMAND_V1.7.md
10-MASTER_CONSOLIDATED_SOFTWARE_REMEDIATION_TO_100_CODE_READINESS_COMMAND_V1.0.md
11-MASTER_2026_06_30_CONSOLIDATED_SOFTWARE_REMEDIATION_TO_100_COMMAND_V1.0.md
12-MASTER_SNORKELING_WATCH_P1_P2_P3_UNIFIED_REMEDIATION_IMPLEMENTATION_COMMAND_V1.0.md
```

Missing command 07 is recorded as manual continuation requirement, not as an execution target for orchestrator 00.
