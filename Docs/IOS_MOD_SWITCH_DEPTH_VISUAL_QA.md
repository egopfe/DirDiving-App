# iOS MOD / Switch Depth Visual QA

**Owner:** ________ **Build:** ________ **Commit:** ________

**Status:** Manual — all rows **PENDING** until executed on simulator or device.

**Evidence:** `Docs/QA_EVIDENCE/MOD_SWITCH_DEPTH/`

| ID | Case | Steps | Expected | Pass/Fail | Evidence |
|---|---|---|---|---|---|
| MOD-01 | O2 100%, PPO₂ 1.6 → MOD ~6 m | Technical gas editor | MOD ≈ 6 m | **PENDING** | |
| MOD-02 | Switch 5 m (at MOD) | Set switch depth | Allowed or clamped per policy | **PENDING** | |
| MOD-03 | Switch 7 m (below MOD) | Set switch depth | Clamped to MOD / warning | **PENDING** | |
| MOD-04 | EAN50 PPO₂ 1.6 | Deco gas | MOD consistent planner/Ratio Deco | **PENDING** | |
| MOD-05 | Trimix with He | Back gas | MOD uses He-aware calc | **PENDING** | |
| MOD-06 | CCR bailout switch depth | CCR planner | Imperial + metric display OK | **PENDING** | |
| MOD-07 | Imperial mode | Settings → ft | Switch depths show ft | **PENDING** | |

---

Related: [`IOS_PLANNER_MOD_SWITCH_DEPTH_AUTOCLAMP_REPORT.md`](IOS_PLANNER_MOD_SWITCH_DEPTH_AUTOCLAMP_REPORT.md)
