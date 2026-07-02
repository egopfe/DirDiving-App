# MASTER APNEA RELEASE WORDING REPAIR PLAN (V1.7)

## Required wording guardrails
- Keep: "Apnea is non-certified and software readiness does not close physical/external gates."
- Keep: "No decompression computer authority in Apnea mode."
- Keep: "No medical/recovery guarantee wording."
- Keep: "No underwater GPS/navigation authority wording."

## Concrete repairs
1. In release summaries, pair Apnea test-pass claims with `PHYSICAL_QA_PENDING`.
2. In index/readme summaries, avoid generic "ready" labels without scope qualifier.
3. Add one canonical sentence in Apnea release docs: "Apnea GPS metadata is surface-only and informational."

## Rerun audits after repair
- 02 (iOS), 03 (UI/UX), 05 (Release), 06 (Documentation)
