# Roadmap DIR DIVING

**Aggiornato:** 2026-05-20 (`main` @ `d962117`)

## Rilasciati su `main` (Watch MAIN + iOS nel workspace)

| Area | Stato | Note |
|------|--------|------|
| Diving live (depth, TTV, RunTime, gauge) | ✅ | UI baseline `MASTER_REFERENCE_DIVING_LIVE` |
| Banner risalita inline | ✅ | 2026-05-20, non full-screen |
| GPS ingresso/uscita superficie | ✅ | Banner compatto ~1.4 s |
| Bussola SET/CLEAR bearing | ✅ | Terminologia BUSSOLA |
| Log + export Subsurface CSV | ✅ | |
| Sync Watch ↔ iOS + tombstone unificata | ✅ | `a75a6c3` manual port backlog |
| Sync iPhone → Watch (session push) | ✅ | `5e595ee` outbound queue + More push |
| UI conflitti sync iOS | ✅ | `5e595ee` card in More |
| Security F1-F12 | ✅ | Audit 2026-05-19 |
| i18n IT/EN (primario + secondario) | 🟡 | Pass 2026-05-23; alcune righe Settings/shortcut ancora IT-key |
| Onboarding legale + disclaimer IT/EN | ✅ | First launch, major update re-consent, Legal & Safety |
| Planner safety acknowledgment | ✅ | Persistito `2026-05-24` (`62e25d5`); toggle obbligatorio prima di Calcola Piano |
| iCloud decode error UI (iOS) | ✅ | `62e25d5` — `lastDecodeError` in Altro |
| i18n Logbook/Detail/Analysis (iOS) | 🟡 | R4 `62e25d5`; Planner/Equipment ancora misto |
| 7 App Shortcuts Watch | ✅ | `db72dce` |
| Strategia controlli Watch | ✅ | `72fa15b`; Crown/touch/App Intents/Side Button documentati |
| Digital Crown tuning soglie | ✅ | Allarmi + limiti risalita; touch fallback mantenuto |
| Feedback SET/CLEAR bearing | ✅ | Toast IT/EN + haptic confirm |
| Ascent gauge imperial labels | ✅ | `db72dce` (lista log: TODO unità `3b7358b`) |
| Mode Selection auto-skip (solo Diving) | ✅ | Cold launch → Live |
| Entitlement profondità Ultra | 🟡 | Configurato su `com.egopfe.dirdiving.ios.watch`; validazione hardware aperta |
| Depth limits 35/38/40 m UI + haptics | ✅ | `6cda004` |
| CSV import sempre in Logbook/More | ✅ | Readiness 100% UX pass |
| Planner tab risultato funzionali | ✅ | Readiness 100% UX pass |
| Legal disclaimer scroll gate | ✅ | Readiness 100% UX pass |
| Unità metriche/imperiali + sync WC | ✅ | `f851b61`; display-only, storage metrico |
| Disclaimer companion ogni avvio | ✅ | `f851b61` |
| Immersioni manuali iOS + export meta CSV | ✅ | `f851b61` |
| Checklist attrezzatura editabile iOS | ✅ | `f851b61` |
| Foto iPhone → Watch (UserImages) | ✅ | `f851b61` transferFile |
| Tab iOS Planner prima | ✅ | `f851b61` |
| Planner ack in cima + field gate | ✅ | Persistenza `62e25d5`; gate campi `f851b61` |
| Marchio altosinistra header | 🟡 | PNG bundled; AppIcon store da rigenerare |
| Planner gas v8 (cilindri, ruoli, Air/EAN/Trimix, MOD) | ✅ | `a36dc23` |
| Equipment template «La mia attrezzatura» + GAS switch | ✅ | `a36dc23` |
| Foto iPhone→Watch con validazione/resize | ✅ | `a36dc23` |
| Watch User Images in superficie (tab sempre) | ✅ | `d962117` |
| Planner/Bühlmann sync su input gas | ✅ | `d962117` — algoritmo Bühlmann invariato |

## Prossimo (MAIN, pre–App Store)

| Priorità | Item | Tipo |
|----------|------|------|
| P0 | Validazione depth su Watch Ultra reale (R1) | QA / Apple — [`TESTFLIGHT_ENTITLEMENT_AND_DEVICE_QA_20260523.md`](TESTFLIGHT_ENTITLEMENT_AND_DEVICE_QA_20260523.md) |
| P1 | Ripristinare unità imperiali in lista log Watch | UX — regressione `3b7358b` |
| P1 | QA pairing sync bidirezionale su device | QA |
| P2 | Completare i18n residuo (Settings shortcut, InfoView) | Localization |
| P2 | Verifica legale contenuti Terms/Privacy URL prima App Store | Legal / App Store |
| P2 | Convergenza documentazione `main` ↔ `main-iOS` | Process |
| P3 | GPX/UDDF export | Feature |
| P3 | Rigenerare AppIcon da `Docs/ReferenceIcon/` | Assets |
| P4 | Watch back navigation audit su tutte le sub-screen | UX |
| P4 | Valutare long-press STOP/RESET solo dopo decisione prodotto | UX safety |

## Rami experimental (non in target MAIN)

| Feature | Branch | Stato |
|---------|--------|--------|
| Snorkeling Live | `codex/experimental-features` | Experimental |
| Mappa Waypoint / Mappa Ritorno | idem | UI-only / Experimental |
| Return-to-entry snorkeling | idem | Experimental |
| Apnea workflow esteso | idem | Experimental |
| Buddy Assist | idem | Experimental |
| iOS Explore Lab / Buddy Lab | `codex/ios-experimental-features` | Experimental |

Merge verso `main` solo con review esplicita e senza regressioni security (vedi PR #8, #9).

## Non in scope (vincoli prodotto)

- Modifiche algoritmi decompressione / TTV-TTR business senza issue dedicata
- GPS subacqueo come tracking certificato
- Certificazione computer subacqueo implicita

---

Dettaglio backlog: [`Docs/MAIN_BRANCH_ISSUES_AND_PRIORITIES_20260520.md`](MAIN_BRANCH_ISSUES_AND_PRIORITIES_20260520.md)
