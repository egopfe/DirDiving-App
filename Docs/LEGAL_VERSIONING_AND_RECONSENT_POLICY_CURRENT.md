# Legal Versioning and Re-consent Policy (Current)

**Date:** 2026-06-20  
**Branch:** `main`

---

## Canonical version model

| Field | Watch source | iOS source | Current value |
|-------|--------------|------------|---------------|
| `legalRevision` | `LegalAcceptanceStore.legalRevision` | `LegalAcceptanceStore.legalRevision` | `2026-05-23` |
| `termsVersion` | Documented in `Docs/TERMS_OF_USE.md` | Same | 2026-05-25 |
| `privacyVersion` | `Docs/PRIVACY_POLICY.md` | Same | Per policy doc date |
| `safetyVersion` | `Docs/SAFETY_DISCLAIMER.md` | `Docs/iOS/SAFETY_DISCLAIMER.md` | 2026-05-19 baseline |
| `revisionClass` | Major legal / typo-only | — | Major bump → re-consent |

Persisted acceptance record (`LegalAcceptanceRecord`):

- timestamp, appVersion, appMajorVersion, deviceType, languageCode, legalRevision
- depth limits acknowledged (Watch/iOS)

---

## Re-consent triggers

Re-consent **required** when:

1. No prior acceptance record exists.
2. `appMajorVersion` changes (major version bump).
3. `legalRevision` constant changes in code.
4. Depth operating limits not acknowledged (Watch/iOS legal flow).

Re-consent **not** required for:

- Typo-only documentation fixes that do not change `legalRevision`.
- Patch/minor app versions within same major version (unless `legalRevision` bumped).

---

## Bypass prevention (software-verified)

| Surface | Gate | Test |
|---------|------|------|
| App Intents / Action Button | `LegalAcceptanceGate` | `ActionButtonIntentsSafetyTests`, `LegalAcceptanceGateTests` |
| Legal onboarding UI | Blocks main UI until accept | Manual + automated key coverage |
| TestFlight simulation | Acknowledgment required (Command 9) | `SecurityPrivacyTrustRemediationTests` |

Deep links and activity selection must not skip legal onboarding on cold launch (existing app entry flow).

---

## Migration

Existing users retain acceptance timestamp and version fields. Bumping `legalRevision` invalidates prior acceptance without deleting historical fields.

---

## Counsel review

Any change to `legalRevision` or substantive Terms/Privacy/Safety text requires **PENDING_LEGAL_REVIEW** before external release.
