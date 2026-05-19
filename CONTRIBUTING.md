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
- Build: seguire `Docs/BUILD_VALIDATION.md` su **macOS**.

## Branch

- `main` = stabile Diving + companion iOS nello stesso repo.
- Rami `codex/*` = sperimentale; non mergeare in `main` senza CI/review.

## Commit

- Messaggi chiari: prefisso `docs:` per solo documentazione.
- Separare commit documentazione da fix runtime quando possibile.
