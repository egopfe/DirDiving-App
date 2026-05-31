import Foundation
import Combine

@MainActor
final class ExplorationPlanningStore: ObservableObject {
    @Published var route: SnorkelingRoutePlan
    @Published var selectedWaypoint: ExplorationWaypoint?
    @Published var settings = ExplorationSettings() {
        didSet { saveIfReady() }
    }
    @Published var exportStatus = "GPX/CSV pronto"
    @Published var syncStatus = "WatchConnectivity pronto"
    @Published var offlineMapStatus = "MBTiles cache pianificata"
    private let cloudSync: CloudSyncStore?
    private let key = "dirdiving_ios_exploration_state"
    private var isReady = false

    init(cloudSync: CloudSyncStore? = nil) {
        self.cloudSync = cloudSync
        let points = [
            ExplorationWaypoint(name: "Entry Cala", category: .buoy, latitude: 42.4024, longitude: 11.2040, colorName: "orange", routeOrder: 1),
            ExplorationWaypoint(name: "Reef Nord", category: .reef, latitude: 42.4030, longitude: 11.2051, colorName: "cyan", routeOrder: 2),
            ExplorationWaypoint(name: "Relitto Basso", category: .wreck, latitude: 42.4036, longitude: 11.2060, colorName: "yellow", routeOrder: 3),
            ExplorationWaypoint(name: "Spot Foto", category: .photography, latitude: 42.4041, longitude: 11.2068, colorName: "white", routeOrder: 4)
        ]
        route = SnorkelingRoutePlan(name: "Snorkel Mezzo", waypoints: points, offlineCacheReady: true, syncReady: true)
        selectedWaypoint = points.first
        if let saved = cloudSync?.load(ExplorationPlanningState.self, forKey: key) {
            route = saved.route
            selectedWaypoint = saved.selectedWaypoint
            settings = saved.settings
            exportStatus = saved.exportStatus
            syncStatus = saved.syncStatus
            offlineMapStatus = saved.offlineMapStatus
            clearPersistedMockSuccessStates()
        }
        isReady = true
        saveIfReady()
    }

    var routeDistanceMeters: Double {
        guard route.waypoints.count > 1 else { return 0 }
        return zip(route.waypoints, route.waypoints.dropFirst()).reduce(0) { total, pair in
            total + distanceMeters(from: pair.0, to: pair.1)
        }
    }
    var heatmapIntensity: Double { 0.74 }
    var readinessScore: Int { 82 }
    var fatigueTrend: String { "Bassa" }

    var apneaSummaries: [ApneaTrainingSummary] {
        [
            ApneaTrainingSummary(title: "Max Depth", value: "24.8 m", trend: "+2.1 m", color: DIRTheme.cyan),
            ApneaTrainingSummary(title: "Recovery", value: "2.4x", trend: "stabile", color: DIRTheme.green),
            ApneaTrainingSummary(title: "Readiness", value: "\(readinessScore)%", trend: "buona", color: DIRTheme.yellow),
            ApneaTrainingSummary(title: "Fatigue", value: fatigueTrend, trend: "-8%", color: DIRTheme.green)
        ]
    }

    var apneaDurationPoints: [ApneaChartPoint] {
        [
            ApneaChartPoint(label: "D1", value: 64),
            ApneaChartPoint(label: "D2", value: 78),
            ApneaChartPoint(label: "D3", value: 91),
            ApneaChartPoint(label: "D4", value: 86),
            ApneaChartPoint(label: "D5", value: 104)
        ]
    }

    func addWaypointFromTap() {
        let next = route.waypoints.count + 1
        let waypoint = ExplorationWaypoint(
            name: "Waypoint \(next)",
            category: .reef,
            latitude: 42.4024 + Double(next) * 0.0004,
            longitude: 11.2040 + Double(next) * 0.0005,
            routeOrder: next
        )
        route.waypoints.append(waypoint)
        selectedWaypoint = waypoint
        exportStatus = "Route aggiornata"
        saveIfReady()
    }

    func moveWaypointUp(_ waypoint: ExplorationWaypoint) {
        guard let index = route.waypoints.firstIndex(of: waypoint), index > 0 else { return }
        route.waypoints.swapAt(index, index - 1)
        renumberRoute()
    }

    func moveWaypointDown(_ waypoint: ExplorationWaypoint) {
        guard let index = route.waypoints.firstIndex(of: waypoint), index < route.waypoints.count - 1 else { return }
        route.waypoints.swapAt(index, index + 1)
        renumberRoute()
    }

    func syncToWatch() {
        syncStatus = "Mock UI: nessun invio Watch eseguito"
    }

    func exportGPX() {
        exportStatus = "Mock UI: GPX non generato"
    }

    func exportCSV() {
        exportStatus = "Mock UI: CSV non generato"
    }

    private func renumberRoute() {
        for idx in route.waypoints.indices {
            route.waypoints[idx].routeOrder = idx + 1
        }
        exportStatus = "Ordine route aggiornato"
        saveIfReady()
    }

    private func saveIfReady() {
        guard isReady else { return }
        cloudSync?.save(
            ExplorationPlanningState(
                route: route,
                selectedWaypoint: selectedWaypoint,
                settings: settings,
                exportStatus: exportStatus,
                syncStatus: syncStatus,
                offlineMapStatus: offlineMapStatus
            ),
            forKey: key
        )
    }

    private func clearPersistedMockSuccessStates() {
        if exportStatus.localizedCaseInsensitiveContains("esportato") {
            exportStatus = "Mock UI: export non generato"
        }
        if syncStatus.localizedCaseInsensitiveContains("inviati") {
            syncStatus = "Mock UI: nessun invio Watch eseguito"
        }
    }

    private func distanceMeters(from start: ExplorationWaypoint, to end: ExplorationWaypoint) -> Double {
        let earthRadius = 6_371_000.0
        let startLat = start.latitude * .pi / 180
        let endLat = end.latitude * .pi / 180
        let deltaLat = (end.latitude - start.latitude) * .pi / 180
        let deltaLon = (end.longitude - start.longitude) * .pi / 180
        let a = sin(deltaLat / 2) * sin(deltaLat / 2)
            + cos(startLat) * cos(endLat) * sin(deltaLon / 2) * sin(deltaLon / 2)
        return earthRadius * 2 * atan2(sqrt(a), sqrt(1 - a))
    }
}

private struct ExplorationPlanningState: Codable {
    var route: SnorkelingRoutePlan
    var selectedWaypoint: ExplorationWaypoint?
    var settings: ExplorationSettings
    var exportStatus: String
    var syncStatus: String
    var offlineMapStatus: String
}
