import Foundation
import Combine

@MainActor
final class DiveLogStore: ObservableObject {
    @Published private(set) var sessions: [DiveSession] = []
    init() { insertDemoDives() }
    func delete(at offsets: IndexSet) {
        for index in offsets.sorted(by: >) {
            sessions.remove(at: index)
        }
    }
    private func insertDemoDives() {
        let names = ["Secca di Mezzo", "Punta Margherita", "Relitto dell’Elba", "Scoglio del Corallo", "Grotta Azzurra"]
        let maxDepths = [42.6, 31.2, 52.8, 24.1, 18.3]
        let gases: [DiveGasLabel] = [.trimix, .oc, .trimix, .nitrox, .oc]
        sessions = names.enumerated().map { idx, name in
            let start = Calendar.current.date(byAdding: .day, value: -idx*3, to: Date())!
            let duration = Double([62,54,74,47,41][idx]) * 60
            let maxD = maxDepths[idx]
            let samples = (0...Int(duration/60)).map { minute -> DiveSample in
                let m = Double(minute)
                let descent = min(maxD, m * (maxD/10.0))
                let profile = m < 10 ? descent : (m < duration/60 - 14 ? maxD - sin(m/5)*2 : max(0, maxD - (m-(duration/60-14))*(maxD/14)))
                return DiveSample(timestamp: start.addingTimeInterval(m*60), depthMeters: max(0, profile), temperatureCelsius: 24 - Double(idx))
            }
            let avg = samples.map(\.depthMeters).reduce(0,+)/Double(samples.count)
            return DiveSession(id: UUID(), startDate: start, endDate: start.addingTimeInterval(duration), durationSeconds: duration, maxDepthMeters: samples.map(\.depthMeters).max() ?? maxD, avgDepthMeters: avg, avgWaterTemperatureCelsius: 24 - Double(idx), ttv: avg + duration/60, entryGPS: GPSPoint(latitude: 38.1157 + Double(idx)*0.001, longitude: 13.3615, horizontalAccuracy: 15, timestamp: start), exitGPS: GPSPoint(latitude: 38.1162 + Double(idx)*0.001, longitude: 13.3620, horizontalAccuracy: 18, timestamp: start.addingTimeInterval(duration)), samples: samples, siteName: name, buddy: idx == 0 ? "Buddy" : nil, notes: "Demo dive", gasLabel: gases[idx], sacLitersMinute: 18.2 + Double(idx))
        }
    }
}
