# Ascent speed alarm — implementation report (Watch MAIN)

**Date:** 2026-05-20  
**Branch:** `main` (Apple Watch MAIN only)

---

## 1. Branch confirmed

Apple Watch **MAIN** (`main`). No experimental branches or files touched.

---

## 2. Files changed

| File | Change |
|------|--------|
| `Views/AscentWarningBannerView.swift` | **New** — inline red banner per mockup |
| `Views/AscentWarningView.swift` | Replaced full-screen UI with thin wrapper around banner |
| `Views/DiveLiveView.swift` | Banner between TTV/RunTime and depth; removed 1 s full-screen takeover; ascent haptic loop |
| `Services/HapticService.swift` | `ascentAlarmTriggered`, `ascentAlarmRepeatIfNeeded`, `ascentAlarmCleared` |
| `Services/DiveManager.swift` | Removed `warnIfNeeded()` from ascent path (haptics owned by live view) |
| `Resources/it.lproj/Localizable.strings` | Ascent alarm keys (IT) |
| `Resources/en.lproj/Localizable.strings` | Ascent alarm keys (EN) |
| `Docs/WATCH_MAIN_UX_CONVENTIONS.md` | Updated policy: inline banner, not full-screen |
| `README.md` | Watch UX baseline line updated |

---

## 3. UI changes made

- **Non-blocking** red banner inserted between `ttvRuntimePanel` and `depthSection`.
- All live metrics remain on screen: TTV, RunTime, depth hero, max/avg depth, ascent gauge, stopwatch, START/STOP/RESET.
- Banner styling: dark red fill (~`#3A0505`), neon border (`#FF362D`), compact height (~40 pt).
- Content: warning icon, localized title, `+X m/min` when rate &gt; 0, instruction, bell/waves icon.
- Appears with ~300 ms fade/slide; subtle border pulse while active; removed when `isOverLimit` is false.
- **Removed** previous 1 s full-screen `AscentWarningView` takeover from `DiveLiveView`.

---

## 4. Haptic changes made

| Event | Behavior |
|-------|----------|
| First over-limit | `HapticService.ascentAlarmTriggered()` → `.failure` |
| While active | Repeat every **1.75 s** via `ascentAlarmRepeatIfNeeded()` |
| Clears | `ascentAlarmCleared()` — no extra haptic (per spec) |
| Disabled | Respects `dirdiving_watch_haptics_enabled` |

Haptics are driven from `DiveLiveView` on `showAscentAlarmBanner` changes, not from ascent rate recalculation.

---

## 5. Localization keys added

| Key | Italian | English |
|-----|---------|---------|
| `ascent_alarm_title` | RISALITA VELOCE | FAST ASCENT |
| `ascent_alarm_instruction` | RALLENTA | SLOW DOWN |
| `ascent_alarm_speed_unit` | m/min | m/min |
| `ascent_alarm_accessibility_hint` | (VoiceOver hint) | (VoiceOver hint) |

---

## 6. Business logic unchanged

- Ascent rate calculation (`DiveManager.updateAscentRate`) unchanged.
- `AscentStatus.make` / zone thresholds unchanged.
- TTV, depth, runtime, GPS, stopwatch, dive lifecycle unchanged.

---

## 7. Ascent thresholds unchanged

- `AscentRateSettingsStore` and `AscentStatus` limits untouched.

---

## 8. TTV / depth / runtime unchanged

- No edits to TTV formula, depth sampling, or runtime timers.

---

## 9. Build result

`swiftc -parse` on modified Watch files: **OK** (no syntax errors).

Full build (requires macOS + watchOS SDK):

```bash
cd /Users/federicolombardo/Development/DirDiving-App
xcodegen generate
xcodebuild -scheme "DIRDiving Watch App" -destination 'platform=watchOS Simulator,name=Apple Watch Ultra 2 (49mm)' build
```

---

## 10. Manual Watch QA checklist

- [ ] Trigger ascent alarm (rise faster than limit) → red banner appears between TTV and depth
- [ ] Banner clears when rate returns below limit
- [ ] Depth, gauge, TTV, RunTime, stopwatch, controls stay visible during alarm
- [ ] Haptics ON: strong pulse on trigger, repeat ~every 1.5–2 s while active
- [ ] Haptics OFF (Settings): banner still shows, no haptics
- [ ] Language **Italiano**: RISALITA VELOCE / RALLENTA
- [ ] Language **English**: FAST ASCENT / SLOW DOWN
- [ ] Apple Watch Ultra: layout not clipped
- [ ] Smaller Watch (41 mm / 40 mm): banner readable, depth still dominant
