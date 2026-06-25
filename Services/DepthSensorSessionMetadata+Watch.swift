import Foundation

extension DepthSensorSessionMetadata {
    @MainActor
    static func capture(from selection: DepthSensorProviderSelection) -> DepthSensorSessionMetadata {
        DepthSensorSessionMetadata(
            depthSampleSource: selection.sampleSource.rawValue,
            depthCapabilityMode: selection.capability.rawValue
        )
    }

    @MainActor
    static func captureCurrentRuntime() -> DepthSensorSessionMetadata {
        capture(from: SensorProviderFactory.makeSelection(mode: SensorSourceMode.runtimeMode))
    }
}
