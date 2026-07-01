# Diving UDDF Export Policy

See [`DIVING_EXPORT_CSV_XML_UDDF_POLICY.md`](DIVING_EXPORT_CSV_XML_UDDF_POLICY.md).

Minimum UDDF structure:

```xml
<uddf version="3.2.0">
  <profiledata>
    <repetitiongroup>
      <dive id="…">
        <datetime>ISO8601</datetime>
        <informationafterdive>
          <greatestdepth><depth>…</depth></greatestdepth>
          <diveduration>seconds</diveduration>
        </informationafterdive>
        <samples>
          <waypoint>
            <divetime>0</divetime>
            <depth>0.0</depth>
            <temperature>22.0</temperature>
          </waypoint>
        </samples>
      </dive>
    </repetitiongroup>
  </profiledata>
</uddf>
```

- Multi-dive supported in one file
- Round-trip validated via `UDDFImportParser` in tests
