import Foundation

enum TissueAnalyticsSource: String, Codable, Hashable {
    case planned
    case recorded
    case simulated
    case insufficientData

    var localizedTitle: String {
        switch self {
        case .planned:
            return String(localized: "tissue_analytics.source.planned")
        case .recorded:
            return String(localized: "tissue_analytics.source.recorded")
        case .simulated:
            return String(localized: "tissue_analytics.source.simulated")
        case .insufficientData:
            return String(localized: "tissue_analytics.source.insufficient")
        }
    }

    var localizedFootnote: String? {
        switch self {
        case .planned:
            return String(localized: "tissue_analytics.source.planned_footnote")
        case .recorded:
            return String(localized: "tissue_analytics.source.recorded_footnote")
        case .simulated:
            return String(localized: "tissue_analytics.source.simulated_footnote")
        case .insufficientData:
            return String(localized: "tissue_analytics.source.insufficient_footnote")
        }
    }
}

struct TissueAnalyticsSample: Hashable, Identifiable, Codable {
    var id: String { "\(runtimeSeconds)-\(controllingCompartment)" }
    let runtimeSeconds: Int
    let depthMeters: Double
    let activeGasName: String
    let compartmentLoadingsPercent: [Double]
    let controllingCompartment: Int
    let ceilingMeters: Double
    let ppN2Bar: Double
    let ppO2Bar: Double
}

struct TissueCompartmentLoading: Hashable, Identifiable, Codable {
    var id: Int { compartmentIndex }
    let compartmentIndex: Int
    let loadingPercent: Double
    let n2Pressure: Double
    let hePressure: Double
    let totalInertPressure: Double
}

struct TissueAnalyticsSummary: Hashable, Codable {
    let maxDepthMeters: Double
    let bottomTimeMinutes: Int
    let ttsMinutes: Int
    let gfLow: Int
    let gfHigh: Int
    let modeTitle: String
    let totalRuntimeMinutes: Int
}

struct TissueAnalyticsTrace: Hashable, Codable {
    let samples: [TissueAnalyticsSample]
    let finalCompartments: [TissueCompartmentLoading]
    let controllingCompartment: Int
    let maxPPN2Bar: Double
    let endEquivalentMeters: Double
    let source: TissueAnalyticsSource
    let summary: TissueAnalyticsSummary
    let depthProfilePoints: [DepthProfilePoint]
    let segments: [DivePlanSegment]
    let decoStops: [DecoStopSnapshot]

    var isEmpty: Bool { samples.isEmpty }

    struct DecoStopSnapshot: Hashable, Codable, Identifiable {
        var id: String { "\(depthMeters)-\(minutes)" }
        let depthMeters: Double
        let minutes: Int
        let gas: String
    }
}

struct TissueAnalyticsPresentation: Hashable {
    let trace: TissueAnalyticsTrace
    let cacheKey: String
}

enum TissueProfileTab: String, CaseIterable, Identifiable {
    case summary
    case profile
    case tissues
    case gas
    case deco

    var id: String { rawValue }

    var localizedTitle: String {
        switch self {
        case .summary: return String(localized: "tissue_analytics.tab.summary")
        case .profile: return String(localized: "tissue_analytics.tab.profile")
        case .tissues: return String(localized: "tissue_analytics.tab.tissues")
        case .gas: return String(localized: "tissue_analytics.tab.gas")
        case .deco: return String(localized: "tissue_analytics.tab.deco")
        }
    }
}
