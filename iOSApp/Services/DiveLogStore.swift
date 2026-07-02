import Foundation
import Combine
import os

@MainActor
protocol DiveLogWatchSyncing: AnyObject {
    func transferToWatch(_ session: DiveSession)
    func publishDeletedSessionIDs(_ ids: Set<UUID>)
}

@MainActor
final class DiveLogStore: ObservableObject {
    private static let logger = Logger(subsystem: "com.egopfe.dirdiving.ios", category: "DiveLogStore")

    static let includeDemoLogbookKey = "dirdiving_ios_include_demo_logbook"
    static var testHook_storageDirectoryURL: URL?
    static var testHook_userDefaults: UserDefaults?
    static var testHook_skipInitialLoad = false
    static var testHook_recordWatchTransfer: ((DiveSession) -> Void)?

    @Published private(set) var sessions: [DiveSession] = [] {
        didSet { saveIfReady() }
    }

    @Published var includeDemoLogbook: Bool {
        didSet {
            guard isReady, includeDemoLogbook != oldValue else { return }
            preferencesDefaults.set(includeDemoLogbook, forKey: Self.includeDemoLogbookKey)
            applyDemoLogbookPreference()
        }
    }

    @Published private(set) var sessionMergeConflicts: [DiveSessionMergeConflict] = []

    private var conflictLocalSnapshots: [UUID: DiveSession] = [:]
    private var conflictCloudSnapshots: [UUID: DiveSession] = [:]

    private let cloudSync: CloudSyncStore?
    private let key = "dirdiving_ios_dive_sessions"
    private let protectedFileName = "dirdiving_ios_dive_sessions.json"
    private let deletedKey = WatchSyncKeys.deletedSessionIDsKey
    private let legacyDeletedKeys = [
        "dirdiving_ios_deleted_session_ids",
        "dirdiving_watch_deleted_session_ids"
    ]
    private var deletedSessionIDs: Set<UUID> = []
    private var isReady = false
    private var hasLoadedSessions = false
    private weak var watchSync: (any DiveLogWatchSyncing)?

    init(cloudSync: CloudSyncStore? = nil, watchSync: (any DiveLogWatchSyncing)? = nil) {
        self.cloudSync = cloudSync
        self.watchSync = watchSync
        includeDemoLogbook = (Self.testHook_userDefaults ?? UserDefaults.standard).bool(forKey: Self.includeDemoLogbookKey)
        deletedSessionIDs = loadDeletedSessionIDs()
        isReady = true

        NotificationCenter.default.addObserver(
            forName: .cloudSyncDidChangeExternally,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in self?.reloadFromCloud() }
        }

        Task { @MainActor in
            await self.performInitialLoadIfNeeded()
        }
    }

    func loadIfNeeded() async {
        await performInitialLoadIfNeeded()
    }

    private func performInitialLoadIfNeeded() async {
        guard !hasLoadedSessions else { return }
        if Self.testHook_skipInitialLoad {
            hasLoadedSessions = true
            return
        }
        hasLoadedSessions = true
        let signpost = DIRPerformanceSignpost.begin(.logbookLoad)
        defer { signpost.end() }
        let localSessions = loadLocalSessions()
        let cloudSessions = loadRawCloudSessions()
        updateMergeConflictState(local: localSessions, cloud: cloudSessions ?? [])
        sessions = IOSDiveLogbookPolicy.normalizeAndCap(
            mergedSessions(local: localSessions, cloud: cloudSessions)
                .filter { !deletedSessionIDs.contains($0.id) }
        )

        if includeDemoLogbook {
            insertMissingDemoDives()
        }

        saveIfReady()
    }

    func attachWatchSync(_ service: any DiveLogWatchSyncing) {
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
        let cloudSessions = loadRawCloudSessions()
        updateMergeConflictState(local: localSessions, cloud: cloudSessions ?? [])
        sessions = IOSDiveLogbookPolicy.normalizeAndCap(
            mergedSessions(local: localSessions, cloud: cloudSessions)
                .filter { !deletedSessionIDs.contains($0.id) }
        )
        applyDemoLogbookPreference()
    }

    @discardableResult
    func add(_ session: DiveSession, suppressWatchPush: Bool = false) -> Bool {
        guard !deletedSessionIDs.contains(session.id) else { return false }
        guard let storedSession = try? DiveSessionAlgorithmValidator.normalizedForStorage(session, allowEmptySamples: true) else {
            return false
        }
        sessions.removeAll { $0.id == session.id }
        sessions.insert(storedSession, at: 0)
        sessions = IOSDiveLogbookPolicy.normalizeAndCap(sessions)
        if !suppressWatchPush {
            if let record = Self.testHook_recordWatchTransfer {
                record(storedSession)
            } else {
                watchSync?.transferToWatch(storedSession)
            }
        }
        return true
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
            guard sessions.indices.contains(index) else { continue }
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

    func resolveSessionMergeConflictKeepingLocal(sessionID: UUID) {
        guard let local = conflictLocalSnapshots[sessionID] ?? sessions.first(where: { $0.id == sessionID }) else { return }
        applyResolvedSession(local)
        conflictLocalSnapshots.removeValue(forKey: sessionID)
        conflictCloudSnapshots.removeValue(forKey: sessionID)
    }

    func resolveSessionMergeConflictUsingCloud(sessionID: UUID) {
        let cloud = conflictCloudSnapshots[sessionID] ?? loadRawCloudSessions()?.first(where: { $0.id == sessionID })
        guard let cloud else { return }
        applyResolvedSession(cloud)
        conflictLocalSnapshots.removeValue(forKey: sessionID)
        conflictCloudSnapshots.removeValue(forKey: sessionID)
    }

    private func applyResolvedSession(_ session: DiveSession) {
        let allowEmpty = session.isManual && !session.hasDepthProfile
        guard let storedSession = try? DiveSessionAlgorithmValidator.normalizedForStorage(session, allowEmptySamples: allowEmpty) else {
            return
        }
        sessions.removeAll { $0.id == session.id }
        sessions.insert(storedSession, at: 0)
        sessions = IOSDiveLogbookPolicy.normalizeAndCap(sessions)
        saveIfReady()
        refreshMergeConflicts()
    }

    private func refreshMergeConflicts() {
        updateMergeConflictState(local: loadLocalSessions(), cloud: loadRawCloudSessions() ?? [])
    }

    private func updateMergeConflictState(local: [DiveSession], cloud: [DiveSession]) {
        sessionMergeConflicts = DiveSessionMergeConflictDetector.detect(local: local, cloud: cloud)
        let conflictIDs = Set(sessionMergeConflicts.map(\.sessionID))
        let dedupedLocal = DiveSessionCollectionIntegrity.deduplicated(local)
        let dedupedCloud = DiveSessionCollectionIntegrity.deduplicated(cloud)
        conflictLocalSnapshots = safeDictionary(
            dedupedLocal.sessions.compactMap { session in
                conflictIDs.contains(session.id) ? (session.id, session) : nil
            }
        )
        conflictCloudSnapshots = safeDictionary(
            dedupedCloud.sessions.compactMap { session in
                conflictIDs.contains(session.id) ? (session.id, session) : nil
            }
        )
    }

    private func safeDictionary(_ pairs: [(UUID, DiveSession)]) -> [UUID: DiveSession] {
        var result: [UUID: DiveSession] = [:]
        for (id, session) in pairs {
            result[id] = session
        }
        return result
    }

    private func loadLocalSessions() -> [DiveSession] {
        if let protected = loadProtectedSessions() {
            return protected
        }
        let legacy = loadLegacyLocalSessions()
        if !legacy.isEmpty {
            persistProtectedSessions(legacy)
        }
        return legacy
    }

    private func loadProtectedSessions() -> [DiveSession]? {
        let url = protectedFileURL()
        guard FileManager.default.fileExists(atPath: url.path),
              let data = try? Data(contentsOf: url) else { return nil }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        do {
            return try decoder.decode([DiveSession].self, from: data)
        } catch {
            Self.logger.error("Protected iOS logbook decode failed: \(error.localizedDescription, privacy: .private)")
            return nil
        }
    }

    private func loadLegacyLocalSessions() -> [DiveSession] {
        let data = cloudSync?.loadRawLocalData(forKey: key) ?? UserDefaults.standard.data(forKey: key)
        guard let data else { return [] }
        if let decoded = cloudSync?.decodeLocal([DiveSession].self, from: data) {
            return decoded
        }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return (try? decoder.decode([DiveSession].self, from: data)) ?? []
    }

    private func loadRawCloudSessions() -> [DiveSession]? {
        guard let data = cloudSync?.loadRawCloudData(forKey: key) else { return nil }
        if let decoded = cloudSync?.decodeCloud([DiveSession].self, from: data) {
            return decoded
        }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try? decoder.decode([DiveSession].self, from: data)
    }

    private func mergedSessions(local: [DiveSession], cloud: [DiveSession]?) -> [DiveSession] {
        var byID: [UUID: DiveSession] = [:]
        for session in local {
            byID[session.id] = session
        }
        if let cloud {
            for session in cloud {
                if let existing = byID[session.id] {
                    let hasConflict = sessionMergeConflicts.contains { $0.sessionID == session.id }
                    byID[session.id] = hasConflict ? existing : DiveSessionMerge.preferred(existing, session)
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
        persistProtectedSessions(sessions)
        syncCloudSessionsBackup()
        cloudSync?.save(Array(deletedSessionIDs), forKey: deletedKey)
    }

    /// Merges per session ID before writing iCloud backup so blob LWW cannot drop unrelated dives.
    private func syncCloudSessionsBackup() {
        guard CloudBackupSettings.isEnabled, let cloudSync else { return }
        let cloud = loadRawCloudSessions() ?? []
        updateMergeConflictState(local: sessions, cloud: cloud)
        let merged = mergedSessions(local: sessions, cloud: cloud)
            .filter { !deletedSessionIDs.contains($0.id) }
        cloudSync.save(merged, forKey: key)
    }

    private func persistProtectedSessions(_ sessions: [DiveSession]) {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            let data = try encoder.encode(sessions)
            try data.write(to: protectedFileURL(), options: [.atomic, .completeFileProtection])
        } catch {
            Self.logger.error("Protected iOS logbook save failed: \(error.localizedDescription, privacy: .private)")
        }
    }

    private var preferencesDefaults: UserDefaults {
        Self.testHook_userDefaults ?? .standard
    }

    private func protectedFileURL() -> URL {
        let base = Self.testHook_storageDirectoryURL
            ?? FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return base.appendingPathComponent(protectedFileName)
    }

    private func removeLegacySessionPayload() {
        if let cloudSync {
            cloudSync.removeValue(forKey: key)
        } else {
            UserDefaults.standard.removeObject(forKey: key)
            UserDefaults.standard.removeObject(forKey: "\(key).__modifiedAt")
        }
    }

    private func applyDemoLogbookPreference() {
        if includeDemoLogbook {
            insertMissingDemoDives()
        } else {
            removeDemoDives()
        }
    }

    /// Inserts canonical demo dives locally without Watch sync (`add(_:)` is not used).
    private func insertMissingDemoDives() {
        let existingIDs = Set(sessions.map(\.id))
        let missing = makeDemoDives().filter { !existingIDs.contains($0.id) }
        guard !missing.isEmpty else { return }
        sessions = IOSDiveLogbookPolicy.normalizeAndCap(sessions + missing)
    }

    private func removeDemoDives() {
        sessions.removeAll { $0.isDemoDive }
    }

    private func makeDemoDives() -> [DiveSession] {
        let names = ["Secca di Mezzo", "Punta Margherita", "Relitto dell'Elba", "Scoglio del Corallo", "Grotta Azzurra"]
        let days = [24, 21, 18, 14, 10]
        let times = [(8, 35), (11, 2), (9, 10), (10, 45), (12, 20)]
        let maxDepths = [42.6, 31.2, 52.8, 24.1, 18.3]
        let durations = [62, 54, 74, 47, 41]
        let gases: [DiveGasLabel] = [.trimix, .oc, .trimix, .nitrox, .oc]

        return names.enumerated().map { idx, name in
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
            let summary = DiveProfileMath.summary(
                samples: samples,
                startDate: start,
                endDate: start.addingTimeInterval(duration)
            )
            return DiveSession(
                id: demoID,
                startDate: start,
                endDate: start.addingTimeInterval(duration),
                durationSeconds: duration,
                maxDepthMeters: samples.map(\.depthMeters).max() ?? maxDepth,
                avgDepthMeters: summary.averageDepthMeters,
                avgWaterTemperatureCelsius: 24 - Double(idx),
                ttv: summary.ttv,
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

    func testing_finishInitialLoad(with sessions: [DiveSession]) {
        hasLoadedSessions = true
        self.sessions = IOSDiveLogbookPolicy.normalizeAndCap(sessions)
        if includeDemoLogbook {
            insertMissingDemoDives()
        }
    }

    func testing_reloadFromCloud() {
        reloadFromCloud()
    }
}
