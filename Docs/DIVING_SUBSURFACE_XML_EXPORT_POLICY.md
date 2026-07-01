# Diving Subsurface XML Export Policy

See [`DIVING_EXPORT_CSV_XML_UDDF_POLICY.md`](DIVING_EXPORT_CSV_XML_UDDF_POLICY.md).

Minimum XML structure:

```xml
<divelog program="DirDiving">
  <dives>
    <dive date="YYYY-MM-DD" time="HH:mm:ss" duration="M:SS min" maxdepth="X.X m">
      <location>…</location>
      <buddy>…</buddy>
      <notes>…</notes>
      <divecomputer model="DirDiving">
        <sample time="0:00 min" depth="0.0 m" temp="22.0 C" />
      </divecomputer>
    </dive>
  </dives>
</divelog>
```

- XML escaped text fields
- Samples ordered by elapsed time from dive start
- Depth in meters, temperature in Celsius
- Round-trip validated via `SubsurfaceXMLImportParser` in tests
