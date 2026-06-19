# 13-DIR_DIVING_RELEASE_LEGAL_CLAIMS_COMPLIANCE_AUDIT_V3.0

**Command version:** 3.0  
**Updated for MAIN:** 2026-06-19  
**Repository:** `egopfe/DirDiving-App`  
**Required branch:** `main`  
**Task type:** audit-only

## ABSOLUTE EXECUTION RULE

This is a read-only audit. Do not modify production code, tests, project configuration, assets, mockups, localization resources or runtime documentation. Generate only the requested audit reports. Do not commit or push.

Run preflight:

```bash
git branch --show-current
git rev-parse --short HEAD
git status
git fetch origin
git status -sb
```

STOP if the branch is not `main`. Record environmental limitations. Do not fix failures.


# OBJECTIVE

Audit release readiness, safety claims, legal wording, store positioning and professional-product truthfulness.

# SCOPE

Verify:

- no unsupported certification claim;
- no claim that Apple Watch is certified where it is not;
- Full Computer wording consistent with actual capability and validation;
- Planner reference-only wording;
- CCR limitations;
- Apnea recovery not framed as medical guarantee;
- Snorkeling return guidance not framed as guaranteed navigation;
- GPS surface-only disclosure;
- CNS/OTU estimate wording;
- equipment/checklist limitations;
- TestFlight/App Store metadata;
- privacy disclosures;
- entitlement status;
- export disclaimers;
- physical/external QA gates;
- EN13319 strategy documentation;
- incident/rollback/release process;
- support/escalation path.

# OUTPUT

Create:

- `Docs/RELEASE_LEGAL_CLAIMS_COMPLIANCE_AUDIT_CURRENT.md`
- `Docs/CLAIMS_EVIDENCE_MATRIX_CURRENT.csv`
- `Docs/RELEASE_GATE_MATRIX_CURRENT.csv`
- `Docs/APP_STORE_TESTFLIGHT_BLOCKERS_CURRENT.md`

Do not give legal certification approval. Mark external legal/certification review pending unless evidenced.
