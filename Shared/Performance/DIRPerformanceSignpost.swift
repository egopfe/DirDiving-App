import Foundation
import os

/// Centralized production performance signpost catalog for field diagnostics.
/// Names and metadata must never include GPS coordinates, dive profiles, gases, notes, or user identifiers.
enum DIRPerformanceSignpostCategory: String, CaseIterable, Sendable {
    case watchFullComputerTissueTick = "fc_tissue_tick"
    case watchFullComputerSolverProjection = "fc_solver_projection"
    case watchFullComputerScheduleGeneration = "fc_schedule_generation"
    case watchCheckpointEncodeWrite = "watch_checkpoint_encode_write"
    case watchCheckpointRestore = "watch_checkpoint_restore"
    case gaugeSampleIngestion = "gauge_sample_ingest"
    case apneaSampleProcessing = "apnea_sample_process"
    case apneaCheckpoint = "apnea_checkpoint"
    case snorkelingGPSProcessing = "snorkeling_gps_process"
    case snorkelingRouteCheckpoint = "snorkeling_route_checkpoint"
    case iosPlannerCalculation = "ios_planner_calc"
    case iosCCRPlannerCalculation = "ios_ccr_planner_calc"
    case tissueAnalyticsGeneration = "tissue_analytics_gen"
    case chartSnapshotPreparation = "chart_snapshot_prep"
    case logbookLoad = "logbook_load"
    case logbookMerge = "logbook_merge"
    case csvImport = "csv_import"
    case csvExport = "csv_export"
    case pdfGeneration = "pdf_generation"
    case cloudMerge = "cloud_merge"
    case wcEncodeDecode = "wc_encode_decode"
    case largePayloadTransfer = "large_payload_transfer"
    case briefingCardImport = "briefing_card_import"
    case photoValidationDownsampling = "photo_validation_downsample"
}

enum DIRPerformanceSignpost {
    private static let logger = Logger(subsystem: "com.egopfe.dirdiving", category: "Performance")
    private static let signposter = OSSignposter(logger: logger)

    struct Interval {
        private let name: StaticString
        private let state: OSSignpostIntervalState

        fileprivate init(name: StaticString, state: OSSignpostIntervalState) {
            self.name = name
            self.state = state
        }

        func end() {
            signposter.endInterval(name, state)
        }
    }

    static func begin(_ category: DIRPerformanceSignpostCategory) -> Interval {
        let name = signpostName(for: category)
        let state = signposter.beginInterval(name)
        return Interval(name: name, state: state)
    }

    static func event(_ category: DIRPerformanceSignpostCategory) {
        signposter.emitEvent(signpostName(for: category))
    }

    static var catalogCategoryCount: Int { DIRPerformanceSignpostCategory.allCases.count }

    private static func signpostName(for category: DIRPerformanceSignpostCategory) -> StaticString {
        switch category {
        case .watchFullComputerTissueTick: "fc_tissue_tick"
        case .watchFullComputerSolverProjection: "fc_solver_projection"
        case .watchFullComputerScheduleGeneration: "fc_schedule_generation"
        case .watchCheckpointEncodeWrite: "watch_checkpoint_encode_write"
        case .watchCheckpointRestore: "watch_checkpoint_restore"
        case .gaugeSampleIngestion: "gauge_sample_ingest"
        case .apneaSampleProcessing: "apnea_sample_process"
        case .apneaCheckpoint: "apnea_checkpoint"
        case .snorkelingGPSProcessing: "snorkeling_gps_process"
        case .snorkelingRouteCheckpoint: "snorkeling_route_checkpoint"
        case .iosPlannerCalculation: "ios_planner_calc"
        case .iosCCRPlannerCalculation: "ios_ccr_planner_calc"
        case .tissueAnalyticsGeneration: "tissue_analytics_gen"
        case .chartSnapshotPreparation: "chart_snapshot_prep"
        case .logbookLoad: "logbook_load"
        case .logbookMerge: "logbook_merge"
        case .csvImport: "csv_import"
        case .csvExport: "csv_export"
        case .pdfGeneration: "pdf_generation"
        case .cloudMerge: "cloud_merge"
        case .wcEncodeDecode: "wc_encode_decode"
        case .largePayloadTransfer: "large_payload_transfer"
        case .briefingCardImport: "briefing_card_import"
        case .photoValidationDownsampling: "photo_validation_downsample"
        }
    }
}
