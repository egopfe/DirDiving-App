# Depth Capability Matrix

## Activity availability

| Capability | Snorkeling | Apnea | Diving Gauge | Diving Full Computer | Notes |
|------------|------------|-------|--------------|----------------------|-------|
| none | disabled | disabled | disabled | disabled | no real depth |
| simulation | developer only | developer only | developer only | disabled | not real data |
| appleShallow | enabled | enabled limited | developer/internal only | **disabled** | real shallow data |
| appleFull | enabled | enabled | enabled | enabled if validated | requires full QA |

Implementation: `DepthCapabilityPolicy` in `Utils/DepthCapabilityPolicy.swift`.

## Sensor source vs capability

| User selection | Resolved capability (examples) | Effective provider |
|----------------|------------------------------|-------------------|
| Automatic | `.appleFull` | Apple full |
| Automatic | `.appleShallow` | Apple shallow |
| Automatic | `.none` (release) | Unavailable |
| Automatic | `.simulation` (dev only) | Mock |
| Apple Sensor | `.appleShallow` | Apple shallow |
| Apple Sensor | `.appleFull` | Apple full |
| Simulation | `.simulation` (dev) | Mock |

## Sample source tagging

| Provider | `DepthSampleSource` | Logbook label (EN) |
|----------|---------------------|----------------------|
| Apple shallow | `.appleShallow` | Apple Shallow |
| Apple full | `.appleFull` | Apple Full |
| Mock | `.simulation` | Simulation |
| Unavailable | `.unavailable` | Unavailable |

## Full Computer block reasons

| Capability | Reason key |
|------------|------------|
| appleShallow | `watch.depth_capability.full_computer.blocked_shallow` |
| simulation | `watch.depth_capability.full_computer.blocked_simulation` |
| none | `watch.depth_capability.full_computer.blocked_none` |

## Entitlement files

| File | Key | Tier |
|------|-----|------|
| `Config/DIRDiving.entitlements` | (none) | none — default dev/simulator |
| `Config/DIRDiving.WithShallowDepth.entitlements` | `submerged-shallow-depth-and-pressure` | shallow |
| `Config/DIRDiving.WithWaterSubmersion.entitlements` | full / legacy | full |

## QA / release

| Gate | Shallow evidence | Verdict |
|------|------------------|---------|
| Internal validation | PENDING allowed | INTERNAL_IMPLEMENTATION_READY |
| Release validation | must be PASS | EXTERNAL_NO_GO until signed |
