import Foundation

/// Pure decision helper for depth sample ingestion (Watch MAIN). Keeps auto-start from double `addSample`.
enum DiveDepthMeasurementIngestion {
    /// After handling a pre-dive branch, skip a second `addSample` when the start sample was already stored.
    static func shouldInvokeAddSampleAfterPreDiveBranch(sampleAddedInPreDiveBranch: Bool) -> Bool {
        !sampleAddedInPreDiveBranch
    }
}
