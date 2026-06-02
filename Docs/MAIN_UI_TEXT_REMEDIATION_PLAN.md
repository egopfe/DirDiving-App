# MAIN UI Text & Menu/Function — Remediation Plan

**Date:** 2026-06-01  
**Source audit:** [`MAIN_UI_TEXT_FORMATTING_AND_MENU_FUNCTION_GAP_ANALYSIS.md`](MAIN_UI_TEXT_FORMATTING_AND_MENU_FUNCTION_GAP_ANALYSIS.md)  
**Branch target:** `main` only  
**Targets:** `DIRDiving Watch App`, `DIRDiving iOS`  
**Baseline commit:** `34fe880` (audit); re-verify `main` HEAD at implementation start  

**Constraints (unchanged from audit):**

- MAIN targets only; no experimental branches or excluded `project.yml` sources  
- No UI redesign / visual identity change (typography tweaks and copy/a11y only)  
- Preserve BUSSOLA (never COMPASSO), Mission Mode semantics, TTV informational positioning, reference-only iOS planner, safety disclaimers  
- No certified dive-computer or decompression-authority claims  

---

## 1. Goals and success criteria

| Goal | Target after remediation |
|------|---------------------------|
| Watch text readiness | **≥95%** (static + simulator 41/45/49 mm sign-off) |
| iOS text readiness | **≥95%** |
| Menu/function alignment | **≥98%** |
| Localization (IT/EN) | Semantic keys for all touched surfaces; zero user-visible EN leaks in IT |
| Accessibility text | VoiceOver on all safety-critical metrics + planner chart summary |
| Safety copy | No regressions; CSV depth-cap copy aligned with `IOS_DEPTH_LIMIT_POLICY.md` |

**Definition of done (program):**

1. All **P0** and **P1** issue IDs closed with tests or documented QA checklist items signed off.  
2. **P2** closed or explicitly deferred with owner + release gate.  
3. Reference UI PNGs committed OR checklist documents substitute captures from approved simulator runs.  
4. `xcodebuild` Watch + iOS MAIN succeed; no new linter issues in touched files.  
5. Final update to audit doc §L with “remediated @ `<commit>`”.

---

## 2. Phased roadmap

```text
Phase 0 — Preflight & QA harness          (0.5 day)
Phase 1 — P1 quick wins (iOS legal, a11y) (1 day)
Phase 2 — P1 Watch localization hygiene   (1.5 days)
Phase 3 — P2 copy & menu clarity          (1 day)
Phase 4 — P2/P3 accessibility expansion   (1.5 days)
Phase 5 — Typography & Dynamic Type pass  (1 day, simulator)
Phase 6 — Reference assets & sign-off doc (0.5 day)
─────────────────────────────────────────
Total estimate: ~6–7 focused dev days (+ field QA as needed)
```

Phases can overlap: Phase 1 and 2 are independent (iOS vs Watch).

---

## 3. Phase 0 — Preflight & QA harness

| Task | Owner | Deliverable |
|------|-------|-------------|
| 0.1 Confirm `main`, clean tree, `xcodegen generate` | Dev | Log in PR |
| 0.2 Create `Docs/ReferenceUI/` and capture baseline screenshots | QA/Dev | `Watch_LIVE_reference.png`, `iOS_Companion_reference.png` (41 mm + 49 mm Watch; iPhone SE + iPhone 17) |
| 0.3 Document simulator matrix | QA | Table in `Docs/MAIN_UI_TEXT_QA_CHECKLIST.md` (optional sibling doc) |
| 0.4 Grep guardrails | Dev | CI or pre-commit script: fail on `COMPASSO` in `Views/`, `iOSApp/Views/` |

**Exit criteria:** Reference folder exists; QA matrix agreed; build green.

---

## 4. Phase 1 — P1 iOS (legal + chart accessibility)

**Estimated effort:** 1 day  
**Risk:** Low (copy/localization/a11y only)

### 4.1 UITEXT-I-001 — `iOS Companion` not localized

| Field | Detail |
|-------|--------|
| **Files** | `iOSApp/Views/IOSLegalOnboardingView.swift`, `iOSApp/Resources/en.lproj/Localizable.strings`, `it.lproj/Localizable.strings` |
| **Action** | Replace `Text("iOS Companion")` with `Text(String(localized: "ios.legal.hero.subtitle"))` |
| **Keys** | EN: `"iOS Companion"`; IT: `"Companion iOS"` or `"App companion iOS"` (product-approved) |
| **Acceptance** | Italian system language shows Italian subtitle on legal hero |

### 4.2 UITEXT-I-002 — Hardcoded legal alert

| Field | Detail |
|-------|--------|
| **Files** | `IOSLegalOnboardingView.swift`, both `.strings` |
| **Action** | Use `String(localized:)` for alert title, cancel button, message (keys exist partially — add `ios.legal.exit_alert.title`, `.message`, `.confirm`) |
| **Acceptance** | Exit guidance alert fully IT/EN |

### 4.3 iOS Planner Bühlmann chart VoiceOver (audit §I HIGH)

| Field | Detail |
|-------|--------|
| **Files** | `iOSApp/Views/PlannerView.swift` (`buhlmannChart`), `.strings` |
| **Action** | Add `.accessibilityElement(children: .ignore)` + label/hint from `planner.buhlmann.chart.a11y.label` / `.hint` (reference-only NDL curve, not tissue loading) |
| **Acceptance** | VoiceOver reads summary before chart exploration; matches visible disclaimer |

### 4.4 Optional same-phase — legal step progress (LOW)

| Field | Detail |
|-------|--------|
| **Action** | `.accessibilityValue("Step \(step+1) of 4")` localized on onboarding container |
| **Priority** | P3 — include if time in Phase 1 |

**Phase 1 tests:** Manual VoiceOver on Planner curve tab + legal onboarding IT locale; no unit test required unless adding pure string helpers.

---

## 5. Phase 2 — P1 Watch (localization hygiene + App Intents)

**Estimated effort:** 1.5 days  
**Risk:** Medium (many string touchpoints; avoid breaking EN)

### 5.1 UITEXT-W-001 — Italian-as-key migration (batch 1: Settings + Alarms)

| Field | Detail |
|-------|--------|
| **Strategy** | Introduce semantic keys; **keep old keys in `.strings` as aliases** for one release OR migrate in single pass with grep verification |
| **Files** | `SettingsView.swift`, `AlarmSettingsView.swift`, `DiveLogListView.swift`, `DiveDetailView.swift`, `Resources/*/Localizable.strings` |

**Key mapping (representative — extend via grep `String(localized: "` in Watch Views):**

| Legacy key (IT literal) | New semantic key |
|---------------------------|------------------|
| `IMPOSTAZIONI` | `settings.header.title` |
| `Velocità risalita` | `settings.row.ascent_rate.title` |
| `Limiti m/min persistenti` | `settings.row.ascent_rate.subtitle` |
| `Allarmi` | `settings.row.alarms.title` |
| `IMMERSIONI` | `logbook.header.title` |
| `NESSUNA IMMERSIONE` | `logbook.empty.title` |
| … | (complete inventory in PR) |

| **Action steps** | |
|------------------|--|
| 1 | Generate CSV/key map from audit appendix |
| 2 | Add EN+IT entries for all `settings.*`, `logbook.*`, `alarms.*` |
| 3 | Replace Swift references |
| 4 | Remove deprecated keys only after parity script passes |

**Acceptance:** EN Settings shows English titles; IT shows Italian; `rg 'String\(localized: "IMPOSTAZIONI' Views` returns 0.

### 5.2 UITEXT-W-002 — Unify localization API

| Field | Detail |
|-------|--------|
| **Convention** | Prefer `String(localized: "semantic.key")` in logic; `Text("semantic.key")` in SwiftUI where `LocalizedStringKey` is enough |
| **Files** | `AscentGaugeView.swift`, `CompassView.swift`, `DiveLiveView.swift` |
| **Action** | Replace `Text("VELOCITA")` / `Text("RISALITA")` with keys `ascent.gauge.label.rate` / `.title` (single-line label optional: `ascent.gauge.title` = "ASCENT RATE" EN / "VELOCITÀ RISALITA" IT) |
| **Action** | Compass idle: `compass.idle.no_dive_data`, `compass.idle.manual_no_depth` |
| **Action** | Stopwatch: `live.stopwatch.title` instead of `CRONOMETRO` key literal |

**Acceptance:** No Italian literal keys remain in touched files; EN/IT verified.

### 5.3 App Intents localization (P1)

| Field | Detail |
|-------|--------|
| **Files** | `Services/ActionButtonIntents.swift`, add `Resources/en.lproj/AppIntents.strings` + `it.lproj` if using string catalogs, OR `LocalizedStringResource("intent.toggle_stopwatch.title")` |
| **Action** | Localize titles/descriptions for: ToggleStopwatch, ResetStopwatch, StartManualDive, EndManualDive, SetBearing, ClearBearing, etc. |
| **Copy note** | Use "DIR DIVING" + BUSSOLA terminology in IT descriptions |
| **Acceptance** | Shortcuts app shows IT strings when Watch language is Italian |

**Phase 2 tests:** Build Watch target; optional snapshot of Settings EN/IT; manual Shortcuts spot-check.

---

## 6. Phase 3 — P2 copy & menu/function clarity

**Estimated effort:** 1 day

### 6.1 Watch Export row (menu mismatch)

| ID | UITEXT-W-006 (related), Export P2 |
|----|-----------------------------------|
| **Files** | `SettingsView.swift`, `.strings` |
| **Action** | Title: `settings.row.export_logbook.title` = "Logbook & export" / "Logbook ed export"; subtitle already `settings.export.from_logbook` — strengthen: "Open dive log to export CSV" |
| **Optional UI** | `informational: false` but add chevron; or add `accessibilityHint` "Opens dive log" |
| **Acceptance** | User testing: no expectation of immediate CSV sheet from Settings |

### 6.2 UITEXT-W-006 — Informational rows vs actions

| Field | Detail |
|-------|--------|
| **Files** | `SettingsView.swift` (`settingsRow`) |
| **Action** | When `informational == true`: remove chevron-like affordance; add trailing `info.circle` SF Symbol; reduce stroke contrast; set `accessibilityAddTraits([])` and hint "Information only, not a button" |
| **Do not** | Change row list order or Mission Mode block |

### 6.3 UITEXT-I-004 — More footer semantic key

| Field | Detail |
|-------|--------|
| **Files** | `MoreView.swift`, `.strings` |
| **Action** | Key `more.safety.footer` with full EN/IT body (migrate text from Italian-sentence key) |
| **Acceptance** | Same user-visible text; grep shows single semantic key |

### 6.4 iOS CSV depth-cap copy (safety P2)

| Field | Detail |
|-------|--------|
| **Files** | `CSVImportPanel.swift` or import error strings, `.strings` |
| **Action** | Ensure import rejection at 351 m uses `import.error.depth_cap` referencing 350 m policy (`IOS_DEPTH_LIMIT_POLICY.md`) |
| **Acceptance** | Error string mentions limit and is localized |

---

## 7. Phase 4 — P2/P3 accessibility expansion

**Estimated effort:** 1.5 days

| ID / area | Screen | Action | Files |
|-----------|--------|--------|-------|
| Watch settings | Settings | `accessibilityLabel`/`Hint` on Mission Mode block, units, language, sync status rows | `SettingsView.swift` |
| Watch log | Dive log list | Combined label: site/date, depth, duration per row | `DiveLogListView.swift` |
| Watch alarms | Alarm settings | Crown stepper `accessibilityValue` with threshold + unit | `AlarmSettingsView.swift` |
| Watch info | Info | Each diagnostic row: `accessibilityLabel("\(title), \(value)")` | `InfoView.swift` |
| iOS Analysis | Analysis | Chart container accessibility summary + empty state | `AnalysisView.swift` |
| iOS Equipment | Equipment | Audit toggles vs `EquipmentChecklistGasSection` pattern | `EquipmentView.swift` |

**Acceptance:** VoiceOver walkthrough script (10 min Watch + 10 min iOS) passes without “unlabeled button” on settings/sync.

---

## 8. Phase 5 — Typography & layout (simulator QA)

**Estimated effort:** 1 day (QA-heavy)

### 8.1 UITEXT-W-004 / W-009 — Live layout & ascent gauge

| Task | Detail |
|------|--------|
| W-004 | Consider single-line `ascent.gauge.title` @ 9–10 pt with `minimumScaleFactor(0.7)` on 41 mm |
| W-009 | Live Dive: run 41 mm / 45 mm / 49 mm with all badges on (mission, sync pending, GPS no-fix, stale depth); reduce vertical padding or badge stacking order if overlap |
| Instrumentation | Compare against `Docs/ReferenceUI/Watch_LIVE_reference.png` |

### 8.2 UITEXT-I-007 — iOS Planner Dynamic Type

| Task | Detail |
|------|--------|
| Add `lineLimit` + `minimumScaleFactor` on dense planner field rows and gas cards |
| Test Content Size: Large / AX1 in Simulator |
| **Files** | `PlannerView.swift`, `PlannerGasMixCard.swift` |

### 8.3 UITEXT-W-007 / I footer — readability (P3)

| Task | Detail |
|------|--------|
| Optional shorten More footer / Watch GPS settings subtitle with “Learn more” link to Legal (no new web dependency — link to in-app Legal) |

**Exit criteria:** Signed QA checklist per device size; screenshots updated in `Docs/ReferenceUI/`.

---

## 9. Phase 6 — Documentation & sign-off

| Task | Deliverable |
|------|-------------|
| Update audit doc | Add § “Remediation status” with commit hash and % scores |
| Create / update | `Docs/MAIN_UI_TEXT_QA_CHECKLIST.md` — repeatable manual test script |
| Release note | Bullet list for TestFlight “copy & accessibility improvements” |
| Terminology grep | `COMPASSO` absent; `BUSSOLA` present in IT |

---

## 10. Issue tracker — full ID → phase map

| ID | Phase | Priority | Fix class | Status |
|----|-------|----------|-----------|--------|
| UITEXT-W-001 | 2 | P1 | localization | Planned |
| UITEXT-W-002 | 2 | P1 | localization | Planned |
| UITEXT-W-003 | — | P3 | — | Accept (brand) |
| UITEXT-W-004 | 5 | P2 | UI-only | Planned |
| UITEXT-W-005 | 2 | P3 | localization | Planned (with W-002) |
| UITEXT-W-006 | 3 | P2 | UI-only | Planned |
| UITEXT-W-007 | 5 | P3 | copy | Optional |
| UITEXT-W-008 | 2 | P3 | localization | Planned |
| UITEXT-W-009 | 5 | P2 | UI-only + QA | Planned |
| App Intents EN | 2 | P1 | localization | Planned |
| Export row mismatch | 3 | P2 | copy | Planned |
| UITEXT-I-001 | 1 | P1 | localization | Planned |
| UITEXT-I-002 | 1 | P1 | localization | Planned |
| UITEXT-I-003 | 1 | P3 | localization | OK via keys |
| UITEXT-I-004 | 3 | P2 | localization | Planned |
| UITEXT-I-005 | — | INFO | — | No action |
| UITEXT-I-006 | — | — | — | No action (already good) |
| UITEXT-I-007 | 5 | P2 | UI-only | Planned |
| UITEXT-I-008 | — | P3 | — | No action |
| Planner chart a11y | 1 | P1 | a11y | Planned |
| Analysis chart a11y | 4 | P2 | a11y | Planned |
| CSV depth-cap copy | 3 | P2 | copy | Planned |
| Reference UI missing | 0, 6 | P1 | process | Planned |
| Mode selection dormant | — | INFO | — | No action unless multi-mode SKU |

---

## 11. Suggested PR breakdown

Keep reviews small and MAIN-scoped:

| PR | Scope | Est. |
|----|-------|------|
| **PR-1** | iOS legal localization + alert keys (`UITEXT-I-001`, `I-002`) | S |
| **PR-2** | iOS planner chart a11y + Analysis chart a11y | S |
| **PR-3** | Watch semantic keys batch 1 (Settings, Alarms, Log) | M |
| **PR-4** | Watch Live/Compass/Gauge key unify (`W-002`, `W-004`, `W-005`) | M |
| **PR-5** | App Intents IT/EN | M |
| **PR-6** | Watch informational row styling + Export copy (`W-006`, Export) | S |
| **PR-7** | iOS More footer + CSV depth message (`I-004`, CSV) | S |
| **PR-8** | Watch/iOS accessibility pass (settings, log, info, alarms) | M |
| **PR-9** | Typography QA + ReferenceUI assets + checklist docs | S |

Merge order: PR-1 → PR-2 (iOS) can ship first; PR-3–5 (Watch strings) before PR-6–8; PR-9 last.

---

## 12. Testing plan

### Automated

- Grep scripts: no `COMPASSO`; no new Italian-as-key in touched files (allowlist legacy until PR-3 merges).  
- Existing unit tests must pass; add tests only if extracting string helpers (optional).  
- `xcodebuild` Watch App + iOS on simulator.

### Manual (required)

| Area | Steps |
|------|--------|
| Language | Watch + iOS set to IT and EN; spot-check Settings, Live, Legal, Planner |
| VoiceOver | Live depth/TTV; Planner chart; Settings Mission Mode; Logbook row |
| Shortcuts | IT Watch: intent titles visible in Shortcuts |
| Layout | 41 mm Watch Live with all banners; iOS Planner AX1 |
| Safety | Confirm no new certified-deco language introduced |

---

## 13. Risks and mitigations

| Risk | Mitigation |
|------|------------|
| String migration breaks EN | Dual-key period or single PR with `scripts/check_localization_keys.py` |
| App Intents catalog not picking up strings | Follow Apple doc for watchOS App Intents `.strings` in target membership |
| Layout changes perceived as redesign | Only padding/scale/opacity on informational rows; no color palette change |
| Translator churn | Export key map CSV for localization vendor |

---

## 14. Post-remediation targets

| Metric | Before | After (target) |
|--------|--------|----------------|
| Watch text readiness | ~84% | **≥95%** |
| iOS text readiness | ~89% | **≥95%** |
| Localization readiness | ~87% | **≥95%** |
| Accessibility text | ~79% | **≥90%** |
| Menu/function | ~92% | **≥98%** |

---

## 15. References

- [`MAIN_UI_TEXT_FORMATTING_AND_MENU_FUNCTION_GAP_ANALYSIS.md`](MAIN_UI_TEXT_FORMATTING_AND_MENU_FUNCTION_GAP_ANALYSIS.md) — issue source  
- [`MAIN_BRANCH_UX_INTERACTION_ACCESSIBILITY_AUDIT_CURRENT.md`](MAIN_BRANCH_UX_INTERACTION_ACCESSIBILITY_AUDIT_CURRENT.md) — navigation/feature baseline  
- [`IOS_DEPTH_LIMIT_POLICY.md`](IOS_DEPTH_LIMIT_POLICY.md) — CSV depth-cap copy  
- [`IOS_PLANNER_CHART_TRUTHFULNESS.md`](IOS_PLANNER_CHART_TRUTHFULNESS.md) — chart a11y wording must stay consistent  

---

*This plan is implementation-ready but does not modify application code until executed in a follow-up development task.*
