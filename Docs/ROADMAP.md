# Roadmap DIR DIVING

**Aggiornato:** 2026-05-26 (`main` base `2322145`, con pass documentale corrente)

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
| i18n IT/EN (primario + secondario) | ✅ | Pass principali chiusi su MAIN stabile; eventuali affinamenti futuri sono polish, non blocker repo-side |
| Onboarding legale + disclaimer IT/EN | ✅ | First launch, major update re-consent, Legal & Safety |
| Planner safety acknowledgment | ✅ | Persistito `2026-05-24` (`62e25d5`); toggle obbligatorio prima di Calcola Piano |
| iCloud decode error UI (iOS) | ✅ | `62e25d5` — `lastDecodeError` in Altro |
| i18n Logbook/Detail/Analysis (iOS) | ✅ | Copertura MAIN riallineata nei pass readiness 2026-05-24/25 |
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
| Marchio altosinistra header | ✅ | Asset bundled nel design system corrente |
| Planner gas v8 (cilindri, ruoli, Air/EAN/Trimix, MOD) | ✅ | `a36dc23` |
| Equipment template «La mia attrezzatura» + GAS switch | ✅ | `a36dc23` |
| Foto iPhone→Watch con validazione/resize | ✅ | `a36dc23` |
| Watch User Images in superficie (tab sempre) | ✅ | `d962117` |
| Planner/Bühlmann sync su input gas | ✅ | `d962117` — algoritmo Bühlmann invariato |
| Start Dive manuale visibile su Watch | ✅ | `2322145` — avvio manuale in superficie senza disattivare l'avvio automatico |
| Mission Mode Watch + indicatore attivo | ✅ | Working tree/doc pass 2026-05-26; ottimizzazione runtime/UI senza regressioni safety-critical documentate |
| Terms / Privacy dedicati | ✅ | Docs legali dedicate usate da Watch e iOS onboarding/settings |
| Sync activity recente Watch/iOS | ✅ | Visibilita recente per photo/session activity senza alterare il protocollo |
| Safeguard reset cronometro Watch | ✅ | Conferma esplicita quando esiste tempo da resettare |
| Docs / audit alignment 2026-05-25 | ✅ | README, INDEX, safety/release docs e matrix riallineati al MAIN corrente |
| Docs / branch / PR alignment 2026-05-26 | ✅ | README, INDEX, roadmap, current audits, branch/PR reports riallineati alla baseline MAIN attuale |

## Prossimo (MAIN, pre–App Store)

| Priorità | Item | Tipo |
|----------|------|------|
| P0 | Approvazione entitlement water-submersion + provisioning aggiornato | Apple Developer / Signing — [`TESTFLIGHT_ENTITLEMENT_AND_DEVICE_QA_20260523.md`](TESTFLIGHT_ENTITLEMENT_AND_DEVICE_QA_20260523.md) |
| P0 | Build generici firmati Watch + iOS con target embedded | Release / QA |
| P1 | QA reale Apple Watch Ultra per lifecycle automatico, profondita e limiti 35/38/40 m | Hardware QA |
| P1 | QA pairing/sync bidirezionale su device | Hardware QA |
| P1 | QA App Intents / Action Button su Watch fisico | Hardware QA |
| P2 | Verifica finale legale contenuti Terms/Privacy e copy App Review | Legal / App Store |
| P2 | Convergenza documentazione `main` ↔ worktree storici (`main-iOS`, `codex/*`) senza merge runtime unsafe | Process |
| P3 | GPX/UDDF export | Feature |
| P3 | Rigenerare e validare AppIcon store da `Docs/ReferenceIcon/` | Assets |
| P4 | Eventuale ledger sync per-session persistente oltre la recente activity | UX / diagnostics |

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
