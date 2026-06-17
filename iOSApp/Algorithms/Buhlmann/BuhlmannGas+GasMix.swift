import Foundation

extension BuhlmannGas {
    init(gas: GasMix, role: GasRole? = nil, switchDepthMeters: Double = 0, cylinderId: UUID? = nil) {
        self.init(
            name: gas.name,
            role: role ?? gas.role,
            oxygenFraction: gas.oxygen,
            heliumFraction: gas.helium,
            maxPPO2Bar: gas.maxPPO2,
            switchDepthMeters: switchDepthMeters,
            gasMixId: gas.id,
            cylinderId: cylinderId
        )
    }
}
