# UI / UX visual guidelines — MAIN

## Riferimenti immagine (repository)

| Piattaforma | File |
|-------------|------|
| Apple Watch live | `Docs/ReferenceUI/Watch_LIVE_reference.png` |
| iOS Companion | `Docs/ReferenceUI/iOS_Companion_reference.png` |

## Watch — principi

- Canvas **nero**; metriche grandi; etichette ciano/blu per acqua e profondità.  
- Stato immersione **verde**; cronometro **giallo**; pericolo **rosso**.  
- Pannelli con **angoli arrotondati** e **bordo sottile** (neon).  
- **START / STOP / RESET** sempre leggibili (guanti / movimento).  
- Gauge risalita sempre visibile accanto al blocco profondità.  
- Evitare card “dashboard” generiche: usare `DivePanel` / `DiveScreenBackground`.

## iOS — principi

- Sfondo **dark marine** (`DIRTheme.background`), card charcoal, accento **ciano**.  
- **Cinque tab** companion: Logbook, Analisi, Planner, Attrezzatura, Altro.  
- Azione primaria: bottone pieno ciano; secondaria: outline / ghost.  
- Grafici: assi discreti, contrasto su griglia.  

## Cosa non fare su MAIN

- Non importare view/store da file **esclusi** in `project.yml` per il target iOS.  
- Non introdurre layout che richiedono nuova logica di business per funzionare.

---

*Linee guida documentali.*
