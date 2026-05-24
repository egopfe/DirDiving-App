# DIR DIVING — Indice documentazione (`Docs/`)

**Aggiornato:** 2026-05-24  
**Branch consigliato:** `main` (dopo `git pull`; ultimo pass readiness UX/i18n/build)  
**Uso:** punto di ingresso per ripartire a lavorare sul progetto.

---

## 1. Documento principale (leggere per primo)

### [`MAIN_BRANCH_COMPLETE_READINESS_AUDIT_20260524.md`](MAIN_BRANCH_COMPLETE_READINESS_AUDIT_20260524.md)

Audit completo **MAIN** (Watch + iOS companion), struttura A–O. Versione Word: [`MAIN_BRANCH_COMPLETE_READINESS_AUDIT_20260524.docx`](MAIN_BRANCH_COMPLETE_READINESS_AUDIT_20260524.docx) · generatore: [`generate_main_branch_complete_readiness_audit_20260524_docx.py`](generate_main_branch_complete_readiness_audit_20260524_docx.py).

| Sezione | Contenuto |
|---------|-----------|
| **A** | Branch, target, `project.yml`, build (nota: audit redatto su host senza Xcode; commit ispezionato `91f3c8d`) |
| **B** | Executive summary (~74% overall nel report statico Windows) |
| **C** | Feature inventory (Watch + iOS: impl / reach / usable / complete) |
| **D** | Navigation map (flussi Watch e iOS, dead end) |
| **E** | UI consistency vs reference (`Docs/ReferenceUI/`) |
| **F** | Settings (unità, allarmi, haptic, cloud, export) |
| **G** | Haptics / tones |
| **H** | Hardware (Crown, Action Button, App Intents) |
| **I** | Sync Watch ↔ iPhone, iCloud KVS |
| **J** | Export Subsurface CSV |
| **K** | Safety / disclaimer / non dive computer |
| **L** | Empty / error states |
| **M** | **Bugs to fix** (tabella con file e severità) |
| **N** | Priority roadmap (compile → TestFlight → App Store → post-release) |
| **O** | Final verdict (compile / utente medio / TestFlight / App Store) |
| **Validation log** | Comandi git/asset; build non eseguita su Windows |

**Bug critici elencati in §M (verificare su `main` @ `8a4d10e` se già risolti):**

| Bug | File indicato |
|-----|----------------|
| Disclaimer non ogni launch | `Utils/CompanionDisclaimerAcceptance.swift`, `iOSApp/Utils/...` |
| Default allarme runtime 60 vs 30 min | `Services/DiveManager.swift` |
| Lista log Watch in `m` fisso | `Views/DiveLogListView.swift` |
| Profondità bussola in `m` fisso | `Views/CompassView.swift` |
| Logbook iOS card in `m` fisso | `iOSApp/Views/LogbookView.swift` |
| Planner metric-only vs unità globali | `iOSApp/Views/PlannerView.swift` — **copy onesta** aggiunta (`planner.units.metric_notice`); calcoli restano metrici |
| Copy unità obsolete | `iOSApp/Resources/*.lproj/Localizable.strings` |
| Build opaque return (Watch) | `Views/AscentRateSettingsView.swift`, `Views/DiveLogListView.swift` — **risolto** (pass 2026-05-24) |

> **Nota:** commit `8a4d10e` + pass successivo: build simulator Watch/iOS verde; i18n Equipment/Planner; checklist device QA in §6.

**Audit readiness precedenti (storico):**

| File | Uso |
|------|-----|
| [`MAIN_BRANCH_COMPLETE_READINESS_AUDIT_20260520.md`](MAIN_BRANCH_COMPLETE_READINESS_AUDIT_20260520.md) | Pass R2–R4, baseline `db72dce` / WIP |
| [`MAIN_BRANCH_COMPLETE_READINESS_AUDIT_20260523.md`](MAIN_BRANCH_COMPLETE_READINESS_AUDIT_20260523.md) | Pass readiness 100% UX |
| [`MAIN_BRANCH_COMPLETE_READINESS_AUDIT_20260522.md`](MAIN_BRANCH_COMPLETE_READINESS_AUDIT_20260522.md) | Onboarding legale |

---

## 2. Stato repo, branch e PR

| Documento | Contenuto |
|-----------|-----------|
| [`DOCUMENTATION_BRANCH_ALIGNMENT_20260524.md`](DOCUMENTATION_BRANCH_ALIGNMENT_20260524.md) | Branch `main` / `main-iOS` / experimental; regole merge; R2–R4 |
| [`DOCUMENTATION_UPDATE_REPORT_20260524.md`](DOCUMENTATION_UPDATE_REPORT_20260524.md) | Report A–K pass docs post `bd129ca` / `86ef349` |
| [`DOCUMENTATION_UPDATE_REPORT_20260524_CONTROL_STRATEGY.md`](DOCUMENTATION_UPDATE_REPORT_20260524_CONTROL_STRATEGY.md) | Docs post Watch control strategy (`72fa15b`) |
| [`PR_STATUS_20260524.md`](PR_STATUS_20260524.md) | PR #8 / #9 — non auto-merge |
| [`DOCUMENTATION_BRANCH_ALIGNMENT_20260523.md`](DOCUMENTATION_BRANCH_ALIGNMENT_20260523.md) | Allineamento precedente |
| [`PR_STATUS_20260523.md`](PR_STATUS_20260523.md) | Stato PR storico |
| [`DOCUMENTATION_SYNC_REPORT_20260519.md`](DOCUMENTATION_SYNC_REPORT_20260519.md) | Sync documentazione multi-branch |

---

## 3. Watch MAIN — UX, controlli, sicurezza

| Documento | Contenuto |
|-----------|-----------|
| [`WATCH_CONTROL_STRATEGY_IMPLEMENTATION_REPORT.md`](WATCH_CONTROL_STRATEGY_IMPLEMENTATION_REPORT.md) | Crown, Settings, App Intents, haptics (`72fa15b`) |
| [`WATCH_MAIN_UX_CONVENTIONS.md`](WATCH_MAIN_UX_CONVENTIONS.md) | Banner risalita inline, layout Live, BUSSOLA |
| [`ASCENT_ALARM_IMPLEMENTATION_REPORT_20260520.md`](ASCENT_ALARM_IMPLEMENTATION_REPORT_20260520.md) | Implementazione allarme risalita |
| [`DEPTH_LIMIT_SAFETY_TEST_CHECKLIST.md`](DEPTH_LIMIT_SAFETY_TEST_CHECKLIST.md) | QA 35 / 38 / 40 m |
| [`TESTFLIGHT_ENTITLEMENT_AND_DEVICE_QA_20260523.md`](TESTFLIGHT_ENTITLEMENT_AND_DEVICE_QA_20260523.md) | **R1** entitlement + Ultra |
| [`TESTFLIGHT_REVIEW_NOTES.md`](TESTFLIGHT_REVIEW_NOTES.md) | Note revisore App Store |

---

## 4. iOS MAIN — UX, audit, implementazione

| Documento | Contenuto |
|-----------|-----------|
| [`MAIN_BRANCH_UX_INTERACTION_ACCESSIBILITY_AUDIT_20260524_CURRENT_PRE_MODIFICATION.md`](MAIN_BRANCH_UX_INTERACTION_ACCESSIBILITY_AUDIT_20260524_CURRENT_PRE_MODIFICATION.md) | **Audit UX/interaction/accessibilità PRE-MOD** @ `8a4d10e` (`.docx` omonimo) |
| [`MAIN_BRANCH_UX_INTERACTION_ACCESSIBILITY_AUDIT_20260524.md`](MAIN_BRANCH_UX_INTERACTION_ACCESSIBILITY_AUDIT_20260524.md) | Audit UX/a11y precedente (`.docx` omonimo) |
| [`MAIN_BRANCH_UX_INTERACTION_ACCESSIBILITY_AUDIT_20260523.md`](MAIN_BRANCH_UX_INTERACTION_ACCESSIBILITY_AUDIT_20260523.md) | Audit precedente |
| [`MAIN_BRANCH_FINAL_READINESS_REPORT.md`](MAIN_BRANCH_FINAL_READINESS_REPORT.md) | **Report finale** pass readiness ~94% (build, i18n, copy, QA docs; device-only residui) |
| [`APP_INTENTS_DEVICE_QA_CHECKLIST.md`](APP_INTENTS_DEVICE_QA_CHECKLIST.md) | QA hardware: 7 App Intents + Action Button |
| [`WATCH_IOS_SYNC_DEVICE_QA_CHECKLIST.md`](WATCH_IOS_SYNC_DEVICE_QA_CHECKLIST.md) | QA hardware: sync, conflitti, tombstone, unità |
| [`MAIN_BRANCH_TARGETED_FIX_REPORT.md`](MAIN_BRANCH_TARGETED_FIX_REPORT.md) | Fix `db72dce` (gauge, intents, detail) |
| [`MAIN_ISSUES_IMPLEMENTATION_REPORT_20260520.md`](MAIN_ISSUES_IMPLEMENTATION_REPORT_20260520.md) | Implementazione issue backlog |
| [`MAIN_BRANCH_ISSUES_AND_PRIORITIES_20260520.md`](MAIN_BRANCH_ISSUES_AND_PRIORITIES_20260520.md) | Priorità issue |
| [`DIR_Diving_Main_Branch_Development_Notes.md`](DIR_Diving_Main_Branch_Development_Notes.md) | Note prodotto (unità, disclaimer, manual dive) |
| [`DIR_DIVING_MAIN_BRANCH_DEVELOPMENT_IMPLEMENTATION_REPORT.md`](DIR_DIVING_MAIN_BRANCH_DEVELOPMENT_IMPLEMENTATION_REPORT.md) | Report `f851b61` |
| [`iOS/BUILD_AND_RUN.md`](iOS/BUILD_AND_RUN.md) | Build companion iOS |
| [`iOS/SUBSURFACE_EXPORT.md`](iOS/SUBSURFACE_EXPORT.md) | Export CSV |
| [`iOS/SAFETY_DISCLAIMER.md`](iOS/SAFETY_DISCLAIMER.md) | Disclaimer iOS |
| [`iOS/VALIDATION_REPORT.md`](iOS/VALIDATION_REPORT.md) | Validazione iOS |
| [`iOS/MOCKUP_COHERENCE.md`](iOS/MOCKUP_COHERENCE.md) | Coerenza mockup |
| [`iOS/GITHUB_SETUP.md`](iOS/GITHUB_SETUP.md) | Setup GitHub |
| [`IOS_TAB_TARGET_MISMATCH_REPORT.md`](IOS_TAB_TARGET_MISMATCH_REPORT.md) | Tab vs target |
| [`IOS_TAB_TARGET_MISMATCH_STATUS_20260519.md`](IOS_TAB_TARGET_MISMATCH_STATUS_20260519.md) | Stato mismatch |

---

## 5. Matrice feature e roadmap

| Documento | Contenuto |
|-----------|-----------|
| [`DIR_DIVING_Feature_Comparison.csv`](DIR_DIVING_Feature_Comparison.csv) | **Matrice master** — Watch Main / Experimental / iOS / status / i18n |
| [`Branch_Functionality_Matrix.xlsx`](Branch_Functionality_Matrix.xlsx) | Export Excel (derivato da CSV) |
| [`ROADMAP.md`](ROADMAP.md) | Fatto / prossimi passi |
| [`MAIN_PRE_RELEASE_OPEN_ITEMS_20260519.md`](MAIN_PRE_RELEASE_OPEN_ITEMS_20260519.md) | Backlog pre-release |
| [`GLOSSARY.md`](GLOSSARY.md) | Glossario termini |

---

## 6. Build, release, sicurezza

| Documento | Contenuto |
|-----------|-----------|
| [`BUILD_VALIDATION.md`](BUILD_VALIDATION.md) | `xcodegen`, scheme, build |
| [`RELEASE_CHECKLIST.md`](RELEASE_CHECKLIST.md) | Checklist release |
| [`SAFETY_DISCLAIMER.md`](SAFETY_DISCLAIMER.md) | Disclaimer (root Docs) |
| [`SECURITY_AUDIT_MAIN_AND_MAIN_IOS_20260519.md`](SECURITY_AUDIT_MAIN_AND_MAIN_IOS_20260519.md) | Audit security F1–F12 |
| [`INTERNAL_TESTING_PLAYBOOK_20260520.md`](INTERNAL_TESTING_PLAYBOOK_20260520.md) | QA interno giornaliero; link checklist device |
| [`APP_INTENTS_DEVICE_QA_CHECKLIST.md`](APP_INTENTS_DEVICE_QA_CHECKLIST.md) | App Intents su Watch fisico |
| [`WATCH_IOS_SYNC_DEVICE_QA_CHECKLIST.md`](WATCH_IOS_SYNC_DEVICE_QA_CHECKLIST.md) | Sync Watch↔iPhone su hardware |
| [`MAIN_PRE_RELEASE_SIMULATOR_QA_20260519.md`](MAIN_PRE_RELEASE_SIMULATOR_QA_20260519.md) | QA simulatore |

---

## 7. Experimental (non in target MAIN)

| Documento | Contenuto |
|-----------|-----------|
| [`EXPERIMENTAL_FEATURES.md`](EXPERIMENTAL_FEATURES.md) | Panoramica Watch experimental |
| [`SNORKELING_EXPERIMENTAL_SPEC.md`](SNORKELING_EXPERIMENTAL_SPEC.md) | Snorkeling Live, Mappa Waypoint/Ritorno, POI, ritorno ingresso |
| [`APNEA_EXPERIMENTAL_SPEC.md`](APNEA_EXPERIMENTAL_SPEC.md) | Apnea workflow |
| [`iOS/EXPERIMENTAL_FEATURES.md`](iOS/EXPERIMENTAL_FEATURES.md) | iOS Explore Lab / Buddy |

---

## 8. Audit UX storici e pass implementativi

| Documento | Contenuto |
|-----------|-----------|
| [`MAIN_BRANCHES_UX_INTERACTION_AUDIT_20260519_CURRENT_PRE_MODIFICATION.md`](MAIN_BRANCHES_UX_INTERACTION_AUDIT_20260519_CURRENT_PRE_MODIFICATION.md) | Audit pre-modifica 20260519 |
| [`MAIN_BRANCHES_UX_INTERACTION_AUDIT_20260518_CURRENT_PRE_MODIFICATION.md`](MAIN_BRANCHES_UX_INTERACTION_AUDIT_20260518_CURRENT_PRE_MODIFICATION.md) | Audit 20260518 |
| [`MAIN_BRANCHES_UX_INTERACTION_AUDIT_20260518_POST_FIX_PRE_MODIFICATION.md`](MAIN_BRANCHES_UX_INTERACTION_AUDIT_20260518_POST_FIX_PRE_MODIFICATION.md) | Post-fix 20260518 |
| [`MAIN_UX_COMPLETION_REPORT.md`](MAIN_UX_COMPLETION_REPORT.md) | Completamento UX MAIN |
| [`MAIN_UX_GAP_FIX_IMPLEMENTATION_20260518.md`](MAIN_UX_GAP_FIX_IMPLEMENTATION_20260518.md) | Gap fix 20260518 |
| [`MAIN_READINESS_100_IMPLEMENTATION_REPORT_20260517.md`](MAIN_READINESS_100_IMPLEMENTATION_REPORT_20260517.md) | Readiness 100% 20260517 |
| [`PHASE0_MAIN_UX_PREFLIGHT_PLAN.md`](PHASE0_MAIN_UX_PREFLIGHT_PLAN.md) | Preflight UX |

---

## 9. Report aggiornamento documentazione (cronologia)

| Data | File |
|------|------|
| 20260524 | [`DOCUMENTATION_UPDATE_REPORT_20260524.md`](DOCUMENTATION_UPDATE_REPORT_20260524.md), [`DOCUMENTATION_UPDATE_REPORT_20260524_CONTROL_STRATEGY.md`](DOCUMENTATION_UPDATE_REPORT_20260524_CONTROL_STRATEGY.md) |
| 20260523 | [`DOCUMENTATION_UPDATE_REPORT_20260523.md`](DOCUMENTATION_UPDATE_REPORT_20260523.md) |
| 20260522 | [`DOCUMENTATION_UPDATE_REPORT_20260522_LEGAL_ONBOARDING.md`](DOCUMENTATION_UPDATE_REPORT_20260522_LEGAL_ONBOARDING.md) |
| 20260520 | [`DOCUMENTATION_UPDATE_REPORT_20260520.md`](DOCUMENTATION_UPDATE_REPORT_20260520.md), [`DOCUMENTATION_UPDATE_REPORT_20260520_POST_RELEASE.md`](DOCUMENTATION_UPDATE_REPORT_20260520_POST_RELEASE.md) |
| 20260519 | [`DOCUMENTATION_UPDATE_REPORT_20260519.md`](DOCUMENTATION_UPDATE_REPORT_20260519.md), [`DOCUMENTATION_UPDATE_REPORT_20260519_I18N.md`](DOCUMENTATION_UPDATE_REPORT_20260519_I18N.md), [`DOCUMENTATION_UPDATE_REPORT_20260519_SECURITY.md`](DOCUMENTATION_UPDATE_REPORT_20260519_SECURITY.md), [`DOCUMENTATION_UPDATE_REPORT_20260519_SECURITY_PT2.md`](DOCUMENTATION_UPDATE_REPORT_20260519_SECURITY_PT2.md), [`DOCUMENTATION_UPDATE_REPORT_20260519_PRE_RELEASE_BACKLOG.md`](DOCUMENTATION_UPDATE_REPORT_20260519_PRE_RELEASE_BACKLOG.md) |

| Data | Branch alignment |
|------|------------------|
| 20260517–24 | [`DOCUMENTATION_BRANCH_ALIGNMENT_20260517.md`](DOCUMENTATION_BRANCH_ALIGNMENT_20260517.md) … [`DOCUMENTATION_BRANCH_ALIGNMENT_20260524.md`](DOCUMENTATION_BRANCH_ALIGNMENT_20260524.md) |

---

## 10. Riferimenti visivi e asset

| Percorso | Contenuto |
|----------|-----------|
| [`ReferenceUI/Watch_LIVE_reference.png`](ReferenceUI/Watch_LIVE_reference.png) | UI Watch Diving (benchmark audit §E) |
| [`ReferenceUI/iOS_Companion_reference.png`](ReferenceUI/iOS_Companion_reference.png) | UI iOS companion |
| [`ReferenceIcon/`](ReferenceIcon/) | Icone app, `altosinistra.png` |
| [`ReferenceLookAndFeel.jpg`](ReferenceLookAndFeel.jpg) | Look & feel (se presente) |
| [`LiveDiveImmersionPremiumPreview.png`](LiveDiveImmersionPremiumPreview.png) | Preview Live Dive |
| [`CurrentCodeLiveViewPreview.png`](CurrentCodeLiveViewPreview.png) | Preview codice Live |
| [`SecureBuddyPairingMockup.svg`](SecureBuddyPairingMockup.svg) | Mockup Buddy (experimental) |
| [`UI_UX_VISUAL_GUIDELINES.md`](UI_UX_VISUAL_GUIDELINES.md) | Linee guida visive |

---

## 11. Script generatori `.docx`

| Script | Output |
|--------|--------|
| [`generate_main_branch_complete_readiness_audit_20260524_docx.py`](generate_main_branch_complete_readiness_audit_20260524_docx.py) | `MAIN_BRANCH_COMPLETE_READINESS_AUDIT_20260524.docx` |
| [`generate_main_branch_complete_readiness_audit_20260520_docx.py`](generate_main_branch_complete_readiness_audit_20260520_docx.py) | Audit 20260520 docx |
| [`generate_main_branch_complete_readiness_audit_20260523_docx.py`](generate_main_branch_complete_readiness_audit_20260523_docx.py) | Audit 20260523 docx |
| [`generate_main_branch_ux_interaction_accessibility_audit_20260524_docx.py`](generate_main_branch_ux_interaction_accessibility_audit_20260524_docx.py) | UX audit 20260524 docx |
| [`generate_main_branch_readiness_audit_full_docx.py`](generate_main_branch_readiness_audit_full_docx.py) | Audit full |
| [`generate_main_readiness_audit_docx.py`](generate_main_readiness_audit_docx.py) | Readiness docx |
| [`generate_main_ux_audit_20260519_docx.py`](generate_main_ux_audit_20260519_docx.py) | UX 20260519 |
| [`generate_ux_roadmap_100_docx.py`](generate_ux_roadmap_100_docx.py) | Roadmap 100 docx |

---

## 12. Percorso rapido (30 minuti)

1. [`../README.md`](../README.md) — panoramica e branch strategy  
2. [`MAIN_BRANCH_COMPLETE_READINESS_AUDIT_20260524.md`](MAIN_BRANCH_COMPLETE_READINESS_AUDIT_20260524.md) — **§B, §M, §N, §O**  
3. [`DIR_DIVING_Feature_Comparison.csv`](DIR_DIVING_Feature_Comparison.csv) — stato feature  
4. [`WATCH_CONTROL_STRATEGY_IMPLEMENTATION_REPORT.md`](WATCH_CONTROL_STRATEGY_IMPLEMENTATION_REPORT.md) — se lavori su Watch  
5. [`TESTFLIGHT_ENTITLEMENT_AND_DEVICE_QA_20260523.md`](TESTFLIGHT_ENTITLEMENT_AND_DEVICE_QA_20260523.md) — se lavori su TestFlight / R1  

---

## 13. File fuori da `Docs/` collegati

| File | Ruolo |
|------|--------|
| [`../README.md`](../README.md) | Ingresso repository |
| [`../CHANGELOG.md`](../CHANGELOG.md) | Changelog |
| [`../CONTRIBUTING.md`](../CONTRIBUTING.md) | Regole contribuzione |
| [`../project.yml`](../project.yml) | XcodeGen / exclude experimental |

---

*Indice generato per ripresa lavoro su `main`. Per aggiornare l’indice dopo nuovi audit, estendere §1 e §9.*
