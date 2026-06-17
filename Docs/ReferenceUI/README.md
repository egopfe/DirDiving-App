# Reference UI assets (visual regression QA)

**Internal gate (automated):** **PASS** — `FullComputerMockupReferenceMatrixTests` (25 mockup IDs, no raster in bundle) + `FullComputerUIStateMatrixTests` (20 live-deco fixture states, EN/IT title keys). Run via `./Scripts/validate_full_computer_release_readiness.sh`.

**External App Store PNG pack:** **PENDING** — optional simulator captures below. Do not mark external visual gate PASS until files are committed under [`Docs/QA_EVIDENCE/REFERENCE_UI/`](../QA_EVIDENCE/REFERENCE_UI/README.md).

**Evidence sign-off:** [`Docs/QA_EVIDENCE/REFERENCE_UI/README.md`](../QA_EVIDENCE/REFERENCE_UI/README.md)  
**Manual checklist:** [`Docs/MAIN_UI_TEXT_QA_CHECKLIST.md`](../MAIN_UI_TEXT_QA_CHECKLIST.md)

---

## Automated substitute vs manual PNG capture

| Layer | Coverage | Blocking |
|-------|----------|----------|
| Mockup index (25 × `FC_UI_*`) | Matrix + fixture key mapping | Internal FC release — **no** |
| Live deco presentation (20 states) | `FullComputerLivePanelFixtures` + l10n key tests | Internal FC release — **no** |
| Simulator PNG screenshots (41/45/49 mm, EN/IT) | Manual capture into this folder | App Store visual gate only |

Full Computer raster mockups (`FC_UI_01` … `FC_UI_25`) remain **external design references** — not embedded in the app bundle (verified by test).

---

## Screenshot capture checklist (UI/UX remediation)

Complete before App Store visual gate or marking reference UI PASS.

### Apple Watch — DIRDiving Watch App

| Item | Simulators | Locales | Status |
|------|------------|---------|--------|
| Live Dive (depth, TTV, ascent gauge, mission + sync + GPS badges) | 41 mm, 45 mm, 49 mm | EN, IT | PENDING |
| Settings, Alarms, Logbook rows | 41 mm, 45 mm, 49 mm | EN, IT | PENDING |
| Inline ascent banner (non full-screen) | 41 mm minimum | EN | PENDING |

### iOS — DIRDiving Companion

| Item | Simulators | Locales | Status |
|------|------------|---------|--------|
| Planner (Base / Deco / Technical / CCR tabs) | iPhone SE, iPhone 17 | EN, IT | PENDING |
| Logbook + dive detail | iPhone SE, iPhone 17 | EN, IT | PENDING |
| More tab + legal onboarding hero | iPhone SE, iPhone 17 | EN, IT | PENDING |
| Watch photo transfer panel | iPhone 17 | EN | PENDING |

### Policies

- Do **not** fabricate or AI-generate reference images.
- Save captures here without altering in-app copy.
- Use exact MAIN filenames below; add `_41` / `_45` / `_49` / `_en` / `_it` suffixes when multiple variants are needed.
- Terminology: UI copy uses **BUSSOLA**, never COMPASSO.

---

## Mandatory MAIN references (when captured)

| File | Purpose | Source |
|------|---------|--------|
| `Watch_LIVE_reference.png` | Apple Watch Live Dive — depth, TTV, inline ascent banner, compact GPS | `main` — DIRDiving Watch App sim 41/45/49 mm |
| `iOS_Companion_reference.png` | iOS Companion — Planner, Logbook, More tabs | `main` — DIRDiving iOS sim |

## Ascent / safety UX reference

| File | Purpose |
|------|---------|
| `ascent_warning_inline_reference.png` | Inline red ascent banner (non full-screen); depth/gauge/controls remain visible |

Policy: [`Docs/WATCH_MAIN_UX_CONVENTIONS.md`](../WATCH_MAIN_UX_CONVENTIONS.md)

## Experimental references (branch-specific — not MAIN runtime)

Capture from experimental branches only; do not merge experimental UI into MAIN docs as production-ready:

| File | Branch | Purpose |
|------|--------|---------|
| `Snorkeling_Live_reference.png` | `codex/experimental-features` | Snorkeling Live surface |
| `Snorkeling_Waypoint_Map_reference.png` | idem | Waypoint map |
| `Snorkeling_Return_Map_reference.png` | idem | Return map |
| `Apnea_Workflow_reference.png` | `codex/experimental-features` / `codex/ios-experimental-features` | Apnea workflow screens |
| FC_UI_01 … FC_UI_25 (external PNGs) | `integration/full-computer` | Full Computer state matrix — indexed in [`FULL_COMPUTER_RELEASE_HARD_TEST_MATRIX.md`](../FULL_COMPUTER_RELEASE_HARD_TEST_MATRIX.md); **do not commit raster mockups into this repo** |

Mark all experimental captures **Experimental / not production** in commit messages and CSV `Notes`.

## How to create

1. Run **DIRDiving Watch App** on simulators: 41 mm, 45 mm, 49 mm — Live Dive with representative badges (mission, sync, GPS, stale depth optional).
2. Run **DIRDiving iOS** on iPhone SE and iPhone 17 — Planner, Logbook, More, Watch photo panel; repeat key screens in IT system language.
3. Save screenshots here without altering in-app copy.
4. Naming convention (exact for MAIN):
   - `Watch_LIVE_reference.png`
   - `iOS_Companion_reference.png`
5. Do **not** fabricate or AI-generate reference images.

## Text/clipping QA

Until PNGs exist, use the checklist in `Docs/MAIN_UI_TEXT_QA_CHECKLIST.md` for manual simulator passes.

External screenshot QA is required before the App Store release gate can pass.
