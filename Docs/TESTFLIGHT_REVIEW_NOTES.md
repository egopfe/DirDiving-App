# Note per TestFlight / App Review - DIR DIVING

**Aggiornato:** 2026-05-26 - branch `main` (Watch + iOS companion unificati)

## Panoramica per il revisore

DIR DIVING e uno strumento companion per Apple Watch Ultra e iPhone: **log immersioni**, monitoraggio profondita dove l'entitlement lo consente, **consapevolezza risalita** (banner non bloccante), **BUSSOLA**, **GPS di superficie** (ingresso/uscita), sync Watch/iPhone ed export CSV Subsurface. Include planner **indicativo** su iOS, non certificato.

L'app **non** e presentata come computer subacqueo certificato.

## Account e dati demo

- In iOS **Altro -> REVIEWER** e disponibile il toggle **Logbook dimostrativo** (5 immersioni demo) per revisione senza Apple Watch fisico.
- Disattivare il demo per test con dati reali.

## Permessi

| Permesso | Uso |
|----------|-----|
| Posizione (Watch/iOS) | GPS superficie, bussola |
| Motion / water submersion (Watch) | Profondita su Ultra; richiede entitlement Apple |
| iCloud KVS | Backup opzionale log/impostazioni |
| WatchConnectivity | Sync log Watch <-> iPhone |

## Lingue

- Watch: Impostazioni -> **Lingua** (Sistema / Italiano / English).
- iOS: Altro -> **Lingua** (segmented).
- La lingua **non** cambia unita ne calcoli. MAIN stabile e allineato IT/EN nei flussi principali; eventuali verifiche residue restano QA device-side, non blocker repo-side.

## Limitazioni note (da dichiarare)

1. **Non** computer subacqueo certificato.
2. Planner e TTV **informativi**: non NDL/TTS certificati.
3. GPS **inaffidabile** sott'acqua.
4. Profondita automatica: validare su **Apple Watch Ultra** reale dopo approvazione entitlement e provisioning corretto.
5. Side Button / Action Button Watch: l'app **non** puo intercettare direttamente il tasto laterale. Controlli immersione affidabili restano **START / STOP / RESET** sullo schermo Live. Comandi aggiuntivi (cronometro, immersione manuale, BUSSOLA, allarme) sono disponibili tramite **Comandi Rapidi / Action Button** solo dove watchOS espone gli App Intent registrati — vedi Impostazioni -> Azione / Comandi.
6. Mission Mode e solo un profilo di ottimizzazione runtime/UI per immersione attiva: non riduce monitoraggio safety-critical, non modifica logica immersione o sensori e usa solo un indicatore visivo minimale.
7. Terms / Privacy da onboarding e settings puntano a documenti dedicati, non alla root del repository.

## Checklist QA consigliata (reviewer)

- [ ] Pairing Watch + iPhone; sync log Watch -> iPhone
- [ ] Delete su iPhone -> non resurrezione su Watch (tombstone)
- [ ] Delete su Watch -> non resurrezione su iPhone
- [ ] Live dive: profondita, gauge risalita, TTV, cronometro visibili con banner GPS compatto
- [ ] Banner risalita rosso: gauge e profondita restano visibili
- [ ] Allarme: pulsante OK + cooldown
- [ ] Surface state Watch: **Start Dive** visibile e avvio manuale disponibile senza rimuovere l'avvio automatico da profondita
- [ ] Mission Mode: toggle Settings + indicatore header verificati; nessun cambiamento ai dati safety-critical
- [ ] Export CSV Subsurface da dettaglio immersione
- [ ] Planner: disclaimer visibile; output indicativo
- [ ] Settings / More: link Terms / Privacy raggiungibili e leggibili
- [ ] Lingua EN: Settings, log, sync senza italiano evidente nelle schermate principali

## Build (interno)

```bash
xcodegen generate
xcodebuild -scheme "DIRDiving Watch App" -destination 'platform=watchOS Simulator,name=Apple Watch Ultra 3 (49mm)' build
xcodebuild -scheme "DIRDiving iOS" -destination 'platform=iOS Simulator,name=iPhone 17' build
```

Runtime iOS 26.5 / watchOS 26.5: Xcode -> Settings -> Components. Vedi [`Docs/BUILD_VALIDATION.md`](BUILD_VALIDATION.md).

## Rami non inclusi in questa build MAIN

Apnea, Snorkeling, Buddy Assist: solo su branch `codex/experimental-features` / `codex/ios-experimental-features`. **Non** mergeare in candidata App Store senza review.

## Contatto / supporto

Repository: https://github.com/egopfe/DirDiving-App
Disclaimer completo: [`Docs/SAFETY_DISCLAIMER.md`](SAFETY_DISCLAIMER.md)
