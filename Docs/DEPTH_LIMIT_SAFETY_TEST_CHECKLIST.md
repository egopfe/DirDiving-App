# Depth limit safety — manual test checklist

Constants: caution **35 m**, critical **38 m**, maximum supported **40 m**.

## Live Watch UI (`DiveLiveView`)

| Depth | Expected |
|-------|----------|
| **34.9 m** | Normal depth styling; no depth safety banner; no depth-limit haptic |
| **35.0 m** | Caution styling; banner “Maximum supported depth approaching”; caution haptic (≤ every 30 s) |
| **38.0 m** | Critical styling; stronger banner; warning haptics (≤ every 15 s) |
| **40.0 m** | Exceeded: “Depth outside supported operating range”, “Ascend within safe limits”, readings disclaimer; max-depth summary hidden; critical haptics (≤ every 10 s) |
| **41.0 m** | Exceeded state remains |

## Haptics

- [ ] With haptics **on**: verify throttling (not every sample tick)
- [ ] With haptics **off**: visual-only badge; no `WKInterfaceDevice.play` crashes on simulator

## Dive log

- [ ] Complete a dive that reached **≥ 40 m** → log shows **Outside supported operating range** (Watch detail + iOS detail after sync)
- [ ] Open an **old log** (saved before this feature) → opens normally; flag treated as **false**

## Onboarding

- [ ] Fresh install / legal revision `2026-05-23`: cannot finish without depth-limits acknowledgement checkbox
- [ ] All prior checkboxes still required

## Positive reinforcement

- [ ] At **≥ 40 m** live: no celebratory max-depth cards; no achievement copy

## CLI build (macOS)

```bash
cd ~/Documents/GitHub/DirDiving-App
git pull origin main
xcodegen generate
xcodebuild -project DIRDiving.xcodeproj -scheme "DIRDiving Watch App" \
  -destination 'platform=watchOS Simulator,name=Apple Watch Ultra 3 (49mm)' build
```
