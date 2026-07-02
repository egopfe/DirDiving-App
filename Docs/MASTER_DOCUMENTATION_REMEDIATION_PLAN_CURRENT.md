# MASTER DOCUMENTATION REMEDIATION PLAN (V1.7)

## P0 — Unsafe / unsupported claims

1. File: `Docs/DOCUMENTATION_UPDATE_REPORT_20260614.md`
   - Section: external validation bullet list
   - Exact change required: replace "CCR external validation complete" with "CCR external validation pending" and link evidence matrix
   - Why: unsupported high-risk claim; contradicts audit/release matrices
   - Priority: P0
   - Audit to rerun: 05, 06

2. File: `Docs/INDEX.md`
   - Section: software-ready summary blocks lacking physical/external qualifiers
   - Exact change required: pair any software-ready wording with explicit `PHYSICAL_QA_PENDING` and `EXTERNAL_VALIDATION_PENDING`
   - Why: reduces unsafe interpretation risk
   - Priority: P0
   - Audit to rerun: 05, 06

## P1 — Structural documentation alignment

1. File: `README.md`
   - Section: release baseline row
   - Exact change required: update baseline hash/date and link latest 01-06 + 07 outputs
   - Why: stale baseline drives mismatch in trust chain
   - Priority: P1
   - Audit to rerun: 06

2. File: `Docs/README.md`
   - Section: feature list and branch status
   - Exact change required: remove contradictory experimental statements for Apnea/Snorkeling on MAIN
   - Why: architecture/logbook/settings ownership truthfulness
   - Priority: P1
   - Audit to rerun: 02, 03, 06

3. File: `Docs/INDEX.md`
   - Section: command index blocks
   - Exact change required: normalize command references to V1.7 00-06 and documented post-remediation/remediation lanes
   - Why: command sequence integrity
   - Priority: P1
   - Audit to rerun: 06

4. File: `commands_for_cursor/*`
   - Section: canonical command chain
   - Exact change required: add missing `07 ... V1.7` and `10 ... V1.0` files (or rename canonical artifacts)
   - Why: command-version matrix contradiction
   - Priority: P1
   - Audit to rerun: 00, 06

5. File: `Docs/MASTER_COMMAND_SEQUENCE_VERSION_ALIGNMENT_CURRENT.csv`
   - Section: expected chain rows
   - Exact change required: keep missing-state rows until files exist
   - Why: prevents false green command status
   - Priority: P1
   - Audit to rerun: 06

## P2 — Index, matrices, linkage

1. File: `Docs/INDEX.md`
   - Section: V1.7 GPS/unified logbook sections
   - Exact change required: add direct links to unified-logbook, GPS, location privacy, and test-evidence alignment matrices
   - Why: discoverability and audit traceability
   - Priority: P2
   - Audit to rerun: 02, 03, 04, 05, 06

2. File: `Docs/DIR_DIVING_Feature_Comparison.csv`
   - Section: activity ownership and latest wave rows
   - Exact change required: add rows for unified read-only logbook, snorkeling GPS ownership, CCR ack remediation, equipment gas UI remediation
   - Why: matrix drift
   - Priority: P2
   - Audit to rerun: 03, 06

3. File: `Docs/MASTER_RELEASE_QA_EVIDENCE_COMPLIANCE_AUDIT_CURRENT.md`
   - Section: latest-wave cross-links
   - Exact change required: reference V1.7 CCR/equipment/demo contamination docs explicitly
   - Why: release-claim traceability
   - Priority: P2
   - Audit to rerun: 05, 06

4. File: `Docs/MASTER_MAIN_CODE_SYNC_SECURITY_PERFORMANCE_AUDIT_CURRENT.md`
   - Section: unified-logbook/gps policy
   - Exact change required: add direct links to no-contamination and location privacy matrices
   - Why: cross-layer integrity transparency
   - Priority: P2
   - Audit to rerun: 04, 06

## P3 — Copy / formatting / archive hygiene

1. File: `Docs/INDEX.md`
   - Section: duplicated historical update blocks
   - Exact change required: compact legacy blocks under one superseded section
   - Why: reduces confusion
   - Priority: P3
   - Audit to rerun: 06

2. File: `Docs/README.md`
   - Section: long historical table
   - Exact change required: split legacy timeline into appendix doc
   - Why: maintainability
   - Priority: P3
   - Audit to rerun: 06

3. File: `Docs/MASTER_OUTDATED_DOCUMENT_INVENTORY_CURRENT.csv`
   - Section: archive markers
   - Exact change required: add archive-keep rationale per historical command
   - Why: consistent superseded governance
   - Priority: P3
   - Audit to rerun: 06
