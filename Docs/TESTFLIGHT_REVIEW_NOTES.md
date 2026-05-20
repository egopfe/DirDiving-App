# Note per TestFlight / App Review — DIR DIVING

**Aggiornato:** 2026-05-20 · branch `main` (Watch) + `main-iOS` (companion)

## Panoramica per il revisore

DIR DIVING è uno strumento di **log immersioni**, **consapevolezza risalita** (banner non bloccante), **bussola**, **GPS di superficie** (ingresso/uscita) e **sync** con companion iPhone. Include planner **indicativo** su iOS, non certificato.

## Account e dati demo

- In iOS **Altro → REVIEWER** è disponibile il toggle **Logbook dimostrativo** (5 immersioni demo) per revisione senza Apple Watch fisico.
- Disattivare il demo per test con dati reali.

## Permessi

| Permesso | Uso |
|----------|-----|
| Posizione (Watch/iOS) | GPS superficie, bussola |
| Motion / water submersion (Watch) | Profondità su Ultra (richiede entitlement Apple) |
| iCloud KVS | Backup opzionale log/impostazioni |
| WatchConnectivity | Sync log Watch ↔ iPhone |

## Lingue

- Watch: Impostazioni → **Lingua** (Sistema / Italiano / English).
- iOS: Altro → **Lingua** (segmented).
- La lingua **non** cambia unità né calcoli. Copertura EN estesa su schermate secondarie (2026-05-20); alcune stringhe planner/technical possono restare miste.

## Limitazioni note (da dichiarare)

1. **Non** computer subacqueo certificato.
2. Planner e TTV **informativi** — non NDL/TTS certificati.
3. GPS **inaffidabile** sott'acqua.
4. Profondità automatica: validare su **Apple Watch Ultra** reale dopo entitlement.
5. Side button Watch: **non** intercettabile dall'app; usare App Intents / Shortcuts dove supportato.

## Checklist QA consigliata (reviewer)

- [ ] Pairing Watch + iPhone; sync log Watch → iPhone
- [ ] Delete su iPhone → non resurrezione su Watch (tombstone)
- [ ] Delete su Watch → non resurrezione su iPhone
- [ ] Live dive: profondità, gauge risalita, TTV, cronometro visibili con banner GPS compatto
- [ ] Banner risalita rosso: gauge e profondità restano visibili
- [ ] Allarme: pulsante OK + cooldown
- [ ] Export CSV Subsurface da dettaglio immersione
- [ ] Planner: disclaimer visibile; output indicativo
- [ ] Lingua EN: Settings, log, sync senza italiano evidente nelle schermate principali

## Build (interno)

```bash
xcodegen generate
xcodebuild -scheme "DIRDiving Watch App" -destination 'platform=watchOS Simulator,name=Apple Watch Ultra 3 (49mm)' build
xcodebuild -scheme "DIRDiving iOS" -destination 'platform=iOS Simulator,name=iPhone 17' build
```

Runtime iOS 26.5 / watchOS 26.5: Xcode → Settings → Components. Vedi [`Docs/BUILD_VALIDATION.md`](BUILD_VALIDATION.md).

## Rami non inclusi in questa build MAIN

Apnea, Snorkeling, Buddy Assist — solo su branch `codex/experimental-features` / `codex/ios-experimental-features`. **Non** mergeare in candidata App Store senza review.

## Contatto / supporto

Repository: https://github.com/egopfe/DirDiving-App  
Disclaimer completo: [`Docs/SAFETY_DISCLAIMER.md`](SAFETY_DISCLAIMER.md)
