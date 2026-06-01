import SwiftUI
import WatchKit
import CoreMotion

struct InfoView: View {
    @EnvironmentObject private var watchSync: WatchSyncService
    @EnvironmentObject private var dive: DiveManager
    @State private var batteryLevel: Float = WKInterfaceDevice.current().batteryLevel

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
                        .font(.system(size: 10, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)

                    VStack(spacing: 4) {
                        infoRow(title: String(localized: "Versione"), value: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "n/d")
                        deviceRow
                        batteryRow
                        appleLowPowerModeRow
                        depthDiagnostics
                        infoRow(title: String(localized: "info.sync"), value: watchSync.lastSyncStatus)
                        infoRow(title: String(localized: "Spazio libero"), value: String(localized: "Gestito da watchOS"))
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
        .frame(minHeight: 34)
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
            .font(.system(size: 10, weight: .semibold, design: .rounded))
            .foregroundStyle(DiveUI.blue)
            .fixedSize(horizontal: false, vertical: true)
            Text(String(localized: "info.apple_lpm.cannot_enable"))
                .font(.system(size: 9, weight: .medium, design: .rounded))
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
        VStack(spacing: 5) {
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
        .frame(minHeight: 42)
        .background(rowBackground)
    }

    private var depthDiagnostics: some View {
        VStack(alignment: .leading, spacing: 5) {
            diagnosticRow(String(localized: "Entitlement profondità"), String(localized: "info.depth.entitlement.review_required"))
            diagnosticRow(
                String(localized: "settings.row.depth_sensor.title"),
                CMWaterSubmersionManager.waterSubmersionAvailable
                    ? String(localized: "Disponibile")
                    : String(localized: "Non disponibile")
            )
            diagnosticRow(
                String(localized: "Callback acqua"),
                dive.isDepthAutomationAvailable ? String(localized: "Pronto") : String(localized: "Non verificabile")
            )
            Text(String(localized: "info.depth.validation_note"))
                .font(.system(size: 9, weight: .semibold, design: .rounded))
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
            String(localized: "Disponibile"),
            String(localized: "Pronto")
        ]
        return positives.contains(value)
    }

    private func diagnosticRow(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 10, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
            Spacer(minLength: 6)
            Text(value)
                .font(.system(size: 10, weight: .black, design: .rounded))
                .foregroundStyle(diagnosticValueIsPositive(value) ? DiveUI.green : DiveUI.yellow)
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
