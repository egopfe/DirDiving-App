# Apnea Planner Session Check Integration

## Section order

1. Title  
2. Session type  
3. Profile  
4. Series  
5. Recovery  
6. Pre-apnea checklist (compact)  
7. Apnea Session Check  
8. Notes  
9. Watch transfer  

## Evaluator

`IOSApneaSessionPlannerView` uses `ApneaReadinessPresentation.plannerSessionCheck`, wrapping `ApneaSessionCheckEvaluator` with:

- Selected profile (companion → session profile bridge)
- Draft recovery policy
- Recovery alerts (`hapticsEnabled`)
- `buddyChecklistConfirmed` from persisted checklist

## Send to Watch

Disabled when planner validation fails **or** session check is `.incomplete` / `.blocked`.

`.warning` allows send; orange warning badge shown in transfer section.

## Wording

Session check is a **training aid / session reminder**, not safety certification.
