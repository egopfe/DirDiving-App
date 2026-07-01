# TestFlight Shallow Depth Risk Assessment — CURRENT

**Command:** 05 — `05-MASTER_RELEASE_QA_EVIDENCE_COMPLIANCE_AUDIT_COMMAND_V1.5.md` §2A.3  
**Baseline:** `main` @ `2c30412`  
**Audit date:** 2026-07-01

---

## A. Executive Summary

Shallow-depth entitlement signing is **internally aligned** for TestFlight. **Full-depth capability is unavailable** unless separately provisioned. Developer shallow Gauge/FC testing toggles are **hidden from public users** (default OFF, dev unlock). **No App Store or TestFlight metadata may claim certified decompression guidance from shallow developer testing.**

**TestFlight shallow-depth risk: CONDITIONAL** — acceptable for **internal** TestFlight with truthful disclosure; **not acceptable** for external/public claims without wet QA (CONS-042).

---

## B. Entitlement Configuration

| Item | Value @2c30412 | Status |
|---|---|---|
| Default Watch entitlements | `Config/DIRDiving.WithShallowDepth.entitlements` | Aligned |
| Shallow capability key | `com.apple.developer.submerged-shallow-depth-and-pressure` | Present |
| Full-depth alternate | `Config/DIRDiving.WithWaterSubmersion.entitlements` | Documented, not default |
| `DIRDepthEntitlementTier` | `shallow` in App/Info.plist | Aligned |
| `WKSupportsAutomaticDepthLaunch` | **true** | Software PASS; physical listing PENDING |
| `WKBackgroundModes` | `underwater-depth` | Present |
| Runtime depth authority | DepthCapabilityPolicy + CONS-007 | PASS |

---

## C. Developer Shallow Testing Gates

| Gate | Software | Public Exposure Risk |
|---|---|---|
| Developer shallow Gauge toggle | PASS — default OFF | **LOW** if TF notes label internal |
| Developer shallow FC toggle | PASS — default OFF | **MEDIUM** (SDG-008) — FC deco in shallow bath |
| TestFlight/internal flags labeled | PASS — DeveloperSettings | Verify TF what-to-test |
| App Store screenshots expose dev toggles | **PASS** — not in public UI | Monitor ASC assets |
| Claim shallow testing = certified deco | **PASS** — no such claim | Maintain |

---

## D. Physical / Wet Risks

| Risk | Severity | Mitigation |
|---|---|---|
| Shallow ~6m limit not field-verified | P1 | Execute CONS-042 wet QA before external TF |
| WAO routes FC predive in shallow build | P2 | Software PASS; physical WAO PENDING |
| GF presets in shallow FC dev session | P2 | Copy: user conservatism, not validation |
| System Auto-Launch listing unverified | P2 | Truthful Settings limitation copy present |

---

## E. TestFlight Recommendations

**Internal TestFlight:**
- **ALLOW** with what-to-test disclosure: shallow-depth limited; not certified dive computer; physical QA pending; developer shallow FC is internal QA only.
- Include WFC-P2-005 known routing test drift in release notes (non-FC).

**External TestFlight:**
- **BLOCK** until CONS-042 shallow wet QA + CMAltimeter physical + WAO physical complete.

---

## F. Verdict

```text
SHALLOW_DEPTH_TESTFLIGHT_INTERNAL: CONDITIONAL (disclosure required)
SHALLOW_DEPTH_TESTFLIGHT_EXTERNAL: NOT_READY
SHALLOW_DEPTH_APP_STORE: NOT_READY
FULL_DEPTH_ENTITLEMENT: NOT_AVAILABLE (default signing)
```

Matrix: [`MASTER_SHALLOW_DEPTH_RELEASE_GATE_MATRIX_CURRENT.csv`](MASTER_SHALLOW_DEPTH_RELEASE_GATE_MATRIX_CURRENT.csv)
