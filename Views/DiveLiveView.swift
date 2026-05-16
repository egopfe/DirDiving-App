import SwiftUI

struct DiveLiveView: View {
    @EnvironmentObject private var dive: DiveManager

    var body: some View {
        ZStack {
            DiveScreenBackground()

            GeometryReader { geometry in
                let contentWidth = geometry.size.width - 18
                let gaugeWidth = min(62, contentWidth * 0.25)
                let leftWidth = contentWidth - gaugeWidth - 7

                VStack(spacing: 8) {
                    if dive.isDiveActive && dive.ascentStatus.isOverLimit {
                        AscentWarningView(status: dive.ascentStatus)
                    } else if dive.isDiveActive {
                        topBar
                        immersionStatus
                        liveMetrics(leftWidth: leftWidth, gaugeWidth: gaugeWidth)
                        controls
                    } else {
                        preDiveWaitingContent
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

            // TODO: Replace this visual placeholder if a watch clock value becomes part of the view model.
            Text("--:--")
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
                .monospacedDigit()
        }
    }

    private var topBar: some View {
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

            VStack(alignment: .trailing, spacing: 1) {
                // TODO: Replace this visual placeholder if a watch clock value becomes part of the view model.
                Text("--:--")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                HStack(spacing: 3) {
                    Image(systemName: "drop.fill")
                        .font(.system(size: 10, weight: .bold))
                    Text(temperatureText)
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .monospacedDigit()
                }
                .foregroundStyle(DiveUI.blue)
            }
        }
    }

    private var immersionStatus: some View {
        HStack(spacing: 5) {
            Text(dive.isDiveActive ? "IN IMMERSIONE" : "PRONTO")
                .font(.system(size: 11, weight: .black, design: .rounded))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            Spacer(minLength: 0)
        }
        .foregroundStyle(DiveUI.green)
    }

    private func liveMetrics(leftWidth: CGFloat, gaugeWidth: CGFloat) -> some View {
        HStack(alignment: .top, spacing: 7) {
            VStack(alignment: .leading, spacing: 6) {
                depthReadout
                ttvRuntimeCards
            }
            .frame(width: leftWidth, alignment: .leading)

            AscentGaugeView(status: dive.ascentStatus)
                .frame(width: gaugeWidth, height: 158)
                .padding(.top, 7)
        }
        .frame(maxWidth: .infinity)
    }

    private var ttvRuntimeCards: some View {
        HStack(spacing: 6) {
            dashboardValue(title: "TTV", value: Formatters.one(dive.ttv), unit: "min", color: DiveUI.green)
            dashboardValue(title: "RunTime", value: runtimeMinutes, unit: "min", color: .white)
        }
    }

    private func dashboardValue(title: String, value: String, unit: String, color: Color) -> some View {
        VStack(spacing: 1) {
            Text(title)
                .font(.system(size: 9, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            Text(value)
                .font(.system(size: 22, weight: .black, design: .rounded))
                .minimumScaleFactor(0.62)
                .lineLimit(1)
                .monospacedDigit()
                .foregroundStyle(color)
            Text(unit)
                .font(.system(size: 9, weight: .bold, design: .rounded))
                .foregroundStyle(color)
        }
        .frame(maxWidth: .infinity, minHeight: 54)
        .background(
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .fill(Color.black.opacity(0.55))
                .overlay(
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .stroke(.white.opacity(0.35), lineWidth: 1.3)
                )
        )
    }

    private var depthReadout: some View {
        VStack(spacing: 0) {
            HStack(alignment: .lastTextBaseline, spacing: 4) {
                Text(Formatters.one(dive.currentDepthMeters))
                    .font(.system(size: 70, weight: .black, design: .rounded))
                    .minimumScaleFactor(0.48)
                    .lineLimit(1)
                    .monospacedDigit()
                    .foregroundStyle(dive.redWarningBlink ? DiveUI.red : .white)
                    .shadow(color: dive.redWarningBlink ? DiveUI.red.opacity(0.75) : .clear, radius: 8, x: 0, y: 0)
                    .layoutPriority(1)
                Text("m")
                    .font(.system(size: 21, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .padding(.bottom, 8)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Text("PROFONDITA ATTUALE")
                .font(.system(size: 12, weight: .black, design: .rounded))
                .lineLimit(1)
                .minimumScaleFactor(0.68)
                .foregroundStyle(DiveUI.blue)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var controls: some View {
        HStack(spacing: 7) {
            DiveCommandButton("START", color: DiveUI.green) {
                dive.startStopwatch()
            }
            DiveCommandButton("STOP", color: DiveUI.red) {
                dive.stopStopwatch()
            }
            DiveCommandButton("RESET", color: .white.opacity(0.86)) {
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
