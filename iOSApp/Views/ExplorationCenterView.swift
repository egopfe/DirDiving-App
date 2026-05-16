import SwiftUI
import Charts

struct ExplorationCenterView: View {
    @EnvironmentObject private var store: ExplorationPlanningStore

    var body: some View {
        NavigationStack {
            ZStack {
                DIRBackground()
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {
                        header
                        dashboardHero
                        mapCard
                        conceptStatusStrip
                        ExperimentalFutureConceptsView()
                        waypointPlanner
                        routeCard
                        apneaAnalytics
                        syncAndSettings
                        exportCard
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 10)
                    .padding(.bottom, 22)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline) {
                Text("Explore Lab")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                Spacer()
                mapBadge("EXPERIMENTAL", color: DIRTheme.yellow)
            }
            Text("Premium experimental dashboard for maps, routes, overlays and apnea concepts")
                .font(.callout)
                .foregroundStyle(DIRTheme.muted)
            HStack(spacing: 8) {
                mapBadge("UI MOCKUPS", color: DIRTheme.cyan)
                mapBadge("NO BACKEND", color: DIRTheme.green)
                mapBadge("TODO ONLY", color: DIRTheme.orange)
            }
        }
    }

    private var dashboardHero: some View {
        DIRCard("UNDERWATER EXPLORATION CONSOLE", icon: "sparkles", accent: DIRTheme.cyan) {
            // TODO: Visual-only experimental dashboard. Do not connect AI, sync, networking or analytics engines here.
            HStack(spacing: 12) {
                heroMetric("Overlays", "7", DIRTheme.cyan, "square.3.layers.3d")
                heroMetric("Route IQ", "--", DIRTheme.yellow, "point.topleft.down.curvedto.point.bottomright.up")
                heroMetric("Readiness", "--%", DIRTheme.green, "bolt.heart")
            }
        }
    }

    private var mapCard: some View {
        DIRCard("Snorkeling Map", icon: "map", accent: DIRTheme.cyan) {
            ZStack {
                RoundedRectangle(cornerRadius: DIRTheme.cardRadius)
                    .fill(LinearGradient(colors: [Color(red: 0.0, green: 0.14, blue: 0.18), Color.black], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(height: 230)
                    .overlay(gridOverlay)
                    .overlay(mapBathymetryOverlay)
                    .overlay(mapHotspotOverlay)
                routeLine
                ForEach(store.route.waypoints) { waypoint in
                    waypointPin(waypoint)
                }
                VStack {
                    HStack {
                        mapBadge("OSM", color: DIRTheme.cyan)
                        mapBadge("OpenSeaMap", color: DIRTheme.green)
                        Spacer()
                        mapBadge("Offline", color: store.route.offlineCacheReady ? DIRTheme.green : DIRTheme.yellow)
                    }
                    Spacer()
                    HStack {
                        Label("Heatmap \(Int(store.heatmapIntensity * 100))%", systemImage: "flame")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(DIRTheme.orange)
                        Spacer()
                        Label("\(Int(store.routeDistanceMeters)) m", systemImage: "point.topleft.down.curvedto.point.bottomright.up")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.white)
                    }
                }
                .padding(12)
            }
            .clipShape(RoundedRectangle(cornerRadius: DIRTheme.cardRadius))
            .overlay(RoundedRectangle(cornerRadius: DIRTheme.cardRadius).stroke(DIRTheme.cyan.opacity(0.28), lineWidth: 1))
        }
    }

    private var conceptStatusStrip: some View {
        HStack(spacing: 12) {
            conceptStatus("Marine", "Layers", DIRTheme.green, "leaf.fill")
            conceptStatus("Bathymetry", "Mock", DIRTheme.cyan, "chart.xyaxis.line")
            conceptStatus("Community", "Soon", DIRTheme.yellow, "person.3.fill")
        }
    }

    private var waypointPlanner: some View {
        DIRCard("Waypoint Planning", icon: "mappin.and.ellipse", accent: DIRTheme.cyan) {
            VStack(spacing: 10) {
                HStack {
                    Button {
                        store.addWaypointFromTap()
                    } label: {
                        Label("Tap mappa", systemImage: "hand.tap")
                            .font(.callout.weight(.semibold))
                            .foregroundStyle(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(RoundedRectangle(cornerRadius: 8).fill(DIRTheme.cyan))
                    }
                    .buttonStyle(.plain)
                    Button {
                        store.syncToWatch()
                    } label: {
                        Image(systemName: "applewatch.radiowaves.left.and.right")
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(DIRTheme.cyan)
                            .frame(width: 48, height: 44)
                            .background(RoundedRectangle(cornerRadius: 8).stroke(DIRTheme.cyan, lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                }
                ForEach(store.route.waypoints) { waypoint in
                    waypointRow(waypoint)
                }
            }
        }
    }

    private var routeCard: some View {
        DIRCard("Route Planning", icon: "point.topleft.down.curvedto.point.bottomright.up", accent: DIRTheme.green) {
            VStack(spacing: 12) {
                HStack {
                    DIRMetricTile(title: "Waypoint", value: "\(store.route.waypoints.count)", color: DIRTheme.cyan)
                    DIRMetricTile(title: "Distanza", value: "\(Int(store.routeDistanceMeters))", unit: "m", color: .white)
                    DIRMetricTile(title: "Cache", value: store.route.offlineCacheReady ? "ON" : "OFF", color: store.route.offlineCacheReady ? DIRTheme.green : DIRTheme.yellow)
                }
                Text("Workflow: iPhone route -> WatchConnectivity -> cache locale Watch -> disponibilita offline underwater.")
                    .font(.caption)
                    .foregroundStyle(DIRTheme.muted)
            }
        }
    }

    private var apneaAnalytics: some View {
        DIRCard("Apnea Analytics", icon: "lungs", accent: DIRTheme.yellow) {
            VStack(spacing: 12) {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                    ForEach(store.apneaSummaries) { item in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(item.title).font(.caption).foregroundStyle(DIRTheme.muted)
                            Text(item.value).font(.title3.bold()).foregroundStyle(item.color)
                            Text(item.trend).font(.caption2).foregroundStyle(.white.opacity(0.72))
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(12)
                        .background(RoundedRectangle(cornerRadius: 8).fill(DIRTheme.surface2.opacity(0.65)))
                    }
                }
                Chart(store.apneaDurationPoints) { point in
                    LineMark(x: .value("Dive", point.label), y: .value("Seconds", point.value))
                        .foregroundStyle(DIRTheme.cyan)
                    AreaMark(x: .value("Dive", point.label), y: .value("Seconds", point.value))
                        .foregroundStyle(DIRTheme.cyan.opacity(0.16))
                }
                .frame(height: 150)
                .chartXAxis { AxisMarks(values: .automatic) { AxisValueLabel().foregroundStyle(DIRTheme.muted) } }
                .chartYAxis { AxisMarks(values: .automatic) { AxisGridLine().foregroundStyle(DIRTheme.hairline); AxisValueLabel().foregroundStyle(DIRTheme.muted) } }
            }
        }
    }

    private var syncAndSettings: some View {
        DIRCard("Sync & Warning Settings", icon: "applewatch", accent: DIRTheme.green) {
            VStack(spacing: 10) {
                settingRow("Apnea warning", value: "\(Int(store.settings.apneaDurationWarningSeconds)) s")
                settingRow("Recovery ratio", value: String(format: "%.1fx", store.settings.recoveryRatio))
                settingRow("Drift threshold", value: "\(Int(store.settings.driftThresholdMeters)) m")
                settingRow("Auto-switch", value: "\(Int(store.settings.waypointAutoSwitchMeters)) m")
                Divider().overlay(DIRTheme.hairline)
                Text(store.syncStatus)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(DIRTheme.green)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    private var exportCard: some View {
        DIRCard("Export", icon: "square.and.arrow.up", accent: DIRTheme.cyan) {
            VStack(spacing: 10) {
                HStack {
                    exportButton("GPX", action: store.exportGPX)
                    exportButton("CSV", action: store.exportCSV)
                }
                Text(store.exportStatus)
                    .font(.caption)
                    .foregroundStyle(DIRTheme.muted)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    private var gridOverlay: some View {
        Canvas { context, size in
            let line = Path { path in
                for idx in 1..<5 {
                    let x = size.width * CGFloat(idx) / 5
                    path.move(to: CGPoint(x: x, y: 0))
                    path.addLine(to: CGPoint(x: x, y: size.height))
                    let y = size.height * CGFloat(idx) / 5
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addLine(to: CGPoint(x: size.width, y: y))
                }
            }
            context.stroke(line, with: .color(DIRTheme.hairline), lineWidth: 1)
        }
    }

    private var routeLine: some View {
        let path = Path { path in
            let points = normalizedRoutePoints()
            guard let first = points.first else { return }
            path.move(to: first)
            for point in points.dropFirst() { path.addLine(to: point) }
        }

        return ZStack {
            path
                .stroke(DIRTheme.cyan.opacity(0.18), style: StrokeStyle(lineWidth: 11, lineCap: .round, lineJoin: .round))
            path
                .stroke(DIRTheme.cyan, style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
                .shadow(color: DIRTheme.cyan.opacity(0.42), radius: 10)
        }
        .frame(height: 230)
        .padding(.horizontal, 24)
    }

    private var mapBathymetryOverlay: some View {
        ZStack {
            ForEach(0..<5) { index in
                RoundedRectangle(cornerRadius: CGFloat(34 + index * 10))
                    .stroke(DIRTheme.cyan.opacity(0.055), lineWidth: 1)
                    .frame(width: CGFloat(112 + index * 48), height: CGFloat(54 + index * 26))
                    .rotationEffect(.degrees(Double(index * 7 - 10)))
                    .offset(x: CGFloat(index * 18 - 28), y: CGFloat(index * -7 + 12))
            }
        }
    }

    private var mapHotspotOverlay: some View {
        ZStack {
            Circle()
                .fill(DIRTheme.orange.opacity(0.16))
                .frame(width: 90, height: 90)
                .blur(radius: 12)
                .offset(x: -82, y: 34)
            Circle()
                .fill(DIRTheme.green.opacity(0.12))
                .frame(width: 120, height: 120)
                .blur(radius: 16)
                .offset(x: 72, y: -28)
        }
        .blendMode(.plusLighter)
    }

    private func waypointPin(_ waypoint: ExplorationWaypoint) -> some View {
        let points = normalizedRoutePoints()
        let index = max(0, min(waypoint.routeOrder - 1, points.count - 1))
        let point = points.isEmpty ? CGPoint(x: 40, y: 40) : points[index]
        return Image(systemName: waypoint.category.icon)
            .font(.caption.bold())
            .foregroundStyle(waypoint.category.color)
            .frame(width: 30, height: 30)
            .background(Circle().fill(Color.black.opacity(0.72)).overlay(Circle().stroke(waypoint.category.color, lineWidth: 1)))
            .position(point)
            .frame(height: 230)
            .padding(.horizontal, 24)
    }

    private func waypointRow(_ waypoint: ExplorationWaypoint) -> some View {
        HStack(spacing: 12) {
            Text("\(waypoint.routeOrder)")
                .font(.caption.bold())
                .foregroundStyle(.black)
                .frame(width: 24, height: 24)
                .background(Circle().fill(waypoint.category.color))
            VStack(alignment: .leading, spacing: 2) {
                Text(waypoint.name).font(.callout.weight(.semibold)).foregroundStyle(.white)
                Text("\(waypoint.category.rawValue) / \(String(format: "%.4f", waypoint.latitude)), \(String(format: "%.4f", waypoint.longitude))")
                    .font(.caption2)
                    .foregroundStyle(DIRTheme.muted)
            }
            Spacer()
            Button { store.moveWaypointUp(waypoint) } label: { Image(systemName: "chevron.up") }
                .buttonStyle(.plain)
                .foregroundStyle(DIRTheme.cyan)
            Button { store.moveWaypointDown(waypoint) } label: { Image(systemName: "chevron.down") }
                .buttonStyle(.plain)
                .foregroundStyle(DIRTheme.cyan)
        }
        .padding(10)
        .background(RoundedRectangle(cornerRadius: 8).fill(DIRTheme.surface2.opacity(0.55)))
    }

    private func heroMetric(_ title: String, _ value: String, _ color: Color, _ icon: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.headline.weight(.bold))
                .foregroundStyle(color)
            Text(value)
                .font(.title2.monospacedDigit().weight(.bold))
                .foregroundStyle(.white)
            Text(title.uppercased())
                .font(.caption2.weight(.bold))
                .foregroundStyle(DIRTheme.muted)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(RoundedRectangle(cornerRadius: DIRTheme.compactRadius).fill(color.opacity(0.11)).overlay(RoundedRectangle(cornerRadius: DIRTheme.compactRadius).stroke(color.opacity(0.34), lineWidth: 1)))
    }

    private func conceptStatus(_ title: String, _ value: String, _ color: Color, _ icon: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.caption.weight(.bold))
                .foregroundStyle(color)
            VStack(alignment: .leading, spacing: 2) {
                Text(title.uppercased())
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(DIRTheme.muted)
                Text(value)
                    .font(.callout.weight(.bold))
                    .foregroundStyle(.white)
            }
            Spacer(minLength: 0)
        }
        .padding(12)
        .frame(maxWidth: .infinity)
        .background(RoundedRectangle(cornerRadius: DIRTheme.cardRadius).fill(DIRTheme.surface.opacity(0.74)).overlay(RoundedRectangle(cornerRadius: DIRTheme.cardRadius).stroke(color.opacity(0.34), lineWidth: 1)))
    }

    private func settingRow(_ title: String, value: String) -> some View {
        HStack {
            Text(title).font(.callout).foregroundStyle(.white)
            Spacer()
            Text(value).font(.callout.monospacedDigit()).foregroundStyle(DIRTheme.cyan)
        }
    }

    private func exportButton(_ title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.callout.weight(.semibold))
                .foregroundStyle(DIRTheme.cyan)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(RoundedRectangle(cornerRadius: 8).stroke(DIRTheme.cyan, lineWidth: 1))
        }
        .buttonStyle(.plain)
    }

    private func mapBadge(_ text: String, color: Color) -> some View {
        Text(text)
            .font(.caption2.weight(.bold))
            .foregroundStyle(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(Capsule().fill(Color.black.opacity(0.6)).overlay(Capsule().stroke(color.opacity(0.7), lineWidth: 1)))
    }

    private func normalizedRoutePoints() -> [CGPoint] {
        let count = max(store.route.waypoints.count, 1)
        guard count > 1 else { return [CGPoint(x: 42, y: 178)] }

        return (0..<count).map { index in
            let progress = Double(index) / Double(count - 1)
            let x = 42 + 278 * progress
            let y = 168 - 82 * sin(progress * .pi) + 28 * sin(progress * .pi * 2)
            return CGPoint(x: x, y: y)
        }
    }
}
