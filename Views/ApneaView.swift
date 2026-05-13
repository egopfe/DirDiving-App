import SwiftUI

struct ApneaView: View {
    @EnvironmentObject private var exploration: ExplorationStore
    @EnvironmentObject private var dive: DiveManager
    @EnvironmentObject private var compass: CompassManager

    var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                topBar
                mainTimer
                recoveryPanel
                counterPanel
                compassPanel
                warningPanel
                controls
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 10)
        }
        .background(Color.black)
    }

    private var topBar: some View {
        HStack {
            DiveOctopusLogo()
            Spacer()
            Label("APNEA", systemImage: "lungs")
                .font(.caption.bold())
                .foregroundStyle(DiveUI.yellow)
            Spacer()
            Text(exploration.apneaState.rawValue)
                .font(.caption2.bold())
                .foregroundStyle(exploration.apneaState == .warning ? DiveUI.red : DiveUI.yellow)
        }
    }

    private var mainTimer: some View {
        DivePanel(stroke: DiveUI.yellow) {
            VStack(spacing: 4) {
                Text(Formatters.time(exploration.currentApneaSeconds))
                    .font(.system(size: 48, weight: .regular, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(.white)
                Text("APNEA TIMER")
                    .font(.caption.bold())
                    .foregroundStyle(DiveUI.yellow)
                HStack {
                    DiveMetric("DEPTH", value: String(format: "%.1f", dive.currentDepthMeters), unit: "m", color: DiveUI.blue)
                    DiveMetric("MAX", value: String(format: "%.1f", dive.maxDepthMeters), unit: "m", color: DiveUI.blue)
                }
            }
        }
    }

    private var recoveryPanel: some View {
        DivePanel(stroke: recoveryColor) {
            HStack {
                Image(systemName: "timer")
                    .font(.title2.bold())
                    .foregroundStyle(recoveryColor)
                VStack(alignment: .leading, spacing: 2) {
                    Text("RECOVERY")
                        .font(.caption.bold())
                        .foregroundStyle(.white)
                        Text(Formatters.time(exploration.recoverySeconds))
                        .font(.title2.bold())
                        .monospacedDigit()
                        .foregroundStyle(recoveryColor)
                }
                Spacer()
                Text("2:1")
                    .font(.caption.bold())
                    .foregroundStyle(DiveUI.secondaryText)
            }
        }
    }

    private var counterPanel: some View {
        DivePanel(stroke: DiveUI.blue) {
            HStack {
                DiveMetric("DIVE", value: "\(exploration.apneaCount)", color: DiveUI.yellow)
                DiveMetric("BEST", value: bestDepth, unit: "m", color: DiveUI.blue)
                DiveMetric("LAST", value: lastDuration, color: .white)
            }
        }
    }

    private var compassPanel: some View {
        DivePanel(stroke: DiveUI.subtleStroke) {
            HStack {
                Image(systemName: "location.north.fill")
                    .font(.title2.bold())
                    .foregroundStyle(DiveUI.green)
                    .rotationEffect(.degrees(compass.headingDegrees))
                VStack(alignment: .leading, spacing: 2) {
                    Text("COMPASS")
                        .font(.caption.bold())
                        .foregroundStyle(.white)
                    Text("\(Int(compass.headingDegrees))° heading")
                        .font(.caption2)
                        .foregroundStyle(DiveUI.secondaryText)
                }
                Spacer()
            }
        }
    }

    private var warningPanel: some View {
        DivePanel(stroke: exploration.apneaWarning == nil ? DiveUI.green : DiveUI.red) {
            Text(exploration.apneaWarning ?? "Buddy reminder, no-movement e depth warning attivi.")
                .font(.caption2.bold())
                .foregroundStyle(exploration.apneaWarning == nil ? DiveUI.green : DiveUI.red)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
        }
    }

    private var controls: some View {
        HStack(spacing: 6) {
            DiveCommandButton("START", systemImage: "play.fill", color: DiveUI.green) { exploration.startApneaSession() }
            DiveCommandButton("DIVE", systemImage: "arrow.down", color: DiveUI.yellow) { exploration.beginApneaDive() }
            DiveCommandButton("WARN", systemImage: "exclamationmark.triangle", color: DiveUI.red) {
                exploration.triggerApneaWarning("APNEA TROPPO LUNGA")
            }
        }
    }

    private var recoveryColor: Color {
        exploration.recoverySeconds >= exploration.currentApneaSeconds * 2 ? DiveUI.green : DiveUI.yellow
    }

    private var bestDepth: String {
        let value = exploration.apneaDives.map(\.maxDepthMeters).max() ?? dive.maxDepthMeters
        return String(format: "%.1f", value)
    }

    private var lastDuration: String {
        guard let last = exploration.apneaDives.first else { return "--" }
        return Formatters.time(last.durationSeconds)
    }
}
