import Foundation

enum SensorProviderFactory {
  @MainActor
  static func makeProvider(mode: SensorSourceMode) -> DepthSensorProvider {
    switch mode {
    case .automatic:
      if AppleDepthSensorProvider.isAvailable {
        return AppleDepthSensorProvider()
      }
      return MockDepthSensorProvider()
    case .appleSensor:
      if AppleDepthSensorProvider.isAvailable {
        return AppleDepthSensorProvider()
      }
      return MockDepthSensorProvider()
    case .simulation:
      return MockDepthSensorProvider()
    }
  }

  @MainActor
  static func resolvedMode(requested: SensorSourceMode) -> (mode: SensorSourceMode, didFallbackFromApple: Bool) {
    switch requested {
    case .automatic, .appleSensor:
      if AppleDepthSensorProvider.isAvailable {
        return (requested, false)
      }
      return (.simulation, true)
    case .simulation:
      return (.simulation, false)
    }
  }
}
