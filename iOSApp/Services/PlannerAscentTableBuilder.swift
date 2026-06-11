import Foundation

enum PlannerAscentRowKind: String, Hashable, Codable {
    case descent
    case bottom
    case travel
    case decoStop
    case surface
}

extension PlannerAscentRowKind {
    var localizedTitle: String {
        switch self {
        case .descent:
            return DIRIOSLocalizer.string("planner.runtime.row.descent")
        case .bottom:
            return DIRIOSLocalizer.string("planner.runtime.row.bottom")
        case .travel:
            return DIRIOSLocalizer.string("planner.runtime.row.travel")
        case .decoStop:
            return DIRIOSLocalizer.string("planner.runtime.row.deco_stop")
        case .surface:
            return DIRIOSLocalizer.string("planner.runtime.row.surface")
        }
    }
}

struct PlannerAscentTableRow: Identifiable, Hashable {
    let id = UUID()
    let kind: PlannerAscentRowKind
    let depthMeters: Double
    let depthLabel: String
    let minutes: Double
    let timeLabel: String
    let gas: String
    let ppO2: Double
    let ppO2Label: String
}

enum PlannerAscentTableBuilder {
    static func rows(
        from enginePlan: BuhlmannEngineResult,
        decoStops: [DecoStop],
        environment: PlannerEnvironment,
        depthFormatter: (Double) -> String = { Formatters.depth($0, units: .metric).text },
        ppO2Formatter: (Double) -> String = { Formatters.one($0) }
    ) -> [PlannerAscentTableRow] {
        guard !enginePlan.segments.isEmpty else {
            return surfaceRow(depthFormatter: depthFormatter)
        }

        var rows: [PlannerAscentTableRow] = []

        if let descentRow = makeDescentRow(
            from: enginePlan,
            environment: environment,
            depthFormatter: depthFormatter,
            ppO2Formatter: ppO2Formatter
        ) {
            rows.append(descentRow)
        }

        if let bottomRow = makeBottomRow(from: enginePlan, environment: environment, depthFormatter: depthFormatter, ppO2Formatter: ppO2Formatter) {
            rows.append(bottomRow)
        }

        rows.append(contentsOf: ascentBriefingTravelRows(
            from: enginePlan,
            environment: environment,
            depthFormatter: depthFormatter,
            ppO2Formatter: ppO2Formatter
        ))

        for stop in decoStops {
            rows.append(
                PlannerAscentTableRow(
                    kind: .decoStop,
                    depthMeters: stop.depthMeters,
                    depthLabel: depthFormatter(stop.depthMeters),
                    minutes: Double(stop.minutes),
                    timeLabel: "\(stop.minutes) min",
                    gas: stop.gas,
                    ppO2: stop.ppO2,
                    ppO2Label: ppO2Formatter(stop.ppO2)
                )
            )
        }

        rows.append(contentsOf: surfaceRow(depthFormatter: depthFormatter))
        return rows
    }

    private static func makeDescentRow(
        from enginePlan: BuhlmannEngineResult,
        environment: PlannerEnvironment,
        depthFormatter: (Double) -> String,
        ppO2Formatter: (Double) -> String
    ) -> PlannerAscentTableRow? {
        let descentSegments = enginePlan.segments.filter { $0.kind == .descent }
        guard !descentSegments.isEmpty else { return nil }
        let targetDepth = descentSegments.map(\.depthMeters).max() ?? 0
        let descentMinutes = descentSegments.reduce(0) { $0 + $1.minutes }
        let reference = descentSegments.last(where: { abs($0.depthMeters - targetDepth) < 0.05 }) ?? descentSegments.last
        guard let reference else { return nil }
        let ppO2 = reference.gas.ppO2(depthMeters: targetDepth, environment: environment)
        return PlannerAscentTableRow(
            kind: .descent,
            depthMeters: targetDepth,
            depthLabel: depthFormatter(targetDepth),
            minutes: descentMinutes,
            timeLabel: "\(Formatters.one(descentMinutes)) min",
            gas: reference.gas.displayLabel,
            ppO2: ppO2,
            ppO2Label: ppO2Formatter(ppO2)
        )
    }

    private static func makeBottomRow(
        from enginePlan: BuhlmannEngineResult,
        environment: PlannerEnvironment,
        depthFormatter: (Double) -> String,
        ppO2Formatter: (Double) -> String
    ) -> PlannerAscentTableRow? {
        let bottomSegments = enginePlan.segments.filter { $0.kind == .bottom }
        guard !bottomSegments.isEmpty else { return nil }
        let maxDepth = bottomSegments.map(\.depthMeters).max() ?? 0
        let bottomMinutes = bottomSegments
            .filter { abs($0.depthMeters - maxDepth) < 0.05 }
            .reduce(0) { $0 + $1.minutes }
        guard let reference = bottomSegments.first(where: { abs($0.depthMeters - maxDepth) < 0.05 }) else { return nil }
        let ppO2 = reference.gas.ppO2(depthMeters: maxDepth, environment: environment)
        return PlannerAscentTableRow(
            kind: .bottom,
            depthMeters: maxDepth,
            depthLabel: depthFormatter(maxDepth),
            minutes: bottomMinutes,
            timeLabel: "\(Int(bottomMinutes.rounded())) min",
            gas: reference.gas.displayLabel,
            ppO2: ppO2,
            ppO2Label: ppO2Formatter(ppO2)
        )
    }

    /// Post-bottom ascent briefing rows in engine elapsed order (ascent and gas switches only).
    private static func ascentBriefingTravelRows(
        from enginePlan: BuhlmannEngineResult,
        environment: PlannerEnvironment,
        depthFormatter: (Double) -> String,
        ppO2Formatter: (Double) -> String
    ) -> [PlannerAscentTableRow] {
        let postBottomSegments = postBottomSegments(from: enginePlan.segments)
        return postBottomSegments
            .filter { $0.kind == .ascent || $0.kind == .gasSwitch }
            .map { segment in
                let ppO2 = segment.gas.ppO2(depthMeters: segment.depthMeters, environment: environment)
                return PlannerAscentTableRow(
                    kind: .travel,
                    depthMeters: segment.depthMeters,
                    depthLabel: depthFormatter(segment.depthMeters),
                    minutes: segment.minutes,
                    timeLabel: "\(Formatters.one(segment.minutes)) min",
                    gas: segment.gas.displayLabel,
                    ppO2: ppO2,
                    ppO2Label: ppO2Formatter(ppO2)
                )
            }
    }

    private static func postBottomSegments(from segments: [BuhlmannRuntimeSegment]) -> [BuhlmannRuntimeSegment] {
        guard !segments.isEmpty else { return [] }
        if let lastBottomIndex = segments.lastIndex(where: { $0.kind == .bottom }) {
            return Array(segments[(lastBottomIndex + 1)...])
        }
        return segments.filter { $0.kind != .descent && $0.kind != .bottom }
    }

    private static func surfaceRow(depthFormatter: (Double) -> String) -> [PlannerAscentTableRow] {
        [
            PlannerAscentTableRow(
                kind: .surface,
                depthMeters: 0,
                depthLabel: depthFormatter(0),
                minutes: 0,
                timeLabel: "-",
                gas: DIRIOSLocalizer.string("planner.table.surface"),
                ppO2: 0,
                ppO2Label: "-"
            )
        ]
    }
}

enum PlannerDepthProfileBuilder {
    static func points(from segments: [DivePlanSegment]) -> [DepthProfilePoint] {
        guard !segments.isEmpty else { return [] }
        var elapsed = 0.0
        var currentDepth = 0.0
        var points: [DepthProfilePoint] = [DepthProfilePoint(elapsedMinutes: 0, depthMeters: 0)]

        for segment in segments {
            let startDepth = currentDepth
            let endDepth = segment.depthMeters
            points.append(DepthProfilePoint(elapsedMinutes: elapsed, depthMeters: startDepth))
            elapsed += segment.minutes
            points.append(DepthProfilePoint(elapsedMinutes: elapsed, depthMeters: endDepth))
            currentDepth = endDepth
        }

        if points.last?.depthMeters != 0 {
            points.append(DepthProfilePoint(elapsedMinutes: elapsed, depthMeters: 0))
        }
        return points
    }
}

struct DepthProfilePoint: Identifiable, Hashable, Codable {
    var id: String { "\(elapsedMinutes)-\(depthMeters)" }
    let elapsedMinutes: Double
    let depthMeters: Double
}

extension BuhlmannGas {
    var displayLabel: String {
        if heliumFraction > 0.000_1 {
            return "TRIMIX \(Int((oxygenFraction * 100).rounded()))/\(Int((heliumFraction * 100).rounded()))"
        }
        return label
    }
}
