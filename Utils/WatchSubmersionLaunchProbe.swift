import CoreMotion
import Foundation

/// One-shot submersion probe used only at cold launch to detect watchOS submerged auto-open.
@MainActor
enum WatchSubmersionLaunchProbe {
    #if DEBUG
    static var testHook_submergedAtLaunch: Bool?
    static var testHook_skipHardwareProbe = false
    #endif

    static func isSubmergedAtLaunch(timeoutNanoseconds: UInt64 = 400_000_000) async -> Bool {
        #if DEBUG
        if let testHook_submergedAtLaunch {
            return testHook_submergedAtLaunch
        }
        if testHook_skipHardwareProbe {
            return false
        }
        #endif

        guard WatchAutomaticDepthLaunchConfiguration.isEnabled else { return false }
        guard CMWaterSubmersionManager.waterSubmersionAvailable else { return false }

        return await withTaskGroup(of: Bool.self) { group in
            group.addTask { await probeSubmersionState() }
            group.addTask {
                try? await Task.sleep(nanoseconds: timeoutNanoseconds)
                return false
            }
            let result = await group.next() ?? false
            group.cancelAll()
            return result
        }
    }

    private static func probeSubmersionState() async -> Bool {
        await withCheckedContinuation { continuation in
            let probe = SubmersionProbe(continuation: continuation)
            probe.start()
        }
    }
}

@MainActor
private final class SubmersionProbe: NSObject, CMWaterSubmersionManagerDelegate {
    private var manager: CMWaterSubmersionManager?
    private var continuation: CheckedContinuation<Bool, Never>?
    private var didResume = false

    init(continuation: CheckedContinuation<Bool, Never>) {
        self.continuation = continuation
    }

    func start() {
        let manager = CMWaterSubmersionManager()
        manager.delegate = self
        self.manager = manager
    }

    func manager(_ manager: CMWaterSubmersionManager, didUpdate event: CMWaterSubmersionEvent) {
        resumeOnce(event.state == .submerged)
    }

    func manager(_ manager: CMWaterSubmersionManager, didUpdate measurement: CMWaterSubmersionMeasurement) {
        // Measurement updates are not needed for launch routing.
    }

    func manager(_ manager: CMWaterSubmersionManager, didUpdate measurement: CMWaterTemperature) {
        // Temperature updates are not needed for launch routing.
    }

    func manager(_ manager: CMWaterSubmersionManager, errorOccurred error: Error) {
        resumeOnce(false)
    }

    private func resumeOnce(_ submerged: Bool) {
        guard !didResume else { return }
        didResume = true
        manager?.delegate = nil
        manager = nil
        continuation?.resume(returning: submerged)
        continuation = nil
    }
}
