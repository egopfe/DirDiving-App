# Glossario utente — DIR DIVING (MAIN)

Testi di supporto per README, schermate e VoiceOver. **Non sostituiscono formazione subacquea né manuali di decompressione.**

| Termine | Significato in-app (descrittivo) | Nota |
|--------|-----------------------------------|--------|
| **TTV** | Valore informativo mostrato in log/live in relazione a profondità media e tempo di immersione (wording esatto dipende dalla schermata). | **Non** è automaticamente equivalente a NDL, TTS o “tempo al superficie” di un computer certificato. |
| **TTR** | Se compare nel companion iOS, indica un indicatore temporale presentato in contesto analitico o di dettaglio. | Verificare nel codice/label se è **sinonimo presentazionale** di TTV o una metrica distinta; **non** cambiare il calcolo numerico senza revisione tecnica. |
| **SAC** | Surface Air Consumption / consumo indicativo in litri/minuto derivato dai dati di sessione. | Dipende da qualità dei campioni e ipotesi sul cilindro; valore indicativo. |
| **MOD** | Maximum Operating Depth per il mix gas corrente e PPO2 massima impostata. | Limite teorico da cross-check con tabelle e procedure reali. |
| **PPO2** | Pressione parziale ossigeno prevista per il gas in uso alla profondità considerata. | Supervisione umana obbligatoria. |
| **CNS** | Indice frazionario ossigeno cumulativo (modello in planner). | Indicativo; non sostituisce analisi da strumenti certificati. |
| **OTU** | Oxygen Toxicity Unit (modello in planner). | Indicativo. |
| **Punto GPS ingresso** | Coordinata (o fallback etichettato) salvato in **superficie** all’inizio sessione quando i permessi e il segnale lo consentono. | GPS in acqua è inaffidabile o assente. |
| **Punto GPS uscita** | Come sopra, alla fine sessione in superficie. | Può mancare: mostrare stato “non disponibile” senza tono da “successo” ingannevole. |
| **Velocità di risalita** | Stima o misura della velocità verticale verso la superficie, confrontata con limiti configurati. | I colori del gauge sono **feedback visivo** su soglie già definite dall’app; questo glossario non modifica soglie. |
| **Runtime / RunTime** | Tempo trascorso dall’avvio cronometro / sessione secondo la logica dell schermata. | Distinto dal TTV salvo dove l’UI li accoppia esplicitamente. |

## Mapping terminologico (direzionale)

| Concetto | Watch (file tipici) | iOS (file tipici) | README |
|----------|---------------------|-------------------|--------|
| TTV / messaggio sicurezza | `DiveLiveView`, `SettingsView` | `DiveDetailView`, `MoreView` | Sezioni Safety / Features |
| GPS superficie | `DiveLiveView`, `SettingsView` | `DiveDetailView`, `MoreView` | Paragrafo GPS |
| Export CSV | `DiveLogListView`, `ExportView` | `DiveDetailView`, `MoreView` | Features |

---

*Solo documentazione; nessuna modifica a formule o persistenza.*
