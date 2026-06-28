# DIR DIVING MASTER AUDIT COMMANDS — LAUNCH SEQUENCE

This is the recommended launch order for the final merged master audit commands.

## 00 — Super Orchestrator

Run first and alone if you want Cursor/Codex to coordinate the full sequence from `commands_for_cursor/`.

File:

```text
00-MASTER_SUPER_ORCHESTRATOR_FULL_AUDIT_SEQUENCE_AND_NON_REGRESSIVE_REMEDIATION_PLAN_COMMAND_V1.2.md
```

This version is aware of the 2026-06-27 / 2026-06-28 development wave: water auto-open, submerged system launch, Digital Crown underwater clamp, Action Button router policy, Watch cold-launch fix, Full Computer GF presets, shallow-depth entitlement and developer shallow-depth testing toggles.



## 01 — Watch Full Computer Forensic Audit

Run first.

Reason: it is the highest-risk safety-critical core. It audits Apple Watch Full Computer runtime, Bühlmann ZH-L16C, Schreiner, Haldane, actual-dt timing, multilevel decompression, altitude/CMAltimeter, gas switch, decompression stops, checkpoint/restore, logbook provenance and external/physical validation gates.

File:

```text
01-MASTER_WATCH_FULL_COMPUTER_FORENSIC_AUDIT_COMMAND_V2.1.md
```

## 02 — iOS Full Deep Comprehensive Audit

Run second.

Reason: after the Watch Full Computer core is audited, audit the iOS Planner and Companion logic that feeds plans, gases, briefing cards, logbooks, settings and exports into the ecosystem.

File:

```text
02-MASTER_IOS_FULL_DEEP_COMPREHENSIVE_AUDIT_COMMAND_V1.1.md
```

## 03 — UI/UX Full Deep Comprehensive Audit

Run third.

Reason: UI/UX must validate the actual implemented behavior, not assumptions. Run it after the Watch/iOS core audits so it can verify visibility, reachability, truthful state presentation, Settings mode switch, Apnea/Snorkeling Settings, Logbook ownership, mockups and visual regression.

File:

```text
03-MASTER_UI_UX_FULL_DEEP_COMPREHENSIVE_AUDIT_COMMAND_V2.2.md
```

## 04 — Main Code / Sync / Security / Performance Audit

Run fourth.

Reason: after feature-specific audits, run the cross-cutting audit for architecture, data integrity, sync, schema, persistence, security, privacy, iOS performance, Watch performance, concurrency, stale async results and battery risks.

File:

```text
04-MASTER_MAIN_CODE_SYNC_SECURITY_PERFORMANCE_AUDIT_COMMAND_V1.1.md
```

## 05 — Release / QA / Evidence / Legal Claims Audit

Run fifth.

Reason: this is the release gate. It must consume all previous audit outputs and separate software evidence, simulator evidence, physical-device evidence, external validation, legal claims, privacy, Apple platform capabilities and TestFlight/App Store readiness.

File:

```text
05-MASTER_RELEASE_QA_EVIDENCE_COMPLIANCE_AUDIT_COMMAND_V1.1.md
```

## 06 — Documentation / Repository Alignment Audit

Run last.

Reason: documentation must be updated only after the final audit reality is known. This command checks README, Docs, command matrix, feature matrix, release wording, physical/external QA labels and superseded command alignment.

File:

```text
06-MASTER_DOCUMENTATION_REPOSITORY_ALIGNMENT_AUDIT_COMMAND_V1.1.md
```

## Summary

```text
00 Super Orchestrator
01 Watch Full Computer Forensic
02 iOS Full Deep
03 UI/UX Full Deep
04 Main Code / Sync / Security / Performance
05 Release / QA / Evidence / Legal Claims
06 Documentation / Repository Alignment
```
