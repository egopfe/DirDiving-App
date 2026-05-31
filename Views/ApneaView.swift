import SwiftUI

struct ApneaView: View {
    @EnvironmentObject private var exploration: ExplorationStore
    @EnvironmentObject private var dive: DiveManager
    @EnvironmentObject private var compass: CompassManager

    var body: some View {
        ZStack {
            DiveScreenBackground()

            ScrollView {
                VStack(spacing: 10) {
                    topBar
                    mainTimer
                    recoveryPanel
                    counterPanel
                    compassPanel
                    warningPanel
                    controls
                }
                .padding(.horizontal, DiveUI.screenPadding)
                .padding(.vertical, 10)
            }
        }
        .onAppear { compass.start() }
        .onDisappear { compass.stop() }
        .animation(.easeInOut(duration: 0.18), value: exploration.currentApneaSeconds)
        .animation(.easeInOut(duration: 0.18), value: exploration.recoverySeconds)
    }

    private var topBar: some View {
        DiveScreenHeader(
            "APNEA",
            subtitle: exploration.apneaState.rawValue.uppercased(),
            accent: exploration.apneaState == .warning ? DiveUI.red : DiveUI.yellow,
            systemImage: "lungs"
        )
    }

    private var mainTimer: some View {
        DivePanel(stroke: exploration.apneaState == .warning ? DiveUI.red : DiveUI.yellow) {
            VStack(spacing: 7) {
                Text(Formatters.time(exploration.currentApneaSeconds))
                    .font(.system(size: 56, weight: .black, design: .rounded))
                    .minimumScaleFactor(0.62)
                    .lineLimit(1)
                    .monospacedDigit()
                    .foregroundStyle(exploration.apneaState == .warning ? DiveUI.red : .white)
                    .shadow(color: exploration.apneaState == .warning ? DiveUI.red.opacity(0.65) : .clear, radius: 8, x: 0, y: 0)

                HStack {
                    Text("APNEA TIMER")
                        .font(.system(size: 11, weight: .black, design: .rounded))
                        .foregroundStyle(DiveUI.yellow)
                    Spacer()
                    DiveStatusPill(exploration.apneaState.rawValue.uppercased(), color: exploration.apneaState == .warning ? DiveUI.red : DiveUI.yellow)
                }

                HStack(spacing: 0) {
                    DiveMetric("DEPTH", value: String(format: "%.1f", dive.currentDepthMeters), unit: "m", color: DiveUI.blue, valueSize: 28)
                    Rectangle().fill(DiveUI.hairline).frame(width: 1, height: 38)
                    DiveMetric("MAX", value: String(format: "%.1f", dive.maxDepthMeters), unit: "m", color: DiveUI.blue, valueSize: 28)
                }
            }
        }
    }

    private var recoveryPanel: some View {
        DivePanel(stroke: recoveryColor) {
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(recoveryColor.opacity(0.13))
                    Circle()
                        .stroke(recoveryColor.opacity(0.78), lineWidth: 1)
                    Image(systemName: "timer")
                        .font(.title2.bold())
                        .foregroundStyle(recoveryColor)
                }
                .frame(width: 48, height: 48)

                VStack(alignment: .leading, spacing: 2) {
                    Text("RECOVERY")
                        .font(.system(size: 10, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                    Text(Formatters.time(exploration.recoverySeconds))
                        .font(.system(size: 30, weight: .black, design: .rounded))
                        .minimumScaleFactor(0.72)
                        .monospacedDigit()
                        .foregroundStyle(recoveryColor)
                }

                Spacer(minLength: 0)

                VStack(spacing: 2) {
                    Text("TARGET")
                        .font(.system(size: 8, weight: .bold, design: .rounded))
                        .foregroundStyle(DiveUI.mutedText)
                    Text("2:1")
                        .font(.system(size: 17, weight: .black, design: .rounded))
                        .foregroundStyle(DiveUI.secondaryText)
                }
            }
        }
    }

    private var counterPanel: some View {
        DivePanel(stroke: DiveUI.blue) {
            HStack(spacing: 0) {
                DiveMetric("DIVE", value: "\(exploration.apneaCount)", color: DiveUI.yellow, valueSize: 26)
                Rectangle().fill(DiveUI.hairline).frame(width: 1, height: 38)
                DiveMetric("BEST", value: bestDepth, unit: "m", color: DiveUI.blue, valueSize: 26)
                Rectangle().fill(DiveUI.hairline).frame(width: 1, height: 38)
                DiveMetric("LAST", value: lastDuration, color: .white, valueSize: 22)
            }
        }
    }

    private var compassPanel: some View {
        DivePanel(stroke: DiveUI.green) {
            HStack(spacing: 10) {
                DiveBearingRing(headingDegrees: compass.headingDegrees, accent: DiveUI.green, size: 82)
                VStack(alignment: .leading, spacing: 3) {
                    Text("COMPASS")
                        .font(.system(size: 11, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                    Text("\(Int(compass.headingDegrees.rounded()))\u{00B0} heading")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .monospacedDigit()
                        .foregroundStyle(DiveUI.secondaryText)
                    Text("Visual reference only")
                        .font(.system(size: 9, weight: .medium, design: .rounded))
                        .foregroundStyle(DiveUI.mutedText)
                }
                Spacer(minLength: 0)
            }
        }
    }

    private var warningPanel: some View {
        let hasWarning = exploration.apneaWarning != nil
        let color = hasWarning ? DiveUI.red : DiveUI.green

        return DivePanel(stroke: color) {
            HStack(spacing: 8) {
                Image(systemName: hasWarning ? "exclamationmark.triangle.fill" : "checkmark.shield.fill")
                    .font(.caption.bold())
                Text(exploration.apneaWarning ?? "Buddy reminder, no-movement e depth warning attivi.")
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer(minLength: 0)
            }
            .foregroundStyle(color)
        }
    }

    private var controls: some View {
        HStack(spacing: 6) {
            DiveCommandButton("START", systemImage: "play.fill", color: DiveUI.green) { exploration.startApneaSession() }
            DiveCommandButton("DIVE", systemImage: "arrow.down", color: DiveUI.yellow) { exploration.beginApneaDive() }
            DiveCommandButton("SURFACE", systemImage: "arrow.up", color: DiveUI.blue) {
                exploration.surfaceFromApnea(maxDepthMeters: dive.maxDepthMeters)
            }
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
