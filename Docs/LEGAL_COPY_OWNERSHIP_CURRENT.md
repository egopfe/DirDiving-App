# Legal Copy Ownership (Current)

**Date:** 2026-06-20

---

## Ownership model

| Layer | Owner document | Surfaces |
|-------|----------------|----------|
| Canonical safety/legal policy | `Docs/SAFETY_DISCLAIMER.md`, `Docs/TERMS_OF_USE.md`, `Docs/PRIVACY_POLICY.md` | All activities |
| iOS companion nuance | `Docs/iOS/SAFETY_DISCLAIMER.md`, `Docs/IOS_PLANNER_LIMITATIONS.md` | Planner, logbook, exports |
| Activity-specific limitations | `Docs/CCR_REBREATHER_LIMITATIONS.md`, `Docs/FULL_COMPUTER_ARCHITECTURE.md`, Snorkeling/Apnea release docs | Mode-specific |
| Runtime concise copy | Semantic localization keys (`Resources/`, `iOSApp/Resources/`) | In-app UI |
| Store positioning | `Docs/TESTFLIGHT_REVIEW_NOTES.md`, `Docs/QA_EVIDENCE/APP_STORE_MARKETING/` | TestFlight / App Store |
| Export immutable text | PDF builders + export string keys | PDF/CSV/briefing |

---

## Variant rules

- **Full disclaimer:** legal onboarding scroll text (`LegalDisclaimer.txt`, settings).
- **Concise banner:** planner `planner.reference_only.warning`, CCR `ccr.safety.disclaimer`.
- **Export footer:** PDF/CSV disclaimers — must not be weaker than in-app copy.
- **EN/IT parity:** required for all semantic keys; no sentence-as-key for new legal strings.

---

## Change process

1. Update canonical policy doc.
2. Update claims registry CSV row(s).
3. Update localization keys EN/IT.
4. Run prohibited-claims scan + legal readiness gate.
5. Bump `legalRevision` if user-facing legal meaning changes (counsel review).

---

## Contradiction check

`Scripts/scan_prohibited_claims.py` + `ReleaseLegalClaimsRemediationTests` + manual review of `TESTFLIGHT_REVIEW_NOTES.md` vs `SAFETY_DISCLAIMER.md`.
