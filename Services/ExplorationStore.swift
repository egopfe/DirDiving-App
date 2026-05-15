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
    @Published private(set) var snorkelingDistanceMeters: Double = 0
    private var snorkelingStartedAt: Date?
    private var snorkelingLastSampleAt: Date?
    private var snorkelingLastSpeedMetersPerSecond: Double = 0
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
    var runtimeSeconds: TimeInterval {
        guard let snorkelingStartedAt,
              snorkelingState == .active || snorkelingState == .navigation || snorkelingState == .returnMode else {
            return 0
        }
        return Date().timeIntervalSince(snorkelingStartedAt)
    }

    var distanceMeters: Double {
        snorkelingState == .idle || snorkelingState == .ended ? 0 : snorkelingDistanceMeters
    }

    var averageSpeedKnots: Double {
        let runtime = runtimeSeconds
        guard runtime > 0 else { return 0 }
        return (distanceMeters / runtime) * 1.94384
    }

    var entryDistanceMeters: Double {
        guard snorkelingState == .returnMode || snorkelingState == .navigation else { return 0 }
        return max(0, snorkelingDistanceMeters * 0.42)
    }
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
            snorkelingDistanceMeters = state.snorkelingDistanceMeters ?? 0
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
        snorkelingStartedAt = Date()
        snorkelingLastSampleAt = snorkelingStartedAt
        snorkelingDistanceMeters = 0
        snorkelingLastSpeedMetersPerSecond = 0
        saveIfReady()
    }

    func updateSnorkelingProgress(speedMetersPerSecond: Double) {
        guard snorkelingState == .active || snorkelingState == .navigation || snorkelingState == .returnMode else { return }
        let now = Date()
        if snorkelingStartedAt == nil {
            snorkelingStartedAt = now
            snorkelingLastSampleAt = now
        }
        let delta = max(0, now.timeIntervalSince(snorkelingLastSampleAt ?? now))
        let speed = max(0, speedMetersPerSecond)
        snorkelingDistanceMeters += ((snorkelingLastSpeedMetersPerSecond + speed) / 2) * delta
        snorkelingLastSpeedMetersPerSecond = speed
        snorkelingLastSampleAt = now
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
        snorkelingStartedAt = nil
        snorkelingLastSampleAt = nil
        snorkelingLastSpeedMetersPerSecond = 0
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
        let plannedRecovery = max(currentApneaSeconds * 2, currentApneaSeconds * 1.8)
        apneaDives.insert(
            ApneaDiveRecord(
                durationSeconds: currentApneaSeconds,
                maxDepthMeters: maxDepthMeters,
                recoverySeconds: plannedRecovery
            ),
            at: 0
        )
        recoverySeconds = plannedRecovery
        apneaState = .surface
        if plannedRecovery < currentApneaSeconds * 2 {
            apneaWarning = "RECOVERY INSUFFICIENTE"
            apneaState = .warning
        } else {
            apneaWarning = nil
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
                snorkelingWarning: snorkelingWarning,
                snorkelingDistanceMeters: snorkelingDistanceMeters
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
    var snorkelingDistanceMeters: Double?
}
