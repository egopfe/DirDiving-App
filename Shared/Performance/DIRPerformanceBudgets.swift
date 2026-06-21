import Foundation

/// Canonical software performance budget registry — single source for tests and documentation exports.
enum DIRPerformanceBudgets {
    private static let watchDecoSolverHardLimitSeconds = 0.05
    private static let watchCheckpointRoundTripHardLimitSeconds = 0.05
    private static let activeDiveDraftPersistenceIntervalSeconds = 8.0
    enum Platform: String, Sendable {
        case watch
        case ios
    }

    enum TestEnvironment: String, Sendable {
        case simulator
        case physicalDevice = "physical_device"
    }

    enum MeasurementUnit: String, Sendable {
        case seconds
        case milliseconds
        case count
        case policy
    }

    enum Operation: String, CaseIterable, Sendable {
        case watchFullComputerTissueUpdate = "watch_fc_tissue_update"
        case watchFullComputerCompleteSolver = "watch_fc_complete_solver"
        case watchFullComputerCeilingCalculation = "watch_fc_ceiling_calc"
        case watchFullComputerNDLProjection = "watch_fc_ndl_projection"
        case watchFullComputerTTSSchedule = "watch_fc_tts_schedule"
        case watchCheckpointEncode = "watch_checkpoint_encode"
        case watchCheckpointWrite = "watch_checkpoint_write"
        case watchCheckpointRestore = "watch_checkpoint_restore"
        case gaugeSampleIngestion = "gauge_sample_ingest"
        case apneaSampleProcessing = "apnea_sample_process"
        case snorkelingGPSUpdate = "snorkeling_gps_update"
        case iosPlannerOCCalculation = "ios_planner_oc_calc"
        case iosPlannerCCRCalculation = "ios_planner_ccr_calc"
        case tissueAnalyticsGeneration = "tissue_analytics_gen"
        case logbookLoad = "logbook_load"
        case logbookMerge = "logbook_merge"
        case csvImport = "csv_import"
        case csvExport = "csv_export"
        case pdfStructureGeneration = "pdf_structure_gen"
        case cloudMerge = "cloud_merge"
        case wcEncodeDecode = "wc_encode_decode"
        case largePayloadHashValidation = "large_payload_hash_validation"
        case photoValidationDownsampling = "photo_validation_downsample"
    }

    struct Entry: Sendable {
        let operation: Operation
        let platform: Platform
        let testEnvironment: TestEnvironment
        let unit: MeasurementUnit
        let softTarget: Double
        let hardTestLimit: Double
        let reason: String
        let physicalValidationRequired: Bool
    }

    static let registry: [Entry] = [
        Entry(
            operation: .watchFullComputerCompleteSolver,
            platform: .watch,
            testEnvironment: .simulator,
            unit: .seconds,
            softTarget: 0.03,
            hardTestLimit: watchDecoSolverHardLimitSeconds,
            reason: "Full Computer deco solver per solve on simulator",
            physicalValidationRequired: true
        ),
        Entry(
            operation: .watchCheckpointRestore,
            platform: .watch,
            testEnvironment: .simulator,
            unit: .seconds,
            softTarget: 0.03,
            hardTestLimit: watchCheckpointRoundTripHardLimitSeconds,
            reason: "Checkpoint encode+decode+restore round trip",
            physicalValidationRequired: true
        ),
        Entry(
            operation: .watchFullComputerTissueUpdate,
            platform: .watch,
            testEnvironment: .simulator,
            unit: .seconds,
            softTarget: 0.05,
            hardTestLimit: 1.0,
            reason: "Nominal 1 Hz tissue tick including solver refresh",
            physicalValidationRequired: true
        ),
        Entry(
            operation: .iosPlannerOCCalculation,
            platform: .ios,
            testEnvironment: .simulator,
            unit: .milliseconds,
            softTarget: 200,
            hardTestLimit: 5_000,
            reason: "Debounced OC planner recompute",
            physicalValidationRequired: false
        ),
        Entry(
            operation: .iosPlannerCCRCalculation,
            platform: .ios,
            testEnvironment: .simulator,
            unit: .milliseconds,
            softTarget: 250,
            hardTestLimit: 6_000,
            reason: "Debounced CCR planner recompute",
            physicalValidationRequired: false
        ),
        Entry(
            operation: .logbookMerge,
            platform: .ios,
            testEnvironment: .simulator,
            unit: .milliseconds,
            softTarget: 500,
            hardTestLimit: 5_000,
            reason: "120 samples × 20 merge regression guard",
            physicalValidationRequired: true
        ),
        Entry(
            operation: .logbookLoad,
            platform: .ios,
            testEnvironment: .simulator,
            unit: .milliseconds,
            softTarget: 250,
            hardTestLimit: 15_000,
            reason: "Synthetic logbook decode at 5,000 sessions",
            physicalValidationRequired: true
        ),
        Entry(
            operation: .csvImport,
            platform: .ios,
            testEnvironment: .simulator,
            unit: .seconds,
            softTarget: 0.5,
            hardTestLimit: 30,
            reason: "Bounded CSV import up to 10 MB cap",
            physicalValidationRequired: false
        ),
        Entry(
            operation: .csvExport,
            platform: .ios,
            testEnvironment: .simulator,
            unit: .seconds,
            softTarget: 1.0,
            hardTestLimit: 60,
            reason: "5,000 session CSV export",
            physicalValidationRequired: true
        ),
        Entry(
            operation: .cloudMerge,
            platform: .ios,
            testEnvironment: .simulator,
            unit: .milliseconds,
            softTarget: 100,
            hardTestLimit: 2_000,
            reason: "50 KVS keys linear merge evaluation",
            physicalValidationRequired: true
        ),
        Entry(
            operation: .wcEncodeDecode,
            platform: .watch,
            testEnvironment: .simulator,
            unit: .milliseconds,
            softTarget: 50,
            hardTestLimit: 1_000,
            reason: "Signed sync envelope encode/decode",
            physicalValidationRequired: true
        ),
        Entry(
            operation: .largePayloadHashValidation,
            platform: .ios,
            testEnvironment: .simulator,
            unit: .milliseconds,
            softTarget: 200,
            hardTestLimit: 5_000,
            reason: "Maximum supported large payload hash validation off main path",
            physicalValidationRequired: true
        ),
        Entry(
            operation: .photoValidationDownsampling,
            platform: .watch,
            testEnvironment: .simulator,
            unit: .milliseconds,
            softTarget: 100,
            hardTestLimit: 2_000,
            reason: "Companion photo magic-byte validation and downsample",
            physicalValidationRequired: true
        ),
        Entry(
            operation: .snorkelingGPSUpdate,
            platform: .watch,
            testEnvironment: .simulator,
            unit: .policy,
            softTarget: 1,
            hardTestLimit: 1,
            reason: "GPS owned only by active Snorkeling/Diving lifecycle",
            physicalValidationRequired: true
        ),
        Entry(
            operation: .gaugeSampleIngestion,
            platform: .watch,
            testEnvironment: .simulator,
            unit: .seconds,
            softTarget: 0.01,
            hardTestLimit: 0.05,
            reason: "Gauge depth sample ingestion path",
            physicalValidationRequired: true
        ),
        Entry(
            operation: .apneaSampleProcessing,
            platform: .watch,
            testEnvironment: .simulator,
            unit: .seconds,
            softTarget: 0.01,
            hardTestLimit: 0.05,
            reason: "Apnea sample processing tick path",
            physicalValidationRequired: true
        ),
        Entry(
            operation: .pdfStructureGeneration,
            platform: .ios,
            testEnvironment: .simulator,
            unit: .seconds,
            softTarget: 2.0,
            hardTestLimit: 30,
            reason: "PDF structure generation for large profile export",
            physicalValidationRequired: true
        ),
        Entry(
            operation: .watchFullComputerCeilingCalculation,
            platform: .watch,
            testEnvironment: .simulator,
            unit: .seconds,
            softTarget: 0.03,
            hardTestLimit: watchDecoSolverHardLimitSeconds,
            reason: "Ceiling projection within deco solver budget",
            physicalValidationRequired: true
        ),
        Entry(
            operation: .watchFullComputerNDLProjection,
            platform: .watch,
            testEnvironment: .simulator,
            unit: .seconds,
            softTarget: 0.03,
            hardTestLimit: watchDecoSolverHardLimitSeconds,
            reason: "NDL projection within deco solver budget",
            physicalValidationRequired: true
        ),
        Entry(
            operation: .watchFullComputerTTSSchedule,
            platform: .watch,
            testEnvironment: .simulator,
            unit: .seconds,
            softTarget: 0.04,
            hardTestLimit: watchDecoSolverHardLimitSeconds,
            reason: "TTS/schedule generation within deco solver budget",
            physicalValidationRequired: true
        ),
        Entry(
            operation: .watchCheckpointEncode,
            platform: .watch,
            testEnvironment: .simulator,
            unit: .seconds,
            softTarget: 0.02,
            hardTestLimit: watchCheckpointRoundTripHardLimitSeconds,
            reason: "Checkpoint encode only",
            physicalValidationRequired: true
        ),
        Entry(
            operation: .watchCheckpointWrite,
            platform: .watch,
            testEnvironment: .simulator,
            unit: .policy,
            softTarget: activeDiveDraftPersistenceIntervalSeconds,
            hardTestLimit: activeDiveDraftPersistenceIntervalSeconds,
            reason: "Active dive draft persistence interval seconds minimum",
            physicalValidationRequired: false
        ),
        Entry(
            operation: .tissueAnalyticsGeneration,
            platform: .ios,
            testEnvironment: .simulator,
            unit: .milliseconds,
            softTarget: 300,
            hardTestLimit: 5_000,
            reason: "Tissue narcosis analytics chart preparation",
            physicalValidationRequired: true
        )
    ]

    static func entry(for operation: Operation) -> Entry? {
        registry.first { $0.operation == operation }
    }

    static var registryCoversAllOperations: Bool {
        Set(registry.map(\.operation)) == Set(Operation.allCases)
    }
}
