import SwiftUI

struct DiveLiveView: View {
    @EnvironmentObject private var dive: DiveManager

    var body: some View {
        ZStack {
            DiveScreenBackground()

            GeometryReader { geometry in
                let contentWidth = geometry.size.width - 18
                let gaugeWidth = min(58, contentWidth * 0.24)
                let leftWidth = contentWidth - gaugeWidth - 8

                VStack(spacing: 7) {
                    if let confirmation = dive.gpsConfirmation {
                        gpsConfirmationView(confirmation)
                    } else if dive.isDiveActive && dive.ascentStatus.isOverLimit {
                        AscentWarningView(status: dive.ascentStatus)
                    } else if dive.isDiveActive {
                        activeDiveContent(leftWidth: leftWidth, gaugeWidth: gaugeWidth)
                    } else {
                        preDiveWaitingContent
                    }

                    if let alarm = dive.alarmWarningMessage {
                        warningBanner(alarm)
                    }
                    if let error = dive.lastErrorMessage {
                        warningBanner(error)
                    }
                }
                .padding(.horizontal, 9)
                .padding(.top, 9)
                .padding(.bottom, 7)
                .frame(width: geometry.size.width, height: geometry.size.height, alignment: .top)
            }
        }
        .animation(.easeInOut(duration: 0.18), value: dive.redWarningBlink)
    }

    @ViewBuilder
    private func gpsConfirmationView(_ confirmation: DiveGPSConfirmation) -> some View {
        switch confirmation {
        case .start(let point):
            GPSStartRegisteredView(point: point)
        case .end(let point):
            GPSEndRegisteredView(point: point)
        }
    }

    private func activeDiveContent(leftWidth: CGFloat, gaugeWidth: CGFloat) -> some View {
        VStack(spacing: 7) {
            topBar
            immersionStatus
            ttvRuntimePanel
            depthSection(leftWidth: leftWidth, gaugeWidth: gaugeWidth)
            stopwatchPanel
            controls
        }
    }

    private var preDiveWaitingContent: some View {
        VStack(spacing: 0) {
            preDiveHeader

            Spacer(minLength: 28)

            Text("PRONTO PER\nL'IMMERSIONE")
                .font(.system(size: 18, weight: .black, design: .rounded))
                .foregroundStyle(DiveUI.blue)
                .multilineTextAlignment(.center)
                .lineSpacing(1)

            Spacer(minLength: 24)

            HStack(spacing: 9) {
                Image(systemName: "mappin.circle.fill")
                    .font(.system(size: 25, weight: .black))
                    .foregroundStyle(DiveUI.blue)
                    .symbolRenderingMode(.hierarchical)
                Text("In attesa di avvio...")
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.78)
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 9)

            Spacer(minLength: 31)

            Text("Il punto GPS di inizio\nverrà registrato\nall'avvio dell'immersione.")
                .font(.system(size: 13, weight: .regular, design: .rounded))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .lineSpacing(2)

            Spacer(minLength: 16)

            if !dive.isDepthAutomationAvailable {
                manualFallbackPanel
                Spacer(minLength: 8)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var preDiveHeader: some View {
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

    private var topBar: some View {
        HStack(alignment: .center) {
            HStack(spacing: 5) {
                DiveOctopusLogo(accent: DiveUI.blue)
                    .frame(width: 29, height: 26, alignment: .leading)
                    .scaleEffect(0.8)
                Text("DIR DIVING")
                    .font(.system(size: 15, weight: .black, design: .rounded))
                    .foregroundStyle(DiveUI.yellow)
                    .lineLimit(1)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 1) {
                DiveClockText(size: 20)
                HStack(spacing: 3) {
                    Image(systemName: "drop.fill")
                        .font(.system(size: 13, weight: .bold))
                    Text(temperatureText)
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .monospacedDigit()
                }
                .foregroundStyle(DiveUI.blue)
            }
        }
    }

    private var immersionStatus: some View {
        HStack(spacing: 8) {
            Image(systemName: "water.waves")
                .font(.system(size: 18, weight: .black))
            Text(dive.isManualLifecycleActive ? "IMMERSIONE MANUALE" : "IN IMMERSIONE")
                .font(.system(size: 15, weight: .black, design: .rounded))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            Spacer(minLength: 0)
        }
        .foregroundStyle(DiveUI.green)
    }

    private var ttvRuntimePanel: some View {
        HStack(spacing: 0) {
            dashboardValue(title: "TTV", value: ttvText, unit: nil, color: DiveUI.green)
            Rectangle()
                .fill(.white.opacity(0.34))
                .frame(width: 1, height: 54)
            dashboardValue(title: "RunTime", value: runtimeMinutes, unit: "min", color: .white)
        }
        .frame(maxWidth: .infinity, minHeight: 70)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.black.opacity(0.42))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(DiveUI.green.opacity(0.86), lineWidth: 1.4)
                )
                .shadow(color: DiveUI.green.opacity(0.16), radius: 5, x: 0, y: 0)
        )
    }

    private func dashboardValue(title: String, value: String, unit: String?, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
            HStack(alignment: .lastTextBaseline, spacing: 4) {
                Text(value)
                    .font(.system(size: 34, weight: .black, design: .rounded))
                    .minimumScaleFactor(0.54)
                    .lineLimit(1)
                    .monospacedDigit()
                    .foregroundStyle(color)
                if let unit {
                    Text(unit)
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(color)
                        .padding(.bottom, 5)
                }
            }
        }
        .frame(maxWidth: .infinity)
    }

    private func depthSection(leftWidth: CGFloat, gaugeWidth: CGFloat) -> some View {
        HStack(alignment: .top, spacing: 8) {
            VStack(alignment: .leading, spacing: 7) {
                depthReadout
                depthSummary
            }
            .frame(width: leftWidth, alignment: .leading)

            AscentGaugeView(status: dive.ascentStatus)
                .frame(width: gaugeWidth, height: 154)
        }
        .frame(maxWidth: .infinity)
    }

    private var depthReadout: some View {
        VStack(spacing: 0) {
            HStack(alignment: .lastTextBaseline, spacing: 4) {
                Text(Formatters.one(dive.currentDepthMeters))
                    .font(.system(size: 72, weight: .black, design: .rounded))
                    .minimumScaleFactor(0.42)
                    .lineLimit(1)
                    .monospacedDigit()
                    .foregroundStyle(dive.redWarningBlink ? DiveUI.red : .white)
                    .shadow(color: dive.redWarningBlink ? DiveUI.red.opacity(0.75) : .clear, radius: 8, x: 0, y: 0)
                    .layoutPriority(1)
                Text("m")
                    .font(.system(size: 31, weight: .black, design: .rounded))
                    .foregroundStyle(DiveUI.blue)
                    .padding(.bottom, 9)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Text("PROFONDITÀ ATTUALE")
                .font(.system(size: 15, weight: .black, design: .rounded))
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
                .font(.system(size: 10, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.62)
            HStack(alignment: .lastTextBaseline, spacing: 3) {
                Text(Formatters.one(value))
                    .font(.system(size: 25, weight: .black, design: .rounded))
                    .foregroundStyle(DiveUI.blue)
                    .monospacedDigit()
                    .lineLimit(1)
                    .minimumScaleFactor(0.62)
                Text("m")
                    .font(.system(size: 12, weight: .black, design: .rounded))
                    .foregroundStyle(DiveUI.blue)
                    .padding(.bottom, 2)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 55)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color.black.opacity(0.45))
                .overlay(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(.white.opacity(0.34), lineWidth: 1.1)
                )
        )
    }

    private var stopwatchPanel: some View {
        HStack(spacing: 15) {
            Image(systemName: "stopwatch")
                .font(.system(size: 35, weight: .black))
                .foregroundStyle(DiveUI.yellow)

            VStack(spacing: 0) {
                Text(Formatters.time(dive.stopwatchTime))
                    .font(.system(size: 39, weight: .black, design: .rounded))
                    .foregroundStyle(DiveUI.yellow)
                    .monospacedDigit()
                    .lineLimit(1)
                    .minimumScaleFactor(0.66)
                Text("CRONOMETRO")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(DiveUI.yellow)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, 14)
        .frame(maxWidth: .infinity, minHeight: 63)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color.black.opacity(0.44))
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(DiveUI.yellow.opacity(0.9), lineWidth: 1.4)
                )
                .shadow(color: DiveUI.yellow.opacity(0.16), radius: 5, x: 0, y: 0)
        )
    }

    private var controls: some View {
        VStack(spacing: 7) {
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
            if dive.isManualLifecycleActive {
                DiveCommandButton("FINE MANUALE", systemImage: "stop.circle.fill", color: DiveUI.red) {
                    dive.endManualDive()
                }
            }
        }
    }

    private var manualFallbackPanel: some View {
        VStack(spacing: 8) {
            Text("AUTOMAZIONE PROFONDITÀ NON DISPONIBILE")
                .font(.system(size: 10, weight: .black, design: .rounded))
                .foregroundStyle(DiveUI.yellow)
                .multilineTextAlignment(.center)
            Text("Puoi registrare una sessione manuale limitata: runtime e GPS sì, profondità automatica no.")
                .font(.system(size: 10, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
            DiveCommandButton("AVVIO MANUALE", systemImage: "play.circle.fill", color: DiveUI.green) {
                dive.startManualDive()
            }
        }
        .padding(9)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(DiveUI.yellow.opacity(0.10))
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(DiveUI.yellow.opacity(0.7), lineWidth: 1)
                )
        )
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
        )
    }

    private var temperatureText: String {
        guard let temp = dive.currentTemperatureCelsius else { return "--.- \u{00B0}C" }
        return "\(Formatters.one(temp)) \u{00B0}C"
    }

    private var ttvText: String {
        Formatters.one(dive.ttv).replacingOccurrences(of: ".", with: ",")
    }

    private var runtimeMinutes: String {
        Formatters.time(dive.runtime)
    }
}
