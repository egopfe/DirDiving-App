# Master UI/UX Gap Remediation Plan — Current

**Audit:** `03-MASTER_UI_UX_FULL_DEEP_COMPREHENSIVE_AUDIT_COMMAND_V2.1.md`  
**Date:** 2026-06-27  
**Commit:** `83f884e`  
**Open findings:** P0=0, P1=8, P2=11, P3=4, P4=2

---

## P0 — Must fix before any safety-critical use

**None open.** Prior P0 altitude/environment mismatch remains closed.

---

## P1 — Must fix before internal TestFlight

| ID | Title | Remediation | Acceptance criteria | Tests | Physical QA |
|----|-------|-------------|---------------------|-------|-------------|
| P1-WAO-001 | Water auto-open not wired to cold launch | Wire watchOS water-entry/auto-launch callback to `beginWaterAutoLaunch()` **or** revise all Settings/marketing copy to state intent-only routing | User with Preferred Mode sees correct destination when watchOS launches app after water entry; OR copy explicitly documents intent requirement | Integration test for launch path; existing policy tests pass | WATCH_WATER_AUTO_OPEN_* packs |
| P1-WAO-002 | Cold-launch limitation not in Settings UI | Add localized string in `WatchWaterAutoOpenSettingsView` footer | Settings show submersion detection limits without opening impl report | L10n audit | n/a |
| P1-AB-001 | Legacy App Intents bypass underwater router | Route legacy intents through router when session active; or mark shortcuts surface-only in catalog + help | Action Button with **Underwater Action** is only recommended underwater path; legacy intents documented | Extend `ActionButtonIntentsSafetyTests` | ACTION_BUTTON QA pack |
| MUIUX-P1-001 | Apnea/Snorkeling physical underwater QA | Execute physical session QA templates | Evidence folders filled with device logs/screenshots | n/a | Required |
| MUIUX-P1-002 | Paired Watch↔iOS sync UI QA | Execute WATCH_IOS_SYNC evidence pack | Conflict/transfer states verified on paired devices | n/a | Required |
| MUIUX-P1-003 | Accessibility manual QA | VoiceOver pass on critical flows | A11Y evidence for Planner, Watch Live, Settings switch | n/a | Required |
| MUIUX-P1-004 | PDF render physical QA | Render Planner/Checklist PDFs on device | PDF matches UI values; disclaimers present | n/a | Required |
| MVR-P1-002 | No physical pixel-diff baselines | Capture simulator/device screenshots vs 59 mockups | PHYSICAL_PIXEL_DIFF folder populated | n/a | Recommended |

**Rerun after remediation:** Master UI/UX audit V2.1; Watch water auto-open audit; underwater hardware audit.

---

## P2 — Must fix before external TestFlight

| ID | Title | Remediation |
|----|-------|-------------|
| P2-UX-001 | Stale underwater help body | Update `shortcuts.help.underwater.body` EN/IT |
| P2-UX-002 | Missing Underwater Action help panel | Add panel to `WatchShortcutHelpView` |
| P2-UX-003 | Diving-centric blocked-nav toast | Activity-neutral or per-activity `nav.underwater.blocked` strings |
| P2-TEST-001 | Missing lastSelected FC predive test | Add to `WatchWaterAutoOpenPolicyTests` |
| P2-TEST-002 | Stale WatchSettingsRoutingTests | Update assertion to `WatchUnderwaterPagePolicy` |
| P2-TEST-003 | Missing ContentView clamp tests | Add integration tests for blocked pages |
| MUIUX-P2-001 | CCR external validation UX | Keep reference-only copy; no controller implication |
| MUIUX-P2-002 | Watch FC pixel baselines | Device captures for FC_UI mockups |
| MUIUX-P2-003 | Localization scanner path | Fix portable scanner if CI gap |
| MUIUX-P2-004 | Ascent speed not linked from Planner | Add discoverable link from Planner header |
| MVR-P2-002 | Manual visual fidelity 0/59 | Score mockups in MANUAL_VISUAL_FIDELITY |
| MVR-P2-004 | 41 mm physical layout | Smallest Watch hardware QA |

---

## P3 — App Store polish

| ID | Title |
|----|-------|
| MUIUX-P3-001 | Duplicate Legal link in Diving iOS settings |
| MUIUX-P3-002 | Settings scope vs runtime activity mismatch UX hint |
| MUIUX-P3-003 | Diving gear tab vs Apnea/Snorkeling settings asymmetry |
| MUIUX-P3-004 | Shared settings layout inconsistency across modes |

---

## P4 — Optional

| ID | Title |
|----|-------|
| MUIUX-P4-001 | Mission Mode discoverability |
| MUIUX-P4-002 | Reminder suppression copy |

---

## Full Computer remediation rule

Any fix touching Full Computer live UI or predive flow must rerun:

- `MASTER_WATCH_FULL_COMPUTER_FORENSIC_AUDIT_CURRENT.md`
- Master UI/UX audit V2.1

---

## Suggested execution order

1. P1-WAO-001 + P1-WAO-002 (truthfulness)
2. P1-AB-001 + P2-UX-001/002/003 (underwater UX coherence)
3. P2-TEST-* (test debt)
4. Physical QA packs (parallel)
5. MVR pixel diff + manual fidelity (external TestFlight gate)
