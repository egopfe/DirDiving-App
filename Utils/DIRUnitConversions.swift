import Foundation

enum DIRUnitConversions {
    static let feetPerMeter = 3.280839895
    static let psiPerBar = 14.5037738

    static func metersToFeet(_ meters: Double) -> Double {
        meters * feetPerMeter
    }

    static func feetToMeters(_ feet: Double) -> Double {
        feet / feetPerMeter
    }

    static func celsiusToFahrenheit(_ celsius: Double) -> Double {
        celsius * 9.0 / 5.0 + 32.0
    }

    static func fahrenheitToCelsius(_ fahrenheit: Double) -> Double {
        (fahrenheit - 32.0) * 5.0 / 9.0
    }

    static func barToPSI(_ bar: Double) -> Double {
        bar * psiPerBar
    }

    static func psiToBar(_ psi: Double) -> Double {
        psi / psiPerBar
    }

    static func metersPerMinuteToFeetPerMinute(_ metersPerMinute: Double) -> Double {
        metersToFeet(metersPerMinute)
    }

    static func feetPerMinuteToMetersPerMinute(_ feetPerMinute: Double) -> Double {
        feetToMeters(feetPerMinute)
    }
}

