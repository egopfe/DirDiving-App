import Foundation

/// Production snorkeling localization keys referenced by shipped Watch UI and operational engines.
enum SnorkelingLocalizationCatalog {
    static let productionKeys: [String] = [
        "snorkeling.ready.duration",
        "snorkeling.ready.distance",
        "snorkeling.ready.mission",
        "snorkeling.surface.header",
        "snorkeling.dip.header",
        "snorkeling.nav.header",
        "snorkeling.return.header",
        "snorkeling.marker.header",
        "snorkeling.summary.header",
        "snorkeling.gps.tracking",
        "snorkeling.gps.degraded",
        "snorkeling.gps.stale",
        "snorkeling.gps.unavailable",
        "snorkeling.gps.underwater",
        "snorkeling.gps.lost",
        "snorkeling.nav.turn_left",
        "snorkeling.nav.turn_right",
        "snorkeling.nav.on_line",
        "snorkeling.nav.gps_unavailable",
        "snorkeling.return.advised",
        "snorkeling.return.advisor.unavailable",
        "snorkeling.return.advisor.distance",
        "snorkeling.return.advisor.duration",
        "snorkeling.return.advisor.battery",
        "snorkeling.return.advisor.manual",
        "snorkeling.return.gps.unavailable",
        "snorkeling.return.gps.degraded",
        "snorkeling.return.heading.stale",
        "snorkeling.return.near.entry",
        "snorkeling.alarm.title",
        "snorkeling.recovery.banner",
        "snorkeling.recovery.subtitle",
        "snorkeling.recovery.gps_degraded",
        "snorkeling.recovery.checkpoint_failed",
        "snorkeling.overlay.sensor_degraded",
        "snorkeling.overlay.gps_underwater",
        "snorkeling.a11y.runtime",
        "snorkeling.a11y.depth",
        "snorkeling.a11y.waypoint_distance",
        "snorkeling.a11y.return_distance",
        "snorkeling.a11y.turn_left",
        "snorkeling.a11y.turn_right",
        "snorkeling.a11y.on_line",
        "snorkeling.a11y.gps_status",
        "snorkeling.a11y.vertical_speed",
        "snorkeling.a11y.recovered_session",
        "snorkeling.a11y.recovery_warning",
        "snorkeling.a11y.return_advisor",
        "snorkeling.a11y.alarm_overlay",
        "snorkeling.a11y.marker_save",
        "snorkeling.a11y.summary",
    ]

    static func keysReferencedInProductionSources(_ sources: [String]) -> Set<String> {
        var keys = Set<String>()
        let pattern = #"\"(snorkeling\.[^\"\\]+)\""#
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return keys }
        for source in sources {
            let range = NSRange(source.startIndex..<source.endIndex, in: source)
            regex.enumerateMatches(in: source, range: range) { match, _, _ in
                guard let match, let keyRange = Range(match.range(at: 1), in: source) else { return }
                let key = String(source[keyRange])
                if key.hasSuffix(".tests") { return }
                if key.hasPrefix("snorkeling.watch.") || key.hasPrefix("snorkeling.ios.") {
                    return
                }
                keys.insert(key)
            }
        }
        return keys
    }
}
