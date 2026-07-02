# Readiness Roadmap — 7 / 14 / 30 Days — CURRENT

**Anchor date:** 2026-07-02  
**Baseline:** `main` @ `7ae527b`  
**Overall verdict:** PARTIAL

---

## 7-day plan

**Goal:** Remove immediate software and truthfulness blockers with the first remediation batch.

- Close `CF-002` (Snorkeling localization key parity).
- Close `CF-008` and `CF-009` (docs truthfulness repair).
- Confirm no regression via reruns 01-06.
- Keep orchestrator boundary explicit: do not execute 07/10/11/12 from command 00.

**Expected outcome by day 7:** internal posture moves from conditional-fragile to conditional-stable.

---

## 14-day plan

**Goal:** Reduce P1 process and release blockers; prepare evidence-ready internal release posture.

- Close `CF-007` rollback gate fail.
- Close `CF-006` and `CF-012` command lifecycle governance findings.
- Start and partially execute physical/manual QA campaigns for `CF-003`, `CF-004`, `CF-010`, `CF-013`.
- Refresh release matrix state after reruns.

**Expected outcome by day 14:** internal TestFlight readiness remains conditional but evidence-backed.

---

## 30-day plan

**Goal:** Move from conditional internal readiness toward external readiness preparation.

- Complete physical/manual QA closure backlog.
- Execute external Buhlmann validation (`CF-001`).
- Close umbrella readiness blocker (`CF-011`) after dependencies resolve.
- Finalize claims/legal readiness with truthful evidence alignment.

**Expected outcome by day 30:** external readiness can move toward conditional-ready; App Store remains blocked until full legal/external closure is signed.

---

## Readiness trajectory

| Milestone | Target status |
|---|---|
| After Batch-1 | major quick-win blockers reduced |
| After Batch-2 | rollback and command governance stabilized |
| After Batch-3 | physical/manual evidence significantly improved |
| After Batch-4 | external validation and release readiness can be reassessed |

---

## Non-goals during this roadmap

- No production code changes from orchestrator outputs.
- No false upgrade of pending physical/external gates to PASS.
- No orchestrator execution of 07/10/11/12.
