# Master Physical Performance QA Plan (CURRENT)

**Scope:** Watch + iOS + paired-device + Instruments verification for performance/concurrency/battery gates.

## Required execution status in this audit

- Physical Watch/iPhone runtime: `NOT_EXECUTED`
- Paired-device stress sync: `NOT_EXECUTED`
- Instruments profiling: `NOT_EXECUTED`

## Mandatory scenarios

1. Watch Full Computer sustained 2-4h runtime with thermal and battery observations
2. Snorkeling long-route capture/render with device movement and route safety messaging
3. iOS large logbook scrolling and detail navigation under realistic session volumes
4. Paired Watch<->iOS sync burst with large payload fallback
5. Startup/first-render timing on representative iPhone and Watch targets

## Evidence requirements

- Device identifiers, OS versions, timestamps
- Instruments traces (Time Profiler, Core Animation, Energy where applicable)
- Pass/fail notes with exact scenario IDs
- Attached artifacts under `Docs/QA_EVIDENCE/...`

## Gate policy

Until these artifacts exist, keep:

- `PHYSICAL_WATCH_QA: PENDING_PHYSICAL`
- `PHYSICAL_IOS_QA: PENDING_PHYSICAL`
- `PAIRED_DEVICE_QA: PENDING_PHYSICAL`
- `PHYSICAL_INSTRUMENTS_PROFILING: PENDING_INSTRUMENTS`
