import SwiftUI

struct ExploreView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                DIRBackground()
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 18) {
                        header
                        mapPreview
                        waypointCards
                        routeOverview
                        snorkelingPresentation
                        apneaAnalyticsPlaceholders
                        syncExportStatus
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 10)
                    .padding(.bottom, 24)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 7) {
            Text("Explore")
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            Text("Marine route concepts, waypoint review and apnea/snorkeling presentation")
                .font(.callout)
                .foregroundStyle(DIRTheme.muted)
        }
    }

    private var mapPreview: some View {
        DIRCard("MAP PREVIEW", icon: "map", accent: DIRTheme.cyan) {
            // TODO: Replace this static visual placeholder with a map engine only after map scope is approved.
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.0, green: 0.06, blue: 0.08),
                                Color(red: 0.0, green: 0.015, blue: 0.025)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(gridOverlay)

                routeLine

                mapPin(x: -112, y: 44, label: "ENTRY", color: DIRTheme.green)
                mapPin(x: -42, y: 4, label: "REEF", color: DIRTheme.cyan)
                mapPin(x: 54, y: -24, label: "WRECK", color: DIRTheme.yellow)
                mapPin(x: 122, y: -58, label: "EXIT", color: DIRTheme.orange)

                VStack {
                    HStack {
                        statusBadge("OFFLINE", color: DIRTheme.green)
                        statusBadge("OSM", color: DIRTheme.cyan)
                        Spacer()
                        statusBadge("UI ONLY", color: DIRTheme.yellow)
                    }
                    Spacer()
                    HStack {
                        Image(systemName: "location.north.fill")
                            .font(.title2.weight(.bold))
                            .foregroundStyle(DIRTheme.cyan)
                            .rotationEffect(.degrees(38))
                        VStack(alignment: .leading, spacing: 2) {
                            Text("ROUTE A")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(.white)
                            Text("4 waypoint | 820 m")
                                .font(.caption2)
                                .foregroundStyle(DIRTheme.muted)
                        }
                        Spacer()
                    }
                    .padding(10)
                    .background(RoundedRectangle(cornerRadius: 10).fill(.black.opacity(0.34)))
                }
                .padding(12)
            }
            .frame(height: 260)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    private var waypointCards: some View {
        VStack(alignment: .leading, spacing: 10) {
            DIRSectionHeader(title: "Waypoint hierarchy", subtitle: "Visual-only route list with marine exploration priority")
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    waypointCard("Entry", "0 m", "Start point", DIRTheme.green, "flag.fill")
                    waypointCard("Reef Nord", "280 m", "Marine layer", DIRTheme.cyan, "water.waves")
                    waypointCard("Relitto", "620 m", "Reference", DIRTheme.yellow, "scope")
                    waypointCard("Exit", "820 m", "Return bearing", DIRTheme.orange, "arrow.uturn.backward.circle")
                }
                .padding(.vertical, 2)
            }
        }
    }

    private var routeOverview: some View {
        DIRCard("ROUTE OVERVIEW", icon: "map", accent: DIRTheme.cyan) {
            // TODO: Keep static until real route calculations are explicitly implemented.
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    DIRMetricTile(title: "Bearing", value: "038", unit: "deg", color: DIRTheme.cyan, icon: "location.north")
                    Divider().overlay(DIRTheme.hairline)
                    DIRMetricTile(title: "Deviation", value: "+06", unit: "deg", color: DIRTheme.green, icon: "arrow.left.and.right")
                    Divider().overlay(DIRTheme.hairline)
                    DIRMetricTile(title: "Return", value: "214", unit: "deg", color: DIRTheme.yellow, icon: "arrow.uturn.backward")
                }
                Divider().overlay(DIRTheme.hairline)
                HStack(spacing: 0) {
                    DIRMetricTile(title: "Entry", value: "SET", color: DIRTheme.green)
                    Divider().overlay(DIRTheme.hairline)
                    DIRMetricTile(title: "Exit", value: "READY", color: DIRTheme.cyan)
                    Divider().overlay(DIRTheme.hairline)
                    DIRMetricTile(title: "Drift", value: "LOW", color: DIRTheme.green)
                }
            }
        }
    }

    private var snorkelingPresentation: some View {
        DIRCard("SNORKELING UX", icon: "figure.pool.swim", accent: DIRTheme.green) {
            // TODO: Visual presentation only; no snorkeling engine, GPS route or sync is implemented here.
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    progressRing(title: "Route", value: "68%", color: DIRTheme.cyan)
                    VStack(alignment: .leading, spacing: 9) {
                        infoRow("Active leg", "Reef Nord -> Relitto", DIRTheme.cyan)
                        infoRow("Entry distance", "320 m", DIRTheme.yellow)
                        infoRow("Exit hierarchy", "ENTRY / SAFE / EXIT", DIRTheme.green)
                    }
                }
                HStack(spacing: 8) {
                    statusBadge("WAYPOINT FIRST", color: DIRTheme.cyan)
                    statusBadge("ENTRY VISIBLE", color: DIRTheme.green)
                    statusBadge("DRIFT CUE", color: DIRTheme.yellow)
                }
            }
        }
    }

    private var apneaAnalyticsPlaceholders: some View {
        DIRCard("APNEA ANALYTICS", icon: "lungs.fill", accent: DIRTheme.yellow) {
            // TODO: Static cards only; do not connect to readiness or fatigue analytics until approved.
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    analyticsTile("Readiness", "--%", DIRTheme.yellow, "bolt.heart")
                    analyticsTile("Recovery", "2.4x", DIRTheme.green, "timer")
                    analyticsTile("Fatigue", "N/A", DIRTheme.red, "waveform.path.ecg")
                }
                DepthTrendPreview()
                    .frame(height: 110)
            }
        }
    }

    private var syncExportStatus: some View {
        HStack(spacing: 12) {
            statusCard("SYNC STATUS", "Prepared UI", "applewatch", DIRTheme.cyan)
            statusCard("EXPORT STATUS", "Placeholder", "square.and.arrow.up", DIRTheme.yellow)
        }
    }

    private var gridOverlay: some View {
        Canvas { context, size in
            let color = Color.white.opacity(0.06)
            for x in stride(from: 0.0, through: size.width, by: 34) {
                var path = Path()
                path.move(to: CGPoint(x: x, y: 0))
                path.addLine(to: CGPoint(x: x, y: size.height))
                context.stroke(path, with: .color(color), lineWidth: 1)
            }
            for y in stride(from: 0.0, through: size.height, by: 34) {
                var path = Path()
                path.move(to: CGPoint(x: 0, y: y))
                path.addLine(to: CGPoint(x: size.width, y: y))
                context.stroke(path, with: .color(color), lineWidth: 1)
            }
        }
    }

    private var routeLine: some View {
        Path { path in
            path.move(to: CGPoint(x: 36, y: 182))
            path.addCurve(to: CGPoint(x: 118, y: 126), control1: CGPoint(x: 58, y: 158), control2: CGPoint(x: 82, y: 142))
            path.addCurve(to: CGPoint(x: 214, y: 94), control1: CGPoint(x: 150, y: 110), control2: CGPoint(x: 182, y: 108))
            path.addCurve(to: CGPoint(x: 282, y: 60), control1: CGPoint(x: 242, y: 82), control2: CGPoint(x: 258, y: 70))
        }
        .stroke(DIRTheme.cyan, style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round))
        .shadow(color: DIRTheme.cyan.opacity(0.45), radius: 10)
    }

    private func mapPin(x: CGFloat, y: CGFloat, label: String, color: Color) -> some View {
        VStack(spacing: 5) {
            ZStack {
                Circle().fill(color.opacity(0.18))
                Circle().stroke(color, lineWidth: 2)
                Circle().fill(color).frame(width: 7, height: 7)
            }
            .frame(width: 24, height: 24)
            Text(label)
                .font(.system(size: 9, weight: .bold, design: .rounded))
                .foregroundStyle(color)
        }
        .offset(x: x, y: y)
    }

    private func waypointCard(_ title: String, _ distance: String, _ subtitle: String, _ color: Color, _ icon: String) -> some View {
        VStack(alignment: .leading, spacing: 9) {
            Image(systemName: icon)
                .font(.title3.weight(.bold))
                .foregroundStyle(color)
            Text(title)
                .font(.callout.weight(.semibold))
                .foregroundStyle(.white)
            Text(distance)
                .font(.title3.monospacedDigit().weight(.bold))
                .foregroundStyle(color)
            Text(subtitle)
                .font(.caption)
                .foregroundStyle(DIRTheme.muted)
        }
        .frame(width: 150, alignment: .leading)
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: DIRTheme.cardRadius)
                .fill(DIRTheme.surface.opacity(0.82))
                .overlay(RoundedRectangle(cornerRadius: DIRTheme.cardRadius).stroke(color.opacity(0.42), lineWidth: 1))
        )
    }

    private func progressRing(title: String, value: String, color: Color) -> some View {
        ZStack {
            Circle().stroke(DIRTheme.hairline, lineWidth: 10)
            Circle()
                .trim(from: 0, to: 0.68)
                .stroke(color, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                .rotationEffect(.degrees(-90))
            VStack(spacing: 2) {
                Text(value)
                    .font(.title2.monospacedDigit().weight(.bold))
                    .foregroundStyle(.white)
                Text(title.uppercased())
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(color)
            }
        }
        .frame(width: 112, height: 112)
    }

    private func infoRow(_ title: String, _ value: String, _ color: Color) -> some View {
        HStack {
            Text(title)
                .foregroundStyle(DIRTheme.muted)
            Spacer()
            Text(value)
                .foregroundStyle(color)
                .fontWeight(.semibold)
        }
        .font(.caption)
    }

    private func analyticsTile(_ title: String, _ value: String, _ color: Color, _ icon: String) -> some View {
        VStack(spacing: 7) {
            Image(systemName: icon)
                .foregroundStyle(color)
            Text(value)
                .font(.title3.monospacedDigit().weight(.bold))
                .foregroundStyle(.white)
            Text(title)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(DIRTheme.muted)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(RoundedRectangle(cornerRadius: 8).fill(DIRTheme.surface2.opacity(0.62)))
    }

    private func statusCard(_ title: String, _ value: String, _ icon: String, _ color: Color) -> some View {
        DIRCard(accent: color) {
            VStack(alignment: .leading, spacing: 8) {
                Image(systemName: icon)
                    .font(.title2.weight(.bold))
                    .foregroundStyle(color)
                Text(title)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(DIRTheme.muted)
                Text(value)
                    .font(.callout.weight(.semibold))
                    .foregroundStyle(.white)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func statusBadge(_ text: String, color: Color) -> some View {
        Text(text)
            .font(.caption2.weight(.bold))
            .foregroundStyle(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(Capsule().fill(color.opacity(0.12)).overlay(Capsule().stroke(color.opacity(0.45), lineWidth: 1)))
    }
}

private struct DepthTrendPreview: View {
    var body: some View {
        Canvas { context, size in
            let gridColor = Color.white.opacity(0.08)
            for y in stride(from: 0.0, through: size.height, by: 28) {
                var grid = Path()
                grid.move(to: CGPoint(x: 0, y: y))
                grid.addLine(to: CGPoint(x: size.width, y: y))
                context.stroke(grid, with: .color(gridColor), lineWidth: 1)
            }

            var path = Path()
            path.move(to: CGPoint(x: 0, y: 18))
            path.addCurve(to: CGPoint(x: size.width * 0.24, y: size.height * 0.82), control1: CGPoint(x: 28, y: 24), control2: CGPoint(x: 42, y: 82))
            path.addLine(to: CGPoint(x: size.width * 0.48, y: size.height * 0.78))
            path.addCurve(to: CGPoint(x: size.width * 0.76, y: size.height * 0.26), control1: CGPoint(x: size.width * 0.56, y: size.height * 0.82), control2: CGPoint(x: size.width * 0.64, y: size.height * 0.28))
            path.addLine(to: CGPoint(x: size.width, y: size.height * 0.18))
            context.stroke(path, with: .color(DIRTheme.cyan), style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
        }
        .background(RoundedRectangle(cornerRadius: 8).fill(.black.opacity(0.22)))
    }
}
