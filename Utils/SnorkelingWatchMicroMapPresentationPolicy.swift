import Foundation

enum SnorkelingWatchMicroMapPresentationPolicy {
    static let maxRoutePoints = 24
    static let projectionSpanMeters: Double = 180

    static func make(
        routeCoordinates: [SnorkelingCoordinate],
        current: SnorkelingCoordinate?,
        entry: SnorkelingEntryPoint?,
        nextWaypoint: SnorkelingWaypoint?,
        headingDegrees: Double?,
        headingQuality: SnorkelingHeadingQuality,
        gpsPresentationState: SnorkelingGPSPresentationState,
        isUnderwater: Bool
    ) -> SnorkelingWatchMicroMapPresentation {
        guard !isUnderwater else { return .unavailable }
        guard gpsPresentationState == .tracking || gpsPresentationState == .degraded else {
            return .unavailable
        }
        guard let current,
              SnorkelingDomainSupport.isValidCoordinate(latitude: current.latitude, longitude: current.longitude) else {
            return .unavailable
        }

        let anchor = current
        let routeLine = downsampledRoute(routeCoordinates).map {
            project(point: $0, anchor: anchor)
        }.filter { $0.x.isFinite && $0.y.isFinite }

        let nextPoint = nextWaypoint.map {
            project(
                point: SnorkelingCoordinate(latitude: $0.latitude, longitude: $0.longitude),
                anchor: anchor
            )
        }

        let entryDirection: Double?
        if let entry, entry.gpsQuality.isMeasuredSurfaceFix {
            entryDirection = SnorkelingDomainSupport.bearingDegrees(
                from: (anchor.latitude, anchor.longitude),
                to: (entry.latitude, entry.longitude)
            )
        } else {
            entryDirection = nil
        }

        let headingAvailable = headingQuality == .valid && headingDegrees != nil
        guard headingAvailable || entryDirection != nil || !routeLine.isEmpty else {
            return .unavailable
        }

        return SnorkelingWatchMicroMapPresentation(
            isAvailable: true,
            routeLine: routeLine,
            currentPoint: SnorkelingWatchMicroMapPoint(x: 0, y: -0.82),
            entryDirectionDegrees: entryDirection,
            nextWaypointPoint: nextPoint,
            unavailableReasonKey: nil
        )
    }

    private static func downsampledRoute(_ coordinates: [SnorkelingCoordinate]) -> [SnorkelingCoordinate] {
        guard coordinates.count > maxRoutePoints else { return coordinates }
        let stride = max(1, coordinates.count / maxRoutePoints)
        var sampled: [SnorkelingCoordinate] = []
        for (index, coordinate) in coordinates.enumerated() where index % stride == 0 {
            sampled.append(coordinate)
        }
        if let last = coordinates.last, sampled.last != last {
            sampled.append(last)
        }
        return sampled
    }

    private static func project(point: SnorkelingCoordinate, anchor: SnorkelingCoordinate) -> SnorkelingWatchMicroMapPoint {
        let eastMeters = (point.longitude - anchor.longitude) * metersPerDegreeLongitude(at: anchor.latitude)
        let northMeters = (point.latitude - anchor.latitude) * 111_320
        let scale = projectionSpanMeters / 2
        let x = max(-1, min(1, eastMeters / scale))
        let y = max(-1, min(1, northMeters / scale))
        return SnorkelingWatchMicroMapPoint(x: x, y: -y)
    }

    private static func metersPerDegreeLongitude(at latitude: Double) -> Double {
        111_320 * cos(latitude * .pi / 180)
    }
}
