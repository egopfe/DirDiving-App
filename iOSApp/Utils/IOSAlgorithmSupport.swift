import Foundation

enum IOSAlgorithmConfiguration {
    static let minimumPlannerDepthMeters = 1.0
    static let maximumPlannerDepthMeters = 100.0
    static let maximumRecommendedDepthMeters = 40.0
    static let maximumBottomTimeMinutes = 240.0
    static let maximumImportRows = 20_000
    static let maximumProfileSamples = 20_000
    static let maximumImportDepthMeters = 200.0
    static let maximumSyncDepthMeters = 350.0
    static let maximumImportDurationSeconds: TimeInterval = 28_800
    static let maximumSyncDurationSeconds: TimeInterval = 86_400
    static let minimumOxygenFraction = 0.10
    static let maximumOxygenFraction = 1.0
    static let minimumPPO2 = 1.0
    static let maximumPPO2 = 1.6
    static let metersPerBar = 10.0
    static let psiPerBar = 14.5038
    static let metersToFeet = 3.280_839_895
    static let metersToKilometers = 0.001
    static let litersToCubicFeet = 0.035_314_7
    static let metersToMiles = 0.000_621_371
    static let gasDensityWarningGramsPerLiter = 6.0
    static let importedGPSUnknownAccuracyMeters = 9_999.0
    static let maxLogSessions = 40
    static let temperatureRangeCelsius = -2.0...40.0
}

enum IOSUnitConversions {
    static func feet(fromMeters meters: Double) -> Double {
        meters * IOSAlgorithmConfiguration.metersToFeet
    }

    static func meters(fromFeet feet: Double) -> Double {
        feet / IOSAlgorithmConfiguration.metersToFeet
    }

    static func kilometers(fromMeters meters: Double) -> Double {
        meters * IOSAlgorithmConfiguration.metersToKilometers
    }

    static func meters(fromKilometers kilometers: Double) -> Double {
        kilometers / IOSAlgorithmConfiguration.metersToKilometers
    }

    static func miles(fromMeters meters: Double) -> Double {
        meters * IOSAlgorithmConfiguration.metersToMiles
    }

    static func meters(fromMiles miles: Double) -> Double {
        miles / IOSAlgorithmConfiguration.metersToMiles
    }

    static func psi(fromBar bar: Double) -> Double {
        bar * IOSAlgorithmConfiguration.psiPerBar
    }

    static func bar(fromPSI psi: Double) -> Double {
        psi / IOSAlgorithmConfiguration.psiPerBar
    }

    static func cubicFeet(fromLiters liters: Double) -> Double {
        liters * IOSAlgorithmConfiguration.litersToCubicFeet
    }

    static func liters(fromCubicFeet cubicFeet: Double) -> Double {
        cubicFeet / IOSAlgorithmConfiguration.litersToCubicFeet
    }

    static func fahrenheit(fromCelsius celsius: Double) -> Double {
        celsius * 9.0 / 5.0 + 32.0
    }

    static func celsius(fromFahrenheit fahrenheit: Double) -> Double {
        (fahrenheit - 32.0) * 5.0 / 9.0
    }

    static func feetPerMinute(fromMetersPerMinute metersPerMinute: Double) -> Double {
        feet(fromMeters: metersPerMinute)
    }

    static func metersPerMinute(fromFeetPerMinute feetPerMinute: Double) -> Double {
        meters(fromFeet: feetPerMinute)
    }

    static func ambientPressureBar(depthMeters: Double) -> Double {
        1.0 + depthMeters / IOSAlgorithmConfiguration.metersPerBar
    }
}

enum PlannerResultState: String, Codable, Hashable, CaseIterable {
    case validReference
    case invalidInput
    case unsupportedDepth
    case unsupportedGas
    case unsupportedTrimix
    case insufficientGas
    case belowReserve
    case MODExceeded
    case PPO2Exceeded
    case modelIncomplete
    case simplifiedReferenceOnly
    case unavailable
    case gasDensityHigh

    var message: String {
        switch self {
        case .validReference:
            return "Riferimento indicativo calcolato da input validati."
        case .invalidInput:
            return "Input non valido: il piano non viene calcolato."
        case .unsupportedDepth:
            return "Profondita non supportata dal planner iOS MAIN."
        case .unsupportedGas:
            return "Miscela non supportata dal planner iOS MAIN."
        case .unsupportedTrimix:
            return "Trimix non elaborato dal modello N2-only semplificato."
        case .insufficientGas:
            return "Gas stimato insufficiente rispetto a SAC, volume e riserva impostati."
        case .belowReserve:
            return "Il consumo stimato scende sotto la riserva impostata."
        case .MODExceeded:
            return "MOD gas fondo inferiore alla profondita pianificata."
        case .PPO2Exceeded:
            return "PPO2 effettiva superiore al limite impostato."
        case .modelIncomplete:
            return "Modello incompleto: output non azionabile per pianificazione reale."
        case .simplifiedReferenceOnly:
            return "Modello semplificato: riferimento di studio, non piano decompressivo certificato."
        case .unavailable:
            return "Planner non disponibile per questa combinazione di input."
        case .gasDensityHigh:
            return "Densita gas stimata elevata: respirabilita non validata per uso tecnico."
        }
    }
}

enum BuhlmannModelState: String, Codable, Hashable {
    case simplifiedReferenceOnly
    case unsupportedTrimix
    case invalidInput
    case unsupportedDepth
    case unavailable

    var isReferenceAvailable: Bool { self == .simplifiedReferenceOnly }
}

struct GasFractions: Hashable {
    let oxygen: Double
    let helium: Double
    let nitrogen: Double
}

struct GasAnalysis: Hashable {
    let ambientPressureBar: Double
    let ppO2: Double
    let ppN2: Double
    let ppHe: Double
    let eadMeters: Double?
    let endMeters: Double?
    let gasDensityGramsPerLiter: Double
}

enum GasMixValidationError: LocalizedError, Hashable {
    case nonFinite
    case oxygenOutOfRange
    case heliumOutOfRange
    case fractionsExceedOne
    case ppo2OutOfRange

    var errorDescription: String? {
        switch self {
        case .nonFinite: return "Miscela non numerica."
        case .oxygenOutOfRange: return "O2 fuori range supportato."
        case .heliumOutOfRange: return "He fuori range supportato."
        case .fractionsExceedOne: return "O2 + He supera 100%."
        case .ppo2OutOfRange: return "PPO2 fuori range supportato."
        }
    }
}

enum GasMixValidator {
    static func validate(_ gas: GasMix) -> Result<GasFractions, GasMixValidationError> {
        guard gas.oxygen.isFinite, gas.helium.isFinite, gas.maxPPO2.isFinite else { return .failure(.nonFinite) }
        guard gas.oxygen > 0, gas.oxygen >= IOSAlgorithmConfiguration.minimumOxygenFraction, gas.oxygen <= IOSAlgorithmConfiguration.maximumOxygenFraction else {
            return .failure(.oxygenOutOfRange)
        }
        guard gas.helium >= 0 else { return .failure(.heliumOutOfRange) }
        guard gas.oxygen + gas.helium <= 1.0 else { return .failure(.fractionsExceedOne) }
        guard gas.maxPPO2 >= IOSAlgorithmConfiguration.minimumPPO2, gas.maxPPO2 <= IOSAlgorithmConfiguration.maximumPPO2 else {
            return .failure(.ppo2OutOfRange)
        }
        return .success(GasFractions(oxygen: gas.oxygen, helium: gas.helium, nitrogen: 1.0 - gas.oxygen - gas.helium))
    }

    static func fractions(for gas: GasMix) -> GasFractions? {
        if case .success(let fractions) = validate(gas) {
            return fractions
        }
        return nil
    }

    static func modMeters(for gas: GasMix) -> Double? {
        guard case .success = validate(gas), gas.oxygen > 0 else { return nil }
        let mod = ((gas.maxPPO2 / gas.oxygen) - 1.0) * IOSAlgorithmConfiguration.metersPerBar
        guard mod.isFinite, mod >= 0 else { return nil }
        return mod
    }

    static func analysis(for gas: GasMix, depthMeters: Double) -> GasAnalysis? {
        guard depthMeters.isFinite, depthMeters >= 0, let fractions = fractions(for: gas) else { return nil }
        let pressure = IOSUnitConversions.ambientPressureBar(depthMeters: depthMeters)
        let ppO2 = fractions.oxygen * pressure
        let ppN2 = fractions.nitrogen * pressure
        let ppHe = fractions.helium * pressure
        let ead = fractions.helium == 0 ? max(0, ((1.0 - gas.oxygen) / 0.79) * (depthMeters + 10.0) - 10.0) : nil
        let end = max(0, ((fractions.oxygen + fractions.nitrogen) * (depthMeters + 10.0)) - 10.0)
        let densityAtSurface = fractions.oxygen * 1.429 + fractions.nitrogen * 1.251 + fractions.helium * 0.1786
        let density = densityAtSurface * pressure
        guard [ppO2, ppN2, ppHe, end, density].allSatisfy(\.isFinite) else { return nil }
        return GasAnalysis(
            ambientPressureBar: pressure,
            ppO2: ppO2,
            ppN2: ppN2,
            ppHe: ppHe,
            eadMeters: ead,
            endMeters: end,
            gasDensityGramsPerLiter: density
        )
    }
}

enum PlannerValidationError: LocalizedError, Hashable {
    case invalidNumber
    case invalidDepth
    case unsupportedDepth
    case invalidBottomTime
    case invalidCylinderVolume
    case invalidPressure
    case invalidReserve
    case invalidSAC
    case invalidGas(String)
    case modExceeded

    var errorDescription: String? {
        switch self {
        case .invalidNumber: return "Input non numerico o non finito."
        case .invalidDepth: return "Profondita non valida."
        case .unsupportedDepth: return "Profondita oltre il range supportato dal planner."
        case .invalidBottomTime: return "Tempo fondo non valido."
        case .invalidCylinderVolume: return "Volume bombola non valido."
        case .invalidPressure: return "Pressioni non valide."
        case .invalidReserve: return "Riserva non valida."
        case .invalidSAC: return "SAC non valido."
        case .invalidGas(let name): return "Miscela non valida: \(name)."
        case .modExceeded: return "MOD gas fondo inferiore alla profondita pianificata."
        }
    }
}

enum PlannerInputValidator {
    static func validate(_ input: GasPlanInput) -> Result<Void, PlannerValidationError> {
        let values = [
            input.cylinderVolumeLiters,
            input.startPressure,
            input.reservePressure,
            input.sacLitersPerMinute,
            input.plannedDepthMeters,
            input.plannedBottomMinutes,
            input.waterTemperatureCelsius
        ]
        guard values.allSatisfy(\.isFinite) else { return .failure(.invalidNumber) }
        guard input.plannedDepthMeters >= IOSAlgorithmConfiguration.minimumPlannerDepthMeters else { return .failure(.invalidDepth) }
        guard input.plannedDepthMeters <= IOSAlgorithmConfiguration.maximumPlannerDepthMeters else { return .failure(.unsupportedDepth) }
        guard input.plannedBottomMinutes > 0, input.plannedBottomMinutes <= IOSAlgorithmConfiguration.maximumBottomTimeMinutes else {
            return .failure(.invalidBottomTime)
        }
        guard input.cylinderVolumeLiters > 0 else { return .failure(.invalidCylinderVolume) }
        guard input.reservePressure >= 0, input.reservePressureBar >= 0 else { return .failure(.invalidReserve) }
        guard input.startPressureBar > input.reservePressureBar else { return .failure(.invalidPressure) }
        guard input.sacLitersPerMinute > 0 else { return .failure(.invalidSAC) }
        for gas in [input.bottomGas, input.decoGas1, input.decoGas2] {
            if case .failure = GasMixValidator.validate(gas) {
                return .failure(.invalidGas(gas.name))
            }
        }
        guard let mod = GasMixValidator.modMeters(for: input.bottomGas), mod >= input.plannedDepthMeters else {
            return .failure(.modExceeded)
        }
        return .success(())
    }

    static func errorMessage(for input: GasPlanInput) -> String? {
        if case .failure(let error) = validate(input) {
            return error.localizedDescription
        }
        return nil
    }
}

struct DiveProfileDerivedMetrics: Hashable {
    let samples: [DiveSample]
    let startDate: Date
    let endDate: Date
    let durationSeconds: TimeInterval
    let maxDepthMeters: Double
    let avgDepthMeters: Double
    let avgWaterTemperatureCelsius: Double?
    let minWaterTemperatureCelsius: Double?
    let maxWaterTemperatureCelsius: Double?
    let ttv: Double
    let exceededSupportedDepthRange: Bool
}

enum DiveProfileMath {
    static func sanitizedDepthMeters(_ value: Double?) -> Double? {
        guard let value, value.isFinite, value >= 0, value <= IOSAlgorithmConfiguration.maximumSyncDepthMeters else { return nil }
        return value
    }

    static func sanitizedTemperatureCelsius(_ value: Double?) -> Double? {
        guard let value else { return nil }
        guard value.isFinite, IOSAlgorithmConfiguration.temperatureRangeCelsius.contains(value) else { return nil }
        return value
    }

    static func sanitizedSamples(_ samples: [DiveSample], maxDepthMeters: Double = IOSAlgorithmConfiguration.maximumSyncDepthMeters) -> [DiveSample] {
        samples
            .compactMap { sample -> DiveSample? in
                guard sample.timestamp.timeIntervalSinceReferenceDate.isFinite,
                      sample.depthMeters.isFinite,
                      sample.depthMeters >= 0,
                      sample.depthMeters <= maxDepthMeters else { return nil }
                return DiveSample(
                    id: sample.id,
                    timestamp: sample.timestamp,
                    depthMeters: sample.depthMeters,
                    temperatureCelsius: sanitizedTemperatureCelsius(sample.temperatureCelsius)
                )
            }
            .sorted { lhs, rhs in
                if lhs.timestamp != rhs.timestamp { return lhs.timestamp < rhs.timestamp }
                return lhs.id.uuidString < rhs.id.uuidString
            }
    }

    static func timeWeightedAverageDepth(samples: [DiveSample], endDate: Date? = nil) -> Double {
        let ordered = sanitizedSamples(samples)
        guard !ordered.isEmpty else { return 0 }
        guard ordered.count > 1 else { return ordered[0].depthMeters }
        var weighted = 0.0
        var total: TimeInterval = 0
        for index in ordered.indices.dropLast() {
            let current = ordered[index]
            let next = ordered[index + 1]
            let interval = max(0, next.timestamp.timeIntervalSince(current.timestamp))
            weighted += current.depthMeters * interval
            total += interval
        }
        if let endDate {
            let last = ordered[ordered.count - 1]
            let interval = max(0, endDate.timeIntervalSince(last.timestamp))
            weighted += last.depthMeters * interval
            total += interval
        }
        if total > 0 {
            return weighted / total
        }
        return ordered.map(\.depthMeters).reduce(0, +) / Double(ordered.count)
    }

    static func ttvIndex(averageDepthMeters: Double, durationSeconds: TimeInterval) -> Double {
        let average = averageDepthMeters.isFinite ? max(0, averageDepthMeters) : 0
        let duration = durationSeconds.isFinite ? max(0, durationSeconds) : 0
        return average + duration / 60.0
    }

    static func derivedMetrics(samples: [DiveSample], fallbackStart: Date, fallbackEnd: Date) -> DiveProfileDerivedMetrics {
        let ordered = sanitizedSamples(samples)
        let start = ordered.first?.timestamp ?? fallbackStart
        let sampleEnd = ordered.last?.timestamp ?? fallbackEnd
        let end = max(max(sampleEnd, fallbackEnd), start)
        let duration = max(0, end.timeIntervalSince(start))
        let depths = ordered.map(\.depthMeters)
        let temps = ordered.compactMap(\.temperatureCelsius)
        let average = timeWeightedAverageDepth(samples: ordered, endDate: end)
        let maxDepth = depths.max() ?? 0
        return DiveProfileDerivedMetrics(
            samples: ordered,
            startDate: start,
            endDate: end,
            durationSeconds: duration,
            maxDepthMeters: maxDepth,
            avgDepthMeters: average,
            avgWaterTemperatureCelsius: temps.isEmpty ? nil : temps.reduce(0, +) / Double(temps.count),
            minWaterTemperatureCelsius: temps.min(),
            maxWaterTemperatureCelsius: temps.max(),
            ttv: ttvIndex(averageDepthMeters: average, durationSeconds: duration),
            exceededSupportedDepthRange: maxDepth > IOSAlgorithmConfiguration.maximumRecommendedDepthMeters
        )
    }

    static func isStrictlyMonotonic(_ samples: [DiveSample]) -> Bool {
        guard samples.count > 1 else { return true }
        for index in samples.indices.dropFirst() where samples[index].timestamp <= samples[samples.index(before: index)].timestamp {
            return false
        }
        return true
    }

    static func trimToLogLimit(_ sessions: [DiveSession]) -> [DiveSession] {
        Array(sessions.sorted { $0.startDate > $1.startDate }.prefix(IOSAlgorithmConfiguration.maxLogSessions))
    }
}

enum DiveSessionAlgorithmValidationError: Error, Equatable {
    case invalidSession
}

enum DiveSessionAlgorithmValidator {
    static func normalized(_ session: DiveSession) throws -> DiveSession {
        guard session.startDate.timeIntervalSinceReferenceDate.isFinite,
              session.endDate.timeIntervalSinceReferenceDate.isFinite,
              session.endDate >= session.startDate,
              session.durationSeconds.isFinite,
              session.durationSeconds >= 0,
              session.durationSeconds <= IOSAlgorithmConfiguration.maximumSyncDurationSeconds,
              session.samples.count <= IOSAlgorithmConfiguration.maximumProfileSamples,
              validGPS(session.entryGPS),
              validGPS(session.exitGPS),
              session.maxDepthMeters.isFinite,
              session.avgDepthMeters.isFinite,
              session.ttv.isFinite else {
            throw DiveSessionAlgorithmValidationError.invalidSession
        }

        for sample in session.samples {
            guard sample.timestamp >= session.startDate,
                  sample.timestamp <= session.endDate,
                  DiveProfileMath.sanitizedDepthMeters(sample.depthMeters) != nil,
                  sample.temperatureCelsius == nil || DiveProfileMath.sanitizedTemperatureCelsius(sample.temperatureCelsius) != nil else {
                throw DiveSessionAlgorithmValidationError.invalidSession
            }
        }

        guard DiveProfileMath.isStrictlyMonotonic(session.samples) else {
            throw DiveSessionAlgorithmValidationError.invalidSession
        }

        let metrics = DiveProfileMath.derivedMetrics(samples: session.samples, fallbackStart: session.startDate, fallbackEnd: session.endDate)
        guard abs(metrics.durationSeconds - session.durationSeconds) <= 1.0,
              abs(metrics.maxDepthMeters - session.maxDepthMeters) <= 0.1,
              abs(metrics.avgDepthMeters - session.avgDepthMeters) <= 0.5,
              abs(metrics.ttv - session.ttv) <= 0.6 else {
            throw DiveSessionAlgorithmValidationError.invalidSession
        }
        return session.replacingDerivedValues(with: metrics)
    }

    static func validate(_ session: DiveSession) throws {
        _ = try normalized(session)
    }

    static func validGPS(_ point: GPSPoint?) -> Bool {
        guard let point else { return true }
        return point.latitude.isFinite
            && point.longitude.isFinite
            && point.horizontalAccuracy.isFinite
            && point.horizontalAccuracy >= 0
            && (-90...90).contains(point.latitude)
            && (-180...180).contains(point.longitude)
    }
}
