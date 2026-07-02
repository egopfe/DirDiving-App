import Foundation

enum ExperimentalSyncKind: String, Codable {
    case watchPOI = "watch.poi.v1"
    case watchApneaRecord = "watch.apnea.record.v1"
    case companionRouteManifest = "companion.route.manifest.v1"
    case companionSettings = "companion.settings.v1"
}

struct ExperimentalSyncEnvelope: Codable {
    var schemaVersion: Int = 1
    var id: UUID = UUID()
    var kind: ExperimentalSyncKind
    var createdAt: Date = Date()
    var payload: [String: String]

    func userInfo() throws -> [String: Any] {
        let data = try JSONEncoder().encode(self)
        guard let object = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw ExperimentalSyncContractError.invalidEnvelope
        }
        return ["dirdivingExperimentalSync": object]
    }
}

enum ExperimentalSyncContractError: Error {
    case invalidEnvelope
}
