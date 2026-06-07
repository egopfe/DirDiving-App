# DIR DIVING iOS — TestFlight Readiness Checklist

**Target:** `DIRDiving iOS` (MAIN)  
**Current posture:** Internal validation **ready**; external TestFlight **not yet**

---

## Internal TestFlight (team)

- [ ] macOS `DIRDiving iOS Algorithm Tests` green on release commit
- [ ] [`IOS_MAIN_ALGORITHM_MATH_AUDIT_CURRENT.md`](IOS_MAIN_ALGORITHM_MATH_AUDIT_CURRENT.md) reviewed
- [ ] [`IOS_MAIN_ALGORITHM_MATH_AUDIT_FIX_COMPLETION_REPORT.md`](IOS_MAIN_ALGORITHM_MATH_AUDIT_FIX_COMPLETION_REPORT.md) reviewed
- [ ] [`DIR_DIVING_IOS_CNS_PLANNER_IMPLEMENTATION_AUDIT.md`](DIR_DIVING_IOS_CNS_PLANNER_IMPLEMENTATION_AUDIT.md) reviewed
- [ ] Cloud profile merge policy documented (`DiveSessionMergePolicy`)
- [ ] Weekly OTU visible in planner when computed
- [ ] Reference-only disclaimers unchanged

---

## External TestFlight

- [ ] [`DIR_DIVING_IOS_EXTERNAL_VALIDATION_AND_QA_PLAN.md`](DIR_DIVING_IOS_EXTERNAL_VALIDATION_AND_QA_PLAN.md) EV-* complete
- [ ] Paired Watch/iPhone sync QA (SYNC-*)
- [ ] Accessibility QA (A11Y-*)
- [ ] Simulator screenshot evidence (SIM-*)

---

## App Store

- [ ] [`RELEASE_CHECKLIST.md`](RELEASE_CHECKLIST.md) full pass
- [ ] Legal / safety review unchanged
- [ ] External Bühlmann comparison signed off (informational, not certification)

---

**Non-certified positioning must remain in all planner and CNS/OTU surfaces.**
