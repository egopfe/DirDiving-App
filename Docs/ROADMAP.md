# Roadmap DIR DIVING

**Aggiornato:** 2026-05-22

## Rilasciati su `main` (Watch MAIN + iOS nel workspace)

| Area | Stato | Note |
|------|--------|------|
| Diving live (depth, TTV, RunTime, gauge) | ✅ | UI baseline `MASTER_REFERENCE_DIVING_LIVE` |
| Banner risalita inline | ✅ | 2026-05-20, non full-screen |
| GPS ingresso/uscita superficie | ✅ | Banner compatto ~1.4 s |
| Bussola SET/CLEAR bearing | ✅ | Terminologia BUSSOLA |
| Log + export Subsurface CSV | ✅ | |
| Sync Watch ↔ iOS + tombstone unificata | ✅ | `a75a6c3` manual port backlog |
| Security F1-F12 | ✅ | Audit 2026-05-19 |
| i18n IT/EN (primario + secondario) | 🟡 | Selettore lingua; migrazione stringhe in corso |
| Onboarding legale + disclaimer IT/EN | ✅ | First launch, major update re-consent, Legal & Safety |
| Entitlement profondità Ultra | 🟡 | Configurato; validazione hardware aperta |

## Prossimo (MAIN, pre–App Store)

| Priorità | Item | Tipo |
|----------|------|------|
| P0 | Validazione depth su Watch Ultra reale | QA / Apple |
| P1 | QA pairing sync bidirezionale su device | QA |
| P2 | Completare i18n planner/GPS detail iOS | Localization |
| P2 | Verifica legale contenuti Terms/Privacy URL prima App Store | Legal / App Store |
| P2 | Convergenza documentazione `main` ↔ `main-iOS` | Process |
| P3 | Hide tab UserImages se bundle vuoto | UX |
| P3 | GPX/UDDF export | Feature |
| P4 | Settings sync bidirezionale unità | Feature |

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
