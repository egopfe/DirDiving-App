import Foundation

struct BuhlmannRuntimeProjection: Hashable {
    let ndlMinutes: Double?
    let rawCeiling: BuhlmannCeiling
    let operationalCeiling: BuhlmannCeiling
    let ttsMinutes: Int
    let stops: [BuhlmannDecompressionStop]
    let issues: [BuhlmannPlanIssue]
    let modelState: BuhlmannModelState

    var rawCeilingMeters: Double { rawCeiling.depthMeters }
    var operationalCeilingMeters: Double { operationalCeiling.depthMeters }
}
