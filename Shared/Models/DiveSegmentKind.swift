import Foundation

enum DiveSegmentKind: String, CaseIterable, Identifiable, Codable {
    case descent = "Discesa"
    case bottom = "Fondo"
    case ascent = "Risalita"
    case stop = "Sosta"
    case gasSwitch = "Gas switch"

    var id: String { rawValue }
}
