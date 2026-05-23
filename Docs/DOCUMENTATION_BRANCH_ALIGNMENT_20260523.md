# Allineamento branch documentazione — 2026-05-23 / aggiornato 2026-05-24

## Snapshot post-fetch

| Branch | Commit | Divergenza da `origin/main` |
|--------|--------|----------------------------|
| `main` (locale) | `6cda004`+ | Allineato con `origin/main` dopo push readiness |
| `origin/main` | `6cda004` | Depth safety + bundle `.ios.watch` |
| `main-iOS` | `6ad130c` merge-base | **~168 commit dietro** `main` / **43 ahead** — merge runtime non automatico |
| `codex/experimental-features` | `6649335` | Watch experimental (Snorkeling Live, mappe, Apnea, Buddy) |
| `codex/ios-experimental-features` | `9e5baca` | iOS experimental (Explore Lab) |

## Cosa contiene `main` e non `main-iOS`

- Workspace unificato Watch + iOS (`project.yml` unico).
- Depth limits 35/38/40 m (`6cda004`).
- Readiness 100% UX: CSV import Logbook/More, planner tabs, legal scroll, units honesty.
- Bundle Watch `com.egopfe.dirdiving.ios.watch` embedded in `com.egopfe.dirdiving.ios`.
- Documentazione audit UX 20260523, TestFlight checklist entitlement.

## Strategia documentazione

1. **Fonte di verità:** branch `main` (root workspace).
2. **`main-iOS`:** allineare file `Docs/`, `README.md`, `CHANGELOG.md`, `CONTRIBUTING.md` **senza** merge runtime finché non c'è review dedicata.
3. **Experimental:** documentati in CSV/README; file esclusi da `project.yml` per target MAIN.

## PR

| PR | Merge | Motivo |
|----|-------|--------|
| #8 | ❌ auto | CONFLICTING; preservare excludes MAIN |
| #9 | ❌ auto | CONFLICTING; F4/F5 export/import |

## Build / project.yml

| Item | Valore |
|------|--------|
| Watch bundle | `com.egopfe.dirdiving.ios.watch` |
| iOS bundle | `com.egopfe.dirdiving.ios` |
| `WKCompanionAppBundleIdentifier` | `com.egopfe.dirdiving.ios` |
| Entitlements Watch | water-submersion + iCloud KVS |
| Esclusioni MAIN | Apnea, Snorkeling, Buddy, Exploration views/services |

## Riferimenti UI master

- Watch MAIN: `Docs/ReferenceUI/Watch_LIVE_reference.png`
- iOS MAIN: `Docs/ReferenceUI/iOS_Companion_reference.png`
- Snorkeling experimental: `Docs/SNORKELING_EXPERIMENTAL_SPEC.md`

## Terminologia

- UI italiana: **BUSSOLA** — non usare «COMPASSO».
- GPS: solo superficie; return-to-entry e marker snorkeling restano su branch experimental.

---

*Allineamento documentale — nessuna modifica GPS/BUSSOLA/calcoli*
