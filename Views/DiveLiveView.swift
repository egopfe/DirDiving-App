import SwiftUI

struct DiveLiveView: View {
    @EnvironmentObject private var dive: DiveManager

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 9) {
                topBar
                immersionStatus
                ttvRuntimePanel
                depthAndAscent
                depthSummary
                stopwatchPanel
                controls

                if let error = dive.lastErrorMessage {
                    Text(error)
                        .font(.caption2)
                        .foregroundStyle(.yellow)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
        }
    }

    private var topBar: some View {
        HStack {
            Text("🐙")
                .font(.title3)
                .foregroundStyle(.blue)
            Spacer()
            HStack(spacing: 5) {
                Image(systemName: "drop.fill")
                Text(temperatureText)
            }
            .font(.headline.monospacedDigit())
            .foregroundStyle(.blue)
        }
    }

    private var immersionStatus: some View {
        HStack(spacing: 8) {
            Image(systemName: "water.waves")
            Text(dive.isDiveActive ? "IN IMMERSIONE" : "PRONTO")
                .font(.headline.bold())
        }
        .foregroundStyle(.green)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.leading, 18)
    }

    private var ttvRuntimePanel: some View {
        HStack(spacing: 0) {
            dashboardValue(title: "TTV", value: Formatters.one(dive.ttv), suffix: "")
            Rectangle()
                .fill(.white.opacity(0.35))
                .frame(width: 1, height: 52)
            dashboardValue(title: "RunTime", value: runtimeMinutes, suffix: "min")
        }
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .stroke(.green, lineWidth: 1.2)
        )
    }

    private func dashboardValue(title: String, value: String, suffix: String) -> some View {
        VStack(spacing: 2) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.white)
            HStack(alignment: .lastTextBaseline, spacing: 4) {
                Text(value)
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(title == "TTV" ? .green : .white)
                if !suffix.isEmpty {
                    Text(suffix)
                        .font(.caption)
                        .foregroundStyle(.white)
                }
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var depthAndAscent: some View {
        HStack(alignment: .center, spacing: 8) {
            VStack(spacing: 0) {
                HStack(alignment: .lastTextBaseline, spacing: 4) {
                    Text(Formatters.one(dive.currentDepthMeters))
                        .font(.system(size: 76, weight: .bold, design: .rounded))
                        .minimumScaleFactor(0.55)
                        .monospacedDigit()
                        .foregroundStyle(dive.redWarningBlink ? .red : .white)
                    Text("m")
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                        .foregroundStyle(.blue)
                }
                Text("PROFONDITÀ ATTUALE")
                    .font(.caption.bold())
                    .foregroundStyle(.blue)
            }
            .frame(maxWidth: .infinity)

            AscentGaugeView(status: dive.ascentStatus)
                .frame(width: 94, height: 168)
        }
    }

    private var depthSummary: some View {
        HStack(spacing: 8) {
            depthCard(title: "PROF. MASSIMA", value: dive.maxDepthMeters)
            depthCard(title: "PROF. MEDIA", value: dive.averageDepthMeters)
        }
    }

    private func depthCard(title: String, value: Double) -> some View {
        VStack(spacing: 3) {
            Text(title)
                .font(.caption2)
                .foregroundStyle(.white)
            HStack(alignment: .lastTextBaseline, spacing: 3) {
                Text(Formatters.one(value))
                    .font(.system(size: 25, weight: .regular, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(.blue)
                Text("m")
                    .font(.caption)
                    .foregroundStyle(.blue)
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
                    .monospacedDigit()
                Text("CRONOMETRO")
                    .font(.caption2.bold())
            }
        }
        .foregroundStyle(.yellow)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 7)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .stroke(.yellow, lineWidth: 1)
        )
    }

    private var controls: some View {
        HStack(spacing: 8) {
            controlButton("START", systemImage: "play.fill", color: .green) {
                dive.startStopwatch()
            }
            controlButton("STOP", systemImage: "stop.fill", color: .red) {
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
        guard let temp = dive.currentTemperatureCelsius else { return "--.- °C" }
        return "\(Formatters.one(temp)) °C"
    }

    private var runtimeMinutes: String {
        String(Int(dive.runtime / 60.0))
    }
}
