import Foundation
import Combine

@MainActor
final class DiveLogStore: ObservableObject {
    @Published private(set) var sessions: [DiveSession] = [] {
        didSet { saveIfReady() }
    }

    private let cloudSync: CloudSyncStore?
    private let key = "dirdiving_ios_dive_sessions"
    private var isReady = false

    init(cloudSync: CloudSyncStore? = nil) {
        self.cloudSync = cloudSync
        if let saved = cloudSync?.load([DiveSession].self, forKey: key) {
            sessions = saved.sorted { $0.startDate > $1.startDate }
        } else {
            insertDemoDives()
        }
        isReady = true
        saveIfReady()
    }

    func add(_ session: DiveSession) {
        sessions.removeAll { $0.id == session.id }
        sessions.insert(session, at: 0)
        sessions = sessions.sorted { $0.startDate > $1.startDate }
    }

    func delete(at offsets: IndexSet) {
        for index in offsets.sorted(by: >) {
            sessions.remove(at: index)
        }
    }

    func synchronizeCloud() {
        saveIfReady()
        cloudSync?.synchronize()
    }

    private func saveIfReady() {
        guard isReady else { return }
        cloudSync?.save(sessions, forKey: key)
    }

    private func insertDemoDives() {
        let names = ["Secca di Mezzo", "Punta Margherita", "Relitto dell'Elba", "Scoglio del Corallo", "Grotta Azzurra"]
        let days = [24, 21, 18, 14, 10]
        let times = [(8, 35), (11, 2), (9, 10), (10, 45), (12, 20)]
        let maxDepths = [42.6, 31.2, 52.8, 24.1, 18.3]
        let durations = [62, 54, 74, 47, 41]
        let gases: [DiveGasLabel] = [.trimix, .oc, .trimix, .nitrox, .oc]

        sessions = names.enumerated().map { idx, name in
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
                id: UUID(),
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
                notes: "Demo dive",
                gasLabel: gases[idx],
                sacLitersMinute: 18.2 + Double(idx)
            )
        }
    }
}
