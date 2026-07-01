# External Validation Gaps — CURRENT

**Command:** 05 — `05-MASTER_RELEASE_QA_EVIDENCE_COMPLIANCE_AUDIT_COMMAND_V1.5.md`  
**Baseline:** `main` @ `2c30412`  
**Audit date:** 2026-07-01  
**Upstream:** Audits 01–04 COMPLETE @ `2c30412`

---

## A. Executive Summary

External validation remains **0% executed** for third-party decompression oracle comparison. Internal automated oracle coverage is **strong** (Audit-15 ML profiles, Schreiner parity, independent TTS sweep). No external evidence may be inferred from simulator, unit tests, or self-comparison.

| Category | Internal Software | External Executed | Release Block |
|---|---|---|---|
| Bühlmann ZH-L16C | **PASS** | **No** | WFC-P1-001 |
| Schreiner integration | **PASS** | **No** | Bundled |
| Subsurface comparison | N/A | **No** | P2 |
| CCR rebreather | Reference-only | **No** | P2 |
| Ratio Deco | Heuristic tests PASS | **No** | P3 |
| Rock Bottom / Gas ledger | Unit tests PASS | **No** | P3 |
| Repetitive-dive field | Software PASS | **No** | P2 |
| PDF/export round-trip | Unit tests PASS | **No** | P2 |
| Privacy/legal review | Static PASS | **No** | CONS-044 |
| Accessibility manual | Contract tests PASS | **No** | P2 |
| App Store review | N/A | **No** | PENDING_APP_STORE_REVIEW |

---

## B. Bühlmann External Validation

**Status:** PENDING_EXTERNAL_VALIDATION  
**Finding:** WFC-P1-001 / CONS-009  
**Internal evidence:** Audit15Air39MultilevelProfileTests, Audit15MultilevelOracleProfilesTests ML-01…ML-10, Audit15TTSScheduleOracleSweepTests — all **PASS** @ `2c30412`  
**External evidence folder:** `Docs/QA_EVIDENCE/BUHLMANN_EXTERNAL/` — **empty / template only**  
**Plan:** [`MASTER_WATCH_FULL_COMPUTER_EXTERNAL_VALIDATION_PLAN_CURRENT.md`](MASTER_WATCH_FULL_COMPUTER_EXTERNAL_VALIDATION_PLAN_CURRENT.md)

**Gap:** No Subsurface, MultiDeco, or independent reference tool comparison executed.

---

## C. Schreiner External Validation

**Status:** PENDING_EXTERNAL_VALIDATION (bundled with Bühlmann campaign)  
**Internal evidence:** SchreinerAnalyticParityTests, BuhlmannSchreinerEquationTests — **PASS**

---

## D. Subsurface Validation

**Status:** PENDING_EXTERNAL_VALIDATION  
**Folder:** `Docs/QA_EVIDENCE/SUBSURFACE_EXTERNAL/` — not executed  
**Internal:** CSV export tests PASS; no external round-trip

---

## E. CCR / Rebreather Validation

**Status:** PENDING_EXTERNAL_VALIDATION — **reference-only by design**  
**Internal:** CCRMathRemediationTests PASS  
**Documentation:** `Docs/CCR_REBREATHER_LIMITATIONS.md` — no controller certification claim

---

## F. Ratio Deco / Rock Bottom / Gas Ledger

| Area | Internal | External |
|---|---|---|
| Ratio Deco heuristic | RatioDecoPlannerTests PASS | PENDING |
| Rock Bottom estimate | GasLedgerDisplayFormatterTests PASS | PENDING |
| Gas ledger cylinder bar | GasLedgerDisplayFormatterTests PASS | PENDING |

Copy audited: estimates labeled, not certified calculations.

---

## G. Software Gates Closed Since @451f8fb

| ID | Prior | Current |
|---|---|---|
| IOS-P1-001 | BLOCKED | **CLOSED** |
| CONS-046 | FAIL | **CLOSED** (V1.5) |
| Watch TTS crash | FAIL | **CLOSED** |

These are **software** gates — not external validation.

---

## H. Remediation Priority

1. **P1:** Execute Bühlmann external validation campaign (WFC-P1-001)  
2. **P2:** Subsurface CSV round-trip with external tool  
3. **P2:** Snorkeling GPS field validation (CONS-048)  
4. **P2:** Fix WFC-P2-005 Watch routing test drift (software, not external)  
5. **P1:** Legal/marketing review (CONS-044)

---

## I. Verdict

```text
EXTERNAL_BUHLMANN_VALIDATION: PENDING_EXTERNAL_VALIDATION
EXTERNAL_SCHREINER_VALIDATION: PENDING_EXTERNAL_VALIDATION
EXTERNAL_SUBSURFACE_VALIDATION: PENDING_EXTERNAL_VALIDATION
CCR_EXTERNAL_VALIDATION: PENDING_EXTERNAL_VALIDATION (reference-only)
```

No external validation claim is supported at `2c30412`.
