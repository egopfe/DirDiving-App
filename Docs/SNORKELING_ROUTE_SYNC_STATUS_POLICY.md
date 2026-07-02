# Snorkeling Route Sync Status Policy

Presentation-only mapping from `IOSSnorkelingWatchSyncState` to user-visible labels.

- **sent** — package queued or transmitting
- **pending** — awaiting Watch ACK
- **received** — prior successful delivery without fresh ACK
- **activated** — Watch ACK `imported`
- **rejected** — ACK failure or stale revision

Uses existing signed ACK infrastructure; does not fabricate ACKs.
