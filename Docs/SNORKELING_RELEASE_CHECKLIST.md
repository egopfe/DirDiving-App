# Snorkeling release checklist

**Branch:** `main`  
**Automation:** `./Scripts/validate_snorkeling_release_readiness.sh`

## Pre-merge (internal code readiness)

- [ ] `validate_snorkeling_release_readiness.sh --internal` exits 0
- [ ] No `SNORKELING_` raster mockups in app bundles (automated)
- [ ] `SnorkelingMockupReferenceMatrix` lists all 10 reference PNGs
- [ ] Reference PNGs exist in `Docs/ReferenceUI/Snorkeling/`
- [ ] Session sync namespace distinct from checkpoint, Apnea, FC, Gauge dive
- [ ] Sensor-unavailable state blocks Watch ready start (automated)
- [ ] Transport crypto tests never XCTSkip (`SnorkelingSyncTestSupport`)
- [ ] Dashboard map preview gap-aware or hidden without measured track
- [ ] EXIF GPS removal asserted at metadata level
- [ ] EN + IT localization audit passes (`audit_localization.sh`)
- [ ] Implementation reports Commands 04–11 indexed in `Docs/INDEX.md`

## TestFlight (requires physical QA)

- [ ] Paired iPhone + Apple Watch sync (route push + session pull)
- [ ] Water Lock session on Watch Ultra
- [ ] Wet/glove interaction on Action button and Digital Crown
- [ ] Real GPS acquisition, gap recovery, airplane mode
- [ ] VoiceOver on all seven Watch stages + iOS tabs
- [ ] Battery/thermal under 90+ minute session
- [ ] Populate `Docs/QA_EVIDENCE/SNORKELING_*` with PASS evidence

## App Store

- [ ] TestFlight complete
- [ ] Privacy review (GPS, photos, export, buddy contacts)
- [ ] Safety/legal review — no rescue, certified-computer, or guaranteed-return claims
- [ ] `validate_snorkeling_release_readiness.sh --release` with QA evidence PASS

## Rollback

1. Revert snorkeling promotion on `main` (exclude `SnorkelingView.swift` from MAIN if needed).
2. Snorkeling sync keys are namespaced — rollback does not affect Gauge/Apnea/FC sync.
3. iOS logbook file `dirdiving_ios_snorkeling_sessions.json` is preserved on device.

## Explicit non-goals

- EN13319 / ISO 6425 dive-computer certification
- Underwater GPS positioning
- Guaranteed return or rescue routing
- Offline map cache without real implementation
- Predictive wellness / fatigue / readiness scores
