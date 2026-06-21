import SwiftUI

struct FullComputerPrediveAltitudeSensorLifecycle: ViewModifier {
    @ObservedObject private var environmentSensor = FullComputerEnvironmentSensorService.shared
    @ObservedObject private var sensorSettings = WatchFullComputerAltitudeSensorProposalSettingsStore.shared
    @ObservedObject private var configuration: FullComputerPrediveConfigurationStore
    @State private var showsAskBeforeSampling = false

    init(configuration: FullComputerPrediveConfigurationStore) {
        self._configuration = ObservedObject(wrappedValue: configuration)
    }

    func body(content: Content) -> some View {
        content
            .onAppear(perform: handleAppear)
            .onDisappear { environmentSensor.cancel() }
            .alert(
                String(localized: "fc.altitude_sensor.ask.title"),
                isPresented: $showsAskBeforeSampling
            ) {
                Button(String(localized: "fc.altitude_sensor.ask.confirm"), role: .none) {
                    environmentSensor.requestProposal(into: configuration)
                }
                Button(String(localized: "fc.altitude_sensor.ask.decline"), role: .cancel) {}
            } message: {
                Text(String(localized: "fc.altitude_sensor.ask.message"))
            }
    }

    private func handleAppear() {
        switch sensorSettings.mode {
        case .manualOnly:
            return
        case .askBeforeSampling:
            showsAskBeforeSampling = true
        case .automatic:
            environmentSensor.requestProposalIfNeeded(into: configuration)
        }
    }
}

extension View {
    func fullComputerPrediveAltitudeSensorLifecycle(
        configuration: FullComputerPrediveConfigurationStore
    ) -> some View {
        modifier(FullComputerPrediveAltitudeSensorLifecycle(configuration: configuration))
    }
}

struct WatchFullComputerAltitudeSensorSettingsSection: View {
    @EnvironmentObject private var dive: DiveManager
    @ObservedObject private var sensorSettings = WatchFullComputerAltitudeSensorProposalSettingsStore.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            WatchSettingsSectionHeader(title: String(localized: "settings.section.full_computer"))

            Text(String(localized: "fc.altitude_sensor.settings.title"))
                .font(DiveUI.Typography.rowTitle)
                .foregroundStyle(.white)
            Text(String(localized: "fc.altitude_sensor.settings.subtitle"))
                .font(DiveUI.Typography.rowSubtitle)
                .foregroundStyle(DiveUI.secondaryText)
                .fixedSize(horizontal: false, vertical: true)

            Picker(String(localized: "fc.altitude_sensor.settings.picker.a11y"), selection: modeBinding) {
                ForEach(FullComputerAltitudeSensorProposalMode.allCases) { mode in
                    Text(String(localized: String.LocalizationValue(mode.localizationKeyTitle)))
                        .tag(mode)
                }
            }
            .pickerStyle(.wheel)
            .tint(DiveUI.cyan)
            .accessibilityLabel(String(localized: "fc.altitude_sensor.settings.picker.a11y"))
            .accessibilityHint(String(localized: String.LocalizationValue(sensorSettings.mode.accessibilityHintKey)))

            Text(String(localized: String.LocalizationValue(sensorSettings.mode.localizationKeySubtitle)))
                .font(DiveUI.Typography.hintCaption)
                .foregroundStyle(DiveUI.mutedText)
                .fixedSize(horizontal: false, vertical: true)

            Text(String(localized: "fc.altitude_sensor.settings.safety_note"))
                .font(DiveUI.Typography.hintCaption)
                .foregroundStyle(DiveUI.orange)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 9)
        .padding(.vertical, 7)
        .background(
            RoundedRectangle(cornerRadius: 7, style: .continuous)
                .fill(Color.black.opacity(0.52))
                .overlay(RoundedRectangle(cornerRadius: 7, style: .continuous).stroke(.white.opacity(0.24), lineWidth: 1))
        )
        .disabled(dive.isDiveActive)
        .accessibilityIdentifier("watch_full_computer_altitude_sensor_settings")
    }

    private var modeBinding: Binding<FullComputerAltitudeSensorProposalMode> {
        Binding(
            get: { sensorSettings.mode },
            set: { sensorSettings.setMode($0) }
        )
    }
}
