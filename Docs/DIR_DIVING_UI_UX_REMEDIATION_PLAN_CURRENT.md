# DIR DIVING — UI/UX Remediation Plan (Current)

**Date:** 2026-06-17  
**Source audit:** [`DIR_DIVING_UI_UX_READINESS_AND_MOCKUP_AUDIT_CURRENT.md`](DIR_DIVING_UI_UX_READINESS_AND_MOCKUP_AUDIT_CURRENT.md)  
**Baseline:** `main` @ `138dccb`  
**Scope:** Ordered fixes only — **do not implement in this audit pass**

---

## Priority order (dependency-aware)

### Phase 0 — Documentation & asset policy (P1, no runtime risk)

| Order | ID | Action | Depends on | Effort |
|-------|-----|--------|------------|--------|
| 0.1 | AUDIT15-MOCK-001 | Declare single canonical mockup root: prefer `mockups/**`; mark `Docs/ReferenceUI/Snorkeling/` as mirror or deprecate | — | S |
| 0.2 | AUDIT15-MOCK-002 | Fix 12 broken doc/CSV mockup references | 0.1 | S |
| 0.3 | — | Update `SnorkelingMockupReferenceMatrix` comment to match canonical path | 0.1 | S |
| 0.4 | — | Add `mockups/README.md` inventory index pointing to matrices | 0.1 | S |

### Phase 1 — iOS root-flow polish (P1/P2)

| Order | ID | Action | Depends on | Effort |
|-------|-----|--------|------------|--------|
| 1.1 | AUDIT15-UX-002 | Consume `pendingApneaLanding` / `pendingSnorkelingLanding` in respective root views (mirror Diving planner landing) | — | M |
| 1.2 | AUDIT15-UX-003 | Wire Apnea/Snorkeling dashboard last-session cards → session detail `NavigationLink` | — | S |
| 1.3 | AUDIT15-UX-006 | Collapse Snorkeling route planner to single entry (tab **or** sheet, not both) | 1.1 | S |

### Phase 2 — Watch settings scoping (P1, Command 14 carry-over)

| Order | ID | Action | Depends on | Effort |
|-------|-----|--------|------------|--------|
| 2.1 | AUDIT15-UX-004 | Scope Watch `SettingsView` by active activity; hide diving-only GF/CNS/PPO2 from Apnea/Snorkeling | Phase 1 | L |

### Phase 3 — Visual regression (P2)

| Order | ID | Action | Depends on | Effort |
|-------|-----|--------|------------|--------|
| 3.1 | AUDIT15-UX-007 | Add iOS SwiftUI preview fixtures for Apnea/Snorkeling iOS mockups (15 + 3 screens) | 0.1 | L |
| 3.2 | — | Optional snapshot tests for `IOSCompanionActivitySelectionView` EN/IT @ SE + Pro Max | 3.1 | M |
| 3.3 | — | Capture physical-device PNG pack per `Docs/ReferenceUI/README.md` | 3.2 | M |

### Phase 4 — Accessibility & localization polish (P2/P3)

| Order | ID | Action | Depends on | Effort |
|-------|-----|--------|------------|--------|
| 4.1 | AUDIT15-L10N-001 | Decide: keep brand hardcoded or add l10n key | — | S |
| 4.2 | AUDIT15-UX-010 | Replace safety-card hardcoded RGB with `DIRTheme` token | — | S |
| 4.3 | — | VoiceOver walkthrough script for activity selection + three logbooks | 1.2 | M |
| 4.4 | — | Dynamic Type stress @ AX5 on selection cards + tab bars | 4.3 | M |

### Phase 5 — Physical QA gate (external release)

| Order | Action | Depends on |
|-------|--------|------------|
| 5.1 | Smallest iPhone + largest iPhone clipping pass | 4.4 |
| 5.2 | Watch 41 mm + Ultra layout pass | 2.1 |
| 5.3 | Sign integrated physical QA matrix (Audit 13 external NO-GO) | 5.1, 5.2 |

---

## Severity → release impact

| Severity | Count | Blocks internal dev | Blocks TestFlight | Blocks App Store |
|----------|-------|--------------------|--------------------|------------------|
| P0 | 0 | No | — | — |
| P1 | 5 | No | Conditional | Yes |
| P2 | 4 | No | No | Conditional |
| P3 | 3 | No | No | No |

---

## Expected outcome after Phase 1–2

| Metric | Current | Target |
|--------|---------|--------|
| iOS root-flow readiness | 89 | 94 |
| iOS functional-link completeness | 86 | 92 |
| Mockup-path integrity | 78 | 90 |
| Global UI/UX readiness | 84 | 90 |
| Final label | CONDITIONAL PASS | PASS (software); external still needs Phase 5 |

---

## Out of scope (explicit)

- Decompression algorithm changes
- Logbook store merge or unified archive UI
- New mockup PNG generation (audit is read-only)
- Snapshot baseline updates in CI (report-only per Command 15 §19)
