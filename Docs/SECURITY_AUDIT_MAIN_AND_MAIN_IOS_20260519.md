# DIR DIVING — Information Security Audit

**Data:** 2026-05-19
**Branch in scope:** `main` (HEAD `e8b70a2`) e `origin/main-iOS` (HEAD `06057d7`)
**Tipologia:** Audit statico solo su codice sorgente. Nessun `xcodebuild` o test runtime eseguito (ambiente Windows).
**Documento di:** documentazione interna; il report è additivo e non modifica codice o algoritmi.

---

## 0. Executive summary

| # | Severity | Area | Branch | Finding sintetico |
|---|----------|------|--------|-------------------|
| F1 | **HIGH** | Build / Auth | `main` | `iOSApp/Services/WatchSyncService.swift:52` chiama `WatchSyncAuth.resetPeerTrust()` ma il metodo **non è definito** su `main`. Compile error sul target `DIRDiving iOS`. |
| F2 | **HIGH** | Crypto protocol drift | `main` ↔ `main-iOS` | `WatchSyncAuth.syncKey(peerBundleID:)` ha **due algoritmi incompatibili** sui due branch. Se Watch=`main` e iOS=`main-iOS` venissero buildati e accoppiati, gli HMAC non corrisponderebbero → tutte le immersioni rifiutate per `invalidSignature`. |
| F3 | **MEDIUM** | Data-at-rest | `main` (Watch) | `Services/SubsurfaceExportService.swift` scrive il CSV in `tmp/` senza `.completeFileProtection` e senza cleanup. Coordinate GPS leggibili a dispositivo bloccato. |
| F4 | **MEDIUM** | Data-at-rest | `main-iOS` (iOS) | `iOSApp/Services/SubsurfaceExportService.swift` **rimuove** `.completeFileProtection` e `cleanupTemporaryExports()` presenti su `main`. Regressione di hardening. |
| F5 | **MEDIUM** | Input validation | `main-iOS` (iOS) | `iOSApp/Services/DiveImportService.swift` rimuove `maxDiveDurationSeconds`, `maxDepthMeters`, `validTemperatureRange`, `isValidGPS()`. Import CSV malformato/maligno → dati corrotti nei log. |
| F6 | **MEDIUM** | Replay window | both | HMAC `issuedAt` accetta una finestra di **±86 400 s (24 h)**. Replay possibile entro 24 h (mitigato da `importedSessionIDs` set, ma con cap a 128 ed evizione FIFO). |
| F7 | **LOW** | Cripto fallback | both | Se `SecRandomCopyBytes` fallisce, il "segreto locale" cade in `SHA256("dirmotion.watch.sync.local")` / `…ios.sync.local"`. Deterministico ma derivato pubblicamente. Watch/iOS hanno stringhe **diverse** → HMAC fallirà comunque, ma è un'invariante fragile e non loggata. |
| F8 | **LOW** | Naming inconsistency | iOS | `iOSApp/Services/WatchSyncAuth.swift` usa Keychain `service = "com.egopfe.dirmotion.watch-sync"` (legacy `dirmotion`) mentre Watch usa `"com.egopfe.dirdiving.watch-sync"`. Non rompe il flusso (Keychain è per-app) ma può causare confusione/migrazione mancata. Stesso pattern in `Utils/WatchSyncNotifications.swift` (`"dirmotion.watchSyncPeerSecretDidUpdate"`) e `Services/AscentRateSettingsStore.swift` (`"dirmotion_ascent_rate_limits"`). |
| F9 | **LOW** | UserDefaults PII | both | `dirdiving_watch_pending_sync_sessions` (Watch) e `dirdiving_ios_watch_sync_conflicts` (iOS) salvano `DiveSession` complete — **coordinate GPS incluse** — in `UserDefaults`, non in Keychain o file con Data Protection. Su device jailbreak/estratto i dati sono leggibili. |
| F10 | **LOW** | CSV import DoS | iOS | `String(contentsOf: url, encoding: .utf8)` legge l'intero file in memoria senza limite di dimensione. Un CSV gigante (centinaia di MB) causa OOM. Mitigato dal fatto che è user-picked. |
| F11 | **LOW** | Reply handler trust | Watch (`main`) | `WCSession.sendMessage` reply handler considera "acknowledged" senza HMAC sul reply. Boundary fidata da Apple (WatchConnectivity è pairing-locked), ma in caso di compromise di una delle due app la pending queue del Watch può essere drenata da un falso ack. |
| F12 | **LOW** | Sensitive print | Watch | `Services/DiveLogStore.swift:108` ha `print("Save error: \(error.localizedDescription)")`. Nessun dato sensibile diretto ma è un log non strutturato; meglio `os.Logger` con `.private`. |
| F13 | **INFO** | Network surface | both | Grep su `URLSession`/`URLRequest`/`URL(string:`/`http`: **nessun uso**. L'app non ha codice di rete (ATS non rilevante). Eccellente riduzione della superficie. |
| F14 | **INFO** | Secrets in repo | repo | Nessun `password`/`apiKey`/`token`/`credential` hardcoded nel sorgente Swift. Solo `secret` come variabile locale CryptoKit. |
| F15 | **INFO** | Entitlements | both | Watch ha `com.apple.developer.coremotion.water-submersion = true`; iOS non lo ha (corretto). iCloud KVS + CloudKit container `iCloud.com.egopfe.dirdiving` allineati Watch/iOS. Nessun App Group, nessuna `keychain-access-groups` (Keychain non condivisa — coerente con scelta architetturale). |
| F16 | **INFO** | Privacy strings | both | `NSLocationWhenInUseUsageDescription` e `NSMotionUsageDescription` presenti, in italiano, descrittive. **Niente background location** dichiarato in `WKBackgroundModes` (solo `underwater-depth`). |
| F17 | **INFO** | HMAC verify | iOS | `WatchDiveSyncCodec.verify` usa HMAC-SHA256, base64 decode e poi **`constantTimeEquals` corretto** (XOR + OR-reduce su tutti i byte). Buona pratica. |
| F18 | **INFO** | File writes | iOS | `DiveLogStore.save` usa `[.atomic, .completeFileProtection]`. `SubsurfaceExportService.writeCSV` (versione `main`) idem. Buona pratica — vedi F3/F4 per le regressioni. |

Stato complessivo: **architettura crittografica sound**, ma con un **build break attivo** su `main` e una **divergenza di protocollo** Watch/iOS che, se non corretta prima del build congiunto su macOS, bloccherà l'accoppiamento.

---

## 1. Scope dell'audit

Path ispezionati (tutti su `main` e differenze su `origin/main-iOS`):

- `App/`, `iOSApp/App/`, `Views/`, `iOSApp/Views/`
- `Services/`, `iOSApp/Services/` (tutti i file inclusi nei target MAIN per `project.yml`)
- `Models/`, `iOSApp/Models/`
- `Utils/`, `iOSApp/Utils/`
- `Config/DIRDiving.entitlements`, `iOSApp/Config/DIRDivingiOS.entitlements`
- `App/Info.plist`, `iOSApp/App/Info.plist`
- `project.yml`

File esclusi dal target MAIN (e quindi **fuori scope**) in base a `project.yml`:

- Watch: `Models/ExplorationModels.swift`, `Models/BuddyAssistMessage.swift`, `Models/BuddyPairingHandshake.swift`, `Services/ExplorationStore.swift`, `Services/BuddyAssistService.swift`, `Services/BuddyAssistPeripheralService.swift`, `Services/BuddyPairingKeyAgreement.swift`, `Services/SecureBuddyStore.swift`, `Views/ApneaView.swift`, `Views/SnorkelingView.swift`, `Views/BuddyAssistView.swift`, `Views/ExperimentalConceptsView.swift`, `Utils/ExperimentalFeatures.swift`.
- iOS: `iOSApp/Models/ExplorationModels.swift`, `iOSApp/Models/BuddyExperimentalModels.swift`, `iOSApp/Services/ExplorationPlanningStore.swift`, `iOSApp/Services/BuddyExperimentalStore.swift`, `iOSApp/Views/ExplorationCenterView.swift`, `iOSApp/Views/ExperimentalFutureConceptsView.swift`, `iOSApp/Views/BuddyExperimentalView.swift`.

Buddy Assist BLE / SecureBuddy (CryptoKit / X25519 / HKDF) e Apnea/Explore non vengono valutati qui perché **non compilati nei target MAIN**.

---

## 2. Findings dettagliati

### F1 — HIGH · Build break su `main`: `resetPeerTrust` non definito

**File coinvolti:**

```51:56:iOSApp/Services/WatchSyncService.swift
    func resetPairingTrust(logStore: DiveLogStore) {
        WatchSyncAuth.resetPeerTrust()
        failedImportCount = 0
        lastMessage = "Trust Watch resettato: attendi una nuova associazione verificata."
        activate(logStore: logStore)
    }
```

`grep` su tutto il workspace conferma che **`resetPeerTrust` è definito solo su `origin/main-iOS`**, non su `main`. Il commit `f8d2af5` ("fix(ios): align MAIN companion build with XcodeGen target") ha probabilmente integrato la chiamata senza portare l'implementazione lato `WatchSyncAuth`.

**Impatto:** il target `DIRDiving iOS` di `main` **non compila**. Tutta la sezione "Sync Watch — reset pairing trust" in UI è morta.

**Fix proposto:** importare da `main-iOS` il blocco

```swift
static func resetPeerTrust() {
    deleteKeychain(account: "\(keychainAccount)-peer")
    NotificationCenter.default.post(name: .watchSyncPeerSecretDidUpdate, object: nil)
}
```

e l'helper `deleteKeychain(account:)`. Va portato **solo** quel pezzo, non l'intero `syncKey` (vedi F2).

---

### F2 — HIGH · Protocol drift di `syncKey` tra `main` (Watch) e `main-iOS` (iOS)

**Differenza:**

- `Services/WatchSyncAuth.swift` (Watch, `main`) deriva la chiave HMAC come
  `SHA256( "dirdiving.watch.sync.v2|com.egopfe.dirdiving|com.egopfe.dirdiving.ios|" || sort(localSecret, peerSecret) )` (peerBundleID non usato — `_:`).
- `iOSApp/Services/WatchSyncAuth.swift` (iOS, `main-iOS`) deriva la chiave come
  `SHA256( peerSecret || peerBundleID )` (algoritmo nuovo, peerBundleID **usato**).
- `iOSApp/Services/WatchSyncAuth.swift` (iOS, `main`) usa **ancora** l'algoritmo v2 dell'altro Watch — ma il file su `main` differisce da quello di `main-iOS`.

**Impatto:** se il Watch è buildato da `main` e l'iPhone da `main-iOS` (lo scenario "stable" dichiarato in `README.md` § *Strategia dei rami*), gli HMAC sono prodotti con due algoritmi diversi → ogni payload di `DIRDiving Watch App` cade su `WatchDiveSyncError.invalidSignature`. **Sync Watch→iPhone totalmente bloccato** in modalità silente (errore generico in UI).

**Fix proposto:**
1. Decidere una sola versione autoritativa (`v2` ordered-secrets oppure il nuovo `peerSecret + peerBundleID`).
2. Allineare `Services/WatchSyncAuth.swift` (Watch) e `iOSApp/Services/WatchSyncAuth.swift` (iOS) su `main` e `main-iOS`.
3. Aggiungere un test/QA che validi end-to-end un payload generato Watch e parsato iOS prima del rilascio.
4. Considerare di portare lo `schemaVersion` da `1` a `2` in `WatchDiveSyncCodec` quando si cambia l'algoritmo, per fallback diagnostico esplicito invece di `invalidSignature`.

---

### F3 — MEDIUM · Watch CSV export senza Data Protection

```19:24:Services/SubsurfaceExportService.swift
    static func writeCSV(for session: DiveSession) -> URL? {
        let csv = makeCSV(for: session)
        let fileName = "DIRDiving_\(session.startDate.formatted(.iso8601.year().month().day().time(includingFractionalSeconds: false))).csv".replacingOccurrences(of: ":", with: "-")
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        do { try csv.data(using: .utf8)?.write(to: url); return url } catch { return nil }
    }
```

**Problemi:**

- Nessun `.completeFileProtection` → su Apple Watch il file resta leggibile anche con device bloccato (a livello fisico, in caso di estrazione).
- Nessun cleanup di file di export passati: si accumulano in `tmp/` finché il sistema non li elimina.
- Coordinate GPS di entry/exit nelle righe → dato PII.

**Fix proposto:**
```swift
try csv.data(using: .utf8)?.write(to: url, options: [.atomic, .completeFileProtection])
```
e aggiungere un `cleanupTemporaryExports()` analogo a quello della versione iOS `main`.

---

### F4 — MEDIUM · Regressione di hardening su `main-iOS` (iOS export)

`origin/main-iOS` rimuove `.completeFileProtection`, `.atomic` extra è preservato, ma il cleanup viene tolto e il filename diventa `DIRDiving_\(session.id.uuidString.prefix(8)).csv` (più predicibile per ID dell'oggetto).

**Impatto:** stessa categoria di F3, ma è una **regressione** rispetto a `main` che già aveva l'hardening corretto.

**Fix proposto:** non importare la versione `main-iOS` del file durante eventuali merge; mantenere quella di `main` (più sicura).

---

### F5 — MEDIUM · `main-iOS` import CSV: validazioni rimosse

Tra `main` e `origin/main-iOS` su `iOSApp/Services/DiveImportService.swift`:

- Rimosse: `(0...maxDiveDurationSeconds).contains(seconds)`, `(0...maxDepthMeters).contains(depth)`, `validTemperatureRange.contains(parsedTemperature)`, `isValidGPS(latitude:longitude:)`.
- Costanti `maxDiveDurationSeconds = 86400`, `maxDepthMeters = 300`, `validTemperatureRange = -5...40`, `isValidGPS(lat:lon:)` **eliminate**.

**Impatto:** un CSV con `depth_m = 1e9`, `time_seconds = -42`, `entry_lat = 5000` viene accettato e salvato. Effetti:

- Polluzione del logbook con dati impossibili → grafici Analisi distorti, statistiche errate.
- Possibile crash o NaN nelle formule downstream (es. `avgDepth + duration/60`).
- Sync verso Watch invierà sessioni che però vengono validate dal `WatchDiveSyncCodec.validate` sull'altro lato — quindi rifiutate con `invalidSession`.

**Fix proposto:** ripristinare i bound. Sono `main`'s righe 67–104; vanno reintrodotti senza alterare la firma del metodo.

---

### F6 — MEDIUM · Replay window HMAC ampia

```11:11:iOSApp/Services/WatchDiveSyncCodec.swift
    static let maxIssuedAtSkew: TimeInterval = 86_400
```

La finestra di 24 ore è ampia per un dispositivo accoppiato locale: un attaccante che catturasse un payload (es. da debug log futuri o app intermedie) potrebbe rigiocarlo entro 24 h. Mitigazioni:

- `importedSessionIDs` set previene duplicati per UUID.
- MA il set è cappato a 128 in `WatchDiveSyncCodec.saveImportedSessionIDs(_:)` → vecchi UUID vengono espulsi (FIFO).

**Fix proposto:** ridurre `maxIssuedAtSkew` a 1 h (3600) o 15 min (900), e/o salvare `importedSessionIDs` senza cap (set di 16 byte/UUID).

---

### F7 — LOW · Fallback "secret" deterministico

```46:48:Services/WatchSyncAuth.swift
        guard let generated = try? randomKeyData(byteCount: 32) else {
            return Data(SHA256.hash(data: Data("dirmotion.watch.sync.local".utf8)))
        }
```

E speculare su iOS con `"dirmotion.ios.sync.local"`. Se `SecRandomCopyBytes` fallisce (estremamente raro), il "segreto locale" è deterministico e nota a chiunque legga il sorgente. Watch e iOS hanno stringhe diverse → l'HMAC fallirà comunque (Watch crea fallback A, iOS crea fallback B, peer secret non viene scambiato perché entrambi i lati pubblicherebbero il proprio fallback). Quindi non c'è un attack pratico, ma è un'invariante fragile non loggata.

**Fix proposto:** in caso di fallimento `SecRandomCopyBytes` propagare l'errore alla UI come "Sync Watch non disponibile su questo dispositivo" e **non** pubblicare alcun applicationContext. Il flusso comunque si interrompe in modo esplicito.

---

### F8 — LOW · Inconsistenza naming `dirmotion` vs `dirdiving`

Ricerca grep nel sorgente Swift incluso nei target MAIN mostra resti dell'antico nome `dirmotion`:

- `iOSApp/Services/WatchSyncAuth.swift:8` → `keychainService = "com.egopfe.dirmotion.watch-sync"`.
- `Services/WatchSyncAuth.swift` fallback string `"dirmotion.watch.sync.local"` (vedi F7).
- `iOSApp/Services/WatchSyncAuth.swift` fallback string `"dirmotion.ios.sync.local"`.
- `Utils/WatchSyncNotifications.swift:4` → `Notification.Name("dirmotion.watchSyncPeerSecretDidUpdate")` (Watch).
- `Services/AscentRateSettingsStore.swift:11` → `key = "dirmotion_ascent_rate_limits"`.

Funzionalmente OK (Keychain e UserDefaults per-app), ma indica che un rename incompleto può aver lasciato altri orfani. Verifica anche `BuddyPairingKeyAgreement.swift:5` `"dirmotion.buddy.v1"` (fuori scope MAIN).

**Fix proposto:** rinomina consolidata in una passata dedicata, **dopo** aver pianificato la migrazione dei valori esistenti (rename → perdita di settings/log iCloud).

---

### F9 — LOW · PII salvata in `UserDefaults`

`UserDefaults` non è cifrato con Data Protection. Le seguenti chiavi contengono `DiveSession` complete (con `entryGPS`/`exitGPS`):

- Watch `Services/WatchSyncService.swift:19` → `pendingSessionsKey = "dirdiving_watch_pending_sync_sessions"`.
- iOS `iOSApp/Services/WatchSyncService.swift:22` → `conflictsKey = "dirdiving_ios_watch_sync_conflicts"`.
- iOS `iOSApp/Services/WatchDiveSyncCodec.swift:12` → `importedSessionIDsKey` (solo UUID, non PII).

Su device standard, `UserDefaults` non è esposto. Su device jailbreak o estrazione fisica, sì.

**Fix proposto:** spostare le code "pending" e i conflitti in un file `Documents/` con `.completeFileProtection`, oppure cifrarli con la stessa `syncKey` prima di scriverli. Priorità bassa perché modifica persistenza e va validato runtime.

---

### F10 — LOW · CSV import senza limite di dimensione

```40:42:iOSApp/Services/DiveImportService.swift
        guard let contents = try? String(contentsOf: url, encoding: .utf8) else {
            return .failure(.unreadableFile)
        }
```

Nessun cap sulla size del file. Un CSV da 500 MB causa OOM crash dell'app, recoverable a relaunch. Mitigato dal fatto che il file è user-picked (file picker iOS).

**Fix proposto:** check size via `URLResourceValues.fileSize` con limite, ad es. 10 MB, prima di leggere.

---

### F11 — LOW · Reply handler senza HMAC

`Services/WatchSyncService.swift:104` controlla `reply["status"] as? String == "acknowledged"` senza HMAC sul reply. La superficie di attacco è bounded da WatchConnectivity (canale OS pairing-locked). Tuttavia, se una delle due app fosse compromessa, può inviare ack falsi → drenare la pending queue del Watch senza che iPhone abbia mai salvato l'immersione.

**Fix proposto:** firmare l'ack con `HMAC( "ack|" + originalSessionID + "|" + nonce, syncKey )`. Migliora la difesa in profondità a un costo crittografico minimo.

---

### F12 — LOW · `print` non strutturato

```108:108:Services/DiveLogStore.swift
        } catch { print("Save error: \(error.localizedDescription)") }
```

Nessun PII diretto, ma `print` finisce nel device console e in eventuali sysdiagnose. Meglio usare `Logger(subsystem: "com.egopfe.dirdiving", category: "log-store").error("Save failed: \(error.localizedDescription, privacy: .private)")`.

---

### F13 — INFO · Nessuna superficie di rete

Grep su `URLSession|URLRequest|URL\(string:|http://|https://|URLProtocol`: nessun hit nei sorgenti Swift compilati nei target MAIN. L'unico canale di trasporto è WatchConnectivity + iCloud KVS. ATS non rilevante. Riduzione di superficie eccellente.

---

### F14 — INFO · Nessun secret hardcoded

Grep case-insensitive su `password|secret|apiKey|api_key|token|credential|private_key` nel sorgente Swift: nessun materiale crittografico inline, solo identificatori di variabile (`secret`, `peerSecret`) e chiavi UserDefaults senza valore segreto. Niente da scrubbare prima del commit pubblico.

---

### F15 — INFO · Entitlements ed esclusioni Apple

`Config/DIRDiving.entitlements`:
- `iCloud.com.egopfe.dirdiving` (CloudKit container)
- `ubiquity-kvstore-identifier = $(TeamIdentifierPrefix)com.egopfe.dirdiving`
- `com.apple.developer.coremotion.water-submersion = true` (Watch only)

`iOSApp/Config/DIRDivingiOS.entitlements`: identica ma **senza** water-submersion (corretto).

`Info.plist` Watch: `WKBackgroundModes = ["underwater-depth"]`, `WKSupportsAutomaticDepthLaunch = true`, `WKCompanionAppBundleIdentifier = com.egopfe.dirdiving.ios`. **Nessuna `location` in WKBackgroundModes** — GPS surface-only, in linea con la safety doc.

**Non** sono dichiarati: HealthKit, Background App Refresh, Push, App Groups, Keychain Sharing — coerente con la riduzione di scope MAIN.

---

### F16 — INFO · Privacy usage strings

- Watch `App/Info.plist`: `NSMotionUsageDescription` + `NSLocationWhenInUseUsageDescription` presenti, in italiano, descrittive del legittimo uso (profilo immersione, GPS surface entry/exit).
- iOS `iOSApp/App/Info.plist`: solo `NSLocationWhenInUseUsageDescription`. Nessun `NSPhotoLibraryUsageDescription`/`NSCameraUsageDescription` perché non sono richiesti (no UI di acquisizione media in MAIN).

---

### F17 — INFO · HMAC verify con confronto constant-time

```130:135:iOSApp/Services/WatchDiveSyncCodec.swift
private extension Data {
    func constantTimeEquals(_ other: Data) -> Bool {
        guard count == other.count else { return false }
        return zip(self, other).reduce(UInt8(0)) { $0 | ($1.0 ^ $1.1) } == 0
    }
}
```

Implementazione corretta. La `guard count` early-return leak (length oracle) è accettabile perché la lunghezza è fissa: SHA-256 base64 = 44 caratteri = 32 byte raw.

---

### F18 — INFO · Persistenza locale con Data Protection

`Services/DiveLogStore.swift` e `iOSApp/Services/DiveLogStore.swift` usano

```swift
try data.write(to: fileURL(), options: [.atomic, .completeFileProtection])
```

per il log JSON principale. Coerente con la classe di dati (PII GPS + temporal trace).

---

## 3. Confronto sintetico `main` ↔ `main-iOS`

| Aspetto | `main` (HEAD `e8b70a2`) | `main-iOS` (HEAD `06057d7`) | Direzione preferita |
|---------|-------------------------|------------------------------|---------------------|
| `WatchSyncAuth.resetPeerTrust` | **assente** (F1) | presente | importare da `main-iOS` |
| `WatchSyncAuth.syncKey` algoritmo | `v2` ordered secrets | `peerSecret + peerBundleID` | decidere e allineare entrambi i lati (F2) |
| `DiveImportService` validazioni input | bound completi | bound rimossi (F5) | **mantenere `main`** |
| `SubsurfaceExportService` Data Protection (iOS) | `.completeFileProtection` + cleanup | rimossi (F4) | **mantenere `main`** |
| `SubsurfaceExportService` Data Protection (Watch) | mancante (F3) | n/a (file solo iOS lato) | fixare `main` |
| `CloudSyncStore` last-write-wins | implementato | semplificato senza `__modifiedAt` | scelta di prodotto, no security |
| `WatchSyncService` reply handler (iOS) | presente | rimosso (no live ack) | dipende dalla scelta UX |
| Documentazione i18n / report | aggiornati `2026-05-19` | indietro | tenere `main` come riferimento docs |

---

## 4. Recommended remediation order

1. **Subito** — F1: completare il merge di `resetPeerTrust` su `main` per ripristinare la build iOS.
2. **Prima di accoppiare Watch/iPhone in QA su macOS** — F2: scegliere una sola algoritmo `syncKey` e allineare entrambi i branch.
3. **Prima del prossimo rilascio iOS** — F4 + F5: bloccare il merge `main-iOS → main` se reintroduce le regressioni.
4. **Hardening incrementale** — F3 (Watch export protection), F6 (replay window), F9 (PII in UserDefaults), F10 (CSV size cap).
5. **Igiene** — F7 (fallback secret esplicito), F8 (rename `dirmotion` consolidato pianificato), F11 (ack HMAC), F12 (Logger).

Nessuna delle remediation richiede nuove dipendenze esterne. Tutto è risolvibile usando già `CryptoKit`, `Security`, `Foundation`.

---

## 5. Cosa NON è stato verificato

- **Runtime/dynamic:** nessun `xcodebuild`, nessuna esecuzione su Apple Watch Ultra / iPhone fisici, nessuna analisi MASTG di runtime tampering, nessun fuzzing del parser CSV.
- **Branch sperimentali:** `codex/experimental-features`, `codex/ios-experimental-features`, Buddy/SecureBuddy/Apnea/Snorkeling — **esclusi** dai target MAIN, fuori scope.
- **Threat model formale:** non c'è uno STRIDE/LINDDUN/ASVS strutturato. Questo report è una *static review*, non una *threat model*.
- **Apple Developer portal:** entitlement per `water-submersion`, capability iCloud, App ID — non verificabili offline.
- **Dependency scanning:** non ci sono dipendenze esterne (no SPM/CocoaPods/Carthage nel repo) — verificato per assenza, non per certezza.

---

## 6. Riferimenti repository

- `Services/WatchSyncAuth.swift` (Watch)
- `iOSApp/Services/WatchSyncAuth.swift` (iOS) — su `main` e `main-iOS` (divergenti)
- `Services/WatchDiveSyncCodec.swift` (sender)
- `iOSApp/Services/WatchDiveSyncCodec.swift` (receiver con HMAC verify)
- `iOSApp/Services/DiveImportService.swift` (CSV input)
- `Services/SubsurfaceExportService.swift` (Watch export) + `iOSApp/Services/SubsurfaceExportService.swift` (iOS export)
- `Services/CloudSyncStore.swift` + `iOSApp/Services/CloudSyncStore.swift` (iCloud KVS)
- `Services/DiveLogStore.swift` (persistenza JSON locale)
- `Config/DIRDiving.entitlements`, `iOSApp/Config/DIRDivingiOS.entitlements`
- `App/Info.plist`, `iOSApp/App/Info.plist`
- `project.yml` (esclusioni Experimental rispettate)

---

**Autore audit:** review statico AI · **Branch report committato su:** `main` · **Backup pre-commit:** `backup/before-docs-merge-20260519-i18n`.
