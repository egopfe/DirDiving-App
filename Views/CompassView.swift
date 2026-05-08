import SwiftUI

struct CompassView: View {
    @EnvironmentObject private var compass: CompassManager

    var body: some View {
        VStack(spacing: 8) {
            Text("BUSSOLA").font(.headline).foregroundStyle(.cyan)
            Text("\(Int(compass.headingDegrees))°").font(.system(size: 42, weight: .bold, design: .rounded))
            Text(compass.cardinal).font(.title3).foregroundStyle(.yellow)

            if let bearing = compass.bearingDegrees {
                Text("BEARING \(Int(bearing))°").font(.caption).foregroundStyle(.green)
                Button("CLEAR") { compass.clearBearing() }
            } else {
                Button("SET BEARING") { compass.setBearing() }
            }
        }
        .padding()
        .onAppear { compass.start() }
        .onDisappear { compass.stop() }
    }
}
