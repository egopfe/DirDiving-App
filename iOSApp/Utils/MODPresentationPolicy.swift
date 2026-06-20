import Foundation

/// Canonical MOD values shared by live validation, PDF export, and briefing presentation.
enum MODPresentationPolicy {
    /// Canonical MOD in meters used for safety classification (not display rounding).
    static func canonicalMODMeters(
        for entry: PlannerCylinderEntry,
        mode: PlannerMode,
        environment: PlannerEnvironment
    ) -> Double {
        switch mode {
        case .base where entry.role == .bottom:
            return PlannerModePolicy.baseDerivedMODMeters(for: entry.gas, environment: environment)
        default:
            return PlannerMODValidator.modMeters(for: entry.gas, environment: environment)
        }
    }

    static func canonicalMODMeters(
        for gas: GasMix,
        role: GasRole,
        mode: PlannerMode,
        environment: PlannerEnvironment
    ) -> Double {
        switch mode {
        case .base where role == .bottom:
            return PlannerModePolicy.baseDerivedMODMeters(for: gas, environment: environment)
        default:
            return PlannerMODValidator.modMeters(for: gas, environment: environment)
        }
    }

    /// Display MOD uses the same canonical value; Formatters.depth applies presentation rounding only.
    static func displayMOD(
        for entry: PlannerCylinderEntry,
        mode: PlannerMode,
        environment: PlannerEnvironment,
        units: IOSUnitPreference
    ) -> DisplayMeasurement {
        let meters = canonicalMODMeters(for: entry, mode: mode, environment: environment)
        return Formatters.depth(meters, units: units)
    }

    /// Returns true when switch/bottom depth exceeds canonical MOD by validator tolerance.
    static func exceedsCanonicalMOD(
        depthMeters: Double,
        gas: GasMix,
        role: GasRole,
        mode: PlannerMode,
        environment: PlannerEnvironment
    ) -> Bool {
        let mod = canonicalMODMeters(for: gas, role: role, mode: mode, environment: environment)
        return depthMeters > mod + 0.05
    }
}
