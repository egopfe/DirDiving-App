# Allineamento branch documentazione — 2026-05-23

## Snapshot post-fetch

| Branch | Commit | Divergenza da `origin/main` |
|--------|--------|----------------------------|
| `main` (locale) | `5e595ee` | **+1** (production readiness) vs remote `9b61e55` prima del push |
| `origin/main` | `9b61e55` | Baseline remota pre-push |
| `main-iOS` | `1cc6203` | **Dietro** `main` per codice unificato Watch+iOS |
| `codex/experimental-features` | `6649335` | Parallelo experimental Watch |
| `codex/ios-experimental-features` | `9e5baca` | Parallelo experimental iOS |

## Cosa contiene `main` e non `main-iOS`

- Target unificato `DIRDiving Watch App` + `DIRDiving iOS` in un solo `project.yml`.
- Commit `5e595ee`: iOS→Watch push, conflict UI, i18n, planner ack, mode skip, build product names.
- Documentazione: `MAIN_BRANCH_FINAL_READINESS_REPORT.md`, audit 20260522, playbook internal test.

## Strategia documentazione

1. **Fonte di verità release candidate:** branch `main` (workspace root).
2. **`main-iOS`:** allineare **solo** file in `Docs/`, `CHANGELOG.md`, `README.md`, `CONTRIBUTING.md` copiati da `main` — **non** forzare merge runtime senza review.
3. **Experimental:** documentare in CSV/README; **non** importare file esclusi da `project.yml` nel MAIN.

## PR

| PR | Merge | Motivo |
|----|-------|--------|
| #8 | ❌ auto | CONFLICTING; Apnea/Snorkeling/Buddy non in MAIN target |
| #9 | ❌ auto | CONFLICTING; regressioni security note in audit |

## Build / project.yml

- `project.yml` valido: esclusioni Apnea, Snorkeling, Buddy, Exploration invariati.
- Bundle ID: `com.egopfe.dirdiving` / `com.egopfe.dirdiving.ios` — invariati.
- `PRODUCT_NAME` interni: `DIRDivingWatchApp` / `DIRDivingiOSApp` (display name utente invariato).

## Riferimenti UI master

- Watch: `Docs/ReferenceUI/Watch_LIVE_reference.png`
- iOS: `Docs/ReferenceUI/iOS_Companion_reference.png`
- Snorkeling (experimental): `Docs/SNORKELING_EXPERIMENTAL_SPEC.md`, righe CSV branch `codex/experimental-features`

---

*Allineamento documentale — nessuna modifica GPS/BUSSOLA/calcoli*
