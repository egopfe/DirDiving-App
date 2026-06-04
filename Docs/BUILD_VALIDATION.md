# Build validation — DIR DIVING (MAIN)

**Branch:** `main` @ `63ee0b4` + Bühlmann OTU remediation (2026-06-04, local).
**Algorithm baseline:** iOS planner OTU canonical fix + bottom-gas switch depth; Watch unchanged.
**Generator:** [XcodeGen](https://github.com/yonaskolb/XcodeGen) (`project.yml` at repository root). **`DIRDiving.xcodeproj/` is gitignored — always run `xcodegen generate` after pull/checkout.**

**Latest local validation (2026-06-04):**

- `xcodegen generate` → **PASS**
- `xcodebuild -scheme "DIRDiving iOS" -destination 'generic/platform=iOS Simulator' build` → **PASS**
- `xcodebuild test -scheme "DIRDiving iOS Algorithm Tests" -destination 'platform=iOS Simulator,name=iPhone 17 Pro'` → **PASS** (247 executed, 4 skipped, 0 failures)
- `xcodebuild -scheme "DIRDiving Watch App" -destination 'platform=watchOS Simulator,name=Apple Watch Ultra 3 (49mm)' build` → **PASS**
- `xcodebuild test -scheme "DIRDiving Watch Algorithm Tests" -destination 'platform=watchOS Simulator,name=Apple Watch Ultra 3 (49mm)'` → **PASS** (all tests incl. `WatchReadinessAlgorithmTests`)

**GitHub Actions:** Build workflow uses `macos-latest`. Jobs may fail immediately if macOS runner minutes are exhausted (no runner assigned). Local builds are authoritative until CI billing is restored.

## Schemes and targets (from `project.yml`)

| Scheme | Target | Platform |
|--------|--------|----------|
| `DIRDiving Watch App` | `DIRDiving Watch App` | watchOS **10.0**+ |
| `DIRDiving iOS` | `DIRDiving iOS` | iOS **17.0**+ |
| `DIRDiving Watch Algorithm Tests` | `DIRDiving Watch Algorithm Tests` | watchOS **10.0**+ |
| `DIRDiving iOS Algorithm Tests` | `DIRDiving iOS Algorithm Tests` | iOS **17.0**+ |

## Prerequisites (macOS)

- Xcode **15.4+** (see `project.yml` → `options.xcodeVersion`; Xcode 16.x with iOS/watchOS **26.5** runtimes is common on current Macs)
- XcodeGen installed (`brew install xcodegen` or equivalent)
- **Platform runtimes** installed: Xcode → Settings → Platforms (or Components) → **iOS 26.5** and **watchOS 26.5** simulator support. Without these, `xcodebuild` reports *platform not installed* even when SDKs are present.

Verify runtimes:

```bash
xcrun simctl list runtimes | grep -E 'iOS 26|watchOS 26'
```

## XcodeGen workflow (required before Xcode)

`DIRDiving.xcodeproj` is **not committed** (see root `.gitignore`). Every checkout and worktree must regenerate it:

```bash
# MAIN repo root
cd /path/to/DirDiving-App
xcodegen generate

# Worktrees (each has its own project.yml variant)
cd /path/to/DirDiving-App/.worktrees/main-iOS && xcodegen generate
cd /path/to/DirDiving-App/.worktrees/codex-experimental && xcodegen generate
cd /path/to/DirDiving-App/.worktrees/codex-ios-experimental && xcodegen generate
cd /path/to/DirDiving-App/.worktrees/watch-audit && xcodegen generate
```

Then open `DIRDiving.xcodeproj` from that same directory. Stale projects cause **“Cannot find type in scope”** errors for Watch algorithm files even when source exists on disk.

## Required Validation Flow

`DIRDiving.xcodeproj` is generated output and is intentionally gitignored. Every `xcodebuild` command below assumes this sequence has just run in the same checkout:

```bash
cd /path/to/DirDiving-App
xcodegen generate
xcodebuild -list -project DIRDiving.xcodeproj
xcrun simctl list devices
```

If any checkout, branch switch, pull, or worktree change occurs, repeat `xcodegen generate` before the next `xcodebuild`.

## Commands (repository root)

Regenerate the Xcode project:

```bash
cd /path/to/DirDiving-App
xcodegen generate
```

### watchOS — generic device build

```bash
xcodebuild -scheme "DIRDiving Watch App" \
  -project DIRDiving.xcodeproj \
  -destination 'generic/platform=watchOS' \
  -configuration Debug \
  build
```

### iOS — generic device build

```bash
xcodebuild -scheme "DIRDiving iOS" \
  -project DIRDiving.xcodeproj \
  -destination 'generic/platform=iOS' \
  -configuration Debug \
  build
```

### Simulator builds (recommended after runtimes install)

```bash
xcodebuild -scheme "DIRDiving iOS" \
  -project DIRDiving.xcodeproj \
  -destination 'platform=iOS Simulator,name=iPhone 17' \
  -configuration Debug \
  build

xcodebuild -scheme "DIRDiving Watch App" \
  -project DIRDiving.xcodeproj \
  -destination 'platform=watchOS Simulator,name=Apple Watch Ultra 3 (49mm)' \
  -configuration Debug \
  build
```

Use `xcodebuild -showdestinations -scheme "DIRDiving iOS"` and `xcodebuild -showdestinations -scheme "DIRDiving Watch App"` if device names differ on your Mac.

### Algorithm tests

```bash
xcodebuild test -scheme "DIRDiving Watch Algorithm Tests" \
  -project DIRDiving.xcodeproj \
  -destination 'platform=watchOS Simulator,name=Apple Watch Ultra 3 (49mm)'

xcodebuild test -scheme "DIRDiving iOS Algorithm Tests" \
  -project DIRDiving.xcodeproj \
  -destination 'platform=iOS Simulator,name=iPhone 17'
```

The tests validate the release-hardening documented in `DIR_DIVING_WATCH_ALGORITHM_RELEASE_HARDENING_FINAL.md` and `DIR_DIVING_IOS_ALGORITHM_RELEASE_HARDENING.md`.

## Known release blocker

Current `main` is simulator-buildable, but generic signed device builds can still fail before runtime validation if the active provisioning profile does not include the Watch entitlement:

```text
Entitlement com.apple.developer.coremotion.water-submersion not found and could not be included in profile.
```

This is an Apple Developer / signing issue, not a source-level compile failure in the repository.

## Troubleshooting

### `Build input files cannot be found: GPSStartRegisteredView.swift` / `GPSEndRegisteredView.swift`

**Cause:** Those Watch views were **removed** in commit `876bcd2` (*fix(main): resolve UX audit blockers*). Live dive uses an **inline GPS banner** instead. `DIRDiving.xcodeproj` is **not** in git (see `.gitignore`); an old generated project still lists the deleted files.

**Fix (repository root):**

```bash
git pull origin main
xcodegen generate
```

Then in Xcode: **Product → Clean Build Folder** (⇧⌘K), close and reopen `DIRDiving.xcodeproj`, build again.

Do **not** recreate the deleted Swift files unless you intentionally revert that UX change.

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
