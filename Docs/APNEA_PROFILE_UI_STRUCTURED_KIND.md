# Apnea Profile UI — Structured Kind

## Profile list

`IOSApneaProfilePresentation.subtitle` shows:

- Profile kind (localized)
- Target depth / duration
- Recovery rule label
- Max repetitions (if set)
- Enabled alarm count

## Editor

`IOSApneaProfileEditorView` sections:

- **Profile type** — `ApneaProfileKind` picker; nil kind resolved via `ApneaSessionProfileBridge.profileKind(for:)`
- **Recovery rule** — maps to `ApneaRecoveryPolicy` modes (1x, 2x, 3x, fixed)
- **Max repetitions** — optional on `ApneaCompanionProfile`

Kind changes set defaults for empty depth/duration only; existing user data is not overwritten aggressively.

Presets remain non-editable in place; duplicate creates editable copy with kind and max repetitions preserved.
