# Hardware QA Matrix

Date: 2026-05-31
Scope: Apple Watch Ultra, paired iPhone, simulator-safe behavior, WatchConnectivity, iCloud, and safety warnings.

Run this matrix after `xcodegen generate`, simulator builds, and algorithm tests pass on the exact commit being promoted.

| ID | Area | Hardware / Target | Steps | Expected Result | Evidence |
|---|---|---|---|---|---|
| QA-001 | Simulator-safe startup | iOS simulator + watchOS simulator | Build and launch both apps without water-submersion entitlement. | Apps launch; entitlement-only code paths do not crash simulator builds. | Screenshot/log |
| QA-002 | Real underwater API behavior | Apple Watch Ultra signed with entitlement | Install entitlement-signed build and start a controlled shallow-water session. | `CMWaterSubmersionManager` delivers depth when entitled; entitlement errors are surfaced when not entitled. | Console log + screen recording |
| QA-003 | Depth callback freshness | Apple Watch Ultra / simulator injection if available | Pause or interrupt depth updates after an active profile begins. | Live state marks stale/last-known depth within the configured callback silence window. | Log + timestamp |
| QA-004 | Max-depth warnings | Apple Watch Ultra / simulator profile | Exercise depths near 35 m, 38 m, and 40 m using safe test input or replay. | Warning states, haptics, and log `exceededSupportedDepthRange` match policy. | Video/logbook export |
| QA-005 | Ascent warnings | Apple Watch Ultra / simulator profile | Replay ascent rates at 70%, 100%, and greater than 100% of the configured limit. | Gauge color, threshold labels, inline warning, and haptics align with `AscentStatus`. | Video + test notes |
| QA-006 | Haptics | Apple Watch Ultra | Trigger ascent and depth warnings with haptics enabled and disabled. | Enabled warnings pulse; disabled setting suppresses warning haptics, including delayed pulses. | Tester initials |
| QA-007 | GPS surface entry/exit | Apple Watch Ultra outdoors | Start a surface session with fix, poor-fix, and no-fix conditions where practical. | UI distinguishes fix, fallback, and no-fix; underwater absence is not shown as success. | Screenshots |
| QA-008 | WatchConnectivity direct sync | Paired iPhone + Watch | Keep devices reachable; create or edit a non-demo iOS session and push to Watch. | Watch imports only after payload validation; iOS marks pushed only after signed ACK. | Activity log |
| QA-009 | WatchConnectivity queued sync | Paired iPhone + Watch | Put Watch unreachable/offline; queue an iOS session; reconnect. | Session remains pending until `transferUserInfo` finishes, then is marked pushed once. | Activity log + queue count |
| QA-010 | Watch to iOS signed ACK | Paired iPhone + Watch | Create a real Watch session and sync to iPhone. | Watch removes pending only after signed companion ACK; unsigned ACKs do not clear queue. | Activity log |
| QA-011 | iCloud tombstones | Two iPhones or reinstall scenario | Delete a synced session and allow iCloud KVS tombstone propagation. | Deleted IDs propagate; full sensitive session bodies are not stored in raw KVS. | KVS/defaults inspection |
| QA-012 | Protected log migration | Existing install with legacy defaults/KVS data | Upgrade from a build with legacy log persistence. | Existing logs migrate to protected files and legacy full-session keys are cleared. | File/defaults inspection |
| QA-013 | Photo transfer | Paired iPhone + Watch | Send allowed `png/jpg/jpeg/heic`; attempt unsupported extension, path-like name, and over-10 MB file. | Allowed file imports with sanitized name; unsafe or oversize files are rejected. | Activity log |
| QA-014 | iOS planner max-depth safety | iPhone | Plan a dive where average depth is safe but max depth violates MOD. | MOD/Buhlmann safety checks use planned max depth; average depth only affects consumption summaries. | Screenshot/test data |

Final promotion requires every row to be PASS, BLOCKED with exact external reason, or product-accepted with documented residual risk.
