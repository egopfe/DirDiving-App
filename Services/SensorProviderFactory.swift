import Foundation

struct DepthSensorProviderSelection {
    let provider: DepthSensorProvider
    let requestedMode: SensorSourceMode
    let effectiveMode: SensorSourceMode
    let capability: DepthCapabilityMode
    let resolution: DepthSensorSourceResolution
    let sampleSource: DepthSampleSource
    let unavailableReason: DepthSensorUnavailableReason?
    let didFallbackFromApple: Bool
}

enum SensorProviderFactory {
    @MainActor
    static func makeSelection(
        mode requested: SensorSourceMode,
        resolver: DepthCapabilityResolver = .shared
    ) -> DepthSensorProviderSelection {
        let capability = resolver.resolve(selectedMode: requested)
        switch requested {
        case .automatic:
            return automaticSelection(capability: capability, requested: requested)
        case .appleSensor:
            return explicitAppleSelection(
                requested: requested.explicitAppleRequest(resolver: resolver),
                originalRequest: requested,
                capability: capability
            )
        case .appleShallow:
            return explicitAppleSelection(requested: .appleShallow, originalRequest: requested, capability: capability)
        case .appleFull:
            return explicitAppleSelection(requested: .appleFull, originalRequest: requested, capability: capability)
        case .simulation:
            return simulationSelection(requested: requested, capability: capability)
        }
    }

    @MainActor
    static func makeProvider(mode: SensorSourceMode) -> DepthSensorProvider {
        makeSelection(mode: mode).provider
    }

    @MainActor
    static func resolvedMode(requested: SensorSourceMode) -> (mode: SensorSourceMode, didFallbackFromApple: Bool) {
        let selection = makeSelection(mode: requested)
        return (selection.effectiveMode, selection.didFallbackFromApple)
    }

    @MainActor
    private static func automaticSelection(
        capability: DepthCapabilityMode,
        requested: SensorSourceMode
    ) -> DepthSensorProviderSelection {
        switch capability {
        case .appleFull:
            return appleProviderSelection(
                operatingMode: .full,
                requested: requested,
                effectiveMode: .automatic,
                capability: .appleFull,
                resolution: .appleFull,
                didFallback: false
            )
        case .appleShallow:
            return appleProviderSelection(
                operatingMode: .shallow,
                requested: requested,
                effectiveMode: .automatic,
                capability: .appleShallow,
                resolution: .appleShallow,
                didFallback: false
            )
        case .simulation where DeveloperSettings.allowsSimulationSensorSelection:
            return mockSelection(requested: requested, effectiveMode: .simulation, capability: .simulation, didFallback: true)
        default:
            return unavailableSelection(
                requested: requested,
                effectiveMode: .automatic,
                capability: capability,
                reason: .capabilityNone,
                didFallback: true
            )
        }
    }

    @MainActor
    private static func explicitAppleSelection(
        requested: SensorSourceMode,
        originalRequest: SensorSourceMode,
        capability: DepthCapabilityMode
    ) -> DepthSensorProviderSelection {
        switch requested {
        case .appleFull:
            guard capability == .appleFull else {
                return unavailableSelection(
                    requested: originalRequest,
                    effectiveMode: requested,
                    capability: capability,
                    reason: .fullEntitlementMissing,
                    didFallback: true
                )
            }
            return appleProviderSelection(
                operatingMode: .full,
                requested: originalRequest,
                effectiveMode: .appleFull,
                capability: .appleFull,
                resolution: .appleFull,
                didFallback: false
            )
        case .appleShallow:
            guard capability == .appleShallow || capability == .appleFull else {
                return unavailableSelection(
                    requested: originalRequest,
                    effectiveMode: requested,
                    capability: capability,
                    reason: .shallowEntitlementMissing,
                    didFallback: true
                )
            }
            let operatingMode: AppleDepthSensorProvider.OperatingMode = capability == .appleFull ? .full : .shallow
            let resolution: DepthSensorSourceResolution = operatingMode == .full ? .appleFull : .appleShallow
            return appleProviderSelection(
                operatingMode: operatingMode,
                requested: originalRequest,
                effectiveMode: .appleShallow,
                capability: capability == .appleFull ? .appleFull : .appleShallow,
                resolution: resolution,
                didFallback: capability == .appleFull && requested == .appleShallow
            )
        default:
            return unavailableSelection(
                requested: originalRequest,
                effectiveMode: requested,
                capability: capability,
                reason: .appleSensorUnavailable,
                didFallback: true
            )
        }
    }

    @MainActor
    private static func simulationSelection(
        requested: SensorSourceMode,
        capability: DepthCapabilityMode
    ) -> DepthSensorProviderSelection {
        guard DeveloperSettings.allowsSimulationSensorSelection else {
            return unavailableSelection(
                requested: requested,
                effectiveMode: .simulation,
                capability: capability,
                reason: .simulationDisabledInRelease,
                didFallback: false
            )
        }
        return mockSelection(requested: requested, effectiveMode: .simulation, capability: .simulation, didFallback: false)
    }

    @MainActor
    private static func appleProviderSelection(
        operatingMode: AppleDepthSensorProvider.OperatingMode,
        requested: SensorSourceMode,
        effectiveMode: SensorSourceMode,
        capability: DepthCapabilityMode,
        resolution: DepthSensorSourceResolution,
        didFallback: Bool
    ) -> DepthSensorProviderSelection {
        guard AppleDepthSensorProvider.isAvailable else {
            return unavailableSelection(
                requested: requested,
                effectiveMode: effectiveMode,
                capability: capability,
                reason: .appleSensorUnavailable,
                didFallback: didFallback
            )
        }
        return DepthSensorProviderSelection(
            provider: AppleDepthSensorProvider(operatingMode: operatingMode),
            requestedMode: requested,
            effectiveMode: effectiveMode,
            capability: capability,
            resolution: resolution,
            sampleSource: resolution.sampleSource,
            unavailableReason: nil,
            didFallbackFromApple: didFallback
        )
    }

    @MainActor
    private static func mockSelection(
        requested: SensorSourceMode,
        effectiveMode: SensorSourceMode,
        capability: DepthCapabilityMode,
        didFallback: Bool
    ) -> DepthSensorProviderSelection {
        DepthSensorProviderSelection(
            provider: MockDepthSensorProvider(),
            requestedMode: requested,
            effectiveMode: effectiveMode,
            capability: .simulation,
            resolution: .simulation,
            sampleSource: .simulation,
            unavailableReason: nil,
            didFallbackFromApple: didFallback
        )
    }

    @MainActor
    private static func unavailableSelection(
        requested: SensorSourceMode,
        effectiveMode: SensorSourceMode,
        capability: DepthCapabilityMode,
        reason: DepthSensorUnavailableReason,
        didFallback: Bool
    ) -> DepthSensorProviderSelection {
        DepthSensorProviderSelection(
            provider: UnavailableDepthSensorProvider(reason: reason),
            requestedMode: requested,
            effectiveMode: effectiveMode,
            capability: capability,
            resolution: .unavailable,
            sampleSource: .unavailable,
            unavailableReason: reason,
            didFallbackFromApple: didFallback
        )
    }
}
