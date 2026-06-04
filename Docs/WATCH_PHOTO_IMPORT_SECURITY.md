# Watch Photo Import Security

Companion photos transferred to Watch are:

1. Size-bounded (10 MB)
2. Filename-sanitized (no path traversal)
3. Decoded as `UIImage` on Watch
4. Re-encoded to normalized JPEG before storage
5. Written with `.completeFileProtection`

Non-image bytes with `.jpg` extension are rejected.
