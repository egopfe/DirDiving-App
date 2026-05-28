import Foundation

enum BuhlmannTestSupport {
    static func air(role: GasRole = .bottom, switchDepth: Double = 0) -> BuhlmannGas {
        BuhlmannGas(
            name: "Air",
            role: role,
            oxygenFraction: 0.21,
            heliumFraction: 0,
            maxPPO2Bar: 1.4,
            switchDepthMeters: switchDepth
        )
    }

    static func nitrox32(role: GasRole = .bottom, switchDepth: Double = 0) -> BuhlmannGas {
        BuhlmannGas(
            name: "EAN32",
            role: role,
            oxygenFraction: 0.32,
            heliumFraction: 0,
            maxPPO2Bar: role == .bottom ? 1.4 : 1.6,
            switchDepthMeters: switchDepth
        )
    }

    static func trimix1845(role: GasRole = .bottom, switchDepth: Double = 0) -> BuhlmannGas {
        BuhlmannGas(
            name: "TX 18/45",
            role: role,
            oxygenFraction: 0.18,
            heliumFraction: 0.45,
            maxPPO2Bar: 1.4,
            switchDepthMeters: switchDepth
        )
    }

    static func ean50(switchDepth: Double = 21) -> BuhlmannGas {
        BuhlmannGas(
            name: "EAN50",
            role: .deco,
            oxygenFraction: 0.50,
            heliumFraction: 0,
            maxPPO2Bar: 1.6,
            switchDepthMeters: switchDepth
        )
    }

    static func oxygen(switchDepth: Double = 6) -> BuhlmannGas {
        BuhlmannGas(
            name: "O2",
            role: .deco,
            oxygenFraction: 1.0,
            heliumFraction: 0,
            maxPPO2Bar: 1.6,
            switchDepthMeters: switchDepth
        )
    }

    static func request(
        depth: Double = 30,
        bottomMinutes: Double = 20,
        bottomGas: BuhlmannGas? = nil,
        travelGases: [BuhlmannGas] = [],
        decoGases: [BuhlmannGas] = [],
        gfLow: Double = 30,
        gfHigh: Double = 70
    ) -> BuhlmannPlanRequest {
        BuhlmannPlanRequest(
            maxDepthMeters: depth,
            bottomMinutes: bottomMinutes,
            bottomGas: bottomGas ?? air(switchDepth: depth),
            travelGases: travelGases,
            decoGases: decoGases,
            gfLow: gfLow,
            gfHigh: gfHigh
        )
    }

    static func gasPlanInput(
        depth: Double = 50,
        bottomMinutes: Double = 30,
        bottomGas: GasMix = GasMix(name: "TX 18/45", role: .bottom, oxygen: 0.18, helium: 0.45, maxPPO2: 1.4)
    ) -> GasPlanInput {
        var input = GasPlanInput()
        input.plannedDepthMeters = depth
        input.plannedAverageDepthMeters = min(depth, max(1, depth * 0.6))
        input.plannedBottomMinutes = bottomMinutes
        input.bottomGas = bottomGas
        input.cylinder = Cylinder(volumeLiters: 12, startPressure: 230, reservePressure: 50, pressureUnit: .bar)
        input.plannerCylinders = [
            PlannerCylinderEntry(
                role: .bottom,
                tankSize: .liters12,
                gas: bottomGas,
                startPressure: 230,
                reservePressure: 50,
                pressureUnit: .bar
            ),
            PlannerCylinderEntry(
                role: .deco,
                tankSize: .liters12,
                gas: GasMix(name: "EAN50", role: .deco, oxygen: 0.50, helium: 0, maxPPO2: 1.6),
                switchDepthMeters: 21
            ),
            PlannerCylinderEntry(
                role: .deco,
                tankSize: .liters12,
                gas: GasMix(name: "O2", role: .deco, oxygen: 1.0, helium: 0, maxPPO2: 1.6),
                switchDepthMeters: 6
            )
        ]
        input.sacLitersPerMinute = 18
        input.emergencySacLitersPerMinute = 30
        input.gfLow = 30
        input.gfHigh = 70
        return input
    }
}

