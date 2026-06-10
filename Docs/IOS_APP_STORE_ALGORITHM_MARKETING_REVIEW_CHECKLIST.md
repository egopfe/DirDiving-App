# iOS App Store — Algorithm & Marketing Review Checklist

Use before App Store submission. DIR DIVING is a **non-certified reference companion** — not a dive computer, decompression planner certification, or CCR life-support controller.

---

## Prohibited claims (must NOT appear in store copy, screenshots, or in-app marketing)

- [ ] Certified dive computer
- [ ] Certified decompression planner
- [ ] Certified CCR controller / life-support system
- [ ] Real-time loop PPO₂ monitoring or solenoid control
- [ ] Authoritative bailout decompression schedule (heuristic only)

## Required disclosures

- [ ] Reference-only / non-certified planner posture (`Docs/SAFETY_DISCLAIMER.md`, in-app legal)
- [ ] CCR is reference planning only (`Docs/CCR_REBREATHER_LIMITATIONS.md`)
- [ ] CCR bailout is heuristic SAC estimate — not Bühlmann OC simulation
- [ ] Ratio Deco is heuristic comparator — Bühlmann remains primary reference
- [ ] TestFlight review notes aligned (`Docs/TESTFLIGHT_REVIEW_NOTES.md`)

## Evidence gates (must be PASS or waived before external release)

- [ ] External Bühlmann validation — [`Docs/QA_EVIDENCE/BUHLMANN_EXTERNAL/`](QA_EVIDENCE/BUHLMANN_EXTERNAL/README.md)
- [ ] External CCR validation — [`Docs/QA_EVIDENCE/CCR_EXTERNAL/`](QA_EVIDENCE/CCR_EXTERNAL/README.md)
- [ ] iCloud two-device QA — [`Docs/QA_EVIDENCE/ICLOUD_TWO_DEVICE/`](QA_EVIDENCE/ICLOUD_TWO_DEVICE/README.md)
- [ ] Subsurface CSV external — [`Docs/QA_EVIDENCE/SUBSURFACE_CSV/`](QA_EVIDENCE/SUBSURFACE_CSV/README.md)
- [ ] Accessibility QA — [`Docs/QA_EVIDENCE/IOS_ACCESSIBILITY/`](QA_EVIDENCE/IOS_ACCESSIBILITY/README.md)
- [ ] Watch physical QA (companion scope) — separate matrices

## Review sign-off

| Role | Name | Date | Approved |
|---|---|---|---|
| Legal | | | PENDING |
| Product / marketing | | | PENDING |
| Algorithm owner | | | PENDING |

**App Store submission remains blocked until evidence gates and legal/marketing sign-off are complete.**
