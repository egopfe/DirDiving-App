# Release checklist — DIR DIVING MAIN

Compilare su **macOS** dopo `xcodegen generate`. Non spuntare voci non verificate.

## Metadati release

| Campo | Valore |
|-------|--------|
| Data | __________ |
| Commit `HEAD` | __________ |
| Esecutore | __________ |

## Build

- [ ] `xcodegen generate` senza errori  
- [ ] `xcodebuild` **DIRDiving Watch App** — `generic/platform=watchOS` — **PASS**  
- [ ] `xcodebuild` **DIRDiving iOS** — `generic/platform=iOS` — **PASS**  

## Device matrix (manuale)

- [ ] Apple Watch **Ultra** — live screen, gauge, START/STOP/RESET, testi non tagliati  
- [ ] Apple Watch **41/45 mm** — stesse schermate  
- [ ] iPhone **piccolo** (es. SE class) — tab bar + Logbook  
- [ ] iPhone **Pro Max** — card e grafici  
- [ ] GPS **negato** — copy coerente, nessun “successo” verde fuorviante  
- [ ] Nessun iPhone / WatchConnectivity disattivato — messaggio sync chiaro  
- [ ] iCloud **non disponibile** — stato backup chiaro  
- [ ] Logbook **vuoto** — empty state + passi successivi  
- [ ] Export **fallito** — messaggio esplicito  
- [ ] Aptica Watch **off** — badge “avvisi solo visivi” visibile  

## Sicurezza / copy

- [ ] Disclaimer MAIN visibile (iOS `MoreView` / README)  
- [ ] Nessun claim di certificazione non supportato  

## Firma

Approvazione release: __________________ Data: ________

---

*Checklist documentale; non modifica il codice.*
