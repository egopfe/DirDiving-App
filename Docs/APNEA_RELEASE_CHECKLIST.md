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

## Promotion to MAIN (explicit decision — not automatic)

- [ ] Remove `ApneaView.swift` exclusion from `project.yml` Watch target
- [ ] Wire `ExperimentalFeatures.apneaIntegrationEnabled` to mode selection / navigation
- [ ] Physical depth validation on Watch Ultra (pool + open water)
- [ ] End-to-end plan transfer + session import on paired devices
- [ ] VoiceOver walkthrough of all Watch stages and iOS tabs
- [ ] Legal review: apnea-specific disclaimer if marketed beyond training aid
- [ ] App Store copy does **not** claim blackout detection, SAM, or rescue monitoring

## Rollback

1. Stay on `main` (Apnea sources not in MAIN target).
2. Or revert `main` merge commit.
3. Apnea sync keys are namespaced — rollback does not affect Gauge/FC dive sync.

## Explicit non-goals

- EN13319 / ISO 6425 dive-computer certification
- Certified blackout or hypoxia monitoring
- Remote buddy rescue or LTE distress relay
