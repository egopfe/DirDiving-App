# DIR Diving — Apple Watch: Crown & Buttons User Guide

**Audience:** Divers using DIR Diving on Apple Watch (especially Apple Watch Ultra)  
**Platform:** watchOS · DIR Diving Watch app  
**Updated:** 2026-06-27 · `main`

This guide explains how to navigate and control DIR Diving with **hardware** on Apple Watch. It reflects the current app design: **Crown = where you go**, **Action Button = do the main thing on this screen**.

---

## Quick summary

| Control | What DIR Diving uses it for |
|---------|----------------------------|
| **Digital Crown — rotate** | Move between app screens (vertical paging) |
| **Action Button (Ultra)** | Run the **primary safe action** for the current screen (recommended underwater) |
| **Touch / on-screen buttons** | Available on surface; not the primary underwater control |
| **Side Button** | **Not** used by DIR Diving as an app command |
| **Crown press** | **Not** used by DIR Diving as OK/confirm |

---

## Digital Crown — navigation

### Normal use (no active session)

Rotate the **Digital Crown** to move between DIR Diving screens in sequence:

1. **Live** — depth dashboard, stopwatch, dive controls  
2. **Compass** — heading and bearing  
3. **Settings** — app preferences  
4. **User Images** — reference photos from iPhone  
5. **Dive Log** — diving logbook (Diving activity only)

On first use, Live may show a hint: *“Turn the Digital Crown to reach Logbook, Settings, and Images.”*

You can also use Crown rotation to **scroll** inside some screens (e.g. Settings lists, alarm thresholds).

### During an active session (underwater)

Crown rotation still changes screens, but **only safe screens** are allowed:

| Activity | Screens you can reach with Crown |
|----------|----------------------------------|
| **Diving** | Live · Compass · User Images *(if images exist)* |
| **Apnea** | Live only |
| **Snorkeling** | Live only |

**Not reachable during a session:** Dive Log, Settings, mode selection.

If you turn the Crown to a blocked screen, DIR Diving returns you to **Live** and shows a short message.

### On-screen hint (active session)

While a session is active, a small overlay shows:

- **Crown: screen** — rotate to change page  
- **Action: …** — what the Action Button will do on this page  

---

## Action Button (Apple Watch Ultra)

DIR Diving does **not** control the Side Button. On **Apple Watch Ultra**, assign DIR Diving in:

**watchOS Settings → Action Button** (or **Shortcuts**)

### Recommended mapping underwater

Assign the shortcut **“Underwater Action”** (*Execute underwater action*).

That runs the **contextual primary action** for whatever screen is visible — you do not need a different mapping per screen.

### What “Underwater Action” does (by screen)

| Current screen | Action Button does | Notes |
|----------------|-------------------|--------|
| **Any screen + alarm showing** | **ACK** — dismiss alarm / overlay | Highest priority |
| **Live (Diving)** | **START** or **STOP** stopwatch | Depends on stopwatch state |
| **Compass** | **SET** or **UPDATE bearing** | Does **not** clear bearing |
| **User Images** | **NEXT IMAGE** | Cycles photos; needs images loaded |
| **Other / unavailable** | Short haptic + “Action unavailable” | e.g. Apnea Live, Full Computer with stopwatch hidden |

DIR Diving **does not** use the Action Button to:

- Start or end a full dive session by itself (except existing manual-dive shortcuts — see below)  
- Reset the stopwatch underwater (primary action)  
- Clear compass bearing underwater (primary action)  
- Change Diving / Apnea / Snorkeling mode during a session  
- Change decompression or gas settings  

### Other shortcuts (Shortcuts app)

These remain available for **Shortcuts** or optional Action Button assignment (surface or custom workflows):

| Shortcut name | Typical use |
|---------------|-------------|
| Toggle stopwatch | Start/stop stopwatch |
| Reset stopwatch | Reset to zero *(use carefully)* |
| Start manual dive | Start manual dive session |
| End manual dive | End manual dive session |
| Set bearing | Set compass bearing |
| Clear bearing | Clear saved bearing |
| Acknowledge alarm | Dismiss Live alarm banner |
| Open Water Mode | Open water-entry startup destination |
| **Underwater Action** | **Recommended for Ultra Action Button in water** |

All shortcuts require **legal/safety acceptance** in the app before they run.

---

## Water entry — automatic startup (optional)

**Settings → Startup → When Apple Watch enters water**

| Option | Behavior |
|--------|----------|
| **Disabled** | Normal cold launch |
| **Last selected mode** | Opens last activity/mode you completed |
| **Preferred mode** | Opens your chosen activity (+ Diving mode if Diving) |

This **opens the right screen** when watchOS launches DIR Diving after water entry. It does **not** start a dive, Apnea, or Snorkeling session automatically.

**Full Computer:** always goes through **pre-dive configuration and confirmation** — never straight into live decompression runtime.

**System note:** Apple’s list *Settings → General → Auto-Launch → When Submerged* is controlled by **watchOS and entitlements**. DIR Diving can prepare the destination but cannot guarantee appearing in that system list.

---

## Water Lock

With **Water Lock** enabled, the touchscreen is disabled. That is why DIR Diving is designed around:

- **Crown rotation** for navigation  
- **Action Button** for the primary action  

Physical validation with Water Lock on Apple Watch Ultra is still pending in project QA. Test carefully in shallow water before relying on hardware controls in demanding conditions.

---

## What DIR Diving does not claim

- Certified dive computer or substitute for training and judgment  
- Control of the **Side Button** or **Crown press** as app inputs  
- Double-click or unverified long-press gestures  
- Guaranteed presence in Apple’s system Auto-Launch submerged list  

---

## Troubleshooting

| Problem | What to check |
|---------|----------------|
| Crown doesn’t change screen | Session may block that page; check overlay hint |
| Action Button does nothing | Assign **Underwater Action** in watchOS Settings → Action Button |
| “Action unavailable” | Wrong screen for action (e.g. Apnea Live), no images, or Full Computer hiding stopwatch |
| Shortcut fails | Complete legal onboarding in app first |
| Settings blocked underwater | By design in current release (safety-first) |

---

## Related technical docs

- [`WATCH_UNDERWATER_FAST_CONTROLS.md`](WATCH_UNDERWATER_FAST_CONTROLS.md) — implementation policy  
- [`WATCH_WATER_AUTO_OPEN_POLICY.md`](WATCH_WATER_AUTO_OPEN_POLICY.md) — water-entry startup  
- [`APP_INTENTS_DEVICE_QA_CHECKLIST.md`](APP_INTENTS_DEVICE_QA_CHECKLIST.md) — QA checklist for intents  

---

# DIR Diving — Apple Watch: Corona e pulsanti (guida utente)

**Pubblico:** Subacquei che usano DIR Diving su Apple Watch (in particolare Apple Watch Ultra)  
**Piattaforma:** watchOS · app Watch DIR Diving  

Guida all’uso di **Corona** e **Action Button** in DIR Diving: **Corona = dove vai**, **Action Button = azione principale su questa schermata**.

---

## Riepilogo

| Controllo | Uso in DIR Diving |
|-----------|-------------------|
| **Corona digitale — rotazione** | Cambiare schermata (paging verticale) |
| **Action Button (Ultra)** | Azione sicura principale della schermata corrente |
| **Tocco / pulsanti a schermo** | Disponibili in superficie; non controllo primario sott’acqua |
| **Tasto laterale** | **Non** usato da DIR Diving |
| **Pressione Corona** | **Non** usata come OK/conferma |

---

## Corona digitale — navigazione

### Uso normale (nessuna sessione attiva)

Ruota la **Corona** per spostarti tra le schermate:

1. **Live** — profondità, cronometro, controlli  
2. **Bussola** — rotta e bearing  
3. **Impostazioni**  
4. **Immagini** — foto di riferimento dall’iPhone  
5. **Logbook** — solo attività Diving  

### Durante una sessione attiva

| Attività | Schermate raggiungibili con la Corona |
|----------|--------------------------------------|
| **Diving** | Live · Bussola · Immagini *(se presenti)* |
| **Apnea** | Solo Live |
| **Snorkeling** | Solo Live |

Logbook, Impostazioni e selezione modalità **non** sono raggiungibili durante la sessione.

### Hint a schermo

Durante la sessione compare un overlay:

- **Corona: schermata**  
- **Action: …** — azione dell’Action Button su questa pagina  

---

## Action Button (Apple Watch Ultra)

Assegna in **Impostazioni watchOS → Action Button** (o **Comandi rapidi**).

### Mapping consigliato sott’acqua

**“Azione subacquea”** (*Esegui azione subacquea*) — azione contestuale della schermata visibile.

| Schermata | Action Button |
|-----------|---------------|
| **Allarme attivo** | **ACK** — conferma/chiudi |
| **Live (Diving)** | **START** / **STOP** cronometro |
| **Bussola** | **IMPOSTA** / **AGGIORNA bussola** (non cancella) |
| **Immagini** | **IMMAGINE SUCCESSIVA** |
| **Non disponibile** | Avviso aptico + messaggio |

L’Action Button **non** avvia sessioni, **non** resetta il cronometro (azione primaria), **non** cancella la bussola, **non** cambia modalità o impostazioni deco.

---

## Ingresso in acqua (opzionale)

**Impostazioni → Avvio → Quando Apple Watch entra in acqua**

- **Disattivato** · **Ultima modalità** · **Modalità preferita**

Apre la destinazione scelta; **non** avvia automaticamente una sessione. **Full Computer** richiede sempre configurazione e conferma pre-immersione.

La lista di sistema *Apertura automatica → Quando immerso* dipende da **watchOS**; DIR Diving non può garantirne la presenza.

---

## Water Lock

Con **Blocco acqua** attivo, il touch è disabilitato: usa **rotazione Corona** e **Action Button**.

---

## Risoluzione problemi

| Problema | Verifica |
|----------|----------|
| Corona non cambia schermata | Pagina bloccata durante sessione |
| Action Button inattivo | Assegna **Azione subacquea** in Impostazioni watchOS |
| “Azione non disponibile” | Schermata o stato non compatibile |
| Comando rapido fallisce | Completa onboarding legale nell’app |

---

## Documentazione correlata

- [`WATCH_UNDERWATER_FAST_CONTROLS.md`](WATCH_UNDERWATER_FAST_CONTROLS.md)  
- [`WATCH_WATER_AUTO_OPEN_POLICY.md`](WATCH_WATER_AUTO_OPEN_POLICY.md)  
- [`APP_INTENTS_DEVICE_QA_CHECKLIST.md`](APP_INTENTS_DEVICE_QA_CHECKLIST.md)  
