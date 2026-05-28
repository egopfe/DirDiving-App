import Foundation

struct BuhlmannGas: Hashable {
    let name: String
    let role: GasRole
    let oxygenFraction: Double
    let heliumFraction: Double
    let maxPPO2Bar: Double
    let switchDepthMeters: Double

    var nitrogenFraction: Double {
        1.0 - oxygenFraction - heliumFraction
    }

    var label: String {
        if heliumFraction > 0.000_1 {
            return "TX \(Int((oxygenFraction * 100).rounded()))/\(Int((heliumFraction * 100).rounded()))"
        }
        if oxygenFraction > 0.985 {
            return "O2"
        }
        if oxygenFraction > 0.215 {
            return "EAN\(Int((oxygenFraction * 100).rounded()))"
        }
        return "AIR"
    }

    init(name: String, role: GasRole, oxygenFraction: Double, heliumFraction: Double, maxPPO2Bar: Double, switchDepthMeters: Double) {
        self.name = name
        self.role = role
        self.oxygenFraction = oxygenFraction
        self.heliumFraction = heliumFraction
        self.maxPPO2Bar = maxPPO2Bar
        self.switchDepthMeters = switchDepthMeters
    }

    init(gas: GasMix, role: GasRole? = nil, switchDepthMeters: Double = 0) {
        self.init(
            name: gas.name,
            role: role ?? gas.role,
            oxygenFraction: gas.oxygen,
            heliumFraction: gas.helium,
            maxPPO2Bar: gas.maxPPO2,
            switchDepthMeters: switchDepthMeters
        )
    }

    func inspiredPressure(depthMeters: Double, inert: BuhlmannInertGas, environment: PlannerEnvironment? = nil) -> Double {
        let ambient = environment.flatMap { IOSUnitConversions.ambientPressureBar(depthMeters: depthMeters, environment: $0) }
            ?? IOSUnitConversions.ambientPressureBar(depthMeters: depthMeters)
        let dryPressure = max(0, ambient - BuhlmannConstants.waterVaporPressureBar)
        switch inert {
        case .nitrogen:
            return dryPressure * max(0, nitrogenFraction)
        case .helium:
            return dryPressure * max(0, heliumFraction)
        }
    }

    func ppO2(depthMeters: Double, environment: PlannerEnvironment? = nil) -> Double {
        let ambient = environment.flatMap { IOSUnitConversions.ambientPressureBar(depthMeters: depthMeters, environment: $0) }
            ?? IOSUnitConversions.ambientPressureBar(depthMeters: depthMeters)
        return max(0, oxygenFraction) * ambient
    }

    func isOperational(fromDepthMeters: Double, toDepthMeters: Double, environment: PlannerEnvironment? = nil) -> Bool {
        guard isCompositionValid, fromDepthMeters.isFinite, toDepthMeters.isFinite else { return false }
        let shallow = max(0, min(fromDepthMeters, toDepthMeters))
        let deep = max(fromDepthMeters, toDepthMeters)
        let minPPO2 = ppO2(depthMeters: shallow, environment: environment)
        let maxPPO2 = ppO2(depthMeters: deep, environment: environment)
        return minPPO2 >= BuhlmannConstants.minBreathablePPO2Bar
            && maxPPO2 <= maxPPO2Bar + 0.000_1
    }

    func modMeters() -> Double? {
        GasMixValidator.modMeters(oxygenFraction: oxygenFraction, maxPPO2: maxPPO2Bar)
    }

    func minimumOperatingDepthMeters(minPPO2: Double = BuhlmannConstants.minBreathablePPO2Bar) -> Double {
        guard oxygenFraction.isFinite, oxygenFraction > 0 else { return Double.infinity }
        return IOSUnitConversions.depthMeters(forPressureBar: minPPO2 / oxygenFraction)
    }

    var isCompositionValid: Bool {
        oxygenFraction.isFinite
            && heliumFraction.isFinite
            && maxPPO2Bar.isFinite
            && switchDepthMeters.isFinite
            && oxygenFraction > 0
            && heliumFraction >= 0
            && oxygenFraction + heliumFraction <= 1.0
            && maxPPO2Bar > 0
            && switchDepthMeters >= 0
    }
}

enum BuhlmannInertGas {
    case nitrogen
    case helium
}

enum BuhlmannPlanIssue: Hashable {
    case invalidProfile(String)
    case invalidGas(String)
    case hypoxicGasTooShallow(String)
    case ppo2Exceeded(String)
    case modExceeded(String)
    case gasSwitchTooDeep(String)
    case gasNotOperationalInSegment(String)
    case calculationLimitReached

    var isBlocking: Bool {
        true
    }
}
