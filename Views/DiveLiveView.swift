import SwiftUI

struct DiveLiveView: View {
    @EnvironmentObject private var dive: DiveManager

    var body: some View {
        ZStack {
            DiveScreenBackground()

            GeometryReader { geometry in
                let contentWidth = geometry.size.width - 20
                let gaugeWidth = min(88, contentWidth * 0.28)
                let leftWidth = contentWidth - gaugeWidth - 8

                VStack(spacing: 7) {
                    topBar
                    immersionStatus
                    ttvRuntimePanel
                    depthSection(leftWidth: leftWidth, gaugeWidth: gaugeWidth)
                    stopwatchPanel
                    controls

                    if let error = dive.lastErrorMessage {
                        warningBanner(error)
                    }
                }
                .padding(.horizontal, DiveUI.screenPadding)
                .padding(.vertical, 8)
                .frame(width: geometry.size.width, height: geometry.size.height, alignment: .top)
            }
        }
        .animation(.easeInOut(duration: 0.18), value: dive.redWarningBlink)
    }

    private var topBar: some View {
        HStack(alignment: .center) {
            DiveOctopusLogo()
                .frame(width: 36, height: 32, alignment: .leading)

            Spacer()

            HStack(spacing: 5) {
                Image(systemName: "drop.fill")
                    .font(.headline)
                Text(temperatureText)
                    .font(.headline.monospacedDigit().bold())
            }
            .foregroundStyle(DiveUI.blue)
        }
    }

    private var immersionStatus: some View {
        HStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill((dive.isDiveActive ? DiveUI.green : DiveUI.blue).opacity(0.14))
                    .frame(width: 30, height: 30)
                Image(systemName: "water.waves")
                    .font(.system(size: 15, weight: .black))
            }
            Text(dive.isDiveActive ? "IN IMMERSIONE" : "PRONTO")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            Spacer(minLength: 0)
            DiveStatusPill(dive.isDiveActive ? "LIVE" : "STANDBY", color: dive.isDiveActive ? DiveUI.green : DiveUI.blue)
        }
        .foregroundStyle(dive.isDiveActive ? DiveUI.green : DiveUI.blue)
    }

    private var ttvRuntimePanel: some View {
        DivePanel(stroke: DiveUI.green) {
            HStack(spacing: 0) {
                dashboardValue(title: "TTV", value: Formatters.one(dive.ttv), suffix: "", color: DiveUI.green)
                Rectangle()
                    .fill(DiveUI.hairline)
                    .frame(width: 1, height: 52)
                dashboardValue(title: "RunTime", value: runtimeMinutes, suffix: "", color: .white)
            }
        }
        .padding(.top, 1)
    }

    private func dashboardValue(title: String, value: String, suffix: String, color: Color) -> some View {
        VStack(spacing: 2) {
            Text(title)
                .font(.system(size: 11, weight: .black, design: .rounded))
                .foregroundStyle(DiveUI.secondaryText)
            HStack(alignment: .lastTextBaseline, spacing: 4) {
                Text(value)
                    .font(.system(size: 36, weight: .black, design: .rounded))
                    .minimumScaleFactor(0.68)
                    .lineLimit(1)
                    .monospacedDigit()
                    .foregroundStyle(color)
                if !suffix.isEmpty {
                    Text(suffix)
                        .font(.caption)
                        .foregroundStyle(.white)
                }
            }
        }
        .frame(maxWidth: .infinity)
    }

    private func depthSection(leftWidth: CGFloat, gaugeWidth: CGFloat) -> some View {
        HStack(alignment: .top, spacing: 8) {
            VStack(spacing: 9) {
                depthReadout
                depthSummary
            }
            .frame(width: leftWidth)

            AscentGaugeView(status: dive.ascentStatus)
                .frame(width: gaugeWidth, height: 188)
                .padding(.top, 1)
        }
        .frame(maxWidth: .infinity)
    }

    private var depthReadout: some View {
        VStack(spacing: 0) {
            HStack(alignment: .lastTextBaseline, spacing: 4) {
                Text(Formatters.one(dive.currentDepthMeters))
                    .font(.system(size: 88, weight: .black, design: .rounded))
                    .minimumScaleFactor(0.48)
                    .lineLimit(1)
                    .monospacedDigit()
                    .foregroundStyle(dive.redWarningBlink ? DiveUI.red : .white)
                    .shadow(color: dive.redWarningBlink ? DiveUI.red.opacity(0.75) : .clear, radius: 8, x: 0, y: 0)
                    .layoutPriority(1)
                Text("m")
                    .font(.system(size: 34, weight: .black, design: .rounded))
                    .foregroundStyle(DiveUI.blue)
                    .padding(.bottom, 5)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Text("PROFONDITA ATTUALE")
                .font(.system(size: 14, weight: .black, design: .rounded))
                .lineLimit(1)
                .minimumScaleFactor(0.68)
                .foregroundStyle(DiveUI.blue)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var depthSummary: some View {
        HStack(spacing: 7) {
            depthCard(title: "PROF. MASSIMA", value: dive.maxDepthMeters)
            depthCard(title: "PROF. MEDIA", value: dive.averageDepthMeters)
        }
    }

    private func depthCard(title: String, value: Double) -> some View {
        VStack(spacing: 2) {
            Text(title)
                .font(.system(size: 10, weight: .bold, design: .rounded))
                .foregroundStyle(DiveUI.secondaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.58)
            HStack(alignment: .lastTextBaseline, spacing: 3) {
                Text(Formatters.one(value))
                    .font(.system(size: 27, weight: .regular, design: .rounded))
                    .minimumScaleFactor(0.62)
                    .lineLimit(1)
                    .monospacedDigit()
                    .foregroundStyle(DiveUI.blue)
                Text("m")
                    .font(.caption.bold())
                    .foregroundStyle(DiveUI.blue)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 54)
        .padding(.horizontal, 5)
        .background(
            RoundedRectangle(cornerRadius: 11, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [DiveUI.blue.opacity(0.12), DiveUI.panelFill.opacity(0.82)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 11, style: .continuous)
                        .stroke(.white.opacity(0.42), lineWidth: 1)
                )
        )
    }

    private var stopwatchPanel: some View {
        DivePanel(stroke: DiveUI.yellow) {
            HStack(spacing: 13) {
                Image(systemName: "timer")
                    .font(.system(size: 33, weight: .black))
                VStack(spacing: 0) {
                    Text(Formatters.time(dive.stopwatchTime))
                        .font(.system(size: 38, weight: .black, design: .rounded))
                        .minimumScaleFactor(0.68)
                        .lineLimit(1)
                        .monospacedDigit()
                    Text("CRONOMETRO")
                        .font(.system(size: 11, weight: .black, design: .rounded))
                }
            }
            .foregroundStyle(DiveUI.yellow)
            .frame(maxWidth: .infinity)
        }
    }

    private var controls: some View {
        HStack(spacing: 7) {
            DiveCommandButton("START", systemImage: "play.fill", color: DiveUI.green) {
                dive.startStopwatch()
            }
            DiveCommandButton("STOP", systemImage: "stop.fill", color: DiveUI.red) {
                dive.stopStopwatch()
            }
            DiveCommandButton("RESET", systemImage: "arrow.clockwise", color: .white.opacity(0.78)) {
                dive.resetStopwatch()
            }
        }
    }

    private func warningBanner(_ error: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: "exclamationmark.triangle.fill")
            Text(error)
                .lineLimit(2)
                .minimumScaleFactor(0.72)
        }
        .font(.caption2.bold())
        .foregroundStyle(DiveUI.yellow)
        .multilineTextAlignment(.center)
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(DiveUI.yellow.opacity(0.12))
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(DiveUI.yellow.opacity(0.7), lineWidth: 1)
                )
                .shadow(color: DiveUI.yellow.opacity(0.28), radius: 8, x: 0, y: 0)
        )
    }

    private var temperatureText: String {
        guard let temp = dive.currentTemperatureCelsius else { return "--.- \u{00B0}C" }
        return "\(Formatters.one(temp)) \u{00B0}C"
    }

    private var runtimeMinutes: String {
        Formatters.time(dive.runtime)
    }
}
