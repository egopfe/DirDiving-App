# DIR DIVING — Release, Legal & Claims Compliance Audit (Current)

**Command:** 13 — `13-DIR_DIVING_RELEASE_LEGAL_CLAIMS_COMPLIANCE_AUDIT_V3.0`  
**Date:** 2026-06-20  
**Branch:** `main`  
**Preflight HEAD:** `dff88e6` (uncommitted Command 12 remediation on working tree)  
**Task type:** Read-only audit (reports only)

**Not claimed:** Legal certification approval, CE/EN13319/ISO 6425 compliance, App Store review approval, external counsel sign-off, or attorney review of store copy.

**Policy:** Unsupported certification or safety guarantees in product copy are **FAIL**. Documented reference-only posture with pending external gates is **CONDITIONAL PASS**.

---

## Executive summary

DIR DIVING MAIN maintains a **consistent non-certified, reference-only product posture** across legal onboarding, Terms/Privacy, safety disclaimers, planner/Full Computer/CCR/Apnea/Snorkeling copy, TestFlight review notes, and export PDF disclaimers. Automated tests cover legal localization keys and Command 12 software gates; privacy manifests declare no tracking.

**No P0/P1 unsupported certification claims** were found in MAIN production strings or primary safety documents. Residual risk is **release positioning and external gates**: App Store marketing assets, legal/marketing sign-off, physical depth-entitlement validation, and external algorithm validation campaigns remain **PENDING**.

| Dimension | Score (0–100) | Notes |
|-----------|---------------|-------|
| Non-certification posture (code + strings) | **96** | Explicit EN/IT disclaimers; planner/FC/CCR reference-only |
| Safety claim truthfulness (software-verified) | **94** | TTV, GPS surface-only, CNS/OTU estimates labeled |
| Store/TestFlight positioning docs | **88** | `TESTFLIGHT_REVIEW_NOTES.md` aligned; assets PENDING |
| Privacy & entitlement disclosures | **92** | Privacy manifests; entitlement field QA PENDING |
| Physical/external QA gates documented | **85** | Matrices exist; evidence folders PENDING |
| External legal / marketing sign-off | **40** | No signed legal review artifact |
| EN13319 / regulatory strategy | **90** | Documented out-of-scope; no false certification claim |
| Incident / rollback / support process | **82** | Release checklist + GitHub; formal SLA PENDING |
| **Overall claims compliance readiness** | **88** | Strong software posture; external legal/store blocked |

**P0:** 0  
**P1:** 0  
**P2:** 6 open (external legal, marketing assets, field QA, external validation)  
**P3:** 4 open (equipment checklist polish, formal support SLA)  
**INFO:** 12 positive controls

---

## Preflight

| Check | Result |
|-------|--------|
| Branch | `main` |
| HEAD | `dff88e6` |
| `origin/main` | Aligned at audit start |
| Test files | **301** |
| Validation scripts | **17** (incl. Command 12 gate on working tree) |
| Physical QA executed in this pass | **No** |
| Legal counsel review | **Not evidenced** |

---

## Scope verification

### No unsupported certification claim — **PASS (software)**

- [`Docs/SAFETY_DISCLAIMER.md`](SAFETY_DISCLAIMER.md), [`Docs/TERMS_OF_USE.md`](TERMS_OF_USE.md), [`Docs/iOS/SAFETY_DISCLAIMER.md`](iOS/SAFETY_DISCLAIMER.md)
- iOS strings: `planner.reference_only.warning`, `ccr.safety.disclaimer`, `planner.buhlmann.reference_disclaimer`
- Watch briefing footer: `briefing.reference_only.footer`
- [`Docs/IOS_APP_STORE_ALGORITHM_MARKETING_REVIEW_CHECKLIST.md`](IOS_APP_STORE_ALGORITHM_MARKETING_REVIEW_CHECKLIST.md) prohibits certified dive-computer claims
- EN13319 / ISO 6425 explicitly **out of scope** in FC/Apnea/Snorkeling release docs

### Apple Watch not presented as certified DC — **PASS (software)**

- Legal onboarding: “DIR Diving is NOT a dive computer”
- Depth entitlement documented as **pending hardware validation** ([`SAFETY_DISCLAIMER.md`](SAFETY_DISCLAIMER.md) § Ultra)
- Mock/simulation depth paths labeled; TestFlight notes require fallback badge QA

### Full Computer wording vs capability — **PASS (software)**

- [`Docs/FULL_COMPUTER_ARCHITECTURE.md`](FULL_COMPUTER_ARCHITECTURE.md): experimental, **not certified**
- iOS has **no live FC runtime**; Watch-only decompressive runtime
- Release-hard validation + timing-fault tests; physical battery/thermal **PENDING**

### Planner reference-only — **PASS (software)**

- [`Docs/IOS_PLANNER_LIMITATIONS.md`](IOS_PLANNER_LIMITATIONS.md)
- In-app ack + `planner.reference_only.warning`; export mode disclaimers
- Bühlmann external golden validation **PENDING** — no stronger marketing claim in repo

### CCR limitations — **PASS (software)**

- [`Docs/CCR_REBREATHER_LIMITATIONS.md`](CCR_REBREATHER_LIMITATIONS.md)
- Heuristic bailout; no live loop PPO₂; separate PDF export policy
- External CCR validation **PENDING**

### Apnea recovery not medical guarantee — **PASS (software)**

- Recovery framed as **policy/interval tracking** (`apnea.recovery.state.*`, settings sync from iPhone)
- Audit 05: “Recovery not medical prescription” — **PASS**
- No medical guarantee strings in MAIN engine paths

### Snorkeling return not guaranteed navigation — **PASS (software)**

- Strings use **“Reference”**, **“GPS unavailable/degraded”**, **“when GPS quality allows”**
- `snorkeling.return.gps.unavailable`, `snorkeling.return.heading.stale`
- Not framed as certified navigation or rescue routing

### GPS surface-only disclosure — **PASS (software)**

- Safety disclaimer + More footer: GPS useful **on surface**; unreliable underwater
- Snorkeling/Watch sync docs: surface metadata only

### CNS/OTU estimate wording — **PASS (software)**

- `planner.cns_full_plan.warning.hint`: “Reference only. Not certified decompression advice.”
- NOAA-style model documented as **reference-only** in Bühlmann design docs

### Equipment / checklist limitations — **PASS (software)**

- Pre-dive checklist is **operational preparation**, not life-support verification
- CCR checklist sync documented; import/export reference-only

### TestFlight / App Store metadata — **PARTIAL**

- [`Docs/TESTFLIGHT_REVIEW_NOTES.md`](TESTFLIGHT_REVIEW_NOTES.md) — aligned non-certified posture
- [`Docs/QA_EVIDENCE/APP_STORE_MARKETING/`](QA_EVIDENCE/APP_STORE_MARKETING/README.md) — **PENDING**
- Legal/marketing sign-off table — **PENDING**

### Privacy disclosures — **PASS (software)**

- [`Docs/PRIVACY_MANIFEST_DECLARATION_CURRENT.md`](PRIVACY_MANIFEST_DECLARATION_CURRENT.md)
- Command 9 gate **100% software**; App Store privacy **review PENDING**

### Entitlement status — **PARTIAL**

- Water submersion entitlement configured; **field validation PENDING** on Ultra
- Documented in safety disclaimer and TestFlight notes

### Export disclaimers — **PASS (software)**

- PDF/CSV export includes reference-only and Ratio Deco/CCR disclaimers
- Subsurface external round-trip **PENDING**; software CSV tests PASS

### Physical / external QA gates — **DOCUMENTED, NOT PASSED**

- Command 12: 78% overall evidence; physical/external folders **PENDING**
- See [`APP_STORE_TESTFLIGHT_BLOCKERS_CURRENT.md`](APP_STORE_TESTFLIGHT_BLOCKERS_CURRENT.md)

### EN13319 strategy — **PASS (documentation)**

- Product **denies** EN13319 / ISO 6425 certification in FC, Apnea, Snorkeling release docs
- Strategy: companion/reference tool — not marketed as normative dive computer

### Incident / rollback / release process — **PARTIAL**

- [`Docs/RELEASE_CHECKLIST.md`](RELEASE_CHECKLIST.md) — multi-audit remediation sections
- Git `main` rollback via standard VCS; no formal incident-response runbook **PENDING**

### Support / escalation — **PARTIAL**

- Repository URL + safety disclaimer in TestFlight notes
- No dedicated support SLA or escalation matrix in repo

---

## Findings register

### RLC-P2-001 — External legal counsel review pending
**Status:** NOT PASSED  
**Evidence:** `IOS_APP_STORE_ALGORITHM_MARKETING_REVIEW_CHECKLIST.md` sign-off table empty

### RLC-P2-002 — App Store marketing assets pending
**Status:** NOT PASSED  
**Folder:** `QA_EVIDENCE/APP_STORE_MARKETING/`

### RLC-P2-003 — External Bühlmann/CCR validation pending for algorithm marketing
**Status:** NOT PASSED  
**Folders:** `BUHLMANN_EXTERNAL/`, `CCR_EXTERNAL/`

### RLC-P2-004 — Watch Ultra underwater entitlement field evidence pending
**Status:** NOT PASSED  
**Matrix:** `HARDWARE_QA_MATRIX.md` QA-002

### RLC-P2-005 — Physical accessibility / VoiceOver legal journey pending
**Status:** NOT PASSED  
**Folder:** `QA_EVIDENCE/DYNAMIC_TYPE_VOICEOVER/`

### RLC-P2-006 — Paired-device / iCloud tombstone field QA pending
**Status:** NOT PASSED  
**Folders:** `WATCH_IOS_SYNC/`, `ICLOUD_TWO_DEVICE/`

### RLC-P3-001 — Formal incident-response runbook not in repo
**Status:** OPEN (documentation gap)

### RLC-P3-002 — Dedicated support SLA / escalation path not documented
**Status:** OPEN (documentation gap)

---

## Positive controls (INFO)

| ID | Control |
|----|---------|
| INFO-01 | Legal onboarding with scroll gate + re-consent on major/legal revision |
| INFO-02 | `IOSLegalSettingsLocalizationTests` — bilingual legal keys |
| INFO-03 | Privacy manifests Watch + iOS, no tracking |
| INFO-04 | Command 9 security/privacy software gate 100% |
| INFO-05 | Command 12 traceability + software QA gate (working tree) |
| INFO-06 | CCR/Ratio Deco/Planner reference disclaimers in EN/IT strings |
| INFO-07 | TestFlight review notes list non-certified limitations |
| INFO-08 | EN13319 explicitly denied in release-hard docs |
| INFO-09 | Export PDF/CSV reference disclaimers |
| INFO-10 | Snorkeling return copy uses “reference” / GPS quality qualifiers |
| INFO-11 | Full Computer architecture denies certification |
| INFO-12 | App Store prohibited-claims checklist exists |

---

## Related artifacts

- [`CLAIMS_EVIDENCE_MATRIX_CURRENT.csv`](CLAIMS_EVIDENCE_MATRIX_CURRENT.csv)
- [`RELEASE_GATE_MATRIX_CURRENT.csv`](RELEASE_GATE_MATRIX_CURRENT.csv)
- [`APP_STORE_TESTFLIGHT_BLOCKERS_CURRENT.md`](APP_STORE_TESTFLIGHT_BLOCKERS_CURRENT.md)
- [`TEST_QA_EVIDENCE_AUDIT_CURRENT.md`](TEST_QA_EVIDENCE_AUDIT_CURRENT.md)
- [`SECURITY_PRIVACY_TRUST_AUDIT_CURRENT.md`](SECURITY_PRIVACY_TRUST_AUDIT_CURRENT.md)

---

## Verdict

**CONDITIONAL PASS** at **88/100** release/legal **claims compliance readiness**.

Software and documentation posture is **truthful and non-certified** with no unsupported certification claims found in MAIN. **External legal review, App Store marketing sign-off, and physical/external evidence packs remain NOT PASSED** — **External TestFlight and App Store submission remain blocked** until those gates close.

This audit does **not** constitute legal approval.
