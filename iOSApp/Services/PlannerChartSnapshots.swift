import Foundation

struct PlannerNDLChartPoint: Identifiable, Hashable, Equatable {
    var id: String { "\(depthMeters)-\(depthBand)" }
    let depthMeters: Double
    let ndlMinutes: Double
    let depthBand: String

    init(from point: NDLPoint) {
        depthMeters = point.depthMeters
        ndlMinutes = point.ndlMinutes
        depthBand = point.depthBand
    }
}

/// Immutable chart presentation snapshots derived from planner results.
/// Charts rebuild only when mathematical inputs or generation token change.
struct PlannerChartSnapshots: Equatable {
    let planningGeneration: UInt
    let tissueGroupedPoints: [BuhlmannTissueGroupPoint]
    let depthProfilePoints: [DepthProfilePoint]
    let ndlCurve: [PlannerNDLChartPoint]
    let tissueHistoryEmpty: Bool

    static let empty = PlannerChartSnapshots(
        planningGeneration: 0,
        tissueGroupedPoints: [],
        depthProfilePoints: [],
        ndlCurve: [],
        tissueHistoryEmpty: true
    )

    static func make(
        from plan: DivePlanResult,
        buhlmann: BuhlmannPlanResult,
        generation: UInt,
        maxTissuePoints: Int = PresentationSeriesDownsampler.defaultMaxPresentationPoints,
        maxDepthPoints: Int = PresentationSeriesDownsampler.defaultMaxPresentationPoints
    ) -> PlannerChartSnapshots {
        let interval = DIRPerformanceSignpost.begin(.chartSnapshotPreparation)
        defer { interval.end() }

        let tissuePoints = plan.tissueHistory.groupedPoints
        let downsampledTissue: [BuhlmannTissueGroupPoint]
        if tissuePoints.count > maxTissuePoints {
            downsampledTissue = PresentationSeriesDownsampler.downsampleUniform(tissuePoints, maxPoints: maxTissuePoints)
        } else {
            downsampledTissue = tissuePoints
        }

        let depthPoints = plan.depthProfilePoints
        let downsampledDepth: [DepthProfilePoint]
        if depthPoints.count > maxDepthPoints {
            downsampledDepth = PresentationSeriesDownsampler.downsampleUniform(depthPoints, maxPoints: maxDepthPoints)
        } else {
            downsampledDepth = depthPoints
        }

        let ndlPoints = buhlmann.curve.map(PlannerNDLChartPoint.init(from:))
        let downsampledNDL: [PlannerNDLChartPoint]
        if ndlPoints.count > maxDepthPoints {
            downsampledNDL = PresentationSeriesDownsampler.downsampleUniform(ndlPoints, maxPoints: maxDepthPoints)
        } else {
            downsampledNDL = ndlPoints
        }

        return PlannerChartSnapshots(
            planningGeneration: generation,
            tissueGroupedPoints: downsampledTissue,
            depthProfilePoints: downsampledDepth,
            ndlCurve: downsampledNDL,
            tissueHistoryEmpty: plan.tissueHistory.isEmpty
        )
    }

#if DEBUG
    static var testHook_invalidationCount = 0

    static func resetTestHook() {
        testHook_invalidationCount = 0
    }
#endif
}
