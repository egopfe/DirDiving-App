# DIR DIVING — Indice documentazione (`Docs/`)

**Aggiornato:** 2026-05-25  
**Branch consigliato:** `main` @ `ab398eb` (allineato a `origin/main` al momento dell'ultimo controllo)
**Uso:** punto di ingresso per ripartire a lavorare sul progetto.  
**Panoramica funzioni (IT):** [`PRODUCT_FEATURES_IT.md`](PRODUCT_FEATURES_IT.md)

---

## 0. Note di sviluppo prodotto (MAIN) — leggere per backlog

| Documento | Contenuto | Stato |
|-----------|-----------|--------|
| [`DIR_Diving_Complete_Development_Notes_UPDATED_v10.md`](DIR_Diving_Complete_Development_Notes_UPDATED_v10.md) | **Note sviluppo complete aggiornate (v10)** — backlog/spec iOS + Apple Watch aggiornato al 2026-05-25 | **Corrente (spec)** — file locale indicizzato |
| [`DIR_Diving_Complete_Development_Notes_UPDATED_v9.md`](DIR_Diving_Complete_Development_Notes_UPDATED_v9.md) | **Note sviluppo complete aggiornate (v9)** — iOS + Watch: icone, equipment, planner gas/Bühlmann, MOD, Watch allarmi/nav, checklist GAS | Spec precedente |
| [`DIR_Diving_Complete_Development_Notes_UPDATED_v8.md`](DIR_Diving_Complete_Development_Notes_UPDATED_v8.md) | Note sviluppo v8 (stesso ambito di v9; in caso di differenze preferire **v9**) | Spec precedente |
| [`DIR_DIVING_v8_IMPLEMENTATION_REPORT.md`](DIR_DIVING_v8_IMPLEMENTATION_REPORT.md) | Report implementazione v8 in codice: gas mix Air/EAN/Trimix, MOD, schedule travel/bailout, disclaimer trimix Bühlmann | **Completato** @ `a36dc23` |
| [`DIR_DIVING_v9_IMPLEMENTATION_REPORT.md`](DIR_DIVING_v9_IMPLEMENTATION_REPORT.md) | Report implementazione v9: immagini Watch in superficie, sync Planner/Bühlmann su input | **Completato** @ `d962117` |
| [`PRODUCT_FEATURES_IT.md`](PRODUCT_FEATURES_IT.md) | Panoramica funzionalità MAIN/experimental, modalità, i18n, branch strategy | Corrente @ `ab398eb` |
| [`DIR_Diving_Complete_Development_Notes_25_05_2026.md`](DIR_Diving_Complete_Development_Notes_25_05_2026.md) | Prima versione note 25/05/2026 (stesso ambito; usare v9/v8 se in conflitto) | Archivio / baseline |
| [`DEVELOPMENT_NOTES_25_05_2026_IMPLEMENTATION_REPORT.md`](DEVELOPMENT_NOTES_25_05_2026_IMPLEMENTATION_REPORT.md) | Implementazione codice note 25/05 (`c23d4d4`) | Completato |
| [`APP_ICON_UPDATE_NOTES.md`](APP_ICON_UPDATE_NOTES.md) | Rigenerazione icone (`Scripts/update_app_icons.sh`) + cache Simulator | Operativo |
| [`MAIN_BRANCH_UX_INTERACTION_ACCESSIBILITY_AUDIT_20260524_POST_DEV_NOTES.md`](MAIN_BRANCH_UX_INTERACTION_ACCESSIBILITY_AUDIT_20260524_POST_DEV_NOTES.md) | Audit UX post-implementazione @ `c23d4d4` · [`.docx`](MAIN_BRANCH_UX_INTERACTION_ACCESSIBILITY_AUDIT_20260524_POST_DEV_NOTES.docx) | Pre-fix B1/B2/B4/B6 |
| — | Fix UX B1/B2/B4/B6 (`9600015`): auto-dive copy, log bloccato in immersione, planner unità display, editor manuale | In `main` |
| — | Planner v8 codice (`a36dc23`): `PlannerGasSchedule`, `PlannerGasMixCard`, MOD block Calcola, N₂ Bühlmann trimix | In `main` |

---

## 1. Documento principale (leggere per primo)

### [`MAIN_BRANCH_COMPLETE_READINESS_AUDIT_2026-05-25.md`](MAIN_BRANCH_COMPLETE_READINESS_AUDIT_2026-05-25.md)

Audit completo **MAIN** (Watch + iOS companion), struttura A–O. Versione Word: [`MAIN_BRANCH_COMPLETE_READINESS_AUDIT_2026-05-25.docx`](MAIN_BRANCH_COMPLETE_READINESS_AUDIT_2026-05-25.docx). Audit pre-modifica redatto su `main` @ `21a7f41`, poi riallineato documentalmene sulla baseline corrente `main` @ `ab398eb`.

| Sezione | Contenuto |
|---------|-----------|
| **A** | Branch, target, `project.yml`, build e separazione target MAIN / experimental |
| **B** | Executive summary (repo-side 100%, overall 84% nel report 2026-05-25) |
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
| **Validation log** | `xcodegen` + simulator build pass; generic device build bloccato da entitlement/provisioning |

**Bug critici elencati in §M (versione audit 2026-05-25; distinguere fra fix repo-side chiusi e blocchi esterni ancora aperti):**

| Bug | File indicato |
|-----|----------------|
| Entitlement `water-submersion` non approvato nel provisioning attivo | Apple Developer / profili / build generici |
| Build generico iOS bloccato dal target Watch embedded | Coppia iOS + Watch release |
| Automatic dive lifecycle non validato su hardware Ultra reale | Device QA |
| Repo-side issues del dated audit | **Risolti** su `main` @ `ab398eb` (legal links dedicati, wording entitlement, BUSSOLA/planner i18n, recent sync activity, safeguard reset cronometro) |

> **Nota:** `e1cc982`–`fc08466`: build simulator Watch/iOS verde; i18n Equipment/Planner; checklist device QA in §6.

**Audit readiness precedenti (storico):**

| File | Uso |
|------|-----|
| [`MAIN_BRANCH_COMPLETE_READINESS_AUDIT_20260524.md`](MAIN_BRANCH_COMPLETE_READINESS_AUDIT_20260524.md) | Pass precedente, baseline immediata prima del dated audit 2026-05-25 |
| [`MAIN_BRANCH_COMPLETE_READINESS_AUDIT_20260520.md`](MAIN_BRANCH_COMPLETE_READINESS_AUDIT_20260520.md) | Pass R2–R4, baseline `db72dce` / WIP |
| [`MAIN_BRANCH_COMPLETE_READINESS_AUDIT_20260523.md`](MAIN_BRANCH_COMPLETE_READINESS_AUDIT_20260523.md) | Pass readiness 100% UX |
| [`MAIN_BRANCH_COMPLETE_READINESS_AUDIT_20260522.md`](MAIN_BRANCH_COMPLETE_READINESS_AUDIT_20260522.md) | Onboarding legale |

---

## 2. Stato repo, branch e PR

| Documento | Contenuto |
|-----------|-----------|
| [`DOCUMENTATION_BRANCH_ALIGNMENT_20260525.md`](DOCUMENTATION_BRANCH_ALIGNMENT_20260525.md) | Allineamento corrente: `main` canonico, `main-iOS` worktree storico divergente, experimental isolato |
| [`DOCUMENTATION_UPDATE_REPORT_20260525.md`](DOCUMENTATION_UPDATE_REPORT_20260525.md) | Report aggiornamento documentazione corrente |
| [`PR_STATUS_20260525.md`](PR_STATUS_20260525.md) | Stato PR/merge safety 2026-05-25 con limiti ambiente correnti |
| [`DOCUMENTATION_BRANCH_ALIGNMENT_20260520_POST_V9.md`](DOCUMENTATION_BRANCH_ALIGNMENT_20260520_POST_V9.md) | Allineamento branch post v9 @ `d962117` |
| [`DOCUMENTATION_UPDATE_REPORT_20260520_POST_V9.md`](DOCUMENTATION_UPDATE_REPORT_20260520_POST_V9.md) | Report A–K pass documentazione post v9 |
| [`PR_STATUS_20260520_POST_V9.md`](PR_STATUS_20260520_POST_V9.md) | Stato PR #8/#9 post v9 |
| [`DOCUMENTATION_BRANCH_ALIGNMENT_20260524.md`](DOCUMENTATION_BRANCH_ALIGNMENT_20260524.md) | Branch `main` / `main-iOS` / experimental; regole merge; R2–R4 (storico) |
| [`DOCUMENTATION_UPDATE_REPORT_20260524.md`](DOCUMENTATION_UPDATE_REPORT_20260524.md) | Report A–K pass docs post `bd129ca` / `86ef349` |
| [`DOCUMENTATION_UPDATE_REPORT_20260524_CONTROL_STRATEGY.md`](DOCUMENTATION_UPDATE_REPORT_20260524_CONTROL_STRATEGY.md) | Docs post Watch control strategy (`72fa15b`) |
| [`PR_STATUS_20260524.md`](PR_STATUS_20260524.md) | PR #8 / #9 — non auto-merge |
| [`DOCUMENTATION_BRANCH_ALIGNMENT_20260523.md`](DOCUMENTATION_BRANCH_ALIGNMENT_20260523.md) | Allineamento precedente |
| [`PR_STATUS_20260523.md`](PR_STATUS_20260523.md) | Stato PR storico |
| [`PR_STATUS_20260520.md`](PR_STATUS_20260520.md) | Stato PR storico (20260520) |
| [`DOCUMENTATION_SYNC_REPORT_20260519.md`](DOCUMENTATION_SYNC_REPORT_20260519.md) | Sync documentazione multi-branch |
| [`DOCUMENTATION_BRANCH_ALIGNMENT_20260518.md`](DOCUMENTATION_BRANCH_ALIGNMENT_20260518.md) | Allineamento branch (archivio) |
| [`DOCUMENTATION_BRANCH_ALIGNMENT_20260519.md`](DOCUMENTATION_BRANCH_ALIGNMENT_20260519.md) | Allineamento branch (archivio) |
| [`DOCUMENTATION_BRANCH_ALIGNMENT_20260520.md`](DOCUMENTATION_BRANCH_ALIGNMENT_20260520.md) | Allineamento branch (archivio) |
| [`DOCUMENTATION_BRANCH_ALIGNMENT_20260522.md`](DOCUMENTATION_BRANCH_ALIGNMENT_20260522.md) | Allineamento branch (archivio) |

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
| [`DIR_Diving_Main_Branch_Development_Notes.md`](DIR_Diving_Main_Branch_Development_Notes.md) | Note prodotto storiche (unità, disclaimer, manual dive) |
| [`DIR_Diving_Complete_Development_Notes_UPDATED_v10.md`](DIR_Diving_Complete_Development_Notes_UPDATED_v10.md) | → vedi **§0** (spec prodotto **corrente**) |
| [`DIR_Diving_Complete_Development_Notes_UPDATED_v9.md`](DIR_Diving_Complete_Development_Notes_UPDATED_v9.md) | → vedi **§0** (spec prodotto precedente) |
| [`DIR_Diving_Complete_Development_Notes_UPDATED_v8.md`](DIR_Diving_Complete_Development_Notes_UPDATED_v8.md) | → vedi **§0** |
| [`DIR_DIVING_v8_IMPLEMENTATION_REPORT.md`](DIR_DIVING_v8_IMPLEMENTATION_REPORT.md) | → vedi **§0** (implementazione v8 in codice) |
| [`DIR_DIVING_v9_IMPLEMENTATION_REPORT.md`](DIR_DIVING_v9_IMPLEMENTATION_REPORT.md) | → vedi **§0** (implementazione v9 in codice) |
| [`DIR_Diving_Complete_Development_Notes_25_05_2026.md`](DIR_Diving_Complete_Development_Notes_25_05_2026.md) | → vedi **§0** |
| [`DEVELOPMENT_NOTES_25_05_2026_IMPLEMENTATION_REPORT.md`](DEVELOPMENT_NOTES_25_05_2026_IMPLEMENTATION_REPORT.md) | → vedi **§0** |
| [`MAIN_BRANCH_UX_INTERACTION_ACCESSIBILITY_AUDIT_20260524_POST_DEV_NOTES.md`](MAIN_BRANCH_UX_INTERACTION_ACCESSIBILITY_AUDIT_20260524_POST_DEV_NOTES.md) | → vedi **§0** |
| [`APP_ICON_UPDATE_NOTES.md`](APP_ICON_UPDATE_NOTES.md) | → vedi **§0** |
| [`DIR_DIVING_MAIN_BRANCH_DEVELOPMENT_IMPLEMENTATION_REPORT.md`](DIR_DIVING_MAIN_BRANCH_DEVELOPMENT_IMPLEMENTATION_REPORT.md) | Report implementazione storico `f851b61` |
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
| [`BUILD_VALIDATION.md`](BUILD_VALIDATION.md) | `xcodegen`, scheme, build; troubleshooting GPS views / `xcodegen generate` |
| [`APP_ICON_UPDATE_NOTES.md`](APP_ICON_UPDATE_NOTES.md) | Icone app: `../Scripts/update_app_icons.sh`, Derived Data |
| [`RELEASE_CHECKLIST.md`](RELEASE_CHECKLIST.md) | Checklist release |
| [`SAFETY_DISCLAIMER.md`](SAFETY_DISCLAIMER.md) | Disclaimer (root Docs) |
| [`TERMS_OF_USE.md`](TERMS_OF_USE.md) | Destinazione dedicata per Termini d'uso da Watch/iOS |
| [`PRIVACY_AND_DATA_USE.md`](PRIVACY_AND_DATA_USE.md) | Destinazione dedicata per privacy / data use da Watch/iOS |
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
| 20260525 | [`DOCUMENTATION_UPDATE_REPORT_20260525.md`](DOCUMENTATION_UPDATE_REPORT_20260525.md) |
| 20260524 | [`DOCUMENTATION_UPDATE_REPORT_20260524.md`](DOCUMENTATION_UPDATE_REPORT_20260524.md), [`DOCUMENTATION_UPDATE_REPORT_20260524_CONTROL_STRATEGY.md`](DOCUMENTATION_UPDATE_REPORT_20260524_CONTROL_STRATEGY.md) |
| 20260523 | [`DOCUMENTATION_UPDATE_REPORT_20260523.md`](DOCUMENTATION_UPDATE_REPORT_20260523.md) |
| 20260522 | [`DOCUMENTATION_UPDATE_REPORT_20260522_LEGAL_ONBOARDING.md`](DOCUMENTATION_UPDATE_REPORT_20260522_LEGAL_ONBOARDING.md) |
| 20260520 | [`DOCUMENTATION_UPDATE_REPORT_20260520.md`](DOCUMENTATION_UPDATE_REPORT_20260520.md), [`DOCUMENTATION_UPDATE_REPORT_20260520_POST_RELEASE.md`](DOCUMENTATION_UPDATE_REPORT_20260520_POST_RELEASE.md) |
| 20260519 | [`DOCUMENTATION_UPDATE_REPORT_20260519.md`](DOCUMENTATION_UPDATE_REPORT_20260519.md), [`DOCUMENTATION_UPDATE_REPORT_20260519_I18N.md`](DOCUMENTATION_UPDATE_REPORT_20260519_I18N.md), [`DOCUMENTATION_UPDATE_REPORT_20260519_SECURITY.md`](DOCUMENTATION_UPDATE_REPORT_20260519_SECURITY.md), [`DOCUMENTATION_UPDATE_REPORT_20260519_SECURITY_PT2.md`](DOCUMENTATION_UPDATE_REPORT_20260519_SECURITY_PT2.md), [`DOCUMENTATION_UPDATE_REPORT_20260519_PRE_RELEASE_BACKLOG.md`](DOCUMENTATION_UPDATE_REPORT_20260519_PRE_RELEASE_BACKLOG.md) |

| Data | Branch alignment |
|------|------------------|
| 20260525 | [`DOCUMENTATION_BRANCH_ALIGNMENT_20260525.md`](DOCUMENTATION_BRANCH_ALIGNMENT_20260525.md) |
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
| [`generate_main_branch_complete_readiness_audit_current_docx.py`](generate_main_branch_complete_readiness_audit_current_docx.py) | Generatore legacy del pass pre-modifica poi archiviato come `MAIN_BRANCH_COMPLETE_READINESS_AUDIT_2026-05-25.docx` |
| [`generate_main_branch_complete_readiness_audit_20260520_docx.py`](generate_main_branch_complete_readiness_audit_20260520_docx.py) | Audit 20260520 docx |
| [`generate_main_branch_complete_readiness_audit_20260522_docx.py`](generate_main_branch_complete_readiness_audit_20260522_docx.py) | Audit 20260522 docx |
| [`generate_main_branch_complete_readiness_audit_20260523_docx.py`](generate_main_branch_complete_readiness_audit_20260523_docx.py) | Audit 20260523 docx |
| [`generate_main_branch_ux_interaction_accessibility_audit_20260523_docx.py`](generate_main_branch_ux_interaction_accessibility_audit_20260523_docx.py) | UX audit 20260523 docx |
| [`generate_main_branch_ux_interaction_accessibility_audit_20260524_docx.py`](generate_main_branch_ux_interaction_accessibility_audit_20260524_docx.py) | UX audit 20260524 docx |
| [`generate_main_branch_ux_interaction_accessibility_audit_20260524_post_dev_notes_docx.py`](generate_main_branch_ux_interaction_accessibility_audit_20260524_post_dev_notes_docx.py) | `MAIN_BRANCH_UX_INTERACTION_ACCESSIBILITY_AUDIT_20260524_POST_DEV_NOTES.docx` |
| [`generate_main_branch_ux_interaction_accessibility_audit_20260524_pre_mod_docx.py`](generate_main_branch_ux_interaction_accessibility_audit_20260524_pre_mod_docx.py) | UX audit PRE-MOD docx |
| [`generate_main_branch_readiness_audit_full_docx.py`](generate_main_branch_readiness_audit_full_docx.py) | Audit full |
| [`generate_main_readiness_audit_docx.py`](generate_main_readiness_audit_docx.py) | Readiness docx |
| [`generate_main_ux_audit_20260519_docx.py`](generate_main_ux_audit_20260519_docx.py) | UX 20260519 |
| [`generate_ux_roadmap_100_docx.py`](generate_ux_roadmap_100_docx.py) | Roadmap 100 docx |

---

## 12. Percorso rapido (30 minuti)

1. [`../README.md`](../README.md) — panoramica e branch strategy  
2. [`DIR_Diving_Complete_Development_Notes_UPDATED_v10.md`](DIR_Diving_Complete_Development_Notes_UPDATED_v10.md) — **backlog prodotto corrente** (iOS + Watch)
3. [`DIR_DIVING_v8_IMPLEMENTATION_REPORT.md`](DIR_DIVING_v8_IMPLEMENTATION_REPORT.md) — cosa è già implementato in codice (v8) @ `a36dc23`  
4. [`MAIN_BRANCH_COMPLETE_READINESS_AUDIT_2026-05-25.md`](MAIN_BRANCH_COMPLETE_READINESS_AUDIT_2026-05-25.md) — **§B, §M, §N, §O**  
5. [`DOCUMENTATION_UPDATE_REPORT_20260525.md`](DOCUMENTATION_UPDATE_REPORT_20260525.md) + [`DOCUMENTATION_BRANCH_ALIGNMENT_20260525.md`](DOCUMENTATION_BRANCH_ALIGNMENT_20260525.md) — allineamento documentazione/branch corrente
6. [`DIR_DIVING_Feature_Comparison.csv`](DIR_DIVING_Feature_Comparison.csv) — stato feature  
7. [`BUILD_VALIDATION.md`](BUILD_VALIDATION.md) — `xcodegen generate` + build  
8. [`WATCH_CONTROL_STRATEGY_IMPLEMENTATION_REPORT.md`](WATCH_CONTROL_STRATEGY_IMPLEMENTATION_REPORT.md) — se lavori su Watch  
9. [`TESTFLIGHT_ENTITLEMENT_AND_DEVICE_QA_20260523.md`](TESTFLIGHT_ENTITLEMENT_AND_DEVICE_QA_20260523.md) — se lavori su TestFlight / R1  

---

## 13. File fuori da `Docs/` collegati

| File | Ruolo |
|------|--------|
| [`../README.md`](../README.md) | Ingresso repository |
| [`../CHANGELOG.md`](../CHANGELOG.md) | Changelog |
| [`../CONTRIBUTING.md`](../CONTRIBUTING.md) | Regole contribuzione |
| [`../project.yml`](../project.yml) | XcodeGen / exclude experimental |

---

---

## 14. Elenco alfabetico — tutti i `.md` in `Docs/` (riferimento rapido)

| File | Sezione indice |
|------|----------------|
| [`APNEA_EXPERIMENTAL_SPEC.md`](APNEA_EXPERIMENTAL_SPEC.md) | §7 |
| [`APP_ICON_UPDATE_NOTES.md`](APP_ICON_UPDATE_NOTES.md) | §0, §6 |
| [`APP_INTENTS_DEVICE_QA_CHECKLIST.md`](APP_INTENTS_DEVICE_QA_CHECKLIST.md) | §4, §6 |
| [`ASCENT_ALARM_IMPLEMENTATION_REPORT_20260520.md`](ASCENT_ALARM_IMPLEMENTATION_REPORT_20260520.md) | §3 |
| [`BUILD_VALIDATION.md`](BUILD_VALIDATION.md) | §6, §12 |
| [`DEPTH_LIMIT_SAFETY_TEST_CHECKLIST.md`](DEPTH_LIMIT_SAFETY_TEST_CHECKLIST.md) | §3 |
| [`DEVELOPMENT_NOTES_25_05_2026_IMPLEMENTATION_REPORT.md`](DEVELOPMENT_NOTES_25_05_2026_IMPLEMENTATION_REPORT.md) | §0 |
| [`DIR_Diving_Complete_Development_Notes_25_05_2026.md`](DIR_Diving_Complete_Development_Notes_25_05_2026.md) | §0 |
| [`DIR_Diving_Complete_Development_Notes_UPDATED_v10.md`](DIR_Diving_Complete_Development_Notes_UPDATED_v10.md) | §0, §4, §12 |
| [`DIR_Diving_Complete_Development_Notes_UPDATED_v8.md`](DIR_Diving_Complete_Development_Notes_UPDATED_v8.md) | §0, §4 |
| [`DIR_Diving_Complete_Development_Notes_UPDATED_v9.md`](DIR_Diving_Complete_Development_Notes_UPDATED_v9.md) | §0, §12 |
| [`DIR_Diving_Main_Branch_Development_Notes.md`](DIR_Diving_Main_Branch_Development_Notes.md) | §4 |
| [`DIR_DIVING_MAIN_BRANCH_DEVELOPMENT_IMPLEMENTATION_REPORT.md`](DIR_DIVING_MAIN_BRANCH_DEVELOPMENT_IMPLEMENTATION_REPORT.md) | §4 |
| [`DIR_DIVING_v8_IMPLEMENTATION_REPORT.md`](DIR_DIVING_v8_IMPLEMENTATION_REPORT.md) | §0, §12 |
| `DOCUMENTATION_BRANCH_ALIGNMENT_20260517.md` … `20260525.md` | §2, §9 |
| [`DOCUMENTATION_SYNC_REPORT_20260519.md`](DOCUMENTATION_SYNC_REPORT_20260519.md) | §2 |
| `DOCUMENTATION_UPDATE_REPORT_20260519.md` … `20260525.md` | §9 |
| [`EXPERIMENTAL_FEATURES.md`](EXPERIMENTAL_FEATURES.md) | §7 |
| [`GLOSSARY.md`](GLOSSARY.md) | §5 |
| [`INDEX.md`](INDEX.md) | questo file |
| [`INTERNAL_TESTING_PLAYBOOK_20260520.md`](INTERNAL_TESTING_PLAYBOOK_20260520.md) | §6 |
| [`IOS_TAB_TARGET_MISMATCH_REPORT.md`](IOS_TAB_TARGET_MISMATCH_REPORT.md) | §4 |
| [`IOS_TAB_TARGET_MISMATCH_STATUS_20260519.md`](IOS_TAB_TARGET_MISMATCH_STATUS_20260519.md) | §4 |
| `MAIN_BRANCH_COMPLETE_READINESS_AUDIT_20260520.md` … `2026-05-25.md` (+ `.docx`) | §1 |
| [`MAIN_BRANCH_FINAL_READINESS_REPORT.md`](MAIN_BRANCH_FINAL_READINESS_REPORT.md) | §4 |
| [`MAIN_BRANCH_ISSUES_AND_PRIORITIES_20260520.md`](MAIN_BRANCH_ISSUES_AND_PRIORITIES_20260520.md) | §4 |
| [`MAIN_BRANCH_TARGETED_FIX_REPORT.md`](MAIN_BRANCH_TARGETED_FIX_REPORT.md) | §4 |
| [`MAIN_BRANCH_UX_INTERACTION_ACCESSIBILITY_AUDIT_20260523.md`](MAIN_BRANCH_UX_INTERACTION_ACCESSIBILITY_AUDIT_20260523.md) | §4 |
| [`MAIN_BRANCH_UX_INTERACTION_ACCESSIBILITY_AUDIT_20260524.md`](MAIN_BRANCH_UX_INTERACTION_ACCESSIBILITY_AUDIT_20260524.md) | §4 |
| [`MAIN_BRANCH_UX_INTERACTION_ACCESSIBILITY_AUDIT_20260524_CURRENT_PRE_MODIFICATION.md`](MAIN_BRANCH_UX_INTERACTION_ACCESSIBILITY_AUDIT_20260524_CURRENT_PRE_MODIFICATION.md) | §4 |
| [`MAIN_BRANCH_UX_INTERACTION_ACCESSIBILITY_AUDIT_20260524_POST_DEV_NOTES.md`](MAIN_BRANCH_UX_INTERACTION_ACCESSIBILITY_AUDIT_20260524_POST_DEV_NOTES.md) | §0, §4 |
| `MAIN_BRANCHES_UX_INTERACTION_AUDIT_20260518*.md`, `20260519*.md` | §8 |
| [`MAIN_ISSUES_IMPLEMENTATION_REPORT_20260520.md`](MAIN_ISSUES_IMPLEMENTATION_REPORT_20260520.md) | §4 |
| [`MAIN_PRE_RELEASE_OPEN_ITEMS_20260519.md`](MAIN_PRE_RELEASE_OPEN_ITEMS_20260519.md), [`MAIN_PRE_RELEASE_SIMULATOR_QA_20260519.md`](MAIN_PRE_RELEASE_SIMULATOR_QA_20260519.md) | §5, §6 |
| [`MAIN_READINESS_100_IMPLEMENTATION_REPORT_20260517.md`](MAIN_READINESS_100_IMPLEMENTATION_REPORT_20260517.md) | §8 |
| [`MAIN_UX_*`](MAIN_UX_COMPLETION_REPORT.md) | §8 |
| [`PHASE0_MAIN_UX_PREFLIGHT_PLAN.md`](PHASE0_MAIN_UX_PREFLIGHT_PLAN.md) | §8 |
| [`PRIVACY_AND_DATA_USE.md`](PRIVACY_AND_DATA_USE.md) | §6 |
| [`PR_STATUS_20260520.md`](PR_STATUS_20260520.md) … [`PR_STATUS_20260525.md`](PR_STATUS_20260525.md) | §2 |
| [`RELEASE_CHECKLIST.md`](RELEASE_CHECKLIST.md) | §6 |
| [`ROADMAP.md`](ROADMAP.md) | §5 |
| [`SAFETY_DISCLAIMER.md`](SAFETY_DISCLAIMER.md) | §6 |
| [`SECURITY_AUDIT_MAIN_AND_MAIN_IOS_20260519.md`](SECURITY_AUDIT_MAIN_AND_MAIN_IOS_20260519.md) | §6 |
| [`SNORKELING_EXPERIMENTAL_SPEC.md`](SNORKELING_EXPERIMENTAL_SPEC.md) | §7 |
| [`TESTFLIGHT_ENTITLEMENT_AND_DEVICE_QA_20260523.md`](TESTFLIGHT_ENTITLEMENT_AND_DEVICE_QA_20260523.md), [`TESTFLIGHT_REVIEW_NOTES.md`](TESTFLIGHT_REVIEW_NOTES.md) | §3, §12 |
| [`TERMS_OF_USE.md`](TERMS_OF_USE.md) | §6 |
| [`UI_UX_VISUAL_GUIDELINES.md`](UI_UX_VISUAL_GUIDELINES.md) | §10 |
| [`WATCH_CONTROL_STRATEGY_IMPLEMENTATION_REPORT.md`](WATCH_CONTROL_STRATEGY_IMPLEMENTATION_REPORT.md) | §3, §12 |
| [`WATCH_IOS_SYNC_DEVICE_QA_CHECKLIST.md`](WATCH_IOS_SYNC_DEVICE_QA_CHECKLIST.md) | §4, §6 |
| [`WATCH_MAIN_UX_CONVENTIONS.md`](WATCH_MAIN_UX_CONVENTIONS.md) | §3 |
| [`iOS/*.md`](iOS/BUILD_AND_RUN.md) | §4 |

Altri asset in `Docs/`: `.docx`, `.csv`, `.xlsx`, `.py` (generatori §11), `ReferenceUI/`, `ReferenceIcon/`, immagini §10.

---

*Indice per ripresa lavoro su `main` @ `ab398eb`. Baseline documentale corrente: README + audit dated 2026-05-25 + report/documentation alignment 2026-05-25.*
