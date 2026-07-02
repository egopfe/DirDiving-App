import Foundation

enum SnorkelingWatchReadyPresentationPolicy {
    static let lowBatteryFraction = 0.20

    static func batteryPresentation(
        fraction: Double?
    ) -> (text: String, colorToken: SnorkelingWatchColorToken, isLow: Bool) {
        guard let fraction, fraction.isFinite else {
            return (DIRWatchLocalizer.string("snorkeling.watch.ready.battery_unknown"), .secondary, false)
        }
        let percent = Int((max(0, min(1, fraction)) * 100).rounded())
        let isLow = fraction <= lowBatteryFraction
        if isLow {
            return (
                String(format: DIRWatchLocalizer.string("snorkeling.watch.ready.battery_low"), percent),
                .yellow,
                true
            )
        }
        return (
            String(format: DIRWatchLocalizer.string("snorkeling.watch.ready.battery"), percent),
            .green,
            false
        )
    }

    static func routeStatusText(for route: SnorkelingWatchImportedRoutePresentation) -> String {
        if route.staleRevisionRejected {
            return DIRWatchLocalizer.string("snorkeling.route_sync.rejected")
        }
        switch route.status {
        case .ready:
            return DIRWatchLocalizer.string("snorkeling.watch.ready.route_ready")
        case .missing:
            return DIRWatchLocalizer.string("snorkeling.watch.ready.route_missing")
        case .pending:
            return DIRWatchLocalizer.string("snorkeling.route_sync.pending")
        }
    }

    static func routePendingBannerText(for route: SnorkelingWatchImportedRoutePresentation) -> String? {
        guard route.isPendingWhileSessionActive else { return nil }
        return DIRWatchLocalizer.string("snorkeling.watch.ready.route_pending_activation")
    }

    static func precheckSummary(
        gpsStatusText: String,
        gpsIsHealthy: Bool,
        depthSensorHealthy: Bool,
        entryCaptured: Bool,
        route: SnorkelingWatchImportedRoutePresentation,
        buddyEnabled: Bool
    ) -> String {
        let gps = "\(DIRWatchLocalizer.string("snorkeling.watch.ready.precheck_gps")): \(gpsIsHealthy ? "OK" : gpsStatusText)"
        let depth = "\(DIRWatchLocalizer.string("snorkeling.watch.ready.precheck_depth")): \(depthSensorHealthy ? "OK" : "—")"
        let entry = "\(DIRWatchLocalizer.string("snorkeling.watch.ready.precheck_entry")): \(entryCaptured ? DIRWatchLocalizer.string("snorkeling.entry.set") : DIRWatchLocalizer.string("snorkeling.entry.auto"))"
        let routeLine = "\(DIRWatchLocalizer.string("snorkeling.watch.ready.route")): \(routeStatusText(for: route))"
        let buddy = "\(DIRWatchLocalizer.string("snorkeling.watch.ready.precheck_buddy")): \(buddyEnabled ? "ON" : "OFF")"
        return [gps, depth, entry, routeLine, buddy].joined(separator: " · ")
    }

    static func depthSensorIsHealthy(
        depthState: SnorkelingDepthPresentationState,
        sensorHealth: SnorkelingSensorHealth
    ) -> Bool {
        sensorHealth != .manualFallback && depthState != .unavailable
    }

    static func gpsIsHealthy(
        gpsState: SnorkelingGPSPresentationState,
        qualityBand: SnorkelingWatchGPSPresentationBand?
    ) -> Bool {
        if let qualityBand {
            return qualityBand == .good || qualityBand == .medium
        }
        return gpsState == .tracking
    }
}
