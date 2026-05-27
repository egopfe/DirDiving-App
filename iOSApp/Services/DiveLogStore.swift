import Foundation
import Combine

@MainActor
final class DiveLogStore: ObservableObject {
    static let includeDemoLogbookKey = "dirdiving_ios_include_demo_logbook"

    @Published private(set) var sessions: [DiveSession] = [] {
        didSet { saveIfReady() }
    }

    @Published var includeDemoLogbook: Bool {
        didSet {
            guard isReady, includeDemoLogbook != oldValue else { return }
            UserDefaults.standard.set(includeDemoLogbook, forKey: Self.includeDemoLogbookKey)
            applyDemoLogbookPreference()
        }
    }

    private let cloudSync: CloudSyncStore?
    private let key = "dirdiving_ios_dive_sessions"
    private let deletedKey = WatchSyncKeys.deletedSessionIDsKey
    private let legacyDeletedKeys = [
        "dirdiving_ios_deleted_session_ids",
        "dirdiving_watch_deleted_session_ids"
    ]
    private var deletedSessionIDs: Set<UUID> = []
    private var isReady = false
    private weak var watchSync: WatchSyncService?

    init(cloudSync: CloudSyncStore? = nil) {
        self.cloudSync = cloudSync
        includeDemoLogbook = UserDefaults.standard.bool(forKey: Self.includeDemoLogbookKey)
        deletedSessionIDs = loadDeletedSessionIDs()
        let localSessions = loadLocalSessions()
        let cloudSessions = cloudSync?.load([DiveSession].self, forKey: key)
        sessions = IOSDiveLogbookPolicy.normalizeAndCap(
            mergedSessions(local: localSessions, cloud: cloudSessions)
                .filter { !deletedSessionIDs.contains($0.id) }
        )

        if includeDemoLogbook, sessions.filter({ !$0.isDemoDive }).isEmpty {
            insertDemoDives()
        }

        isReady = true
        saveIfReady()

        NotificationCenter.default.addObserver(
            forName: .cloudSyncDidChangeExternally,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in self?.reloadFromCloud() }
        }
    }

    func attachWatchSync(_ service: WatchSyncService) {
        watchSync = service
    }

    func applyRemoteDeletedSessionIDs(_ ids: Set<UUID>) {
        guard !ids.isEmpty else { return }
        deletedSessionIDs.formUnion(ids)
        sessions.removeAll { deletedSessionIDs.contains($0.id) }
        sessions = IOSDiveLogbookPolicy.normalizeAndCap(sessions)
        saveIfReady()
    }

    func reloadFromCloud() {
        guard isReady else { return }
        let localSessions = loadLocalSessions()
        deletedSessionIDs = loadDeletedSessionIDs()
        let cloudSessions = cloudSync?.load([DiveSession].self, forKey: key)
        sessions = IOSDiveLogbookPolicy.normalizeAndCap(
            mergedSessions(local: localSessions, cloud: cloudSessions)
                .filter { !deletedSessionIDs.contains($0.id) }
        )
        applyDemoLogbookPreference()
    }

    func add(_ session: DiveSession, suppressWatchPush: Bool = false) {
        guard !deletedSessionIDs.contains(session.id) else { return }
        guard let storedSession = try? DiveSessionAlgorithmValidator.normalizedForStorage(session, allowEmptySamples: true) else { return }
        sessions.removeAll { $0.id == session.id }
        sessions.insert(storedSession, at: 0)
        sessions = IOSDiveLogbookPolicy.normalizeAndCap(sessions)
        if !suppressWatchPush {
            watchSync?.transferToWatch(storedSession)
        }
    }

    func session(id: UUID) -> DiveSession? {
        sessions.first { $0.id == id }
    }

    func delete(id: UUID) {
        deletedSessionIDs.insert(id)
        sessions.removeAll { $0.id == id }
        saveIfReady()
        watchSync?.publishDeletedSessionIDs([id])
    }

    func delete(at offsets: IndexSet) {
        var removed: Set<UUID> = []
        for index in offsets.sorted(by: >) {
            removed.insert(sessions[index].id)
            deletedSessionIDs.insert(sessions[index].id)
            sessions.remove(at: index)
        }
        saveIfReady()
        if !removed.isEmpty {
            watchSync?.publishDeletedSessionIDs(removed)
        }
    }

    func synchronizeCloud() {
        saveIfReady()
        cloudSync?.synchronize()
    }

    private func loadLocalSessions() -> [DiveSession] {
        cloudSync?.load([DiveSession].self, forKey: key) ?? []
    }

    private func mergedSessions(local: [DiveSession], cloud: [DiveSession]?) -> [DiveSession] {
        var byID: [UUID: DiveSession] = [:]
        for session in local {
            byID[session.id] = session
        }
        if let cloud {
            for session in cloud {
                if let existing = byID[session.id] {
                    byID[session.id] = DiveSessionMerge.preferred(existing, session)
                } else {
                    byID[session.id] = session
                }
            }
        }
        return IOSDiveLogbookPolicy.normalizeAndCap(Array(byID.values))
    }

    private func loadDeletedSessionIDs() -> Set<UUID> {
        var merged = Set<UUID>()
        for legacyKey in legacyDeletedKeys {
            if let legacy = cloudSync?.load([UUID].self, forKey: legacyKey) {
                merged.formUnion(legacy)
            }
            if let data = UserDefaults.standard.data(forKey: legacyKey),
               let decoded = try? JSONDecoder().decode([UUID].self, from: data) {
                merged.formUnion(decoded)
            }
        }
        if let shared = cloudSync?.load([UUID].self, forKey: deletedKey) {
            merged.formUnion(shared)
        }
        if !merged.isEmpty {
            cloudSync?.save(Array(merged), forKey: deletedKey)
        }
        return merged
    }

    private func saveIfReady() {
        guard isReady else { return }
        cloudSync?.save(sessions, forKey: key)
        cloudSync?.save(Array(deletedSessionIDs), forKey: deletedKey)
    }

    private func applyDemoLogbookPreference() {
        if includeDemoLogbook {
            guard sessions.filter({ !$0.isDemoDive }).isEmpty else { return }
            insertDemoDives()
        } else {
            sessions.removeAll { $0.isDemoDive }
        }
    }

    private func insertDemoDives() {
        let names = ["Secca di Mezzo", "Punta Margherita", "Relitto dell'Elba", "Scoglio del Corallo", "Grotta Azzurra"]
        let days = [24, 21, 18, 14, 10]
        let times = [(8, 35), (11, 2), (9, 10), (10, 45), (12, 20)]
        let maxDepths = [42.6, 31.2, 52.8, 24.1, 18.3]
        let durations = [62, 54, 74, 47, 41]
        let gases: [DiveGasLabel] = [.trimix, .oc, .trimix, .nitrox, .oc]

        sessions = IOSDiveLogbookPolicy.normalizeAndCap(names.enumerated().map { idx, name in
            let demoID = DemoDiveCatalog.sessionIDs[idx]
            let start = Calendar.current.date(
                from: DateComponents(year: 2024, month: 5, day: days[idx], hour: times[idx].0, minute: times[idx].1)
            ) ?? Date()
            let duration = Double(durations[idx]) * 60
            let maxDepth = maxDepths[idx]
            let samples = (0...durations[idx]).map { minute -> DiveSample in
                let m = Double(minute)
                let descent = min(maxDepth, m * (maxDepth / 10.0))
                let bottomEnd = duration / 60 - 14
                let profile: Double
                if m < 10 {
                    profile = descent
                } else if m < bottomEnd {
                    profile = maxDepth - sin(m / 5) * 2
                } else {
                    profile = max(0, maxDepth - (m - bottomEnd) * (maxDepth / 14))
                }
                return DiveSample(
                    timestamp: start.addingTimeInterval(m * 60),
                    depthMeters: max(0, profile),
                    temperatureCelsius: 24 - Double(idx)
                )
            }
            let avg = samples.map(\.depthMeters).reduce(0, +) / Double(samples.count)
            return DiveSession(
                id: demoID,
                startDate: start,
                endDate: start.addingTimeInterval(duration),
                durationSeconds: duration,
                maxDepthMeters: samples.map(\.depthMeters).max() ?? maxDepth,
                avgDepthMeters: avg,
                avgWaterTemperatureCelsius: 24 - Double(idx),
                ttv: idx == 0 ? 24 : avg + duration / 60,
                entryGPS: GPSPoint(latitude: 38.1157 + Double(idx) * 0.001, longitude: 13.3615, horizontalAccuracy: 15, timestamp: start),
                exitGPS: GPSPoint(latitude: 38.1162 + Double(idx) * 0.001, longitude: 13.3620, horizontalAccuracy: 18, timestamp: start.addingTimeInterval(duration)),
                samples: samples,
                siteName: name,
                buddy: idx == 0 ? "Buddy" : nil,
                notes: DiveSession.demoNotesLabel,
                gasLabel: gases[idx],
                sacLitersMinute: 18.2 + Double(idx),
                isDemo: true
            )
        })
    }
}
