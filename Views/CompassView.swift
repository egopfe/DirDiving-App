import SwiftUI

struct CompassView: View {
    @EnvironmentObject private var compass: CompassManager

    var body: some View {
        ZStack {
            DiveScreenBackground()

            VStack(spacing: 11) {
                header
                headingPanel
                bearingPanel
                controls
            }
            .padding(.horizontal, DiveUI.screenPadding)
            .padding(.vertical, 9)
        }
        .onAppear { compass.start() }
        .onDisappear { compass.stop() }
        .animation(.easeInOut(duration: 0.24), value: compass.headingDegrees)
        .animation(.easeInOut(duration: 0.24), value: compass.bearingDegrees ?? -1)
    }

    private var header: some View {
        DiveScreenHeader(
            "BUSSOLA",
            subtitle: "HEADING REFERENCE",
            accent: DiveUI.blue,
            systemImage: "safari"
        )
    }

    private var headingPanel: some View {
        DivePanel(stroke: DiveUI.green) {
            VStack(spacing: 8) {
                DiveBearingRing(
                    headingDegrees: compass.headingDegrees,
                    bearingDelta: bearingDelta,
                    accent: DiveUI.green,
                    size: 138
                )

                HStack(alignment: .lastTextBaseline, spacing: 6) {
                    Text("\(Int(compass.headingDegrees.rounded()))")
                        .font(.system(size: 44, weight: .black, design: .rounded))
                        .minimumScaleFactor(0.72)
                        .lineLimit(1)
                        .monospacedDigit()
                        .foregroundStyle(.white)
                    Text("\u{00B0}")
                        .font(.title2.bold())
                        .foregroundStyle(DiveUI.blue)
                    Text(compass.cardinal)
                        .font(.system(size: 18, weight: .black, design: .rounded))
                        .foregroundStyle(DiveUI.yellow)
                }

                Text("HEADING")
                    .font(.system(size: 10, weight: .black, design: .rounded))
                    .foregroundStyle(DiveUI.blue)
            }
        }
    }

    private var bearingPanel: some View {
        DivePanel(stroke: compass.bearingDegrees == nil ? DiveUI.subtleStroke : DiveUI.yellow) {
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill((compass.bearingDegrees == nil ? DiveUI.subtleStroke : DiveUI.yellow).opacity(0.13))
                    Circle()
                        .stroke((compass.bearingDegrees == nil ? DiveUI.subtleStroke : DiveUI.yellow).opacity(0.75), lineWidth: 1)
                    Image(systemName: "location.north.line.fill")
                        .font(.title2.bold())
                        .foregroundStyle(compass.bearingDegrees == nil ? DiveUI.secondaryText : DiveUI.yellow)
                        .rotationEffect(.degrees(bearingDelta ?? 0))
                }
                .frame(width: 48, height: 48)

                VStack(alignment: .leading, spacing: 2) {
                    Text("BEARING")
                        .font(.system(size: 10, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                    Text(bearingText)
                        .font(.system(size: 31, weight: .black, design: .rounded))
                        .monospacedDigit()
                        .foregroundStyle(compass.bearingDegrees == nil ? DiveUI.secondaryText : DiveUI.yellow)
                }

                Spacer(minLength: 0)

                DiveStatusPill(compass.bearingDegrees == nil ? "FREE" : "LOCK", color: compass.bearingDegrees == nil ? DiveUI.secondaryText : DiveUI.yellow)
            }
        }
    }

    private var controls: some View {
        HStack(spacing: 8) {
            DiveCommandButton("SET", systemImage: "scope", color: DiveUI.green) {
                compass.setBearing()
            }
            DiveCommandButton("CLEAR", systemImage: "xmark", color: .white.opacity(0.78)) {
                compass.clearBearing()
            }
        }
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
}
