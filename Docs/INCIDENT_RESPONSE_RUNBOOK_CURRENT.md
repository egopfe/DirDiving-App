# Incident Response Runbook (Current)

**Date:** 2026-06-20  
**Scope:** DIR DIVING MAIN (Watch + iOS)  
**Not legal advice.** Role-based ownership only — assign names at execution time.

---

## Severity scale

| Level | Definition | Examples |
|-------|------------|----------|
| P0 | Immediate safety or false certification claim in production | Wrong mandatory stop; unsupported certified claim in store copy |
| P1 | Data loss, privacy breach, major sync failure | Tombstone failure; exposed private data |
| P2 | Degraded feature, crash spike, incorrect non-safety display | Chart glitch; export formatting |
| P3 | Documentation/process gap | Stale TestFlight notes |

---

## P0 emergency procedure

1. **Contain:** Pause external TestFlight / App Store phased release if active.
2. **Disable claim:** Remove or correct false certification/safety marketing immediately.
3. **Feature gate:** Disable affected surface if code flag or release rollback available (see rollback doc).
4. **Notify:** Product owner → technical owner → legal counsel (if claim/privacy/safety).
5. **Preserve:** Retain logs, builds, store copy screenshots, user reports.
6. **Communicate:** Internal status update; user communication only with legal approval.
7. **Verify fix:** Re-run `validate_release_legal_claims_readiness.sh` + domain tests.
8. **Postmortem:** Required within 5 business days.

---

## Incident playbooks

### Safety-critical algorithm display (Watch FC / Planner)

- **Trigger:** Report of false NDL/TTS/ceiling or gas guidance.
- **Owner:** Algorithm owner + Watch/iOS technical lead.
- **Contain:** Stop external distribution; document reproduction profile.
- **Do not** claim EN13319 compliance or certified status in communications.

### False certification / marketing claim

- **Trigger:** Prohibited-claims scanner failure or App Store complaint.
- **Owner:** Product + legal counsel.
- **Contain:** Halt store submission; archive offending copy.

### Data loss / sync / tombstone

- **Trigger:** Resurrection after delete; merge data loss.
- **Owner:** Sync technical owner.
- **Contain:** Document paired devices; preserve WC logs.

### Privacy / security

- **Trigger:** Unexpected export of GPS; auth bypass; leaked payload.
- **Owner:** Security/privacy owner.
- **Contain:** Disable affected export/sync path if needed.

### Entitlement / depth sensor failure

- **Trigger:** Silent fallback without user-visible label.
- **Owner:** Watch platform owner.
- **Contain:** Verify simulation badge visible; update TestFlight notes.

---

## Closure criteria

- Root cause documented.
- Fix or accepted risk recorded in `RELEASE_LEGAL_FINDING_TRACEABILITY_CURRENT.csv`.
- Regression tests added where software-verifiable.
- External gates re-evaluated before release resume.

---

## Evidence retention

Store incident artifacts under `Docs/QA_EVIDENCE/INCIDENTS/` (create per incident; do not pre-fill fake incidents).
