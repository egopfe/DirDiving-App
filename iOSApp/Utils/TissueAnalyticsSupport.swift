import SwiftUI

enum TissueAnalyticsTheme {
    static let screenBackground = Color(red: 0, green: 0, blue: 0)
    static let cardBackground = Color(red: 0.08, green: 0.08, blue: 0.11)
    static let cardBorder = Color(red: 0.16, green: 0.16, blue: 0.18)
    static let tabContainer = Color(red: 0.10, green: 0.10, blue: 0.11)
    static let tabSelectedBackground = Color(red: 0.024, green: 0.129, blue: 0.227)
    static let accentBlue = Color(red: 0.04, green: 0.52, blue: 1.0)
    static let labelSecondary = Color(red: 0.82, green: 0.82, blue: 0.84)
    static let labelMuted = Color(red: 0.56, green: 0.56, blue: 0.58)
    static let grid = Color(red: 0.17, green: 0.17, blue: 0.18)
    static let warningRed = Color(red: 1.0, green: 0.27, blue: 0.23)
    static let green = Color(red: 0.20, green: 0.84, blue: 0.29)
    static let yellow = Color(red: 1.0, green: 0.84, blue: 0.04)
    static let orange = Color(red: 1.0, green: 0.62, blue: 0.04)
    static let orangeRed = Color(red: 1.0, green: 0.37, blue: 0.23)
    static let purple = Color(red: 0.75, green: 0.35, blue: 0.95)
    static let cyan = Color(red: 0.39, green: 0.82, blue: 1.0)
    static let badgeBrown = Color(red: 0.60, green: 0.35, blue: 0.075)

    static func loadingColor(for percent: Double) -> Color {
        if percent > 90 { return orangeRed }
        if percent >= 70 { return yellow }
        return green
    }

    static func runtimeLabel(seconds: Int) -> String {
        let minutes = seconds / 60
        let secs = seconds % 60
        return String(format: "%d:%02d", minutes, secs)
    }

    static func controllingCompartmentLabel(index: Int) -> String {
        "C\(index + 1)"
    }
}

enum NarcosisAnalyticsSupport {
    static func ppN2Bar(depthMeters: Double, gas: BuhlmannGas, environment: PlannerEnvironment) -> Double {
        max(0, gas.inspiredPressure(depthMeters: depthMeters, inert: .nitrogen, environment: environment))
    }

    static func ppO2Bar(depthMeters: Double, gas: BuhlmannGas, environment: PlannerEnvironment) -> Double {
        max(0, gas.ppO2(depthMeters: depthMeters, environment: environment))
    }

    static func endMeters(fromPPN2Bar ppN2: Double, environment: PlannerEnvironment) -> Double {
        guard ppN2.isFinite, ppN2 > 0 else { return 0 }
        let airNarcoticFraction = 0.79
        let equivalentAmbient = ppN2 / max(airNarcoticFraction, 0.01)
        guard let depth = AmbientPressureModel.depthMeters(ambientPressureBar: equivalentAmbient, environment: environment) else {
            return 0
        }
        return max(0, depth)
    }

    static func ceilingMeters(from toleratedAmbientBar: Double, environment: PlannerEnvironment) -> Double {
        guard toleratedAmbientBar.isFinite, toleratedAmbientBar > 0,
              let depth = AmbientPressureModel.depthMeters(ambientPressureBar: toleratedAmbientBar, environment: environment) else {
            return 0
        }
        return max(0, depth)
    }
}
