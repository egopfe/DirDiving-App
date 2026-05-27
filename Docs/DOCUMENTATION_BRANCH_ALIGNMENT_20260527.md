# DIR DIVING - Documentation Branch Alignment 2026-05-27

**Date:** 2026-05-27  
**Working branch:** `main` @ `37e4464` before this documentation pass  
**Remote:** `origin = https://github.com/egopfe/DirDiving-App.git`  
**Scope:** documentation / repository consistency only  
**Runtime policy:** no dive, planner, sync, GPS, BUSSOLA, UI, persistence, or algorithm code changed in this pass

---

## A. Branches inspected

Fetched and inspected local and remote refs:

- `main`
- `main-iOS`
- `codex/experimental-features`
- `codex/ios-experimental-features`
- local `backup/*` branches
- `origin/main`
- `origin/main-iOS`
- `origin/codex/experimental-features`
- `origin/codex/ios-experimental-features`

---

## B. Local/upstream alignment

Local branch tracking status after `git fetch --all --prune`:

| Local branch | Upstream | Local/remote divergence | Status |
|--------------|----------|-------------------------|--------|
| `main` | `origin/main` | `0 0` | aligned |
| `main-iOS` | `origin/main-iOS` | `0 0` | aligned |
| `codex/experimental-features` | `origin/codex/experimental-features` | `0 0` | aligned |
| `codex/ios-experimental-features` | `origin/codex/ios-experimental-features` | `0 0` | aligned |
| `backup/*` | none | n/a | local safety snapshots only |

Backup created before edits:

- `backup/docs-alignment-20260527`

---

## C. Divergence from `origin/main`

Measured with `git rev-list --left-right --count origin/main...<remote-ref>`:

| Branch ref | `origin/main` ahead | Branch ahead | Interpretation |
|------------|---------------------|--------------|----------------|
| `origin/main` | 0 | 0 | stable MAIN baseline |
| `origin/main-iOS` | 221 | 49 | historical divergent iOS branch; not the current MAIN release source |
| `origin/codex/experimental-features` | 85 | 30 | expected Watch experimental divergence |
| `origin/codex/ios-experimental-features` | 132 | 61 | expected iOS experimental divergence |

These counts are merge-risk evidence only. They are not merge instructions.

---

## D. Current MAIN architecture narrative

`main` remains the authoritative stable branch for:

- Apple Watch Diving MAIN
- iOS Companion MAIN in the same XcodeGen workspace
- legal onboarding and disclaimer acceptance / re-consent
- depth safety discouragement at 35 / 38 / 40 m
- inline ascent warning banners
- compact GPS entry/exit overlays
- BUSSOLA terminology and bearing workflow
- Watch <-> iPhone sync plus iPhone -> Watch push
- tombstones and conflict visibility
- manual dive add/edit
- planner safety acknowledgement
- User Images conditional visibility
- mode auto-skip when only Diving is production-enabled
- App Intents catalog and Action Button via Shortcuts
- Side Button documented as system-controlled
- Watch and iOS algorithm release-hardening documentation

---

## E. Experimental isolation

Experimental features remain isolated:

- Snorkeling architecture and UI concepts: `codex/experimental-features`
- Apnea architecture and UI concepts: `codex/experimental-features`
- Buddy Assist / Buddy Link / BLE pairing concepts: `codex/experimental-features`
- iOS exploration, route, Apnea review, Buddy lab and POI enrichment concepts: `codex/ios-experimental-features`

`project.yml` continues to exclude the experimental Watch and iOS sources from MAIN target membership. No experimental runtime code was merged into `main` in this pass.

---

## F. Conflict and merge policy

If a future merge is required, preserve in this order:

1. buildable code
2. stable Diving functionality on `main`
3. latest premium Watch and iOS UI references
4. inline underwater warning UX
5. compact GPS overlay behavior
6. legal onboarding and disclaimer docs
7. algorithm hardening docs
8. release/TestFlight docs
9. experimental isolation

Never overwrite:

- `BUSSOLA` terminology
- inline ascent warning policy
- depth-limit discouragement philosophy
- Action Button / Side Button truthfulness
- Watch <-> iPhone sync safety docs
- non-certified planner wording
- iOS Buhlmann multigas assessment limitations

---

## G. PR status summary

Live PR metadata was available through `gh pr list`.

| PR | Head -> base | Mergeable | Risk | Recommendation |
|----|--------------|-----------|------|----------------|
| #8 `Update experimental Apnea workflow` | `codex/experimental-features` -> `main` | `CONFLICTING` | high runtime risk | do not auto-merge |
| #9 `Add experimental Apnea companion review` | `codex/ios-experimental-features` -> `main-iOS` | `CONFLICTING` | high runtime risk | do not auto-merge |

Both PRs are experimental and require manual review, macOS/Xcode validation and explicit safety signoff before any merge.

---

## H. Documentation alignment decision

The 2026-05-27 documentation pass updates `main` only. It does not rewrite history in older dated reports, but current entry points now point to the current architecture:

- `README.md`
- `Docs/INDEX.md`
- `Docs/ROADMAP.md`
- `Docs/RELEASE_CHECKLIST.md`
- `Docs/TESTFLIGHT_REVIEW_NOTES.md`
- `Docs/DIR_DIVING_Feature_Comparison.csv`
- this branch alignment report
- `Docs/DOCUMENTATION_UPDATE_REPORT_20260527.md`
- `Docs/PR_STATUS_20260527.md`

---

## I. Remaining branch-level risks

- `main-iOS` remains a historical divergent branch and should not be treated as the production iOS source of truth without a dedicated diff and port plan.
- PR #8 and PR #9 remain open and conflicting.
- A complete iOS Buhlmann ZHL-16C + Gradient Factor + Helium multigas engine is not implemented yet; it is documented as future work in the assessment report.
- Apple water-submersion entitlement, provisioning and real Apple Watch Ultra QA remain external release blockers.

---

## J. Conclusion

Repository documentation is aligned around:

- **`main` = stable production-oriented Watch + iOS branch**
- **`main-iOS` = historical/divergent branch**
- **`codex/*` = experimental only**

No runtime code, UI, planner logic, sync logic, GPS behavior, BUSSOLA logic, persistence model or algorithm implementation was changed by this pass.
