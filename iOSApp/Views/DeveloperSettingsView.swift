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
                        Text(DIRIOSLocalizer.string("developer.section.title"))
                            .dirScreenTitleStyle()
                        Text(DIRIOSLocalizer.string("developer.section.subtitle"))
                            .font(.callout)
                            .foregroundStyle(DIRTheme.muted)
                    }

                    DIRCard(DIRIOSLocalizer.string("developer.sensor_source.title"), icon: "waveform.path", accent: DIRTheme.yellow) {
                        ForEach(SensorSourceMode.selectableModes) { mode in
                            sensorSourceRow(mode)
                        }
                        Text(DIRIOSLocalizer.string("developer.sensor_source.footer"))
                            .font(.caption2)
                            .foregroundStyle(DIRTheme.muted)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.top, 4)
                    }
                }
                .padding(16)
            }
            .dirCompanionScrollSurface()
        }
        .toolbar(.hidden, for: .navigationBar)
        .alert(DIRIOSLocalizer.string("developer.sensor_source.title"), isPresented: $showAppleFallbackAlert) {
            Button(DIRIOSLocalizer.string("common.ok"), role: .cancel) {}
        } message: {
            Text(DIRIOSLocalizer.string("developer.sensor_source.apple_fallback"))
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
            return DIRIOSLocalizer.string("developer.sensor_source.automatic")
        case .appleSensor:
            return DIRIOSLocalizer.string("developer.sensor_source.apple_sensor")
        case .simulation:
            return DIRIOSLocalizer.string("developer.sensor_source.simulation")
        }
    }
}
