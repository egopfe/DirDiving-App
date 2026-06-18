# Apnea release checklist

**Branch:** `main`  
**Automation:** `./Scripts/validate_apnea_release_readiness.sh`

## Pre-merge (integration branch)

- [ ] `validate_apnea_release_readiness.sh` exits 0
- [ ] No `APNEA_` raster mockups in app bundles (automated)
- [ ] `ApneaMockupReferenceMatrix` lists all 23 external PNG references
- [ ] Sync namespaces distinct from `dirdiving_dive_session` and `fullComputerPlanPackage`
- [ ] Buddy disclaimer visible on iOS (`apnea.ios.buddy.disclaimer`)
- [ ] Sensor-degraded state blocks Watch ready start (automated)
- [ ] Degraded sessions excluded from personal records by default (automated)
- [ ] EN + IT localization audit passes (`audit_localization.sh`)
- [ ] Implementation reports Commands 05–11 indexed in `Docs/INDEX.md`

## Promotion to MAIN (Command 04 — completed on `main`)

- [x] `ApneaView.swift` included in Watch MAIN target (`project.yml`)
- [x] `ApneaWatchRuntimeStore` wired — no `DiveManager` dependency
- [x] Suspend/resume integration tests pass (`ApneaSuspendResumeLifecycleIntegrationTests`)
- [x] Monotonic clock restore tests pass (`ApneaMonotonicClockRestoreTests`)
- [ ] Physical depth validation on Watch Ultra (pool + open water)
- [ ] End-to-end plan transfer + session import on paired devices
- [ ] VoiceOver walkthrough of all Watch stages and iOS tabs
- [ ] Legal review: apnea-specific disclaimer if marketed beyond training aid
- [ ] App Store copy does **not** claim blackout detection, SAM, or rescue monitoring

## Rollback

1. Revert Apnea Watch UI route on `main` (exclude `ApneaView.swift` from MAIN target) while preserving data.
2. Or revert the promotion merge commit on `main`.
3. Apnea sync keys are namespaced — rollback does not affect Gauge/FC dive sync.

## Explicit non-goals

- EN13319 / ISO 6425 dive-computer certification
- Certified blackout or hypoxia monitoring
- Remote buddy rescue or LTE distress relay
