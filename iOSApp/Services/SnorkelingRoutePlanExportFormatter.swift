import Foundation

enum SnorkelingRoutePlanExportFormatter {
    static func shareText(
        draft: SnorkelingRoutePlannerDraft,
        profile: SnorkelingCompanionProfile?,
        validation: SnorkelingRouteValidationResult
    ) -> String {
        let distance = SnorkelingDistanceCalculator.distanceMeters(points: draft.routingPoints)
        let duration = SnorkelingDurationEstimator.estimatedDurationSeconds(
            distanceMeters: distance,
            draft: draft,
            profile: profile
        )
        var lines: [String] = []
        let name = draft.name.trimmingCharacters(in: .whitespacesAndNewlines)
        lines.append(name.isEmpty ? "Snorkeling route plan" : name)
        lines.append("Route type: \(draft.resolvedRouteType.rawValue)")
        if let entry = draft.entryPoint {
            lines.append(String(format: "Entry: %.5f, %.5f", entry.latitude, entry.longitude))
        }
        for waypoint in draft.waypoints.sorted(by: { $0.routeOrder < $1.routeOrder }) {
            let label = waypoint.name.isEmpty ? "Waypoint \(waypoint.routeOrder + 1)" : waypoint.name
            lines.append(String(format: "%@: %.5f, %.5f", label, waypoint.latitude, waypoint.longitude))
        }
        if let exit = draft.exitPoint {
            lines.append(String(format: "Exit: %.5f, %.5f", exit.latitude, exit.longitude))
        }
        lines.append(String(format: "Estimated distance: %.0f m", distance))
        lines.append(String(format: "Estimated duration: %.0f min", duration / 60))
        lines.append("Route check: \(validation.status.rawValue)")
        if !validation.warnings.isEmpty {
            lines.append("Warnings: \(validation.warnings.map(\.rawValue).joined(separator: ", "))")
        }
        lines.append("GPS-based orientation aid. Not a life-saving navigation system.")
        return lines.joined(separator: "\n")
    }
}
