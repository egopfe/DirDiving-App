import Foundation

enum OxygenExposureWarningState: Hashable {
    case elevatedCNS(Double)
    case elevatedOTU(Double)
    case invalidExposureInput
}

enum CNSClockModel {
    static func cnsIncrement(ppO2: Double, minutes: Double) -> Double? {
        guard ppO2.isFinite, minutes.isFinite, minutes >= 0 else { return nil }
        guard ppO2 > 0.5 else { return 0 }
        let limitMinutes: Double
        switch ppO2 {
        case ..<1.0: limitMinutes = 720
        case ..<1.2: limitMinutes = 210
        case ..<1.4: limitMinutes = 150
        case ..<1.6: limitMinutes = 45
        default: limitMinutes = 10
        }
        let value = (minutes / limitMinutes) * 100
        return value.isFinite ? value : nil
    }
}

enum OTUModel {
    static func otuIncrement(ppO2: Double, minutes: Double) -> Double? {
        guard ppO2.isFinite, minutes.isFinite, minutes >= 0 else { return nil }
        guard ppO2 > 0.5 else { return 0 }
        let value = minutes * pow((0.5 / (ppO2 - 0.5)), -0.833)
        return value.isFinite ? value : nil
    }
}

struct OxygenExposureModel: Hashable {
    let cnsPercent: Double
    let otu: Double
    let warningStates: [OxygenExposureWarningState]

    static func from(segments: [BuhlmannRuntimeSegment], environment: PlannerEnvironment) -> Result<OxygenExposureModel, OxygenExposureWarningState> {
        var cns = 0.0
        var otu = 0.0
        for segment in segments {
            guard let ambient = AmbientPressureModel.ambientPressureBar(depthMeters: segment.depthMeters, environment: environment) else {
                return .failure(.invalidExposureInput)
            }
            let ppo2 = max(0, segment.gas.oxygenFraction) * ambient
            guard let cnsIncrement = CNSClockModel.cnsIncrement(ppO2: ppo2, minutes: segment.minutes),
                  let otuIncrement = OTUModel.otuIncrement(ppO2: ppo2, minutes: segment.minutes) else {
                return .failure(.invalidExposureInput)
            }
            cns += cnsIncrement
            otu += otuIncrement
        }

        guard cns.isFinite, otu.isFinite else { return .failure(.invalidExposureInput) }
        var warnings: [OxygenExposureWarningState] = []
        if cns >= 80 { warnings.append(.elevatedCNS(cns)) }
        if otu >= 300 { warnings.append(.elevatedOTU(otu)) }

        return .success(.init(cnsPercent: min(300, cns), otu: otu, warningStates: warnings))
    }
}
