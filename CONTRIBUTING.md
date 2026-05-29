# Contribuire a DIR DIVING

## Principi

1. **Non modificare la business logic** (decompressione, gas, TTV/TTR/SAC/CNS/OTU, sampling sensori, regole sync, persistenza modelli) salvo issue aperta esplicita e review tecnica.
2. **Non cambiare** logica GPS, algoritmi bussola, calcoli profondità/risalita salvo fix di bug approvato.
3. **Non introdurre dipendenze** nuove senza discussione.
4. **Preferire aggiornamenti additivi** alla documentazione (`README.md`, `Docs/*`) invece di riscritture complete.
5. Terminologia UI italiana: usare **BUSSOLA**, non «COMPASSO».

## Documentazione

- Aggiornare `Docs/DIR_DIVING_Feature_Comparison.csv` con **nuove righe** (non cancellare righe storiche senza approvazione).
- Allineare `README.md` con `project.yml` (nomi scheme, piattaforme).
- Aggiornare README/Docs quando cambiano onboarding legale, disclaimer, lingua, unità/sync o Branch Strategy.
- Panoramica funzioni (IT): [`Docs/PRODUCT_FEATURES_IT.md`](Docs/PRODUCT_FEATURES_IT.md).
- Specifiche prodotto MAIN: note v10 [`Docs/DIR_Diving_Complete_Development_Notes_UPDATED_v10.md`](Docs/DIR_Diving_Complete_Development_Notes_UPDATED_v10.md).
- Audit algoritmi (read-only): Watch pre-hardening [`Docs/CODEX_DIR_DIVING_WATCH_ALGORITHM_MATH_AUDIT.md`](Docs/CODEX_DIR_DIVING_WATCH_ALGORITHM_MATH_AUDIT.md); Watch post-hardening [`DIR_DIVING_WATCH_ALGORITHM_MATH_AUDIT.md`](DIR_DIVING_WATCH_ALGORITHM_MATH_AUDIT.md); iOS [`DIR_DIVING_IOS_ALGORITHM_MATH_AUDIT.md`](DIR_DIVING_IOS_ALGORITHM_MATH_AUDIT.md); hardening [`Docs/DIR_DIVING_WATCH_ALGORITHM_RELEASE_HARDENING.md`](Docs/DIR_DIVING_WATCH_ALGORITHM_RELEASE_HARDENING.md), [`Docs/DIR_DIVING_IOS_ALGORITHM_RELEASE_HARDENING.md`](Docs/DIR_DIVING_IOS_ALGORITHM_RELEASE_HARDENING.md).
- Buhlmann iOS: design/verifica in [`Docs/INDEX.md`](Docs/INDEX.md) §6; reaudit [`Docs/DIR_DIVING_IOS_BUHLMANN_REAUDIT_2026-05-28.md`](Docs/DIR_DIVING_IOS_BUHLMANN_REAUDIT_2026-05-28.md) (P1–P3 fix @ `69e69b2`); **UX readiness** [`DIR_DIVING_IOS_BUHLMANN_UX_UI_READINESS_AUDIT.md`](DIR_DIVING_IOS_BUHLMANN_UX_UI_READINESS_AUDIT.md) (gap UI post-fix algoritmico).
- Mission Mode Watch: [`Docs/MISSION_MODE_MAIN_WATCH.md`](Docs/MISSION_MODE_MAIN_WATCH.md).
- Specifiche storiche: [`Docs/DIR_Diving_Main_Branch_Development_Notes.md`](Docs/DIR_Diving_Main_Branch_Development_Notes.md), [`Docs/DIR_DIVING_MAIN_BRANCH_DEVELOPMENT_IMPLEMENTATION_REPORT.md`](Docs/DIR_DIVING_MAIN_BRANCH_DEVELOPMENT_IMPLEMENTATION_REPORT.md).
- Build: seguire `Docs/BUILD_VALIDATION.md` su **macOS**.

## Pull request GitHub

- Se una PR risulta `CONFLICTING` / `DIRTY`, **non** mergeare da automazione: usare `gh pr view` e risolvere su macOS.
- Dopo un pass solo-documentazione, e utile `gh pr comment` con stato e checklist (build, QA BUSSOLA/GPS surface-only).

## Branch

- `main` = stabile Diving + companion iOS nello stesso repo.
- Rami `codex/*` = sperimentale; non mergeare in `main` senza CI/review.
- Le modifiche UI-only devono preservare onboarding legale, Diving mode, GPS surface-only, BUSSOLA, export Subsurface e sync documentati.

## Commit

- Messaggi chiari: prefisso `docs:` per solo documentazione.
- Separare commit documentazione da fix runtime quando possibile.
