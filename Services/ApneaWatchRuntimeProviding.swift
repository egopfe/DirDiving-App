import Foundation

@MainActor
protocol ApneaWatchRuntimeProviding: AnyObject {
    var presentationInput: ApneaWatchPresentationInput { get }
    var lifecyclePhase: ApneaLifecyclePhase { get }
    var currentDepthMeters: Double? { get }
    var operationalOverlay: ApneaOperationalOverlay? { get }
    var isSensorDegraded: Bool { get }
    var isSessionActive: Bool { get }
    var showSessionSummary: Bool { get set }

    func armSession(at wallClock: Date)
    func startManualFallback()
    func triggerManualDescent()
    func triggerManualSurface()
    func requestSessionSummary()
    func endSession()
    func dismissOperationalOverlay(eventID: UUID)
    func saveCompletedSession(to logbook: ApneaLogbookStore)
    func resetAfterSave()
    func ingestDepthForTesting(depthMeters: Double, temperatureCelsius: Double?, at wallClock: Date)
    func tickForTesting(at wallClock: Date)
}

@MainActor
extension ApneaWatchRuntimeProviding {
    func armSession() {
        armSession(at: Date())
    }
}
