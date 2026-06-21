# Release Rollback Procedure (Current)

**Date:** 2026-06-20

---

## Git rollback

1. Identify last known-good commit on `main` (green gates).
2. Prefer **revert commit** over hard reset for shared branches.
3. Tag rollback point: `rollback-YYYY-MM-DD-<reason>`.
4. Re-run validation matrix on reverted tree.

```bash
git revert <bad-commit-sha>
./Scripts/validate_release_legal_claims_readiness.sh
```

---

## Release channel actions

| Channel | Action |
|---------|--------|
| TestFlight | Expire bad build; upload prior build; update review notes |
| App Store phased release | Pause rollout in App Store Connect |
| Marketing | Withdraw claims tied to bad build; restore prior approved copy |

---

## Feature / surface disablement

Priority order (safest first):

1. Remove false marketing claims (no code change).
2. Disable Planner export if export disclaimer regressed.
3. Disable cloud sync upload if unsafe (Settings scope — Diving only).
4. Code revert for algorithm/display defects (requires audit 15 if FC touched).

**Do not** destructive-reset user logbooks or schema without migration plan.

---

## Schema / migration constraints

- Logbook and sync schemas are forward-compatible; rollback builds must read current on-disk format or ship compatible decoder.
- Do not ship rollback that corrupts `fullComputerCheckpoint` or activity-scoped logbooks.

---

## User notification

- TestFlight: release notes explaining rollback reason (no unsupported safety promises).
- App Store: use standard update notes; legal review if safety-related.

---

## Post-rollback verification

- [ ] iOS + Watch build green
- [ ] Legal claims gate PASS
- [ ] Command 12 gate PASS
- [ ] Prohibited-claims scan PASS
- [ ] TestFlight notes aligned

---

## Related

- [`INCIDENT_RESPONSE_RUNBOOK_CURRENT.md`](INCIDENT_RESPONSE_RUNBOOK_CURRENT.md)
- [`RELEASE_CLAIMS_GATE_POLICY_CURRENT.md`](RELEASE_CLAIMS_GATE_POLICY_CURRENT.md)
