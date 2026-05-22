# Build validation — DIR DIVING (MAIN)

**Branch:** `main` only.
**Generator:** [XcodeGen](https://github.com/yonaskolb/XcodeGen) (`project.yml` at repository root).

## Schemes and targets (from `project.yml`)

| Scheme | Target | Platform |
|--------|--------|----------|
| `DIRDiving Watch App` | `DIRDiving Watch App` | watchOS **10.0**+ |
| `DIRDiving iOS` | `DIRDiving iOS` | iOS **17.0**+ |

## Prerequisites (macOS)

- Xcode **15.4+** (see `project.yml` → `options.xcodeVersion`; Xcode 16.x with iOS/watchOS **26.5** runtimes is common on current Macs)
- XcodeGen installed (`brew install xcodegen` or equivalent)
- **Platform runtimes** installed: Xcode → Settings → Platforms (or Components) → **iOS 26.5** and **watchOS 26.5** simulator support. Without these, `xcodebuild` reports *platform not installed* even when SDKs are present.

Verify runtimes:

```bash
xcrun simctl list runtimes | grep -E 'iOS 26|watchOS 26'
```

## Commands (repository root)

Regenerate the Xcode project:

```bash
cd /path/to/DirDiving-App
xcodegen generate
```

### watchOS — generic device build

```bash
xcodebuild -scheme "DIRDiving Watch App" \
  -destination 'generic/platform=watchOS' \
  -configuration Debug \
  build
```

### iOS — generic device build

```bash
xcodebuild -scheme "DIRDiving iOS" \
  -destination 'generic/platform=iOS' \
  -configuration Debug \
  build
```

### Simulator builds (recommended after runtimes install)

```bash
xcodebuild -scheme "DIRDiving iOS" \
  -destination 'platform=iOS Simulator,name=iPhone 17' \
  -configuration Debug \
  build

xcodebuild -scheme "DIRDiving Watch App" \
  -destination 'platform=watchOS Simulator,name=Apple Watch Ultra 2 (49mm)' \
  -configuration Debug \
  build
```

Use `xcodebuild -showdestinations -scheme "DIRDiving iOS"` if device names differ on your Mac.

## Post-build smoke checks

Dopo una build pulita, verificare anche:

- primo avvio Watch: onboarding legale visibile prima della `ContentView`;
- primo avvio iOS: onboarding legale visibile prima della tabbar companion;
- lingua impostata su `System`, `Italiano`, `English`: disclaimer caricato da `LegalDisclaimer.txt` corretto;
- bottone Continue disabilitato finche tutte le checkbox obbligatorie non sono selezionate;
- Settings -> Legal & Safety mostra disclaimer completo, versione accettata e timestamp;
- nessun cambiamento inatteso a Diving live, BUSSOLA, GPS entry/exit, export Subsurface e sync.

## Host note (Windows / CI without Xcode)

This repository is often edited on Windows. **Apple builds cannot be asserted from Windows** unless a remote macOS runner executes the commands above. Any “build OK” claim must cite logs from those commands.

## Release checklist (fill on macOS)

Use [`Docs/RELEASE_CHECKLIST.md`](RELEASE_CHECKLIST.md) and record:

- Date
- `git rev-parse HEAD`
- Simulator build (pass/fail)
- Physical Watch + iPhone (pass/fail)
- Apple Watch Ultra spot-check (layout, legibility, crown paging)

---

*Document added as part of MAIN UI/UX/safety completion — no application business logic was modified in this documentation file.*
