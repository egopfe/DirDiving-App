# Documentation branch alignment (2026-05-20)

Allineamento documentazione dopo `git fetch origin` e implementazione banner risalita su `main`.

---

## Remote branches (origin)

| Branch | Ruolo |
|--------|-------|
| `main` | Watch MAIN stabile + `iOSApp/` legacy nel workspace XcodeGen |
| `main-iOS` | Companion iOS canonico (worktree separato consigliato) |
| `codex/experimental-features` | Watch: Snorkeling Live, mappe, Apnea, Buddy |
| `codex/ios-experimental-features` | iOS: Explore Lab, Apnea Review, POI enrichment |

---

## Divergence notes

### `main` (local vs `origin/main`)

- Commit `a75a6c3`: P0/P1/P2 implementation (sync inbound, tombstones, GPS banner, alarm OK).
- Commit docs + `fix(i18n)` secondario (questo pass 2026-05-20).
- Push `origin/main` dopo commit documentazione/i18n.

### `main-iOS`

- Allineare **documentazione** (README se presente, `Docs/DIR_DIVING_Feature_Comparison.csv`, `CHANGELOG.md`, report 20260520) senza toccare business logic.
- SAF-3/SAF-4 già su `origin/main-iOS` (`bf4718d`).

### Experimental branches

- Documentazione snorkeling/apnea: `Docs/SNORKELING_EXPERIMENTAL_SPEC.md`, `Docs/APNEA_EXPERIMENTAL_SPEC.md`, `Docs/EXPERIMENTAL_FEATURES.md`.
- Non promuovere file experimental nel target MAIN (`project.yml` exclude list).

---

## Terminology preserved

- **BUSSOLA** (mai COMPASSO)
- GPS **surface-only**
- Return-to-entry snorkeling su branch experimental
- Export Subsurface invariato (formato CSV business)

---

## Backup branches (local)

- `backup/before-docs-merge-20260520` — creato prima commit docs (se presente)
- `backup/main-watch-backlog-20260519` — commit UX Watch da cherry-pick
- `backup/before-docs-pre-release-pass-20260519`

---

*2026-05-20 · additive alignment note*
