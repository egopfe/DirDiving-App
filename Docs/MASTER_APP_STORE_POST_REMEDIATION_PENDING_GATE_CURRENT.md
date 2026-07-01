# App Store Post-Remediation Pending Gate — CURRENT

**Command:** 05 §2B  
**Baseline:** `main` @ `2c30412`  
**Audit date:** 2026-07-01

---

## Pending Gates (Not Closed by Software Remediation)

| Gate ID | Category | Status | Severity | Notes |
|---|---|---|---|---|
| MASB-P-01 | Physical Watch QA | PENDING_PHYSICAL | P1 | 0% executed — CMAltimeter, depth, WAO |
| MASB-P-02 | Physical iPhone QA | PENDING_PHYSICAL | P1 | VoiceOver, PDF, scroll, Instruments |
| MASB-P-03 | Paired-device QA | PENDING_PHYSICAL | P1 | WC sync, briefing transfer, tombstones |
| MASB-P-04 | Underwater / depth sensor | PENDING_PHYSICAL | P1 | Shallow wet Gauge/FC |
| MASB-P-05 | External Bühlmann/Schreiner | PENDING_EXTERNAL_VALIDATION | P1 | WFC-P1-001 / CONS-009 |
| MASB-P-06 | Legal / marketing review | PENDING_LEGAL_REVIEW | P1 | CONS-044 counsel sign-off |
| MASB-P-07 | App Store assets / screenshots | PENDING_EVIDENCE | P2 | Marketing pack incomplete |
| MASB-P-08 | Snorkeling field QA | PENDING_PHYSICAL | P1 | CONS-048 — 12/12 templates |
| MASB-P-09 | Apnea wet QA | PENDING_PHYSICAL | P2 | Auto-detection, recovery UX |
| MASB-P-10 | Full-depth entitlement | NOT_AVAILABLE | P2 | Shallow-only default signing |
| MASB-P-11 | Accessibility manual QA | PENDING_PHYSICAL | P2 | VoiceOver field pass |
| MASB-P-12 | Incident / rollback drill | NOT_EXECUTED | P3 | Process documented; drill pending |

---

## Software Remediation Did NOT Close

```text
Physical Watch, underwater, Water Lock, Action Button, Digital Crown, shallow wet
Paired-device field sync
External Bühlmann / Subsurface / CCR validation
Legal counsel App Store marketing sign-off
Full-depth entitlement provisioning
Snorkeling open-water GPS (12 templates)
Apnea wet auto-detection field validation
```

---

## Verdict

```text
APP_STORE_WITH_LEGAL_PHYSICAL_EXTERNAL_GATES: NOT_READY
EXTERNAL_TESTFLIGHT_WITH_PHYSICAL_GATES: NOT_READY
NO_FAKE_PHYSICAL_EXTERNAL_CLAIMS: PASS
RELEASE_SOFTWARE_READINESS_AFTER_REMEDIATION: 82
```
