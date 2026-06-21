# DIR DIVING — Claims Policy Registry (Current)

**Command:** 13 remediation  
**Date:** 2026-06-20  
**Branch:** `main`  
**Canonical CSV:** [`CLAIMS_POLICY_REGISTRY_CURRENT.csv`](CLAIMS_POLICY_REGISTRY_CURRENT.csv)

This registry is the **single canonical source** for allowed/prohibited product wording. It is used for documentation, validation scripts, and tests — **not** loaded at runtime.

---

## Global policy (mandatory)

- DIR Diving is **not** a certified dive computer.
- **Not** EN 13319 or ISO 6425 certified.
- Does **not** guarantee diving safety.
- Does **not** replace training, judgment, procedures, or certified equipment.
- Reference-only calculations remain explicitly labeled.
- External validation must **not** be implied before evidence exists.

---

## Activity summary

| Activity | Allowed posture | Primary disclaimer surfaces |
|----------|-----------------|----------------------------|
| Gauge | TTV informational only | Watch live, logbook detail |
| Full Computer | Non-certified experimental runtime | Watch live, briefing footer, architecture docs |
| Planner | Reference-only Bühlmann/heuristics | Planner ack, result tabs, exports |
| CCR | Reference planner; heuristic bailout | CCR safety banner, PDF |
| Apnea | Recovery policy tracking | Settings, ready/surface copy |
| Snorkeling | Reference return navigation | Return/nav strings, GPS degraded states |

---

## Prohibited claims (never in production without negation)

See [`PROHIBITED_CLAIMS_ALLOWLIST_CURRENT.csv`](PROHIBITED_CLAIMS_ALLOWLIST_CURRENT.csv) and `Scripts/scan_prohibited_claims.py`.

---

## External review matrix

| Claim domain | External review required |
|--------------|-------------------------|
| App Store marketing copy | Legal + Marketing |
| Bühlmann marketing beyond reference-only | Legal + External validation |
| CCR marketing beyond reference-only | Legal + External validation |
| Underwater depth reliability | Physical Ultra QA |
| Paired sync reliability | Physical paired QA |

---

## Validation

```bash
./Scripts/validate_release_legal_claims_readiness.sh
```
