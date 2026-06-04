# DIR Diving — Apple Watch Compass Cardinal Rotation Bug Report (Current)

**Branch:** `main`  
**Date:** 2026-06-02  
**Task type:** Debug / verification / report only (no code changes)  
**Reported symptom (real Apple Watch):** Numeric heading degrees update when the watch moves; cardinal letters around the dial (N, S, E, W — user report also mentions “O” for west/Ovest) do not move or rotate with heading.

---

## A. Executive summary

| Question | Finding |
|----------|---------|
| **Bug confirmed by code inspection?** | **Yes.** The outer dial cardinal labels are laid out at fixed screen angles and are **not** included in the only rotating layer (`CompassTickRing`). |
| **Same data source for numeric heading and outer cardinals?** | **Partially.** All UI reads `compass.headingDegrees` from `CompassManager`, but **only** the tick ring applies that value to geometry via `.rotationEffect`. Outer N/E/S/W positions ignore heading. |
| **Cardinal labels static or incorrectly bound?** | **Static geometry.** `CompassMarker.position(in:)` uses fixed `angle` values (0°, 90°, 180°, 270°) with no heading offset. |
| **Sensor / heading pipeline broken?** | **No evidence.** `CLLocationManager` updates `headingDegrees` on the main actor; numeric text and center `compass.cardinal` string derive from the same published value. |
| **Severity** | **Medium (functional UX defect).** Compass is usable via numeric heading and updating center cardinal text, but the rose labels contradict a rotating-compass mental model and match the field report. |

**Intended behavior (from report + code pattern):** Rotating compass rose with a **fixed top reference** (red diamond at top of dial). When the watch rotates, the tick ring and cardinal letters should rotate so that magnetic north aligns visually with the live heading; numeric degrees and center cardinal summary stay in sync.

**What actually happens:** Tick ring rotates; numeric degrees and center `compass.cardinal` update; **outer N/E/S/W labels stay pinned** to top/right/bottom/left of the dial frame.

---

## B. Files inspected

| File | Role |
|------|------|
| `Views/CompassView.swift` | Watch compass UI: dial, tick ring rotation, cardinal `ForEach`, numeric heading, Mission Mode animations |
| `Services/CompassManager.swift` | `CLLocationManager` heading updates, `@Published headingDegrees`, `cardinal` string |
| `Views/ContentView.swift` | Tab navigation to `CompassView` |
| `App/DIRDivingApp.swift` | `CompassManager` created as `@StateObject`, injected into environment |
| `App/Info.plist` | Location usage description (heading authorization context) |
| `Utils/DiveAlgorithmConfiguration.swift` | `DiveAlgorithm.normalizedDegrees`, `signedBearingDeltaDegrees` (bearing delta text only) |
| `Views/DiveUIComponents.swift` | `DiveBearingRing` (different compass widget pattern; not used on main compass tab) |
| `Views/SnorkelingView.swift` | Secondary consumer of `compass.headingDegrees` (out of fix scope) |
| `Views/BuddyAssistView.swift` | Secondary consumer of compass heading (out of fix scope) |
| `Views/ApneaView.swift` | Environment object reference (out of fix scope) |
| `Services/ActionButtonIntents.swift` | `setBearing` / `clearBearing` via `CompassManager.shared` |
| `Resources/en.lproj/Localizable.strings` | Compass localization keys (sample grep) |

**Not used for Watch compass heading:** CoreMotion attitude/yaw, custom motion managers, or separate `HeadingManager` type.

**Explicitly not inspected for changes:** iOS companion compass/planner files (per scope).

---

## C. Compass data-flow analysis

### Heading source

- **API:** `CoreLocation` via `CLLocationManager.startUpdatingHeading()`.
- **Delegate:** `locationManager(_:didUpdateHeading:)` in `CompassManager`.
- **Value selection:** `trueHeading` when `>= 0`, else `magneticHeading` (lines 62–67).
- **Normalization:** `DiveAlgorithm.normalizedDegrees(rawHeading)` → stored in `@Published headingDegrees`.
- **Filter:** `headingFilter = 1` (degree-level updates).
- **Threading:** Delegate callbacks hop to `@MainActor` via `Task { @MainActor in ... }`.

### Update path

```
CLHeading (device)
  → CompassManager.headingDegrees (@Published, MainActor)
    → CompassView (@EnvironmentObject compass)
      → headingText (numeric, Int rounded)
      → compass.cardinal (center text, 8-point sector)
      → CompassTickRing.rotationEffect(-headingDegrees)
      → cardinalMarkers ForEach (NO heading in layout)
```

### State / bindings

| Consumer | Binding / access | Uses live heading? |
|----------|------------------|--------------------|
| Numeric `headingText` | `compass.headingDegrees` | Yes (recomputed each body) |
| Center `Text(compass.cardinal)` | Computed property on manager | Yes |
| `CompassTickRing` | `.rotationEffect(.degrees(-compass.headingDegrees))` | Yes |
| Outer `N/E/S/W` | `CompassMarker.angle` constants | **No** (fixed 0/90/180/270) |
| Bearing SET/CLEAR | `bearingDegrees` separate published field | Independent of rose layout |
| Status banner | `statusMessage` | Independent |

### Numeric heading rendering

```287:289:Views/CompassView.swift
    private var headingText: String {
        "\(Int(DiveAlgorithm.normalizedDegrees(compass.headingDegrees).rounded()) % 360)"
    }
```

### Cardinal label rendering (outer dial)

```291:314:Views/CompassView.swift
    private var cardinalMarkers: [CompassMarker] {
        [
            CompassMarker(label: "N", angle: 0, ...),
            CompassMarker(label: "E", angle: 90, ...),
            CompassMarker(label: "S", angle: 180, ...),
            CompassMarker(label: "W", angle: 270, ...),
        ]
    }
// ...
    func position(in size: CGFloat) -> CGPoint {
        let radians = (angle - 90) * .pi / 180
        return CGPoint(x: size / 2 + cos(radians) * radius, ...)
    }
```

**Conclusion:** Heading reaches the view and drives numeric text, center cardinal string, and tick ring rotation. It does **not** reach outer cardinal label positions.

### Note on “O” vs “W”

The dial uses English letters **`W`** for west, not **`O`** (Italian *Ovest*). The **center** green cardinal text uses the same English set via `CompassManager.cardinal` (`N`, `NE`, `E`, …). If the tester referred to west generically as “O”, the frozen label is still the outer **`W`** at a fixed 270° layout position.

---

## D. UI rendering analysis

### `compassDial` structure (`CompassView.swift` lines 97–130)

```
ZStack {
  CompassTickRing + rotationEffect(-heading)     ← ROTATES
  ForEach(cardinalMarkers) { Text at position }  ← FIXED screen positions
  VStack { red diamond, headingText, cardinal }  ← FIXED center (no rotation)
}
```

### What rotates

- **`CompassTickRing`:** Full tick marks; rotated by **negative** heading (rose moves opposite to device heading so a fixed top indicator represents “forward”).

### What does not rotate

- **Outer `N`, `E`, `S`, `W` labels:** Placed with `Text(...).position(...)` from fixed angles.
- **Red diamond (`diamond.fill`):** Fixed at center-top of the stack (acts as lubber line / reference).
- **Numeric degrees and center cardinal:** Fixed in place; values **change** via SwiftUI text updates, not rotation.

### `.rotationEffect` correctness (for the part that uses it)

- Applied only to `CompassTickRing` (line 102).
- Sign **`-compass.headingDegrees`** matches a **fixed pointer, rotating rose** pattern (standard compass UI).
- Degrees (not radians) — correct for `rotationEffect(.degrees(...))`.

### Mission Mode / animation

When `dive.isMissionModeActive && dive.isDiveActive`:

```39:40:Views/CompassView.swift
        .animation(missionModeActiveForCurrentDive ? nil : .easeInOut(duration: 0.24), value: compass.headingDegrees)
```

- Disables **implicit animation** on heading changes; it does **not** block layout updates or `rotationEffect` angle changes.
- **Not the root cause** of frozen cardinals; those labels never depended on heading in their layout math.

### Comparison: `DiveBearingRing` (dive UI widget)

`DiveBearingRing` shows a **single** rotating `location.north.fill` icon and a **single** cardinal string derived from `headingDegrees` — not four fixed peripheral labels. Different design; not the bug site for the Compass tab.

---

## E. Root cause hypothesis

**Primary root cause (high confidence):** Incomplete rotating-rose implementation in `CompassView.compassDial`. Developers rotated the tick ring but left cardinal `Text` views in the parent `ZStack` with **static** polar coordinates.

| Component | File | Lines | Issue |
|-----------|------|-------|-------|
| Rotating layer | `Views/CompassView.swift` | 99–102 | Only `CompassTickRing` has `rotationEffect` |
| Static cardinals | `Views/CompassView.swift` | 104–109, 291–314 | `ForEach` + `CompassMarker.position` without `-headingDegrees` |
| Live heading (working) | `Services/CompassManager.swift` | 60–73 | Publishes `headingDegrees` correctly |

**Secondary confusion (low):** Center `Text(compass.cardinal)` **does** update (e.g. `N` → `NE`), which can look like “cardinal text works” while **peripheral** N/E/S/W appear frozen — consistent with user report if they focus on the ring letters.

**Ruled out by inspection:**

- Stale heading source for rose vs numeric (same `@Published` property).
- Mission Mode blocking updates (animation only).
- CoreMotion / dual-heading mismatch.
- `.id` / `EquatableView` caching on markers.
- Early `Int` cast on heading for **outer** labels (they never used heading).

---

## F. Reproduction steps

### Real Apple Watch

1. Install/run DIR Diving Watch app from `main` build.
2. Grant location permission when prompted (required for heading).
3. Open app → swipe to **Compass** tab (`CompassView` / localized “BUSSOLA”).
4. Confirm status shows active compass (not “denied” / “unavailable”).
5. Hold watch flat; rotate slowly **clockwise** in yaw.
6. **Observe numeric heading** (large white degrees): should change continuously.
7. **Observe outer N, E, S, W** around the ring: stay at fixed screen positions (top, right, bottom, left).
8. **Observe tick marks** on the ring: should rotate with heading.
9. **Observe center green cardinal** (below degrees): should change among N/NE/E/… as sectors change.

| | Expected (rotating rose + fixed top diamond) | Actual (report + code) |
|---|---------------------------------------------|-------------------------|
| Numeric heading | Updates | Updates ✓ |
| Tick ring | Rotates with heading | Rotates ✓ |
| Outer N/E/S/W | Rotate with tick ring | **Frozen** ✗ |
| Center cardinal text | May update as sector changes | Updates ✓ |
| Red diamond | Fixed at top reference | Fixed ✓ |

**Diagnostic observation:** If ticks move but letters do not, the bug is localized to cardinal layout/rotation grouping, not `CLLocationManager`.

### Simulator

- Heading updates are **unreliable or absent** in watchOS Simulator; numeric and rotation may not move.
- The **static cardinal layout bug is still present in code** and would appear whenever heading updates are mocked or available.
- Field report on real hardware confirms the heading pipeline works; UI bug is **binding/layout**, not hardware-only.

---

## G. Suggested fix strategy (future implementation — do not apply in this task)

**Recommended (safest, minimal):** Group **tick ring + all four cardinal labels** in one child `ZStack`, apply a single `.rotationEffect(.degrees(-compass.headingDegrees))` to that group. Keep the red diamond and numeric stack **outside** the rotated group (fixed lubber line).

**Optional readability:** Counter-rotate each cardinal `Text` by `+compass.headingDegrees` so letters stay upright while positions orbit.

**Alternative:** Keep flat `ZStack`; change `CompassMarker.position` to use `(angle - compass.headingDegrees)` for layout (equivalent math, more error-prone with multiple rotations).

**Also recommended for verification:**

- SwiftUI `#Preview` or debug overlay with mocked `headingDegrees`: 0, 45, 90, 180, 270, 359.
- Temporary logs: `headingDegrees` at tick ring vs marker layout (should be identical).
- Manual QA: after fix, rotate watch — **N** should leave the top screen position when heading ≠ 0.

**Do not change** in the same pass unless proven broken: `CompassManager` delegate logic, bearing SET/CLEAR storage, dive algorithms, snorkel/buddy assist consumers.

**Bearing UI:** Current compass tab has no bearing needle on the dial (only text delta in controls). If a bearing indicator is added later, anchor it in the **rotated** group or offset by `bearing - heading` consistently.

---

## H. Risk assessment

| Area | Risk if changed incorrectly |
|------|-----------------------------|
| `CompassManager` / `CLLocationManager` | Could break all compass consumers (Snorkeling, Buddy Assist, Action Button) |
| Bearing SET/CLEAR | Navigation feature regression |
| Mission Mode animation guards | Battery/UX during dive; unrelated to cardinal freeze |
| `DiveBearingRing` / dive live UI | Out of scope; different component |
| iOS companion | Explicitly out of scope |

**Safe change surface:** `Views/CompassView.swift` — `compassDial` structure and/or `CompassMarker` layout only.

---

## I. Acceptance criteria (future fix)

1. Numeric heading still updates smoothly from live `headingDegrees`.
2. Outer **N, E, S, W** rotate with heading so north indicator aligns with the rose model (fixed top diamond).
3. At heading 0° (normalized), **N** sits at the correct angular position relative to the reference (typically under the fixed top marker when using standard rose math).
4. E/S/W remain 90° apart on the rose after rotation.
5. Tick ring and cardinals stay visually aligned (no double-rotation drift).
6. Center numeric + `compass.cardinal` remain correct and readable.
7. SET/CLEAR bearing and delta text unchanged in behavior.
8. No new layout jitter; Mission Mode still suppresses animation only, not updates.
9. No changes to dive/sensor/business logic beyond compass view layout.

---

## J. No-code-change confirmation

- **No** Swift source files were modified.
- **No** SwiftUI views were edited.
- **No** sensor or `CompassManager` logic was changed.
- **No** assets were changed.
- **Only** this report file was created: `Docs/DIR_DIVING_WATCH_COMPASS_CARDINAL_ROTATION_BUG_REPORT_CURRENT.md`.

---

## Validation

| Activity | Result |
|----------|--------|
| Static code inspection | **Completed** (primary validation) |
| Xcode build | **Not run** — report-only task; root cause is structural in `CompassView` and does not require linker confirmation |
| Unit tests | **Not run** — no test targets cover compass layout; not required for this report |

To validate after a future fix: build Watch target, run on physical Apple Watch, repeat Section F.

---

## Minimal diagnostic suggestions (future fix task)

1. Log `compass.headingDegrees` when `headingText` is rendered and when applying `rotationEffect` to the rose group (should match).
2. Overlay debug text: `rotation: -\(headingDegrees)°`.
3. Draw a small dot at computed north position after fix.
4. Compare `newHeading.trueHeading` vs `magneticHeading` in logs (informational only).
5. Inject mock headings 0 / 45 / 90 / 180 / 270 / 359 via preview or test double `CompassManager`.

---

## Summary table for triage

| Item | Value |
|------|-------|
| **Bug confirmed** | Yes |
| **Most likely root cause** | Outer cardinal labels omitted from `rotationEffect` group; fixed `CompassMarker.angle` layout |
| **Primary file** | `Views/CompassView.swift` (`compassDial`, `CompassMarker`) |
| **Heading source (OK)** | `Services/CompassManager.swift` |
| **Recommended fix** | Rotate tick ring + cardinals together; keep diamond/numbers fixed; optional per-label counter-rotation |
