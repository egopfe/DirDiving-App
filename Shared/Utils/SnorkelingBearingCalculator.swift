import Foundation

enum SnorkelingBearingCalculator {
    static func bearingDegrees(
        from origin: SnorkelingCoordinate,
        to destination: SnorkelingCoordinate
    ) -> Double {
        SnorkelingDomainSupport.bearingDegrees(
            from: (origin.latitude, origin.longitude),
            to: (destination.latitude, destination.longitude)
        ) ?? 0
    }
}
