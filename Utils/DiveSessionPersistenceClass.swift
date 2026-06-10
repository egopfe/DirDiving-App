import Foundation

enum DiveSessionPersistenceClass: Equatable {
    case profileExportable
    case manualNoDepth
    case invalid(reason: String)

    static func classify(_ session: DiveSession) -> DiveSessionPersistenceClass {
        do {
            try DiveSessionAlgorithmValidator.validate(session)
        } catch {
            return .invalid(reason: String(localized: "dive.session.invalid.incoherent_data"))
        }

        if session.hasDepthProfile {
            return .profileExportable
        }
        if session.isManual {
            return .manualNoDepth
        }
        return .invalid(reason: String(localized: "dive.session.unclassified_no_profile"))
    }

    var allowsSync: Bool {
        switch self {
        case .profileExportable, .manualNoDepth:
            return true
        case .invalid:
            return false
        }
    }

    var allowsExport: Bool {
        switch self {
        case .profileExportable:
            return true
        case .manualNoDepth, .invalid:
            return false
        }
    }
}
