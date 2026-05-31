import Foundation

struct GPSPoint: Codable, Hashable {
    let latitude: Double
    let longitude: Double
    let horizontalAccuracy: Double
    let timestamp: Date

    var coordinateText: String {
        String(format: "%.6f, %.6f", latitude, longitude)
    }
}
