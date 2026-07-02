# Snorkeling Watch P1/P2/P3 — Unified Remediation Rerun Checklist

## Before merge / release candidate

- [ ] `xcodegen generate`
- [ ] Watch build (`DIRDiving Watch App`)
- [ ] iOS build (`DIRDiving iOS`)
- [ ] Watch Algorithm Tests full scheme
- [ ] iOS Algorithm Tests full scheme
- [ ] `./Scripts/check_main_target_isolation.sh`
- [ ] `./Scripts/check_secrets.sh`
- [ ] `./Scripts/audit_localization.sh`
- [ ] `Scripts/validate_snorkeling_release_readiness.sh`
- [ ] `Scripts/validate_no_fake_physical_evidence_claims.sh`
- [ ] `Scripts/validate_release_claims_against_evidence.sh`

## Manual QA (blocking — all PENDING)

- [ ] SNORKELING_P1_ROUTE_SYNC_STATUS_IOS
- [ ] SNORKELING_P1_WATCH_TO_IOS_SYNC_STATUS
- [ ] SNORKELING_P1_WATCH_READY_ROUTE_STATUS
- [ ] SNORKELING_P1_WATCH_BATTERY_PRESENTATION
- [ ] SNORKELING_P2_RETURN_PRIMARY_ACTION
- [ ] SNORKELING_P2_OPERATIONAL_SETTINGS_IOS
- [ ] SNORKELING_P3_WATCH_MICRO_MAP
- [ ] SNORKELING_P3_PLANNED_VS_ACTUAL
- [ ] SNORKELING_ROUTE_PUSH (paired device E2E per PROCEDURE.md)
- [ ] SNORKELING_NO_CROSS_ACTIVITY_REGRESSION

## Readiness gates

Do **not** claim PRODUCTION_READY, APP_STORE_READY, or FIELD_VALIDATED until manual QA evidence folders contain dated device artifacts and signed README verdicts.
