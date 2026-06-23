# Master Cursor Remediation Command Sequence — Current

**Baseline:** `main` @ `1f62235`  
**Orchestrator:** `00-MASTER_SUPER_ORCHESTRATOR...V1.1`

Execute remediation **only after** Batch 0 gates pass. Do not skip batches without documenting dependency override.

---

## Sequence

| Step | Command / action | Batch | Findings |
|------|------------------|-------|----------|
| 0 | **Batch 0:** Clean DerivedData; full `xcodebuild` iOS + Watch test @ HEAD | Batch-0 | CONS-007 |
| 1 | Watch independent oracle hardening OR documented external tolerance acceptance | Batch-1 | CONS-001 |
| 2 | Re-run `01-MASTER_WATCH` forensic audit (read-only) after any FC math change | Batch-1 | — |
| 3 | iOS navigation state restoration OR documented limitation | Batch-3 | CONS-008 |
| 4 | iOS performance test budget fix (`testTissueAnalyticsCacheBounded`) | Batch-5 | CONS-013 |
| 5 | **Physical QA campaign:** Watch Ultra depth/CMAltimeter matrix | Batch-8 | CONS-003 |
| 6 | **Paired device QA:** sync + briefing + large payload | Batch-8 | CONS-004 |
| 7 | **Accessibility field matrix:** VoiceOver + Dynamic Type | Batch-6 | CONS-005 |
| 8 | **External validation:** Bühlmann reference tool comparison | Batch-8 | CONS-002 |
| 9 | **Subsurface desktop round-trip** on exported CSV | Batch-8 | CONS-011 |
| 10 | Pixel-diff baseline capture (59 mockups) | Batch-6 | CONS-009 |
| 11 | **Release/legal:** PDF golden renders + marketing review | Batch-9 | CONS-006 |
| 12 | Documentation INDEX/README historical block repair | Batch-9 | CONS-012 |
| 13 | Re-run **00 orchestrator** to refresh consolidated plan | — | All |

---

## Do-not-run early

- UI polish-only commands before Batch 1–5 safety/data gates
- Documentation claiming external validation before Batch 8 evidence exists
- Performance micro-optimizations that weaken HMAC/ACK/replay (Batch 7 policy)

---

## Recommended first command after orchestrator

```text
Batch 0 — Full build and test verification @ 1f62235 (clean DerivedData)
```

Then:

```text
Batch 8 — Physical + external QA campaign planning (no code unless blockers found)
```

For software-only remediation first:

```text
Batch 5 — iOS performance test hardening (CONS-013)
Batch 3 — iOS navigation state restoration (CONS-008)
```
