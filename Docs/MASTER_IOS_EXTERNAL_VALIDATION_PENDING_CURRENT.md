# DIR Diving iOS — External Validation and Physical QA Pending — CURRENT

**Audit command:** `02-MASTER_IOS_FULL_DEEP_COMPREHENSIVE_AUDIT_COMMAND_V1.5`  
**Baseline:** `main` @ `2c30412`  
**Audit date:** 2026-07-01

All items below remain **PENDING** unless signed evidence exists under `Docs/QA_EVIDENCE/`. Simulator passes, static audits, and internal unit tests **do not** satisfy these gates.

---

## External validation pending

| Gate | Status | iOS relevance | Evidence path |
|---|---|---|---|
| Bühlmann external decompression validation | **PENDING_EXTERNAL_VALIDATION** | Planner + shared BuhlmannCore | `Docs/QA_EVIDENCE/BUHLMANN_EXTERNAL/` — upstream **WFC-P1-001** |
| Subsurface CSV desktop round-trip | **PENDING_EXTERNAL_VALIDATION** | Diving logbook export/import | `Docs/QA_EVIDENCE/SUBSURFACE_EXTERNAL/` |
| CCR external validation | **PENDING_EXTERNAL_VALIDATION** | CCR planner reference-only UI | `Docs/QA_EVIDENCE/CCR_EXTERNAL/` |
| Ratio Deco external validation | **PENDING_EXTERNAL_VALIDATION** | Heuristic comparative overlay | Not executed — Bühlmann remains primary |
| PDF/export legal review | **PENDING_EXTERNAL_VALIDATION** | Plan/briefing/checklist PDFs | `Docs/QA_EVIDENCE/PDF_PHYSICAL_RENDER/` |
| GF preset external spot-check | **PENDING_EXTERNAL_VALIDATION** | iOS→Watch GF package (CONS-043) | Software parity PASS; external oracle pending |
| App Store legal/marketing counsel | **PENDING_EXTERNAL_VALIDATION** | Release claims registry | `APP_STORE_TESTFLIGHT_BLOCKERS` |

---

## Physical QA pending (iOS-relevant)

| Gate | Status | Scope |
|---|---|---|
| Physical iPhone QA | **PENDING_PHYSICAL** | General companion flows, logbook scroll at cap (CONS-025) |
| Paired Watch↔iPhone sync QA | **PENDING_PAIRED_DEVICE_QA** | Tombstone HMAC, briefing PNG, large payload, diveImportAck field (CONS-011) |
| iCloud two-device merge | **PENDING_PHYSICAL** | Diving logbook cloud backup (CONS-029) |
| Accessibility manual QA | **PENDING_PHYSICAL** | VoiceOver, Dynamic Type on device (CONS-012) |
| Snorkeling field GPS + battery | **PENDING_PHYSICAL** | Long-route navigation trust (CONS-031) |
| Snorkeling P1/P2/P3 open-water QA | **PENDING_PHYSICAL** | 12 `SNORKELING_*` evidence folders (CONS-048) |
| Apnea wet auto-detection field QA | **PENDING_PHYSICAL** | Apnea P1/P2/P3 @ `76f3703` — Watch primary; iOS companion sync/export only |
| Snorkeling fake logbook device QA | **PENDING_PHYSICAL** | Demo banner + toggle behavior on device |
| Snorkeling map UX field QA | **PENDING_PHYSICAL** | Center-on-location, map type, reset map confirmation |
| PDF physical render QA | **PENDING_PHYSICAL** | Golden PDF on device (CONS-013) |
| Watch water-auto-open routing | **PENDING_PHYSICAL** | Upstream **WFC-P2-005** — 13 Watch routing test failures; FC math unaffected |

---

## Explicit non-claims preserved

- iOS Planner is **reference/planning support**, not a certified decompression planner.
- Watch briefing cards are **reference-only** (`PlannerBriefingCardManifest.referenceOnly == true`).
- CCR planner output is **reference-only**; no live loop PPO2 monitoring or certified CCR controller claim.
- Apnea recovery countdown is **not** a medical guarantee.
- Water auto-open on Watch **does not** start an Apnea session (reference routing only).
- No EN13319 / ISO 6425 / CE certification claim without official evidence.
- App Store readiness **not** asserted at this audit baseline.

---

## Software evidence that does NOT close external/physical gates

- `xcodebuild` iOS MAIN **BUILD SUCCEEDED** @ `2c30412`
- iOS Algorithm Tests **TEST SUCCEEDED** — **1655 executed, 0 failures** @ `2c30412`
- CONS-002/003/004/005 code verification **PASS** (static + tests)
- CONS-046 V1.5 command integrity script **PASS** @ `2c30412`
- Snorkeling route planner P1/P2/P3 **software implemented** with unit tests PASS
- Apnea iOS companion scope **software PASS** — live session/detection on Watch; iOS is planning/logbook/settings/export
