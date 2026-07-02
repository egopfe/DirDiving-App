# Watch Full Computer Numerical Error Budget (V1.7)

| Source_of_Error | Bound | Measured_Worst_Case | Safety_Direction | Accepted | Evidence |
|---|---:|---:|---|---|---|
| Schreiner analytic vs stepped | 1e-4 bar | <=1e-4 bar | Conservative/neutral | YES | `SchreinerAnalyticParityTests` |
| Tissue floating precision (Double) | 1e-6 bar per update | <1e-6 bar observed in tests | Neutral | YES | core algorithm tests |
| Ceiling depth conversion rounding | <=0.1 m display | <=0.1 m display delta | Conservative | YES | solver tests and review |
| TTS quantization (1-min forward steps) | <=60 s | <=60 s documented | Conservative high-side | YES | TTS sweep tests |
| Segment sub-step integration (30 s) | bounded by configured sub-step | within oracle tolerance | Conservative/neutral | YES | Audit15 oracle profiles |
| Invalid numeric guards (NaN/Inf/dt<=0) | fail-safe | fail-safe branches covered | Conservative | YES | timing fault tests |

No evidence of optimistic fail-open numerical behavior was found in this run.
