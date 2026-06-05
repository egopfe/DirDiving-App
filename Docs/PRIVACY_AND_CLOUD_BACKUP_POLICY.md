# Privacy and Cloud Backup Policy (iOS Companion)

Full dive logbook backup to **iCloud Key-Value Store** is **opt-in** (`dirdiving_ios_cloud_backup_enabled`, default **false**).

When enabled, backups may include: dive logs, timestamps, GPS points, notes, gas, equipment, and related session fields.

When disabled:

- Local protected-file logbook persistence continues unchanged
- WatchConnectivity session sync remains separate
- Existing iCloud data is not silently deleted (user may enable backup or manage iCloud separately)

User-facing copy: More → Cloud backup (EN/IT).
