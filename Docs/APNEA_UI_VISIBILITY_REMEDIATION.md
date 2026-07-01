# Apnea UI Visibility Remediation

## Scope

Apnea iOS companion, Apple Watch presentation, settings, planner, dashboard, profiles, checklist persistence, session check integration, localization, tests, and docs only.

## Problem

Core Apnea models and evaluators existed (profiles, checklist, session check) but were partially hidden in settings or not wired into primary user flows.

## Remediation summary

| Area | Before | After |
|------|--------|-------|
| Checklist | Local `@State` in settings view | Persisted in `ApneaCompanionSettings.preApneaChecklist` |
| Planner | Validation issues only | Compact checklist + `ApneaSessionCheckEvaluator` section before Watch transfer |
| Dashboard | No readiness summary | **Apnea Readiness** card with quick actions |
| Profiles | Name/depth/duration only | Profile kind, recovery rule, max repetitions |
| Watch ready | Buddy/recovery only | Synthetic pre-check count or reminder label |

## Safety policy

All UI uses training-aid / operational-reminder wording. No safety certification, no “safe to dive/hold”, no blackout prevention claims. Disclaimer retained: training and logging aid only; do not freedive alone.

## QA

Physical QA templates under `Docs/QA_EVIDENCE/APNEA_*` default to **PENDING**.

## Related docs

- [APNEA_CHECKLIST_PERSISTENCE.md](APNEA_CHECKLIST_PERSISTENCE.md)
- [APNEA_PLANNER_SESSION_CHECK_INTEGRATION.md](APNEA_PLANNER_SESSION_CHECK_INTEGRATION.md)
- [APNEA_READINESS_DASHBOARD.md](APNEA_READINESS_DASHBOARD.md)
- [APNEA_PROFILE_UI_STRUCTURED_KIND.md](APNEA_PROFILE_UI_STRUCTURED_KIND.md)
- [APNEA_UI_VISIBILITY_REMEDIATION_IMPLEMENTATION_REPORT_CURRENT.md](APNEA_UI_VISIBILITY_REMEDIATION_IMPLEMENTATION_REPORT_CURRENT.md)
