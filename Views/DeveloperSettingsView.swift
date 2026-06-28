import SwiftUI

struct DeveloperSettingsView: View {
    @EnvironmentObject private var dive: DiveManager
    @AppStorage(SensorSourceMode.storageKey) private var sensorSourceRaw = SensorSourceMode.automatic.rawValue
    @State private var showAppleFallbackAlert = false

    private var sensorSource: SensorSourceMode {
        get { SensorSourceMode(rawValue: sensorSourceRaw) ?? .automatic }
        nonmutating set { sensorSourceRaw = newValue.rawValue }
    }

    var body: some View {
        ZStack {
            DiveScreenBackground()

            ScrollView {
                VStack(spacing: 7) {
                    HStack {
                        WatchDetailBackButton()
                        Spacer()
                    }

                    Text(String(localized: "developer.section.title"))
                        .font(DiveUI.Typography.settingsSection)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)

                    VStack(alignment: .leading, spacing: 6) {
                        Text(String(localized: "developer.sensor_source.title"))
                            .font(.system(size: 11, weight: .semibold, design: .rounded))
                            .foregroundStyle(.white)

                        ForEach(SensorSourceMode.selectableModes) { mode in
                            sensorSourceRow(mode)
                        }

                        Text(String(localized: "developer.sensor_source.footer"))
                            .font(DiveUI.Typography.hintCaption)
                            .foregroundStyle(DiveUI.secondaryText)
                            .fixedSize(horizontal: false, vertical: true)

                        Text(depthCapabilityStatusLine)
                            .font(DiveUI.Typography.hintCaption)
                            .foregroundStyle(DiveUI.cyan)
                            .fixedSize(horizontal: false, vertical: true)
                            .accessibilityLabel(depthCapabilityStatusLine)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 7, style: .continuous)
                            .fill(Color.black.opacity(0.52))
                            .overlay(
                                RoundedRectangle(cornerRadius: 7, style: .continuous)
                                    .stroke(.white.opacity(0.24), lineWidth: 1)
                            )
                    )

                    VStack(alignment: .leading, spacing: 6) {
                        Toggle(isOn: shallowGaugeTestingBinding) {
                            Text(String(localized: "developer.shallow_gauge_testing.title"))
                                .font(.system(size: 11, weight: .semibold, design: .rounded))
                                .foregroundStyle(.white)
                        }
                        .toggleStyle(SwitchToggleStyle(tint: DiveUI.cyan))

                        Text(String(localized: "developer.shallow_gauge_testing.footer"))
                            .font(DiveUI.Typography.hintCaption)
                            .foregroundStyle(DiveUI.cyan)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 7, style: .continuous)
                            .fill(Color.black.opacity(0.52))
                            .overlay(
                                RoundedRectangle(cornerRadius: 7, style: .continuous)
                                    .stroke(DiveUI.cyan.opacity(0.45), lineWidth: 1)
                            )
                    )

                    VStack(alignment: .leading, spacing: 6) {
                        Toggle(isOn: shallowFullComputerTestingBinding) {
                            Text(String(localized: "developer.shallow_diving_testing.title"))
                                .font(.system(size: 11, weight: .semibold, design: .rounded))
                                .foregroundStyle(.white)
                        }
                        .toggleStyle(SwitchToggleStyle(tint: DiveUI.yellow))

                        Text(String(localized: "developer.shallow_diving_testing.footer"))
                            .font(DiveUI.Typography.hintCaption)
                            .foregroundStyle(DiveUI.yellow)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 7, style: .continuous)
                            .fill(Color.black.opacity(0.52))
                            .overlay(
                                RoundedRectangle(cornerRadius: 7, style: .continuous)
                                    .stroke(DiveUI.yellow.opacity(0.45), lineWidth: 1)
                            )
                    )
                }
                .padding(.horizontal, 11)
                .padding(.top, 9)
                .padding(.bottom, 8)
            }
        }
        .onAppear {
            if dive.developerSensorSourceWarning != nil {
                showAppleFallbackAlert = true
            }
        }
        .alert(String(localized: "developer.sensor_source.title"), isPresented: $showAppleFallbackAlert) {
            Button(String(localized: "OK"), role: .cancel) {}
        } message: {
            Text(dive.developerSensorSourceWarning ?? String(localized: "developer.sensor_source.apple_fallback"))
        }
    }

    private func sensorSourceRow(_ mode: SensorSourceMode) -> some View {
        Button {
            applySensorSource(mode)
        } label: {
            HStack {
                Image(systemName: sensorSource == mode ? "largecircle.fill.circle" : "circle")
                    .foregroundStyle(sensorSource == mode ? DiveUI.green : DiveUI.secondaryText)
                Text(mode.displayName)
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                Spacer()
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
    }

    private func applySensorSource(_ mode: SensorSourceMode) {
        sensorSourceRaw = mode.rawValue
        DeveloperSettings.persistSensorSource(mode)
        dive.reloadDepthSensorConfiguration()
        if dive.developerSensorSourceWarning != nil {
            showAppleFallbackAlert = true
        }
    }

    private var shallowGaugeTestingBinding: Binding<Bool> {
        Binding(
            get: { DeveloperSettings.allowsShallowGaugeTesting },
            set: { DeveloperSettings.setShallowGaugeTestingEnabled($0) }
        )
    }

    private var shallowFullComputerTestingBinding: Binding<Bool> {
        Binding(
            get: { DeveloperSettings.allowsShallowDepthDivingTesting },
            set: { DeveloperSettings.setShallowDepthDivingTestingEnabled($0) }
        )
    }

    private var depthCapabilityStatusLine: String {
        let capability = DepthCapabilityResolver.resolve()
        let resolution = dive.depthSensorSourceResolution
        return String(
            format: String(localized: "developer.sensor_source.capability_status"),
            capability.localizedLabel,
            resolution.localizedLabel
        )
    }
}
