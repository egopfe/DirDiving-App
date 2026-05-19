# Build validation — DIR DIVING (MAIN)

**Branch:** `main` only.  
**Generator:** [XcodeGen](https://github.com/yonaskolb/XcodeGen) (`project.yml` at repository root).

## Schemes and targets (from `project.yml`)

| Scheme | Target | Platform |
|--------|--------|----------|
| `DIRDiving Watch App` | `DIRDiving Watch App` | watchOS **10.0**+ |
| `DIRDiving iOS` | `DIRDiving iOS` | iOS **17.0**+ |

## Prerequisites (macOS)

- Xcode **15.4** (see `project.yml` → `options.xcodeVersion`)
- XcodeGen installed (`brew install xcodegen` or equivalent)

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

### Optional: simulator destinations

Use `xcodebuild -showdestinations -scheme "DIRDiving iOS"` to pick a concrete simulator ID, for example:

```bash
xcodebuild -scheme "DIRDiving iOS" \
  -destination 'platform=iOS Simulator,name=iPhone 16,OS=18.0' \
  build
```

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
