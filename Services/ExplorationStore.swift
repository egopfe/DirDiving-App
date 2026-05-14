import Foundation
import Combine

@MainActor
final class ExplorationStore: ObservableObject {
    @Published var selectedMode: DIRActivityMode = .diving
    @Published var snorkelingState: ExplorationSessionState = .idle
    @Published var apneaState: ExplorationSessionState = .idle
    @Published var activeWaypointIndex: Int = 0
    @Published var markers: [GPSInterestMarker] = []
    @Published var apneaDives: [ApneaDiveRecord] = []
    @Published var currentMarkerCategory: GPSMarkerCategory = .reef
    @Published var currentApneaSeconds: TimeInterval = 84
    @Published var recoverySeconds: TimeInterval = 156
    @Published var apneaCount: Int = 4
    @Published var apneaWarning: String?
    @Published var snorkelingWarning: String?
    private let cloudSync = CloudSyncStore()
    private let cloudKey = "dirdiving_watch_exploration_state"
    private var isReady = false

    let waypoints: [SnorkelingWaypoint] = [
        SnorkelingWaypoint(name: "Entry", category: .buoy, latitude: 42.4024, longitude: 11.2040, targetBearing: 0, distanceMeters: 0),
        SnorkelingWaypoint(name: "Reef Nord", category: .reef, latitude: 42.4030, longitude: 11.2051, targetBearing: 38, distanceMeters: 94),
        SnorkelingWaypoint(name: "Relitto Basso", category: .wreck, latitude: 42.4036, longitude: 11.2060, targetBearing: 74, distanceMeters: 168),
        SnorkelingWaypoint(name: "Spot Foto", category: .photoSpot, latitude: 42.4041, longitude: 11.2068, targetBearing: 118, distanceMeters: 230)
    ]

    var activeWaypoint: SnorkelingWaypoint { waypoints[min(activeWaypointIndex, waypoints.count - 1)] }
    var runtimeSeconds: TimeInterval { snorkelingState == .active || snorkelingState == .navigation || snorkelingState == .returnMode ? 1740 : 0 }
    var distanceMeters: Double { snorkelingState == .idle ? 0 : 742 }
    var averageSpeedKnots: Double { snorkelingState == .idle ? 0 : 1.4 }
    var entryDistanceMeters: Double { snorkelingState == .returnMode ? 318 : 142 }
    var gpsStatus: String { snorkelingState == .active ? "SURFACE GPS" : "LAST FIX" }

    init() {
        if let state = cloudSync.load(ExplorationState.self, forKey: cloudKey) {
            selectedMode = state.selectedMode
            snorkelingState = state.snorkelingState
            apneaState = state.apneaState
            activeWaypointIndex = state.activeWaypointIndex
            markers = state.markers
            apneaDives = state.apneaDives
            currentMarkerCategory = state.currentMarkerCategory
            currentApneaSeconds = state.currentApneaSeconds
            recoverySeconds = state.recoverySeconds
            apneaCount = state.apneaCount
            apneaWarning = state.apneaWarning
            snorkelingWarning = state.snorkelingWarning
        }
        isReady = true
        saveIfReady()
    }

    func select(_ mode: DIRActivityMode) {
        selectedMode = mode
        saveIfReady()
    }

    func startSnorkeling() {
        snorkelingState = .active
        snorkelingWarning = nil
        saveIfReady()
    }

    func startNavigation() {
        snorkelingState = .navigation
        saveIfReady()
    }

    func startReturnMode() {
        snorkelingState = .returnMode
        activeWaypointIndex = 0
        saveIfReady()
    }

    func endSnorkeling() {
        snorkelingState = .ended
        saveIfReady()
    }

    func nextWaypoint() {
        activeWaypointIndex = min(activeWaypointIndex + 1, waypoints.count - 1)
        snorkelingState = .navigation
        saveIfReady()
    }

    func previousWaypoint() {
        activeWaypointIndex = max(activeWaypointIndex - 1, 0)
        snorkelingState = .navigation
        saveIfReady()
    }

    func saveMarker(gpsPoint: GPSPoint?, depthMeters: Double, bearingDegrees: Double) {
        let marker = GPSInterestMarker(
            category: currentMarkerCategory,
            latitude: gpsPoint?.latitude,
            longitude: gpsPoint?.longitude,
            depthMeters: depthMeters,
            distanceFromEntryMeters: entryDistanceMeters,
            bearingDegrees: bearingDegrees
        )
        markers.insert(marker, at: 0)
        saveIfReady()
    }

    func startApneaSession() {
        apneaState = .surface
        apneaWarning = nil
        recoverySeconds = 0
        saveIfReady()
    }

    func beginApneaDive() {
        apneaState = .dive
        currentApneaSeconds = 0
        apneaCount += 1
        saveIfReady()
    }

    func surfaceFromApnea(maxDepthMeters: Double) {
        apneaState = .surface
        let recovery = max(recoverySeconds, currentApneaSeconds * 1.8)
        apneaDives.insert(ApneaDiveRecord(durationSeconds: currentApneaSeconds, maxDepthMeters: maxDepthMeters, recoverySeconds: recovery), at: 0)
        recoverySeconds = 0
        if recovery < currentApneaSeconds * 2 {
            apneaWarning = "RECOVERY INSUFFICIENTE"
            apneaState = .warning
        }
        saveIfReady()
    }

    func triggerApneaWarning(_ text: String) {
        apneaWarning = text
        apneaState = .warning
        saveIfReady()
    }

    private func saveIfReady() {
        guard isReady else { return }
        cloudSync.save(
            ExplorationState(
                selectedMode: selectedMode,
                snorkelingState: snorkelingState,
                apneaState: apneaState,
                activeWaypointIndex: activeWaypointIndex,
                markers: markers,
                apneaDives: apneaDives,
                currentMarkerCategory: currentMarkerCategory,
                currentApneaSeconds: currentApneaSeconds,
                recoverySeconds: recoverySeconds,
                apneaCount: apneaCount,
                apneaWarning: apneaWarning,
                snorkelingWarning: snorkelingWarning
            ),
            forKey: cloudKey
        )
    }
}

private struct ExplorationState: Codable {
    var selectedMode: DIRActivityMode
    var snorkelingState: ExplorationSessionState
    var apneaState: ExplorationSessionState
    var activeWaypointIndex: Int
    var markers: [GPSInterestMarker]
    var apneaDives: [ApneaDiveRecord]
    var currentMarkerCategory: GPSMarkerCategory
    var currentApneaSeconds: TimeInterval
    var recoverySeconds: TimeInterval
    var apneaCount: Int
    var apneaWarning: String?
    var snorkelingWarning: String?
}
