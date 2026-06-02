# iOS Planner — CNS UI/UX Visibility Audit (Current)

**Audit date:** 2026-06-02  
**Branch:** `main`  
**Scope:** `DIRDiving iOS` — Planner / plan result only (MAIN)  
**Mode:** Read-only audit (code + localization review; no physical VoiceOver walkthrough executed in this pass)

---

## 1. Where the information is displayed

### A. Planner input screen (before **Calcola Piano**)

| Value | Screen | Section / card | Swift component | Label (EN) | When shown |
|---|---|---|---|---|---|
| Total CNS (preview) | Planner | **DENSITY / END** (`technicalAnalysisCard`) | `PlannerView` → `DIRMetricTile` | `CNS` | Live preview while editing inputs (before full plan) |
| OTU (preview) | Planner | **DENSITY / END** | `DIRMetricTile` | `OTU` | Same |
| Daily CNS / OTU 24h | Planner | **DENSITY / END** (footer) | `Text` | `Daily reference: CNS … · OTU 24h …` | Same |
| Reference-only disclaimer | Planner | **DENSITY / END** (footer) | `Text` + `accessibilityLabel` | `planner.oxygen_exposure.disclaimer` | Same |
| CNS Descent + Bottom | — | **Not shown** | — | — | **NOT VISIBLE** before calculation |
| 15% warning | — | — | — | — | **NOT VISIBLE** before calculation |
| Deco gas CNS contribution | — | — | — | — | **NOT VISIBLE** |

**Note:** Pre-calculation `CNS` is derived from a **bottom-only** preview segment (`GasPlanningService.analyze(input:)`), not the full ascent/deco profile. It can differ from post-calculation **CNS%** on the result screen.

### B. Dive plan result screen (after **Calcola Piano**)

Navigation: `PlannerView` → `navigationDestination` → `PlanResultView` (`planner.result.title` = “Dive plan”).

Default tab: **PLAN** (`resultGrid`).

| Value | Screen | Section | Swift component | Label (EN) | When shown |
|---|---|---|---|---|---|
| Total CNS (planned dive) | Dive plan result | **PLAN** tab — metric grid row 2 | `PlanResultView.resultGrid` → `DIRMetricTile` | `CNS%` | After successful calculation, always on PLAN tab |
| OTU (planned dive) | Dive plan result | **PLAN** tab — metric grid row 1 | `DIRMetricTile` | `OTU` | After calculation |
| CNS Descent + Bottom | Dive plan result | **PLAN** tab — row below NDL footnote | `DIRMetricTile` | `CNS Descent + Bottom` | After calculation |
| 15% warning state | Dive plan result | **PLAN** tab — inline banner directly under CNS Descent + Bottom tile | `HStack` + `Image` + `Text` | `planner.cns_descent_bottom.warning` | When toggle **on** (`More` → `CNS Descent + Bottom 15% check`) **and** `cnsDescentBottomPercent > 15` |
| Red value (15%) | Dive plan result | Same tile as CNS Descent + Bottom | `DIRMetricTile` (`color: DIRTheme.red`, warning icon) | Same label | Same condition as warning |
| Daily CNS / OTU 24h | Dive plan result | **PLAN** tab — block under CNS warning | `Text` | `Daily reference: CNS … · OTU 24h …` | After calculation |
| Reference-only disclaimer | Dive plan result | (1) Header badge area; (2) PLAN tab oxygen block | `Text` | `planner.header.reference_only.hint`; `planner.oxygen_exposure.disclaimer` | After calculation |
| Elevated CNS/OTU (generic) | Dive plan result | **PLAN WARNINGS** card (`resultWarningsSection`) | `DIRCard` + `PlannerUserFacingMessage` | `Elevated oxygen exposure` | When planner states include oxygen exposure warning (separate from 15% rule) |
| Deco gas CNS contribution | — | — | — | — | **NOT VISIBLE** as its own value; deco stops show **gas + PPO2** only in **ASCENT PLAN** table, not CNS per gas |

### C. Settings (enables 15% rule)

| Item | Screen | Section | Swift file | Label (EN) |
|---|---|---|---|---|
| 15% check toggle | More | Settings | `MoreView` | `CNS Descent + Bottom 15% check` |

Stored in `@AppStorage(PlannerCNSDescentBottomCheckSettings.storageKey)`; default **on**.

---

## 2. UX/UI clarity assessment (summary)

| Topic | Assessment |
|---|---|
| Label clarity for **CNS%** | **PARTIAL** — short label; does not state “full planned profile” or “includes decompression gases”. |
| **CNS%** vs **CNS Descent + Bottom** | **PARTIAL** — distinct labels exist, but no in-UI sentence explaining inclusion/exclusion. |
| Total includes decompression | **UNCLEAR** — not stated next to **CNS%**. |
| Descent + bottom excludes decompression | **PARTIAL** — name implies scope; not explicit; 15% warning mentions “descent and bottom time” only. |
| 15% rule explained | **PARTIAL** — warning says “exceeds 15% of the maximum CNS budget”; does not define the rule or link to daily budget in plain language. |
| Red warning visibility | **CLEAR** on result screen when active (red tile + red text + triangle). |
| Warning proximity to values | **CLEAR** — immediately under CNS Descent + Bottom in the same grid. |
| Action if warning appears | **UNCLEAR** — no corrective hint on the 15% banner (unlike `PLAN WARNINGS` messages that can include `correctiveHint`). |
| Too technical | **PARTIAL** — NOAA/REPEX disclaimer is technical but marked reference-only; **CNS%** / budget wording may confuse non-technical users. |
| Below the fold | **PARTIAL** — CNS Descent + Bottom and warning sit mid-grid on PLAN tab; user must scroll on smaller phones to see disclaimer block and ascent table. |
| VoiceOver | **PARTIAL** — tiles use generic `"\(title), \(value) \(unit)"`; oxygen disclaimer has dedicated a11y string; **15% warning** uses `accessibilityElement(children: .combine)` only (no dedicated hint / action). |
| Non-certified positioning | **CLEAR** — `planner.header.reference_only.hint`, `planner.oxygen_exposure.disclaimer`, elevated-exposure hint. |
| Pre-calc vs post-calc CNS | **UNCLEAR** — same `CNS` label before and after calculate, but semantics change (preview vs full profile). |
| Deco CNS misunderstanding risk | **MEDIUM** — users may assume **CNS% − CNS Descent + Bottom** equals “deco CNS”; difference is not labeled and deco CNS is not shown. |

---

## CNS UI/UX Visibility Matrix

| Information | Visible To User | UI Location | Swift File / Component | Label Text (EN) | When It Appears | UX Clarity | Issue Priority | Recommended Fix |
|---|---|---|---|---|---|---|---|---|
| Total CNS | Yes | Planner → DENSITY / END card; Dive plan → PLAN tab grid | `PlannerView.technicalAnalysisCard`; `PlanResultView.resultGrid` | `CNS` / `CNS%` | Before calc (preview); after calc (full plan) | PARTIAL | P2 | Rename to “CNS (full plan)” on result; add footnote “Includes descent, bottom, ascent, and decompression segments.” |
| OTU | Yes | Same cards / grid | `DIRMetricTile` | `OTU` | Before and after calculation | CLEAR | NONE | — |
| CNS Descent + Bottom | Yes (result only) | Dive plan → PLAN tab grid | `PlanResultView.resultGrid` | `CNS Descent + Bottom` | After calculation only | PARTIAL | P1 | Show in same oxygen block on result; add subtitle “Descent + bottom only (excludes decompression stops).” |
| CNS Descent + Bottom 15% Warning | Yes (conditional) | Dive plan → PLAN tab, under CNS Descent + Bottom | `PlanResultView` inline `HStack` | `Warning: CNS accumulated during descent and bottom time exceeds 15% of the maximum CNS budget.` | After calc, if toggle on and value > 15% | PARTIAL | P1 | Add action-oriented copy + `accessibilityHint`; optional corrective hint (reduce bottom time, gas O₂, or verify with certified tools). |
| Deco Gas CNS Contribution | No | — | — | — | — | NOT VISIBLE | P2 | Optional read-only row “CNS from decompression (est.)” = `cnsPercent − cnsDescentBottomPercent` with disclaimer; or explicit footnote that difference is deco-related. |
| Reference-Only Disclaimer | Yes | Planner DENSITY / END; Result header + PLAN oxygen block | `Text` | `planner.oxygen_exposure.disclaimer`; `planner.header.reference_only.hint` | Always on those surfaces | CLEAR | NONE | — |

---

## CNS UX/UI Verdict

**ALMOST READY**

### Rationale

- **Findability:** After calculation, users can find **CNS%**, **OTU**, and **CNS Descent + Bottom** in one PLAN-tab metric grid (`PlanResultView.resultGrid`). Reference-only disclaimers are present in the result header and oxygen block.
- **Understanding total vs descent+bottom:** Labels differ, but the UI does **not** clearly state that **CNS%** includes decompression segments while **CNS Descent + Bottom** excludes them. Users must infer from naming and documentation.
- **15% warning strength:** When active, the warning is **visually strong** (red tile, icon, adjacent red banner) and **correctly placed** next to the CNS Descent + Bottom value.
- **15% rule explanation:** The rule is **not** explained in plain language on-screen; the warning does not tell the user what to change.
- **Decompression CNS risk:** There is **no** dedicated deco CNS line item; only PPO2 per stop in the ascent table. Users may **misread** the gap between the two CNS numbers as precise “deco CNS” without qualification.

### Acceptance criteria (required checklist)

| Criterion | Met? |
|---|---|
| Total CNS visible in CNS/OTU planner area | Yes (result); preview only before calc |
| CNS Descent + Bottom visible in same area | Yes (result only) |
| OTU remains visible | Yes |
| Total CNS clearly includes decompression gases | **No** |
| CNS Descent + Bottom clearly excludes decompression | **Partial** |
| CNS Descent + Bottom > 15% → value red | Yes |
| > 15% → clear warning near CNS/OTU values | Yes (visibility); **partial** (action clarity) |
| Warning in IT and EN | Yes |
| User-facing wording clear and action-oriented | **Partial** |
| No certified oxygen tracking claim | Yes |
| VoiceOver labels/hints for warning/value | **Partial** |

**Conclusion:** Visibility is largely in place on the result screen; **clarity and acceptance criteria are not fully met** without copy/footnote and accessibility improvements.

---

## Fix plan (implementation-ready)

### P1 — Scope labels and warning copy (result grid)

| Item | Detail |
|---|---|
| UI section | `PlanResultView.resultGrid` (PLAN tab metric grid + oxygen block) |
| Swift file | `iOSApp/Views/PlannerView.swift` (`PlanResultView`) |
| Localization (add/update EN + IT) | `planner.metric.cns_full_plan` = “CNS (full plan)” / IT equivalent |
| | `planner.metric.cns_full_plan.footnote` = “Includes descent, bottom, ascent, and decompression segments (reference estimate).” |
| | `planner.metric.cns_descent_bottom.footnote` = “Descent and bottom only; excludes decompression stops.” |
| | `planner.cns_descent_bottom.warning.hint` = “Consider shorter bottom time, lower O₂ fraction, or replan gases. Reference only — verify with certified methods.” |
| Warning copy | Extend `planner.cns_descent_bottom.warning` to two lines: what happened + what to do (use hint as secondary `Text` or `correctiveHint` pattern). |
| Accessibility | Add `.accessibilityHint` on 15% banner; add `.accessibilityLabel` on CNS Descent + Bottom tile when warning active (e.g. “CNS descent and bottom, warning, exceeds fifteen percent reference threshold”). |
| Tests | Extend `CNSDescentBottomTests` or add `PlannerCNSCopyTests` asserting localized keys exist EN/IT; snapshot optional. |
| A11y QA | VoiceOver pass on PLAN tab with warning on/off (matrix: `Docs/IOS_DYNAMIC_TYPE_VOICEOVER_QA_MATRIX.md`). |
| Acceptance | User can state what each CNS number includes; warning announces threshold and suggested next step. |

### P2 — Pre-calculation alignment

| Item | Detail |
|---|---|
| UI section | `PlannerView.technicalAnalysisCard` |
| Swift file | `PlannerView.swift` |
| Change | Either (a) hide **CNS%** until plan calculated, or (b) label preview `CNS (bottom preview)` and show **CNS Descent + Bottom** preview tile using `store.analysis.cnsDescentBottomPercent` (already computed, not displayed). |
| Localization | `planner.metric.cns_preview` / footnote “Full-plan CNS available after Calcola Piano.” |
| Acceptance | No misleading equality between pre- and post-calc **CNS** labels. |

### P2 — Deco CNS exposure (optional informational)

| Item | Detail |
|---|---|
| UI section | PLAN tab, below CNS Descent + Bottom |
| Swift file | `PlanResultView` |
| Logic | Display `max(0, cnsPercent - cnsDescentBottomPercent)` as **“CNS from ascent/deco (est.)”** with footnote “Derived difference; reference only.” |
| Risk control | Do not imply certified tracking; keep reference disclaimer visible. |
| Tests | Unit test on derived value for fixture plan with deco stops. |

### P3 — Settings discoverability

| Item | Detail |
|---|---|
| UI | `MoreView` toggle already exists |
| Doc | Link from warning banner to settings is **not** required in code; optional footnote “Can be disabled in More → Settings.” |

---

## Code references (primary)

```1163:1240:iOSApp/Views/PlannerView.swift
    private var resultGrid: some View {
        // ...
                DIRMetricTile(title: "CNS%", value: store.plan.gasAnalysis.cnsPercentDisplay, unit: "%")
        // ...
                DIRMetricTile(
                    title: String(localized: "planner.metric.cns_descent_bottom"),
                    value: Formatters.zero(store.plan.gasAnalysis.cnsDescentBottomPercent),
                    unit: "%",
                    color: cnsDescentBottomWarningActive ? DIRTheme.red : DIRTheme.cyan,
                    icon: cnsDescentBottomWarningActive ? "exclamationmark.triangle.fill" : nil
                )
            if cnsDescentBottomWarningActive {
                // planner.cns_descent_bottom.warning
            }
```

```456:493:iOSApp/Views/PlannerView.swift
    private var technicalAnalysisCard: some View {
        DIRCard(String(localized: "planner.card.density_end"), ...) {
            // CNS + OTU preview tiles (no CNS Descent + Bottom tile)
        }
    }
```

```299:322:iOSApp/Models/GasPlan.swift
    let cnsPercent: Double
    /// CNS% integrated only over descent + bottom planner segments ...
    let cnsDescentBottomPercent: Double
```

---

## Related documentation

- Algorithm / model: `iOSApp/Services/OxygenExposureModels.swift` (`CNSDescentBottomPlannerRule`, `cnsPercentDescentAndBottom`)
- Settings: `iOSApp/Utils/PlannerCNSDescentBottomCheckSettings.swift`, `MoreView.swift`
- Physical VoiceOver evidence: **external QA** — `Docs/IOS_DYNAMIC_TYPE_VOICEOVER_QA_MATRIX.md`

---

*Audit performed from source and localization on `main`; no UI screenshots or device VoiceOver logs attached.*
