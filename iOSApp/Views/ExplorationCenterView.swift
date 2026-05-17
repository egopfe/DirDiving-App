import SwiftUI
import Charts

struct ExplorationCenterView: View {
    @EnvironmentObject private var store: ExplorationPlanningStore
    @State private var selectedApneaReviewTab: ApneaReviewTab = .summary

    var body: some View {
        NavigationStack {
            ZStack {
                DIRBackground()
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {
                        header
                        dashboardHero
                        labSection("Snorkeling Review", subtitle: "Mock route/map review until Watch session sync exists")
                        mapCard
                        conceptStatusStrip
                        ExperimentalFutureConceptsView()
                        labSection("Waypoint Planning", subtitle: "Configured on iPhone; Watch sync is explicitly TODO")
                        waypointPlanner
                        routeCard
                        labSection("POI / Osservazioni", subtitle: "Reachable enrichment surface, media/save still TODO")
                        poiEnrichmentCard
                        labSection("Apnea Review", subtitle: "Interactive review tabs with mock-data labels")
                        apneaCompanionReview
                        apneaAnalytics
                        labSection("Experimental Settings", subtitle: "Editable local settings with explicit sync queue status")
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
                        mapBadge("SCHEMATIC", color: DIRTheme.yellow)
                        mapBadge("NO TILES", color: DIRTheme.orange)
                        Spacer()
                        mapBadge(store.route.offlineCacheReady ? "Offline" : "MBTiles TODO", color: store.route.offlineCacheReady ? DIRTheme.green : DIRTheme.yellow)
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
            Text("TODO map engine: preparare MapLibre/OpenStreetMap/OpenSeaMap compatibile, MBTiles offline, overlay GEBCO/EMODnet e policy anti-abuso tile pubbliche.")
                .font(.caption2.weight(.semibold))
                .foregroundStyle(DIRTheme.yellow)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var conceptStatusStrip: some View {
        HStack(spacing: 12) {
            conceptStatus("Marine", "Layers", DIRTheme.green, "leaf.fill")
            conceptStatus("Bathymetry", "Mock", DIRTheme.cyan, "chart.xyaxis.line")
            conceptStatus("Community", "Soon", DIRTheme.yellow, "person.3.fill")
        }
    }

    private var poiEnrichmentCard: some View {
        DIRCard("POI / Osservazioni", icon: "mappin.circle", accent: DIRTheme.green) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 10) {
                    mapBadge("DA WATCH", color: DIRTheme.cyan)
                    mapBadge("ENRICH TODO", color: DIRTheme.yellow)
                    mapBadge("NO MEDIA SAVE", color: DIRTheme.orange)
                }
                Text("Superficie companion per arricchire i MARCATORI creati su Apple Watch. Il sync POI reale non e ancora implementato.")
                    .font(.footnote)
                    .foregroundStyle(DIRTheme.muted)
                    .fixedSize(horizontal: false, vertical: true)
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                    poiTodoTile("Foto", icon: "photo", note: "MOCK - no upload") {
                        store.requestMediaAttachment("Foto")
                    }
                    poiTodoTile("Video", icon: "video", note: "MOCK - no upload") {
                        store.requestMediaAttachment("Video")
                    }
                    poiTodoTile("Commenti", icon: "text.bubble", note: "MOCK - no save") {
                        store.requestMediaAttachment("Commenti")
                    }
                    poiTodoTile("Categoria", icon: "tag", note: "MOCK selector") {
                        store.requestMediaAttachment("Categoria")
                    }
                    poiTodoTile("Tag", icon: "number", note: "MOCK tags") {
                        store.requestMediaAttachment("Tag")
                    }
                    poiTodoTile("Specie", icon: "fish", note: "MOCK note") {
                        store.requestMediaAttachment("Specie")
                    }
                }
                Text(store.mediaAttachmentStatus)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(DIRTheme.yellow)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
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
                Button {
                    store.prepareWatchSyncManifest()
                } label: {
                        Label("Prepara manifest mock Watch", systemImage: "doc.badge.gearshape")
                        .font(.callout.weight(.semibold))
                        .foregroundStyle(DIRTheme.cyan)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 11)
                        .background(RoundedRectangle(cornerRadius: 9).stroke(DIRTheme.cyan, lineWidth: 1))
                }
                .buttonStyle(.plain)
                Text("MOCK: prepara solo contratto dati locale. Nessun invio WatchConnectivity reale.")
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

    private var apneaCompanionReview: some View {
        DIRCard("Apnea Review", icon: "waveform.path.ecg", accent: DIRTheme.cyan) {
            VStack(spacing: 0) {
                HStack {
                    Button {
                        selectedApneaReviewTab = .summary
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.headline.weight(.semibold))
                            .foregroundStyle(DIRTheme.cyan)
                    }
                    .buttonStyle(.plain)

                    Spacer()

                    Text("Apnea • MOCK")
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(.white)

                    Spacer()

                    mapBadge("MOCK DATA", color: DIRTheme.yellow)
                }
                .padding(.horizontal, 10)
                .padding(.top, 6)
                .padding(.bottom, 12)

                HStack(spacing: 0) {
                    ForEach(ApneaReviewTab.allCases) { tab in
                        Button {
                            selectedApneaReviewTab = tab
                        } label: {
                            reviewTab(tab.title, isActive: selectedApneaReviewTab == tab)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 4)
                .padding(.bottom, 12)

                switch selectedApneaReviewTab {
                case .summary:
                    apneaReviewMap
                    HStack(spacing: 0) {
                        reviewMetric("22.4", unit: "m", label: "Prof. max")
                        Rectangle().fill(DIRTheme.hairline).frame(width: 1, height: 44)
                        reviewMetric("1:55", unit: nil, label: "Tempo")
                        Rectangle().fill(DIRTheme.hairline).frame(width: 1, height: 44)
                        reviewMetric("10", unit: "°C", label: "Temp. acqua")
                    }
                    .padding(.top, 14)
                case .graph:
                    Chart(store.apneaDurationPoints) { point in
                        LineMark(x: .value("Dive", point.label), y: .value("Seconds", point.value))
                            .foregroundStyle(DIRTheme.cyan)
                        AreaMark(x: .value("Dive", point.label), y: .value("Seconds", point.value))
                            .foregroundStyle(DIRTheme.cyan.opacity(0.16))
                    }
                    .frame(height: 210)
                    .chartXAxis { AxisMarks(values: .automatic) { AxisValueLabel().foregroundStyle(DIRTheme.muted) } }
                    .chartYAxis { AxisMarks(values: .automatic) { AxisGridLine().foregroundStyle(DIRTheme.hairline); AxisValueLabel().foregroundStyle(DIRTheme.muted) } }
                case .details:
                    VStack(spacing: 10) {
                        settingRow("Origine dati", value: "Mock locale")
                        settingRow("Sync Watch", value: "TODO")
                        settingRow("Campioni profondità", value: "Non sincronizzati")
                        settingRow("HR / Temp", value: "Placeholder")
                    }
                    .padding(12)
                    .background(RoundedRectangle(cornerRadius: 10).fill(DIRTheme.surface2.opacity(0.56)))
                }
                Text("TODO iOS companion experimental: sostituire questi dati con record Apnea sincronizzati dal Watch.")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(DIRTheme.yellow)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 12)
            }
        }
    }

    private var apneaReviewMap: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 0)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.02, green: 0.18, blue: 0.24),
                            Color(red: 0.01, green: 0.06, blue: 0.09)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(apneaReviewWaterTexture)

            // TODO: Replace the static review path with synced Apnea GPS/profile data when available.
            ApneaCompanionRouteShape()
                .stroke(DIRTheme.cyan, style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
                .shadow(color: DIRTheme.cyan.opacity(0.55), radius: 8)
                .padding(32)

            ForEach(apneaReviewPoints.indices, id: \.self) { index in
                Circle()
                    .fill(Color(red: 0.0, green: 0.30, blue: 0.82))
                    .frame(width: 12, height: 12)
                    .overlay(Circle().stroke(DIRTheme.cyan, lineWidth: 2))
                    .position(apneaReviewPoints[index])
            }

            HStack {
                Spacer()
                VStack(spacing: 6) {
                    Image(systemName: "mappin.circle.fill")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(DIRTheme.cyan)
                    Text("entry")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(DIRTheme.muted)
                }
                .padding(14)
                .background(Circle().fill(Color.black.opacity(0.38)))
                .padding(.trailing, 28)
            }
        }
        .frame(height: 210)
        .clipShape(RoundedRectangle(cornerRadius: 2, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 2, style: .continuous).stroke(DIRTheme.cyan.opacity(0.18), lineWidth: 1))
    }

    private var apneaReviewWaterTexture: some View {
        ZStack {
            ForEach(0..<5) { index in
                Capsule()
                    .fill(DIRTheme.cyan.opacity(0.055))
                    .frame(width: CGFloat(170 + index * 42), height: 16)
                    .rotationEffect(.degrees(Double(-18 + index * 6)))
                    .offset(x: CGFloat(-95 + index * 34), y: CGFloat(-54 + index * 28))
                    .blur(radius: 8)
            }
        }
    }

    private var apneaReviewPoints: [CGPoint] {
        [
            CGPoint(x: 78, y: 150),
            CGPoint(x: 96, y: 78),
            CGPoint(x: 174, y: 66),
            CGPoint(x: 244, y: 88),
            CGPoint(x: 248, y: 156),
            CGPoint(x: 160, y: 160),
            CGPoint(x: 132, y: 116)
        ]
    }

    private func reviewTab(_ title: String, isActive: Bool) -> some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(isActive ? .white : DIRTheme.muted)
                .frame(maxWidth: .infinity)
            Rectangle()
                .fill(isActive ? DIRTheme.cyan : .clear)
                .frame(height: 3)
                .shadow(color: isActive ? DIRTheme.cyan.opacity(0.55) : .clear, radius: 4)
        }
    }

    private func reviewMetric(_ value: String, unit: String?, label: String) -> some View {
        VStack(spacing: 3) {
            HStack(alignment: .lastTextBaseline, spacing: 3) {
                Text(value)
                    .font(.system(size: 28, weight: .semibold, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(.white)
                if let unit {
                    Text(unit)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.white)
                }
            }
            Text(label)
                .font(.caption.weight(.semibold))
                .foregroundStyle(DIRTheme.muted)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity)
    }

    private var syncAndSettings: some View {
        DIRCard("Experimental Settings", icon: "applewatch", accent: DIRTheme.green) {
            VStack(spacing: 10) {
                adjustableSettingRow("Apnea warning", value: "\(Int(store.settings.apneaDurationWarningSeconds)) s", decrement: { store.adjustApneaWarning(by: -15) }, increment: { store.adjustApneaWarning(by: 15) })
                adjustableSettingRow("Recovery ratio", value: String(format: "%.1fx", store.settings.recoveryRatio), decrement: { store.adjustRecoveryRatio(by: -0.1) }, increment: { store.adjustRecoveryRatio(by: 0.1) })
                adjustableSettingRow("Drift threshold", value: "\(Int(store.settings.driftThresholdMeters)) m", decrement: { store.adjustDriftThreshold(by: -25) }, increment: { store.adjustDriftThreshold(by: 25) })
                adjustableSettingRow("Auto-switch", value: "\(Int(store.settings.waypointAutoSwitchMeters)) m", decrement: { store.adjustWaypointAutoSwitch(by: -5) }, increment: { store.adjustWaypointAutoSwitch(by: 5) })
                Text("Persistenza locale attiva. iPhone -> Watch settings sync resta TODO.")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(DIRTheme.yellow)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Divider().overlay(DIRTheme.hairline)
                syncBoundaryRow("Watch -> iPhone POI", value: "Envelope received only; merge/enrichment queue LAB")
                syncBoundaryRow("Watch -> iPhone Apnea", value: "Record envelope only; no sample profile")
                syncBoundaryRow("iPhone -> Watch route", value: "Local manifest queue")
                syncBoundaryRow("iPhone -> Watch settings", value: "Local settings payload queue")
                HStack(spacing: 10) {
                    DIRMetricTile(title: "Sync queue", value: "\(store.experimentalSyncQueueCount)", color: store.experimentalSyncQueueCount == 0 ? DIRTheme.green : DIRTheme.yellow)
                    Button {
                        store.acknowledgeExperimentalQueue()
                    } label: {
                        Text("REVISIONA CODA")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(DIRTheme.cyan)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(RoundedRectangle(cornerRadius: 8).stroke(DIRTheme.cyan, lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                }
                Text(store.syncQueueStatus)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(DIRTheme.yellow)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Button {
                    store.requestOfflineMapPreparation()
                } label: {
                    Label("Verifica offline map / MBTiles", systemImage: "map")
                        .font(.callout.weight(.semibold))
                        .foregroundStyle(DIRTheme.yellow)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 11)
                        .background(RoundedRectangle(cornerRadius: 9).stroke(DIRTheme.yellow, lineWidth: 1))
                }
                .buttonStyle(.plain)
                Text(store.syncStatus)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(DIRTheme.green)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(store.offlineMapStatus)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(DIRTheme.yellow)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    private var exportCard: some View {
        DIRCard("Export", icon: "square.and.arrow.up", accent: DIRTheme.cyan) {
            VStack(spacing: 10) {
                HStack {
                    exportButton("MOCK GPX", action: store.exportGPX)
                    exportButton("MOCK CSV", action: store.exportCSV)
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

    private func labSection(_ title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title.uppercased())
                .font(.caption.weight(.bold))
                .foregroundStyle(DIRTheme.cyan)
            Text(subtitle)
                .font(.caption)
                .foregroundStyle(DIRTheme.muted)
        }
        .padding(.top, 4)
    }

    private func poiTodoTile(_ title: String, icon: String, note: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 7) {
                Image(systemName: icon)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(DIRTheme.cyan)
                Text(title)
                    .font(.callout.weight(.semibold))
                    .foregroundStyle(.white)
                Text(note)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(DIRTheme.yellow)
                    .lineLimit(2)
                    .minimumScaleFactor(0.72)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            .background(RoundedRectangle(cornerRadius: 10).fill(DIRTheme.surface2.opacity(0.58)).overlay(RoundedRectangle(cornerRadius: 10).stroke(DIRTheme.cyan.opacity(0.24), lineWidth: 1)))
        }
        .buttonStyle(.plain)
    }

    private func settingRow(_ title: String, value: String) -> some View {
        HStack {
            Text(title).font(.callout).foregroundStyle(.white)
            Spacer()
            Text(value).font(.callout.monospacedDigit()).foregroundStyle(DIRTheme.cyan)
        }
    }

    private func adjustableSettingRow(_ title: String, value: String, decrement: @escaping () -> Void, increment: @escaping () -> Void) -> some View {
        HStack(spacing: 10) {
            Text(title).font(.callout).foregroundStyle(.white)
            Spacer()
            Text(value).font(.callout.monospacedDigit().weight(.semibold)).foregroundStyle(DIRTheme.cyan)
            Button(action: decrement) {
                Image(systemName: "minus")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(DIRTheme.cyan)
                    .frame(width: 30, height: 30)
                    .background(RoundedRectangle(cornerRadius: 8).stroke(DIRTheme.cyan.opacity(0.7), lineWidth: 1))
            }
            .buttonStyle(.plain)
            Button(action: increment) {
                Image(systemName: "plus")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(DIRTheme.cyan)
                    .frame(width: 30, height: 30)
                    .background(RoundedRectangle(cornerRadius: 8).stroke(DIRTheme.cyan.opacity(0.7), lineWidth: 1))
            }
            .buttonStyle(.plain)
        }
    }

    private func syncBoundaryRow(_ title: String, value: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "arrow.triangle.2.circlepath")
                .font(.caption.weight(.bold))
                .foregroundStyle(DIRTheme.cyan)
                .padding(.top, 2)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.white)
                Text(value)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(DIRTheme.yellow)
            }
            Spacer(minLength: 0)
        }
        .padding(10)
        .background(RoundedRectangle(cornerRadius: 9).fill(DIRTheme.surface2.opacity(0.46)))
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

private enum ApneaReviewTab: String, CaseIterable, Identifiable {
    case summary
    case graph
    case details

    var id: String { rawValue }

    var title: String {
        switch self {
        case .summary: return "Riepilogo"
        case .graph: return "Grafico"
        case .details: return "Dettagli"
        }
    }
}

private struct ApneaCompanionRouteShape: Shape {
    func path(in rect: CGRect) -> Path {
        let points: [CGPoint] = [
            CGPoint(x: rect.minX + rect.width * 0.07, y: rect.minY + rect.height * 0.72),
            CGPoint(x: rect.minX + rect.width * 0.16, y: rect.minY + rect.height * 0.25),
            CGPoint(x: rect.minX + rect.width * 0.47, y: rect.minY + rect.height * 0.17),
            CGPoint(x: rect.minX + rect.width * 0.84, y: rect.minY + rect.height * 0.38),
            CGPoint(x: rect.minX + rect.width * 0.88, y: rect.minY + rect.height * 0.76),
            CGPoint(x: rect.minX + rect.width * 0.46, y: rect.minY + rect.height * 0.80),
            CGPoint(x: rect.minX + rect.width * 0.34, y: rect.minY + rect.height * 0.54),
            CGPoint(x: rect.minX + rect.width * 0.07, y: rect.minY + rect.height * 0.72)
        ]

        var path = Path()
        guard let first = points.first else { return path }
        path.move(to: first)
        for point in points.dropFirst() {
            path.addLine(to: point)
        }
        return path
    }
}
