# Release Claims Gate Policy (Current)

**Date:** 2026-06-20  
**Matrix:** [`RELEASE_GATE_MATRIX_CURRENT.csv`](RELEASE_GATE_MATRIX_CURRENT.csv)  
**Blockers:** [`APP_STORE_TESTFLIGHT_BLOCKERS_CURRENT.md`](APP_STORE_TESTFLIGHT_BLOCKERS_CURRENT.md)

---

## Gate tiers

| Tier | May proceed when | External evidence |
|------|------------------|-------------------|
| Internal development | Claims scanner PASS; truthful WIP docs | Pending allowed with warnings |
| Internal TestFlight | + legal flow tests; simulation disclosed; non-certified copy visible | Physical QA documented as pending |
| External TestFlight | **Blocked by default** unless product accepts conditional policy | Legal review + critical physical journeys |
| App Store submission | **Blocked** until legal/marketing sign-off + assets + required QA | All P1 blockers closed or accepted risk |

---

## Automated software gate

```bash
./Scripts/validate_release_legal_claims_readiness.sh
```

Must print `RELEASE_LEGAL_CLAIMS_SOFTWARE_GATE_PASS` and `SOFTWARE_VERIFIABLE_FINDINGS_OPEN_0`.

---

## Non-negotiable rules

1. Do not mark App Store or external TestFlight **READY** from documentation alone.
2. Do not fabricate legal counsel approval.
3. Prohibited-claims scanner failure blocks all tiers.
4. Evidence folders must remain **PENDING** until real artifacts exist.

---

## Regression gates

Command 12 test/QA gate and Command 9 security/privacy gate must remain green during claims remediation.
