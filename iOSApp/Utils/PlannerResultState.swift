import Foundation

enum PlannerResultState: String, Codable, Hashable, CaseIterable {
    case validReference
    case invalidInput
    case unsupportedDepth
    case unsupportedGas
    case unsupportedTrimix
    case modelIncomplete
    case simplifiedReferenceOnly
    case nonCertifiedReference
    case unavailable
    case insufficientGas
    case belowReserve
    case MODExceeded
    case PPO2Exceeded
    case gasDensityWarning
    case gasDensityDanger
    case invalidEnvironment
    case gasAllocationIncomplete
    case oxygenExposureElevated

    var warningText: String? {
        switch self {
        case .validReference:
            return nil
        case .invalidInput:
            return "Input non valido: il piano non viene calcolato."
        case .unsupportedDepth:
            return "Profondita fuori dal range supportato per il riferimento planner."
        case .unsupportedGas:
            return "Miscela non valida o non supportata."
        case .unsupportedTrimix:
            return "Trimix: modello decompressivo completo non disponibile, risultato non operativo."
        case .modelIncomplete:
            return "Modello semplificato: usare solo come riferimento non certificato."
        case .simplifiedReferenceOnly:
            return "Output reference-only: non e un piano decompressivo certificato."
        case .nonCertifiedReference:
            return "Buhlmann ZHL-16C reference-only: non e un piano decompressivo certificato."
        case .unavailable:
            return "Calcolo non disponibile con gli input correnti."
        case .insufficientGas:
            return "Gas insufficiente per il profilo pianificato."
        case .belowReserve:
            return "Il gas residuo scende sotto la riserva impostata."
        case .MODExceeded:
            return "MOD superata per una o piu miscele."
        case .PPO2Exceeded:
            return "PPO2 effettiva oltre il limite impostato."
        case .gasDensityWarning:
            return "Densita gas elevata: verificare respirabilita con strumenti certificati."
        case .gasDensityDanger:
            return "Densita gas critica: profilo non consigliato."
        case .invalidEnvironment:
            return "Ambiente (altitudine/salinita) non valido: calcolo bloccato."
        case .gasAllocationIncomplete:
            return "Allocazione gas/cilindri incompleta: risultato non valido."
        case .oxygenExposureElevated:
            return "Esposizione ossigeno elevata (CNS/OTU): riferimento non certificato."
        }
    }
}

enum BuhlmannModelState: String, Codable, Hashable {
    case validReference
    case simplifiedReferenceOnly
    case unsupportedTrimix
    case modelIncomplete
    case unavailable
    case invalidInput
}

struct PlannerValidationResult: Hashable {
    var states: [PlannerResultState] = []
    var messages: [String] = []

    var isValid: Bool {
        !states.contains(.invalidInput)
            && !states.contains(.unsupportedDepth)
            && !states.contains(.unsupportedGas)
            && !states.contains(.unavailable)
            && !states.contains(.invalidEnvironment)
    }

    mutating func add(_ state: PlannerResultState, message: String? = nil) {
        if !states.contains(state) {
            states.append(state)
        }
        if let message, !messages.contains(message) {
            messages.append(message)
        } else if let warning = state.warningText, !messages.contains(warning) {
            messages.append(warning)
        }
    }

    mutating func merge(_ other: PlannerValidationResult) {
        other.states.forEach { add($0) }
        other.messages.forEach { message in
            if !messages.contains(message) {
                messages.append(message)
            }
        }
    }
}
