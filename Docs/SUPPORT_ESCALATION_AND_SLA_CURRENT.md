# Support Escalation and SLA (Current)

**Date:** 2026-06-20

**Not legally binding.** Internal service targets subject to final legal/operational approval.

---

## Support channels (readiness checklist)

| Channel | Status | Notes |
|---------|--------|-------|
| GitHub repository issues | Available | https://github.com/egopfe/DirDiving-App |
| In-app Legal & Safety / More | Available | Links to Terms/Privacy |
| Dedicated support email | **PENDING** | Configure before App Store — placeholder in checklist |
| App Store review contact | **PENDING** | App Store Connect |

---

## Categories

| Category | L1 owner | Escalation |
|----------|----------|------------|
| General support | Product support | Technical owner |
| Crash / bug | Technical owner | Platform lead |
| Sync / data loss | Sync owner | Security/privacy owner |
| Safety-critical algorithm display | Algorithm owner | Executive release authority + legal counsel |
| Incorrect decompression display | Algorithm owner | Same as safety-critical |
| GPS / navigation issue | Snorkeling owner | Product owner |
| Privacy / data deletion | Privacy owner | Legal counsel |
| Security report | Security owner | Legal counsel |
| Legal inquiry | Product owner | Legal counsel |
| App Store review | Product/marketing | Legal counsel |

---

## Internal response targets (non-binding)

| Severity | Target first response | Target mitigation start |
|----------|----------------------|-------------------------|
| P0 safety/claim | 4 hours | Immediate |
| P1 data/privacy | 1 business day | 1 business day |
| P2 functional | 3 business days | Next sprint |
| P3 docs/process | 5 business days | Backlog |

---

## Escalation ladder

1. L1 support (triage + reproduction)
2. Technical owner (fix or workaround)
3. Security/privacy owner (if data handling)
4. Product owner (release decision)
5. Legal counsel (claims, privacy, store)
6. Executive release authority (P0 ship/no-ship)

---

## Safety-critical intake

For reports of wrong decompression display or false certification in store copy:

- Assign P0 in incident runbook.
- Do not promise decompression safety in responses.
- Preserve user environment details and build number.

---

## App Store / TestFlight

Review notes must list support route (`TESTFLIGHT_REVIEW_NOTES.md`). Update when dedicated support URL is configured.
