import SwiftUI

struct SnorkelingView: View {
    @EnvironmentObject private var exploration: ExplorationStore
    @EnvironmentObject private var gps: GPSManager
    @EnvironmentObject private var compass: CompassManager
    @EnvironmentObject private var dive: DiveManager

    private var bearingDelta: Double {
        let delta = exploration.activeWaypoint.targetBearing - compass.headingDegrees
        if delta > 180 { return delta - 360 }
        if delta < -180 { return delta + 360 }
        return delta
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                topBar
                runtimePanel
                navigationPanel
                markerPanel
                safetyPanel
                controls
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 10)
        }
        .background(Color.black)
        .onAppear { gps.start() }
    }

    private var topBar: some View {
        HStack {
            DiveOctopusLogo()
            Spacer()
            Label("SNORKELING", systemImage: "figure.pool.swim")
                .font(.caption.bold())
                .foregroundStyle(DiveUI.green)
            Spacer()
            Text(exploration.snorkelingState.rawValue)
                .font(.caption2.bold())
                .foregroundStyle(exploration.snorkelingState == .returnMode ? DiveUI.yellow : DiveUI.green)
        }
    }

    private var runtimePanel: some View {
        DivePanel(stroke: DiveUI.green) {
            HStack {
                DiveMetric("RUN", value: Formatters.time(exploration.runtimeSeconds), color: DiveUI.green)
                Divider().background(DiveUI.subtleStroke)
                DiveMetric("DIST", value: String(format: "%.0f", exploration.distanceMeters), unit: "m", color: DiveUI.blue)
                Divider().background(DiveUI.subtleStroke)
                DiveMetric("AVG", value: String(format: "%.1f", exploration.averageSpeedKnots), unit: "kt", color: DiveUI.yellow)
            }
        }
    }

    private var navigationPanel: some View {
        DivePanel(stroke: DiveUI.blue) {
            VStack(spacing: 8) {
                Image(systemName: "location.north.fill")
                    .font(.system(size: 54, weight: .black))
                    .foregroundStyle(DiveUI.blue)
                    .rotationEffect(.degrees(bearingDelta))
                Text(exploration.activeWaypoint.name.uppercased())
                    .font(.headline.bold())
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                HStack {
                    DiveMetric("HEAD", value: String(format: "%.0f", compass.headingDegrees), unit: "°", color: .white)
                    DiveMetric("TARGET", value: String(format: "%.0f", exploration.activeWaypoint.targetBearing), unit: "°", color: DiveUI.green)
                    DiveMetric("DELTA", value: String(format: "%+.0f", bearingDelta), unit: "°", color: abs(bearingDelta) < 12 ? DiveUI.green : DiveUI.yellow)
                }
                HStack {
                    Label(exploration.gpsStatus, systemImage: "location")
                    Spacer()
                    Text("\(Int(exploration.activeWaypoint.distanceMeters)) m")
                }
                .font(.caption2.bold())
                .foregroundStyle(DiveUI.secondaryText)
            }
        }
    }

    private var markerPanel: some View {
        DivePanel(stroke: DiveUI.yellow) {
            VStack(spacing: 8) {
                HStack {
                    Text("GPS MARKER")
                        .font(.caption.bold())
                        .foregroundStyle(DiveUI.yellow)
                    Spacer()
                    Text("\(exploration.markers.count)")
                        .font(.caption.bold())
                        .foregroundStyle(.white)
                }
                Picker("Marker", selection: $exploration.currentMarkerCategory) {
                    ForEach(GPSMarkerCategory.allCases) { category in
                        Label(category.rawValue, systemImage: category.symbol).tag(category)
                    }
                }
                .labelsHidden()
                DiveCommandButton("SAVE", systemImage: "mappin.and.ellipse", color: DiveUI.yellow) {
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
        DivePanel(stroke: exploration.entryDistanceMeters > 300 ? DiveUI.red : DiveUI.green) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("RETURN TO ENTRY")
                        .font(.caption2.bold())
                        .foregroundStyle(DiveUI.secondaryText)
                    Text("\(Int(exploration.entryDistanceMeters)) m")
                        .font(.title3.bold())
                        .foregroundStyle(exploration.entryDistanceMeters > 300 ? DiveUI.red : DiveUI.green)
                }
                Spacer()
                Image(systemName: "arrow.uturn.backward.circle.fill")
                    .font(.title2)
                    .foregroundStyle(DiveUI.yellow)
            }
        }
    }

    private var controls: some View {
        HStack(spacing: 6) {
            DiveCommandButton("START", systemImage: "play.fill", color: DiveUI.green) { exploration.startSnorkeling() }
            DiveCommandButton("NAV", systemImage: "location.north.fill", color: DiveUI.blue) { exploration.startNavigation() }
            DiveCommandButton("ENTRY", systemImage: "arrow.uturn.backward", color: DiveUI.yellow) { exploration.startReturnMode() }
        }
    }
}
