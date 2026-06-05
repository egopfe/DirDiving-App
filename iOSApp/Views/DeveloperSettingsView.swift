import SwiftUI

struct DeveloperSettingsView: View {
    @AppStorage(SensorSourceMode.storageKey) private var sensorSourceRaw = SensorSourceMode.automatic.rawValue
    @State private var showAppleFallbackAlert = false

    private var sensorSource: SensorSourceMode {
        get { SensorSourceMode(rawValue: sensorSourceRaw) ?? .automatic }
        nonmutating set { sensorSourceRaw = newValue.rawValue }
    }

    var body: some View {
        DIRScreenContainer {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 7) {
                        Text(String(localized: "developer.section.title"))
                            .dirScreenTitleStyle()
                        Text(String(localized: "developer.section.subtitle"))
                            .font(.callout)
                            .foregroundStyle(DIRTheme.muted)
                    }

                    DIRCard(String(localized: "developer.sensor_source.title"), icon: "waveform.path", accent: DIRTheme.yellow) {
                        ForEach(SensorSourceMode.selectableModes) { mode in
                            sensorSourceRow(mode)
                        }
                        Text(String(localized: "developer.sensor_source.footer"))
                            .font(.caption2)
                            .foregroundStyle(DIRTheme.muted)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.top, 4)
                    }
                }
                .padding(16)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .alert(String(localized: "developer.sensor_source.title"), isPresented: $showAppleFallbackAlert) {
            Button(String(localized: "OK"), role: .cancel) {}
        } message: {
            Text(String(localized: "developer.sensor_source.apple_fallback"))
        }
    }

    private func sensorSourceRow(_ mode: SensorSourceMode) -> some View {
        Button {
            applySensorSource(mode)
        } label: {
            HStack {
                Image(systemName: sensorSource == mode ? "largecircle.fill.circle" : "circle")
                    .foregroundStyle(sensorSource == mode ? DIRTheme.cyan : DIRTheme.muted)
                Text(mode.displayName)
                    .foregroundStyle(.white)
                    .font(.callout.weight(.semibold))
                Spacer()
            }
            .padding(.vertical, 6)
        }
        .buttonStyle(.plain)
    }

    private func applySensorSource(_ mode: SensorSourceMode) {
        if mode == .appleSensor, !AppleDepthSensorAvailability.isAvailable {
            showAppleFallbackAlert = true
            let fallback: SensorSourceMode = DeveloperSettings.allowsSimulationSensorSelection ? .simulation : .automatic
            sensorSourceRaw = fallback.rawValue
            DeveloperSettings.persistSensorSource(fallback)
            return
        }
        sensorSourceRaw = mode.rawValue
        DeveloperSettings.persistSensorSource(mode)
    }
}

private extension SensorSourceMode {
    var displayName: String {
        switch self {
        case .automatic:
            return String(localized: "developer.sensor_source.automatic")
        case .appleSensor:
            return String(localized: "developer.sensor_source.apple_sensor")
        case .simulation:
            return String(localized: "developer.sensor_source.simulation")
        }
    }
}
