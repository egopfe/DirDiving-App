import Foundation

enum CCROxygenExposureUnavailableReason: String, Codable, Hashable, CaseIterable {
    case invalidSegmentDuration
    case emptySegments
    case invalidSetpoint
    case impossibleSetpoint
    case invalidEnvironment
    case invalidInspiredPPO2
    case modelLimit
    case numericalFailure
    case invalidInput
}

enum CCROxygenExposureState: Equatable, Hashable {
    case available(
        cnsPercent: Double,
        otu: Double,
        descentBottomCNSPercent: Double?
    )
    case unavailable(reason: CCROxygenExposureUnavailableReason)

    var isAvailable: Bool {
        if case .available = self { return true }
        return false
    }

    var cnsPercent: Double? {
        if case .available(let cns, _, _) = self { return cns }
        return nil
    }

    var otu: Double? {
        if case .available(_, let otu, _) = self { return otu }
        return nil
    }

    var descentBottomCNSPercent: Double? {
        switch self {
        case .available(_, _, let descentBottom): return descentBottom
        case .unavailable: return nil
        }
    }

    var unavailableReason: CCROxygenExposureUnavailableReason? {
        if case .unavailable(let reason) = self { return reason }
        return nil
    }

    var localizedUnavailableLabel: String {
        guard let reason = unavailableReason else { return "" }
        return DIRIOSLocalizer.string("ccr.exposure.unavailable.\(reason.rawValue)")
    }
}

extension CCROxygenExposureState {
    static func fromExposureResult(
        _ result: Result<OxygenExposureResult, OxygenExposureWarningState>,
        descentBottomResult: Result<OxygenExposureResult, OxygenExposureWarningState>?
    ) -> CCROxygenExposureState {
        switch result {
        case .success(let exposure):
            let descentBottom: Double?
            if let descentBottomResult {
                switch descentBottomResult {
                case .success(let db): descentBottom = db.cnsSinglePercent
                case .failure: descentBottom = nil
                }
            } else {
                descentBottom = nil
            }
            return .available(
                cnsPercent: exposure.cnsSinglePercent,
                otu: exposure.otuDive,
                descentBottomCNSPercent: descentBottom
            )
        case .failure(let warning):
            return .unavailable(reason: mapWarning(warning))
        }
    }

    private static func mapWarning(_ warning: OxygenExposureWarningState) -> CCROxygenExposureUnavailableReason {
        switch warning {
        case .invalidExposureInput:
            return .numericalFailure
        case .elevatedCNS, .elevatedDailyCNS, .elevatedOTU, .elevatedDailyOTU, .elevatedWeeklyOTU:
            return .modelLimit
        }
    }
}
