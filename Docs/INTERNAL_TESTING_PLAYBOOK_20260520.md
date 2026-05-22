# Internal testing playbook — DIR DIVING MAIN

**For:** developers and testers on branch `main`  
**Updated:** 2026-05-20  
**Goal:** reach confident **internal test** → **TestFlight** without surprises

Use this as the single day-by-day guide. Detailed checklists live in linked docs.

---

## What you are testing

| App | Target | Role |
|-----|--------|------|
| Apple Watch | `DIRDiving Watch App` | Live dive, log, bussola, export, sync **to** iPhone |
| iPhone | `DIRDiving iOS` (same repo) | Logbook, planner, analysis, sync **from** Watch |

**Not in MAIN:** Apnea, Snorkeling, Buddy (experimental branches only).

**Product stance:** support/log tool — **not** a certified dive computer. See [`SAFETY_DISCLAIMER.md`](SAFETY_DISCLAIMER.md).

---

## Hardware you need

| Phase | Minimum | Ideal |
|-------|---------|--------|
| Simulator smoke | Mac + Xcode | Same |
| Real sync QA | iPhone + Apple Watch (any pairable) | iPhone + **Watch Ultra** |
| Depth automation | — | **Apple Watch Ultra** + water submersion entitlement approved |
| TestFlight | Same devices + testers’ Apple IDs |

---

## Phase 0 — One-time Mac setup (30–60 min)

### 0.1 Clone and branch

```bash
git clone https://github.com/egopfe/DirDiving-App.git
cd DirDiving-App
git checkout main
git pull origin main
```

Record: `git rev-parse --short HEAD` → write in your test log.

### 0.2 Xcode runtimes

Xcode → **Settings → Platforms** (or Components):

- Install **iOS 26.5** simulator support  
- Install **watchOS 26.5** simulator support  

Verify:

```bash
xcrun simctl list runtimes | grep -E 'iOS 26|watchOS 26'
```

### 0.3 Generate and build

```bash
xcodegen generate

xcodebuild -scheme "DIRDiving Watch App" \
  -destination 'platform=watchOS Simulator,name=Apple Watch Ultra 3 (49mm)' \
  build

xcodebuild -scheme "DIRDiving iOS" \
  -destination 'platform=iOS Simulator,name=iPhone 17' \
  build
```

Both must end with **BUILD SUCCEEDED**.  
Details: [`BUILD_VALIDATION.md`](BUILD_VALIDATION.md).

### 0.4 Run from Xcode (simulator)

1. Open `DIRDiving.xcodeproj`.  
2. Scheme **DIRDiving iOS** → Run on iPhone simulator (installs Watch app to paired Watch sim if configured).  
3. Or scheme **DIRDiving Watch App** → Run on Watch simulator only.

**Simulator limits:** no real GPS, no real depth, WatchConnectivity between sims is limited. Use Phase 3 for sync.

---

## Phase 1 — Simulator smoke (1–2 h, solo developer)

Purpose: UI layout, navigation, crashes, English/Italian toggle — **not** sync or depth.

### Watch (simulator)

| # | Action | Pass? |
|---|--------|-------|
| 1 | Open app → Mode Selection → tap **Diving** → swipe to **Live** | |
| 2 | **AVVIO MANUALE** (depth unavailable in sim) → see depth/timer UI | |
| 3 | START/STOP/RESET stopwatch | |
| 4 | Trigger fast ascent (if debug) or simulate → red **inline** banner; gauge still visible | |
| 5 | Tabs: BUSSOLA, Settings, Log, Images | |
| 6 | Settings → Language **English** → main strings not obviously Italian | |
| 7 | Log empty state → export hint | |

Extended list: [`MAIN_PRE_RELEASE_SIMULATOR_QA_20260519.md`](MAIN_PRE_RELEASE_SIMULATOR_QA_20260519.md) §1–2.

### iOS (simulator)

| # | Action | Pass? |
|---|--------|-------|
| 1 | All five tabs open: Logbook, Analisi, Planner, Attrezzatura, Altro | |
| 2 | Altro → enable **Logbook dimostrativo** → 5 dives appear | |
| 3 | Open dive detail → tabs Riepilogo/Grafici/Dettagli | |
| 4 | Planner → disclaimer visible → Calcola Piano → result screen | |
| 5 | Altro → Language **English** | |
| 6 | Analysis → Import CSV (pick a sample file) if you have one | |

---

## Phase 2 — Physical devices, no sync yet (2–3 h)

Install via Xcode **Run** on your iPhone and Watch (same Apple ID, development signing).

### Watch solo

| # | Test | Expected |
|---|------|----------|
| 1 | GPS permission on first use | System dialog; Settings shows status |
| 2 | Manual dive start → end | Session in Log |
| 3 | Dive detail → Export CSV → Share | File or error message |
| 4 | Delete dive | Confirm dialog; log removed |
| 5 | Settings → turn **Vibrazione** off → yellow badge on live pre-dive | |
| 6 | Alarm (if enabled) → **OK** on banner → does not spam immediately | |

### iPhone solo

| # | Test | Expected |
|---|------|----------|
| 1 | Demo logbook off → empty logbook message | |
| 2 | Delete dive from logbook (swipe/trash) | |
| 3 | Planner: read disclaimer; do not treat output as certified plan | |

---

## Phase 3 — Watch + iPhone paired (critical, 2–4 h)

**Most important phase for internal test.**

### 3.1 First launch / pairing

1. Install **iOS app** on iPhone, **Watch app** on Watch.  
2. Open **both** at least once.  
3. iPhone **Altro** → check **SYNC WATCH** rows (Supportato, Stato, Ultimo evento).  
4. Watch **Impostazioni** → **Sync companion** / pending counts.

**Known behavior:** first sync may show *pending* until peer secret is exchanged. Open both apps, wait ~30 s, tap **Riprova sync** on Watch if needed.

### 3.2 Watch → iPhone

| # | Steps | Pass? |
|---|--------|-------|
| A | Complete a short manual dive on Watch → end dive | |
| B | On iPhone Logbook, pull to refresh / reopen app | |
| C | New dive appears with similar date/depth/duration | |
| D | Watch Settings: pending count decreases / “confermati” increases | |

### 3.3 Delete / tombstone (both directions)

| # | Steps | Pass? |
|---|--------|-------|
| E | Delete dive on **iPhone** → must **not** reappear on Watch after sync/wait | |
| F | New dive on Watch, sync, delete on **Watch** → must **not** reappear on iPhone | |

If a deleted dive comes back → **stop** and file bug (tombstone/sync).

### 3.4 Live UX on device

| # | Check | Pass? |
|---|--------|-------|
| G | GPS banner at start/end is **thin top strip** ~1 s; depth/gauge stay visible | |
| H | Sync strip on live when pending/failed (yellow/cyan) | |
| I | Ascent banner: depth + gauge visible together | |

### 3.5 iOS conflict path (optional)

If you can force two different versions of same dive ID (advanced): Watch sends update, iPhone has different copy → conflict saved; resolve in UI if exposed.

---

## Phase 4 — Depth on Watch Ultra (when ready)

**Skip until Apple water submersion entitlement is on App ID + profile.**

Follow [`README.md`](../README.md) “Depth Entitlement And Signing Checklist” and [`RELEASE_CHECKLIST.md`](RELEASE_CHECKLIST.md) depth section.

| # | Test | Pass? |
|---|------|-------|
| 1 | Info → Sensore profondità = **Disponibile** (not only “Configurato”) | |
| 2 | In water: depth value changes on live screen | |
| 3 | Manual fallback still works if you deny motion / old watch | |

Pool or controlled shallow test is enough for **internal** validation.

---

## Phase 5 — TestFlight (team beta)

### 5.1 Prepare build

1. Archive **DIRDiving iOS** (embeds Watch).  
2. Upload to App Store Connect.  
3. Add **internal** or **external** testers.  
4. Paste notes from [`TESTFLIGHT_REVIEW_NOTES.md`](TESTFLIGHT_REVIEW_NOTES.md) into TestFlight “What to test”.

### 5.2 Tester instructions (copy/paste)

```
1. Pair Apple Watch with iPhone; install both apps from TestFlight.
2. Open Watch app → Mode Selection → Diving → Live.
3. Do one short “dive” (manual start if no depth) and check iPhone Logbook.
4. Delete the dive on iPhone; confirm it does not return on Watch.
5. Settings → try English on Watch and iPhone.
6. Report: device models, iOS/watchOS versions, screenshots of any Italian text in EN mode or sync errors.
```

### 5.3 What blocks TestFlight sign-off

- [ ] Phase 3 E/F pass on real devices  
- [ ] No CRITICAL crashes in 30 min mixed use  
- [ ] Depth Phase 4 done **or** documented as “manual dive only” for this build  
- [ ] [`RELEASE_CHECKLIST.md`](RELEASE_CHECKLIST.md) signed off for your build SHA  

---

## Test log template (copy per session)

```markdown
## Session YYYY-MM-DD
- Tester:
- main @ <git sha>
- iPhone: model / iOS ___
- Watch: model / watchOS ___
- Build: Xcode Run / TestFlight build ___

### Results
| ID | Test | PASS / FAIL | Notes |
|----|------|-------------|-------|
| 3.2-A | Watch→iPhone sync | | |
| 3.3-E | Delete iPhone→Watch | | |
| ... | | | |

### Blockers for next gate
- 
```

---

## Quick troubleshooting

| Problem | What to try |
|---------|-------------|
| “Sync non disponibile” | Open iPhone app first; Bluetooth on; Watch app installed |
| Pending never clears | Both apps open → Watch **Riprova sync**; iPhone Altro → sync |
| Deleted dive returns | Bug — note exact steps; check both devices after 1 min |
| Depth always 0 | Ultra? Entitlement in profile? Use manual dive for this build |
| English still Italian | Note screen name; some planner strings still partial |
| GPS denied | iPhone Settings → Privacy → Location → DIR DIVING |

---

## Recommended order (timeline)

| Week | Focus |
|------|--------|
| Day 1 | Phase 0 + 1 (build + simulator) |
| Day 2 | Phase 2 (solo devices) |
| Day 3 | Phase 3 (pairing + sync + delete) — **gate for internal OK** |
| Day 4+ | Phase 4 Ultra depth (parallel with Apple entitlement) |
| When 3 passes | Phase 5 TestFlight to 2–5 testers |

---

## Related docs

| Doc | Use for |
|-----|---------|
| [`TESTFLIGHT_REVIEW_NOTES.md`](TESTFLIGHT_REVIEW_NOTES.md) | Reviewer copy |
| [`RELEASE_CHECKLIST.md`](RELEASE_CHECKLIST.md) | Sign-off before release |
| [`MAIN_PRE_RELEASE_SIMULATOR_QA_20260519.md`](MAIN_PRE_RELEASE_SIMULATOR_QA_20260519.md) | Exhaustive simulator cases |
| [`MAIN_BRANCH_COMPLETE_READINESS_AUDIT_20260520.md`](MAIN_BRANCH_COMPLETE_READINESS_AUDIT_20260520.md) | Known gaps |
| [`MAIN_BRANCH_ISSUES_AND_PRIORITIES_20260520.md`](MAIN_BRANCH_ISSUES_AND_PRIORITIES_20260520.md) | Priority IDs (update after fixes) |

---

*Internal testing only — MAIN branch · not a substitute for legal/safety review*
