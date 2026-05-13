import Foundation

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
        }
        isReady = true
        saveIfReady()
    }

    var routeDistanceMeters: Double { 742 }
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
        syncStatus = "Route, waypoint e warning inviati al Watch"
        route.syncReady = true
        saveIfReady()
    }

    func exportGPX() {
        exportStatus = "GPX esportato: \(route.waypoints.count) waypoint"
        saveIfReady()
    }

    func exportCSV() {
        exportStatus = "CSV esportato: analytics + marker"
        saveIfReady()
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
}

private struct ExplorationPlanningState: Codable {
    var route: SnorkelingRoutePlan
    var selectedWaypoint: ExplorationWaypoint?
    var settings: ExplorationSettings
    var exportStatus: String
    var syncStatus: String
    var offlineMapStatus: String
}
