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
    private let tombstoneKey = "dirdiving_ios_deleted_dive_session_ids"
    private var deletedSessionIDs: Set<UUID> = []
    private var isReady = false

    init(cloudSync: CloudSyncStore? = nil) {
        self.cloudSync = cloudSync
        includeDemoLogbook = UserDefaults.standard.bool(forKey: Self.includeDemoLogbookKey)
        deletedSessionIDs = loadDeletedSessionIDs()
        let localSessions = loadLocalSessions()
        let cloudSessions = cloudSync?.load([DiveSession].self, forKey: key)
        sessions = mergedSessions(local: localSessions, cloud: cloudSessions)
            .sorted { $0.startDate > $1.startDate }

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

    func reloadFromCloud() {
        guard isReady else { return }
        deletedSessionIDs = loadDeletedSessionIDs()
        let localSessions = loadLocalSessions()
        let cloudSessions = cloudSync?.load([DiveSession].self, forKey: key)
        sessions = mergedSessions(local: localSessions, cloud: cloudSessions)
            .sorted { $0.startDate > $1.startDate }
        applyDemoLogbookPreference()
    }

    func add(_ session: DiveSession) {
        deletedSessionIDs.remove(session.id)
        saveDeletedSessionIDs()
        sessions.removeAll { $0.id == session.id }
        sessions.insert(session, at: 0)
        sessions = sessions.sorted { $0.startDate > $1.startDate }
    }

    func session(id: UUID) -> DiveSession? {
        sessions.first { $0.id == id }
    }

    func delete(id: UUID) {
        deletedSessionIDs.insert(id)
        saveDeletedSessionIDs()
        sessions.removeAll { $0.id == id }
    }

    func delete(at offsets: IndexSet) {
        for index in offsets.sorted(by: >) {
            deletedSessionIDs.insert(sessions[index].id)
            sessions.remove(at: index)
        }
        saveDeletedSessionIDs()
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
        return Array(byID.values).filter { !deletedSessionIDs.contains($0.id) }
    }

    private func saveIfReady() {
        guard isReady else { return }
        cloudSync?.save(sessions, forKey: key)
        saveDeletedSessionIDs()
    }

    private func loadDeletedSessionIDs() -> Set<UUID> {
        let cloudIDs = cloudSync?.load([UUID].self, forKey: tombstoneKey) ?? []
        let localIDs = (try? JSONDecoder().decode([UUID].self, from: UserDefaults.standard.data(forKey: tombstoneKey) ?? Data())) ?? []
        return Set(cloudIDs + localIDs)
    }

    private func saveDeletedSessionIDs() {
        let ids = Array(deletedSessionIDs)
        if let data = try? JSONEncoder().encode(ids) {
            UserDefaults.standard.set(data, forKey: tombstoneKey)
        }
        cloudSync?.save(ids, forKey: tombstoneKey)
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

        sessions = names.enumerated().map { idx, name in
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
        }
    }
}
