import SwiftUI
import WatchKit

struct InfoView: View {
    @EnvironmentObject private var watchSync: WatchSyncService
    @EnvironmentObject private var dive: DiveManager
    @State private var batteryLevel: Float = WKInterfaceDevice.current().batteryLevel
    @State private var versionTapCount = 0
    @State private var developerUnlockedNotice = false

    var body: some View {
        ZStack {
            DiveScreenBackground()

            ScrollView {
                VStack(spacing: 5) {
                    HStack {
                        WatchDetailBackButton()
                        Spacer()
                    }
                    header

                    Text(String(localized: "info.title"))
                        .font(DiveUI.Typography.screenTitle)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)

                    VStack(spacing: 4) {
                        versionRow
                        deviceRow
                        batteryRow
                        appleLowPowerModeRow
                        depthDiagnostics
                        infoRow(title: String(localized: "info.sync"), value: watchSync.lastSyncStatus)
                        infoRow(title: String(localized: "sync.storage.free_space"), value: String(localized: "info.storage.managed_by_watchos"))
                    }
                }
                .padding(.horizontal, 11)
                .padding(.top, 9)
                .padding(.bottom, 8)
            }
        }
        .onAppear {
            WKInterfaceDevice.current().isBatteryMonitoringEnabled = true
            batteryLevel = WKInterfaceDevice.current().batteryLevel
        }
        .alert(String(localized: "developer.section.title"), isPresented: $developerUnlockedNotice) {
            Button(String(localized: "OK"), role: .cancel) {}
        } message: {
            Text(String(localized: "developer.unlock.confirmed"))
        }
    }

    private var versionRow: some View {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "n/d"
        return infoRow(title: String(localized: "Versione"), value: version)
            .developerVersionUnlock(tapCount: $versionTapCount) {
                developerUnlockedNotice = true
            }
    }

    private var header: some View {
        HStack(alignment: .center) {
            HStack(spacing: 5) {
                DiveOctopusLogo(accent: DiveUI.yellow)
                    .frame(width: 23, height: 22, alignment: .leading)
                    .scaleEffect(0.68)
                Text("DIR DIVING")
                    .font(.system(size: 11, weight: .black, design: .rounded))
                    .foregroundStyle(DiveUI.yellow)
                    .lineLimit(1)
            }

            Spacer()

            DiveClockText(size: 14)
        }
    }

    private func infoRow(title: String, value: String) -> some View {
        HStack(alignment: .center) {
            Text(title)
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
            Spacer(minLength: 8)
            Text(value)
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
                .monospacedDigit()
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 7)
        .frame(minHeight: 44)
        .background(rowBackground)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(String(format: String(localized: "info.row.a11y.format"), title, value))
    }

    private var deviceRow: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(String(localized: "Dispositivo"))
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
            Text(WKInterfaceDevice.current().name)
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundStyle(DiveUI.blue)
                .lineLimit(1)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .frame(maxWidth: .infinity, minHeight: 42, alignment: .leading)
        .background(rowBackground)
    }

    private var appleLowPowerModeRow: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(String(localized: "info.apple_lpm.title"))
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
            Text(
                ProcessInfo.processInfo.isLowPowerModeEnabled
                    ? String(localized: "info.apple_lpm.on")
                    : String(localized: "info.apple_lpm.off")
            )
            .font(DiveUI.Typography.hintCaption)
            .foregroundStyle(DiveUI.blue)
            .fixedSize(horizontal: false, vertical: true)
            Text(String(localized: "info.apple_lpm.cannot_enable"))
                .font(DiveUI.Typography.rowSubtitle)
                .foregroundStyle(DiveUI.secondaryText)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 7)
        .frame(maxWidth: .infinity, minHeight: 42, alignment: .leading)
        .background(rowBackground)
    }

    private var batteryBarColor: Color {
        guard batteryLevel >= 0 else { return DiveUI.secondaryText }
        if batteryLevel > 0.5 { return DiveUI.green }
        if batteryLevel > 0.2 { return DiveUI.yellow }
        return DiveUI.red
    }

    @ViewBuilder
    private var batteryRow: some View {
        let percent = batteryLevel >= 0 ? Int((batteryLevel * 100).rounded()) : -1
        return VStack(spacing: 5) {
            HStack {
                Text(String(localized: "Batteria"))
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                Spacer()
                Text(percent >= 0 ? "\(percent)%" : "n/d")
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                    .monospacedDigit()
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(.white.opacity(0.22))
                    Capsule()
                        .fill(batteryBarColor)
                        .frame(width: geometry.size.width * CGFloat(max(0, batteryLevel)))
                }
            }
            .frame(height: 6)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 7)
        .frame(minHeight: 44)
        .background(rowBackground)
    }

    private var depthDiagnostics: some View {
        VStack(alignment: .leading, spacing: 5) {
            diagnosticRow(String(localized: "Entitlement profondità"), String(localized: "info.depth.entitlement.review_required"))
            diagnosticRow(
                String(localized: "developer.sensor_source.title"),
                dive.depthSensorSourceResolution.localizedLabel
            )
            if let draftDiagnostic = dive.draftRecoveryDiagnostic {
                Text(draftDiagnostic)
                    .font(DiveUI.Typography.rowSubtitle)
                    .foregroundStyle(DiveUI.yellow)
                    .fixedSize(horizontal: false, vertical: true)
            }
            diagnosticRow(
                String(localized: "settings.row.depth_sensor.title"),
                dive.isDepthAutomationAvailable
                    ? String(localized: "info.status.available")
                    : String(localized: "Non disponibile")
            )
            diagnosticRow(
                String(localized: "Callback acqua"),
                dive.isDepthAutomationAvailable ? String(localized: "Pronto") : String(localized: "Non verificabile")
            )
            Text(String(localized: "info.depth.validation_note"))
                .font(DiveUI.Typography.rowSubtitle)
                .foregroundStyle(DiveUI.yellow)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 7)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 7, style: .continuous)
                .fill(DiveUI.blue.opacity(0.10))
                .overlay(RoundedRectangle(cornerRadius: 7, style: .continuous).stroke(DiveUI.blue.opacity(0.45), lineWidth: 1))
        )
    }

    private func diagnosticValueIsPositive(_ value: String) -> Bool {
        let positives = [
            String(localized: "info.status.available"),
            String(localized: "Pronto")
        ]
        return positives.contains(value)
    }

    private func diagnosticRow(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title)
                .font(DiveUI.Typography.rowTitle)
                .foregroundStyle(.white)
            Spacer(minLength: 6)
            Text(value)
                .font(DiveUI.Typography.statusValue)
                .foregroundStyle(diagnosticValueIsPositive(value) ? DiveUI.green : DiveUI.yellow)
        }
    }

    private var sensorSourceLabel: String {
        switch DeveloperSettings.sensorSourceMode {
        case .automatic:
            return String(localized: "developer.sensor_source.automatic")
        case .appleSensor:
            return String(localized: "developer.sensor_source.apple_sensor")
        case .simulation:
            return String(localized: "developer.sensor_source.simulation")
        }
    }

    private var rowBackground: some View {
        RoundedRectangle(cornerRadius: 7, style: .continuous)
            .fill(Color.black.opacity(0.52))
            .overlay(
                RoundedRectangle(cornerRadius: 7, style: .continuous)
                    .stroke(.white.opacity(0.24), lineWidth: 1)
            )
    }
}
