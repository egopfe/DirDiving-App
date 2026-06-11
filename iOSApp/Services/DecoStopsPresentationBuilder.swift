import Foundation

struct DecoStopPresentationRow: Identifiable, Hashable {
    let id: String
    let index: Int
    let depthMeters: Double
    let depthLabel: String
    let minutes: Int
    let timeLabel: String
    let gasLabel: String
    let ppO2: Double
    let ppO2Label: String
    let hasPPO2Warning: Bool
}

enum DecoStopsPresentationBuilder {
    static func shouldShowSection(mode: PlannerMode, decoStops: [DecoStop]) -> Bool {
        guard !decoStops.isEmpty else { return false }
        switch mode {
        case .deco, .technical, .ccr:
            return true
        case .base:
            return false
        }
    }

    static func shouldShowNoStopsNote(mode: PlannerMode, decoStops: [DecoStop]) -> Bool {
        mode == .deco && decoStops.isEmpty
    }

    static func rows(
        from decoStops: [DecoStop],
        depthFormatter: (Double) -> String = { Formatters.depth($0, units: .metric).text },
        ppO2Formatter: (Double) -> String = { Formatters.one($0) }
    ) -> [DecoStopPresentationRow] {
        decoStops.enumerated().map { offset, stop in
            DecoStopPresentationRow(
                id: "\(offset)-\(stop.depthMeters)-\(stop.minutes)",
                index: offset + 1,
                depthMeters: stop.depthMeters,
                depthLabel: depthFormatter(stop.depthMeters),
                minutes: stop.minutes,
                timeLabel: "\(stop.minutes) min",
                gasLabel: stop.gas,
                ppO2: stop.ppO2,
                ppO2Label: ppO2Formatter(stop.ppO2),
                hasPPO2Warning: stop.states.contains(.PPO2Exceeded)
            )
        }
    }
}
