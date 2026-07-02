# Snorkeling Watch P1/P2/P3 — Unified Remediation Non-Regression

**Date:** 2026-06-17

## Activity isolation

Snorkeling remediation touched only Snorkeling iOS/Watch modules, Shared Snorkeling models, and Snorkeling-specific tests. No Diving, Apnea, Full Computer, or Gauge runtime logic modified.

**Evidence:** `SnorkelingArchitectureIsolationTests`, `SnorkelingCrossDomainIsolationTests` (included in algorithm test schemes).

## Full Computer / decompression

No changes to Bühlmann, GF, NDL, TTS, ceiling, gas switching, or Full Computer checkpoint/restore.

## Location / GPS policy

No Always Location added. No underwater GPS navigation claims. Snorkeling thresholds remain in Snorkeling-specific modules only.

## Heatmap (R3-001)

Production Snorkeling heatmap remains blocked. `SnorkelingReleaseHardValidationTests` continues to guard release wording and scope.

## Apnea / Diving transfer queues

Route pending queue uses `dirdiving_snorkeling_route_pending_send_queue_v1` namespace only. Apnea transfer services unchanged.

## Fake evidence

No QA folder marked PASS without device artifacts. Validation scripts `validate_no_fake_physical_evidence_claims.sh` and `validate_release_claims_against_evidence.sh` expected PASS at commit time.
