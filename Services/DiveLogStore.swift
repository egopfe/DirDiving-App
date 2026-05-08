import Foundation

@MainActor
final class DiveLogStore: ObservableObject {
    @Published private(set) var sessions: [DiveSession] = []
    private let fileName = "dirdiving_sessions.json"
    private let maxSessions = 40

    init() { load() }

    func add(_ session: DiveSession) {
        sessions.insert(session, at: 0)
        sessions = Array(sessions.sorted { $0.startDate > $1.startDate }.prefix(maxSessions))
        save()
    }

    func delete(at offsets: IndexSet) {
        sessions.remove(atOffsets: offsets)
        save()
    }

    private func load() {
        let url = fileURL()
        guard FileManager.default.fileExists(atPath: url.path) else { return }
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            sessions = try decoder.decode([DiveSession].self, from: Data(contentsOf: url)).sorted { $0.startDate > $1.startDate }
        } catch { sessions = [] }
    }

    private func save() {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            try encoder.encode(sessions).write(to: fileURL(), options: .atomic)
        } catch { print("Save error: \(error.localizedDescription)") }
    }

    private func fileURL() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(fileName)
    }
}
