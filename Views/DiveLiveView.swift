import SwiftUI

struct DiveLiveView: View {
    @EnvironmentObject private var dive: DiveManager

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            GeometryReader { geometry in
                let contentWidth = geometry.size.width - 20
                let gaugeWidth = min(92, contentWidth * 0.25)
                let leftWidth = contentWidth - gaugeWidth - 8

                VStack(spacing: 8) {
                    topBar
                    immersionStatus
                    ttvRuntimePanel
                    depthSection(leftWidth: leftWidth, gaugeWidth: gaugeWidth)
                    stopwatchPanel
                    controls

                    if let error = dive.lastErrorMessage {
                        Text(error)
                            .font(.caption2)
                            .foregroundStyle(DiveUI.yellow)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                    }
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .frame(width: geometry.size.width, height: geometry.size.height, alignment: .top)
            }
        }
    }

    private var topBar: some View {
        HStack(alignment: .center) {
            DiveOctopusLogo()
                .frame(width: 34, height: 30, alignment: .leading)

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
            Image(systemName: "water.waves")
                .font(.title3)
            Text(dive.isDiveActive ? "IN IMMERSIONE" : "PRONTO")
                .font(.headline.bold())
        }
        .foregroundStyle(DiveUI.green)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.leading, 46)
    }

    private var ttvRuntimePanel: some View {
        HStack(spacing: 0) {
            dashboardValue(title: "TTV", value: Formatters.one(dive.ttv), suffix: "", color: DiveUI.green)
            Rectangle()
                .fill(.white.opacity(0.35))
                .frame(width: 1, height: 48)
            dashboardValue(title: "RunTime", value: runtimeMinutes, suffix: "min", color: .white)
        }
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .stroke(DiveUI.green, lineWidth: 1.4)
        )
    }

    private func dashboardValue(title: String, value: String, suffix: String, color: Color) -> some View {
        VStack(spacing: 2) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.white)
            HStack(alignment: .lastTextBaseline, spacing: 4) {
                Text(value)
                    .font(.system(size: 31, weight: .bold, design: .rounded))
                    .minimumScaleFactor(0.72)
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
                .frame(width: gaugeWidth, height: 176)
                .padding(.top, 4)
        }
        .frame(maxWidth: .infinity)
    }

    private var depthReadout: some View {
        VStack(spacing: 0) {
            HStack(alignment: .lastTextBaseline, spacing: 4) {
                Text(Formatters.one(dive.currentDepthMeters))
                    .font(.system(size: 88, weight: .bold, design: .rounded))
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                    .monospacedDigit()
                    .foregroundStyle(dive.redWarningBlink ? DiveUI.red : .white)
                    .layoutPriority(1)
                Text("m")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundStyle(DiveUI.blue)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Text("PROFONDIT\u{00C0} ATTUALE")
                .font(.caption.bold())
                .lineLimit(1)
                .minimumScaleFactor(0.75)
                .foregroundStyle(DiveUI.blue)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var depthSummary: some View {
        HStack(spacing: 8) {
            depthCard(title: "PROF. MASSIMA", value: dive.maxDepthMeters)
            depthCard(title: "PROF. MEDIA", value: dive.averageDepthMeters)
        }
    }

    private func depthCard(title: String, value: Double) -> some View {
        VStack(spacing: 2) {
            Text(title)
                .font(.caption2)
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.65)
            HStack(alignment: .lastTextBaseline, spacing: 3) {
                Text(Formatters.one(value))
                    .font(.system(size: 25, weight: .regular, design: .rounded))
                    .minimumScaleFactor(0.7)
                    .monospacedDigit()
                    .foregroundStyle(DiveUI.blue)
                Text("m")
                    .font(.caption)
                    .foregroundStyle(DiveUI.blue)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 7)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .stroke(.white.opacity(0.42), lineWidth: 1)
        )
    }

    private var stopwatchPanel: some View {
        HStack(spacing: 14) {
            Image(systemName: "timer")
                .font(.title)
            VStack(spacing: 0) {
                Text(Formatters.time(dive.stopwatchTime))
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .minimumScaleFactor(0.75)
                    .monospacedDigit()
                Text("CRONOMETRO")
                    .font(.caption2.bold())
            }
        }
        .foregroundStyle(DiveUI.yellow)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 7)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .stroke(DiveUI.yellow, lineWidth: 1.2)
        )
    }

    private var controls: some View {
        HStack(spacing: 8) {
            controlButton("START", systemImage: "play.fill", color: DiveUI.green) {
                dive.startStopwatch()
            }
            controlButton("STOP", systemImage: "stop.fill", color: DiveUI.red) {
                dive.stopStopwatch()
            }
            controlButton("RESET", systemImage: "arrow.clockwise", color: .white.opacity(0.78)) {
                dive.resetStopwatch()
            }
        }
    }

    private func controlButton(_ title: String, systemImage: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 5) {
                Text(title)
                    .font(.caption.bold())
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
                Image(systemName: systemImage)
                    .font(.caption.bold())
            }
            .foregroundStyle(color)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 9)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(color.opacity(0.12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(color.opacity(0.75), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }

    private var temperatureText: String {
        guard let temp = dive.currentTemperatureCelsius else { return "--.- \u{00B0}C" }
        return "\(Formatters.one(temp)) \u{00B0}C"
    }

    private var runtimeMinutes: String {
        String(Int(dive.runtime / 60.0))
    }
}
