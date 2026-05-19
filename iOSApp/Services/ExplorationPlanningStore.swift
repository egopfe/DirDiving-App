import Foundation
import Combine

@MainActor
final class ExplorationPlanningStore: ObservableObject {
    @Published var route: SnorkelingRoutePlan
    @Published var selectedWaypoint: ExplorationWaypoint?
    @Published var settings = ExplorationSettings() {
        didSet { saveIfReady() }
    }
    @Published var exportStatus = "Mock UI: export route non generato"
    @Published var syncStatus = "Sync sperimentale: non ancora sincronizzato"
    @Published var offlineMapStatus = "MBTiles TODO: cache non implementata"
    @Published var mediaAttachmentStatus = "Media TODO: nessun allegato salvato"
    @Published var experimentalSyncQueueCount = 0
    @Published var syncQueueStatus = "Coda experimental vuota"
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
        route = SnorkelingRoutePlan(name: "Snorkel Mezzo", waypoints: points, offlineCacheReady: false, syncReady: false)
        selectedWaypoint = points.first
        if let saved = cloudSync?.load(ExplorationPlanningState.self, forKey: key) {
            route = saved.route
            selectedWaypoint = saved.selectedWaypoint
            settings = saved.settings
            exportStatus = saved.exportStatus
            syncStatus = saved.syncStatus
            offlineMapStatus = saved.offlineMapStatus
            mediaAttachmentStatus = saved.mediaAttachmentStatus ?? mediaAttachmentStatus
            experimentalSyncQueueCount = saved.experimentalSyncQueueCount ?? 0
            syncQueueStatus = saved.syncQueueStatus ?? syncQueueStatus
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
        exportStatus = "Waypoint mock aggiunto: export TODO"
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
        let envelope = makeRouteManifestEnvelope()
        enqueueExperimentalSync(envelope, note: "Route manifest pronto per invio Watch")
        syncStatus = "SYNC QUEUE: \(envelope.kind.rawValue) accodato (\(route.waypoints.count) waypoint). Invio/ACK reale resta LAB."
        saveIfReady()
    }

    func prepareWatchSyncManifest() {
        let routeEnvelope = makeRouteManifestEnvelope()
        let settingsEnvelope = makeSettingsEnvelope()
        enqueueExperimentalSync(routeEnvelope, note: "Route manifest")
        enqueueExperimentalSync(settingsEnvelope, note: "Settings manifest")
        syncStatus = "Manifest accodati: \(routeEnvelope.kind.rawValue) + \(settingsEnvelope.kind.rawValue). Invio reale resta LAB."
        saveIfReady()
    }

    func requestMediaAttachment(_ kind: String) {
        mediaAttachmentStatus = "\(kind): selezione mock. TODO media picker/storage iOS companion experimental."
        saveIfReady()
    }

    func requestOfflineMapPreparation() {
        offlineMapStatus = "MBTiles TODO: MapLibre/OSM/OpenSeaMap non inizializzati; GEBCO/EMODnet overlay pianificati."
        saveIfReady()
    }

    func acknowledgeExperimentalQueue() {
        experimentalSyncQueueCount = 0
        syncQueueStatus = "Coda marcata come revisionata localmente. Nessun ACK Watch reale."
        saveIfReady()
    }

    func exportGPX() {
        exportStatus = "MOCK EXPORT: GPX non generato. Contratto route pronto, file reale TODO."
        saveIfReady()
    }

    func exportCSV() {
        exportStatus = "MOCK EXPORT: CSV non generato. POI/route export reale TODO."
        saveIfReady()
    }

    func adjustApneaWarning(by delta: Double) {
        settings.apneaDurationWarningSeconds = min(300, max(30, settings.apneaDurationWarningSeconds + delta))
        syncStatus = "Settings locali aggiornati: sync Watch TODO"
        saveIfReady()
    }

    func adjustRecoveryRatio(by delta: Double) {
        settings.recoveryRatio = min(4.0, max(1.0, settings.recoveryRatio + delta))
        syncStatus = "Settings locali aggiornati: sync Watch TODO"
        saveIfReady()
    }

    func adjustDriftThreshold(by delta: Double) {
        settings.driftThresholdMeters = min(1_000, max(50, settings.driftThresholdMeters + delta))
        syncStatus = "Settings locali aggiornati: sync Watch TODO"
        saveIfReady()
    }

    func adjustWaypointAutoSwitch(by delta: Double) {
        settings.waypointAutoSwitchMeters = min(100, max(5, settings.waypointAutoSwitchMeters + delta))
        syncStatus = "Settings locali aggiornati: sync Watch TODO"
        saveIfReady()
    }

    private func renumberRoute() {
        for idx in route.waypoints.indices {
            route.waypoints[idx].routeOrder = idx + 1
        }
        exportStatus = "Ordine route aggiornato: export TODO"
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
                offlineMapStatus: offlineMapStatus,
                mediaAttachmentStatus: mediaAttachmentStatus,
                experimentalSyncQueueCount: experimentalSyncQueueCount,
                syncQueueStatus: syncQueueStatus
            ),
            forKey: key
        )
    }

    private func makeRouteManifestEnvelope() -> ExperimentalSyncEnvelope {
        ExperimentalSyncEnvelope(
            kind: .companionRouteManifest,
            payload: [
                "routeID": route.id.uuidString,
                "routeName": route.name,
                "waypointCount": String(route.waypoints.count),
                "distanceMeters": String(Int(routeDistanceMeters)),
                "offlineCacheReady": String(route.offlineCacheReady)
            ]
        )
    }

    private func makeSettingsEnvelope() -> ExperimentalSyncEnvelope {
        ExperimentalSyncEnvelope(
            kind: .companionSettings,
            payload: [
                "apneaDurationWarningSeconds": String(Int(settings.apneaDurationWarningSeconds)),
                "recoveryRatio": String(settings.recoveryRatio),
                "driftThresholdMeters": String(Int(settings.driftThresholdMeters)),
                "waypointAutoSwitchMeters": String(Int(settings.waypointAutoSwitchMeters))
            ]
        )
    }

    private func enqueueExperimentalSync(_ envelope: ExperimentalSyncEnvelope, note: String) {
        experimentalSyncQueueCount = min(99, experimentalSyncQueueCount + 1)
        syncQueueStatus = "\(note): \(envelope.kind.rawValue). Coda locale: \(experimentalSyncQueueCount)."
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
    var mediaAttachmentStatus: String?
    var experimentalSyncQueueCount: Int?
    var syncQueueStatus: String?
}
