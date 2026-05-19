import SwiftUI

struct SnorkelingView: View {
    @EnvironmentObject private var exploration: ExplorationStore
    @EnvironmentObject private var gps: GPSManager
    @EnvironmentObject private var compass: CompassManager
    @EnvironmentObject private var dive: DiveManager

    private var bearingDelta: Double {
        let delta = exploration.liveTargetBearing - compass.headingDegrees
        if delta > 180 { return delta - 360 }
        if delta < -180 { return delta + 360 }
        return delta
    }

    var body: some View {
        ZStack {
            DiveScreenBackground()

            ScrollView {
                VStack(spacing: 10) {
                    topBar
                    runtimePanel
                    navigationPanel
                    markerPanel
                    safetyPanel
                    controls
                }
                .padding(.horizontal, DiveUI.screenPadding)
                .padding(.vertical, 10)
            }
        }
        .onAppear {
            compass.start()
            gps.start()
        }
        .onDisappear {
            gps.stop()
            compass.stop()
        }
        .onReceive(gps.$lastSpeedMetersPerSecond) { speed in
            exploration.updateSnorkelingProgress(
                speedMetersPerSecond: speed,
                currentPoint: gps.currentBestPoint()
            )
        }
    }

    private var topBar: some View {
        DiveScreenHeader(
            "SNORKELING",
            subtitle: exploration.snorkelingState.rawValue.uppercased(),
            accent: exploration.snorkelingState == .returnMode ? DiveUI.yellow : DiveUI.green,
            systemImage: "figure.pool.swim"
        )
    }

    private var runtimePanel: some View {
        DivePanel(stroke: DiveUI.green) {
            VStack(spacing: 8) {
                HStack(alignment: .lastTextBaseline, spacing: 6) {
                    Image(systemName: "timer")
                        .font(.system(size: 16, weight: .black))
                        .foregroundStyle(DiveUI.green)
                    Text(Formatters.time(exploration.runtimeSeconds))
                        .font(.system(size: 44, weight: .black, design: .rounded))
                        .minimumScaleFactor(0.68)
                        .lineLimit(1)
                        .monospacedDigit()
                        .foregroundStyle(DiveUI.green)
                    Text("RUN")
                        .font(.system(size: 11, weight: .black, design: .rounded))
                        .foregroundStyle(DiveUI.secondaryText)
                    Spacer(minLength: 0)
                }

                HStack(spacing: 0) {
                    DiveMetric("DIST", value: String(format: "%.0f", exploration.distanceMeters), unit: "m", color: DiveUI.blue, valueSize: 26)
                    Rectangle().fill(DiveUI.hairline).frame(width: 1, height: 34)
                    DiveMetric("AVG", value: String(format: "%.1f", exploration.averageSpeedKnots), unit: "kt", color: DiveUI.yellow, valueSize: 26)
                    Rectangle().fill(DiveUI.hairline).frame(width: 1, height: 34)
                    DiveMetric("GPS", value: exploration.gpsStatus, color: .white, valueSize: 15)
                }
            }
        }
    }

    private var navigationPanel: some View {
        DivePanel(stroke: DiveUI.blue) {
            HStack(spacing: 10) {
                DiveBearingRing(
                    headingDegrees: compass.headingDegrees,
                    bearingDelta: bearingDelta,
                    accent: abs(bearingDelta) < 12 ? DiveUI.green : DiveUI.blue,
                    size: 112
                )

                VStack(alignment: .leading, spacing: 7) {
                    Text(exploration.activeWaypoint.name.uppercased())
                        .font(.system(size: 16, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                        .lineLimit(2)
                        .minimumScaleFactor(0.68)

                    HStack(spacing: 5) {
                        DiveStatusPill("\(Int(exploration.liveTargetDistanceMeters)) m", color: DiveUI.blue, systemImage: "point.topleft.down.curvedto.point.bottomright.up")
                        DiveStatusPill(abs(bearingDelta) < 12 ? "ON LINE" : "TURN", color: abs(bearingDelta) < 12 ? DiveUI.green : DiveUI.yellow)
                    }

                    VStack(spacing: 4) {
                        navRow("HEAD", "\(Int(compass.headingDegrees.rounded()))\u{00B0}", .white)
                        navRow("TARGET", "\(Int(exploration.liveTargetBearing.rounded()))\u{00B0}", DiveUI.green)
                        navRow("DELTA", String(format: "%+.0f\u{00B0}", bearingDelta), abs(bearingDelta) < 12 ? DiveUI.green : DiveUI.yellow)
                    }
                }

                Spacer(minLength: 0)
            }
        }
    }

    private func navRow(_ title: String, _ value: String, _ color: Color) -> some View {
        HStack(spacing: 6) {
            Text(title)
                .font(.system(size: 9, weight: .bold, design: .rounded))
                .foregroundStyle(DiveUI.secondaryText)
            Spacer(minLength: 0)
            Text(value)
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(color)
        }
    }

    private var markerPanel: some View {
        DivePanel(stroke: DiveUI.yellow) {
            VStack(spacing: 8) {
                HStack {
                    Label("GPS MARKER", systemImage: "mappin.and.ellipse")
                        .font(.system(size: 11, weight: .black, design: .rounded))
                        .foregroundStyle(DiveUI.yellow)
                    Spacer()
                    DiveStatusPill("\(exploration.markers.count)", color: .white)
                }
                Picker("Marker", selection: $exploration.currentMarkerCategory) {
                    ForEach(GPSMarkerCategory.allCases) { category in
                        Label(category.rawValue, systemImage: category.symbol).tag(category)
                    }
                }
                .labelsHidden()
                DiveCommandButton("SAVE MARKER", systemImage: "mappin.and.ellipse", color: DiveUI.yellow) {
                    exploration.saveMarker(
                        gpsPoint: gps.currentBestPoint(),
                        depthMeters: dive.currentDepthMeters,
                        bearingDegrees: compass.headingDegrees
                    )
                }
            }
        }
    }

    private var safetyPanel: some View {
        let color = exploration.entryDistanceMeters > 300 ? DiveUI.red : DiveUI.green

        return DivePanel(stroke: color) {
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.14))
                        .shadow(color: color.opacity(0.28), radius: 8, x: 0, y: 0)
                    Circle()
                        .stroke(color.opacity(0.78), lineWidth: 1)
                    Image(systemName: "arrow.uturn.backward")
                        .font(.title3.bold())
                        .foregroundStyle(DiveUI.yellow)
                }
                .frame(width: 46, height: 46)

                VStack(alignment: .leading, spacing: 2) {
                    Text("RETURN TO ENTRY")
                        .font(.system(size: 10, weight: .black, design: .rounded))
                        .foregroundStyle(DiveUI.secondaryText)
                    Text("\(Int(exploration.entryDistanceMeters)) m")
                        .font(.system(size: 26, weight: .black, design: .rounded))
                        .monospacedDigit()
                        .foregroundStyle(color)
                }

                Spacer(minLength: 0)
            }
        }
    }

    private var controls: some View {
        HStack(spacing: 6) {
            DiveCommandButton("START", systemImage: "play.fill", color: DiveUI.green) {
                exploration.startSnorkeling(entryPoint: gps.currentBestPoint())
            }
            DiveCommandButton("NAV", systemImage: "location.north.fill", color: DiveUI.blue) { exploration.startNavigation() }
            DiveCommandButton("ENTRY", systemImage: "arrow.uturn.backward", color: DiveUI.yellow) { exploration.startReturnMode() }
        }
    }
}
