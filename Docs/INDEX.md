# DIR DIVING — Indice documentazione (`Docs/`)

**Aggiornato:** 2026-07-01  
**Branch consigliato:** `main` = `origin/main` @ `a79e1ff`

---

## Aggiornamento indice 2026-07-01 — Diving Import Center P1+P2

File-based Diving logbook Import Center: CSV preview/dedup, Subsurface XML, UDDF; selective import; 18 import tests PASS; Watch build OK.

| Campo | Valore |
|-------|--------|
| **Report** | [`DIVING_IMPORT_CENTER_IMPLEMENTATION_REPORT_CURRENT.md`](DIVING_IMPORT_CENTER_IMPLEMENTATION_REPORT_CURRENT.md) |
| **Audit** | [`DIVING_IMPORT_CENTER_AUDIT_CURRENT.md`](DIVING_IMPORT_CENTER_AUDIT_CURRENT.md) |
| **Plan** | [`DIVING_IMPORT_CENTER_P1_P2_IMPLEMENTATION_PLAN.md`](DIVING_IMPORT_CENTER_P1_P2_IMPLEMENTATION_PLAN.md) |
| **Policies** | CSV · [Subsurface XML](DIVING_IMPORT_CENTER_SUBSURFACE_XML_POLICY.md) · [UDDF](DIVING_IMPORT_CENTER_UDDF_POLICY.md) · [Dedup](DIVING_IMPORT_CENTER_DEDUPLICATION_POLICY.md) |
| **Verdict** | **DIVING_IMPORT_CENTER_P1_READY** · **DIVING_IMPORT_CENTER_P2_READY** · **CSV_IMPORT_REGRESSION_PROTECTED** · **MANUAL_UI_QA_PENDING** |

---

## Aggiornamento indice 2026-07-01 — iOS unified activity logbook view @ `d32ad96`

Per-activity toggle “Show all activities in logbook” (default OFF); presentation-only aggregated Diving + Snorkeling + Apnea timeline; no store merge; 22 new iOS tests PASS.

| Campo | Valore |
|-------|--------|
| **Report** | [`IOS_UNIFIED_ACTIVITY_LOGBOOK_IMPLEMENTATION_REPORT_CURRENT.md`](IOS_UNIFIED_ACTIVITY_LOGBOOK_IMPLEMENTATION_REPORT_CURRENT.md) |
| **Feature** | [`IOS_UNIFIED_ACTIVITY_LOGBOOK_VIEW.md`](IOS_UNIFIED_ACTIVITY_LOGBOOK_VIEW.md) |
| **Settings** | [`IOS_ACTIVITY_LOGBOOK_VISIBILITY_SETTINGS.md`](IOS_ACTIVITY_LOGBOOK_VISIBILITY_SETTINGS.md) |
| **Policy** | [`IOS_UNIFIED_LOGBOOK_NO_CONTAMINATION_POLICY.md`](IOS_UNIFIED_LOGBOOK_NO_CONTAMINATION_POLICY.md) |
| **Verdict** | **IOS_UNIFIED_ACTIVITY_LOGBOOK_VIEW_READY** · **PRESENTATION_ONLY_CONFIRMED** · **MANUAL_UI_QA_PENDING** |

---

## Aggiornamento indice 2026-07-01 — Audit 07 post-remediation @ `dfbceec`

Audit 07 V1.5 complete: software gates **100%**; iOS **1655/1655** + Watch **1152/1152** PASS; physical/external/legal **PENDING**.

| Campo | Valore |
|-------|--------|
| **Audit** | [`MASTER_POST_REMEDIATION_CODE_READINESS_AUDIT_CURRENT.md`](MASTER_POST_REMEDIATION_CODE_READINESS_AUDIT_CURRENT.md) |
| **Verdict** | [`MASTER_POST_REMEDIATION_FINAL_VERDICT_CURRENT.md`](MASTER_POST_REMEDIATION_FINAL_VERDICT_CURRENT.md) |
| **Algorithmic safety** | [`MASTER_POST_REMEDIATION_ALGORITHMIC_SAFETY_VERIFICATION_CURRENT.md`](MASTER_POST_REMEDIATION_ALGORITHMIC_SAFETY_VERIFICATION_CURRENT.md) |
| **Apnea verification** | [`MASTER_POST_REMEDIATION_APNEA_VERIFICATION_CURRENT.md`](MASTER_POST_REMEDIATION_APNEA_VERIFICATION_CURRENT.md) |
| **Status** | **AUDIT_07 PASS** · **INTERNAL_TF_SOFTWARE_READY** · **PHYSICAL_QA_PENDING** |

---

## Aggiornamento indice 2026-07-01 — R09 WAO routing test alignment 

CONS-050 / WFC-P2-005 closed: Watch **1152/1152** PASS; snorkeling progress fix; CONS-053/054 doc alignment.

| Campo | Valore |
|-------|--------|
| **Report** | [`R09_WAO_ROUTING_TEST_ALIGNMENT_REMEDIATION_REPORT_CURRENT.md`](R09_WAO_ROUTING_TEST_ALIGNMENT_REMEDIATION_REPORT_CURRENT.md) |
| **Verdict** | **CONS-050 FIXED** · **WATCH 1152/1152** · **PHYSICAL_QA_PENDING** |

---

## Aggiornamento indice 2026-07-01 — Orchestrator V1.5 full audit 01–06 @ `235b7d9`

Audits 01–06 + consolidation @ `2c30412`; PARTIAL verdict; internal TestFlight software READY; physical/external pending.

| Campo | Valore |
|-------|--------|
| **Plan** | [`MASTER_CONSOLIDATED_AUDIT_AND_NON_REGRESSIVE_REMEDIATION_PLAN_CURRENT.md`](MASTER_CONSOLIDATED_AUDIT_AND_NON_REGRESSIVE_REMEDIATION_PLAN_CURRENT.md) |
| **Findings** | [`MASTER_CONSOLIDATED_FINDINGS_REGISTER_CURRENT.csv`](MASTER_CONSOLIDATED_FINDINGS_REGISTER_CURRENT.csv) |
| **Verdict** | **PARTIAL** · **INTERNAL_TF_SOFTWARE_READY** · **CONS-050 FIXED** · **PHYSICAL_QA_PENDING** |

---

## Aggiornamento indice 2026-07-01 — Apnea P1/P2/P3 verification @ `ad1c836`

Apnea test gate verified: 21 iOS + 25 Watch algorithm tests PASS; P1/P2/P3 INTERNAL_READY.

| Campo | Valore |
|-------|--------|
| **Report** | [APNEA_IOS_WATCH_P1_P2_P3_IMPLEMENTATION_REPORT_CURRENT.md](APNEA_IOS_WATCH_P1_P2_P3_IMPLEMENTATION_REPORT_CURRENT.md) |
| **Verdict** | **APNEA_P1_P2_P3_INTERNAL_READY** · **46/46 APNEA TESTS PASS** · **PHYSICAL_QA_PENDING** |

---

## Aggiornamento indice 2026-06-17 — CONS-046 V1.5 integrity script @ `ad1c836`

## Aggiornamento indice 2026-06-17 — Apnea P1/P2/P3 @ `76f3703`

Apnea profiles, session check, recovery timer, training tables; INTERNAL_READY / PHYSICAL_QA_PENDING.

| Campo | Valore |
|-------|--------|
| **Report** | [APNEA_IOS_WATCH_P1_P2_P3_IMPLEMENTATION_REPORT_CURRENT.md](APNEA_IOS_WATCH_P1_P2_P3_IMPLEMENTATION_REPORT_CURRENT.md) |
| **Verdict** | **APNEA_P1_P2_P3_INTERNAL_READY** · **PHYSICAL_QA_PENDING** |


Post-merge V1.5 command upgrade: integrity script aligned to V1.5 paths; consolidated readiness PASS.

| Campo | Valore |
|-------|--------|
| **Report** | [`MASTER_CONSOLIDATED_SOFTWARE_REMEDIATION_FROM_2026_06_30_AUDIT_REPORT_CURRENT.md`](MASTER_CONSOLIDATED_SOFTWARE_REMEDIATION_FROM_2026_06_30_AUDIT_REPORT_CURRENT.md) |
| **Verdict** | [`MASTER_POST_REMEDIATION_FINAL_VERDICT_CURRENT.md`](MASTER_POST_REMEDIATION_FINAL_VERDICT_CURRENT.md) |
| **Verdict** | **SOFTWARE_READY 100%** · **INTERNAL_TF_READY** · **CONS-046 V1.5 PASS** |

---

## Aggiornamento indice 2026-06-17 — Command 11 software remediation @ `7a429a7`

IOS-P1-001 / CONS-049 and CONS-046 fixed; 1637 iOS tests PASS; internal TestFlight software **READY**; physical/external gates pending.

| Campo | Valore |
|-------|--------|
| **Report** | [`MASTER_CONSOLIDATED_SOFTWARE_REMEDIATION_FROM_2026_06_30_AUDIT_REPORT_CURRENT.md`](MASTER_CONSOLIDATED_SOFTWARE_REMEDIATION_FROM_2026_06_30_AUDIT_REPORT_CURRENT.md) |
| **Verdict** | [`MASTER_POST_REMEDIATION_FINAL_VERDICT_CURRENT.md`](MASTER_POST_REMEDIATION_FINAL_VERDICT_CURRENT.md) |
| **Verdict** | **SOFTWARE_READY 100%** · **INTERNAL_TF_READY** · **PHYSICAL_QA_PENDING** |

---

## Aggiornamento indice 2026-06-17 — Full audit sequence 01–06 + 07 @ `abfb574`

Orchestrator V1.3 comprehensive rerun @ `451f8fb`; all domain audits refreshed; CONS-047 closed; CONS-049 iOS test compile; PARTIAL verdict.

| Campo | Valore |
|-------|--------|
| **Plan** | [`MASTER_CONSOLIDATED_AUDIT_AND_NON_REGRESSIVE_REMEDIATION_PLAN_CURRENT.md`](MASTER_CONSOLIDATED_AUDIT_AND_NON_REGRESSIVE_REMEDIATION_PLAN_CURRENT.md) |
| **Verdict** | [`MASTER_POST_REMEDIATION_FINAL_VERDICT_CURRENT.md`](MASTER_POST_REMEDIATION_FINAL_VERDICT_CURRENT.md) |
| **Findings** | [`MASTER_CONSOLIDATED_FINDINGS_REGISTER_CURRENT.csv`](MASTER_CONSOLIDATED_FINDINGS_REGISTER_CURRENT.csv) |
| **Verdict** | **PARTIAL** · **IOS-P1-001** · **PHYSICAL_QA_PENDING** · **APP_STORE_NOT_READY** |

---

## Aggiornamento indice 2026-06-17 — Master audit orchestrator V1.3 + audit 07 @ `8f224da`

Orchestrator consolidation at `bb204f5`; post-remediation verification (build PASS); CONS-046 script drift, CONS-047 stale upstream audits, CONS-048 Snorkeling physical QA pending.

| Campo | Valore |
|-------|--------|
| **Plan** | [`MASTER_CONSOLIDATED_AUDIT_AND_NON_REGRESSIVE_REMEDIATION_PLAN_CURRENT.md`](MASTER_CONSOLIDATED_AUDIT_AND_NON_REGRESSIVE_REMEDIATION_PLAN_CURRENT.md) |
| **Verdict** | [`MASTER_POST_REMEDIATION_FINAL_VERDICT_CURRENT.md`](MASTER_POST_REMEDIATION_FINAL_VERDICT_CURRENT.md) |
| **Findings** | [`MASTER_CONSOLIDATED_FINDINGS_REGISTER_CURRENT.csv`](MASTER_CONSOLIDATED_FINDINGS_REGISTER_CURRENT.csv) |
| **Verdict** | **PARTIAL** · **PHYSICAL_QA_PENDING** · **APP_STORE_NOT_READY** |

---

## Aggiornamento indice 2026-06-17 — Snorkeling iOS + Watch P1/P2/P3 @ `dbe5d8b`

Route safety check, profile-based duration, route type, checklist, return alert policy, Watch runtime (GPS bands, route progress, off-route, 50% return alert), logbook runtime summary, export, tests, docs, QA templates.

| Campo | Valore |
|-------|--------|
| **Roadmap** | [`SNORKELING_IOS_WATCH_ROADMAP_P1_P2_P3.md`](SNORKELING_IOS_WATCH_ROADMAP_P1_P2_P3.md) |
| **Architecture** | [`SNORKELING_IOS_WATCH_ARCHITECTURE.md`](SNORKELING_IOS_WATCH_ARCHITECTURE.md) |
| **Route safety** | [`SNORKELING_ROUTE_SAFETY_CHECK.md`](SNORKELING_ROUTE_SAFETY_CHECK.md) |
| **Watch return** | [`SNORKELING_WATCH_RETURN_TO_ENTRY.md`](SNORKELING_WATCH_RETURN_TO_ENTRY.md) |
| **GPS policy** | [`SNORKELING_GPS_QUALITY_POLICY.md`](SNORKELING_GPS_QUALITY_POLICY.md) |
| **Report** | [`SNORKELING_IOS_WATCH_P1_P2_P3_IMPLEMENTATION_REPORT_CURRENT.md`](SNORKELING_IOS_WATCH_P1_P2_P3_IMPLEMENTATION_REPORT_CURRENT.md) |
| **QA** | `Docs/QA_EVIDENCE/SNORKELING_IOS_ROUTE_*` · `SNORKELING_WATCH_*` · `SNORKELING_LOGBOOK_GPS_QUALITY` |
| **Verdict** | **INTERNAL_READY** · **PHYSICAL_QA_PENDING** |

---

## Aggiornamento indice 2026-06-17 — iOS Snorkeling map UX improvements @ `7a88e9c`

Center-on-location button, reset map with confirmation, section reorder (Map → Route points → Profiles) in iOS Route Planner.

| Campo | Valore |
|-------|--------|
| **Spec** | [`IOS_SNORKELING_MAP_UX_IMPROVEMENTS.md`](IOS_SNORKELING_MAP_UX_IMPROVEMENTS.md) |
| **Report** | [`IOS_SNORKELING_MAP_UX_IMPROVEMENTS_IMPLEMENTATION_REPORT_CURRENT.md`](IOS_SNORKELING_MAP_UX_IMPROVEMENTS_IMPLEMENTATION_REPORT_CURRENT.md) |
| **QA** | SNK-QA-MAP-001…005 · `Docs/QA_EVIDENCE/IOS_SNORKELING_MAP_*` |
| **Verdict** | **INTERNAL_READY** · **PHYSICAL_QA_PENDING** |

---

## Aggiornamento indice 2026-06-17 — iOS Apnea & Snorkeling fake logbook @ `b230672`

iOS-only demo logbook toggles for Apnea and Snorkeling (default OFF); separate in-memory providers; no real storage, Watch sync, or export contamination.

| Campo | Valore |
|-------|--------|
| **Spec** | [`IOS_APNEA_SNORKELING_FAKE_LOGBOOK.md`](IOS_APNEA_SNORKELING_FAKE_LOGBOOK.md) |
| **Report** | [`IOS_APNEA_SNORKELING_FAKE_LOGBOOK_IMPLEMENTATION_REPORT_CURRENT.md`](IOS_APNEA_SNORKELING_FAKE_LOGBOOK_IMPLEMENTATION_REPORT_CURRENT.md) |
| **QA** | IOS-QA-AFL-001…004 · `Docs/QA_EVIDENCE/IOS_*_FAKE_LOGBOOK_*` |
| **Verdict** | **INTERNAL_READY** · **PHYSICAL_QA_PENDING** |

---

## Aggiornamento indice 2026-06-29 — Diving Planner emergency buddy deco gas @ `79854fa`

Emergency-section toggle for per-deco-gas adequacy with optional 2× buddy multiplier; no Bühlmann/deco schedule or runtime changes.

| Campo | Valore |
|-------|--------|
| **Spec** | [`DIVE_PLANNER_EMERGENCY_BUDDY_DECO_GAS.md`](DIVE_PLANNER_EMERGENCY_BUDDY_DECO_GAS.md) |
| **Report** | [`DIVE_PLANNER_EMERGENCY_BUDDY_DECO_GAS_IMPLEMENTATION_REPORT_CURRENT.md`](DIVE_PLANNER_EMERGENCY_BUDDY_DECO_GAS_IMPLEMENTATION_REPORT_CURRENT.md) |
| **QA** | DPL-QA-EBDG-001…004 · `Docs/QA_EVIDENCE/DIVE_PLANNER_EMERGENCY_BUDDY_DECO_GAS_*` |
| **Verdict** | **INTERNAL_READY** · **PHYSICAL_QA_PENDING** |

---

## Aggiornamento indice 2026-06-29 — Snorkeling Map Type settings @ `88f9009`

Snorkeling-only Satellite / Explore map type preference (default Satellite); iOS Route Planner, Session Detail, Dashboard preview; Watch settings parity (stored, no interactive Watch map yet).

| Campo | Valore |
|-------|--------|
| **Spec** | [`SNORKELING_MAP_TYPE_SETTINGS.md`](SNORKELING_MAP_TYPE_SETTINGS.md) |
| **Report** | [`SNORKELING_MAP_TYPE_SETTINGS_IMPLEMENTATION_REPORT_CURRENT.md`](SNORKELING_MAP_TYPE_SETTINGS_IMPLEMENTATION_REPORT_CURRENT.md) |
| **QA** | SNK-QA-022…025 · `Docs/QA_EVIDENCE/SNORKELING_MAP_TYPE_*` |
| **Validate** | `./Scripts/validate_snorkeling_release_readiness.sh` **PASS** (internal) |
| **Verdict** | **INTERNAL_READY** · **PHYSICAL_QA_PENDING** |

---

## Aggiornamento indice 2026-06-29 — Orchestrator V1.2 refresh @ `4d415c0`

All six upstream audits (01–06) refreshed post-remediation. **UPSTREAM_AUDITS_COMPLETE: PASS.** Audit 03 no longer stale.

| Campo | Valore |
|-------|--------|
| **Command** | `00-MASTER_SUPER_ORCHESTRATOR_...V1.2.md` |
| **Plan** | [`MASTER_CONSOLIDATED_AUDIT_AND_NON_REGRESSIVE_REMEDIATION_PLAN_CURRENT.md`](MASTER_CONSOLIDATED_AUDIT_AND_NON_REGRESSIVE_REMEDIATION_PLAN_CURRENT.md) |
| **Checklist** | [`MASTER_CONSOLIDATED_POST_REMEDIATION_AUDIT_RERUN_CHECKLIST_CURRENT.md`](MASTER_CONSOLIDATED_POST_REMEDIATION_AUDIT_RERUN_CHECKLIST_CURRENT.md) |
| **Verdict** | **PARTIAL** · software **100%** · P0=0 · P1 software=0 · overall **~72%** |
| **Next** | Physical/external QA · README/matrix doc-only · legal packaging |

---

## Aggiornamento indice 2026-06-29 — UI/UX audit rerun (Command 03) @ post-remediation

Post-remediation read-only rerun after Command 10 @ `5d757cc`. CONS-019 WAO depth gate **FIXED_SOFTWARE**; GF/shallow dev surfaces verified; physical/pixel/a11y remain **PENDING**.

| Campo | Valore |
|-------|--------|
| **Command** | `03-MASTER_UI_UX_FULL_DEEP_COMPREHENSIVE_AUDIT_COMMAND_V2.2.md` |
| **Report** | [`MASTER_UI_UX_FULL_DEEP_COMPREHENSIVE_AUDIT_CURRENT.md`](MASTER_UI_UX_FULL_DEEP_COMPREHENSIVE_AUDIT_CURRENT.md) |
| **WAO audit** | [`MASTER_WATCH_WATER_AUTO_OPEN_AUDIT_CURRENT.md`](MASTER_WATCH_WATER_AUTO_OPEN_AUDIT_CURRENT.md) |
| **Underwater HW** | [`MASTER_WATCH_UNDERWATER_HARDWARE_INTERACTION_AUDIT_CURRENT.md`](MASTER_WATCH_UNDERWATER_HARDWARE_INTERACTION_AUDIT_CURRENT.md) |
| **Validate** | `audit_accessibility_contracts.sh` **PASS** · pixel baselines **0/59 PENDING** |
| **Verdict** | **PARTIAL** — P0=0 · software UI/UX **PASS** · physical/pixel **PENDING** |

---

## Aggiornamento indice 2026-06-28 — Orchestrator V1.2 refresh @ `8ae1034`

Command **00** consolidation refresh after Command 10 remediation @ `5d757cc` and post-remediation reruns **01–06** @ `4d415c0`.

| Campo | Valore |
|-------|--------|
| **Command** | `00-MASTER_SUPER_ORCHESTRATOR_FULL_AUDIT_SEQUENCE_AND_NON_REGRESSIVE_REMEDIATION_PLAN_COMMAND_V1.2.md` |
| **Plan** | [`MASTER_CONSOLIDATED_AUDIT_AND_NON_REGRESSIVE_REMEDIATION_PLAN_CURRENT.md`](MASTER_CONSOLIDATED_AUDIT_AND_NON_REGRESSIVE_REMEDIATION_PLAN_CURRENT.md) |
| **Findings register** | [`MASTER_CONSOLIDATED_FINDINGS_REGISTER_CURRENT.csv`](MASTER_CONSOLIDATED_FINDINGS_REGISTER_CURRENT.csv) (45 rows CONS-001..045) |
| **Checklist** | [`MASTER_CONSOLIDATED_POST_REMEDIATION_AUDIT_RERUN_CHECKLIST_CURRENT.md`](MASTER_CONSOLIDATED_POST_REMEDIATION_AUDIT_RERUN_CHECKLIST_CURRENT.md) |
| **Validate** | `./Scripts/validate_consolidated_software_readiness.sh` **PASS** |
| **Verdict** | **PARTIAL** · P0=0 · P1 software open=0 · software **100%** · physical/external/legal **PENDING** · overall **~72%** |
| **Audit baseline** | `8ae1034` (remediation `5d757cc`) |

Deliverables: deduplication matrix, dependency graph, priority matrix, non-regression gates, remediation sequence, audit rerun plan, release blocker burndown, 7/14/30 roadmap, physical/external QA register, do-not-touch policies.

---

## Aggiornamento indice 2026-06-28 — Post-remediation audit reruns 01 / 02 / 04 / 05 / 06 @ `5d757cc`

Read-only reruns after consolidated software remediation. Checklist: [`MASTER_CONSOLIDATED_POST_REMEDIATION_AUDIT_RERUN_CHECKLIST_CURRENT.md`](MASTER_CONSOLIDATED_POST_REMEDIATION_AUDIT_RERUN_CHECKLIST_CURRENT.md).

| # | Report | Verdict |
|---|--------|---------|
| 01 | [`MASTER_WATCH_FULL_COMPUTER_FORENSIC_AUDIT_CURRENT.md`](MASTER_WATCH_FULL_COMPUTER_FORENSIC_AUDIT_CURRENT.md) | **PARTIAL** — software strong; P0=0; physical/external pending |
| 02 | [`MASTER_IOS_FULL_DEEP_COMPREHENSIVE_AUDIT_CURRENT.md`](MASTER_IOS_FULL_DEEP_COMPREHENSIVE_AUDIT_CURRENT.md) | **PASS** (software) — GF parity verified |
| 03 | [`MASTER_UI_UX_FULL_DEEP_COMPREHENSIVE_AUDIT_CURRENT.md`](MASTER_UI_UX_FULL_DEEP_COMPREHENSIVE_AUDIT_CURRENT.md) | **PARTIAL** @ `15c8068` — software PASS; physical/pixel pending |
| 04 | [`MASTER_MAIN_CODE_SYNC_SECURITY_PERFORMANCE_AUDIT_CURRENT.md`](MASTER_MAIN_CODE_SYNC_SECURITY_PERFORMANCE_AUDIT_CURRENT.md) | **PARTIAL** — CONS-003–007 closed; P1=0 |
| 05 | [`MASTER_RELEASE_QA_EVIDENCE_COMPLIANCE_AUDIT_CURRENT.md`](MASTER_RELEASE_QA_EVIDENCE_COMPLIANCE_AUDIT_CURRENT.md) | Software **100%**; physical/legal **PENDING** |
| 06 | [`MASTER_DOCUMENTATION_REPOSITORY_ALIGNMENT_AUDIT_CURRENT.md`](MASTER_DOCUMENTATION_REPOSITORY_ALIGNMENT_AUDIT_CURRENT.md) | **PARTIAL** — command integrity PASS; README drift P2 |

---

## Aggiornamento indice 2026-06-28 — Command 04 post-remediation audit rerun

Post-remediation read-only rerun @ `5d757cc`: **CONS-003–007 VERIFIED** — sync in-flight release, symmetric `diveImportAck`, signed tombstones, shallow dev toggles default OFF, `runtimeAuthorityTier` compile authority. Gate scripts PASS.

| Campo | Valore |
|-------|--------|
| **Command** | `04-MASTER_MAIN_CODE_SYNC_SECURITY_PERFORMANCE_AUDIT_COMMAND_V1.1.md` |
| **Report** | [`MASTER_MAIN_CODE_SYNC_SECURITY_PERFORMANCE_AUDIT_CURRENT.md`](MASTER_MAIN_CODE_SYNC_SECURITY_PERFORMANCE_AUDIT_CURRENT.md) |
| **Validate** | `./Scripts/validate_master_main_code_sync_security_performance_audit.sh` |
| **Verdict** | **PARTIAL** — P1 software closed; P2 physical/WAO/planner open |
| **Audit baseline** | `5d757cc` |

---

## Aggiornamento indice 2026-06-28 — Master Consolidated Software Remediation to 100% V1.0 (Command 10)

Remediation software post-orchestrator V1.2: permutazione `commands_for_cursor/01`–`04` riparata, parità GF iOS↔Watch, sync Watch (inFlight/ACK/tombstones), authority depth shallow, gate dev toggles, test hardening.

| Campo | Valore |
|-------|--------|
| **Command** | `10-MASTER_CONSOLIDATED_SOFTWARE_REMEDIATION_TO_100_CODE_READINESS_COMMAND_V1.0.md` |
| **Report** | [`MASTER_CONSOLIDATED_SOFTWARE_REMEDIATION_TO_100_REPORT_CURRENT.md`](MASTER_CONSOLIDATED_SOFTWARE_REMEDIATION_TO_100_REPORT_CURRENT.md) |
| **Finding status** | [`MASTER_CONSOLIDATED_SOFTWARE_REMEDIATION_FINDING_STATUS_CURRENT.csv`](MASTER_CONSOLIDATED_SOFTWARE_REMEDIATION_FINDING_STATUS_CURRENT.csv) |
| **Test evidence** | [`MASTER_CONSOLIDATED_SOFTWARE_REMEDIATION_TEST_EVIDENCE_CURRENT.md`](MASTER_CONSOLIDATED_SOFTWARE_REMEDIATION_TEST_EVIDENCE_CURRENT.md) |
| **Completion summary** | [`MASTER_CONSOLIDATED_SOFTWARE_READINESS_TO_100_COMPLETION_SUMMARY_CURRENT.md`](MASTER_CONSOLIDATED_SOFTWARE_READINESS_TO_100_COMPLETION_SUMMARY_CURRENT.md) |
| **Validate** | `./Scripts/validate_consolidated_software_readiness.sh` |
| **Verdict** | **SOFTWARE 100%** · internal TestFlight software **100%** · physical/external/legal **PENDING** |
| **Audit baseline** | `5d757cc` · consolidated software remediation committed on `main` |

---

## Aggiornamento indice 2026-06-28 — Documentation / Repository Alignment Audit V1.1 (Command 06 post-remediation)

Post-remediation read-only rerun @ `5d757cc`: **CONS-001** command integrity **PASS** (`validate_commands_for_cursor_integrity.sh`); **CONS-034** INDEX wave **PARTIAL** (Command 10 section present; README baseline + feature matrix drift remain).

| Campo | Valore |
|-------|--------|
| **Command** | `06-MASTER_DOCUMENTATION_REPOSITORY_ALIGNMENT_AUDIT_COMMAND_V1.1.md` |
| **Report** | [`MASTER_DOCUMENTATION_REPOSITORY_ALIGNMENT_AUDIT_CURRENT.md`](MASTER_DOCUMENTATION_REPOSITORY_ALIGNMENT_AUDIT_CURRENT.md) |
| **Truthfulness matrix** | [`MASTER_DOCUMENTATION_TRUTHFULNESS_MATRIX_CURRENT.csv`](MASTER_DOCUMENTATION_TRUTHFULNESS_MATRIX_CURRENT.csv) |
| **Outdated inventory** | [`MASTER_OUTDATED_DOCUMENT_INVENTORY_CURRENT.csv`](MASTER_OUTDATED_DOCUMENT_INVENTORY_CURRENT.csv) |
| **Command alignment** | [`MASTER_COMMAND_VERSION_ALIGNMENT_MATRIX_CURRENT.csv`](MASTER_COMMAND_VERSION_ALIGNMENT_MATRIX_CURRENT.csv) · [`MASTER_COMMAND_SEQUENCE_VERSION_ALIGNMENT_CURRENT.csv`](MASTER_COMMAND_SEQUENCE_VERSION_ALIGNMENT_CURRENT.csv) |
| **Remediation plan** | [`MASTER_DOCUMENTATION_REMEDIATION_PLAN_CURRENT.md`](MASTER_DOCUMENTATION_REMEDIATION_PLAN_CURRENT.md) |
| **Index repair plan** | [`MASTER_DOCS_INDEX_REPAIR_PLAN_CURRENT.md`](MASTER_DOCS_INDEX_REPAIR_PLAN_CURRENT.md) |
| **Feature matrix repair** | [`MASTER_FEATURE_MATRIX_REPAIR_PLAN_CURRENT.md`](MASTER_FEATURE_MATRIX_REPAIR_PLAN_CURRENT.md) |
| **Watch wave alignment** | [`MASTER_LATEST_WATCH_DEVELOPMENT_DOC_ALIGNMENT_CURRENT.csv`](MASTER_LATEST_WATCH_DEVELOPMENT_DOC_ALIGNMENT_CURRENT.csv) |
| **Entitlement alignment** | [`MASTER_ENTITLEMENT_DOCUMENTATION_ALIGNMENT_CURRENT.csv`](MASTER_ENTITLEMENT_DOCUMENTATION_ALIGNMENT_CURRENT.csv) |
| **Launch sequence** | [`commands_for_cursor/00-DIR_DIVING_MASTER_AUDIT_LAUNCH_SEQUENCE_UPDATED_2026-06-28.md`](../commands_for_cursor/00-DIR_DIVING_MASTER_AUDIT_LAUNCH_SEQUENCE_UPDATED_2026-06-28.md) |
| **Validate** | `./Scripts/validate_commands_for_cursor_integrity.sh` **PASS** |
| **Verdict** | **PARTIAL** — command integrity PASS; README baseline FAIL; feature matrix PARTIAL; 2× P0 claim docs remain |
| **Audit baseline** | `5d757cc` |

---

## Guida utente Watch — Corona e pulsanti

| Documento | Descrizione |
|-----------|-------------|
| [`WATCH_CROWN_AND_BUTTONS_USER_GUIDE.md`](WATCH_CROWN_AND_BUTTONS_USER_GUIDE.md) | **Guida utente** — Corona (navigazione), Action Button Ultra, Water Lock, ingresso acqua · EN + IT |

Policy tecniche correlate: [`WATCH_UNDERWATER_FAST_CONTROLS.md`](WATCH_UNDERWATER_FAST_CONTROLS.md) · [`WATCH_WATER_AUTO_OPEN_POLICY.md`](WATCH_WATER_AUTO_OPEN_POLICY.md)

---

## Aggiornamento indice 2026-06-23 — Master Software Remediation to 100% V1.0

Implementazione remediation software post-orchestrator: oracle TTS indipendente, IntegratedModes test gate, persistenza navigazione iOS, doc P0, test performance.

| Campo | Valore |
|-------|--------|
| **Command** | [`0000MASTER_SOFTWARE_REMEDIATION_TO_100_READINESS_COMMAND_V1.0.md`](0000MASTER_SOFTWARE_REMEDIATION_TO_100_READINESS_COMMAND_V1.0.md) |
| **Report** | [`MASTER_SOFTWARE_REMEDIATION_TO_100_REPORT_CURRENT.md`](MASTER_SOFTWARE_REMEDIATION_TO_100_REPORT_CURRENT.md) |
| **Finding status** | [`MASTER_SOFTWARE_REMEDIATION_FINDING_STATUS_CURRENT.csv`](MASTER_SOFTWARE_REMEDIATION_FINDING_STATUS_CURRENT.csv) |
| **Test evidence** | [`MASTER_SOFTWARE_REMEDIATION_TEST_EVIDENCE_CURRENT.md`](MASTER_SOFTWARE_REMEDIATION_TEST_EVIDENCE_CURRENT.md) |
| **Validate** | `./Scripts/validate_master_software_remediation_readiness.sh` |
| **Verdict** | **SOFTWARE 100%** · internal TestFlight software **100%** · physical/external **PENDING** |
| **Baseline** | `main` @ `ed5d599` |

---

## Aggiornamento indice 2026-06-22 — Master Super Orchestrator Audit V1.1 (Commands 00–06)

Orchestrazione audit read-only su `main` @ `1f62235`: sei audit upstream (Watch, iOS, UI/UX, Main code/sync/security/performance, Release QA, Documentation) + piano consolidato non-regressivo.

| Campo | Valore |
|-------|--------|
| **Command** | `commands_for_cursor/00-MASTER_SUPER_ORCHESTRATOR...V1.1.md` |
| **Consolidated plan** | [`MASTER_CONSOLIDATED_AUDIT_AND_NON_REGRESSIVE_REMEDIATION_PLAN_CURRENT.md`](MASTER_CONSOLIDATED_AUDIT_AND_NON_REGRESSIVE_REMEDIATION_PLAN_CURRENT.md) |
| **Findings register** | [`MASTER_CONSOLIDATED_FINDINGS_REGISTER_CURRENT.csv`](MASTER_CONSOLIDATED_FINDINGS_REGISTER_CURRENT.csv) — **P0=0, P1=6, P2=6** |
| **01 Watch FC** | [`MASTER_WATCH_FULL_COMPUTER_FORENSIC_AUDIT_CURRENT.md`](MASTER_WATCH_FULL_COMPUTER_FORENSIC_AUDIT_CURRENT.md) |
| **02 iOS** | [`MASTER_IOS_FULL_DEEP_COMPREHENSIVE_AUDIT_CURRENT.md`](MASTER_IOS_FULL_DEEP_COMPREHENSIVE_AUDIT_CURRENT.md) |
| **03 UI/UX** | [`MASTER_UI_UX_FULL_DEEP_COMPREHENSIVE_AUDIT_CURRENT.md`](MASTER_UI_UX_FULL_DEEP_COMPREHENSIVE_AUDIT_CURRENT.md) |
| **04 Main/sync/security/perf** | [`MASTER_MAIN_CODE_SYNC_SECURITY_PERFORMANCE_AUDIT_CURRENT.md`](MASTER_MAIN_CODE_SYNC_SECURITY_PERFORMANCE_AUDIT_CURRENT.md) |
| **05 Release/QA/legal** | [`MASTER_RELEASE_QA_EVIDENCE_COMPLIANCE_AUDIT_CURRENT.md`](MASTER_RELEASE_QA_EVIDENCE_COMPLIANCE_AUDIT_CURRENT.md) |
| **06 Documentation** | [`MASTER_DOCUMENTATION_REPOSITORY_ALIGNMENT_AUDIT_CURRENT.md`](MASTER_DOCUMENTATION_REPOSITORY_ALIGNMENT_AUDIT_CURRENT.md) |
| **Validate (04)** | `./Scripts/validate_master_main_code_sync_security_performance_audit.sh` |
| **XCTest (05 re-run)** | iOS **1519/1519** · Watch **990/990** · 0 failures (7 IntegratedModes tests excluded — simulator stall) |
| **Verdict** | **PARTIAL** — consolidated **72%** · internal TestFlight **READY** (software) · external/App Store **NOT READY** |
| **Baseline** | `main` @ `6511de9` |

---

## Aggiornamento indice 2026-06-22 — iOS Performance Remediation V1.0

Remediation software-verificabile di tutti i finding audit performance iOS (P0–P3). Readiness software 100%; physical QA pending.

| Campo | Valore |
|-------|--------|
| **Remediation report** | [`IOS_PERFORMANCE_REMEDIATION_REPORT_CURRENT.md`](IOS_PERFORMANCE_REMEDIATION_REPORT_CURRENT.md) |
| **Audit (updated)** | [`IOS_PERFORMANCE_OPTIMIZATION_AUDIT_CURRENT.md`](IOS_PERFORMANCE_OPTIMIZATION_AUDIT_CURRENT.md) |
| **Findings** | [`IOS_PERFORMANCE_FINDING_TRACEABILITY_CURRENT.csv`](IOS_PERFORMANCE_FINDING_TRACEABILITY_CURRENT.csv) — **SOFTWARE_OPEN=0** |
| **Validate** | `./Scripts/validate_ios_performance_readiness.sh` PASS |
| **XCTest** | iOS 1519/1519 · Watch 992/992 · 0 skipped |
| **Verdict** | **PASS** — software 100% · physical Instruments **PENDING** |
| **Baseline** | `main` @ `3f6f349` |

---

## Aggiornamento indice 2026-06-22 — iOS Performance Optimization Audit V1.0

Audit read-only performance iOS Companion: startup, SwiftUI, planner, charts, logbook, export/import, sync, map, observability. Nessuna remediation production.

| Campo | Valore |
|-------|--------|
| **Command** | `IOS_PERFORMANCE_OPTIMIZATION_AUDIT_COMMAND_V1.0.md` |
| **Main report** | [`IOS_PERFORMANCE_OPTIMIZATION_AUDIT_CURRENT.md`](IOS_PERFORMANCE_OPTIMIZATION_AUDIT_CURRENT.md) |
| **Findings** | [`IOS_PERFORMANCE_FINDING_TRACEABILITY_CURRENT.csv`](IOS_PERFORMANCE_FINDING_TRACEABILITY_CURRENT.csv) — **P0=4, P1=11, P2=7, P3=6** |
| **Budget matrix** | [`IOS_PERFORMANCE_BUDGET_MATRIX_CURRENT.csv`](IOS_PERFORMANCE_BUDGET_MATRIX_CURRENT.csv) |
| **Test matrix** | [`IOS_PERFORMANCE_REQUIREMENT_TEST_MATRIX_CURRENT.csv`](IOS_PERFORMANCE_REQUIREMENT_TEST_MATRIX_CURRENT.csv) |
| **Scalability inventory** | [`IOS_PERFORMANCE_SCALABILITY_MATRIX_CURRENT.csv`](IOS_PERFORMANCE_SCALABILITY_MATRIX_CURRENT.csv) |
| **Profiling plan** | [`IOS_PERFORMANCE_PROFILING_PLAN_CURRENT.md`](IOS_PERFORMANCE_PROFILING_PLAN_CURRENT.md) |
| **Signpost catalog** | [`IOS_PERFORMANCE_SIGNPOST_CATALOG_CURRENT.md`](IOS_PERFORMANCE_SIGNPOST_CATALOG_CURRENT.md) |
| **External QA** | [`IOS_PERFORMANCE_EXTERNAL_QA_PENDING_CURRENT.md`](IOS_PERFORMANCE_EXTERNAL_QA_PENDING_CURRENT.md) |
| **Validate** | `./Scripts/validate_ios_performance_audit_readiness.sh` PASS |
| **XCTest (gate subset)** | iOS 53/53 · 0 skipped |
| **Verdict** | **PARTIAL** — overall 58% · physical Instruments **PENDING** |
| **Baseline** | `main` @ `6bc4111` |

---

## Aggiornamento indice 2026-06-22 — iOS embeddable activity settings content fix

Apnea/Snorkeling Settings resi visibili sotto mode switcher: sostituito Form annidato in ScrollView con `IOSApneaSettingsContent` / `IOSSnorkelingSettingsContent` (DIRCard + row components).

| Campo | Valore |
|-------|--------|
| **Tests** | `IOSActivitySettingsContentVisibilityTests` |
| **Components** | `IOSCompanionSettingsRows`, `IOSCompanionSharedSettingsEmbeddedContent` |
| **Validate** | `./Scripts/validate_activity_settings_navigation_readiness.sh` PASS |
| **XCTest** | iOS 1510/1510 · Watch 992/992 · 0 skipped |
| **Baseline** | `main` @ `2f1d702` |

---

## Aggiornamento indice 2026-06-22 — Activity settings navigation remediation

Settings activity-scoped per iOS Companion e Apple Watch (Diving / Apnea / Snorkeling): mode switcher UI-only, gear routing, sezioni Watch, ownership tests.

| Campo | Valore |
|-------|--------|
| **Remediation** | [`ACTIVITY_SETTINGS_NAVIGATION_REMEDIATION_REPORT_CURRENT.md`](ACTIVITY_SETTINGS_NAVIGATION_REMEDIATION_REPORT_CURRENT.md) |
| **iOS mode switch** | [`IOS_COMPANION_SETTINGS_MODE_SWITCH_CURRENT.md`](IOS_COMPANION_SETTINGS_MODE_SWITCH_CURRENT.md) |
| **Watch access** | [`WATCH_ACTIVITY_SETTINGS_ACCESS_CURRENT.md`](WATCH_ACTIVITY_SETTINGS_ACCESS_CURRENT.md) |
| **Ownership matrix** | [`ACTIVITY_SETTINGS_OWNERSHIP_MATRIX_CURRENT.csv`](ACTIVITY_SETTINGS_OWNERSHIP_MATRIX_CURRENT.csv) |
| **Test matrix** | [`ACTIVITY_SETTINGS_REQUIREMENT_TEST_MATRIX_CURRENT.csv`](ACTIVITY_SETTINGS_REQUIREMENT_TEST_MATRIX_CURRENT.csv) |
| **Validate** | `./Scripts/validate_activity_settings_navigation_readiness.sh` PASS |
| **Baseline** | `main` @ `a909686` |
| **XCTest** | iOS 1501/1501 · Watch 992/992 · 0 skipped |

---

## Aggiornamento indice 2026-06-17 — Command 18 Watch CMAltimeter / Full Computer interaction audit

Audit read-only su catena `CMAltimeter` → proposta sensore → ambiente Full Computer @ `8ab4776`+.

| Campo | Valore |
|-------|--------|
| **Command** | `18-DIR_DIVING_WATCH_CMALTIMETER_FULL_COMPUTER_INTERACTION_AUDIT_COMMAND_V1.0.md` |
| **Main report** | [`WATCH_CMALTIMETER_FULL_COMPUTER_INTERACTION_AUDIT_CURRENT.md`](WATCH_CMALTIMETER_FULL_COMPUTER_INTERACTION_AUDIT_CURRENT.md) |
| **Traceability** | [`WATCH_CMALTIMETER_REQUIREMENT_TRACEABILITY_CURRENT.csv`](WATCH_CMALTIMETER_REQUIREMENT_TRACEABILITY_CURRENT.csv) |
| **Failure matrix** | [`WATCH_CMALTIMETER_FAILURE_INJECTION_MATRIX_CURRENT.csv`](WATCH_CMALTIMETER_FAILURE_INJECTION_MATRIX_CURRENT.csv) |
| **Physical QA matrix** | [`WATCH_CMALTIMETER_PHYSICAL_QA_MATRIX_CURRENT.csv`](WATCH_CMALTIMETER_PHYSICAL_QA_MATRIX_CURRENT.csv) |
| **Verdict** | **PARTIAL** — software 78% · physical 0% · blockers WCMA-001, WCMA-002, PENDING_PHYSICAL |
| **Remediation** | [`WATCH_CMALTIMETER_FULL_COMPUTER_REMEDIATION_REPORT_CURRENT.md`](WATCH_CMALTIMETER_FULL_COMPUTER_REMEDIATION_REPORT_CURRENT.md) — software 100% @ post-`27d9097` |
| **Watch tests** | 965/965 PASS (macOS simulator) |

---

## Aggiornamento indice 2026-06-21 — Orchestrated audit V1.1 (orchestrator) · Command 17 remediation pending

Audit read-only orchestrato su 19 comandi audit V3/V1.0 @ `6cbba649`; output consolidato in `Docs/*ORCHESTRATED*`. Nessuna modifica production; remediation successiva via Command 17.

| Campo | Valore |
|-------|--------|
| **Orchestrator** | `DIR_DIVING_CODEX_ORCHESTRATOR_AUDIT_COMMAND_V1.1` |
| **Next command** | `17-DIR_DIVING_ORCHESTRATED_AUDIT_FULL_REMEDIATION_COMMAND_V1.0.md` |
| **Consolidated report** | [`ORCHESTRATED_AUDIT_CONSOLIDATED_REPORT_CURRENT.md`](ORCHESTRATED_AUDIT_CONSOLIDATED_REPORT_CURRENT.md) |
| **Issue register** | [`ORCHESTRATED_AUDIT_ISSUE_REGISTER_CURRENT.csv`](ORCHESTRATED_AUDIT_ISSUE_REGISTER_CURRENT.csv) — ORCH-001…015 (**P0=1, P1=7, P2=7**) |
| **Remediation roadmap** | [`ORCHESTRATED_AUDIT_REMEDIATION_ROADMAP_CURRENT.md`](ORCHESTRATED_AUDIT_REMEDIATION_ROADMAP_CURRENT.md) |
| **Non-regression plan** | [`ORCHESTRATED_AUDIT_NON_REGRESSION_PLAN_CURRENT.md`](ORCHESTRATED_AUDIT_NON_REGRESSION_PLAN_CURRENT.md) |
| **Release readiness matrix** | [`ORCHESTRATED_AUDIT_RELEASE_READINESS_MATRIX_CURRENT.csv`](ORCHESTRATED_AUDIT_RELEASE_READINESS_MATRIX_CURRENT.csv) |
| **Run log** | [`ORCHESTRATED_AUDIT_RUN_LOG_CURRENT.md`](ORCHESTRATED_AUDIT_RUN_LOG_CURRENT.md) |
| **Command inventory** | [`ORCHESTRATED_AUDIT_COMMAND_INVENTORY_CURRENT.csv`](ORCHESTRATED_AUDIT_COMMAND_INVENTORY_CURRENT.csv) |
| **Audit baseline** | `main` @ `6cbba649` (19 executed, 7 superseded skipped) |
| **P0 root cause** | Watch Full Computer drops imported altitude/salinity → silent sea-level default (ORCH-001) |
| **Verdict** | **NO-GO** internal code/tests · TestFlight/App Store **NO-GO** · physical/external **PENDING** |
| **Supporting (Command 17)** | [`WATCH_BUHLMANN_ALTITUDE_SCHREINER_AUDIT_CURRENT.md`](WATCH_BUHLMANN_ALTITUDE_SCHREINER_AUDIT_CURRENT.md), [`COMPLETE_UI_UX_IMPLEMENTATION_COHERENCE_AUDIT_CURRENT.md`](COMPLETE_UI_UX_IMPLEMENTATION_COHERENCE_AUDIT_CURRENT.md) + related matrices |

---

## Aggiornamento indice 2026-06-17 — Command 9 security/privacy/trust audit V3.0

Audit read-only sicurezza/privacy/trust verticale su prodotto MAIN completo (Watch + iOS).

| Campo | Valore |
|-------|--------|
| **Command** | `9-DIR_DIVING_SECURITY_PRIVACY_TRUST_AUDIT_V3.0.md` |
| **Audit** | [`SECURITY_PRIVACY_TRUST_AUDIT_CURRENT.md`](SECURITY_PRIVACY_TRUST_AUDIT_CURRENT.md) |
| **Threat model** | [`THREAT_MODEL_CURRENT.md`](THREAT_MODEL_CURRENT.md) |
| **Data flow matrix** | [`PRIVACY_DATA_FLOW_MATRIX_CURRENT.csv`](PRIVACY_DATA_FLOW_MATRIX_CURRENT.csv) |
| **Remediation plan** | [`SECURITY_REMEDIATION_PLAN_CURRENT.md`](SECURITY_REMEDIATION_PLAN_CURRENT.md) |
| **Negative tests** | [`MAIN_SECURITY_NEGATIVE_TEST_MATRIX_CURRENT.csv`](MAIN_SECURITY_NEGATIVE_TEST_MATRIX_CURRENT.csv) — SEC-NEG-01…10 **PASS** |
| **Overall readiness** | **83/100** (P0=0, P1=1 open: Privacy Manifest) |

---

## Aggiornamento indice 2026-06-17 — Command 8 sync/persistence/schema remediation

Chiusura finding P1/P2/P3 audit sync/persistence/schema; envelope v3 firmato, tombstone multi-attività, cloud diving-only, large-payload transfer.

| Campo | Valore |
|-------|--------|
| **Audit (input)** | [`MULTI_ACTIVITY_SYNC_PERSISTENCE_SCHEMA_AUDIT_CURRENT.md`](MULTI_ACTIVITY_SYNC_PERSISTENCE_SCHEMA_AUDIT_CURRENT.md) |
| **Remediation** | [`MULTI_ACTIVITY_SYNC_PERSISTENCE_SCHEMA_REMEDIATION_REPORT_CURRENT.md`](MULTI_ACTIVITY_SYNC_PERSISTENCE_SCHEMA_REMEDIATION_REPORT_CURRENT.md) |
| **Traceability** | [`MULTI_ACTIVITY_SYNC_FINDING_TRACEABILITY_CURRENT.csv`](MULTI_ACTIVITY_SYNC_FINDING_TRACEABILITY_CURRENT.csv) |
| **Validate** | `./Scripts/validate_multi_activity_sync_persistence_schema_readiness.sh` PASS |
| **Software readiness** | **100%** (physical QA **PENDING**) |

---

## Aggiornamento indice 2026-06-20 — Command 8 sync/persistence/schema audit V3.0

Audit read-only sync Watch↔iOS, persistence, schema, migration, backup/restore multi-attività.

| Campo | Valore |
|-------|--------|
| **Audit** | [`MULTI_ACTIVITY_SYNC_PERSISTENCE_SCHEMA_AUDIT_CURRENT.md`](MULTI_ACTIVITY_SYNC_PERSISTENCE_SCHEMA_AUDIT_CURRENT.md) |
| **Namespaces** | [`SYNC_MESSAGE_NAMESPACE_MATRIX_CURRENT.csv`](SYNC_MESSAGE_NAMESPACE_MATRIX_CURRENT.csv) |
| **Schema/migration** | [`SCHEMA_MIGRATION_COMPATIBILITY_MATRIX_CURRENT.csv`](SCHEMA_MIGRATION_COMPATIBILITY_MATRIX_CURRENT.csv) |
| **Backup/restore** | [`BACKUP_RESTORE_ISOLATION_MATRIX_CURRENT.csv`](BACKUP_RESTORE_ISOLATION_MATRIX_CURRENT.csv) |
| **Overall readiness** | **82/100** (P0=0, P1=2) |

---

## Aggiornamento indice 2026-06-20 — Command 7 activity architecture remediation

Chiusura finding P0/P1 audit architettura multi-attività; logbook Watch gated; environment iOS isolato; settings facade.

| Campo | Valore |
|-------|--------|
| **Audit** | [`ACTIVITY_ARCHITECTURE_SETTINGS_LOGBOOK_AUDIT_CURRENT.md`](ACTIVITY_ARCHITECTURE_SETTINGS_LOGBOOK_AUDIT_CURRENT.md) |
| **Remediation** | [`ACTIVITY_ARCHITECTURE_SETTINGS_LOGBOOK_REMEDIATION_REPORT_CURRENT.md`](ACTIVITY_ARCHITECTURE_SETTINGS_LOGBOOK_REMEDIATION_REPORT_CURRENT.md) |
| **Traceability** | [`ACTIVITY_ARCHITECTURE_FINDING_TRACEABILITY_CURRENT.csv`](ACTIVITY_ARCHITECTURE_FINDING_TRACEABILITY_CURRENT.csv) |
| **Validate** | `./Scripts/validate_activity_architecture_settings_logbook_readiness.sh` PASS (1381 iOS + 902 Watch) |
| **External QA** | [`ACTIVITY_ARCHITECTURE_EXTERNAL_QA_PENDING_CURRENT.md`](ACTIVITY_ARCHITECTURE_EXTERNAL_QA_PENDING_CURRENT.md) — **PENDING** |

---

## Aggiornamento indice 2026-06-20 — Command 6 git/documentation alignment V3.0

Allineamento documentazione multi-attività (Diving, Apnea, Snorkeling) su `main`; baseline README/INDEX/CSV; report branch alignment.

| Campo | Valore |
|-------|--------|
| **Command** | `6-DIR_DIVING_GIT_DOCUMENTATION_ALIGNMENT_COMMAND_CCR_UPDATED_V3.0.md` |
| **Report** | [`DIR_DIVING_DOCUMENTATION_BRANCH_ALIGNMENT_REPORT.md`](DIR_DIVING_DOCUMENTATION_BRANCH_ALIGNMENT_REPORT.md) |
| **PR snapshot** | [`PR_STATUS_20260620.md`](PR_STATUS_20260620.md) |
| **Baseline HEAD** | `bf03fb0` |
| **Validate** | `./Scripts/validate_main_deep_code_readiness.sh` PASS (1362 iOS + 890 Watch tests, 0 skipped) |

---

## Aggiornamento indice 2026-06-20 — Command 5 deep code audit V3.0 + remediation

Audit read-only V3.0 multi-attività; remediation software MAIN deep code readiness 100%.

| Campo | Valore |
|-------|--------|
| **Command** | `5-DIR_DIVING_MAIN_DEEP_CODE_ANALYSIS_COMMAND_CCR_UPDATED_V3.0.md` |
| **Audit** | [`MAIN_DEEP_CODE_ANALYSIS_BUG_PERFORMANCE_SECURITY_AUDIT_CURRENT.md`](MAIN_DEEP_CODE_ANALYSIS_BUG_PERFORMANCE_SECURITY_AUDIT_CURRENT.md) |
| **Remediation** | [`MAIN_DEEP_CODE_ANALYSIS_REMEDIATION_REPORT_CURRENT.md`](MAIN_DEEP_CODE_ANALYSIS_REMEDIATION_REPORT_CURRENT.md) |
| **Traceability** | [`MAIN_DEEP_CODE_FINDING_TRACEABILITY_CURRENT.csv`](MAIN_DEEP_CODE_FINDING_TRACEABILITY_CURRENT.csv) |
| **Matrices** | [`MAIN_SECURITY_NEGATIVE_TEST_MATRIX_CURRENT.csv`](MAIN_SECURITY_NEGATIVE_TEST_MATRIX_CURRENT.csv), [`MAIN_SYNC_DATA_INTEGRITY_MATRIX_CURRENT.csv`](MAIN_SYNC_DATA_INTEGRITY_MATRIX_CURRENT.csv), [`MAIN_PRIVACY_FILE_PROTECTION_MATRIX_CURRENT.csv`](MAIN_PRIVACY_FILE_PROTECTION_MATRIX_CURRENT.csv) |
| **Gate** | `MAIN_INTERNAL_CODE_READINESS_100` / `MAIN_SOFTWARE_FINDINGS_OPEN_0` |
| **External QA** | [`MAIN_EXTERNAL_QA_PENDING_CURRENT.md`](MAIN_EXTERNAL_QA_PENDING_CURRENT.md) — all **PENDING** |

---

## Aggiornamento indice 2026-06-17 — Command 15 UI/UX mockup and iOS root-flow audit

Audit read-only UI/UX, mockup path integrity, activity selection, functional links e logbook ownership @ `138dccb`.

| Campo | Valore |
|-------|--------|
| **Command** | `15_DIR_DIVING_UI_UX_READINESS_MOCKUP_IOS_ROOT_FLOW_AND_LOGBOOK_OWNERSHIP_AUDIT_UPDATED.md` |
| **Report** | [`DIR_DIVING_UI_UX_READINESS_AND_MOCKUP_AUDIT_CURRENT.md`](DIR_DIVING_UI_UX_READINESS_AND_MOCKUP_AUDIT_CURRENT.md) |
| **iOS selection report** | [`DIR_DIVING_IOS_ACTIVITY_SELECTION_AND_LINKS_AUDIT_CURRENT.md`](DIR_DIVING_IOS_ACTIVITY_SELECTION_AND_LINKS_AUDIT_CURRENT.md) |
| **Remediation plan** | [`DIR_DIVING_UI_UX_REMEDIATION_PLAN_CURRENT.md`](DIR_DIVING_UI_UX_REMEDIATION_PLAN_CURRENT.md) |
| **Matrices** | [`DIR_DIVING_MOCKUP_PATH_VALIDATION_CURRENT.csv`](DIR_DIVING_MOCKUP_PATH_VALIDATION_CURRENT.csv), [`DIR_DIVING_MOCKUP_IMPLEMENTATION_MATRIX_CURRENT.csv`](DIR_DIVING_MOCKUP_IMPLEMENTATION_MATRIX_CURRENT.csv), [`DIR_DIVING_UI_SCREEN_INVENTORY_CURRENT.csv`](DIR_DIVING_UI_SCREEN_INVENTORY_CURRENT.csv), [`DIR_DIVING_IOS_FUNCTIONAL_LINK_MATRIX_CURRENT.csv`](DIR_DIVING_IOS_FUNCTIONAL_LINK_MATRIX_CURRENT.csv), [`DIR_DIVING_LOGBOOK_OWNERSHIP_AND_ROUTING_MATRIX_CURRENT.csv`](DIR_DIVING_LOGBOOK_OWNERSHIP_AND_ROUTING_MATRIX_CURRENT.csv) |
| **Verdict** | **CONDITIONAL PASS** (84/100 global UI/UX; no P0) |
| **Mockups** | `mockups/` 59 PNG + `Docs/ReferenceUI/` legacy/duplicate set |
| **Validate** | `./Scripts/audit_localization.sh` PASS |

---

## Aggiornamento indice 2026-06-17 — Command 14 activity-specific roots/settings/logbooks

Consolidamento architettura iOS Companion per Diving, Apnea, Snorkeling: shared settings store, snorkeling settings domain, activity switching da tutte le settings, registry coerenza.

| Campo | Valore |
|-------|--------|
| **Command** | `14_ACTIVITY_SPECIFIC_ROOT_FEATURES_SETTINGS_AND_LOGBOOKS_IMPLEMENTATION_UPDATED.md` |
| **Report** | [`DIR_DIVING_ACTIVITY_SPECIFIC_ROOT_FEATURES_SETTINGS_AND_LOGBOOKS_IMPLEMENTATION_REPORT_CURRENT.md`](DIR_DIVING_ACTIVITY_SPECIFIC_ROOT_FEATURES_SETTINGS_AND_LOGBOOKS_IMPLEMENTATION_REPORT_CURRENT.md) |
| **Coherence matrix** | [`DIR_DIVING_ACTIVITY_SETTINGS_COHERENCE_MATRIX_CURRENT.csv`](DIR_DIVING_ACTIVITY_SETTINGS_COHERENCE_MATRIX_CURRENT.csv) |
| **Verdict** | **CONDITIONAL PASS** (iOS software; Watch settings scoping deferred) |
| **XCTest (focused)** | `IOSActivitySettingsCoherenceTests` 7/7; `IOSCompanionActivitySelectionTests` 11/11 |
| **Build** | DIRDiving iOS — BUILD SUCCEEDED |
| **Validate** | `./Scripts/audit_localization.sh` PASS |

---

## Aggiornamento indice 2026-06-17 — Audit 13 integrated three-mode remediation

Remediation software P1–P3 da [`AUDIT_INTEGRATO_TRE_MODALITA_CURRENT.md`](AUDIT_INTEGRATO_TRE_MODALITA_CURRENT.md): fix Apnea suspend/resume session clock, integrated validator, sequential flow tests.

| Campo | Valore |
|-------|--------|
| **Audit** | [`AUDIT_INTEGRATO_TRE_MODALITA_CURRENT.md`](AUDIT_INTEGRATO_TRE_MODALITA_CURRENT.md) |
| **Remediation** | [`AUDIT_INTEGRATO_TRE_MODALITA_REMEDIATION_REPORT_CURRENT.md`](AUDIT_INTEGRATO_TRE_MODALITA_REMEDIATION_REPORT_CURRENT.md) |
| **Validation matrix** | [`INTEGRATED_MODES_RELEASE_VALIDATION_MATRIX_CURRENT.csv`](INTEGRATED_MODES_RELEASE_VALIDATION_MATRIX_CURRENT.csv) |
| **Traceability** | [`INTEGRATED_MODES_REMEDIATION_TRACEABILITY_CURRENT.csv`](INTEGRATED_MODES_REMEDIATION_TRACEABILITY_CURRENT.csv) |
| **Verdict** | Internal **GO**; external **NO-GO** (physical QA pending) |
| **Gate** | `INTEGRATED_MODES_INTERNAL_RELEASE_GATE_PASS` |
| **Validate** | `./Scripts/validate_integrated_modes.sh --internal` |

---

Audit indipendente read-only post Command 12.

| Campo | Valore |
|-------|--------|
| **Command** | `12_AUDIT_SNORKELING_RELEASE_GATE.md` |
| **Report** | [`AUDIT_SNORKELING_RELEASE_GATE_CURRENT.md`](AUDIT_SNORKELING_RELEASE_GATE_CURRENT.md) |
| **Verdict** | Internal 100%; external **GO WITH CONDITIONS** |
| **Gate** | `SNORKELING_RELEASE_HARD_INTERNAL_GO` |

---

## Aggiornamento indice 2026-06-19 — Snorkeling Command 12 release hardening

Mockup matrix, architecture doc, release checklist, hardened validation script.

| Campo | Valore |
|-------|--------|
| **Command** | `12_SNORKELING_RELEASE_HARDENING_AND_DOCUMENTATION.md` |
| **Architecture** | [`SNORKELING_ARCHITECTURE.md`](SNORKELING_ARCHITECTURE.md) |
| **Checklist** | [`SNORKELING_RELEASE_CHECKLIST.md`](SNORKELING_RELEASE_CHECKLIST.md) |
| **Test matrix** | [`SNORKELING_RELEASE_HARD_TEST_MATRIX.md`](SNORKELING_RELEASE_HARD_TEST_MATRIX.md) |
| **Validation report** | [`DIR_DIVING_SNORKELING_RELEASE_HARD_VALIDATION_REPORT.md`](DIR_DIVING_SNORKELING_RELEASE_HARD_VALIDATION_REPORT.md) |
| **Gate** | [`AUDIT_SNORKELING_RELEASE_GATE_CURRENT.md`](AUDIT_SNORKELING_RELEASE_GATE_CURRENT.md) |
| **Mockups** | `mockups/` (59 PNG canonical; Snorkeling under `mockups/iOS/` + `mockups/Apple_Watch/`) |
| **Gate** | `SNORKELING_RELEASE_HARD_INTERNAL_GO` |

---

## Aggiornamento indice 2026-06-19 — Audit 11 remediation V1.0

Chiusura finding AUDIT11-SNK-001…006; gate incondizionato Command 12.

| Campo | Valore |
|-------|--------|
| **Audit** | [`AUDIT_SNORKELING_IOS_MAPS_SYNC_EXPORT_CURRENT.md`](AUDIT_SNORKELING_IOS_MAPS_SYNC_EXPORT_CURRENT.md) |
| **Remediation** | [`SNORKELING_IOS_MAPS_SYNC_EXPORT_REMEDIATION_REPORT_V1.0.md`](SNORKELING_IOS_MAPS_SYNC_EXPORT_REMEDIATION_REPORT_V1.0.md) |
| **Verdict** | Internal code readiness 100% |
| **Gate** | `READY_FOR_SNORKELING_COMMAND_12` |
| **Validate** | `./Scripts/validate_snorkeling_release_readiness.sh --internal` |

---

## Aggiornamento indice 2026-06-18 — Audit 11 iOS maps/sync/export

Audit indipendente read-only post Commands 08–11; gate condizionato verso Command 12.

| Campo | Valore |
|-------|--------|
| **Command** | `11_AUDIT_SNORKELING_IOS_MAPS_SYNC_EXPORT.md` |
| **Report** | [`AUDIT_SNORKELING_IOS_MAPS_SYNC_EXPORT_CURRENT.md`](AUDIT_SNORKELING_IOS_MAPS_SYNC_EXPORT_CURRENT.md) |
| **Verdict** | Internal GO ~88%; release script gaps |
| **Gate** | `READY_FOR_SNORKELING_COMMAND_12_WITH_CONDITIONS` |

---

## Aggiornamento indice 2026-06-18 — Snorkeling iOS/Watch sync protocol (Command 11)

Namespace WC dedicato snorkeling: iOS→Watch route (Command 08) + Watch→iOS session signed transport, ACK, retry, merge idempotente.

| Campo | Valore |
|-------|--------|
| **Command** | `11_SNORKELING_IOS_WATCH_SYNC_PROTOCOL.md` |
| **Report** | [`DIR_DIVING_SNORKELING_IOS_WATCH_SYNC_PROTOCOL_IMPLEMENTATION_REPORT_CURRENT.md`](DIR_DIVING_SNORKELING_IOS_WATCH_SYNC_PROTOCOL_IMPLEMENTATION_REPORT_CURRENT.md) |
| **Tests focused** | 9 PASS + 5 XCTSkip (peer keychain) — Command 11 session sync suites |
| **Build** | DIRDiving iOS — BUILD SUCCEEDED |
| **Gate** | `READY_FOR_SNORKELING_COMMAND_12` |

---

## Aggiornamento indice 2026-06-18 — Snorkeling iOS photos/gear/export (Command 10)

Foto sessione/marker, profili attrezzatura, buddy/gruppo, export privacy-gated (PDF/CSV/JSON/GPX/chart).

| Campo | Valore |
|-------|--------|
| **Command** | `10_IOS_SNORKELING_PHOTOS_GEAR_BUDDY_EXPORT_PRIVACY.md` |
| **Report** | [`DIR_DIVING_SNORKELING_IOS_PHOTOS_GEAR_BUDDY_EXPORT_PRIVACY_IMPLEMENTATION_REPORT_CURRENT.md`](DIR_DIVING_SNORKELING_IOS_PHOTOS_GEAR_BUDDY_EXPORT_PRIVACY_IMPLEMENTATION_REPORT_CURRENT.md) |
| **Tests focused** | 48/48 PASS (Command 08–10 suites) |
| **Build** | DIRDiving iOS — BUILD SUCCEEDED |
| **Gate** | `READY_FOR_SNORKELING_COMMAND_11` |

---

## Aggiornamento indice 2026-06-18 — Snorkeling iOS logbook (Command 09)

Logbook, grafici sessione, statistiche, record personali, mappa superficie con gap GPS.

| Campo | Valore |
|-------|--------|
| **Command** | `09_IOS_SNORKELING_LOGBOOK_GRAPHS_STATS_RECORDS.md` |
| **Report** | [`DIR_DIVING_SNORKELING_IOS_LOGBOOK_GRAPHS_STATS_RECORDS_IMPLEMENTATION_REPORT_CURRENT.md`](DIR_DIVING_SNORKELING_IOS_LOGBOOK_GRAPHS_STATS_RECORDS_IMPLEMENTATION_REPORT_CURRENT.md) |
| **Tests focused** | 38/38 PASS (`IOSSnorkelingLogbookAnalyticsTests` + Command 08 suites) |
| **Build** | DIRDiving iOS — BUILD SUCCEEDED |
| **Gate** | `READY_FOR_SNORKELING_COMMAND_10` |

---

## Aggiornamento indice 2026-06-18 — Snorkeling iOS companion (Command 08)

Dashboard, profili, route planner MapKit, sync percorso iOS→Watch.

| Campo | Valore |
|-------|--------|
| **Command** | `08_IOS_SNORKELING_DASHBOARD_PROFILES_ROUTE_PLANNER_MAPS.md` |
| **Report** | [`DIR_DIVING_SNORKELING_IOS_DASHBOARD_PROFILES_ROUTE_PLANNER_MAPS_IMPLEMENTATION_REPORT_CURRENT.md`](DIR_DIVING_SNORKELING_IOS_DASHBOARD_PROFILES_ROUTE_PLANNER_MAPS_IMPLEMENTATION_REPORT_CURRENT.md) |
| **Tests focused** | 26/26 PASS (`IOSSnorkelingCompanionTests`, `IOSSnorkelingRoutePlannerTests`, `SnorkelingRouteSyncCodecTests`, selection) |
| **Build** | DIRDiving iOS — BUILD SUCCEEDED |
| **Gate** | `READY_FOR_SNORKELING_COMMAND_09` |

---

## Aggiornamento indice 2026-06-18 — Audit 10 remediation V1.0

Remediation Audit 10 → internal readiness 100%.

| Campo | Valore |
|-------|--------|
| **Remediation** | [`SNORKELING_NAV_UI_PERSISTENCE_REMEDIATION_REPORT_V1.0.md`](SNORKELING_NAV_UI_PERSISTENCE_REMEDIATION_REPORT_V1.0.md) |
| **Audit (updated)** | [`AUDIT_SNORKELING_NAV_UI_PERSISTENCE_CURRENT.md`](AUDIT_SNORKELING_NAV_UI_PERSISTENCE_CURRENT.md) |
| **Validation script** | `Scripts/validate_snorkeling_release_readiness.sh` |
| **Tests Snorkeling focused** | 168/168 PASS |
| **Gate** | `READY_FOR_SNORKELING_COMMAND_08` |

---

## Aggiornamento indice 2026-06-18 — Audit 10 Snorkeling nav/UI/persistence (Commands 04–07)

Audit indipendente read-only post-Commands 04–07.

| Campo | Valore |
|-------|--------|
| **Audit** | [`AUDIT_SNORKELING_NAV_UI_PERSISTENCE_CURRENT.md`](AUDIT_SNORKELING_NAV_UI_PERSISTENCE_CURRENT.md) |
| **Scope** | Navigation, return, alarms, markers, Watch UI, persistence, logbook |
| **Tests 04–07** | 76/76 PASS (simulator) |
| **Tests Snorkeling focused** | 150/150 PASS |
| **Verdict** | **PASS WITH CONDITIONS** (P1: 11 localization keys missing) |
| **Gate** | `READY_FOR_SNORKELING_COMMAND_08_WITH_CONDITIONS` |

---

## Aggiornamento indice 2026-06-18 — Snorkeling persistence/recovery/logbook (Command 07)

Checkpoint atomico SHA-256, recovery con quarantena, logbook Watch dedicato.

| Campo | Valore |
|-------|--------|
| **Command** | `07_SNORKELING_PERSISTENCE_RECOVERY_AND_WATCH_LOGBOOK.md` |
| **Report** | [`DIR_DIVING_SNORKELING_PERSISTENCE_RECOVERY_LOGBOOK_IMPLEMENTATION_REPORT_CURRENT.md`](DIR_DIVING_SNORKELING_PERSISTENCE_RECOVERY_LOGBOOK_IMPLEMENTATION_REPORT_CURRENT.md) |
| **Contract** | [`SNORKELING_PERSISTENCE_RECOVERY_CONTRACT.md`](SNORKELING_PERSISTENCE_RECOVERY_CONTRACT.md) |
| **Tests** | `SnorkelingPersistenceRecoveryTests` (11), `SnorkelingWatchRuntimeStorePersistenceTests` (2) |
| **Gate** | `READY_FOR_SNORKELING_COMMAND_08` |

---

UI Watch promossa su MAIN: presentation mapper, runtime store, 8 schermate approvate.

| Campo | Valore |
|-------|--------|
| **Command** | `06_WATCH_SNORKELING_UI_ALL_STATES.md` |
| **Report** | [`DIR_DIVING_SNORKELING_WATCH_UI_ALL_STATES_IMPLEMENTATION_REPORT_CURRENT.md`](DIR_DIVING_SNORKELING_WATCH_UI_ALL_STATES_IMPLEMENTATION_REPORT_CURRENT.md) |
| **Tests** | `SnorkelingWatchPresentationTests` (15), `SnorkelingWatchLayoutContractTests` (5), `SnorkelingWatchMainPromotionTests` (8) |
| **Gate** | `READY_FOR_SNORKELING_COMMAND_07` |

---

Motore eventi operativo: allarmi, marker con qualità posizione, aptiche, Mission Mode presentation profile.

| Campo | Valore |
|-------|--------|
| **Command** | `05_SNORKELING_ALARMS_MARKERS_HAPTICS_MISSION_MODE.md` |
| **Report** | [`DIR_DIVING_SNORKELING_ALARMS_MARKERS_HAPTICS_MISSION_MODE_IMPLEMENTATION_REPORT_CURRENT.md`](DIR_DIVING_SNORKELING_ALARMS_MARKERS_HAPTICS_MISSION_MODE_IMPLEMENTATION_REPORT_CURRENT.md) |
| **Tests** | `SnorkelingAlarmsMarkersHapticsMissionModeTests` (12) |
| **Gate** | `READY_FOR_SNORKELING_COMMAND_06` |

---

## Aggiornamento indice 2026-06-18 — Snorkeling navigation/return engine (Command 04)

Engine navigazione waypoint + return advisor su `Shared/`; UI non promossa.

| Campo | Valore |
|-------|--------|
| **Command** | `04_SNORKELING_NAVIGATION_AND_RETURN_ENGINE.md` |
| **Report** | [`DIR_DIVING_SNORKELING_NAVIGATION_RETURN_ENGINE_IMPLEMENTATION_REPORT_CURRENT.md`](DIR_DIVING_SNORKELING_NAVIGATION_RETURN_ENGINE_IMPLEMENTATION_REPORT_CURRENT.md) |
| **Tests** | `SnorkelingNavigationReturnEngineTests` (18) |
| **Watch MAIN** | **not promoted** |

---

## Aggiornamento indice 2026-06-18 — Audit 09 remediation Snorkeling (V1.0)

Remediation Commands 01–03 a **100% internal foundation readiness**; gate Command 04 **READY**.

| Campo | Valore |
|-------|--------|
| **Audit baseline** | `f38dbd4` |
| **Remediation** | [`SNORKELING_DOMAIN_INGESTION_LIFECYCLE_REMEDIATION_REPORT_V1.0.md`](SNORKELING_DOMAIN_INGESTION_LIFECYCLE_REMEDIATION_REPORT_V1.0.md) |
| **Contracts** | [`SNORKELING_NAVIGATION_RETURN_ENGINE_CONTRACT.md`](SNORKELING_NAVIGATION_RETURN_ENGINE_CONTRACT.md), [`SNORKELING_PERSISTENCE_RECOVERY_CONTRACT.md`](SNORKELING_PERSISTENCE_RECOVERY_CONTRACT.md) |
| **Focused tests** | 85 Snorkeling tests **PASS** (iOS Algorithm Tests) |
| **Gate** | `SNORKELING_FOUNDATIONS_INTERNAL_GO`, `READY_FOR_SNORKELING_COMMAND_04` |
| **Production** | **NO-GO** |

---

Audit read-only post-Commands 01–03; gate Command 04 **PASS WITH CONDITIONS**.

| Campo | Valore |
|-------|--------|
| **Comando** | `09_AUDIT_SNORKELING_DOMAIN_INGESTION_LIFECYCLE.md` |
| **Report** | [`AUDIT_SNORKELING_DOMAIN_INGESTION_LIFECYCLE_CURRENT.md`](AUDIT_SNORKELING_DOMAIN_INGESTION_LIFECYCLE_CURRENT.md) |
| **Baseline** | `main` @ **`f38dbd4`** |
| **Verdict** | **PASS WITH CONDITIONS** |
| **Gate Command 04** | **GO** (fix P2 isolation test comment) |
| **XCTest snorkeling** | 41/42 pass (1 isolation false positive) |

---

## Aggiornamento indice 2026-06-18 — Audit 08 Apnea release gate

Gate finale indipendente post-Command 12: lifecycle, sync, UI, privacy, rollback; conferma non-regressione Gauge/FC.

| Campo | Valore |
|-------|--------|
| **Comando** | `08_AUDIT_APNEA_RELEASE_GATE.md` |
| **Report** | [`AUDIT_APNEA_RELEASE_GATE_CURRENT.md`](AUDIT_APNEA_RELEASE_GATE_CURRENT.md) |
| **Baseline** | `main` @ **`7c8e8d3`** |
| **Commit remediation** | **`7c8e8d3`** |
| **Readiness interna** | **96%** |
| **Decisione** | **GO WITH CONDITIONS** (interno) — TestFlight/App Store **NO-GO** |
| **P1** | `ApneaSuspendResumeLifecycleIntegrationTests` (2 fail release-hard); QA fisica PENDING |

---

## Aggiornamento indice 2026-06-18 — Remediation V1.0 Apnea iOS / sync / end-to-end

Chiusura P3 Audit 07: negative-path sync, E2E harness, ACK tests, QA evidence sync, cloud stub.

| Campo | Valore |
|-------|--------|
| **Audit** | [`AUDIT_APNEA_IOS_SYNC_END_TO_END_CURRENT.md`](AUDIT_APNEA_IOS_SYNC_END_TO_END_CURRENT.md) |
| **Remediation** | [`APNEA_IOS_SYNC_END_TO_END_REMEDIATION_REPORT_V1.0.md`](APNEA_IOS_SYNC_END_TO_END_REMEDIATION_REPORT_V1.0.md) |
| **Commit remediation** | **`7c8e8d3`** |
| **Readiness interna** | **100%** (codice/test/docs) |
| **Command 12 gate** | **READY_FOR_APNEA_COMMAND_12** (automazione; QA fisica PENDING) |

---

## Aggiornamento indice 2026-06-18 — Audit 07 Apnea iOS / sync / end-to-end

Read-only audit su `main`: dashboard iOS, profili, planner, logbook, export, sync iOS↔Watch, autonomia offline (Commands Apnea 08–11). Nessuna modifica al codice applicativo.

| Campo | Valore |
|-------|--------|
| **Comando** | `07_AUDIT_APNEA_IOS_SYNC_END_TO_END.md` |
| **Report** | [`AUDIT_APNEA_IOS_SYNC_END_TO_END_CURRENT.md`](AUDIT_APNEA_IOS_SYNC_END_TO_END_CURRENT.md) |
| **Baseline** | `main` @ **`2309320`** |
| **Commit remediation** | **`2309320`** |
| **Readiness interna** | **96%** |
| **Verdict** | **PASS** — gate Apnea Command 12 **PASS WITH CONDITIONS** |
| **Prerequisites** | Audits 05–06 **PASS**; Commands 08–11 implementati |

---

## Aggiornamento indice 2026-06-18 — Remediation V1.0 Apnea Watch features / UI / logbook

Chiusura finding P2/P3 Audit 06: `ApneaWatchRuntimeStore`, promozione `ApneaView` su Watch MAIN, test target-not-reached, layout contract, QA evidence scaffolding.

| Campo | Valore |
|-------|--------|
| **Audit** | [`AUDIT_APNEA_WATCH_FEATURES_UI_LOGBOOK_CURRENT.md`](AUDIT_APNEA_WATCH_FEATURES_UI_LOGBOOK_CURRENT.md) |
| **Remediation** | [`APNEA_WATCH_FEATURES_UI_LOGBOOK_REMEDIATION_REPORT_V1.0.md`](APNEA_WATCH_FEATURES_UI_LOGBOOK_REMEDIATION_REPORT_V1.0.md) |
| **Baseline audit** | `main` @ **`5baa97e`** |
| **Commit remediation** | **`2309320`** |
| **Readiness interna** | **100%** (codice/test/docs) |
| **Watch MAIN promotion** | **PASS** |
| **Command 08 gate** | **READY_FOR_APNEA_COMMAND_08** |
| **Test** | Watch 576 (0 fail), iOS focused Apnea 41 (0 fail) |

---

## Aggiornamento indice 2026-06-18 — Audit 06 Apnea Watch features / UI / logbook

Read-only audit su `main`: allarmi, target, marker, aptiche, Mission Mode, UI presentation, logbook Watch (Commands Apnea 04–07). Nessuna modifica al codice.

| Campo | Valore |
|-------|--------|
| **Comando** | `06_AUDIT_APNEA_WATCH_FEATURES_UI_LOGBOOK.md` |
| **Report** | [`AUDIT_APNEA_WATCH_FEATURES_UI_LOGBOOK_CURRENT.md`](AUDIT_APNEA_WATCH_FEATURES_UI_LOGBOOK_CURRENT.md) |
| **Baseline** | `main` @ **`5baa97e`** |
| **Readiness interna** | **94%** |
| **Verdict** | **PASS** — gate Apnea Command 08 **PASS WITH CONDITIONS** |
| **Prerequisites** | Audit 05 **PASS** |

---

## Aggiornamento indice 2026-06-18 — Remediation V1.0 Apnea domain / lifecycle / recovery

Chiusura finding P2/P3 Audit 05: suspend/resume integration tests, checkpoint hardening, script/docs su `main`, QA evidence scaffolding.

| Campo | Valore |
|-------|--------|
| **Audit** | [`AUDIT_APNEA_DOMAIN_LIFECYCLE_RECOVERY_CURRENT.md`](AUDIT_APNEA_DOMAIN_LIFECYCLE_RECOVERY_CURRENT.md) |
| **Remediation** | [`APNEA_DOMAIN_LIFECYCLE_RECOVERY_REMEDIATION_REPORT_V1.0.md`](APNEA_DOMAIN_LIFECYCLE_RECOVERY_REMEDIATION_REPORT_V1.0.md) |
| **Baseline audit** | `main` @ **`bcb985b`** |
| **Readiness interna** | **100%** |
| **Command 04 gate** | **READY_FOR_COMMAND_04** (UI non promossa) |
| **Test** | Watch 549 (0 fail), iOS 936 (0 fail) |

---

## Aggiornamento indice 2026-06-18 — Audit 05 Apnea domain / lifecycle / recovery

Read-only audit su `main`: modelli dominio, depth feed, `ApneaSessionEngine`, recovery, checkpoint (Commands Apnea 01–03). Nessuna modifica al codice.

| Campo | Valore |
|-------|--------|
| **Comando** | `05_AUDIT_APNEA_DOMAIN_LIFECYCLE_RECOVERY.md` |
| **Report** | [`AUDIT_APNEA_DOMAIN_LIFECYCLE_RECOVERY_CURRENT.md`](AUDIT_APNEA_DOMAIN_LIFECYCLE_RECOVERY_CURRENT.md) |
| **Baseline** | `main` @ **`bcb985b`** |
| **Readiness interna** | **95%** |
| **Verdict** | **PASS** — gate Apnea Command 04 **PASS WITH CONDITIONS** |
| **Script** | `validate_apnea_release_readiness.sh` **PASS** |

---

## Aggiornamento indice 2026-06-17 — Audit 04 Full Computer release gate

Audit finale indipendente post-Commands 11–12. Nessuna modifica al codice.

| Campo | Valore |
|-------|--------|
| **Comando** | `04_AUDIT_FULL_COMPUTER_RELEASE_GATE.md` |
| **Report** | [`AUDIT_FULL_COMPUTER_RELEASE_GATE_CURRENT.md`](AUDIT_FULL_COMPUTER_RELEASE_GATE_CURRENT.md) |
| **Baseline** | `main` @ **`b8b277d`** |
| **Readiness interna** | **96%** |
| **Decisione** | **GO WITH CONDITIONS** — produzione esterna **NO-GO** (QA fisica PENDING) |
| **Prerequisites** | Audit 01–03 + remediation V1.0 **PASS** |

---

## Aggiornamento indice 2026-06-17 — Remediation V1.0 Full Computer multigas / sync / recovery

Chiusura finding P2/P3 Audit 03: Policy A travel/bailout, test suite store/recovery/namespace, hardening import store.

| Campo | Valore |
|-------|--------|
| **Audit** | [`AUDIT_FULL_COMPUTER_MULTIGAS_SYNC_RECOVERY_CURRENT.md`](AUDIT_FULL_COMPUTER_MULTIGAS_SYNC_RECOVERY_CURRENT.md) |
| **Remediation** | [`FULL_COMPUTER_MULTIGAS_SYNC_RECOVERY_REMEDIATION_REPORT_V1.0.md`](FULL_COMPUTER_MULTIGAS_SYNC_RECOVERY_REMEDIATION_REPORT_V1.0.md) @ **`d6eec3a`** |
| **Policy** | Travel/bailout **Policy A** — schema v1 invariato |
| **Test** | Watch 508 (0 fail), iOS 933 (0 fail) |

---

## Aggiornamento indice 2026-06-17 — Audit 03 Full Computer multigas / sync / recovery

Read-only audit su `main`: modelli multigas, sync piano iOS→Watch, gas switch runtime, checkpoint recovery (Commands 07–10). Nessuna modifica al codice.

| Campo | Valore |
|-------|--------|
| **Comando** | `03_AUDIT_FULL_COMPUTER_MULTIGAS_SYNC_RECOVERY.md` |
| **Report** | [`AUDIT_FULL_COMPUTER_MULTIGAS_SYNC_RECOVERY_CURRENT.md`](AUDIT_FULL_COMPUTER_MULTIGAS_SYNC_RECOVERY_CURRENT.md) |
| **Baseline** | `main` @ **`8820de0`** |
| **Verdict** | **PASS** — gate Command 11 (FC scope) |
| **Prerequisites** | Audit 01–02 **PASS** |

---  
**Uso:** punto di ingresso per ripartire a lavorare sul progetto.  
**Panoramica funzioni (IT):** [`PRODUCT_FEATURES_IT.md`](PRODUCT_FEATURES_IT.md)

---

## Aggiornamento indice 2026-06-17 — Audit 02 Full Computer runtime / deco / UI

Read-only audit su `main`: runtime Bühlmann Watch, solver prospettico, state machine tappe, UI live FC. Nessuna modifica al codice.

| Campo | Valore |
|-------|--------|
| **Comando** | `02_AUDIT_FULL_COMPUTER_RUNTIME_DECO_UI.md` |
| **Report** | [`AUDIT_FULL_COMPUTER_RUNTIME_DECO_UI_CURRENT.md`](AUDIT_FULL_COMPUTER_RUNTIME_DECO_UI_CURRENT.md) |
| **Baseline** | `main` @ audit run |
| **Verdict** | **PASS** (Watch MAIN); iOS = planner/logbook only |
| **Remediation** | P2/P3 closed @ post-`efdcb3a` commit — see audit addendum |
| **Prerequisite** | [`FULL_COMPUTER_FOUNDATIONS_REMEDIATION_REPORT_V1.1.md`](FULL_COMPUTER_FOUNDATIONS_REMEDIATION_REPORT_V1.1.md) |

---

## Aggiornamento indice 2026-06-18 — Snorkeling session lifecycle (Command 03)

`SnorkelingSessionEngine` deterministico + state machine dip; separato da `ExplorationStore`.

| Campo | Valore |
|-------|--------|
| **Command** | `03_SNORKELING_SESSION_AND_DIP_LIFECYCLE_ENGINE.md` |
| **Report** | [`DIR_DIVING_SNORKELING_SESSION_LIFECYCLE_IMPLEMENTATION_REPORT_CURRENT.md`](DIR_DIVING_SNORKELING_SESSION_LIFECYCLE_IMPLEMENTATION_REPORT_CURRENT.md) |
| **Commit** | **`8f7aeeb`** |
| **Tests** | `SnorkelingLifecycleEngineTests` (15) |
| **MAIN promotion** | **not yet** |

---

## Aggiornamento indice 2026-06-18 — Snorkeling sensor/GPS ingestion (Command 02)

Feed condivisi profondità + GPS su `Shared/Utils/Snorkeling*Feed`; UI non attivata.

| Campo | Valore |
|-------|--------|
| **Command** | `02_SNORKELING_SHARED_SENSOR_GPS_INGESTION.md` |
| **Report** | [`DIR_DIVING_SNORKELING_SENSOR_GPS_INGESTION_IMPLEMENTATION_REPORT_CURRENT.md`](DIR_DIVING_SNORKELING_SENSOR_GPS_INGESTION_IMPLEMENTATION_REPORT_CURRENT.md) |
| **Commit** | **`8f7aeeb`** |
| **Tests** | `SnorkelingSensorGPSIngestionTests` (13) + isolation |
| **MAIN promotion** | **not yet** |

---

## Aggiornamento indice 2026-06-18 — Snorkeling domain models (Command 01)

Dominio puro Snorkeling su `Shared/Models/Snorkeling*` + validator/migration; UI non attivata.

| Campo | Valore |
|-------|--------|
| **Command** | `01_SNORKELING_DOMAIN_MODELS_AND_VERSIONED_SCHEMA.md` |
| **Report** | [`DIR_DIVING_SNORKELING_DOMAIN_MODELS_IMPLEMENTATION_REPORT_CURRENT.md`](DIR_DIVING_SNORKELING_DOMAIN_MODELS_IMPLEMENTATION_REPORT_CURRENT.md) |
| **Commit** | **`db06bcd`** |
| **Tests** | `SnorkelingDomainModelTests` (12) |
| **MAIN promotion** | **not yet** — `SnorkelingView` excluded |

---

## Aggiornamento indice 2026-06-18 — Audit 08 release gate remediation

Remediation Audit 08: suspend/resume + monotonic clock fix, release-hard script `--internal`/`--release`, pure HMAC tests, documentation alignment, `APNEA_BATTERY_THERMAL` QA scaffold.

| Campo | Valore |
|-------|--------|
| **Audit** | [`AUDIT_APNEA_RELEASE_GATE_CURRENT.md`](AUDIT_APNEA_RELEASE_GATE_CURRENT.md) |
| **Remediation** | [`APNEA_RELEASE_GATE_REMEDIATION_REPORT_V1.0.md`](APNEA_RELEASE_GATE_REMEDIATION_REPORT_V1.0.md) |
| **Baseline commit** | **`db06bcd`** |
| **Internal gate** | **GO** (`validate_apnea_release_readiness.sh --internal`) |
| **TestFlight / App Store** | **NO-GO** (physical QA PENDING) |

---

## Aggiornamento indice 2026-06-17 — Apnea release-hard (Command 12)

Pass release-hard su `integration/full-computer`: matrice 23 mockup `APNEA_*`, test automatizzati, script `validate_apnea_release_readiness.sh`, architettura e checklist.

| Campo | Valore |
|-------|--------|
| **Architettura** | [`APNEA_ARCHITECTURE.md`](APNEA_ARCHITECTURE.md) |
| **Test matrix** | [`APNEA_RELEASE_HARD_TEST_MATRIX.md`](APNEA_RELEASE_HARD_TEST_MATRIX.md) |
| **Checklist** | [`APNEA_RELEASE_CHECKLIST.md`](APNEA_RELEASE_CHECKLIST.md) |
| **Validation report** | [`DIR_DIVING_APNEA_RELEASE_HARD_VALIDATION_REPORT.md`](DIR_DIVING_APNEA_RELEASE_HARD_VALIDATION_REPORT.md) |
| **Automation** | `./Scripts/validate_apnea_release_readiness.sh` |
| **Verdict** | Sim/build/test verdi sul branch; **physical QA PENDING** — non certificato per immersione |

### Report implementazione Apnea (Commands 05–11)

| Command | Report |
|---------|--------|
| 05 Domain | [`DIR_DIVING_APNEA_DOMAIN_MODELS_IMPLEMENTATION_REPORT_CURRENT.md`](DIR_DIVING_APNEA_DOMAIN_MODELS_IMPLEMENTATION_REPORT_CURRENT.md) |
| 06 Depth/lifecycle | [`DIR_DIVING_APNEA_DEPTH_FEED_LIFECYCLE_IMPLEMENTATION_REPORT_CURRENT.md`](DIR_DIVING_APNEA_DEPTH_FEED_LIFECYCLE_IMPLEMENTATION_REPORT_CURRENT.md) |
| 07 Alarms/markers | [`DIR_DIVING_APNEA_ALARMS_TARGETS_MARKERS_HAPTICS_IMPLEMENTATION_REPORT_CURRENT.md`](DIR_DIVING_APNEA_ALARMS_TARGETS_MARKERS_HAPTICS_IMPLEMENTATION_REPORT_CURRENT.md) |
| 08 Recovery/checkpoint | [`DIR_DIVING_APNEA_TIME_RECOVERY_CHECKPOINT_IMPLEMENTATION_REPORT_CURRENT.md`](DIR_DIVING_APNEA_TIME_RECOVERY_CHECKPOINT_IMPLEMENTATION_REPORT_CURRENT.md) |
| 09 Watch UI | [`DIR_DIVING_APNEA_WATCH_READY_ACTIVE_UI_IMPLEMENTATION_REPORT_CURRENT.md`](DIR_DIVING_APNEA_WATCH_READY_ACTIVE_UI_IMPLEMENTATION_REPORT_CURRENT.md) |
| 10 Watch logbook | [`DIR_DIVING_APNEA_WATCH_LOGBOOK_SESSION_STATISTICS_IMPLEMENTATION_REPORT_CURRENT.md`](DIR_DIVING_APNEA_WATCH_LOGBOOK_SESSION_STATISTICS_IMPLEMENTATION_REPORT_CURRENT.md) |
| 10b Surface/summary | [`DIR_DIVING_APNEA_WATCH_SURFACE_RECOVERY_SUMMARY_IMPLEMENTATION_REPORT_CURRENT.md`](DIR_DIVING_APNEA_WATCH_SURFACE_RECOVERY_SUMMARY_IMPLEMENTATION_REPORT_CURRENT.md) |
| 10c iOS profiles | [`DIR_DIVING_APNEA_IOS_PROFILES_PLANNER_DASHBOARD_IMPLEMENTATION_REPORT_CURRENT.md`](DIR_DIVING_APNEA_IOS_PROFILES_PLANNER_DASHBOARD_IMPLEMENTATION_REPORT_CURRENT.md) |
| 10d iOS logbook | [`DIR_DIVING_APNEA_IOS_LOGBOOK_GRAPHS_STATS_RECORDS_IMPLEMENTATION_REPORT_CURRENT.md`](DIR_DIVING_APNEA_IOS_LOGBOOK_GRAPHS_STATS_RECORDS_IMPLEMENTATION_REPORT_CURRENT.md) |
| 10e iOS map/export | [`DIR_DIVING_APNEA_IOS_MAP_EQUIPMENT_BUDDY_EXPORT_IMPLEMENTATION_REPORT_CURRENT.md`](DIR_DIVING_APNEA_IOS_MAP_EQUIPMENT_BUDDY_EXPORT_IMPLEMENTATION_REPORT_CURRENT.md) |
| 11 iOS↔Watch sync | [`DIR_DIVING_APNEA_IOS_WATCH_SYNC_OFFLINE_AUTONOMY_IMPLEMENTATION_REPORT_CURRENT.md`](DIR_DIVING_APNEA_IOS_WATCH_SYNC_OFFLINE_AUTONOMY_IMPLEMENTATION_REPORT_CURRENT.md) |

---

## Aggiornamento indice 2026-06-14 — Documentazione allineata (`DIR_DIVING_DOCUMENTATION_BRANCH_ALIGNMENT_REPORT.md`)

Pass **docs-only** su `main` @ `99ea74a`: README, INDEX, matrice CSV, branch strategy, release/TestFlight notes, cross-links audit/remediation V1.0. Nessun cambiamento a runtime MAIN o file experimental.

| Campo | Valore |
|-------|--------|
| **Report** | [`DIR_DIVING_DOCUMENTATION_BRANCH_ALIGNMENT_REPORT.md`](DIR_DIVING_DOCUMENTATION_BRANCH_ALIGNMENT_REPORT.md) |
| **Baseline codice** | `99ea74a` — deep-code remediation V1.0 MAIN-DCA-011…031 |
| **XCTest (sim)** | Watch **239** / iOS **832** passed @ `99ea74a` |
| **Verdict docs** | Architettura MAIN allineata; **physical QA ancora PENDING** |

---

## Aggiornamento indice 2026-06-14 — Deep code analysis remediation V1.0 (`MAIN_DEEP_CODE_ANALYSIS_REMEDIATION_REPORT_V1.0.md`)

Remediation **MAIN-DCA-011 … MAIN-DCA-031** (codice) @ `99ea74a`. Audit originale: [`MAIN_DEEP_CODE_ANALYSIS_BUG_PERFORMANCE_SECURITY_AUDIT_CURRENT.md`](MAIN_DEEP_CODE_ANALYSIS_BUG_PERFORMANCE_SECURITY_AUDIT_CURRENT.md) @ `7c79105` (report commit `009855e`).

| Campo | Valore |
|-------|--------|
| **Report fix** | [`MAIN_DEEP_CODE_ANALYSIS_REMEDIATION_REPORT_V1.0.md`](MAIN_DEEP_CODE_ANALYSIS_REMEDIATION_REPORT_V1.0.md) |
| **Prior pass** | [`MAIN_DEEP_CODE_ANALYSIS_REMEDIATION_REPORT.md`](MAIN_DEEP_CODE_ANALYSIS_REMEDIATION_REPORT.md) @ `0569903` (MAIN-DCA-001…018) |
| **Physical QA** | [`MAIN_PHYSICAL_EXTERNAL_QA_CHECKLIST.md`](MAIN_PHYSICAL_EXTERNAL_QA_CHECKLIST.md) — tutti **PENDING** |
| **Verdict release** | Sim/build/test verdi; **non** TestFlight/App Store senza QA fisica ed evidenza esterna |

---

## Aggiornamento indice 2026-06-14 — Deep code analysis audit (read-only @ `7c79105`)

Audit read-only post UI/UX remediation V1.0 @ `7c79105`; report commit `009855e`.

| Campo | Valore |
|-------|--------|
| **Documento** | [`MAIN_DEEP_CODE_ANALYSIS_BUG_PERFORMANCE_SECURITY_AUDIT_CURRENT.md`](MAIN_DEEP_CODE_ANALYSIS_BUG_PERFORMANCE_SECURITY_AUDIT_CURRENT.md) |
| **Issue count** | MAIN-DCA-001…031 (018 closed @ `0569903`; 011…031 in V1.0 remediation) |
| **Verdict** | V1.0 remediation @ `99ea74a` — internal code readiness 100%; external QA pending |

---

## Aggiornamento indice 2026-06-14 — UI/UX audit remediation V1.0 (`UI_UX_MAIN_AUDIT_REMEDIATION_REPORT_V1.0.md`)

Implementazione UI/UX MAIN @ `7c79105`. **Codice UI/UX: 100%** nel scope audit; QA device matrices ancora pending.

| Campo | Valore |
|-------|--------|
| **Documento** | [`UI_UX_MAIN_AUDIT_REMEDIATION_REPORT_V1.0.md`](UI_UX_MAIN_AUDIT_REMEDIATION_REPORT_V1.0.md) |
| **Prior pass** | [`UI_UX_MAIN_AUDIT_REMEDIATION_REPORT.md`](UI_UX_MAIN_AUDIT_REMEDIATION_REPORT.md) @ `dba1a22` |
| **Audit baseline** | [`UI_UX_MAIN_AUDIT_CURRENT.md`](UI_UX_MAIN_AUDIT_CURRENT.md) @ `b7b6e93` |
| **Verdict** | Code complete; device QA matrices open |

---

## Aggiornamento indice 2026-06-09 — Documentazione allineata (prior pass @ `0569903`)

Pass **docs-only** su `main` @ `0569903`: README, INDEX, matrice CSV, CCR reference docs, branch strategy. **Superseded for HEAD baseline** by 2026-06-14 report.

| Campo | Valore |
|-------|--------|
| **Report** | [`DIR_DIVING_DOCUMENTATION_BRANCH_ALIGNMENT_REPORT.md`](DIR_DIVING_DOCUMENTATION_BRANCH_ALIGNMENT_REPORT.md) (updated in place @ `99ea74a`) |
| **Baseline codice (storico)** | `0569903` — deep-code remediation MAIN-DCA-001…018 |
| **XCTest (sim)** | Watch **192** / iOS **561** passed @ `0569903` |

---

## Aggiornamento indice 2026-06-09 — Deep code analysis remediation (`MAIN_DEEP_CODE_ANALYSIS_REMEDIATION_REPORT.md`)

Remediation **MAIN-DCA-001 … MAIN-DCA-018** (codice) @ `0569903`. Audit originale: [`MAIN_DEEP_CODE_ANALYSIS_BUG_PERFORMANCE_SECURITY_AUDIT_CURRENT.md`](MAIN_DEEP_CODE_ANALYSIS_BUG_PERFORMANCE_SECURITY_AUDIT_CURRENT.md) @ `a2733d2` (baseline `dba1a22`).

| Campo | Valore |
|-------|--------|
| **Report fix** | [`MAIN_DEEP_CODE_ANALYSIS_REMEDIATION_REPORT.md`](MAIN_DEEP_CODE_ANALYSIS_REMEDIATION_REPORT.md) |
| **Threat model** | [`WATCH_SYNC_SECURITY_THREAT_MODEL.md`](WATCH_SYNC_SECURITY_THREAT_MODEL.md) |
| **Physical QA** | [`MAIN_PHYSICAL_EXTERNAL_QA_CHECKLIST.md`](MAIN_PHYSICAL_EXTERNAL_QA_CHECKLIST.md) — tutti **PENDING** |
| **Verdict release** | Sim/build/test verdi; **non** TestFlight/App Store senza QA fisica ed evidenza esterna |

---

## Aggiornamento indice 2026-06-09 — Deep code analysis audit (read-only)

Audit read-only post UI/UX remediation @ `dba1a22`.

| Campo | Valore |
|-------|--------|
| **Documento** | [`MAIN_DEEP_CODE_ANALYSIS_BUG_PERFORMANCE_SECURITY_AUDIT_CURRENT.md`](MAIN_DEEP_CODE_ANALYSIS_BUG_PERFORMANCE_SECURITY_AUDIT_CURRENT.md) |
| **Commit report** | `a2733d2` |
| **Issue count** | MAIN-DCA-001…018 |
| **Verdict** | Remediation required before external release claims |

---

## Aggiornamento indice 2026-06-09 — UI/UX audit remediation (`UI_UX_MAIN_AUDIT_REMEDIATION_REPORT.md`)

Implementazione UI/UX MAIN @ `dba1a22` (localization, a11y, CCR checklist import, sync badge, locale dates). **Codice UI/UX: 100%** nel scope audit; QA device matrices ancora pending.

| Campo | Valore |
|-------|--------|
| **Documento** | [`UI_UX_MAIN_AUDIT_REMEDIATION_REPORT.md`](UI_UX_MAIN_AUDIT_REMEDIATION_REPORT.md) |
| **Audit baseline** | [`UI_UX_MAIN_AUDIT_CURRENT.md`](UI_UX_MAIN_AUDIT_CURRENT.md) @ `b7b6e93` |
| **Verdict** | Code complete; device QA matrices open |

---

## Aggiornamento indice 2026-06-09 — UI/UX audit (read-only)

Audit read-only MAIN UI/UX accessibility and release readiness @ `b7b6e93`.

| Campo | Valore |
|-------|--------|
| **Documento** | [`UI_UX_MAIN_AUDIT_CURRENT.md`](UI_UX_MAIN_AUDIT_CURRENT.md) |
| **Overall UX** | 88% pre-remediation |
| **Verdict** | Remediation plan executed @ `dba1a22` |

---

## Aggiornamento indice 2026-06-07 — iOS MAIN post-audit non-physical fixes

Residual gaps from [`IOS_MAIN_ALGORITHM_MATH_AUDIT_CURRENT.md`](IOS_MAIN_ALGORITHM_MATH_AUDIT_CURRENT.md) @ audit baseline `32f8d3e`, audit re-run @ `af31937`.

| Campo | Valore |
|-------|--------|
| **Report** | [`IOS_MAIN_ALGORITHM_MATH_POST_AUDIT_FIX_REPORT_CURRENT.md`](IOS_MAIN_ALGORITHM_MATH_POST_AUDIT_FIX_REPORT_CURRENT.md) |
| **Audit baseline** | `32f8d3e` |
| **Tests added** | Briefing PDF, manual dive logic, Ratio Deco MOD, Watch depth alarm, reminder hiddenCount, photo pipeline, localization sweep |
| **Physical / external QA** | **PENDING** |

---

## Aggiornamento indice 2026-06-07 — iOS MAIN algorithm math remediation

Remediation **P1–P4** from [`IOS_MAIN_ALGORITHM_MATH_AUDIT_CURRENT.md`](IOS_MAIN_ALGORITHM_MATH_AUDIT_CURRENT.md). **455** iOS algorithm XCTest passed @ iPhone 17 Pro sim; Watch algorithm tests green @ Ultra 3 sim.

| Campo | Valore |
|-------|--------|
| **Audit** | [`IOS_MAIN_ALGORITHM_MATH_AUDIT_CURRENT.md`](IOS_MAIN_ALGORITHM_MATH_AUDIT_CURRENT.md) |
| **Remediation report** | [`IOS_MAIN_ALGORITHM_MATH_REMEDIATION_REPORT_CURRENT.md`](IOS_MAIN_ALGORITHM_MATH_REMEDIATION_REPORT_CURRENT.md) |
| **Ratio Deco user doc** | [`RATIO_DECO_COMPARATIVE_HEURISTIC.md`](RATIO_DECO_COMPARATIVE_HEURISTIC.md) |
| **Bühlmann** | Primary decompression engine (unchanged math) |
| **Ratio Deco** | Comparative heuristic only |
| **Physical / external QA** | **PENDING** — [`MAIN_PHYSICAL_EXTERNAL_QA_CHECKLIST.md`](MAIN_PHYSICAL_EXTERNAL_QA_CHECKLIST.md) |

---

## Aggiornamento indice 2026-06-07 — Documentazione allineata (`DIR_DIVING_DOCUMENTATION_BRANCH_ALIGNMENT_REPORT.md`)

Pass **docs-only** su `main` @ `a69bc4b`: README, INDEX, matrice CSV, branch strategy, audit cross-links, release/TestFlight notes. Nessun cambiamento a runtime MAIN o file experimental.

| Campo | Valore |
|-------|--------|
| **Report** | [`DIR_DIVING_DOCUMENTATION_BRANCH_ALIGNMENT_REPORT.md`](DIR_DIVING_DOCUMENTATION_BRANCH_ALIGNMENT_REPORT.md) |
| **Baseline codice** | `a69bc4b` — deep-code remediation + UI/UX @ `8c7d6e6` |
| **XCTest (sim)** | Watch **171** / iOS **415** passed @ `a69bc4b` |
| **Verdict docs** | Architettura MAIN allineata; **physical QA ancora PENDING** |

---

## Aggiornamento indice 2026-06-07 — Deep code remediation (`MAIN_DEEP_CODE_ANALYSIS_REMEDIATION_REPORT_CURRENT.md`)

Remediation **MAIN-AUD-001 … MAIN-AUD-016** (codice) @ `a69bc4b`. Audit originale: [`MAIN_DEEP_CODE_ANALYSIS_BUG_PERFORMANCE_SECURITY_AUDIT_CURRENT.md`](MAIN_DEEP_CODE_ANALYSIS_BUG_PERFORMANCE_SECURITY_AUDIT_CURRENT.md) @ `4a80c54` (**storico** — issue list pre-fix).

| Campo | Valore |
|-------|--------|
| **Report fix** | [`MAIN_DEEP_CODE_ANALYSIS_REMEDIATION_REPORT_CURRENT.md`](MAIN_DEEP_CODE_ANALYSIS_REMEDIATION_REPORT_CURRENT.md) |
| **Physical QA** | [`MAIN_PHYSICAL_EXTERNAL_QA_CHECKLIST.md`](MAIN_PHYSICAL_EXTERNAL_QA_CHECKLIST.md) — tutti **PENDING** |
| **Verdict release** | Sim/build/test verdi; **non** TestFlight/App Store senza QA fisica ed evidenza esterna Bühlmann |

| Documento correlato | Ruolo |
|---|---|
| [`MAIN_DEEP_CODE_ANALYSIS_BUG_PERFORMANCE_SECURITY_AUDIT_CURRENT.md`](MAIN_DEEP_CODE_ANALYSIS_BUG_PERFORMANCE_SECURITY_AUDIT_CURRENT.md) | Audit pre-remediation (riferimento storico) |
| [`DIR_DIVING_UI_UX_READINESS_CODE_100_COMPLETION_REPORT.md`](DIR_DIVING_UI_UX_READINESS_CODE_100_COMPLETION_REPORT.md) | UI/UX code 100% @ `8c7d6e6` |

---

## Aggiornamento indice 2026-06-07 — UI/UX code 100% (`DIR_DIVING_UI_UX_READINESS_CODE_100_COMPLETION_REPORT.md`)

Implementazione UI/UX MAIN @ `8c7d6e6` (localization, a11y, typography, banner policy, planner/logbook fixes). **Codice UI/UX: 100%** nel scope audit UI; QA device matrices ancora pending.

| Campo | Valore |
|-------|--------|
| **Documento** | [`DIR_DIVING_UI_UX_READINESS_CODE_100_COMPLETION_REPORT.md`](DIR_DIVING_UI_UX_READINESS_CODE_100_COMPLETION_REPORT.md) |
| **Commit** | `8c7d6e6` |
| **Verdict** | Code complete; device QA matrices open |

---

## Aggiornamento indice 2026-06-07 — UI/UX readiness audit (`DIR_DIVING_UI_UX_READINESS_AUDIT_CURRENT.md`)

Audit read-only post-implementazione **Apple Watch MAIN + iOS Companion MAIN** @ `c5d48b4`.

| Campo | Valore |
|-------|--------|
| **Documento** | [`DIR_DIVING_UI_UX_READINESS_AUDIT_CURRENT.md`](DIR_DIVING_UI_UX_READINESS_AUDIT_CURRENT.md) |
| **Watch readiness** | 82% |
| **iOS readiness** | 84% |
| **Overall UI/UX** | 83% |
| **Verdict** | Ready for broader internal testing; P1 localization/a11y/device fullscreen QA open |

Top blockers: iOS legal onboarding EN-only; Watch hardcoded IT log strings; iOS fullscreen not device-verified; logbook swipe-delete pattern.

---

## Aggiornamento indice 2026-06-07 — Watch MAIN audit remediation (P1–P3)

Implementazione completa issue aperte da [`DIR_DIVING_WATCH_ALGORITHM_MATH_AUDIT.md`](DIR_DIVING_WATCH_ALGORITHM_MATH_AUDIT.md) su **Apple Watch MAIN** only.

| Campo | Valore |
|-------|--------|
| **Report** | [`WATCH_MAIN_ALGORITHM_MATH_AUDIT_FIX_COMPLETION_REPORT.md`](WATCH_MAIN_ALGORITHM_MATH_AUDIT_FIX_COMPLETION_REPORT.md) |
| **Baseline pre-fix** | `4b73954` |
| **Target** | `DIRDiving Watch App` |
| **XCTest** | **161** passed, 8 skipped, 0 failures (Apple Watch Ultra 3 sim) |
| **Verdict** | **READY FOR INTERNAL TESTFLIGHT** (physical QA still required for external gate) |

**P1:** sync pending queue signed-ACK dequeue; mock/simulation sensor visibility; TestFlight simulation safeguards; ascent haptic coordinator tests.  
**P2:** persistence errors, draft avg-depth tail cap, auto-end/sync/App Intent/haptic/GPS tests, photo trust doc, deterministic ID retention.  
**P3:** 40 m band docs, double classify removed, expired draft quarantine, DepthSafetySelfCheck in CI, CSV call-path doc.

| Documento | Ruolo |
|---|---|
| [`WATCH_MAIN_ALGORITHM_MATH_AUDIT_FIX_COMPLETION_REPORT.md`](WATCH_MAIN_ALGORITHM_MATH_AUDIT_FIX_COMPLETION_REPORT.md) | Report finale remediation |
| [`WATCH_TESTFLIGHT_SENSOR_SOURCE_QA.md`](WATCH_TESTFLIGHT_SENSOR_SOURCE_QA.md) | QA TestFlight simulation |
| [`WATCH_SENSOR_SOURCE_RELEASE_POLICY.md`](WATCH_SENSOR_SOURCE_RELEASE_POLICY.md) | Policy release/simulation |
| [`WATCH_IOS_SYNC_QA_MATRIX.md`](WATCH_IOS_SYNC_QA_MATRIX.md) | Matrice sync pending queue |

---

## Aggiornamento indice 2026-06-07 — Watch MAIN algorithm audit refresh (`DIR_DIVING_WATCH_ALGORITHM_MATH_AUDIT.md`)

Audit read-only completo **Apple Watch MAIN** (`DIRDiving Watch App` only) @ baseline `c314b93`. Supersedes audit root 2026-05-27 e snapshot parallelo [`WATCH_MAIN_ALGORITHM_MATH_AUDIT_CURRENT.md`](WATCH_MAIN_ALGORITHM_MATH_AUDIT_CURRENT.md) @ `5415213`.

| Campo | Valore |
|-------|--------|
| **Documento** | [`DIR_DIVING_WATCH_ALGORITHM_MATH_AUDIT.md`](DIR_DIVING_WATCH_ALGORITHM_MATH_AUDIT.md) |
| **Baseline codice** | `c314b93` |
| **Target** | `DIRDiving Watch App` (MAIN only) |
| **XCTest** | **135** passed, 3 skipped, 0 failures (Apple Watch Ultra 3 sim) |
| **P0** | 0 |
| **Verdict** | **READY FOR INTERNAL WATCH MAIN ALGORITHM VALIDATION**; external TestFlight/App Store blocked on physical QA + P1 sync/haptic gaps |

| Area readiness | Stima |
|---|---:|
| Algorithm | 94% |
| Math robustness | 95% |
| Safety algorithms | 91% |
| Runtime / lifecycle | 93% |
| Sync / data | 90% |

---

## Aggiornamento indice 2026-06-07 — Bühlmann hardening + canonical consistency @ `74035fd`

Pass di verifica iOS Companion MAIN (solo test + docs; **nessuna modifica math Bühlmann**):

| Campo | Valore |
|-------|--------|
| **Commit** | `74035fd` (`test(ios): harden Bühlmann canonical consistency and refresh docs`) |
| **Baseline precedente** | `829babe` (audit P1–P3 remediation) |
| **Target** | `DIRDiving iOS` (MAIN only) |
| **XCTest** | **387** passed, 5 skipped, 0 failures (iPhone 17 sim) |
| **Nuovo suite** | `BuhlmannEngineCanonicalConsistencyTests.swift` (5 test) |
| **Verdict** | **READY FOR INTERNAL VALIDATION** |

| Documento | Aggiornamento |
|-----------|---------------|
| [`DIR_DIVING_IOS_BUHLMANN_IMPLEMENTATION_COMPLETION_REPORT.md`](DIR_DIVING_IOS_BUHLMANN_IMPLEMENTATION_COMPLETION_REPORT.md) | Report completo + build/test evidence |
| [`DIR_DIVING_IOS_BUHLMANN_MATH_VERIFICATION.md`](DIR_DIVING_IOS_BUHLMANN_MATH_VERIFICATION.md) | §13 canonical engine consistency |
| [`DIR_DIVING_IOS_BUHLMANN_VALIDATION_FIXTURES.md`](DIR_DIVING_IOS_BUHLMANN_VALIDATION_FIXTURES.md) | Riga suite canonical consistency |
| [`IOS_MAIN_ALGORITHM_MATH_AUDIT_FIX_COMPLETION_REPORT.md`](IOS_MAIN_ALGORITHM_MATH_AUDIT_FIX_COMPLETION_REPORT.md) | Remediation P1–P3 @ `829babe` |

---

## Aggiornamento indice 2026-06-07 — iOS MAIN algorithm audit (`IOS_MAIN_ALGORITHM_MATH_AUDIT_CURRENT.md`)

Audit read-only **iOS Companion MAIN** (`DIRDiving iOS` only), post-P2/P3 Bühlmann planner fixes @ `81f2d7f`. Documento indicizzato su `main` @ commit `c723295`. Supersedes revisione @ `ecad0d9` (2026-06-05).

| Campo | Valore |
|-------|--------|
| **Documento** | [`IOS_MAIN_ALGORITHM_MATH_AUDIT_CURRENT.md`](IOS_MAIN_ALGORITHM_MATH_AUDIT_CURRENT.md) |
| **Percorso** | `Docs/IOS_MAIN_ALGORITHM_MATH_AUDIT_CURRENT.md` |
| **Commit indicizzazione** | `c723295` (`docs(ios): refresh MAIN algorithm math audit at 81f2d7f`) |
| **Baseline codice auditata** | `81f2d7f` |
| **Data audit** | 2026-06-07 |
| **Target** | `DIRDiving iOS` (MAIN only) |
| **Modalità** | Read-only + macOS build/test |
| **XCTest** | 363 passed, 5 skipped, 0 failures (iPhone 17 sim) |

### Readiness (executive summary §A)

| Area | Stima | Note |
|------|------:|------|
| Mathematical robustness | **92%** | Core Bühlmann + exposure sound |
| Planner three-mode | **90%** | Projection reale; engine condiviso |
| Bühlmann ZHL-16C | **94%** | Tissue history post-plan |
| Automated tests | **94%** | 363 XCTest pass |

### Severity (§L)

| Priority | Count | Blocker principale |
|----------|------:|-------------------|
| P0 | 0 | — |
| P1 | 2 | External Bühlmann validation campaign |
| P2 | 7 | Cloud merge, weekly OTU UI, integration tests |
| P3 | 5 | README baseline drift, doc supersession |

### Mappa sezioni report

| § | Titolo | Contenuto chiave |
|---|--------|------------------|
| A | Executive Summary | Readiness, severity, blockers TestFlight/App Store |
| B | Algorithm Inventory | Bühlmann, gas, CNS/OTU, logbook, sync, CSV |
| C | Planner Mode Audit | Base / Deco / Technical — projection, validation, UI gating |
| D | Findings by Family | Issue IDs per famiglia algoritmica |
| E | Edge Case Matrix | Bound, NaN, empty, mode switch |
| F–K | Test plans | Unit, mode regression, Watch pair, CSV, cloud, boundaries |
| L | Prioritized Roadmap | HIGH → LOW remediation order |
| U | Final Verdict | Internal validation ready; external TestFlight/App Store not yet |
| Appendix | Build evidence | `DIRDiving iOS Algorithm Tests` @ `81f2d7f` — 363 pass |

### Documenti correlati

| Documento | Relazione |
|-----------|-----------|
| [`IOS_MAIN_ALGORITHM_MATH_AUDIT_CURRENT.md`](IOS_MAIN_ALGORITHM_MATH_AUDIT_CURRENT.md) | **Audit corrente** (questo file) |
| [`IOS_MAIN_ALGORITHM_MATH_AUDIT_REMEDIATION_REPORT.md`](IOS_MAIN_ALGORITHM_MATH_AUDIT_REMEDIATION_REPORT.md) | Remediation IOS-AUDIT-001…012 @ 2026-06-03 |
| [`IOS_MAIN_ALGORITHM_READINESS_100_REPORT.md`](IOS_MAIN_ALGORITHM_READINESS_100_REPORT.md) | Remediation storica pre three-tab @ `dce89e7` |
| [`IOS_MAIN_ALGORITHM_READINESS_100_FINAL_QA.md`](IOS_MAIN_ALGORITHM_READINESS_100_FINAL_QA.md) | QA matrix post-remediation |
| [`DIR_DIVING_IOS_PLANNER_LIMITATIONS.md`](DIR_DIVING_IOS_PLANNER_LIMITATIONS.md) | Limitazioni reference-only |
| [`DIR_DIVING_IOS_PLANNER_DECO_TABLE_BUHLMANN_CURVE_AUDIT_CURRENT.md`](DIR_DIVING_IOS_PLANNER_DECO_TABLE_BUHLMANN_CURVE_AUDIT_CURRENT.md) | Audit UI deco table / curva Bühlmann @ 2026-06-06 |
| [`DIR_DIVING_IOS_ALGORITHM_MATH_AUDIT.md`](DIR_DIVING_IOS_ALGORITHM_MATH_AUDIT.md) | Audit post-hardening storico |
| [`WATCH_MAIN_ALGORITHM_MATH_AUDIT_CURRENT.md`](WATCH_MAIN_ALGORITHM_MATH_AUDIT_CURRENT.md) | Audit parallelo Watch MAIN |


## Aggiornamento indice 2026-06-05 — sync rami experimental

Aggiornamento **solo documentazione** per registrare che i rami experimental sono stati verificati sui rispettivi ultimi remote e fast-forwardati prima delle modifiche docs.

| Campo | Valore |
|-------|--------|
| **Report** | [`EXPERIMENTAL_BRANCH_SYNC_REPORT_20260605.md`](EXPERIMENTAL_BRANCH_SYNC_REPORT_20260605.md) |
| **MAIN verificato** | `origin/main` @ `5fd821b` |
| **Watch/iOS experimental** | `origin/codex/experimental-features` (merged `origin/main`) |
| **iOS-named experimental** | `origin/codex/ios-experimental-features` (merged `origin/main`) |
| **Scope** | Apnea + Snorkeling experimental; Buddy/BLE resta lab-only |
| **Tipo modifica** | Docs-only; nessuna modifica runtime |

Nota: `codex/experimental-features` resta il ramo experimental combinato canonico; `codex/ios-experimental-features` resta allineato per i path app/progetto ma conserva i documenti specifici iOS.

---

**Esclusi da scope audit iOS:** file experimental in `project.yml` (`Exploration*`, `BuddyExperimental*`, …). Apple Watch runtime fuori scope salvo modelli/codec condivisi.

---

## Aggiornamento indice 2026-06-06 — Watch MAIN algorithm remediation @ `36a4d9f`

Remediation codice/test Watch MAIN da audit @ `5415213` (120 XCTest pass, 0 failures):

| Documento | Posizione | Contenuto |
|-----------|-----------|-----------|
| [`WATCH_MAIN_ALGORITHM_MATH_AUDIT_REMEDIATION_REPORT.md`](WATCH_MAIN_ALGORITHM_MATH_AUDIT_REMEDIATION_REPORT.md) | `Docs/` | **Report remediation** — WATCH-TEST-001…SYNC-001; ~97–98% readiness escl. QA fisica |
| [`WATCH_MAIN_HARDWARE_ALGORITHM_QA_CHECKLIST.md`](WATCH_MAIN_HARDWARE_ALGORITHM_QA_CHECKLIST.md) | `Docs/` | Checklist QA hardware Watch Ultra |
| [`WATCH_CSV_EXPORT_POLICY.md`](WATCH_CSV_EXPORT_POLICY.md) | `Docs/` | Policy export CSV allineata iOS |

---

## Aggiornamento indice 2026-06-05 — UI/UX readiness 100% plan (Watch + iOS)

Piano operativo per portare **Apple Watch MAIN** e **iOS Companion MAIN** da readiness stimata ~90% / ~84% a **100%** UI/UX (codice + QA manuale ripetibile). Complementa l’audit statico [`DIR_DIVING_FULL_UI_UX_AUDIT_CURRENT.md`](DIR_DIVING_FULL_UI_UX_AUDIT_CURRENT.md) @ `bdd3a43` con roadmap per fase, backlog prioritizzato e matrice QA screenshot/device.

| Campo | Valore |
|-------|--------|
| **Piano** | [`DIR_DIVING_UI_UX_READINESS_100_PLAN_CURRENT.md`](DIR_DIVING_UI_UX_READINESS_100_PLAN_CURRENT.md) |
| **Percorso** | `Docs/DIR_DIVING_UI_UX_READINESS_100_PLAN_CURRENT.md` |
| **Commit** | `e47c860` (`Create DIR_DIVING_UI_UX_READINESS_100_PLAN_CURRENT.md`) |
| **Data piano** | 2026-06-05 |
| **Branch** | `main` |
| **Scope** | Watch app + iOS Companion (MAIN only) |
| **Target** | 100% UI/UX readiness |
| **Audit correlato** | [`DIR_DIVING_FULL_UI_UX_AUDIT_CURRENT.md`](DIR_DIVING_FULL_UI_UX_AUDIT_CURRENT.md) — Watch 79% / iOS 76% @ `bdd3a43` (report-only) |

### Readiness stimata (executive summary §1)

| App | Attuale | Target | Blocker principale |
|-----|--------:|-------:|--------------------|
| Apple Watch | 90% | 100% | QA dispositivo reale, densità Settings, Compass, accessibilità |
| iOS Companion | 84% | 100% | Layout fullscreen/adaptive, polish Planner result, chart/table |
| Design system condiviso | 86% | 100% | Allineamento token, documentazione componenti, screenshot QA |

### Top 5 priorità (§1)

1. Fix layout fullscreen/adaptive iOS (iPhone 14+ — bande nere).
2. Polish schermata risultato Planner (dashboard, tabella risalita, curva Bühlmann).
3. Validazione Watch Settings, Compass, warning e Mission Mode su dispositivo reale.
4. Allineamento `DiveUI` (Watch) ↔ `DIRTheme` (iOS).
5. Matrice QA ripetibile (screenshot, device, Dynamic Type).

### Mappa sezioni piano

| § | Titolo | Contenuto chiave |
|---|--------|------------------|
| 1 | Executive summary | Readiness attuale, blocker, top 5 |
| 2 | Watch — current state | Punti di forza + gap W-P1/P2 |
| 3 | iOS — current state | Punti di forza + gap I-P0/P1/P2 |
| 4 | Watch plan → 100% | Fasi W1–W4 (94% → 97% → 99% → 100%) |
| 5 | iOS plan → 100% | Fasi I1–I4 (90% → 95% → 98% → 100%) |
| 6 | Shared design system | S1 token, S2 componenti, S3 screenshot QA |
| 7 | Backlog Watch | W-01…W-07 (P1–P3) |
| 8 | Backlog iOS | I-01…I-08 (P0–P2) |
| 9 | Validation commands | `xcodebuild` Watch Ultra 2 + iPhone 14/15/17 Pro |
| 10 | Manual QA matrix | Scenari Watch + iOS (fullscreen, Planner tabs, VoiceOver) |
| 11 | Final verdict | Percorso più rapido verso 100% |

### Fasi implementative — Apple Watch (§4)

| Fase | Target | Focus |
|------|--------|--------|
| **W1** | 94% | Compass cardinals, Settings readability, warning stress |
| **W2** | 97% | Settings density, Crown hint, bearing flow |
| **W3** | 99% | Images captions, logbook hierarchy, export states |
| **W4** | 100% | VoiceOver, Dynamic Type, l10n, Reduced Motion |

**File principali Watch:** `CompassView.swift`, `SettingsView.swift`, `DiveLiveView.swift`, `AscentWarningBannerView.swift`, `DepthSafetyLiveViews.swift`, `DiveUIComponents.swift`.

### Fasi implementative — iOS Companion (§5)

| Fase | Target | Focus |
|------|--------|--------|
| **I1** | 90% | Edge-to-edge root (`ContentView`, `DIRScreenContainer`, adaptive layout) |
| **I2** | 95% | `PlanResultView`, ascent table, Bühlmann `tissueHistory.groupedPoints` |
| **I3** | 98% | Logbook, Analysis, Equipment GAS/BAR/PSI, More |
| **I4** | 100% | VoiceOver chart/table, Dynamic Type, contrasto, l10n |

**File principali iOS:** `PlannerView.swift`, `BuhlmannTissueHistory.swift`, `PlannerAscentTableBuilder.swift`, `IOSCompanionAdaptiveLayout.swift`, `IOSWindowChromeConfigurator.swift`.

### Backlog prioritizzato (estratto §7–§8)

| ID | P | App | Area | Azione |
|----|---|-----|------|--------|
| I-01 | P0 | iOS | Root layout | Eliminare bande nere top/bottom |
| W-01 | P1 | Watch | Compass | Validare/fix rotazione cardinali N/E/S/W |
| W-02 | P1 | Watch | Settings | Ridurre densità; diagnostics in subpage |
| I-02 | P1 | iOS | Planner result | Gerarchia dashboard |
| I-03 | P1 | iOS | Bühlmann chart | Tab/legend/assi leggibili |
| I-04 | P1 | iOS | Ascent table | Layout premium colonne Prof/Tempo/Gas/PPO₂ |
| W-06 / I-08 | P2 | Both | Accessibility | VoiceOver + Dynamic Type |

### Documenti correlati

| Documento | Relazione |
|-----------|-----------|
| [`DIR_DIVING_FULL_UI_UX_AUDIT_CURRENT.md`](DIR_DIVING_FULL_UI_UX_AUDIT_CURRENT.md) | Audit read-only pre-piano @ `bdd3a43` |
| [`DIR_DIVING_WATCH_UI_TEXT_VISIBILITY_AUDIT_CURRENT.md`](DIR_DIVING_WATCH_UI_TEXT_VISIBILITY_AUDIT_CURRENT.md) | Audit testo Watch @ 78% (2026-06-04) |
| [`DIR_DIVING_WATCH_COMPASS_CARDINAL_ROTATION_BUG_REPORT_CURRENT.md`](DIR_DIVING_WATCH_COMPASS_CARDINAL_ROTATION_BUG_REPORT_CURRENT.md) | Bug report Compass → fase W1 |
| [`MAIN_UI_UX_READINESS_AUDIT_POST_FIX.md`](MAIN_UI_UX_READINESS_AUDIT_POST_FIX.md) | Remediation UX storica (baseline pre-audit corrente) |
| [`WATCH_MAIN_UX_CONVENTIONS.md`](WATCH_MAIN_UX_CONVENTIONS.md) | Convenzioni UX Watch MAIN |
| [`UI_UX_VISUAL_GUIDELINES.md`](UI_UX_VISUAL_GUIDELINES.md) | Linee guida visive condivise |
| [`DIR_DIVING_IOS_PLANNER_DECO_TABLE_BUHLMANN_CURVE_FIX_REPORT.md`](DIR_DIVING_IOS_PLANNER_DECO_TABLE_BUHLMANN_CURVE_FIX_REPORT.md) | Fix algoritmo/UI Planner @ `bea4f74` (input per fase I2) |

**Percorso consigliato:** audit → piano → **implementazione** [`DIR_DIVING_UI_UX_READINESS_100_IMPLEMENTATION_REPORT_CURRENT.md`](DIR_DIVING_UI_UX_READINESS_100_IMPLEMENTATION_REPORT_CURRENT.md) → design system [`DIR_DIVING_UI_DESIGN_SYSTEM_CURRENT.md`](DIR_DIVING_UI_DESIGN_SYSTEM_CURRENT.md) → §10 QA matrix fisica.

---

## Aggiornamento indice 2026-06-06 — iOS Planner tabs (Base / Deco / Tecnico) + audit deco/Bühlmann

Piano implementativo per i **tre tab modalità** del Planner iOS (non i tab risultato PIANO / CURVA BÜHLMANN / GRAFICI) e audit statico tabella risalita + curva Bühlmann vs screenshot di riferimento.

| Campo | Valore |
|-------|--------|
| **Piano implementazione** | [`DIR_Diving_Planner_Tabs_Implementation_Plan.md`](DIR_Diving_Planner_Tabs_Implementation_Plan.md) |
| **Percorso** | `Docs/DIR_Diving_Planner_Tabs_Implementation_Plan.md` |
| **Commit** | `25e12d9` (`Create DIR_Diving_Planner_Tabs_Implementation_Plan.md`) |
| **Baseline** | `main` @ `c3d1164` (audit) → `25e12d9` (piano) |
| **Scope** | iOS Companion MAIN — `PlannerView`, `PlanResultView`, `PlannerMode`, gas/Bühlmann, export, test |
| **Modalità piano** | Plan-only — un motore, tre livelli di esposizione UI (Base monogas / Deco fondo+1 deco / Tecnico multigas) |
| **Audit correlato** | [`DIR_DIVING_IOS_PLANNER_DECO_TABLE_BUHLMANN_CURVE_AUDIT_CURRENT.md`](DIR_DIVING_IOS_PLANNER_DECO_TABLE_BUHLMANN_CURVE_AUDIT_CURRENT.md) @ `c3d1164` |

### Obiettivo piano (executive)

| Modalità | Ruolo |
|----------|--------|
| **Base** | Planner ricreativo monogas; output semplice; curva Bühlmann nascosta o minimale |
| **Deco** | Fondo + max 1 deco gas; validazioni MOD/PPO₂; Bühlmann semplificato |
| **Tecnico** | Multigas completo (travel, deco multipli, bailout, GF); curva compartimenti; colloca il Planner attuale |

**Principio:** un solo `BuhlmannEngine` + `PlannerService`; tre preset via `PlannerMode` reducer — **non** tre algoritmi separati.

### Mappa sezioni piano

| § | Titolo | Contenuto chiave |
|---|--------|------------------|
| 1–3 | Obiettivo, architettura, nomenclatura | Base/Deco/Tecnico vs Semplice/Avanzato/Tecnico legacy |
| 4 | Planner Base | Input, gas, validazioni, output, grafici |
| 5 | Planner Deco | GF, 1 deco gas, curva semplificata |
| 6 | Planner Tecnico | Multigas, bailout, curva compartimenti completa |
| 7–8 | Modello dati + UI | `PlannerInput`, mode reducer, `PlannerView` |
| 9 | `PlanResultView` | Result differenziati per modalità |
| 10 | Curva Bühlmann | Visibilità/complessità per modalità; requisito non decorativo |
| 11–12 | Safety copy + export | Disclaimer per modalità; share mode-aware |
| 13–14 | Test + priorità | Fasi 1–6 implementative |
| 15–17 | File coinvolti, acceptance, raccomandazione | `PlannerView.swift`, `PlannerStore`, l10n, XCTest |

### Audit deco table / curva Bühlmann (stato attuale @ `c3d1164`)

| Elemento | Verdetto audit |
|----------|----------------|
| Tab risultato PIANO / CURVA BÜHLMANN / GRAFICI | **Presenti** (IT localized) |
| Tabella PIANO DI RISALITA (Prof / Tempo / Gas / PPO₂) | **Sì** — dati reali `decoStops`; manca riga fondo come nel mock |
| Curva ZHL-L16C % vs tempo (compartimenti 1–4 … 13–16) | **No** — chart attuale = NDL vs profondità; serve estensione output algoritmo |
| Match screenshot reference | **Partial** |

**Implementazione consigliata:** seguire piano §10.4 (tissue history) + fasi 4–5 del piano tab modalità.

---

## Aggiornamento indice 2026-06-06 — allineamento documentazione MAIN

> **Superseded for HEAD:** [`DIR_DIVING_DOCUMENTATION_BRANCH_ALIGNMENT_REPORT.md`](DIR_DIVING_DOCUMENTATION_BRANCH_ALIGNMENT_REPORT.md) @ `a69bc4b` (2026-06-07).

Pass **solo documentazione** (nessuna modifica runtime). Backup: `backup/docs-alignment-20260606`.

| Campo | Valore |
|-------|--------|
| **Report principale** | [`DOCUMENTATION_BRANCH_ALIGNMENT_20260606.md`](DOCUMENTATION_BRANCH_ALIGNMENT_20260606.md) |
| **Changelog doc** | [`DOCUMENTATION_UPDATE_REPORT_20260606.md`](DOCUMENTATION_UPDATE_REPORT_20260606.md) |
| **PR snapshot** | [`PR_STATUS_20260606.md`](PR_STATUS_20260606.md) |
| **Baseline runtime** | `main` @ `90dc3f5` |
| **Root README** | [`../README.md`](../README.md) → punta a [`README.md`](README.md) |

**Architettura MAIN documentata:** Diving Watch + iOS Companion, onboarding legale, depth discouragement 35/38/40 m, banner risalita inline, GPS overlay compatto, **BUSSOLA**, sync/tombstone, App Intents / Action Button via Shortcuts, foto iPhone→Watch con ACK e gestione da iOS, Bühlmann indicative (iOS planner).

**Experimental isolato:** Snorkeling, Apnea, Buddy Assist su `codex/experimental-features` e `codex/ios-experimental-features` — non target MAIN (`project.yml`).

---

## Aggiornamento indice 2026-06-05 — Watch photo transfer audit (iOS → Watch)

Audit statico sul percorso **invio foto iPhone → Apple Watch** (`PhotosPicker` → `WatchPhotoPreprocessor` → `WCSession.transferFile` → `UserImageStore` → `UserImagesView`). Nessuna modifica codice nel report; QA runtime richiede macOS + coppia iPhone/Watch o simulatori.

| Campo | Valore |
|-------|--------|
| **Documento** | [`DIRDIVING_WATCH_PHOTO_TRANSFER_AUDIT_REPORT_20260605.md`](DIRDIVING_WATCH_PHOTO_TRANSFER_AUDIT_REPORT_20260605.md) |
| **Percorso** | `Docs/DIRDIVING_WATCH_PHOTO_TRANSFER_AUDIT_REPORT_20260605.md` |
| **Data audit** | 2026-06-05 |
| **Branch / commit auditato** | `main` @ `ca76a19` |
| **Modalità** | Static audit, report-only |
| **Verdetto** | Architettura core **corretta**; gap UX remediation **implementata** @ `fc311be`/`90dc3f5` — QA device pair ancora richiesta |
| **File chiave** | `WatchPhotoTransferPanel.swift`, `WatchPhotoPreprocessor.swift`, `WatchSyncService.swift` (iOS), `UserImageStore.swift`, `UserImagesView.swift`, `WatchCompanionPhotoValidator.swift` |

### Issues (Executive Summary)

| ID | Sev | Titolo |
|----|-----|--------|
| 1 | Medium | iOS segnala successo prima della prova di ricezione Watch |
| 2 | Medium | Nessun acknowledgement Watch → iOS post-import foto |
| 3 | Medium | `WCSessionFileTransfer` completion non tracciata su iOS |
| 4 | Low | Possibile collisione filename `companion_<timestamp>.jpg` |
| 5 | Low | Layout galleria Watch da verificare su 41 / 45 / 49 mm |

### Piano remediation (fasi report)

| Fase | Obiettivo |
|------|-----------|
| 1 | Acknowledgement import foto Watch → iOS |
| 2 | Stati transfer file su iOS (queued / delivered / failed) |
| 3 | Filename UUID al posto del timestamp |
| 4 | Messaggi iOS distinti (queued vs received) |
| 5 | Polish UX galleria Watch (`UserImagesView`, page dots, highlight nuova foto) |
| 6 | Test mirati preprocessor / validator / import |
| 7 | QA macOS/device (JPEG, PNG, HEIC, panorama, connettività) |

**Release recommendation:** feature **directionally correct**; non dichiarare fully verified senza QA device/simulator.

### Implementazione remediation (2026-06-05)

| Campo | Valore |
|-------|--------|
| **Documento** | [`DIRDIVING_WATCH_PHOTO_TRANSFER_IMPLEMENTATION_REPORT_20260605.md`](DIRDIVING_WATCH_PHOTO_TRANSFER_IMPLEMENTATION_REPORT_20260605.md) |
| **Percorso** | `Docs/DIRDIVING_WATCH_PHOTO_TRANSFER_IMPLEMENTATION_REPORT_20260605.md` |
| **Stato** | Implementato su `main` @ `fc311be`/`90dc3f5` — ACK Watch→iOS, lifecycle transfer iOS, UUID filename, status localizzati, dedup import, page dots, tap-to-fullscreen in `UserImagesView`, **manual send**, **iOS manage/delete sheet**, Watch **staging sync** fix; test |
| **Build/test** | iOS + Watch build ✅; `CompanionPhotoTransferPipelineTests` 7/7; `CompanionPhotoImportSupportTests` 7/7 |
| **QA residua** | Coppia fisica iPhone/Watch; connettività disabilitata/ripristinata; 41 / 45 / 49 mm |

### Piano opzioni cancellazione immagini Watch (2026-06-05)

Piano **plan-only** per eliminare le immagini caricate su Apple Watch (nessuna modifica codice nel documento). Baseline: `main` @ `aa5a5c3` (fullscreen `UserImagesView`).

| Campo | Valore |
|-------|--------|
| **Documento** | [`DIRDIVING_WATCH_IMAGE_DELETE_OPTIONS_PLAN_20260605.txt`](DIRDIVING_WATCH_IMAGE_DELETE_OPTIONS_PLAN_20260605.txt) |
| **Percorso** | `Docs/DIRDIVING_WATCH_IMAGE_DELETE_OPTIONS_PLAN_20260605.txt` |
| **Data** | 2026-06-05 |
| **Modalità** | Plan-only (Opzione 1 consigliata prima; Opzione 2 iOS companion dopo) |
| **Gap attuale** | Nessuna delete singola / clear-all; bundle `UserImages` non cancellabile |
| **File chiave** | `UserImageStore.swift`, `UserImagesView.swift`, `WatchSyncService.swift` (se Opzione 2), `WatchSyncKeys.swift` |

| Opzione | Obiettivo | Priorità |
|---------|-----------|----------|
| **1** | Delete su Watch (trash + conferma in detail; solo `Documents/UserImages`) | **Implementare per prima** |
| **2** | Delete richiesta da iOS Companion con ACK Watch (`companionPhotoDeleteRequest` / `companionPhotoDeleteAck`) | Dopo Opzione 1, se serve gestione bulk da iPhone |

**Acceptance (Opzione 1):** immagine upload sparisce subito dalla lista; empty state se ultima; asset bundle intatti; send foto + ACK + fullscreen invariati.

### Implementazione full management (2026-06-05)

| Campo | Valore |
|-------|--------|
| **Documento** | [`DIRDIVING_WATCH_IMAGE_FULL_MANAGEMENT_IMPLEMENTATION_REPORT_20260605.md`](DIRDIVING_WATCH_IMAGE_FULL_MANAGEMENT_IMPLEMENTATION_REPORT_20260605.md) |
| **Stato** | Implementato — delete Watch locale, inventario Watch→iOS, delete remoto iOS con ACK |
| **Build/test** | Watch + iOS build ✅; management tests Watch 16/16, iOS 11/11 (subset) |

---

## Aggiornamento indice 2026-06-04 - consolidamento `.md` in `Docs/`

Tutti i file Markdown che erano nella root del repository sono stati spostati in `Docs/` per avere un unico punto documentale. Nessun file codice, asset, modello, servizio o configurazione Xcode e stato modificato in questo pass.

| Documento | Nuova posizione | Nota |
|-----------|-----------------|------|
| [`README.md`](README.md) | `Docs/` | Ingresso documentale del progetto |
| [`CHANGELOG.md`](CHANGELOG.md) | `Docs/` | Cronologia modifiche |
| [`CONTRIBUTING.md`](CONTRIBUTING.md) | `Docs/` | Regole contribuzione |
| [`DIR_DIVING_WATCH_UI_TEXT_VISIBILITY_AUDIT_CURRENT.md`](DIR_DIVING_WATCH_UI_TEXT_VISIBILITY_AUDIT_CURRENT.md) | `Docs/` | Audit Watch UI/UX/testo 2026-06-04 |
| [`DIR_DIVING_WATCH_ALGORITHM_MATH_AUDIT.md`](DIR_DIVING_WATCH_ALGORITHM_MATH_AUDIT.md) | `Docs/` | **Audit Watch MAIN corrente** @ `c314b93` (2026-06-07): 135 XCTest; P0=0; internal validation ready |
| [`DIR_DIVING_IOS_ALGORITHM_MATH_AUDIT.md`](DIR_DIVING_IOS_ALGORITHM_MATH_AUDIT.md) | `Docs/` | Audit matematico iOS Companion |
| [`DIR_DIVING_IOS_BUHLMANN_UX_UI_READINESS_AUDIT.md`](DIR_DIVING_IOS_BUHLMANN_UX_UI_READINESS_AUDIT.md) | `Docs/` | Audit UX/UI planner Buhlmann |
| [`DIR_DIVING_IOS_BUHLMANN_UX_UI_FIX_VERIFICATION.md`](DIR_DIVING_IOS_BUHLMANN_UX_UI_FIX_VERIFICATION.md) | `Docs/` | Verifica fix UX/UI Buhlmann |
| [`DIR_DIVING_FINAL_IMPLEMENTATION_AND_READINESS_REPORT.md`](DIR_DIVING_FINAL_IMPLEMENTATION_AND_READINESS_REPORT.md) | `Docs/` | Report readiness finale |
| [`DIR_DIVING_GRAPHICS_UI_TEXT_AUDIT_CURRENT.md`](DIR_DIVING_GRAPHICS_UI_TEXT_AUDIT_CURRENT.md) | `Docs/` | Audit grafica/testo |
| [`MAIN_BRANCH_FULL_CODE_SECURITY_AUDIT_CURRENT.md`](MAIN_BRANCH_FULL_CODE_SECURITY_AUDIT_CURRENT.md) | `Docs/` | Audit security current |
| [`MAIN_BRANCH_FULL_CODE_SECURITY_REMEDIATION_REPORT.md`](MAIN_BRANCH_FULL_CODE_SECURITY_REMEDIATION_REPORT.md) | `Docs/` | Report remediation security |
| [`DIR_DIVING_SECURITY_EXPLOIT_AUDIT_AND_REMEDIATION_PLAN_20260604.md`](DIR_DIVING_SECURITY_EXPLOIT_AUDIT_AND_REMEDIATION_PLAN_20260604.md) | `Docs/` | Audit security/exploit 2026-06-04 — piano remediation P1–P3 (vedi sezione dedicata sotto) |
| [`DIRDIVING_WATCH_PHOTO_TRANSFER_AUDIT_REPORT_20260605.md`](DIRDIVING_WATCH_PHOTO_TRANSFER_AUDIT_REPORT_20260605.md) | `Docs/` | Audit transfer foto iOS → Watch 2026-06-05 — vedi sezione indice 2026-06-05 sopra |
| [`DIRDIVING_WATCH_PHOTO_TRANSFER_IMPLEMENTATION_REPORT_20260605.md`](DIRDIVING_WATCH_PHOTO_TRANSFER_IMPLEMENTATION_REPORT_20260605.md) | `Docs/` | Implementazione remediation transfer foto iOS → Watch 2026-06-05 — vedi sezione indice 2026-06-05 sopra |
| [`DIRDIVING_WATCH_IMAGE_DELETE_OPTIONS_PLAN_20260605.txt`](DIRDIVING_WATCH_IMAGE_DELETE_OPTIONS_PLAN_20260605.txt) | `Docs/` | Piano opzioni delete immagini Watch 2026-06-05 — vedi sezione indice 2026-06-05 sopra |

---

## Aggiornamento indice 2026-06-04 — Security exploit audit & remediation plan

Audit statico **security / exploitability** su branch `main` @ `d2ad45b`. Report + piano remediation only (build/test non eseguiti sull’host audit Windows; comandi macOS in § finale del report).

| Campo | Valore |
|-------|--------|
| **Documento** | [`DIR_DIVING_SECURITY_EXPLOIT_AUDIT_AND_REMEDIATION_PLAN_20260604.md`](DIR_DIVING_SECURITY_EXPLOIT_AUDIT_AND_REMEDIATION_PLAN_20260604.md) |
| **Percorso** | `Docs/DIR_DIVING_SECURITY_EXPLOIT_AUDIT_AND_REMEDIATION_PLAN_20260604.md` |
| **Data** | 2026-06-04 |
| **Commit audit** | `d2ad45b` |
| **Modalità** | Static audit, report-only |
| **P0** | Nessuno |
| **Verdetto** | Parziale — fix **P1** prima di TestFlight/App Store esterno |

### Controlli positivi (Executive Summary)

- HMAC-SHA256 su payload Watch↔iPhone; sync bounded (size, schema, bundle ID, skew).
- Keychain `AfterFirstUnlockThisDeviceOnly`; CSV import bounded; export `.completeFileProtection`.
- Nessun client rete arbitrario evidente nei path MAIN auditati; secret scan regex senza secret in sorgente.

### Mappa sezioni report

| § | Titolo | Contenuto chiave |
|---|--------|------------------|
| — | Executive Summary | Controlli forti; rischi trust-boundary / privacy / safety-integrity / repo hygiene |
| — | Scope | Watch + iOS MAIN, WCSession, Keychain, iCloud KVS, CSV, foto, legal gate, App Intents, CI |
| — | Severity Model | P0–P3 + INFO |
| — | Findings | `SEC-P1-001` … `SEC-P3-002` (dettaglio sotto) |
| — | Remediation Roadmap | Phase 1–4 (P1 release-blocking → docs/privacy) |
| — | Suggested Implementation Order | Ordine 1–8 per ID finding |
| — | Proposed Tests | Watch / iOS / repo-CI |
| — | macOS Validation Commands | `xcodegen`, build Watch/iOS, algorithm tests |
| — | Physical QA Requirements | Ultra, Action Button, WCSession, iCloud, foto, legal revision |
| — | Final Verdict | No P0; P1 blocca release “security-hard” |

### Indice findings (priorità)

| ID | Sev | Area | File / evidenza principale |
|----|-----|------|----------------------------|
| **SEC-P1-001** | P1 | App Intents bypass legal onboarding | `ActionButtonIntents.swift`, `DIRDivingApp.swift`, `DiveManager.swift` → gate `LegalAcceptanceGate` |
| **SEC-P1-002** | P1 | Simulation sensor in release | `SensorSourceMode.swift`, `SensorProviderFactory.swift`, `DeveloperVersionUnlock.swift`, `InfoView` / `MoreView` |
| **SEC-P1-003** | P1 | iCloud KVS backup automatico log sensibili | `CloudSyncStore`, `DiveLogStore` (iOS), opt-in default off |
| **SEC-P2-001** | P2 | Peer secret overwrite da application context | `WatchSyncAuth.swift` (Watch + iOS), TOFU pinning |
| **SEC-P2-002** | P2 | Foto Watch senza decode/validazione contenuto | `UserImageStore.swift`, `WatchPhotoPreprocessor`, `WatchSyncService` |
| **SEC-P2-003** | P2 | ZIP tracciato bypass secret scan | `DirDiving-All-Branches-*.zip`, `Scripts/check_secrets.sh` |
| **SEC-P3-001** | P3 | Watch ACK verifier parità iOS | `WatchDiveSyncCodec` / ACK legacy `"acknowledged"` |
| **SEC-P3-002** | P3 | GitHub Actions least-privilege | `.github/workflows/build.yml` → `permissions: contents: read` |

### Roadmap remediation (Phase 1–4)

| Phase | Priorità | Task principali |
|-------|----------|-----------------|
| **1** | P1 | Legal gate App Intents; sensor `.automatic` in release; cloud backup opt-in |
| **2** | P2 | Peer-secret TOFU; ACK guard Watch; test sync |
| **3** | P2–P3 | Validazione immagine Watch; rimozione ZIP da repo; CI permissions |
| **4** | P2 | Privacy docs, TestFlight notes, security checklist, QA App Intents |

### Ordine implementazione suggerito (report § Suggested Implementation Order)

1. `SEC-P1-001` → 2. `SEC-P1-002` → 3. `SEC-P1-003` → 4. `SEC-P2-001` → 5. `SEC-P2-002` → 6. `SEC-P2-003` → 7. `SEC-P3-001` → 8. `SEC-P3-002`

### Documenti correlati

| Documento | Relazione |
|-----------|-----------|
| [`MAIN_BRANCH_FULL_CODE_SECURITY_AUDIT_CURRENT.md`](MAIN_BRANCH_FULL_CODE_SECURITY_AUDIT_CURRENT.md) | Audit security precedente (baseline storica) |
| [`MAIN_BRANCH_FULL_CODE_SECURITY_REMEDIATION_REPORT.md`](MAIN_BRANCH_FULL_CODE_SECURITY_REMEDIATION_REPORT.md) | Report remediation security storico |
| [`SECURITY_STATIC_CHECKLIST.md`](SECURITY_STATIC_CHECKLIST.md) | Checklist statica release |
| [`SECURITY_PRIVACY_RELEASE_EVIDENCE.md`](SECURITY_PRIVACY_RELEASE_EVIDENCE.md) | Evidenze privacy/release |
| [`Scripts/check_secrets.sh`](../Scripts/check_secrets.sh) | Secret scan (ZIP esclusi — vedi SEC-P2-003) |
| [`TESTFLIGHT_REVIEW_NOTES.md`](TESTFLIGHT_REVIEW_NOTES.md) | Note reviewer (simulation/cloud policy) |

**Commit doc su `main`:** `40bf110` (`docs: add security exploit remediation plan`).  
**Remediation implementata:** [`DIR_DIVING_SECURITY_REMEDIATION_REPORT_20260604.md`](DIR_DIVING_SECURITY_REMEDIATION_REPORT_20260604.md) — SEC-P1–P3 chiusi in codice/repo.

---

## Aggiornamento indice 2026-06-04 — iOS Bühlmann comprehensive readiness audit (updated)

Audit statico read-only su **iOS Companion MAIN — Planner only** (`DIRDiving iOS`). Nessuna modifica codice; report-only (host audit Windows: `xcodegen`/`xcodebuild` non eseguiti).

| Campo | Valore |
|-------|--------|
| **Documento** | [`DIR_DIVING_IOS_BUHLMANN_COMPREHENSIVE_READINESS_AUDIT_UPDATED.md`](DIR_DIVING_IOS_BUHLMANN_COMPREHENSIVE_READINESS_AUDIT_UPDATED.md) |
| **Percorso** | `Docs/DIR_DIVING_IOS_BUHLMANN_COMPREHENSIVE_READINESS_AUDIT_UPDATED.md` |
| **Data** | 2026-06-04 |
| **Commit doc** | `63ee0b4` (`docs: add updated iOS Buhlmann readiness audit`) |
| **Baseline audit** | `40bf110` (pre-report; post-security plan doc) |
| **Scope** | Motore ZHL-16C N2+He, planner services, CNS/OTU, UX/UI planner, test/docs |
| **Modalità** | Static audit only |
| **Verdetto** | **Partially ready** — core Bühlmann + CNS 15% rule forti; **OTU constant-depth formula** bloccante |

### Relazione con audit precedenti

| Documento | Relazione |
|-----------|-----------|
| [`DIR_DIVING_IOS_BUHLMANN_COMPREHENSIVE_READINESS_AUDIT.md`](DIR_DIVING_IOS_BUHLMANN_COMPREHENSIVE_READINESS_AUDIT.md) | Audit comprehensive @ `e1370f7` (2026-05-30) — verdict *Almost Ready*; **baseline storica** |
| [`DIR_DIVING_IOS_BUHLMANN_IMPLEMENTATION_COMPLETION_REPORT.md`](DIR_DIVING_IOS_BUHLMANN_IMPLEMENTATION_COMPLETION_REPORT.md) | Implementazione + hardening @ `74035fd` — **387 XCTest**; verdict **READY FOR INTERNAL VALIDATION** |
| [`DIR_DIVING_IOS_BUHLMANN_MATH_VERIFICATION.md`](DIR_DIVING_IOS_BUHLMANN_MATH_VERIFICATION.md) | §11 oxygen exposure — allineare formula OTU dopo fix |
| [`DIR_DIVING_IOS_BUHLMANN_EXTERNAL_VALIDATION_PLAN.md`](DIR_DIVING_IOS_BUHLMANN_EXTERNAL_VALIDATION_PLAN.md) | Campagna validazione esterna (P1 pending) |
| [`DIR_DIVING_IOS_PLANNER_LIMITATIONS.md`](DIR_DIVING_IOS_PLANNER_LIMITATIONS.md) | Limiti reference-only planner |

### Mappa sezioni report

| § | Titolo | Contenuto chiave |
|---|--------|------------------|
| — | Executive Verdict | *Partially ready*; blocker OTU inverted constant-depth |
| — | Scope Confirmation | iOS MAIN planner only; Watch/experimental esclusi |
| — | Repository State | `main`, `40bf110`, Windows static |
| — | Files Inspected | Engine, planner services, views, tests, l10n |
| — | Buhlmann Mathematical Model Assessment | ZHL-16C, GF, NDL, multigas, trimix |
| — | CNS / OTU / 15% Rule Assessment | CNS full plan + descent+bottom 15% warning; **OTU correctness** |
| — | Algorithmic Consistency Assessment | Validation, gas planning, result states |
| — | Numerical Robustness Assessment | Edge cases, OTU formula |
| — | UX/UI Readiness Assessment | Planner discoverability, safety copy |
| — | CNS UI/UX Visibility Matrix | Tabella visibilità CNS/OTU in UI |
| — | Test Coverage Assessment | Gap test OTU vs riferimento indipendente |
| — | Documentation Assessment | Docs OTU da correggere con codice |
| — | Risk Matrix | P0–P4 findings |
| — | Release Readiness Verdict | OTU not ready; Bühlmann core largely coherent |
| — | Implementation Plan | Phase 1–5 (OTU fix → macOS validation) |
| — | Protected Files / Areas | Watch + experimental iOS esclusi |
| — | Recommended Next Cursor / Codex Command | Prompt fix OTU + test (non eseguire automaticamente) |
| — | Final Recommendations | Fix OTU prima di release-hard |
| — | Audit Certification | Report-only, no commit dal audit |

### Indice findings (priorità)

| ID | Sev | Area | Sintesi |
|----|-----|------|---------|
| **OTU inverted** | P0/P1 | Oxygen exposure | `OxygenExposureModels.swift` — formula costante-depth apparentemente invertita; sottostima OTU a PPO2 elevato |
| **External validation** | P1 | Decompression reference | Campagna esterna ancora pending |
| **OTU tests self-referential** | P1 | Tests | Test validano implementazione, non riferimento canonico |
| **Travel gas switch** | P2 | Multigas | Switch depth travel→bottom semplificato |
| **macOS build/test stale** | P2 | Release process | Validazione macOS su HEAD corrente richiesta |
| **Build validation docs stale** | P2 | Documentation | Conteggi test/docs da aggiornare |
| **Hardcoded IT validation** | P3 | Localization | Messaggi validator planner |
| **Persistence key `experimental`** | P3 | Maintainability | Naming chiave planner |
| **Share/export CNS label** | P3 | UX copy | Etichette export generiche |
| **Bailout schedule-only** | P3 | Planning model | Documentato come limite |
| **Physical a11y QA** | P4 | UX validation | Dynamic Type / VoiceOver su device |
| **No exact equivalence claim** | P4 | Legal/docs | Reference-only — OK se esplicito |

### Piano implementazione (Phase 1–5)

| Phase | Focus |
|-------|--------|
| **1** | Correggere formula OTU + test monotonicità / fixture PPO2 0.6–1.6 |
| **2** | Campagna validazione esterna Bühlmann (NDL, stop, TTS, gas switch) |
| **3** | Modello travel gas switch depth |
| **4** | Localization + copy share/export CNS/OTU |
| **5** | `xcodegen`, build iOS, iOS Algorithm Tests su macOS |

**Esclusi da scope:** Apple Watch MAIN, file experimental iOS in `project.yml`, branch experimental.

**Remediation implementata:** [`DIR_DIVING_IOS_BUHLMANN_READINESS_REMEDIATION_REPORT.md`](DIR_DIVING_IOS_BUHLMANN_READINESS_REMEDIATION_REPORT.md) — OTU fix, test canonici, switch depth fondo, export CNS, l10n validator.

---

## Aggiornamento indice 2026-06-04 — Watch UI text visibility audit (current)

Audit read-only su **Apple Watch MAIN** (`DIRDiving Watch App` only). Nessuna modifica codice; solo report statico SwiftUI.

| Campo | Valore |
|-------|--------|
| **Documento** | [`DIR_DIVING_WATCH_UI_TEXT_VISIBILITY_AUDIT_CURRENT.md`](DIR_DIVING_WATCH_UI_TEXT_VISIBILITY_AUDIT_CURRENT.md) |
| **Data audit** | 2026-06-04 |
| **Branch** | `main` |
| **Target** | `DIRDiving Watch App` |
| **Modalità** | Report-only (build/test non eseguiti) |
| **Readiness testo/UI** | **78%** |
| **Verdetto Settings** | Issue piccolo testo **confermata** (P1); Live Dive **forte** |
| **Benchmark** | Oceanic+, Garmin Descent, watchOS native density |

### Mappa sezioni report

| § | Titolo | Contenuto chiave |
|---|--------|------------------|
| 1 | Executive Summary | 78% readiness; P1 Settings + warning text; P2 secondarie |
| 2 | Scope Confirmed | View incluse/escluse da `project.yml` |
| 3 | Screen-by-Screen Audit | Home, Live Dive, Settings, Alarm/Ascent settings, Compass, Images, Logs, Info, Legal, Banners |
| 4 | Settings Deep Dive | 8 pt badge, 11/10 pt rows, `minimumScaleFactor(0.68)`, target 13/14 pt |
| 5 | Typography Inventory | `DiveUI.Typography.*`, 7–72 pt, `.caption2`, scale factors |
| 6 | Color and Contrast | Palette `DiveUI`, muted/disabled, warning colors |
| 7 | UX Fluidity | TabView, scroll, tap targets 31–44 pt |
| 8 | Benchmark Comparison | Oceanic+ / Garmin / watchOS |
| 9 | Prioritized Remediation Plan | P0 none; P1 Settings + warnings; P2 polish; P3 optional |
| 10 | Acceptance Criteria | Criteri fix futuro (44 pt rows, no micro-text, ecc.) |
| 11 | No-Code-Change Confirmation | Solo questo file creato/aggiornato |
| 12 | Final Verdict | Prossimo pass: UI-only typography/spacing |

### Indice per schermata (severità)

| Schermata | Severità | File principali |
|-----------|----------|-----------------|
| Settings | **P1** | `SettingsView.swift`, `DiveUIComponents.swift` |
| Warning banners / safety | **P1** (testo) / P2 (layout) | `AscentWarningBannerView.swift`, `DepthSafetyLiveViews.swift`, `DiveLiveView.swift` |
| Live Dive | P2 | `DiveLiveView.swift`, `AscentGaugeView.swift`, … |
| Compass | P2 | `CompassView.swift` |
| User Images | P2 | `UserImageStore.swift`, `UserImagesView.swift`, `WatchPhotoTransferPanel.swift` — delete Watch, inventario iOS, delete remoto ACK; vedi [`DIRDIVING_WATCH_IMAGE_FULL_MANAGEMENT_IMPLEMENTATION_REPORT_20260605.md`](DIRDIVING_WATCH_IMAGE_FULL_MANAGEMENT_IMPLEMENTATION_REPORT_20260605.md) |
| Logs / Dive Detail / Export | P2 | `DiveLogListView.swift`, `DiveDetailView.swift`, `ExportView.swift` |
| Info / diagnostics | P2 | `InfoView.swift` |
| Legal onboarding | P2 | `WatchLegalOnboardingView.swift` |
| Alarm settings | P2 | `AlarmSettingsView.swift` |
| Ascent rate settings | P3 | `AscentRateSettingsView.swift` |
| Mode selection | P3 | `ModeSelectionView.swift` (di solito nascosta in MAIN) |

### Indice remediation P1–P3 (§9)

| ID | Priorità | Azione | File |
|----|----------|--------|------|
| 1 | P1 | Restyle Settings typography/density | `SettingsView.swift`, `DiveUIComponents.swift` |
| 2 | P1 | Warning title/body più grandi | `AscentWarningBannerView.swift`, `DepthSafetyLiveViews.swift`, `DiveLiveView.swift` |
| 3 | P1 | Ridurre copy Settings; dettaglio in Info/Legal | `SettingsView.swift`, `InfoView.swift`, `WatchLegalOnboardingView.swift` |
| 4 | P2 | Eliminare label 7–8 pt secondarie | `DiveDetailView.swift`, `DiveLogListView.swift`, `CompassView.swift`, `UserImagesView.swift`, `InfoView.swift` |
| 5 | P2 | Tap target 40–44 pt | `DiveUIComponents.swift`, `CompassView.swift`, `SettingsView.swift`, `AlarmSettingsView.swift` |
| 6 | P2 | Coordinate/status-first su Watch | `DiveDetailView.swift`, `DiveLogListView.swift` |
| 7–10 | P3 | Header uniformi, stroke, l10n IT, QA Dynamic Type | Vari |

### Documenti correlati

| Documento | Relazione |
|-----------|-----------|
| [`WATCH_MAIN_ALGORITHM_MATH_AUDIT_CURRENT.md`](WATCH_MAIN_ALGORITHM_MATH_AUDIT_CURRENT.md) | Audit **algoritmi** Watch (separato da questo audit **UI/testo**) |
| [`WATCH_MAIN_ALGORITHM_MATH_AUDIT_REMEDIATION_REPORT.md`](WATCH_MAIN_ALGORITHM_MATH_AUDIT_REMEDIATION_REPORT.md) | Remediation algoritmi @ `39b3d4e` / `ba21813` |
| [`MAIN_UI_UX_READINESS_AUDIT_CURRENT.md`](MAIN_UI_UX_READINESS_AUDIT_CURRENT.md) | Audit UX cross-app (baseline storico) |
| [`DIR_DIVING_GRAPHICS_UI_TEXT_AUDIT_CURRENT.md`](DIR_DIVING_GRAPHICS_UI_TEXT_AUDIT_CURRENT.md) | Audit grafica/testo (ambito diverso) |
| [`WATCH_MAIN_UX_CONVENTIONS.md`](WATCH_MAIN_UX_CONVENTIONS.md) | Convenzioni UX Watch MAIN |

**Esclusi da scope** (non in target audit): `ApneaView`, `SnorkelingView`, `BuddyAssistView`, `ExperimentalConceptsView`, iOS Companion.

---

Remediation completa da audit [`MAIN_UI_UX_READINESS_AUDIT_CURRENT.md`](MAIN_UI_UX_READINESS_AUDIT_CURRENT.md) (83% Watch / 86% iOS / 81% cross-app → **100%** criteri codice; QA fisica ancora richiesta):

| Documento | Posizione | Contenuto |
|-----------|-----------|-----------|
| [`MAIN_UI_UX_READINESS_AUDIT_CURRENT.md`](MAIN_UI_UX_READINESS_AUDIT_CURRENT.md) | `Docs/` | Audit read-only pre-fix (baseline storico @ `02eb9d8`) |
| [`MAIN_UI_UX_READINESS_AUDIT_LONG_PRE_FIX.md`](MAIN_UI_UX_READINESS_AUDIT_LONG_PRE_FIX.md) | `Docs/` | Conferma issue pre-implementazione |
| [`MAIN_UI_UX_READINESS_AUDIT_POST_FIX.md`](MAIN_UI_UX_READINESS_AUDIT_POST_FIX.md) | `Docs/` | **Report post-fix** — P0–P3 chiusi; Internal TestFlight UI/UX YES |
| [`MAIN_UI_UX_READINESS_QA_ANALYSIS.md`](MAIN_UI_UX_READINESS_QA_ANALYSIS.md) | `Docs/` | QA sintetica build/test + file modificati |

Implementazione: Live Dive scroll/compact banners, legal onboarding i18n, Crown hint, underwater lock toast, Policy A no-depth edit, DEMO badge, iCloud conflict UI, planner team preview, logbook search/swipe-delete, CSV import unificato via `CSVImportPanel`.

---

## Aggiornamento indice 2026-05-31 — Watch MAIN algorithmic readiness 100%

Remediation completa da audit [`WATCH_MAIN_ALGORITHM_MATH_AUDIT_CURRENT.md`](WATCH_MAIN_ALGORITHM_MATH_AUDIT_CURRENT.md) (82% pre-remediation → **100%** criteri codice; QA fisica § L ancora richiesta):

| Documento | Posizione | Contenuto |
|-----------|-----------|-----------|
| [`WATCH_MAIN_ALGORITHM_READINESS_100_REPORT.md`](WATCH_MAIN_ALGORITHM_READINESS_100_REPORT.md) | `Docs/` | **Report finale** — WMATH-HIGH/MED/LOW/INFO risolti, XCTest Watch + iOS sync |
| [`WATCH_MANUAL_NODEPTH_SYNC_POLICY.md`](WATCH_MANUAL_NODEPTH_SYNC_POLICY.md) | `Docs/` | Policy A: sessioni manuali senza profilo — sync iOS, export disabilitato |
| [`WATCH_MAIN_ALGORITHM_MATH_AUDIT_CURRENT.md`](WATCH_MAIN_ALGORITHM_MATH_AUDIT_CURRENT.md) | `Docs/` | Audit read-only originale + link al report 100% |

Implementazione runtime Watch: depth silence watchdog, GPS fix/fallback/no-fix, `MonotonicElapsedClock`, blink/haptic indipendenti, gauge/zone alignment, CSV time origin, persistence class, iOS logbook manual no-depth UI.

---

## Aggiornamento indice 2026-05-31 — iOS MAIN algorithmic readiness 100% @ `dce89e7`

Remediation completa da audit [`IOS_MAIN_ALGORITHM_MATH_AUDIT_CURRENT.md`](IOS_MAIN_ALGORITHM_MATH_AUDIT_CURRENT.md) (76% @ `4d5aabc` → **100%** criteri codice @ `dce89e7`):

| Documento | Posizione | Contenuto |
|-----------|-----------|-----------|
| [`IOS_MAIN_ALGORITHM_READINESS_100_REPORT.md`](IOS_MAIN_ALGORITHM_READINESS_100_REPORT.md) | `Docs/` | **Report finale** — B2–B5 risolti, 154/154 XCTest, build locale OK |
| [`IOS_MAIN_ALGORITHM_MATH_AUDIT_CURRENT.md`](IOS_MAIN_ALGORITHM_MATH_AUDIT_CURRENT.md) | `Docs/` | Audit read-only originale + link al report 100% |
| [`SUBSURFACE_CSV_ROUNDTRIP.md`](SUBSURFACE_CSV_ROUNDTRIP.md) | `Docs/` | CSV `# session_meta` export/import round-trip |
| [`DOCUMENTATION_BRANCH_ALIGNMENT_20260531.md`](DOCUMENTATION_BRANCH_ALIGNMENT_20260531.md) | `Docs/` | Branch strategy + PR #8/#9/#10 @ `1d69d88` |
| [`PR_STATUS_20260531.md`](PR_STATUS_20260531.md) | `Docs/` | Stato PR aperti, CI, raccomandazioni merge |
| [`DIR_DIVING_IOS_PLANNER_LIMITATIONS.md`](DIR_DIVING_IOS_PLANNER_LIMITATIONS.md) | `Docs/` | Pressure unificato, planning depth toggle, cloud merge, incomplete calc |
| [`DOCUMENTATION_UPDATE_REPORT_20260531.md`](DOCUMENTATION_UPDATE_REPORT_20260531.md) | `Docs/` | Pass documentale CNS/OTU + readiness 100% |

Implementazione runtime (non Watch experimental): pressure `AmbientPressureModel`, toggle max/avg depth, merge cloud per sessione, CSV metadata, demo isolation Analysis, engine contingencies, **154 XCTest** (1 skipped) iPhone 17 sim.

---

## Aggiornamento indice 2026-06-05 — Watch MAIN algorithm audit @ `5415213`

Audit read-only Apple Watch MAIN (`DIRDiving Watch App` only):

| Documento | Posizione | Contenuto |
|-----------|-----------|-----------|
| [`WATCH_MAIN_ALGORITHM_MATH_AUDIT_CURRENT.md`](WATCH_MAIN_ALGORITHM_MATH_AUDIT_CURRENT.md) | `Docs/` | **Audit corrente** — ~93% readiness; HIGH-001 remediated; 0 CRITICAL/0 HIGH; 113 XCTest (21 integration isolation failures) |

---

## Aggiornamento indice 2026-06-05 — iOS MAIN algorithm audit (three-tab Planner) @ `ecad0d9`

> **Indice completo:** vedi sezione **2026-06-06 — iOS MAIN algorithm audit** in cima a questo file.

| Documento | Posizione | Contenuto |
|-----------|-----------|-----------|
| [`IOS_MAIN_ALGORITHM_MATH_AUDIT_CURRENT.md`](IOS_MAIN_ALGORITHM_MATH_AUDIT_CURRENT.md) | `Docs/` | **Audit corrente** — ~92% math robustness; three-mode **90%**; 363 XCTest @ baseline `81f2d7f`; **387** post-remediation @ `74035fd`; 0 P0; vedi @ `c723295` |

Scope: `DIRDiving iOS` only; experimental files esclusi in `project.yml`. Indicizzato su `main` @ `c723295` (supersedes `5415213` / `ecad0d9`).

---

## Aggiornamento indice 2026-05-31 — Watch MAIN algorithm audit (current)

Audit read-only su **Apple Watch MAIN** (`DIRDiving Watch App` only), parallelo a [`IOS_MAIN_ALGORITHM_MATH_AUDIT_CURRENT.md`](IOS_MAIN_ALGORITHM_MATH_AUDIT_CURRENT.md):

| Documento | Posizione | Contenuto |
|-----------|-----------|-----------|
| [`WATCH_MAIN_ALGORITHM_MATH_AUDIT_CURRENT.md`](WATCH_MAIN_ALGORITHM_MATH_AUDIT_CURRENT.md) | `Docs/` | **Audit corrente Watch MAIN** @ `5415213` (~93%); remediation storica → [`WATCH_MAIN_ALGORITHM_READINESS_100_REPORT.md`](WATCH_MAIN_ALGORITHM_READINESS_100_REPORT.md) |
| [`WATCH_MAIN_ALGORITHM_READINESS_100_REPORT.md`](WATCH_MAIN_ALGORITHM_READINESS_100_REPORT.md) | `Docs/` | Report finale readiness 100% (codice) + QA fisica § L |
| [`WATCH_MANUAL_NODEPTH_SYNC_POLICY.md`](WATCH_MANUAL_NODEPTH_SYNC_POLICY.md) | `Docs/` | Policy sync sessioni manuali senza profilo |
| [`CODEX_DIR_DIVING_WATCH_ALGORITHM_MATH_AUDIT.md`](CODEX_DIR_DIVING_WATCH_ALGORITHM_MATH_AUDIT.md) | `Docs/` | Audit pre-hardening @ `ddaf2d7` (storico) |
| [`DIR_DIVING_WATCH_ALGORITHM_MATH_AUDIT.md`](DIR_DIVING_WATCH_ALGORITHM_MATH_AUDIT.md) | `Docs/` | Audit post-hardening 2026-05-27 |
| [`DIR_DIVING_WATCH_ALGORITHM_RELEASE_HARDENING.md`](DIR_DIVING_WATCH_ALGORITHM_RELEASE_HARDENING.md) | `Docs/` | Implementazione hardening @ `92e639a` |
| [`DIR_DIVING_WATCH_ALGORITHM_RELEASE_HARDENING_FINAL.md`](DIR_DIVING_WATCH_ALGORITHM_RELEASE_HARDENING_FINAL.md) | `Docs/` | Final hardening cap log / export / GPS |

Origine: branch [`codex/watch-main-algorithm-audit-current`](https://github.com/egopfe/DirDiving-App/pull/10); file indicizzato su `main` per navigazione. **Non** include Snorkeling, Apnea, Buddy, Exploration Lab (esclusi in `project.yml`).

---

## Aggiornamento indice 2026-05-31 — comprehensive NOAA CNS/OTU + readiness @ `dae29b8`

Implementazione runtime + documentazione allineata (**119/119 XCTest pass**, iPhone 17 sim):

| Documento | Posizione | Contenuto |
|-----------|-----------|-----------|
| [`DIR_DIVING_IOS_BUHLMANN_IMPLEMENTATION_COMPLETION_REPORT.md`](DIR_DIVING_IOS_BUHLMANN_IMPLEMENTATION_COMPLETION_REPORT.md) | `Docs/` | P1–P4 + **comprehensive CNS/OTU** — verdict **READY FOR INTERNAL VALIDATION** |
| [`DIR_DIVING_IOS_PLANNER_LIMITATIONS.md`](DIR_DIVING_IOS_PLANNER_LIMITATIONS.md) | `Docs/` | Daily CNS, surface/air-break recovery, REPEX OTU, snapshot v2 carryover |
| [`DIR_DIVING_IOS_BUHLMANN_MATH_VERIFICATION.md`](DIR_DIVING_IOS_BUHLMANN_MATH_VERIFICATION.md) | `Docs/` | §11 oxygen exposure — NOAA single/daily, recovery, REPEX |
| [`OxygenExposureDeepModelTests.swift`](../Tests/iOSAlgorithmTests/OxygenExposureDeepModelTests.swift) | `Tests/` | 14 test CNS/OTU (decay, daily limits, air-break, carryover) |
| [`DIR_DIVING_Feature_Comparison.csv`](DIR_DIVING_Feature_Comparison.csv) | `Docs/` | Righe algorithm/UX CNS/OTU comprehensive @ `dae29b8` |
| [`DOCUMENTATION_UPDATE_REPORT_20260531.md`](DOCUMENTATION_UPDATE_REPORT_20260531.md) | `Docs/` | Report A–K allineamento documentazione post CNS/OTU |

Relazione: comprehensive readiness @ `f7de936` → implementazione P1–P4 + NOAA CNS/OTU @ `dae29b8`.

---

## Aggiornamento indice 2026-05-29 — comprehensive readiness implementation

Implementazione P1–P4 da [`DIR_DIVING_IOS_BUHLMANN_COMPREHENSIVE_READINESS_AUDIT.md`](DIR_DIVING_IOS_BUHLMANN_COMPREHENSIVE_READINESS_AUDIT.md) (**119/119 XCTest pass** @ `dae29b8`, iPhone 17 sim):

| Documento | Posizione | Contenuto |
|-----------|-----------|-----------|
| [`DIR_DIVING_IOS_BUHLMANN_IMPLEMENTATION_COMPLETION_REPORT.md`](DIR_DIVING_IOS_BUHLMANN_IMPLEMENTATION_COMPLETION_REPORT.md) | `Docs/` | **Completion report** — verdict **READY FOR INTERNAL VALIDATION** |
| [`DIR_DIVING_IOS_BUHLMANN_EXTERNAL_VALIDATION_PLAN.md`](DIR_DIVING_IOS_BUHLMANN_EXTERNAL_VALIDATION_PLAN.md) | `Docs/` | External validation campaign checklist |
| [`DIR_DIVING_IOS_PHYSICAL_ACCESSIBILITY_QA.md`](DIR_DIVING_IOS_PHYSICAL_ACCESSIBILITY_QA.md) | `Docs/` | Physical a11y QA matrix |

---

## Aggiornamento indice 2026-05-30 — comprehensive Bühlmann readiness audit

Pass read-only su `main` @ `e1370f7` (math, consistency, UX/UI, tests, docs; **88/88 XCTest pass**):

| Documento | Posizione | Contenuto |
|-----------|-----------|-----------|
| [`DIR_DIVING_IOS_BUHLMANN_COMPREHENSIVE_READINESS_AUDIT.md`](DIR_DIVING_IOS_BUHLMANN_COMPREHENSIVE_READINESS_AUDIT.md) | `Docs/` | **Comprehensive readiness audit** @ `e1370f7` — verdict **Almost Ready**; baseline storica |
| [`DIR_DIVING_IOS_BUHLMANN_COMPREHENSIVE_READINESS_AUDIT_UPDATED.md`](DIR_DIVING_IOS_BUHLMANN_COMPREHENSIVE_READINESS_AUDIT_UPDATED.md) | `Docs/` | **Audit aggiornato 2026-06-04** @ `63ee0b4` — verdict **Partially ready**; blocker OTU; CNS 15% OK — vedi sezione indice 2026-06-04 sopra |

---

## Aggiornamento indice 2026-05-30 — Phase 15 UX fix + re-audit READY

Pass UX/UI su `main` @ `3237262` (fix P1–P3 presentation; algoritmo invariato @ `69e69b2`; XCTest `BuhlmannUxReadinessTests` verde):

| Documento | Posizione | Contenuto |
|-----------|-----------|-----------|
| [`DIR_DIVING_IOS_BUHLMANN_UX_UI_REAUDIT.md`](DIR_DIVING_IOS_BUHLMANN_UX_UI_REAUDIT.md) | `Docs/` | **Post-fix re-audit** — verdict **READY**; matrice issue originale → SOLVED |
| [`DIR_DIVING_IOS_BUHLMANN_UX_UI_FIX_VERIFICATION.md`](DIR_DIVING_IOS_BUHLMANN_UX_UI_FIX_VERIFICATION.md) | `Docs/` | Verifica implementazione fix UX @ `3237262` |
| [`DIR_DIVING_IOS_BUHLMANN_UX_UI_READINESS_AUDIT.md`](DIR_DIVING_IOS_BUHLMANN_UX_UI_READINESS_AUDIT.md) | `Docs/` | Audit originale (2026-05-28) *Partially ready* — **superseded** da re-audit |
| [`DIR_DIVING_FINAL_IMPLEMENTATION_AND_READINESS_REPORT.md`](DIR_DIVING_FINAL_IMPLEMENTATION_AND_READINESS_REPORT.md) | `Docs/` | Report Phase 15 — verdict **READY FOR INTERNAL VALIDATION** |
| [`DIR_DIVING_REPOSITORY_CONSISTENCY_REPORT.md`](DIR_DIVING_REPOSITORY_CONSISTENCY_REPORT.md) | `Docs/` | Consistency audit pre-commit Phase 15 |
| [`DOCUMENTATION_BRANCH_ALIGNMENT_20260530.md`](DOCUMENTATION_BRANCH_ALIGNMENT_20260530.md) | `Docs/` | Branch strategy + MAIN capabilities @ `3237262` |

Relazione: reaudit math → fix @ `69e69b2` → UX audit gaps → fix @ `3237262` → re-audit **READY**.

---

## Aggiornamento indice 2026-05-29 — reaudit P1–P3 fix + UX readiness audit

Pass algoritmico su `main` @ `69e69b2` (fix reaudit [`DIR_DIVING_IOS_BUHLMANN_REAUDIT_2026-05-28.md`](DIR_DIVING_IOS_BUHLMANN_REAUDIT_2026-05-28.md) P1–P3; XCTest verde su macOS):

| Documento | Posizione | Contenuto |
|-----------|-----------|-----------|
| [`DIR_DIVING_IOS_ALGORITHM_RELEASE_HARDENING.md`](DIR_DIVING_IOS_ALGORITHM_RELEASE_HARDENING.md) | `Docs/` | Tabella fix P1–P3 @ `69e69b2`; build/test macOS |
| [`DIR_DIVING_IOS_BUHLMANN_ENGINE_DESIGN.md`](DIR_DIVING_IOS_BUHLMANN_ENGINE_DESIGN.md) | `Docs/` | Environment-aware ceiling/NDL, canonical engine result, stable gas IDs |
| [`DIR_DIVING_IOS_BUHLMANN_UX_UI_READINESS_AUDIT.md`](DIR_DIVING_IOS_BUHLMANN_UX_UI_READINESS_AUDIT.md) | `Docs/` | **Audit UX/UI readiness** planner Bühlmann iOS (2026-05-28): verdict *Partially ready*; gap UI su repetitive planning, ledger per cilindro, messaging ambiente — da affrontare **dopo** fix algoritmico @ `69e69b2` |

Relazione: reaudit math [`DIR_DIVING_IOS_BUHLMANN_REAUDIT_2026-05-28.md`](DIR_DIVING_IOS_BUHLMANN_REAUDIT_2026-05-28.md) → fix @ `69e69b2` → UX gaps residui in audit root UX/UI.

---

## Aggiornamento indice 2026-05-29 — audit algoritmi root + Buhlmann reaudit/UX

Pass documentale additivo su `main` @ `570964e`–`69e69b2` (post-sync remoto: hardening Watch/iOS, motore Buhlmann, golden fixtures, reaudit fix):

| Documento | Posizione | Contenuto |
|-----------|-----------|-----------|
| [`DIR_DIVING_WATCH_ALGORITHM_MATH_AUDIT.md`](DIR_DIVING_WATCH_ALGORITHM_MATH_AUDIT.md) | `Docs/` | Audit matematico Watch MAIN post-hardening (2026-05-27): lifecycle, TTV, risalita, GPS, bussola, logbook, export; P0–P3 |
| [`DIR_DIVING_IOS_ALGORITHM_MATH_AUDIT.md`](DIR_DIVING_IOS_ALGORITHM_MATH_AUDIT.md) | `Docs/` | Audit matematico iOS Companion MAIN (2026-05-27): planner, gas, sync, export, limiti reference-only |
| [`DIR_DIVING_IOS_BUHLMANN_REAUDIT_2026-05-28.md`](DIR_DIVING_IOS_BUHLMANN_REAUDIT_2026-05-28.md) | `Docs/` | Re-audit Buhlmann/gas planner iOS dopo fixture golden e hardening @ `76fce90`–`570964e` |
| [`DIR_DIVING_IOS_BUHLMANN_UX_UI_READINESS_AUDIT.md`](DIR_DIVING_IOS_BUHLMANN_UX_UI_READINESS_AUDIT.md) | `Docs/` | Audit UX/UI readiness planner Bühlmann iOS (2026-05-28): discoverability, safety copy, gap interpretazione UI (repetitive, ledger, ambiente) — complementa reaudit math |

Relazione audit Watch: [`CODEX_DIR_DIVING_WATCH_ALGORITHM_MATH_AUDIT.md`](CODEX_DIR_DIVING_WATCH_ALGORITHM_MATH_AUDIT.md) = pre-hardening @ `ddaf2d7`; audit root = post-hardening 2026-05-27; [`WATCH_MAIN_ALGORITHM_MATH_AUDIT_CURRENT.md`](WATCH_MAIN_ALGORITHM_MATH_AUDIT_CURRENT.md) = audit corrente read-only @ `main` (2026-05-31, PR #10). Implementazione: [`DIR_DIVING_WATCH_ALGORITHM_RELEASE_HARDENING.md`](DIR_DIVING_WATCH_ALGORITHM_RELEASE_HARDENING.md), [`DIR_DIVING_WATCH_ALGORITHM_RELEASE_HARDENING_FINAL.md`](DIR_DIVING_WATCH_ALGORITHM_RELEASE_HARDENING_FINAL.md).

---

## Aggiornamento indice 2026-05-19 — baseline `92e639a` + algorithm hardening

Pass documentale additivo su `main` @ `92e639a`:

| Documento | Contenuto |
|-----------|-----------|
| [`DIR_DIVING_WATCH_ALGORITHM_RELEASE_HARDENING.md`](DIR_DIVING_WATCH_ALGORITHM_RELEASE_HARDENING.md) | Release-hard pass Watch MAIN @ `92e639a`: depth validator, lifecycle, TTV, haptic coordinator, XCTest |
| [`CODEX_DIR_DIVING_WATCH_ALGORITHM_MATH_AUDIT.md`](CODEX_DIR_DIVING_WATCH_ALGORITHM_MATH_AUDIT.md) | Audit matematico/algoritmico Watch MAIN @ `ddaf2d7` |
| [`DOCUMENTATION_BRANCH_ALIGNMENT_20260519.md`](DOCUMENTATION_BRANCH_ALIGNMENT_20260519.md) | Allineamento branch strategy, MAIN vs experimental, conflict policy |
| [`DOCUMENTATION_UPDATE_REPORT_20260519.md`](DOCUMENTATION_UPDATE_REPORT_20260519.md) | Report A–O del pass documentale corrente |
| [`PR_STATUS_20260519.md`](PR_STATUS_20260519.md) | Stato PR #8 / #9 e raccomandazioni merge |

Riferimenti UI obbligatori: [`ReferenceUI/Watch_LIVE_reference.png`](ReferenceUI/Watch_LIVE_reference.png), [`ReferenceUI/iOS_Companion_reference.png`](ReferenceUI/iOS_Companion_reference.png), [`FeatureScreenshots/02-ascent-warning.png`](FeatureScreenshots/02-ascent-warning.png).

---

## Aggiornamento indice 2026-05-28 - iOS gas+Buhlmann plan e refresh algoritmico

Pass documentale additivo su `main` tra `d1d48d5` -> `2edc46e` -> `9ee1912` -> `bc08707`:

| Documento | Stato | Contenuto |
|-----------|-------|-----------|
| [`DIR_DIVING_IOS_GAS_BUHLMANN_PLANNER_IMPROVEMENT_PLAN.md`](DIR_DIVING_IOS_GAS_BUHLMANN_PLANNER_IMPROVEMENT_PLAN.md) | **Nuovo** | Piano operativo miglioramenti planner gas+Buhlmann iOS: obiettivi, criteri qualità, piano test e readiness |
| [`DIR_DIVING_IOS_BUHLMANN_REFERENCE_CROSSCHECK.md`](DIR_DIVING_IOS_BUHLMANN_REFERENCE_CROSSCHECK.md) | Nuovo (pass 2026-05-28) | Cross-check esterno su envelope di riferimento Air/Nitrox/Trimix |
| [`DIR_DIVING_IOS_ALGORITHM_RELEASE_HARDENING.md`](DIR_DIVING_IOS_ALGORITHM_RELEASE_HARDENING.md) | Aggiornato | Hardening iOS planner/Buhlmann e policy safety/reference |
| [`DIR_DIVING_IOS_BUHLMANN_ENGINE_DESIGN.md`](DIR_DIVING_IOS_BUHLMANN_ENGINE_DESIGN.md) | Aggiornato | Design engine Buhlmann multigas e note implementative correnti |
| [`DIR_DIVING_IOS_BUHLMANN_MATH_VERIFICATION.md`](DIR_DIVING_IOS_BUHLMANN_MATH_VERIFICATION.md) | Aggiornato | Verifica matematica estesa + copertura casi edge |
| [`DIR_DIVING_IOS_BUHLMANN_VALIDATION_FIXTURES.md`](DIR_DIVING_IOS_BUHLMANN_VALIDATION_FIXTURES.md) | Aggiornato | Fixture/test aggiornati per regressioni numeriche |
| [`DIR_DIVING_IOS_PLANNER_LIMITATIONS.md`](DIR_DIVING_IOS_PLANNER_LIMITATIONS.md) | Aggiornato | Limiti planner/reference esplicitati post hardening |
| [`DIR_DIVING_IOS_BUHLMANN_REAUDIT_2026-05-28.md`](DIR_DIVING_IOS_BUHLMANN_REAUDIT_2026-05-28.md) | **Nuovo** | Re-audit statico planner Buhlmann/gas iOS @ `76fce90`–`a7d2961`: motore ZHL-16C N2+He, golden fixtures, finding P1/P2 |
| [`DIR_DIVING_Feature_Comparison.csv`](DIR_DIVING_Feature_Comparison.csv) | Aggiornato | Matrice feature aggiornata con stato iOS planner/Buhlmann |
| [`INDEX.md`](INDEX.md) | Aggiornato | Indicizzazione completa file nuovi/aggiornati 2026-05-28 |

Nota: aggiornamenti 2026-05-28 sono documentali/di validazione; non promuovono feature experimental nel runtime MAIN.

---

## Aggiornamento indice 2026-05-27 - current architecture, algorithm docs, branch safety

Pass documentale additivo su `main` dopo `37e4464`:

| Documento | Contenuto |
|-----------|-----------|
| [`DIR_DIVING_IOS_ALGORITHM_RELEASE_HARDENING.md`](DIR_DIVING_IOS_ALGORITHM_RELEASE_HARDENING.md) | Hardening iOS MAIN: validator, planner/gas safe states, import/export/sync/logbook math e test iOS |
| [`DIR_DIVING_IOS_BUHLMANN_ENGINE_DESIGN.md`](DIR_DIVING_IOS_BUHLMANN_ENGINE_DESIGN.md) | Design motore iOS MAIN: Buhlmann ZHL-16C N2+He multigas reference engine |
| [`DIR_DIVING_IOS_BUHLMANN_MATH_VERIFICATION.md`](DIR_DIVING_IOS_BUHLMANN_MATH_VERIFICATION.md) | Verifica matematica Buhlmann: costanti, formule, GF, NDL, multigas, robustezza numerica |
| [`DIR_DIVING_IOS_BUHLMANN_REFERENCE_CROSSCHECK.md`](DIR_DIVING_IOS_BUHLMANN_REFERENCE_CROSSCHECK.md) | Cross-check esterno a tolleranza larga con fixture decotengu ZHL-16C |
| [`DIR_DIVING_IOS_BUHLMANN_VALIDATION_FIXTURES.md`](DIR_DIVING_IOS_BUHLMANN_VALIDATION_FIXTURES.md) | Fixture/test iOS Algorithm per air, nitrox, trimix, deco gases, GF e helium loading |
| [`DIR_DIVING_IOS_GAS_BUHLMANN_PLANNER_IMPROVEMENT_PLAN.md`](DIR_DIVING_IOS_GAS_BUHLMANN_PLANNER_IMPROVEMENT_PLAN.md) | Piano migliorativo iOS per planner gas + Buhlmann: scope, hardening, QA e criteri release-ready |
| [`DIR_DIVING_IOS_PLANNER_LIMITATIONS.md`](DIR_DIVING_IOS_PLANNER_LIMITATIONS.md) | Limiti planner iOS: reference-only, assunzioni pressione, QA esterna richiesta |
| [`DIR_DIVING_IOS_BUHLMANN_MULTIGAS_ASSESSMENT.md`](DIR_DIVING_IOS_BUHLMANN_MULTIGAS_ASSESSMENT.md) | Assessment pre-implementazione con nota 2026-05-28 che rimanda al motore implementato |
| [`DIR_DIVING_WATCH_ALGORITHM_RELEASE_HARDENING_FINAL.md`](DIR_DIVING_WATCH_ALGORITHM_RELEASE_HARDENING_FINAL.md) | Final hardening Watch MAIN: cap 40 log, temperatura plausibile, export vuoto, GPS fallback, conversioni |
| [`DOCUMENTATION_BRANCH_ALIGNMENT_20260527.md`](DOCUMENTATION_BRANCH_ALIGNMENT_20260527.md) | Stato branch, divergenze, policy merge e isolamento experimental |
| [`DOCUMENTATION_UPDATE_REPORT_20260527.md`](DOCUMENTATION_UPDATE_REPORT_20260527.md) | Report A-O del pass documentale corrente |
| [`PR_STATUS_20260527.md`](PR_STATUS_20260527.md) | PR #8/#9 live via `gh`, experimental e non safe-to-merge automaticamente |

Nota corrente: Snorkeling, Apnea, Buddy Assist e concept iOS experimental restano esclusi dai target MAIN in `project.yml`; le schermate e gli screenshot experimental sono documentati ma non promossi in runtime stabile.

---

## Aggiornamento indice 2026-05-26 - documenti e asset indicizzati

Questa sezione indicizza in modo additivo i file documentali e gli asset tracciati che non erano citati esplicitamente nell'indice precedente. Non cambia il contenuto dei documenti indicizzati.

| Documento / asset | Tipo | Nota |
|-------------------|------|------|
| [`CODEX_DIR_DIVING_WATCH_ALGORITHM_MATH_AUDIT.md`](CODEX_DIR_DIVING_WATCH_ALGORITHM_MATH_AUDIT.md) | Audit algoritmico Watch MAIN | Audit 2026-05-26 su algoritmi, formule, costanti, edge case e test mancanti del target Apple Watch MAIN. |
| [`DIR_DIVING_WATCH_ALGORITHM_RELEASE_HARDENING.md`](DIR_DIVING_WATCH_ALGORITHM_RELEASE_HARDENING.md) | Hardening algoritmico Watch MAIN | P0/P1 fix, assunzioni finali, limiti residui e copertura test del pass release-hard. |
| [`Audits/DIR_DIVING_MAIN_BRANCH_READINESS_AUDIT_20260523.docx`](Audits/DIR_DIVING_MAIN_BRANCH_READINESS_AUDIT_20260523.docx) | Documento Word / audit storico | Indicizzato nel pass 2026-05-26; contenuto preservato senza modifiche. |
| [`DIR_DIVING_Piano_100_UX_UI_Watch_iOS_Sicurezza.docx`](DIR_DIVING_Piano_100_UX_UI_Watch_iOS_Sicurezza.docx) | Documento Word / audit storico | Indicizzato nel pass 2026-05-26; contenuto preservato senza modifiche. |
| [`EXPERIMENTAL_FUNCTIONS_UX_AUDIT_20260517_POST_FIX.docx`](EXPERIMENTAL_FUNCTIONS_UX_AUDIT_20260517_POST_FIX.docx) | Documento Word / audit storico | Indicizzato nel pass 2026-05-26; contenuto preservato senza modifiche. |
| [`EXPERIMENTAL_FUNCTIONS_UX_AUDIT_20260517_PRE_MODIFICATION.docx`](EXPERIMENTAL_FUNCTIONS_UX_AUDIT_20260517_PRE_MODIFICATION.docx) | Documento Word / audit storico | Indicizzato nel pass 2026-05-26; contenuto preservato senza modifiche. |
| [`EXPERIMENTAL_UX_INTERACTION_AUDIT_20260517.docx`](EXPERIMENTAL_UX_INTERACTION_AUDIT_20260517.docx) | Documento Word / audit storico | Indicizzato nel pass 2026-05-26; contenuto preservato senza modifiche. |
| [`FeatureScreenshots/01-live-dive.png`](FeatureScreenshots/01-live-dive.png) | Asset / screenshot documentale | Indicizzato nel pass 2026-05-26; contenuto preservato senza modifiche. |
| [`FeatureScreenshots/02-ascent-warning.png`](FeatureScreenshots/02-ascent-warning.png) | Asset / screenshot documentale | Indicizzato nel pass 2026-05-26; contenuto preservato senza modifiche. |
| [`FeatureScreenshots/03-ascent-settings.png`](FeatureScreenshots/03-ascent-settings.png) | Asset / screenshot documentale | Indicizzato nel pass 2026-05-26; contenuto preservato senza modifiche. |
| [`FeatureScreenshots/04-compass-bearing.png`](FeatureScreenshots/04-compass-bearing.png) | Asset / screenshot documentale | Indicizzato nel pass 2026-05-26; contenuto preservato senza modifiche. |
| [`FeatureScreenshots/05-stopwatch-action.png`](FeatureScreenshots/05-stopwatch-action.png) | Asset / screenshot documentale | Indicizzato nel pass 2026-05-26; contenuto preservato senza modifiche. |
| [`FeatureScreenshots/06-dive-log.png`](FeatureScreenshots/06-dive-log.png) | Asset / screenshot documentale | Indicizzato nel pass 2026-05-26; contenuto preservato senza modifiche. |
| [`FeatureScreenshots/07-dive-detail-export.png`](FeatureScreenshots/07-dive-detail-export.png) | Asset / screenshot documentale | Indicizzato nel pass 2026-05-26; contenuto preservato senza modifiche. |
| [`FeatureScreenshots/08-gps-entry-exit.png`](FeatureScreenshots/08-gps-entry-exit.png) | Asset / screenshot documentale | Indicizzato nel pass 2026-05-26; contenuto preservato senza modifiche. |
| [`FeatureScreenshots/09-user-images.png`](FeatureScreenshots/09-user-images.png) | Asset / screenshot documentale | Indicizzato nel pass 2026-05-26; contenuto preservato senza modifiche. |
| [`FeatureScreenshots/10-buddy-send.png`](FeatureScreenshots/10-buddy-send.png) | Asset / screenshot documentale | Indicizzato nel pass 2026-05-26; contenuto preservato senza modifiche. |
| [`FeatureScreenshots/11-buddy-answer.png`](FeatureScreenshots/11-buddy-answer.png) | Asset / screenshot documentale | Indicizzato nel pass 2026-05-26; contenuto preservato senza modifiche. |
| [`FeatureScreenshots/12-buddy-link-compass.png`](FeatureScreenshots/12-buddy-link-compass.png) | Asset / screenshot documentale | Indicizzato nel pass 2026-05-26; contenuto preservato senza modifiche. |
| [`iOS/FeatureScreenshots/01-buddy-lab.png`](iOS/FeatureScreenshots/01-buddy-lab.png) | Asset / screenshot documentale | Indicizzato nel pass 2026-05-26; contenuto preservato senza modifiche. |
| [`iOS/FeatureScreenshots/02-technical-planner.png`](iOS/FeatureScreenshots/02-technical-planner.png) | Asset / screenshot documentale | Indicizzato nel pass 2026-05-26; contenuto preservato senza modifiche. |
| [`iOS/FeatureScreenshots/03-plan-result-v1-v2.png`](iOS/FeatureScreenshots/03-plan-result-v1-v2.png) | Asset / screenshot documentale | Indicizzato nel pass 2026-05-26; contenuto preservato senza modifiche. |
| [`iOS/FeatureScreenshots/04-contingencies-briefing.png`](iOS/FeatureScreenshots/04-contingencies-briefing.png) | Asset / screenshot documentale | Indicizzato nel pass 2026-05-26; contenuto preservato senza modifiche. |
| [`MAIN_BRANCH_COMPLETE_READINESS_AUDIT_20260517.docx`](MAIN_BRANCH_COMPLETE_READINESS_AUDIT_20260517.docx) | Documento Word / audit storico | Indicizzato nel pass 2026-05-26; contenuto preservato senza modifiche. |
| [`MAIN_BRANCH_COMPLETE_READINESS_AUDIT_20260519.docx`](MAIN_BRANCH_COMPLETE_READINESS_AUDIT_20260519.docx) | Documento Word / audit storico | Indicizzato nel pass 2026-05-26; contenuto preservato senza modifiche. |
| [`MAIN_BRANCH_COMPLETE_READINESS_AUDIT_20260520.docx`](MAIN_BRANCH_COMPLETE_READINESS_AUDIT_20260520.docx) | Documento Word / audit storico | Indicizzato nel pass 2026-05-26; contenuto preservato senza modifiche. |
| [`MAIN_BRANCH_COMPLETE_READINESS_AUDIT_20260522.docx`](MAIN_BRANCH_COMPLETE_READINESS_AUDIT_20260522.docx) | Documento Word / audit storico | Indicizzato nel pass 2026-05-26; contenuto preservato senza modifiche. |
| [`MAIN_BRANCH_COMPLETE_READINESS_AUDIT_20260523.docx`](MAIN_BRANCH_COMPLETE_READINESS_AUDIT_20260523.docx) | Documento Word / audit storico | Indicizzato nel pass 2026-05-26; contenuto preservato senza modifiche. |
| [`MAIN_BRANCH_READINESS_AUDIT_FULL_20260519.docx`](MAIN_BRANCH_READINESS_AUDIT_FULL_20260519.docx) | Documento Word / audit storico | Indicizzato nel pass 2026-05-26; contenuto preservato senza modifiche. |
| [`MAIN_BRANCH_UX_INTERACTION_ACCESSIBILITY_AUDIT_20260523.docx`](MAIN_BRANCH_UX_INTERACTION_ACCESSIBILITY_AUDIT_20260523.docx) | Documento Word / audit storico | Indicizzato nel pass 2026-05-26; contenuto preservato senza modifiche. |
| [`MAIN_BRANCH_UX_INTERACTION_ACCESSIBILITY_AUDIT_20260524.docx`](MAIN_BRANCH_UX_INTERACTION_ACCESSIBILITY_AUDIT_20260524.docx) | Documento Word / audit storico | Indicizzato nel pass 2026-05-26; contenuto preservato senza modifiche. |
| [`MAIN_BRANCH_UX_INTERACTION_ACCESSIBILITY_AUDIT_20260524_CURRENT_PRE_MODIFICATION.docx`](MAIN_BRANCH_UX_INTERACTION_ACCESSIBILITY_AUDIT_20260524_CURRENT_PRE_MODIFICATION.docx) | Documento Word / audit storico | Indicizzato nel pass 2026-05-26; contenuto preservato senza modifiche. |
| [`MAIN_BRANCH_UX_INTERACTION_ACCESSIBILITY_AUDIT_CURRENT.docx`](MAIN_BRANCH_UX_INTERACTION_ACCESSIBILITY_AUDIT_CURRENT.docx) | Documento Word / audit storico | Indicizzato nel pass 2026-05-26; contenuto preservato senza modifiche. |
| [`MAIN_BRANCH_UX_INTERACTION_ACCESSIBILITY_AUDIT_CURRENT.md`](MAIN_BRANCH_UX_INTERACTION_ACCESSIBILITY_AUDIT_CURRENT.md) | Documento Markdown | Indicizzato nel pass 2026-05-26; contenuto preservato senza modifiche. |
| [`MAIN_BRANCHES_UX_INTERACTION_AUDIT_20260517_CURRENT_PRE_MODIFICATION.docx`](MAIN_BRANCHES_UX_INTERACTION_AUDIT_20260517_CURRENT_PRE_MODIFICATION.docx) | Documento Word / audit storico | Indicizzato nel pass 2026-05-26; contenuto preservato senza modifiche. |
| [`MAIN_BRANCHES_UX_INTERACTION_AUDIT_20260517_PRE_MODIFICATION.docx`](MAIN_BRANCHES_UX_INTERACTION_AUDIT_20260517_PRE_MODIFICATION.docx) | Documento Word / audit storico | Indicizzato nel pass 2026-05-26; contenuto preservato senza modifiche. |
| [`MAIN_BRANCHES_UX_INTERACTION_AUDIT_20260518_CURRENT_PRE_MODIFICATION.docx`](MAIN_BRANCHES_UX_INTERACTION_AUDIT_20260518_CURRENT_PRE_MODIFICATION.docx) | Documento Word / audit storico | Indicizzato nel pass 2026-05-26; contenuto preservato senza modifiche. |
| [`MAIN_BRANCHES_UX_INTERACTION_AUDIT_20260518_POST_FIX_PRE_MODIFICATION.docx`](MAIN_BRANCHES_UX_INTERACTION_AUDIT_20260518_POST_FIX_PRE_MODIFICATION.docx) | Documento Word / audit storico | Indicizzato nel pass 2026-05-26; contenuto preservato senza modifiche. |
| [`MAIN_BRANCHES_UX_INTERACTION_AUDIT_20260518_PRE_MODIFICATION.docx`](MAIN_BRANCHES_UX_INTERACTION_AUDIT_20260518_PRE_MODIFICATION.docx) | Documento Word / audit storico | Indicizzato nel pass 2026-05-26; contenuto preservato senza modifiche. |
| [`MAIN_BRANCHES_UX_INTERACTION_AUDIT_20260519_CURRENT_PRE_MODIFICATION.docx`](MAIN_BRANCHES_UX_INTERACTION_AUDIT_20260519_CURRENT_PRE_MODIFICATION.docx) | Documento Word / audit storico | Indicizzato nel pass 2026-05-26; contenuto preservato senza modifiche. |
| [`ReferenceIcon/apple watch icon.png`](<ReferenceIcon/apple watch icon.png>) | Asset / screenshot documentale | Indicizzato nel pass 2026-05-26; contenuto preservato senza modifiche. |
| [`ReferenceIcon/ios icon.png`](<ReferenceIcon/ios icon.png>) | Asset / screenshot documentale | Indicizzato nel pass 2026-05-26; contenuto preservato senza modifiche. |

---

## 0. Note di sviluppo prodotto (MAIN) — leggere per backlog

| Documento | Contenuto | Stato |
|-----------|-----------|--------|
| [`DIR_Diving_Complete_Development_Notes_UPDATED_v10.md`](DIR_Diving_Complete_Development_Notes_UPDATED_v10.md) | **Note sviluppo complete aggiornate (v10)** — backlog/spec iOS + Apple Watch aggiornato al 2026-05-25 | **Corrente (spec)** — file locale indicizzato |
| [`DIR_Diving_Complete_Development_Notes_UPDATED_v9.md`](DIR_Diving_Complete_Development_Notes_UPDATED_v9.md) | **Note sviluppo complete aggiornate (v9)** — iOS + Watch: icone, equipment, planner gas/Bühlmann, MOD, Watch allarmi/nav, checklist GAS | Spec precedente |
| [`DIR_Diving_Complete_Development_Notes_UPDATED_v8.md`](DIR_Diving_Complete_Development_Notes_UPDATED_v8.md) | Note sviluppo v8 (stesso ambito di v9; in caso di differenze preferire **v9**) | Spec precedente |
| [`DIR_DIVING_v8_IMPLEMENTATION_REPORT.md`](DIR_DIVING_v8_IMPLEMENTATION_REPORT.md) | Report implementazione v8 in codice: gas mix Air/EAN/Trimix, MOD, schedule travel/bailout, disclaimer trimix Bühlmann | **Completato** @ `a36dc23` |
| [`DIR_DIVING_v9_IMPLEMENTATION_REPORT.md`](DIR_DIVING_v9_IMPLEMENTATION_REPORT.md) | Report implementazione v9: immagini Watch in superficie, sync Planner/Bühlmann su input | **Completato** @ `d962117` |
| [`PRODUCT_FEATURES_IT.md`](PRODUCT_FEATURES_IT.md) | Panoramica funzionalità MAIN/experimental, modalità, i18n, branch strategy | Corrente @ `2322145` + pass docs 2026-05-26 |
| [`DIR_Diving_Complete_Development_Notes_25_05_2026.md`](DIR_Diving_Complete_Development_Notes_25_05_2026.md) | Prima versione note 25/05/2026 (stesso ambito; usare v9/v8 se in conflitto) | Archivio / baseline |
| [`DEVELOPMENT_NOTES_25_05_2026_IMPLEMENTATION_REPORT.md`](DEVELOPMENT_NOTES_25_05_2026_IMPLEMENTATION_REPORT.md) | Implementazione codice note 25/05 (`c23d4d4`) | Completato |
| [`APP_ICON_UPDATE_NOTES.md`](APP_ICON_UPDATE_NOTES.md) | Rigenerazione icone (`Scripts/update_app_icons.sh`) + cache Simulator | Operativo |
| [`MAIN_BRANCH_UX_INTERACTION_ACCESSIBILITY_AUDIT_20260524_POST_DEV_NOTES.md`](MAIN_BRANCH_UX_INTERACTION_ACCESSIBILITY_AUDIT_20260524_POST_DEV_NOTES.md) | Audit UX post-implementazione @ `c23d4d4` · [`.docx`](MAIN_BRANCH_UX_INTERACTION_ACCESSIBILITY_AUDIT_20260524_POST_DEV_NOTES.docx) | Pre-fix B1/B2/B4/B6 |
| — | Fix UX B1/B2/B4/B6 (`9600015`): auto-dive copy, log bloccato in immersione, planner unità display, editor manuale | In `main` |
| — | Planner v8 codice (`a36dc23`): `PlannerGasSchedule`, `PlannerGasMixCard`, MOD block Calcola, N₂ Bühlmann trimix | In `main` |

---

## 1. Documento principale (leggere per primo)

### [`MAIN_BRANCH_COMPLETE_READINESS_AUDIT_2026-05-25.md`](MAIN_BRANCH_COMPLETE_READINESS_AUDIT_2026-05-25.md)

Audit completo **MAIN** (Watch + iOS companion), struttura A–O. Versione Word: [`MAIN_BRANCH_COMPLETE_READINESS_AUDIT_2026-05-25.docx`](MAIN_BRANCH_COMPLETE_READINESS_AUDIT_2026-05-25.docx). Audit pre-modifica redatto su `main` @ `21a7f41`, poi riallineato documentalmene sulla baseline corrente `main` e aggiornato nei delta documentali fino al pass 2026-05-26.

| Sezione | Contenuto |
|---------|-----------|
| **A** | Branch, target, `project.yml`, build e separazione target MAIN / experimental |
| **B** | Executive summary (repo-side 100%, overall 84% nel report 2026-05-25) |
| **C** | Feature inventory (Watch + iOS: impl / reach / usable / complete) |
| **D** | Navigation map (flussi Watch e iOS, dead end) |
| **E** | UI consistency vs reference (`Docs/ReferenceUI/`) |
| **F** | Settings (unità, allarmi, haptic, cloud, export) |
| **G** | Haptics / tones |
| **H** | Hardware (Crown, Action Button, App Intents) |
| **I** | Sync Watch ↔ iPhone, iCloud KVS |
| **J** | Export Subsurface CSV |
| **K** | Safety / disclaimer / non dive computer |
| **L** | Empty / error states |
| **M** | **Bugs to fix** (tabella con file e severità) |
| **N** | Priority roadmap (compile → TestFlight → App Store → post-release) |
| **O** | Final verdict (compile / utente medio / TestFlight / App Store) |
| **Validation log** | `xcodegen` + simulator build pass; generic device build bloccato da entitlement/provisioning |

**Bug critici elencati in §M (versione audit 2026-05-25; distinguere fra fix repo-side chiusi e blocchi esterni ancora aperti):**

| Bug | File indicato |
|-----|----------------|
| Entitlement `water-submersion` non approvato nel provisioning attivo | Apple Developer / profili / build generici |
| Build generico iOS bloccato dal target Watch embedded | Coppia iOS + Watch release |
| Automatic dive lifecycle non validato su hardware Ultra reale | Device QA |
| Repo-side issues del dated audit | **Risolti** su `main` (baseline commit `2322145`, con delta documentali 2026-05-26) — legal links dedicati, wording entitlement, BUSSOLA/planner i18n, recent sync activity, safeguard reset cronometro, docs branch alignment corrente |

> **Nota:** `e1cc982`–`fc08466`: build simulator Watch/iOS verde; i18n Equipment/Planner; checklist device QA in §6.

**Audit readiness precedenti (storico):**

| File | Uso |
|------|-----|
| [`MAIN_BRANCH_COMPLETE_READINESS_AUDIT_20260524.md`](MAIN_BRANCH_COMPLETE_READINESS_AUDIT_20260524.md) | Pass precedente, baseline immediata prima del dated audit 2026-05-25 |
| [`MAIN_BRANCH_COMPLETE_READINESS_AUDIT_20260520.md`](MAIN_BRANCH_COMPLETE_READINESS_AUDIT_20260520.md) | Pass R2–R4, baseline `db72dce` / WIP |
| [`MAIN_BRANCH_COMPLETE_READINESS_AUDIT_20260523.md`](MAIN_BRANCH_COMPLETE_READINESS_AUDIT_20260523.md) | Pass readiness 100% UX |
| [`MAIN_BRANCH_COMPLETE_READINESS_AUDIT_20260522.md`](MAIN_BRANCH_COMPLETE_READINESS_AUDIT_20260522.md) | Onboarding legale |

**Audit planner / Bühlmann iOS MAIN (read-only):**

| File | Uso |
|------|-----|
| [`DIR_DIVING_IOS_BUHLMANN_COMPREHENSIVE_READINESS_AUDIT_UPDATED.md`](DIR_DIVING_IOS_BUHLMANN_COMPREHENSIVE_READINESS_AUDIT_UPDATED.md) | **Audit comprehensive corrente** (2026-06-04 @ `63ee0b4`): Bühlmann + CNS/OTU + UX planner; verdict *Partially ready*; **P0/P1 OTU formula** |
| [`DIR_DIVING_IOS_BUHLMANN_COMPREHENSIVE_READINESS_AUDIT.md`](DIR_DIVING_IOS_BUHLMANN_COMPREHENSIVE_READINESS_AUDIT.md) | Audit comprehensive @ `e1370f7` (2026-05-30) — superseded per snapshot OTU/post-`40bf110` dall’audit **UPDATED** |
| [`DIR_DIVING_IOS_BUHLMANN_REAUDIT_2026-05-28.md`](DIR_DIVING_IOS_BUHLMANN_REAUDIT_2026-05-28.md) | Re-audit post motore ZHL-16C N2+He, golden fixtures e hardening gas: scope iOS-only, verdict, file ispezionati, finding P1–P3 (**risolti** @ `69e69b2`); complementa [`DIR_DIVING_IOS_BUHLMANN_ENGINE_DESIGN.md`](DIR_DIVING_IOS_BUHLMANN_ENGINE_DESIGN.md) e [`DIR_DIVING_IOS_ALGORITHM_MATH_AUDIT.md`](DIR_DIVING_IOS_ALGORITHM_MATH_AUDIT.md) |
| [`DIR_DIVING_IOS_BUHLMANN_UX_UI_READINESS_AUDIT.md`](DIR_DIVING_IOS_BUHLMANN_UX_UI_READINESS_AUDIT.md) | Audit UX/UI readiness planner Bühlmann iOS (Docs): verdict *Partially ready*; gap UI su repetitive planning, ledger per cilindro, copy ambiente — **non** coperti dal fix algoritmico @ `69e69b2` |

---

## 2. Stato repo, branch e PR

| Documento | Contenuto |
|-----------|-----------|
| [`DOCUMENTATION_BRANCH_ALIGNMENT_20260526.md`](DOCUMENTATION_BRANCH_ALIGNMENT_20260526.md) | Allineamento corrente 2026-05-26: `main` baseline stabile, `main-iOS` worktree storico divergente, `codex/*` experimental-only |
| [`DOCUMENTATION_BRANCH_ALIGNMENT_20260527.md`](DOCUMENTATION_BRANCH_ALIGNMENT_20260527.md) | Allineamento corrente 2026-05-27: `main` stabile, branch tracciati allineati ai remoti, PR #8/#9 experimental e non auto-merge |
| [`DOCUMENTATION_UPDATE_REPORT_20260526.md`](DOCUMENTATION_UPDATE_REPORT_20260526.md) | Report aggiornamento documentazione/repository consistency corrente |
| [`DOCUMENTATION_UPDATE_REPORT_20260527.md`](DOCUMENTATION_UPDATE_REPORT_20260527.md) | Report aggiornamento documentazione/repository consistency corrente post iOS algorithm/Buhlmann assessment |
| [`PR_STATUS_20260526.md`](PR_STATUS_20260526.md) | Stato PR/merge safety 2026-05-26 con divergenza branch aggiornata e limiti ambiente correnti |
| [`PR_STATUS_20260527.md`](PR_STATUS_20260527.md) | Stato PR/merge safety 2026-05-27 da `gh pr list` |
| [`DOCUMENTATION_BRANCH_ALIGNMENT_20260525.md`](DOCUMENTATION_BRANCH_ALIGNMENT_20260525.md) | Allineamento corrente: `main` canonico, `main-iOS` worktree storico divergente, experimental isolato |
| [`DOCUMENTATION_UPDATE_REPORT_20260525.md`](DOCUMENTATION_UPDATE_REPORT_20260525.md) | Report aggiornamento documentazione corrente |
| [`PR_STATUS_20260525.md`](PR_STATUS_20260525.md) | Stato PR/merge safety 2026-05-25 con limiti ambiente correnti |
| [`DOCUMENTATION_BRANCH_ALIGNMENT_20260520_POST_V9.md`](DOCUMENTATION_BRANCH_ALIGNMENT_20260520_POST_V9.md) | Allineamento branch post v9 @ `d962117` |
| [`DOCUMENTATION_UPDATE_REPORT_20260520_POST_V9.md`](DOCUMENTATION_UPDATE_REPORT_20260520_POST_V9.md) | Report A–K pass documentazione post v9 |
| [`PR_STATUS_20260520_POST_V9.md`](PR_STATUS_20260520_POST_V9.md) | Stato PR #8/#9 post v9 |
| [`DOCUMENTATION_BRANCH_ALIGNMENT_20260524.md`](DOCUMENTATION_BRANCH_ALIGNMENT_20260524.md) | Branch `main` / `main-iOS` / experimental; regole merge; R2–R4 (storico) |
| [`DOCUMENTATION_UPDATE_REPORT_20260524.md`](DOCUMENTATION_UPDATE_REPORT_20260524.md) | Report A–K pass docs post `bd129ca` / `86ef349` |
| [`DOCUMENTATION_UPDATE_REPORT_20260524_CONTROL_STRATEGY.md`](DOCUMENTATION_UPDATE_REPORT_20260524_CONTROL_STRATEGY.md) | Docs post Watch control strategy (`72fa15b`) |
| [`PR_STATUS_20260524.md`](PR_STATUS_20260524.md) | PR #8 / #9 — non auto-merge |
| [`DOCUMENTATION_BRANCH_ALIGNMENT_20260523.md`](DOCUMENTATION_BRANCH_ALIGNMENT_20260523.md) | Allineamento precedente |
| [`PR_STATUS_20260523.md`](PR_STATUS_20260523.md) | Stato PR storico |
| [`PR_STATUS_20260520.md`](PR_STATUS_20260520.md) | Stato PR storico (20260520) |
| [`DOCUMENTATION_SYNC_REPORT_20260519.md`](DOCUMENTATION_SYNC_REPORT_20260519.md) | Sync documentazione multi-branch |
| [`DOCUMENTATION_BRANCH_ALIGNMENT_20260518.md`](DOCUMENTATION_BRANCH_ALIGNMENT_20260518.md) | Allineamento branch (archivio) |
| [`DOCUMENTATION_BRANCH_ALIGNMENT_20260519.md`](DOCUMENTATION_BRANCH_ALIGNMENT_20260519.md) | Allineamento branch (archivio) |
| [`DOCUMENTATION_BRANCH_ALIGNMENT_20260520.md`](DOCUMENTATION_BRANCH_ALIGNMENT_20260520.md) | Allineamento branch (archivio) |
| [`DOCUMENTATION_BRANCH_ALIGNMENT_20260522.md`](DOCUMENTATION_BRANCH_ALIGNMENT_20260522.md) | Allineamento branch (archivio) |

---

## 3. Watch MAIN — UX, controlli, sicurezza

| Documento | Contenuto |
|-----------|-----------|
| [`DIRDIVING_WATCH_PHOTO_TRANSFER_AUDIT_REPORT_20260605.md`](DIRDIVING_WATCH_PHOTO_TRANSFER_AUDIT_REPORT_20260605.md) | **Audit** transfer foto iOS → Watch @ `ca76a19` (2026-06-05) — gap ack delivery, UX galleria |
| [`DIRDIVING_WATCH_PHOTO_TRANSFER_IMPLEMENTATION_REPORT_20260605.md`](DIRDIVING_WATCH_PHOTO_TRANSFER_IMPLEMENTATION_REPORT_20260605.md) | **Implementazione** remediation transfer foto iOS → Watch (2026-06-05) — lifecycle, ACK, UUID, test |
| [`DIRDIVING_WATCH_IMAGE_DELETE_OPTIONS_PLAN_20260605.txt`](DIRDIVING_WATCH_IMAGE_DELETE_OPTIONS_PLAN_20260605.txt) | **Piano** delete immagini Watch (2026-06-05) — Opzione 1 Watch-first; Opzione 2 iOS+ACK |
| [`WATCH_CONTROL_STRATEGY_IMPLEMENTATION_REPORT.md`](WATCH_CONTROL_STRATEGY_IMPLEMENTATION_REPORT.md) | Crown, Settings, App Intents, haptics (`72fa15b`) |
| [`WATCH_MAIN_UX_CONVENTIONS.md`](WATCH_MAIN_UX_CONVENTIONS.md) | Banner risalita inline, layout Live, BUSSOLA |
| [`MISSION_MODE_MAIN_WATCH.md`](MISSION_MODE_MAIN_WATCH.md) | Mission Mode MAIN: persistenza, attivazione/disattivazione, scope runtime e safety exclusions |
| [`WATCH_MAIN_ALGORITHM_MATH_AUDIT_CURRENT.md`](WATCH_MAIN_ALGORITHM_MATH_AUDIT_CURRENT.md) | **Audit corrente** Watch MAIN @ `main`: pre-audit ~82%; post-remediation **100%** codice — [`WATCH_MAIN_ALGORITHM_READINESS_100_REPORT.md`](WATCH_MAIN_ALGORITHM_READINESS_100_REPORT.md) |
| [`WATCH_MAIN_ALGORITHM_READINESS_100_REPORT.md`](WATCH_MAIN_ALGORITHM_READINESS_100_REPORT.md) | Report readiness 100% Watch MAIN (codice + test) |
| [`WATCH_MANUAL_NODEPTH_SYNC_POLICY.md`](WATCH_MANUAL_NODEPTH_SYNC_POLICY.md) | Policy sync manual/no-depth Watch → iOS |
| [`CODEX_DIR_DIVING_WATCH_ALGORITHM_MATH_AUDIT.md`](CODEX_DIR_DIVING_WATCH_ALGORITHM_MATH_AUDIT.md) | Audit Watch pre-hardening @ `ddaf2d7` |
| [`DIR_DIVING_WATCH_ALGORITHM_RELEASE_HARDENING.md`](DIR_DIVING_WATCH_ALGORITHM_RELEASE_HARDENING.md) | Release-hard pass @ `92e639a` + XCTest |
| [`DIR_DIVING_WATCH_ALGORITHM_RELEASE_HARDENING_FINAL.md`](DIR_DIVING_WATCH_ALGORITHM_RELEASE_HARDENING_FINAL.md) | Final hardening: cap log 40, temperature, export vuoto, GPS fallback |
| [`DIR_DIVING_WATCH_ALGORITHM_MATH_AUDIT.md`](DIR_DIVING_WATCH_ALGORITHM_MATH_AUDIT.md) | **Audit Docs** Watch MAIN post-hardening (2026-05-27) |
| [`ASCENT_ALARM_IMPLEMENTATION_REPORT_20260520.md`](ASCENT_ALARM_IMPLEMENTATION_REPORT_20260520.md) | Implementazione allarme risalita |
| [`DEPTH_LIMIT_SAFETY_TEST_CHECKLIST.md`](DEPTH_LIMIT_SAFETY_TEST_CHECKLIST.md) | QA 35 / 38 / 40 m |
| [`TESTFLIGHT_ENTITLEMENT_AND_DEVICE_QA_20260523.md`](TESTFLIGHT_ENTITLEMENT_AND_DEVICE_QA_20260523.md) | **R1** entitlement + Ultra |
| [`TESTFLIGHT_REVIEW_NOTES.md`](TESTFLIGHT_REVIEW_NOTES.md) | Note revisore App Store |

---

## 4. iOS MAIN — UX, audit, implementazione

| Documento | Contenuto |
|-----------|-----------|
| [`IOS_MAIN_ALGORITHM_MATH_AUDIT_CURRENT.md`](IOS_MAIN_ALGORITHM_MATH_AUDIT_CURRENT.md) | **Audit corrente** iOS Companion MAIN — @ `81f2d7f` (~92%); indicizzato @ `c723295`; remediation storica @ `dce89e7` |
| [`IOS_MAIN_ALGORITHM_READINESS_100_REPORT.md`](IOS_MAIN_ALGORITHM_READINESS_100_REPORT.md) | Report remediation iOS MAIN @ `dce89e7` |
| [`WATCH_MAIN_ALGORITHM_MATH_AUDIT_CURRENT.md`](WATCH_MAIN_ALGORITHM_MATH_AUDIT_CURRENT.md) | Audit corrente Watch MAIN — remediation **100%** codice |
| [`WATCH_MAIN_ALGORITHM_READINESS_100_REPORT.md`](WATCH_MAIN_ALGORITHM_READINESS_100_REPORT.md) | Report finale Watch MAIN readiness |
| [`MAIN_BRANCH_UX_INTERACTION_ACCESSIBILITY_AUDIT_20260524_CURRENT_PRE_MODIFICATION.md`](MAIN_BRANCH_UX_INTERACTION_ACCESSIBILITY_AUDIT_20260524_CURRENT_PRE_MODIFICATION.md) | **Audit UX/interaction/accessibilità PRE-MOD** @ `8a4d10e` (`.docx` omonimo) |
| [`MAIN_BRANCH_UX_INTERACTION_ACCESSIBILITY_AUDIT_20260524.md`](MAIN_BRANCH_UX_INTERACTION_ACCESSIBILITY_AUDIT_20260524.md) | Audit UX/a11y precedente (`.docx` omonimo) |
| [`MAIN_BRANCH_UX_INTERACTION_ACCESSIBILITY_AUDIT_20260523.md`](MAIN_BRANCH_UX_INTERACTION_ACCESSIBILITY_AUDIT_20260523.md) | Audit precedente |
| [`MAIN_BRANCH_FINAL_READINESS_REPORT.md`](MAIN_BRANCH_FINAL_READINESS_REPORT.md) | **Report finale** pass readiness ~94% (build, i18n, copy, QA docs; device-only residui) |
| [`APP_INTENTS_DEVICE_QA_CHECKLIST.md`](APP_INTENTS_DEVICE_QA_CHECKLIST.md) | QA hardware: 7 App Intents + Action Button |
| [`WATCH_IOS_SYNC_DEVICE_QA_CHECKLIST.md`](WATCH_IOS_SYNC_DEVICE_QA_CHECKLIST.md) | QA hardware: sync, conflitti, tombstone, unità |
| [`MAIN_BRANCH_TARGETED_FIX_REPORT.md`](MAIN_BRANCH_TARGETED_FIX_REPORT.md) | Fix `db72dce` (gauge, intents, detail) |
| [`MAIN_ISSUES_IMPLEMENTATION_REPORT_20260520.md`](MAIN_ISSUES_IMPLEMENTATION_REPORT_20260520.md) | Implementazione issue backlog |
| [`MAIN_BRANCH_ISSUES_AND_PRIORITIES_20260520.md`](MAIN_BRANCH_ISSUES_AND_PRIORITIES_20260520.md) | Priorità issue |
| [`DIR_Diving_Main_Branch_Development_Notes.md`](DIR_Diving_Main_Branch_Development_Notes.md) | Note prodotto storiche (unità, disclaimer, manual dive) |
| [`DIR_Diving_Complete_Development_Notes_UPDATED_v10.md`](DIR_Diving_Complete_Development_Notes_UPDATED_v10.md) | → vedi **§0** (spec prodotto **corrente**) |
| [`DIR_Diving_Complete_Development_Notes_UPDATED_v9.md`](DIR_Diving_Complete_Development_Notes_UPDATED_v9.md) | → vedi **§0** (spec prodotto precedente) |
| [`DIR_Diving_Complete_Development_Notes_UPDATED_v8.md`](DIR_Diving_Complete_Development_Notes_UPDATED_v8.md) | → vedi **§0** |
| [`DIR_DIVING_v8_IMPLEMENTATION_REPORT.md`](DIR_DIVING_v8_IMPLEMENTATION_REPORT.md) | → vedi **§0** (implementazione v8 in codice) |
| [`DIR_DIVING_v9_IMPLEMENTATION_REPORT.md`](DIR_DIVING_v9_IMPLEMENTATION_REPORT.md) | → vedi **§0** (implementazione v9 in codice) |
| [`DIR_Diving_Complete_Development_Notes_25_05_2026.md`](DIR_Diving_Complete_Development_Notes_25_05_2026.md) | → vedi **§0** |
| [`DEVELOPMENT_NOTES_25_05_2026_IMPLEMENTATION_REPORT.md`](DEVELOPMENT_NOTES_25_05_2026_IMPLEMENTATION_REPORT.md) | → vedi **§0** |
| [`MAIN_BRANCH_UX_INTERACTION_ACCESSIBILITY_AUDIT_20260524_POST_DEV_NOTES.md`](MAIN_BRANCH_UX_INTERACTION_ACCESSIBILITY_AUDIT_20260524_POST_DEV_NOTES.md) | → vedi **§0** |
| [`APP_ICON_UPDATE_NOTES.md`](APP_ICON_UPDATE_NOTES.md) | → vedi **§0** |
| [`DIR_DIVING_MAIN_BRANCH_DEVELOPMENT_IMPLEMENTATION_REPORT.md`](DIR_DIVING_MAIN_BRANCH_DEVELOPMENT_IMPLEMENTATION_REPORT.md) | Report implementazione storico `f851b61` |
| [`iOS/BUILD_AND_RUN.md`](iOS/BUILD_AND_RUN.md) | Build companion iOS |
| [`iOS/SUBSURFACE_EXPORT.md`](iOS/SUBSURFACE_EXPORT.md) | Export CSV |
| [`iOS/SAFETY_DISCLAIMER.md`](iOS/SAFETY_DISCLAIMER.md) | Disclaimer iOS |
| [`iOS/VALIDATION_REPORT.md`](iOS/VALIDATION_REPORT.md) | Validazione iOS |
| [`iOS/MOCKUP_COHERENCE.md`](iOS/MOCKUP_COHERENCE.md) | Coerenza mockup |
| [`iOS/GITHUB_SETUP.md`](iOS/GITHUB_SETUP.md) | Setup GitHub |
| [`IOS_TAB_TARGET_MISMATCH_REPORT.md`](IOS_TAB_TARGET_MISMATCH_REPORT.md) | Tab vs target |
| [`IOS_TAB_TARGET_MISMATCH_STATUS_20260519.md`](IOS_TAB_TARGET_MISMATCH_STATUS_20260519.md) | Stato mismatch |
| [`DIR_DIVING_IOS_BUHLMANN_REAUDIT_2026-05-28.md`](DIR_DIVING_IOS_BUHLMANN_REAUDIT_2026-05-28.md) | Re-audit Buhlmann/gas planner iOS MAIN |
| [`DIR_DIVING_IOS_ALGORITHM_MATH_AUDIT.md`](DIR_DIVING_IOS_ALGORITHM_MATH_AUDIT.md) | **Audit Docs** algoritmi/math iOS Companion MAIN |
| [`DIR_DIVING_IOS_BUHLMANN_UX_UI_READINESS_AUDIT.md`](DIR_DIVING_IOS_BUHLMANN_UX_UI_READINESS_AUDIT.md) | **Audit Docs** UX/UI readiness planner Bühlmann iOS — gap UI post-fix algoritmico |

---

## 5. Matrice feature e roadmap

| Documento | Contenuto |
|-----------|-----------|
| [`DIR_DIVING_Feature_Comparison.csv`](DIR_DIVING_Feature_Comparison.csv) | **Matrice master** — Watch Main / Experimental / iOS / status / i18n |
| [`Branch_Functionality_Matrix.xlsx`](Branch_Functionality_Matrix.xlsx) | Export Excel (derivato da CSV) |
| [`ROADMAP.md`](ROADMAP.md) | Fatto / prossimi passi |
| [`MAIN_PRE_RELEASE_OPEN_ITEMS_20260519.md`](MAIN_PRE_RELEASE_OPEN_ITEMS_20260519.md) | Backlog pre-release |
| [`GLOSSARY.md`](GLOSSARY.md) | Glossario termini |

---

## 6. Build, release, sicurezza

| Documento | Contenuto |
|-----------|-----------|
| [`BUILD_VALIDATION.md`](BUILD_VALIDATION.md) | `xcodegen`, scheme, build; troubleshooting GPS views / `xcodegen generate` |
| [`APP_ICON_UPDATE_NOTES.md`](APP_ICON_UPDATE_NOTES.md) | Icone app: `../Scripts/update_app_icons.sh`, Derived Data |
| [`RELEASE_CHECKLIST.md`](RELEASE_CHECKLIST.md) | Checklist release |
| [`DIR_DIVING_WATCH_ALGORITHM_RELEASE_HARDENING_FINAL.md`](DIR_DIVING_WATCH_ALGORITHM_RELEASE_HARDENING_FINAL.md) | Hardening algoritmico finale Watch MAIN |
| [`DIR_DIVING_IOS_ALGORITHM_RELEASE_HARDENING.md`](DIR_DIVING_IOS_ALGORITHM_RELEASE_HARDENING.md) | Hardening algoritmico iOS MAIN |
| [`DIR_DIVING_IOS_BUHLMANN_COMPREHENSIVE_READINESS_AUDIT_UPDATED.md`](DIR_DIVING_IOS_BUHLMANN_COMPREHENSIVE_READINESS_AUDIT_UPDATED.md) | **Audit comprehensive planner** 2026-06-04 — OTU blocker, risk matrix P0–P4 |
| [`DIR_DIVING_IOS_BUHLMANN_COMPREHENSIVE_READINESS_AUDIT.md`](DIR_DIVING_IOS_BUHLMANN_COMPREHENSIVE_READINESS_AUDIT.md) | Audit comprehensive 2026-05-30 (baseline) |
| [`DIR_DIVING_IOS_BUHLMANN_ENGINE_DESIGN.md`](DIR_DIVING_IOS_BUHLMANN_ENGINE_DESIGN.md) | Motore Buhlmann ZHL-16C N2+He multigas iOS |
| [`DIR_DIVING_IOS_BUHLMANN_MATH_VERIFICATION.md`](DIR_DIVING_IOS_BUHLMANN_MATH_VERIFICATION.md) | Verifica matematica e statica del motore Buhlmann iOS |
| [`DIR_DIVING_IOS_BUHLMANN_VALIDATION_FIXTURES.md`](DIR_DIVING_IOS_BUHLMANN_VALIDATION_FIXTURES.md) | Fixture e test iOS Buhlmann |
| [`DIR_DIVING_IOS_BUHLMANN_FIXTURE_SOURCES.md`](DIR_DIVING_IOS_BUHLMANN_FIXTURE_SOURCES.md) | Origine fixture golden/regression e tolleranze dichiarate |
| [`DIR_DIVING_IOS_BUHLMANN_REFERENCE_CROSSCHECK.md`](DIR_DIVING_IOS_BUHLMANN_REFERENCE_CROSSCHECK.md) | Envelope di riferimento esterno per Air, Nitrox e Trimix multigas |
| [`DIR_DIVING_IOS_PLANNER_LIMITATIONS.md`](DIR_DIVING_IOS_PLANNER_LIMITATIONS.md) | Limiti planner reference-only |
| [`DIR_Diving_Planner_Tabs_Implementation_Plan.md`](DIR_Diving_Planner_Tabs_Implementation_Plan.md) | **Piano implementazione** tab modalità Planner iOS Base / Deco / Tecnico @ `25e12d9` |
| [`DIR_DIVING_IOS_PLANNER_DECO_TABLE_BUHLMANN_CURVE_AUDIT_CURRENT.md`](DIR_DIVING_IOS_PLANNER_DECO_TABLE_BUHLMANN_CURVE_AUDIT_CURRENT.md) | Audit statico tab risalita + curva Bühlmann vs reference @ `c3d1164` |
| [`DIR_DIVING_IOS_GAS_BUHLMANN_PLANNER_IMPROVEMENT_PLAN.md`](DIR_DIVING_IOS_GAS_BUHLMANN_PLANNER_IMPROVEMENT_PLAN.md) | Piano migliorativo planner gas+Buhlmann iOS (scope, roadmap, QA) |
| [`DIR_DIVING_IOS_BUHLMANN_MULTIGAS_ASSESSMENT.md`](DIR_DIVING_IOS_BUHLMANN_MULTIGAS_ASSESSMENT.md) | Assessment pre-implementazione ora superseded da design/fixture |
| [`DIR_DIVING_IOS_BUHLMANN_REAUDIT_2026-05-28.md`](DIR_DIVING_IOS_BUHLMANN_REAUDIT_2026-05-28.md) | Re-audit Buhlmann post golden fixtures e hardening (P1–P3 fix @ `69e69b2`) |
| [`DIR_DIVING_IOS_ALGORITHM_MATH_AUDIT.md`](DIR_DIVING_IOS_ALGORITHM_MATH_AUDIT.md) | Audit iOS algorithm/math |
| [`DIR_DIVING_IOS_BUHLMANN_UX_UI_READINESS_AUDIT.md`](DIR_DIVING_IOS_BUHLMANN_UX_UI_READINESS_AUDIT.md) | **Audit Docs** UX/UI readiness Bühlmann — repetitive UI, per-cylinder ledger, environment copy |
| [`SAFETY_DISCLAIMER.md`](SAFETY_DISCLAIMER.md) | Disclaimer (root Docs) |
| [`TERMS_OF_USE.md`](TERMS_OF_USE.md) | Destinazione dedicata per Termini d'uso da Watch/iOS |
| [`PRIVACY_AND_DATA_USE.md`](PRIVACY_AND_DATA_USE.md) | Destinazione dedicata per privacy / data use da Watch/iOS |
| [`SECURITY_AUDIT_MAIN_AND_MAIN_IOS_20260519.md`](SECURITY_AUDIT_MAIN_AND_MAIN_IOS_20260519.md) | Audit security F1–F12 |
| [`INTERNAL_TESTING_PLAYBOOK_20260520.md`](INTERNAL_TESTING_PLAYBOOK_20260520.md) | QA interno giornaliero; link checklist device |
| [`APP_INTENTS_DEVICE_QA_CHECKLIST.md`](APP_INTENTS_DEVICE_QA_CHECKLIST.md) | App Intents su Watch fisico |
| [`WATCH_IOS_SYNC_DEVICE_QA_CHECKLIST.md`](WATCH_IOS_SYNC_DEVICE_QA_CHECKLIST.md) | Sync Watch↔iPhone su hardware |
| [`MAIN_PRE_RELEASE_SIMULATOR_QA_20260519.md`](MAIN_PRE_RELEASE_SIMULATOR_QA_20260519.md) | QA simulatore |

---

## 7. Experimental (non in target MAIN)

| Documento | Contenuto |
|-----------|-----------|
| [`EXPERIMENTAL_FEATURES.md`](EXPERIMENTAL_FEATURES.md) | Panoramica Watch experimental |
| [`SNORKELING_EXPERIMENTAL_SPEC.md`](SNORKELING_EXPERIMENTAL_SPEC.md) | Snorkeling Live, Mappa Waypoint/Ritorno, POI, ritorno ingresso |
| [`APNEA_EXPERIMENTAL_SPEC.md`](APNEA_EXPERIMENTAL_SPEC.md) | Apnea workflow |
| [`iOS/EXPERIMENTAL_FEATURES.md`](iOS/EXPERIMENTAL_FEATURES.md) | iOS Explore Lab / Buddy |

---

## 8. Audit UX storici e pass implementativi

| Documento | Contenuto |
|-----------|-----------|
| [`MAIN_BRANCHES_UX_INTERACTION_AUDIT_20260519_CURRENT_PRE_MODIFICATION.md`](MAIN_BRANCHES_UX_INTERACTION_AUDIT_20260519_CURRENT_PRE_MODIFICATION.md) | Audit pre-modifica 20260519 |
| [`MAIN_BRANCHES_UX_INTERACTION_AUDIT_20260518_CURRENT_PRE_MODIFICATION.md`](MAIN_BRANCHES_UX_INTERACTION_AUDIT_20260518_CURRENT_PRE_MODIFICATION.md) | Audit 20260518 |
| [`MAIN_BRANCHES_UX_INTERACTION_AUDIT_20260518_POST_FIX_PRE_MODIFICATION.md`](MAIN_BRANCHES_UX_INTERACTION_AUDIT_20260518_POST_FIX_PRE_MODIFICATION.md) | Post-fix 20260518 |
| [`MAIN_UX_COMPLETION_REPORT.md`](MAIN_UX_COMPLETION_REPORT.md) | Completamento UX MAIN |
| [`MAIN_UX_GAP_FIX_IMPLEMENTATION_20260518.md`](MAIN_UX_GAP_FIX_IMPLEMENTATION_20260518.md) | Gap fix 20260518 |
| [`MAIN_READINESS_100_IMPLEMENTATION_REPORT_20260517.md`](MAIN_READINESS_100_IMPLEMENTATION_REPORT_20260517.md) | Readiness 100% 20260517 |
| [`PHASE0_MAIN_UX_PREFLIGHT_PLAN.md`](PHASE0_MAIN_UX_PREFLIGHT_PLAN.md) | Preflight UX |

---

## 9. Report aggiornamento documentazione (cronologia)

| Data | File |
|------|------|
| 20260527 | [`DOCUMENTATION_UPDATE_REPORT_20260527.md`](DOCUMENTATION_UPDATE_REPORT_20260527.md) |
| 20260526 | [`DOCUMENTATION_UPDATE_REPORT_20260526.md`](DOCUMENTATION_UPDATE_REPORT_20260526.md) |
| 20260525 | [`DOCUMENTATION_UPDATE_REPORT_20260525.md`](DOCUMENTATION_UPDATE_REPORT_20260525.md) |
| 20260524 | [`DOCUMENTATION_UPDATE_REPORT_20260524.md`](DOCUMENTATION_UPDATE_REPORT_20260524.md), [`DOCUMENTATION_UPDATE_REPORT_20260524_CONTROL_STRATEGY.md`](DOCUMENTATION_UPDATE_REPORT_20260524_CONTROL_STRATEGY.md) |
| 20260523 | [`DOCUMENTATION_UPDATE_REPORT_20260523.md`](DOCUMENTATION_UPDATE_REPORT_20260523.md) |
| 20260522 | [`DOCUMENTATION_UPDATE_REPORT_20260522_LEGAL_ONBOARDING.md`](DOCUMENTATION_UPDATE_REPORT_20260522_LEGAL_ONBOARDING.md) |
| 20260520 | [`DOCUMENTATION_UPDATE_REPORT_20260520.md`](DOCUMENTATION_UPDATE_REPORT_20260520.md), [`DOCUMENTATION_UPDATE_REPORT_20260520_POST_RELEASE.md`](DOCUMENTATION_UPDATE_REPORT_20260520_POST_RELEASE.md) |
| 20260519 | [`DOCUMENTATION_UPDATE_REPORT_20260519.md`](DOCUMENTATION_UPDATE_REPORT_20260519.md), [`DOCUMENTATION_UPDATE_REPORT_20260519_I18N.md`](DOCUMENTATION_UPDATE_REPORT_20260519_I18N.md), [`DOCUMENTATION_UPDATE_REPORT_20260519_SECURITY.md`](DOCUMENTATION_UPDATE_REPORT_20260519_SECURITY.md), [`DOCUMENTATION_UPDATE_REPORT_20260519_SECURITY_PT2.md`](DOCUMENTATION_UPDATE_REPORT_20260519_SECURITY_PT2.md), [`DOCUMENTATION_UPDATE_REPORT_20260519_PRE_RELEASE_BACKLOG.md`](DOCUMENTATION_UPDATE_REPORT_20260519_PRE_RELEASE_BACKLOG.md) |

| Data | Branch alignment |
|------|------------------|
| 20260527 | [`DOCUMENTATION_BRANCH_ALIGNMENT_20260527.md`](DOCUMENTATION_BRANCH_ALIGNMENT_20260527.md) |
| 20260526 | [`DOCUMENTATION_BRANCH_ALIGNMENT_20260526.md`](DOCUMENTATION_BRANCH_ALIGNMENT_20260526.md) |
| 20260525 | [`DOCUMENTATION_BRANCH_ALIGNMENT_20260525.md`](DOCUMENTATION_BRANCH_ALIGNMENT_20260525.md) |
| 20260517–24 | [`DOCUMENTATION_BRANCH_ALIGNMENT_20260517.md`](DOCUMENTATION_BRANCH_ALIGNMENT_20260517.md) … [`DOCUMENTATION_BRANCH_ALIGNMENT_20260524.md`](DOCUMENTATION_BRANCH_ALIGNMENT_20260524.md) |

---

## 10. Riferimenti visivi e asset

| Percorso | Contenuto |
|----------|-----------|
| [`ReferenceUI/Watch_LIVE_reference.png`](ReferenceUI/Watch_LIVE_reference.png) | UI Watch Diving (benchmark audit §E) |
| [`ReferenceUI/iOS_Companion_reference.png`](ReferenceUI/iOS_Companion_reference.png) | UI iOS companion |
| [`ReferenceIcon/`](ReferenceIcon/) | Icone app, `altosinistra.png` |
| [`ReferenceLookAndFeel.jpg`](ReferenceLookAndFeel.jpg) | Look & feel (se presente) |
| [`LiveDiveImmersionPremiumPreview.png`](LiveDiveImmersionPremiumPreview.png) | Preview Live Dive |
| [`CurrentCodeLiveViewPreview.png`](CurrentCodeLiveViewPreview.png) | Preview codice Live |
| [`SecureBuddyPairingMockup.svg`](SecureBuddyPairingMockup.svg) | Mockup Buddy (experimental) |
| [`UI_UX_VISUAL_GUIDELINES.md`](UI_UX_VISUAL_GUIDELINES.md) | Linee guida visive |

---

## 11. Script generatori `.docx`

| Script | Output |
|--------|--------|
| [`generate_main_branch_complete_readiness_audit_20260524_docx.py`](generate_main_branch_complete_readiness_audit_20260524_docx.py) | `MAIN_BRANCH_COMPLETE_READINESS_AUDIT_20260524.docx` |
| [`generate_main_branch_complete_readiness_audit_current_docx.py`](generate_main_branch_complete_readiness_audit_current_docx.py) | Generatore legacy del pass pre-modifica poi archiviato come `MAIN_BRANCH_COMPLETE_READINESS_AUDIT_2026-05-25.docx` |
| [`generate_main_branch_complete_readiness_audit_20260520_docx.py`](generate_main_branch_complete_readiness_audit_20260520_docx.py) | Audit 20260520 docx |
| [`generate_main_branch_complete_readiness_audit_20260522_docx.py`](generate_main_branch_complete_readiness_audit_20260522_docx.py) | Audit 20260522 docx |
| [`generate_main_branch_complete_readiness_audit_20260523_docx.py`](generate_main_branch_complete_readiness_audit_20260523_docx.py) | Audit 20260523 docx |
| [`generate_main_branch_ux_interaction_accessibility_audit_20260523_docx.py`](generate_main_branch_ux_interaction_accessibility_audit_20260523_docx.py) | UX audit 20260523 docx |
| [`generate_main_branch_ux_interaction_accessibility_audit_20260524_docx.py`](generate_main_branch_ux_interaction_accessibility_audit_20260524_docx.py) | UX audit 20260524 docx |
| [`generate_main_branch_ux_interaction_accessibility_audit_20260524_post_dev_notes_docx.py`](generate_main_branch_ux_interaction_accessibility_audit_20260524_post_dev_notes_docx.py) | `MAIN_BRANCH_UX_INTERACTION_ACCESSIBILITY_AUDIT_20260524_POST_DEV_NOTES.docx` |
| [`generate_main_branch_ux_interaction_accessibility_audit_20260524_pre_mod_docx.py`](generate_main_branch_ux_interaction_accessibility_audit_20260524_pre_mod_docx.py) | UX audit PRE-MOD docx |
| [`generate_main_branch_readiness_audit_full_docx.py`](generate_main_branch_readiness_audit_full_docx.py) | Audit full |
| [`generate_main_readiness_audit_docx.py`](generate_main_readiness_audit_docx.py) | Readiness docx |
| [`generate_main_ux_audit_20260519_docx.py`](generate_main_ux_audit_20260519_docx.py) | UX 20260519 |
| [`generate_ux_roadmap_100_docx.py`](generate_ux_roadmap_100_docx.py) | Roadmap 100 docx |

---

## 12. Percorso rapido (30 minuti)

1. [`README.md`](README.md) — panoramica e branch strategy
2. [`DIR_Diving_Complete_Development_Notes_UPDATED_v10.md`](DIR_Diving_Complete_Development_Notes_UPDATED_v10.md) — **backlog prodotto corrente** (iOS + Watch)
3. [`DIR_DIVING_v8_IMPLEMENTATION_REPORT.md`](DIR_DIVING_v8_IMPLEMENTATION_REPORT.md) — cosa è già implementato in codice (v8) @ `a36dc23`
4. [`MAIN_BRANCH_COMPLETE_READINESS_AUDIT_2026-05-25.md`](MAIN_BRANCH_COMPLETE_READINESS_AUDIT_2026-05-25.md) — **§B, §M, §N, §O**
5. [`DOCUMENTATION_UPDATE_REPORT_20260525.md`](DOCUMENTATION_UPDATE_REPORT_20260525.md) + [`DOCUMENTATION_BRANCH_ALIGNMENT_20260525.md`](DOCUMENTATION_BRANCH_ALIGNMENT_20260525.md) — allineamento documentazione/branch corrente
6. [`DIR_DIVING_Feature_Comparison.csv`](DIR_DIVING_Feature_Comparison.csv) — stato feature
7. [`BUILD_VALIDATION.md`](BUILD_VALIDATION.md) — `xcodegen generate` + build
8. [`WATCH_CONTROL_STRATEGY_IMPLEMENTATION_REPORT.md`](WATCH_CONTROL_STRATEGY_IMPLEMENTATION_REPORT.md) — se lavori su Watch
9. [`WATCH_MAIN_ALGORITHM_MATH_AUDIT_CURRENT.md`](WATCH_MAIN_ALGORITHM_MATH_AUDIT_CURRENT.md) + [`DIR_DIVING_WATCH_ALGORITHM_MATH_AUDIT.md`](DIR_DIVING_WATCH_ALGORITHM_MATH_AUDIT.md) — audit math Watch MAIN (corrente + post-hardening root)
10. [`IOS_MAIN_ALGORITHM_MATH_AUDIT_CURRENT.md`](IOS_MAIN_ALGORITHM_MATH_AUDIT_CURRENT.md) + [`IOS_MAIN_ALGORITHM_READINESS_100_REPORT.md`](IOS_MAIN_ALGORITHM_READINESS_100_REPORT.md) + [`DIR_DIVING_IOS_ALGORITHM_MATH_AUDIT.md`](DIR_DIVING_IOS_ALGORITHM_MATH_AUDIT.md) — se lavori su planner/iOS
11. [`DIR_DIVING_FULL_UI_UX_AUDIT_CURRENT.md`](DIR_DIVING_FULL_UI_UX_AUDIT_CURRENT.md) + [`DIR_DIVING_UI_UX_READINESS_100_PLAN_CURRENT.md`](DIR_DIVING_UI_UX_READINESS_100_PLAN_CURRENT.md) — se lavori su UI/UX Watch+iOS
12. [`TESTFLIGHT_ENTITLEMENT_AND_DEVICE_QA_20260523.md`](TESTFLIGHT_ENTITLEMENT_AND_DEVICE_QA_20260523.md) — se lavori su TestFlight / R1

---

## 13. File principali collegati e repository root

| File | Ruolo |
|------|--------|
| [`README.md`](README.md) | Ingresso repository |
| [`CHANGELOG.md`](CHANGELOG.md) | Changelog |
| [`CONTRIBUTING.md`](CONTRIBUTING.md) | Regole contribuzione |
| [`../project.yml`](../project.yml) | XcodeGen / exclude experimental |
| [`WATCH_MAIN_ALGORITHM_MATH_AUDIT_CURRENT.md`](WATCH_MAIN_ALGORITHM_MATH_AUDIT_CURRENT.md) | Audit corrente Watch MAIN (`Docs/`) |
| [`IOS_MAIN_ALGORITHM_MATH_AUDIT_CURRENT.md`](IOS_MAIN_ALGORITHM_MATH_AUDIT_CURRENT.md) | Audit corrente iOS Companion MAIN (`Docs/`) |
| [`DIR_DIVING_WATCH_ALGORITHM_MATH_AUDIT.md`](DIR_DIVING_WATCH_ALGORITHM_MATH_AUDIT.md) | Audit algoritmi/math Watch MAIN (Docs) |
| [`DIR_DIVING_IOS_ALGORITHM_MATH_AUDIT.md`](DIR_DIVING_IOS_ALGORITHM_MATH_AUDIT.md) | Audit algoritmi/math iOS Companion MAIN (Docs) |
| [`DIR_DIVING_IOS_BUHLMANN_UX_UI_READINESS_AUDIT.md`](DIR_DIVING_IOS_BUHLMANN_UX_UI_READINESS_AUDIT.md) | Audit UX/UI readiness planner Bühlmann iOS (Docs) |
| [`DIR_DIVING_IOS_BUHLMANN_COMPREHENSIVE_READINESS_AUDIT_UPDATED.md`](DIR_DIVING_IOS_BUHLMANN_COMPREHENSIVE_READINESS_AUDIT_UPDATED.md) | Audit comprehensive planner iOS @ `63ee0b4` (2026-06-04) |
| [`DIR_DIVING_FULL_UI_UX_AUDIT_CURRENT.md`](DIR_DIVING_FULL_UI_UX_AUDIT_CURRENT.md) | Audit UI/UX cross-app Watch+iOS @ `bdd3a43` (2026-06-05) |
| [`DIR_DIVING_UI_UX_READINESS_AUDIT_CURRENT.md`](DIR_DIVING_UI_UX_READINESS_AUDIT_CURRENT.md) | **Audit UI/UX post-implementazione** Watch 82% / iOS 84% @ `bc01f04` (2026-06-07) |
| [`DIR_DIVING_UI_UX_READINESS_100_PLAN_CURRENT.md`](DIR_DIVING_UI_UX_READINESS_100_PLAN_CURRENT.md) | **Piano operativo UI/UX 100%** Watch+iOS @ `e47c860` |

---

---

## 14. Elenco alfabetico — `.md` in `Docs/` + audit root (riferimento rapido)

Audit storici ora consolidati in `Docs/`: vedi anche **§13** — [`DIR_DIVING_WATCH_ALGORITHM_MATH_AUDIT.md`](DIR_DIVING_WATCH_ALGORITHM_MATH_AUDIT.md), [`DIR_DIVING_IOS_ALGORITHM_MATH_AUDIT.md`](DIR_DIVING_IOS_ALGORITHM_MATH_AUDIT.md), [`DIR_DIVING_IOS_BUHLMANN_UX_UI_READINESS_AUDIT.md`](DIR_DIVING_IOS_BUHLMANN_UX_UI_READINESS_AUDIT.md).

| File | Sezione indice |
|------|----------------|
| [`APNEA_EXPERIMENTAL_SPEC.md`](APNEA_EXPERIMENTAL_SPEC.md) | §7 |
| [`APP_ICON_UPDATE_NOTES.md`](APP_ICON_UPDATE_NOTES.md) | §0, §6 |
| [`APP_INTENTS_DEVICE_QA_CHECKLIST.md`](APP_INTENTS_DEVICE_QA_CHECKLIST.md) | §4, §6 |
| [`ASCENT_ALARM_IMPLEMENTATION_REPORT_20260520.md`](ASCENT_ALARM_IMPLEMENTATION_REPORT_20260520.md) | §3 |
| [`BUILD_VALIDATION.md`](BUILD_VALIDATION.md) | §6, §12 |
| [`CODEX_DIR_DIVING_WATCH_ALGORITHM_MATH_AUDIT.md`](CODEX_DIR_DIVING_WATCH_ALGORITHM_MATH_AUDIT.md) | §3 |
| [`DEPTH_LIMIT_SAFETY_TEST_CHECKLIST.md`](DEPTH_LIMIT_SAFETY_TEST_CHECKLIST.md) | §3 |
| [`DIR_DIVING_IOS_BUHLMANN_COMPREHENSIVE_READINESS_AUDIT.md`](DIR_DIVING_IOS_BUHLMANN_COMPREHENSIVE_READINESS_AUDIT.md) | §6, agg. 2026-05-30 |
| [`DIR_DIVING_IOS_BUHLMANN_COMPREHENSIVE_READINESS_AUDIT_UPDATED.md`](DIR_DIVING_IOS_BUHLMANN_COMPREHENSIVE_READINESS_AUDIT_UPDATED.md) | §6, agg. 2026-06-04 |
| [`DIR_DIVING_IOS_BUHLMANN_FIXTURE_SOURCES.md`](DIR_DIVING_IOS_BUHLMANN_FIXTURE_SOURCES.md) | §6 |
| [`DIR_DIVING_IOS_BUHLMANN_REAUDIT_2026-05-28.md`](DIR_DIVING_IOS_BUHLMANN_REAUDIT_2026-05-28.md) | §1, §4, §6 |
| [`DIR_DIVING_IOS_BUHLMANN_UX_UI_READINESS_AUDIT.md`](DIR_DIVING_IOS_BUHLMANN_UX_UI_READINESS_AUDIT.md) | §1, §4, §6, §13 |
| [`DIR_DIVING_IOS_BUHLMANN_MULTIGAS_ASSESSMENT.md`](DIR_DIVING_IOS_BUHLMANN_MULTIGAS_ASSESSMENT.md) | §6 |
| [`DIR_DIVING_WATCH_ALGORITHM_RELEASE_HARDENING.md`](DIR_DIVING_WATCH_ALGORITHM_RELEASE_HARDENING.md) | §3, §6 |
| [`DIR_DIVING_WATCH_ALGORITHM_RELEASE_HARDENING_FINAL.md`](DIR_DIVING_WATCH_ALGORITHM_RELEASE_HARDENING_FINAL.md) | §3, §6 |
| [`DEVELOPMENT_NOTES_25_05_2026_IMPLEMENTATION_REPORT.md`](DEVELOPMENT_NOTES_25_05_2026_IMPLEMENTATION_REPORT.md) | §0 |
| [`DIR_Diving_Complete_Development_Notes_25_05_2026.md`](DIR_Diving_Complete_Development_Notes_25_05_2026.md) | §0 |
| [`DIR_Diving_Complete_Development_Notes_UPDATED_v10.md`](DIR_Diving_Complete_Development_Notes_UPDATED_v10.md) | §0, §4, §12 |
| [`DIR_Diving_Complete_Development_Notes_UPDATED_v8.md`](DIR_Diving_Complete_Development_Notes_UPDATED_v8.md) | §0, §4 |
| [`DIR_Diving_Complete_Development_Notes_UPDATED_v9.md`](DIR_Diving_Complete_Development_Notes_UPDATED_v9.md) | §0, §12 |
| [`DIR_Diving_Main_Branch_Development_Notes.md`](DIR_Diving_Main_Branch_Development_Notes.md) | §4 |
| [`DIR_DIVING_MAIN_BRANCH_DEVELOPMENT_IMPLEMENTATION_REPORT.md`](DIR_DIVING_MAIN_BRANCH_DEVELOPMENT_IMPLEMENTATION_REPORT.md) | §4 |
| [`DIR_DIVING_v8_IMPLEMENTATION_REPORT.md`](DIR_DIVING_v8_IMPLEMENTATION_REPORT.md) | §0, §12 |
| [`DIR_DIVING_IOS_GAS_BUHLMANN_PLANNER_IMPROVEMENT_PLAN.md`](DIR_DIVING_IOS_GAS_BUHLMANN_PLANNER_IMPROVEMENT_PLAN.md) | §6 |
| [`DIR_DIVING_IOS_ALGORITHM_RELEASE_HARDENING.md`](DIR_DIVING_IOS_ALGORITHM_RELEASE_HARDENING.md) | §6 |
| [`DIR_DIVING_IOS_BUHLMANN_ENGINE_DESIGN.md`](DIR_DIVING_IOS_BUHLMANN_ENGINE_DESIGN.md) | §6 |
| [`DIR_DIVING_IOS_BUHLMANN_MATH_VERIFICATION.md`](DIR_DIVING_IOS_BUHLMANN_MATH_VERIFICATION.md) | §6 |
| [`DIR_DIVING_IOS_BUHLMANN_REFERENCE_CROSSCHECK.md`](DIR_DIVING_IOS_BUHLMANN_REFERENCE_CROSSCHECK.md) | §6 |
| [`DIR_DIVING_IOS_BUHLMANN_VALIDATION_FIXTURES.md`](DIR_DIVING_IOS_BUHLMANN_VALIDATION_FIXTURES.md) | §6 |
| [`DIR_DIVING_IOS_PLANNER_LIMITATIONS.md`](DIR_DIVING_IOS_PLANNER_LIMITATIONS.md) | §6 |
| [`DIR_Diving_Planner_Tabs_Implementation_Plan.md`](DIR_Diving_Planner_Tabs_Implementation_Plan.md) | §6, agg. 2026-06-06 |
| [`DIR_DIVING_IOS_PLANNER_DECO_TABLE_BUHLMANN_CURVE_AUDIT_CURRENT.md`](DIR_DIVING_IOS_PLANNER_DECO_TABLE_BUHLMANN_CURVE_AUDIT_CURRENT.md) | §6, agg. 2026-06-06 |
| [`IOS_MAIN_ALGORITHM_MATH_AUDIT_CURRENT.md`](IOS_MAIN_ALGORITHM_MATH_AUDIT_CURRENT.md) | **§4**, agg. 2026-06-07 @ `c723295` — audit iOS MAIN @ `81f2d7f` |
| [`IOS_MAIN_ALGORITHM_MATH_AUDIT_REMEDIATION_REPORT.md`](IOS_MAIN_ALGORITHM_MATH_AUDIT_REMEDIATION_REPORT.md) | §4, §6 — remediation IOS-AUDIT-001…012 |
| [`IOS_MAIN_ALGORITHM_READINESS_100_REPORT.md`](IOS_MAIN_ALGORITHM_READINESS_100_REPORT.md) | §4, §6 — remediation storica @ `dce89e7` |
| [`IOS_MAIN_ALGORITHM_READINESS_100_FINAL_QA.md`](IOS_MAIN_ALGORITHM_READINESS_100_FINAL_QA.md) | §4, §6 — QA matrix iOS MAIN |
| [`DIR_DIVING_FULL_UI_UX_AUDIT_CURRENT.md`](DIR_DIVING_FULL_UI_UX_AUDIT_CURRENT.md) | agg. 2026-06-05 — audit Watch+iOS @ `bdd3a43` |
| [`DIR_DIVING_UI_UX_READINESS_100_PLAN_CURRENT.md`](DIR_DIVING_UI_UX_READINESS_100_PLAN_CURRENT.md) | **agg. 2026-06-05** — piano UI/UX 100% Watch+iOS @ `e47c860` |
| `DOCUMENTATION_BRANCH_ALIGNMENT_20260517.md` … `20260525.md` | §2, §9 |
| [`DOCUMENTATION_SYNC_REPORT_20260519.md`](DOCUMENTATION_SYNC_REPORT_20260519.md) | §2 |
| `DOCUMENTATION_UPDATE_REPORT_20260519.md` … `20260525.md` | §9 |
| [`EXPERIMENTAL_FEATURES.md`](EXPERIMENTAL_FEATURES.md) | §7 |
| [`GLOSSARY.md`](GLOSSARY.md) | §5 |
| [`INDEX.md`](INDEX.md) | questo file |
| [`INTERNAL_TESTING_PLAYBOOK_20260520.md`](INTERNAL_TESTING_PLAYBOOK_20260520.md) | §6 |
| [`IOS_TAB_TARGET_MISMATCH_REPORT.md`](IOS_TAB_TARGET_MISMATCH_REPORT.md) | §4 |
| [`IOS_TAB_TARGET_MISMATCH_STATUS_20260519.md`](IOS_TAB_TARGET_MISMATCH_STATUS_20260519.md) | §4 |
| `MAIN_BRANCH_COMPLETE_READINESS_AUDIT_20260520.md` … `2026-05-25.md` (+ `.docx`) | §1 |
| [`MAIN_BRANCH_FINAL_READINESS_REPORT.md`](MAIN_BRANCH_FINAL_READINESS_REPORT.md) | §4 |
| [`MAIN_BRANCH_ISSUES_AND_PRIORITIES_20260520.md`](MAIN_BRANCH_ISSUES_AND_PRIORITIES_20260520.md) | §4 |
| [`MAIN_BRANCH_TARGETED_FIX_REPORT.md`](MAIN_BRANCH_TARGETED_FIX_REPORT.md) | §4 |
| [`MAIN_BRANCH_UX_INTERACTION_ACCESSIBILITY_AUDIT_20260523.md`](MAIN_BRANCH_UX_INTERACTION_ACCESSIBILITY_AUDIT_20260523.md) | §4 |
| [`MAIN_BRANCH_UX_INTERACTION_ACCESSIBILITY_AUDIT_20260524.md`](MAIN_BRANCH_UX_INTERACTION_ACCESSIBILITY_AUDIT_20260524.md) | §4 |
| [`MAIN_BRANCH_UX_INTERACTION_ACCESSIBILITY_AUDIT_20260524_CURRENT_PRE_MODIFICATION.md`](MAIN_BRANCH_UX_INTERACTION_ACCESSIBILITY_AUDIT_20260524_CURRENT_PRE_MODIFICATION.md) | §4 |
| [`MAIN_BRANCH_UX_INTERACTION_ACCESSIBILITY_AUDIT_20260524_POST_DEV_NOTES.md`](MAIN_BRANCH_UX_INTERACTION_ACCESSIBILITY_AUDIT_20260524_POST_DEV_NOTES.md) | §0, §4 |
| `MAIN_BRANCHES_UX_INTERACTION_AUDIT_20260518*.md`, `20260519*.md` | §8 |
| [`MAIN_ISSUES_IMPLEMENTATION_REPORT_20260520.md`](MAIN_ISSUES_IMPLEMENTATION_REPORT_20260520.md) | §4 |
| [`MISSION_MODE_MAIN_WATCH.md`](MISSION_MODE_MAIN_WATCH.md) | §3 |
| [`MAIN_PRE_RELEASE_OPEN_ITEMS_20260519.md`](MAIN_PRE_RELEASE_OPEN_ITEMS_20260519.md), [`MAIN_PRE_RELEASE_SIMULATOR_QA_20260519.md`](MAIN_PRE_RELEASE_SIMULATOR_QA_20260519.md) | §5, §6 |
| [`MAIN_READINESS_100_IMPLEMENTATION_REPORT_20260517.md`](MAIN_READINESS_100_IMPLEMENTATION_REPORT_20260517.md) | §8 |
| [`MAIN_UX_*`](MAIN_UX_COMPLETION_REPORT.md) | §8 |
| [`ORCHESTRATED_AUDIT_COMMAND_INVENTORY_CURRENT.csv`](ORCHESTRATED_AUDIT_COMMAND_INVENTORY_CURRENT.csv) | **agg. 2026-06-21** — orchestrator command inventory (19 executed) |
| [`ORCHESTRATED_AUDIT_CONSOLIDATED_REPORT_CURRENT.md`](ORCHESTRATED_AUDIT_CONSOLIDATED_REPORT_CURRENT.md) | **agg. 2026-06-21** — orchestrated audit consolidated report @ `6cbba649` |
| [`ORCHESTRATED_AUDIT_ISSUE_REGISTER_CURRENT.csv`](ORCHESTRATED_AUDIT_ISSUE_REGISTER_CURRENT.csv) | **agg. 2026-06-21** — ORCH-001…015 deduplicated issue register |
| [`ORCHESTRATED_AUDIT_NON_REGRESSION_PLAN_CURRENT.md`](ORCHESTRATED_AUDIT_NON_REGRESSION_PLAN_CURRENT.md) | **agg. 2026-06-21** — macOS build/test/readiness non-regression gates |
| [`ORCHESTRATED_AUDIT_RELEASE_READINESS_MATRIX_CURRENT.csv`](ORCHESTRATED_AUDIT_RELEASE_READINESS_MATRIX_CURRENT.csv) | **agg. 2026-06-21** — release gate matrix (internal/TestFlight/App Store) |
| [`ORCHESTRATED_AUDIT_REMEDIATION_ROADMAP_CURRENT.md`](ORCHESTRATED_AUDIT_REMEDIATION_ROADMAP_CURRENT.md) | **agg. 2026-06-21** — Phase A–E remediation roadmap (Command 17 input) |
| [`ORCHESTRATED_AUDIT_RUN_LOG_CURRENT.md`](ORCHESTRATED_AUDIT_RUN_LOG_CURRENT.md) | **agg. 2026-06-21** — orchestrator run log (V1.1, audit-only) |
| [`PHASE0_MAIN_UX_PREFLIGHT_PLAN.md`](PHASE0_MAIN_UX_PREFLIGHT_PLAN.md) | §8 |
| [`PRIVACY_AND_DATA_USE.md`](PRIVACY_AND_DATA_USE.md) | §6 |
| [`PR_STATUS_20260520.md`](PR_STATUS_20260520.md) … [`PR_STATUS_20260527.md`](PR_STATUS_20260527.md) | §2 |
| [`RELEASE_CHECKLIST.md`](RELEASE_CHECKLIST.md) | §6 |
| [`ROADMAP.md`](ROADMAP.md) | §5 |
| [`SAFETY_DISCLAIMER.md`](SAFETY_DISCLAIMER.md) | §6 |
| [`SECURITY_AUDIT_MAIN_AND_MAIN_IOS_20260519.md`](SECURITY_AUDIT_MAIN_AND_MAIN_IOS_20260519.md) | §6 |
| [`SNORKELING_EXPERIMENTAL_SPEC.md`](SNORKELING_EXPERIMENTAL_SPEC.md) | §7 |
| [`TESTFLIGHT_ENTITLEMENT_AND_DEVICE_QA_20260523.md`](TESTFLIGHT_ENTITLEMENT_AND_DEVICE_QA_20260523.md), [`TESTFLIGHT_REVIEW_NOTES.md`](TESTFLIGHT_REVIEW_NOTES.md) | §3, §12 |
| [`TERMS_OF_USE.md`](TERMS_OF_USE.md) | §6 |
| [`UI_UX_VISUAL_GUIDELINES.md`](UI_UX_VISUAL_GUIDELINES.md) | §10 |
| [`WATCH_CMALTIMETER_FAILURE_INJECTION_MATRIX_CURRENT.csv`](WATCH_CMALTIMETER_FAILURE_INJECTION_MATRIX_CURRENT.csv) | **agg. 2026-06-17** — Command 18 failure/concurrency matrix (30 cases) |
| [`WATCH_CMALTIMETER_FULL_COMPUTER_INTERACTION_AUDIT_CURRENT.md`](WATCH_CMALTIMETER_FULL_COMPUTER_INTERACTION_AUDIT_CURRENT.md) | **agg. 2026-06-17** — Command 18 CMAltimeter → Full Computer audit (PARTIAL) |
| [`WATCH_CMALTIMETER_PHYSICAL_QA_MATRIX_CURRENT.csv`](WATCH_CMALTIMETER_PHYSICAL_QA_MATRIX_CURRENT.csv) | **agg. 2026-06-17** — Command 18 physical Watch QA (PENDING_PHYSICAL) |
| [`WATCH_CMALTIMETER_REQUIREMENT_TRACEABILITY_CURRENT.csv`](WATCH_CMALTIMETER_REQUIREMENT_TRACEABILITY_CURRENT.csv) | **agg. 2026-06-17** — Command 18 requirement traceability (30 reqs) |
| [`WATCH_CONTROL_STRATEGY_IMPLEMENTATION_REPORT.md`](WATCH_CONTROL_STRATEGY_IMPLEMENTATION_REPORT.md) | §3, §12 |
| [`WATCH_IOS_SYNC_DEVICE_QA_CHECKLIST.md`](WATCH_IOS_SYNC_DEVICE_QA_CHECKLIST.md) | §4, §6 |
| [`WATCH_MAIN_UX_CONVENTIONS.md`](WATCH_MAIN_UX_CONVENTIONS.md) | §3 |
| [`WATCH_MAIN_ALGORITHM_MATH_AUDIT_FIX_COMPLETION_REPORT.md`](WATCH_MAIN_ALGORITHM_MATH_AUDIT_FIX_COMPLETION_REPORT.md) | §3, agg. 2026-06-07 — remediation P1–P3 |
| [`WATCH_MAIN_ALGORITHM_MATH_AUDIT_CURRENT.md`](WATCH_MAIN_ALGORITHM_MATH_AUDIT_CURRENT.md) | §3, agg. 2026-06-05 @ `5415213` |
| [`WATCH_MAIN_ALGORITHM_MATH_AUDIT_REMEDIATION_REPORT.md`](WATCH_MAIN_ALGORITHM_MATH_AUDIT_REMEDIATION_REPORT.md) | §3, agg. 2026-06-07 remediation pass |
| [`WATCH_MAIN_HARDWARE_ALGORITHM_QA_CHECKLIST.md`](WATCH_MAIN_HARDWARE_ALGORITHM_QA_CHECKLIST.md) | §3, §6 |
| [`WATCH_CSV_EXPORT_POLICY.md`](WATCH_CSV_EXPORT_POLICY.md) | §3, §6 |
| [`iOS/*.md`](iOS/BUILD_AND_RUN.md) | §4 |

Altri asset in `Docs/`: `.docx`, `.csv`, `.xlsx`, `.py` (generatori §11), `ReferenceUI/`, `ReferenceIcon/`, immagini §10.

---

*Indice per ripresa lavoro su `main` @ `origin/main` @ `cc38a47`. Baseline orchestrator audit 2026-06-21 @ `6cbba649`; next remediation Command 17. Baseline documentale storica: piano UI/UX readiness 100% 2026-06-05, audit full UI/UX @ `bdd3a43`.*
