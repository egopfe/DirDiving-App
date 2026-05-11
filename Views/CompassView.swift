import SwiftUI

struct CompassView: View {
    @EnvironmentObject private var compass: CompassManager

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 10) {
                header
                headingPanel
                bearingPanel
                controls
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
        }
        .onAppear { compass.start() }
        .onDisappear { compass.stop() }
    }

    private var header: some View {
        HStack {
            Text("BUSSOLA")
                .font(.headline.bold())
                .foregroundStyle(DiveUI.blue)
            Spacer()
            Text(compass.cardinal)
                .font(.headline.bold())
                .foregroundStyle(DiveUI.yellow)
        }
    }

    private var headingPanel: some View {
        DivePanel(stroke: DiveUI.green) {
            VStack(spacing: 0) {
                Text("\(Int(compass.headingDegrees.rounded()))")
                    .font(.system(size: 72, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(.white)
                Text("HEADING")
                    .font(.caption.bold())
                    .foregroundStyle(DiveUI.blue)
            }
        }
    }

    private var bearingPanel: some View {
        DivePanel(stroke: compass.bearingDegrees == nil ? DiveUI.subtleStroke : DiveUI.yellow) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text("BEARING")
                        .font(.caption.bold())
                        .foregroundStyle(.white)
                    Text(bearingText)
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                        .monospacedDigit()
                        .foregroundStyle(compass.bearingDegrees == nil ? DiveUI.secondaryText : DiveUI.yellow)
                }
                Spacer()
                Image(systemName: "location.north.line.fill")
                    .font(.title)
                    .foregroundStyle(DiveUI.blue)
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

    private var bearingText: String {
        guard let bearing = compass.bearingDegrees else { return "---" }
        return "\(Int(bearing.rounded()))"
    }
}

