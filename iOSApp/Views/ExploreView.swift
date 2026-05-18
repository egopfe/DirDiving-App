import SwiftUI

struct ExploreView: View {
    @EnvironmentObject private var logStore: DiveLogStore

    var body: some View {
        NavigationStack {
            ZStack {
                DIRBackground()
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 18) {
                        header
                        if routeSummaries.isEmpty {
                            emptyRouteState
                        } else {
                            routeStatusStrip
                            waypointCards
                            routeOverview
                            syncExportStatus
                        }
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
            HStack(alignment: .firstTextBaseline) {
                Text("Route Review")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                Spacer()
                Text("MARINE")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(DIRTheme.cyan)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Capsule().fill(DIRTheme.cyan.opacity(0.12)).overlay(Capsule().stroke(DIRTheme.cyan.opacity(0.45), lineWidth: 1)))
            }
            Text("Route calcolate dai punti GPS entry/exit dei log importati o sincronizzati.")
                .font(.callout)
                .foregroundStyle(DIRTheme.muted)
            HStack(spacing: 8) {
                statusBadge("WAYPOINTS", color: DIRTheme.cyan)
                statusBadge("ROUTES", color: DIRTheme.green)
                statusBadge("GPS LOGS", color: DIRTheme.yellow)
            }
        }
    }

    private var routeStatusStrip: some View {
        let routes = routeSummaries
        return HStack(spacing: 12) {
            routeStatus("ROUTES", "\(routes.count)", DIRTheme.cyan, "point.topleft.down.curvedto.point.bottomright.up")
            routeStatus("DIST", Formatters.zero(totalDistance / 1000), DIRTheme.green, "ruler")
            routeStatus("LATEST", latestBearingText, DIRTheme.yellow, "location.north")
        }
    }

    private var waypointCards: some View {
        VStack(alignment: .leading, spacing: 10) {
            DIRSectionHeader(title: "Waypoint hierarchy", subtitle: "Entry/exit points from real logged GPS data")
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(routeSummaries) { route in
                        waypointCard(route.name, "\(Formatters.zero(route.distanceMeters)) m", route.startDate.formatted(.dateTime.day().month().hour().minute()), DIRTheme.cyan, "mappin.and.ellipse")
                    }
                }
                .padding(.vertical, 2)
            }
        }
    }

    private var routeOverview: some View {
        DIRCard("ROUTE REVIEW", icon: "point.topleft.down.curvedto.point.bottomright.up", accent: DIRTheme.cyan) {
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    DIRMetricTile(title: "Bearing", value: latestBearingText, unit: nil, color: DIRTheme.cyan, icon: "location.north")
                    Divider().overlay(DIRTheme.hairline)
                    DIRMetricTile(title: "Distance", value: Formatters.zero(totalDistance), unit: "m", color: DIRTheme.green, icon: "arrow.left.and.right")
                    Divider().overlay(DIRTheme.hairline)
                    DIRMetricTile(title: "Fix", value: "\(routeSummaries.count)", color: DIRTheme.yellow, icon: "flag")
                }
                Divider().overlay(DIRTheme.hairline)
                HStack(spacing: 0) {
                    DIRMetricTile(title: "Entry", value: routeSummaries.isEmpty ? "--" : "SET", color: DIRTheme.green)
                    Divider().overlay(DIRTheme.hairline)
                    DIRMetricTile(title: "Exit", value: routeSummaries.isEmpty ? "--" : "SET", color: DIRTheme.cyan)
                    Divider().overlay(DIRTheme.hairline)
                    DIRMetricTile(title: "Source", value: "LOG", color: DIRTheme.green)
                }
            }
        }
    }

    private var syncExportStatus: some View {
        HStack(spacing: 12) {
            statusCard("ROUTE SOURCE", "\(routeSummaries.count) GPS logs", "applewatch", DIRTheme.cyan)
            statusCard("EXPORT STATUS", "CSV via Logbook", "square.and.arrow.up", DIRTheme.yellow)
        }
    }

    private var emptyRouteState: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 11) {
                Image(systemName: "point.topleft.down.curvedto.point.bottomright.up")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(DIRTheme.cyan)
                    .frame(width: 44, height: 44)
                    .background(RoundedRectangle(cornerRadius: 12).fill(DIRTheme.cyan.opacity(0.12)))
                VStack(alignment: .leading, spacing: 4) {
                    Text("Nessuna route disponibile")
                        .font(.headline.weight(.bold))
                        .foregroundStyle(.white)
                    Text("Route Review usa solo punti GPS entry/exit presenti nei log. Nessun tracking subacqueo viene simulato.")
                        .font(.caption)
                        .foregroundStyle(DIRTheme.muted)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            HStack(spacing: 10) {
                emptyAction("Sincronizza Apple Watch", "applewatch")
                emptyAction("Importa CSV", "square.and.arrow.down")
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: DIRTheme.cardRadius)
                .fill(DIRTheme.surface.opacity(0.86))
                .overlay(RoundedRectangle(cornerRadius: DIRTheme.cardRadius).stroke(DIRTheme.cyan.opacity(0.30), lineWidth: 1))
        )
    }

    private var routeSummaries: [RouteSummary] {
        RouteSummaryService.summaries(from: logStore.sessions)
    }

    private var totalDistance: Double {
        routeSummaries.map(\.distanceMeters).reduce(0, +)
    }

    private var latestBearingText: String {
        guard let bearing = routeSummaries.first?.bearingDegrees else { return "--" }
        return Formatters.zero(bearing)
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
        let path = Path { path in
            path.move(to: CGPoint(x: 36, y: 182))
            path.addCurve(to: CGPoint(x: 118, y: 126), control1: CGPoint(x: 58, y: 158), control2: CGPoint(x: 82, y: 142))
            path.addCurve(to: CGPoint(x: 214, y: 94), control1: CGPoint(x: 150, y: 110), control2: CGPoint(x: 182, y: 108))
            path.addCurve(to: CGPoint(x: 282, y: 60), control1: CGPoint(x: 242, y: 82), control2: CGPoint(x: 258, y: 70))
        }

        return ZStack {
            path
                .stroke(DIRTheme.cyan.opacity(0.18), style: StrokeStyle(lineWidth: 12, lineCap: .round, lineJoin: .round))
            path
                .stroke(DIRTheme.cyan, style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round))
                .shadow(color: DIRTheme.cyan.opacity(0.45), radius: 10)
        }
    }

    private var bathymetryOverlay: some View {
        ZStack {
            ForEach(0..<4) { index in
                RoundedRectangle(cornerRadius: CGFloat(42 + index * 12))
                    .stroke(DIRTheme.cyan.opacity(0.055), lineWidth: 1)
                    .frame(width: CGFloat(120 + index * 58), height: CGFloat(68 + index * 34))
                    .rotationEffect(.degrees(Double(index * 8 - 12)))
                    .offset(x: CGFloat(index * 18 - 24), y: CGFloat(index * -8 + 10))
            }
        }
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
                .fill(
                    LinearGradient(
                        colors: [color.opacity(0.14), DIRTheme.surface.opacity(0.88)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(RoundedRectangle(cornerRadius: DIRTheme.cardRadius).stroke(color.opacity(0.48), lineWidth: 1))
                .shadow(color: color.opacity(0.12), radius: 12, x: 0, y: 8)
        )
    }

    private func routeStatus(_ title: String, _ value: String, _ color: Color, _ icon: String) -> some View {
        HStack(spacing: 9) {
            Image(systemName: icon)
                .font(.caption.weight(.bold))
                .foregroundStyle(color)
                .frame(width: 24, height: 24)
                .background(Circle().fill(color.opacity(0.13)))
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(DIRTheme.muted)
                Text(value)
                    .font(.callout.monospacedDigit().weight(.bold))
                    .foregroundStyle(.white)
            }
            Spacer(minLength: 0)
        }
        .padding(12)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: DIRTheme.cardRadius)
                .fill(DIRTheme.surface.opacity(0.74))
                .overlay(RoundedRectangle(cornerRadius: DIRTheme.cardRadius).stroke(color.opacity(0.34), lineWidth: 1))
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

    private func emptyAction(_ title: String, _ icon: String) -> some View {
        Label(title, systemImage: icon)
            .font(.caption.weight(.bold))
            .foregroundStyle(DIRTheme.cyan)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 9)
            .background(RoundedRectangle(cornerRadius: 8).stroke(DIRTheme.cyan.opacity(0.62), lineWidth: 1))
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
