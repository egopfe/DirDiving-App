# DIR DIVING — App Store Post-Remediation Pending Gate (Current)

**Command:** 05 §2B  
**Date:** 2026-06-30  
**Branch:** `main` @ `451f8fb`

---

## Pending Gates (must remain open until evidence exists)

| Gate | Status | Blocker IDs | Notes |
|------|--------|-------------|-------|
| Physical Watch QA | **PENDING** | PDQ-W-001..038 | 0% executed |
| Physical iPhone QA | **PENDING** | PDQ-I-001..016 | 0% executed |
| Paired-device QA | **PENDING** | PDQ-P-001..008 | 0% executed |
| Underwater / depth sensor | **PENDING** | PDQ-W-025, PDQ-W-032..033 | Shallow wet NOT_EXECUTED |
| CMAltimeter physical | **PENDING** | REQ-FC-08, REQ-ALT-03 | CoreMotion field samples |
| Water auto-open physical | **PENDING** | WAO-PHY-001..003 | System listing NOT_EXECUTED |
| Hardware controls physical | **PENDING** | HWC-PHY-001..004 | Water Lock, Crown, Action Button |
| Snorkeling field QA | **PENDING** | CONS-048 | 12/12 templates |
| External Bühlmann/Schreiner | **PENDING** | WFC-P1-001 | Third-party oracle |
| External Subsurface | **PENDING** | MEXT-SS-01 | Tool round-trip |
| CCR external | **PENDING** | MEXT-CCR-01 | Reference-only posture only |
| Legal counsel review | **PENDING** | CONS-044 | Marketing sign-off |
| ASC metadata / screenshots | **PENDING** | MASB-L-03 | Incomplete assets |
| Full-depth entitlement field | **PENDING** | CAP-W-DEPTH-FULL | Alternate archive only |
| Accessibility manual QA | **PENDING** | PDQ-I-014, PDQ-I-015 | VoiceOver/Dynamic Type |
| Incident / rollback drill | **PENDING** | AB support gate | Not executed |
| iOS test regression | **OPEN** | IOS-P1-001 | Must fix before ASC submission |

---

## App Store Decision

```text
APP_STORE_POST_REMEDIATION_GATE: NOT_READY
REASON: All physical + external + legal gates open; IOS-P1-001 unresolved
NO_FAKE_GATE_CLOSURE: PASS — gates correctly marked PENDING
```

---

**Status:** COMPLETE @ `451f8fb` · 2026-06-30
