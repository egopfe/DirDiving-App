# Master Audit Rerun Plan — Current

**Orchestrator:** V1.1 @ `1f62235`  
**Policy:** Rerun upstream master audits after each remediation batch that touches their scope.

| Remediation batch | Audits to rerun | Rationale |
|-------------------|-----------------|-----------|
| **Batch 0** — Baseline | None (snapshot only) | Establish clean baseline |
| **Batch 1** — Watch FC safety | **01**, **03**, **04**, **05** | Algorithm/environment/deco UI/performance/release gates |
| **Batch 2** — Sync/persistence | **02**, **04**, **05**, **06** | Data integrity + docs |
| **Batch 3** — Activity architecture | **02**, **03**, **04**, **06** | Settings/logbook ownership + UI |
| **Batch 4** — iOS planner | **02**, **03**, **04**, **05** | Planner math + UI truthfulness |
| **Batch 5** — Performance | **01**, **02**, **03**, **04** | Stale async + charts/maps |
| **Batch 6** — UI/UX/a11y | **03**, **05**, **06** | Visual/accessibility/release copy |
| **Batch 7** — Security/privacy | **04**, **05**, **06** | Threat model + disclosures |
| **Batch 8** — QA/evidence | **01**, **02**, **04**, **05** | Physical/external evidence refresh |
| **Batch 9** — Release/docs | **05**, **06** | Legal + INDEX/feature matrix |

**Full Computer rule:** Any batch touching Watch FC runtime, altitude, CMAltimeter, tissue, or deco schedule must rerun **01** before external release claims.

**After physical QA campaigns:** Rerun **01**, **03**, **05** and update `MASTER_UNRESOLVED_PHYSICAL_EXTERNAL_QA_REGISTER_CURRENT.csv`.

**After external validation:** Rerun **01**, **02**, **05** and attach evidence under `Docs/QA_EVIDENCE/`.
