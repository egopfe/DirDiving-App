import SwiftUI

struct CompassView: View {
    @EnvironmentObject private var compass: CompassManager
    @EnvironmentObject private var dive: DiveManager
    @AppStorage(DIRUnitPreference.storageKey) private var watchUnits = DIRUnitPreference.metric.rawValue
    @State private var bearingToast: String?

    private var unitPreference: DIRUnitPreference { DIRUnitPreference.fromStorage(watchUnits) }
    private var missionModeActiveForCurrentDive: Bool { dive.isMissionModeActive && dive.isDiveActive }
    private var missionModeProfile: MissionModeRuntimeProfile { dive.missionModeRuntimeProfile }
    private var compassTransition: AnyTransition {
        missionModeProfile.animationsEnabled
            ? .opacity.combined(with: .move(edge: .top))
            : .identity
    }

    var body: some View {
        ZStack {
            DiveScreenBackground()

            VStack(spacing: 9) {
                header
                statusBanner
                if let bearingToast {
                    bearingFeedbackBanner(bearingToast)
                        .transition(compassTransition)
                }
                compassDial
                diveMetricsPanel
                controls
            }
            .padding(.horizontal, 12)
            .padding(.top, 9)
            .padding(.bottom, 8)
        }
        .onAppear { compass.start() }
        .onDisappear { compass.stop() }
        .animation(missionModeActiveForCurrentDive ? nil : .easeInOut(duration: 0.24), value: compass.headingDegrees)
        .animation(missionModeActiveForCurrentDive ? nil : .easeInOut(duration: 0.24), value: compass.bearingDegrees ?? -1)
        .animation(missionModeActiveForCurrentDive ? nil : .easeInOut(duration: 0.18), value: bearingToast)
    }

    private var compassStatusIsWarning: Bool {
        let message = compass.statusMessage
        return message.localizedCaseInsensitiveContains(String(localized: "compass.keyword.denied"))
            || message.localizedCaseInsensitiveContains(String(localized: "compass.keyword.unavailable"))
    }

    private var statusBanner: some View {
        Text(compass.statusMessage)
            .font(DiveUI.Typography.bannerDetail)
            .foregroundStyle(compassStatusIsWarning ? DiveUI.yellow : DiveUI.secondaryText)
            .lineLimit(1)
            .minimumScaleFactor(0.7)
            .frame(maxWidth: .infinity)
    }

    private func bearingFeedbackBanner(_ message: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 11, weight: .black))
            Text(message)
                .font(DiveUI.Typography.bannerTitle)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
            Spacer(minLength: 0)
        }
        .foregroundStyle(DiveUI.green)
        .padding(.horizontal, 8)
        .padding(.vertical, 5)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(DiveUI.green.opacity(0.10))
                .overlay(RoundedRectangle(cornerRadius: 8, style: .continuous).stroke(DiveUI.green.opacity(0.68), lineWidth: 1))
        )
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

    private var compassDial: some View {
        ZStack {
            CompassTickRing()
                .stroke(.white.opacity(0.72), style: StrokeStyle(lineWidth: 1, lineCap: .round))
                .frame(width: 148, height: 148)
                .rotationEffect(.degrees(-compass.headingDegrees))

            ForEach(cardinalMarkers, id: \.label) { marker in
                Text(marker.label)
                    .font(.system(size: marker.isPrimary ? 18 : 13, weight: .black, design: .rounded))
                    .foregroundStyle(marker.color)
                    .position(marker.position(in: 148))
            }

            VStack(spacing: 1) {
                Image(systemName: "diamond.fill")
                    .font(.system(size: 17, weight: .black))
                    .foregroundStyle(DiveUI.red)
                HStack(alignment: .lastTextBaseline, spacing: 2) {
                    Text(headingText)
                        .font(.system(size: 36, weight: .black, design: .rounded))
                        .minimumScaleFactor(0.72)
                        .lineLimit(1)
                        .monospacedDigit()
                        .foregroundStyle(.white)
                    Text("\u{00B0}")
                        .font(.system(size: 18, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                }
                Text(compass.cardinal)
                    .font(.system(size: 17, weight: .black, design: .rounded))
                    .foregroundStyle(DiveUI.green)
            }
        }
        .frame(width: 156, height: 156)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(String(localized: "BUSSOLA"))
        .accessibilityValue(String(format: String(localized: "compass.a11y.heading_format"), headingText, compass.cardinal))
    }

    private var diveMetricsPanel: some View {
        VStack(spacing: 6) {
            if dive.isDiveActive {
                HStack(spacing: 7) {
                    let depthDisplay = WatchDepthFormatting.display(meters: dive.currentDepthMeters, units: unitPreference)
                    inDiveMetric(title: String(localized: "compass.metric.depth"), value: depthDisplay.valueText, unit: depthDisplay.unitLabel)
                    inDiveMetric(title: String(localized: "compass.metric.runtime"), value: Formatters.time(dive.runtime), unit: nil)
                }
            } else {
                Text(String(localized: "compass.idle.no_dive_data"))
                    .font(.system(size: 10, weight: .black, design: .rounded))
                    .foregroundStyle(DiveUI.yellow)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, minHeight: 39)
                    .background(
                        RoundedRectangle(cornerRadius: 7.5, style: .continuous)
                            .fill(DiveUI.yellow.opacity(0.10))
                            .overlay(
                                RoundedRectangle(cornerRadius: 7.5, style: .continuous)
                                    .stroke(DiveUI.yellow.opacity(0.65), lineWidth: 1)
                            )
                    )
            }
            if dive.isManualLifecycleActive {
                Text(String(localized: "compass.idle.manual_no_depth"))
                    .font(.system(size: 9, weight: .semibold, design: .rounded))
                    .foregroundStyle(DiveUI.yellow)
                    .lineLimit(2)
                    .minimumScaleFactor(0.72)
            }
        }
    }

    private func inDiveMetric(title: String, value: String, unit: String?) -> some View {
        VStack(spacing: 0) {
            Text(title)
                .font(.system(size: 8, weight: .black, design: .rounded))
                .foregroundStyle(DiveUI.blue)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
            HStack(alignment: .lastTextBaseline, spacing: 2) {
                Text(value)
                    .font(.system(size: 20, weight: .black, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(DiveUI.blue)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                if let unit {
                    Text(unit)
                        .font(.system(size: 9, weight: .black, design: .rounded))
                        .foregroundStyle(DiveUI.blue)
                        .padding(.bottom, 2)
                }
            }
        }
        .frame(maxWidth: .infinity, minHeight: 39)
        .background(
            RoundedRectangle(cornerRadius: 7.5, style: .continuous)
                .fill(Color.black.opacity(0.46))
                .overlay(
                    RoundedRectangle(cornerRadius: 7.5, style: .continuous)
                        .stroke(.white.opacity(0.38), lineWidth: 1.2)
                )
        )
    }

    private var controls: some View {
        VStack(spacing: 6) {
            if compass.bearingDegrees != nil {
                Text(String(format: String(localized: "compass.bearing.delta_format"), bearingText, deltaText))
                    .font(.system(size: 10, weight: .black, design: .rounded))
                    .foregroundStyle(DiveUI.yellow)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
            }

            HStack(spacing: 6) {
                Button {
                    compass.setBearing()
                    HapticService.shared.confirm()
                    showBearingToast(String(localized: "compass.bearing.set.toast"))
                } label: {
                    Text(String(localized: "compass.bearing.set"))
                        .font(.system(size: 11, weight: .black, design: .rounded))
                        .foregroundStyle(DiveUI.yellow)
                        .frame(maxWidth: .infinity, minHeight: 31)
                }
                .buttonStyle(.plain)
                .background(commandBackground(DiveUI.yellow))
                .accessibilityLabel(String(localized: "compass.bearing.set.a11y"))

                Button {
                    compass.clearBearing()
                    HapticService.shared.confirm()
                    showBearingToast(String(localized: "compass.bearing.clear.toast"))
                } label: {
                    Text(String(localized: "compass.bearing.clear"))
                        .font(.system(size: 11, weight: .black, design: .rounded))
                        .foregroundStyle(compass.bearingDegrees == nil ? .white.opacity(0.34) : DiveUI.red)
                        .frame(maxWidth: .infinity, minHeight: 31)
                }
                .buttonStyle(.plain)
                .disabled(compass.bearingDegrees == nil)
                .background(commandBackground(compass.bearingDegrees == nil ? .white.opacity(0.34) : DiveUI.red))
                .accessibilityLabel(String(localized: "compass.bearing.clear.a11y"))
            }
        }
    }

    private func commandBackground(_ color: Color) -> some View {
        RoundedRectangle(cornerRadius: 9, style: .continuous)
            .fill(color.opacity(0.08))
            .overlay(
                RoundedRectangle(cornerRadius: 9, style: .continuous)
                    .stroke(color, lineWidth: 1.4)
            )
            .shadow(
                color: missionModeProfile.decorativeEffectsEnabled ? color.opacity(0.18) : .clear,
                radius: missionModeProfile.decorativeEffectsEnabled ? 5 : 0,
                x: 0,
                y: 0
            )
    }

    private func showBearingToast(_ message: String) {
        bearingToast = message
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 1_400_000_000)
            if bearingToast == message {
                bearingToast = nil
            }
        }
    }

    private var bearingDelta: Double? {
        guard let bearing = compass.bearingDegrees else { return nil }
        return DiveAlgorithm.signedBearingDeltaDegrees(from: compass.headingDegrees, to: bearing)
    }

    private var bearingText: String {
        guard let bearing = compass.bearingDegrees else { return "---" }
        return "\(Int(DiveAlgorithm.normalizedDegrees(bearing).rounded()) % 360)\u{00B0}"
    }

    private var deltaText: String {
        guard let bearingDelta else { return "---" }
        let sign = bearingDelta >= 0 ? "+" : ""
        return "\(sign)\(Int(bearingDelta.rounded()))\u{00B0}"
    }

    private var headingText: String {
        "\(Int(DiveAlgorithm.normalizedDegrees(compass.headingDegrees).rounded()) % 360)"
    }

    private var cardinalMarkers: [CompassMarker] {
        [
            CompassMarker(label: "N", angle: 0, color: DiveUI.red, isPrimary: true),
            CompassMarker(label: "E", angle: 90, color: .white.opacity(0.78), isPrimary: false),
            CompassMarker(label: "S", angle: 180, color: .white.opacity(0.86), isPrimary: true),
            CompassMarker(label: "W", angle: 270, color: .white.opacity(0.78), isPrimary: false)
        ]
    }
}

private struct CompassMarker {
    let label: String
    let angle: Double
    let color: Color
    let isPrimary: Bool

    func position(in size: CGFloat) -> CGPoint {
        let radius = size * 0.41
        let radians = (angle - 90) * .pi / 180
        return CGPoint(
            x: size / 2 + cos(radians) * radius,
            y: size / 2 + sin(radians) * radius
        )
    }
}

private struct CompassTickRing: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let outer = min(rect.width, rect.height) / 2

        for tick in 0..<72 {
            let angle = Double(tick) * 5 - 90
            let radians = angle * .pi / 180
            let isMajor = tick % 6 == 0
            let inner = outer - (isMajor ? 11 : 6)
            let start = CGPoint(x: center.x + cos(radians) * inner, y: center.y + sin(radians) * inner)
            let end = CGPoint(x: center.x + cos(radians) * outer, y: center.y + sin(radians) * outer)
            path.move(to: start)
            path.addLine(to: end)
        }

        return path
    }
}
