import SwiftUI

struct CompassView: View {
    @EnvironmentObject private var compass: CompassManager

    var body: some View {
        ZStack {
            DiveScreenBackground()

            VStack(spacing: 9) {
                header
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
        .animation(.easeInOut(duration: 0.24), value: compass.headingDegrees)
        .animation(.easeInOut(duration: 0.24), value: compass.bearingDegrees ?? -1)
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

            // TODO: Replace this visual placeholder if a watch clock value becomes part of the view model.
            Text("--:--")
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
                .monospacedDigit()
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
    }

    private var diveMetricsPanel: some View {
        HStack(spacing: 7) {
            inDiveMetric(title: "PROFONDITÀ", value: placeholderDepthText, unit: "m")
            inDiveMetric(title: "RUNTIME", value: placeholderRuntimeText, unit: nil)
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
        Button {
            compass.setBearing()
        } label: {
            Text("Premi tasto laterale\nper impostare bearing")
                .font(.system(size: 12, weight: .black, design: .rounded))
                .foregroundStyle(DiveUI.yellow)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.7)
                .frame(maxWidth: .infinity, minHeight: 31)
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 7)
        .background(
            RoundedRectangle(cornerRadius: 9, style: .continuous)
                .fill(DiveUI.yellow.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 9, style: .continuous)
                        .stroke(DiveUI.yellow, lineWidth: 1.7)
                )
                .shadow(color: DiveUI.yellow.opacity(0.24), radius: 5, x: 0, y: 0)
        )
    }

    private var bearingDelta: Double? {
        guard let bearing = compass.bearingDegrees else { return nil }
        let delta = bearing - compass.headingDegrees
        if delta > 180 { return delta - 360 }
        if delta < -180 { return delta + 360 }
        return delta
    }

    private var bearingText: String {
        guard let bearing = compass.bearingDegrees else { return "---" }
        return "\(Int(bearing.rounded()))\u{00B0}"
    }

    private var headingText: String {
        "\(Int(compass.headingDegrees.rounded()))"
    }

    private var placeholderDepthText: String {
        // TODO: Wire to current dive depth if CompassView receives dive context in the future.
        "21.4"
    }

    private var placeholderRuntimeText: String {
        // TODO: Wire to current dive runtime if CompassView receives dive context in the future.
        "28:47"
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
