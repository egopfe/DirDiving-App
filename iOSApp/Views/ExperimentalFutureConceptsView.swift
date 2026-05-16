import SwiftUI

struct ExperimentalFutureConceptsView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            DIRSectionHeader(
                title: "Future Exploration Concepts",
                subtitle: "Static SwiftUI mockups only. No AI, sync, backend, analytics, networking or persistence."
            )
            advancedMapOverlays
            marineConceptGrid
            routeIntelligence
            adaptiveApneaAnalytics
            cloudCommunityConcepts
        }
    }

    private var advancedMapOverlays: some View {
        DIRCard("ADVANCED MAP OVERLAYS", icon: "map", accent: DIRTheme.cyan) {
            // TODO: Visual placeholder only. Do not connect to map engines, bathymetry providers or networking here.
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.0, green: 0.07, blue: 0.09),
                                Color(red: 0.0, green: 0.018, blue: 0.026)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(ExperimentalMapGrid())

                BathymetryContours()
                    .stroke(DIRTheme.cyan.opacity(0.32), style: StrokeStyle(lineWidth: 1.2, lineCap: .round, lineJoin: .round))
                    .padding(18)

                HeatmapBlobs()
                    .blendMode(.plusLighter)

                routePreview

                VStack {
                    HStack(spacing: 8) {
                        conceptBadge("BATHY", color: DIRTheme.cyan)
                        conceptBadge("REEF", color: DIRTheme.green)
                        conceptBadge("HOTSPOT", color: DIRTheme.orange)
                        Spacer()
                    }
                    Spacer()
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("REEF EXPLORATION")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(.white)
                            Text("Layer stack preview")
                                .font(.caption2)
                                .foregroundStyle(DIRTheme.muted)
                        }
                        Spacer()
                        conceptBadge("UI ONLY", color: DIRTheme.yellow)
                    }
                    .padding(10)
                    .background(RoundedRectangle(cornerRadius: 10).fill(.black.opacity(0.34)))
                }
                .padding(12)
            }
            .frame(height: 280)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    private var routePreview: some View {
        Path { path in
            path.move(to: CGPoint(x: 42, y: 214))
            path.addCurve(to: CGPoint(x: 128, y: 156), control1: CGPoint(x: 70, y: 184), control2: CGPoint(x: 96, y: 174))
            path.addCurve(to: CGPoint(x: 232, y: 108), control1: CGPoint(x: 166, y: 134), control2: CGPoint(x: 194, y: 130))
            path.addCurve(to: CGPoint(x: 312, y: 72), control1: CGPoint(x: 258, y: 92), control2: CGPoint(x: 282, y: 84))
        }
        .stroke(DIRTheme.cyan, style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round))
        .shadow(color: DIRTheme.cyan.opacity(0.42), radius: 10)
    }

    private var marineConceptGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            conceptTile("Marine overlays", "species / current", "leaf.fill", DIRTheme.green)
            conceptTile("Bathymetry", "depth contours", "chart.xyaxis.line", DIRTheme.cyan)
            conceptTile("Reef exploration", "reef-safe path", "water.waves", DIRTheme.yellow)
            conceptTile("Hotspot heatmaps", "density layer", "flame.fill", DIRTheme.orange)
        }
    }

    private var routeIntelligence: some View {
        DIRCard("ADVANCED ROUTE INTELLIGENCE", icon: "point.topleft.down.curvedto.point.bottomright.up", accent: DIRTheme.cyan) {
            // TODO: Static presentation only. Do not implement route scoring or adaptive routing here.
            VStack(spacing: 12) {
                HStack(spacing: 0) {
                    DIRMetricTile(title: "Route IQ", value: "--", color: DIRTheme.cyan, icon: "sparkles")
                    Divider().overlay(DIRTheme.hairline)
                    DIRMetricTile(title: "Deviation", value: "+06", unit: "deg", color: DIRTheme.green, icon: "arrow.left.and.right")
                    Divider().overlay(DIRTheme.hairline)
                    DIRMetricTile(title: "Return", value: "214", unit: "deg", color: DIRTheme.yellow, icon: "arrow.uturn.backward")
                }
                routeTimeline
            }
        }
    }

    private var routeTimeline: some View {
        HStack(spacing: 0) {
            timelineNode("ENTRY", DIRTheme.green)
            timelineLine(DIRTheme.cyan)
            timelineNode("REEF", DIRTheme.cyan)
            timelineLine(DIRTheme.yellow)
            timelineNode("HOT", DIRTheme.orange)
            timelineLine(DIRTheme.red)
            timelineNode("EXIT", DIRTheme.yellow)
        }
        .padding(.vertical, 6)
    }

    private var adaptiveApneaAnalytics: some View {
        DIRCard("ADAPTIVE APNEA ANALYTICS", icon: "lungs.fill", accent: DIRTheme.yellow) {
            // TODO: Visual concept only. Do not implement readiness, fatigue or analytics engines here.
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    circularMetric("READINESS", "--%", DIRTheme.yellow)
                    circularMetric("FATIGUE", "N/A", DIRTheme.red)
                    circularMetric("RECOVERY", "2.4x", DIRTheme.green)
                }
                FatigueWaveform()
                    .frame(height: 110)
                    .background(RoundedRectangle(cornerRadius: 10).fill(.black.opacity(0.2)))
            }
        }
    }

    private var cloudCommunityConcepts: some View {
        HStack(spacing: 12) {
            conceptStatusCard(
                title: "AI Exploration",
                value: "TODO",
                icon: "sparkles",
                color: DIRTheme.cyan,
                note: "No AI implemented"
            )
            conceptStatusCard(
                title: "Cloud Sync",
                value: "Mock",
                icon: "icloud",
                color: DIRTheme.green,
                note: "No sync implemented"
            )
            conceptStatusCard(
                title: "Community Spots",
                value: "Soon",
                icon: "person.3.fill",
                color: DIRTheme.yellow,
                note: "No network"
            )
        }
    }

    private func conceptTile(_ title: String, _ subtitle: String, _ icon: String, _ color: Color) -> some View {
        DIRCard(accent: color) {
            VStack(alignment: .leading, spacing: 10) {
                Image(systemName: icon)
                    .font(.title2.weight(.bold))
                    .foregroundStyle(color)
                Text(title)
                    .font(.callout.weight(.semibold))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.78)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(DIRTheme.muted)
                conceptBadge("TODO", color: color)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func timelineNode(_ text: String, _ color: Color) -> some View {
        VStack(spacing: 6) {
            Circle()
                .fill(color)
                .frame(width: 12, height: 12)
                .shadow(color: color.opacity(0.5), radius: 8)
            Text(text)
                .font(.caption2.weight(.bold))
                .foregroundStyle(color)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(width: 54)
    }

    private func timelineLine(_ color: Color) -> some View {
        Rectangle()
            .fill(color.opacity(0.65))
            .frame(height: 2)
            .frame(maxWidth: .infinity)
            .offset(y: -12)
    }

    private func circularMetric(_ title: String, _ value: String, _ color: Color) -> some View {
        ZStack {
            Circle().stroke(DIRTheme.hairline, lineWidth: 8)
            Circle()
                .trim(from: 0, to: title == "FATIGUE" ? 0.32 : 0.68)
                .stroke(color, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                .rotationEffect(.degrees(-90))
            VStack(spacing: 2) {
                Text(value)
                    .font(.headline.monospacedDigit().weight(.bold))
                    .foregroundStyle(.white)
                Text(title)
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(color)
            }
        }
        .frame(maxWidth: .infinity)
        .aspectRatio(1, contentMode: .fit)
    }

    private func conceptStatusCard(title: String, value: String, icon: String, color: Color, note: String) -> some View {
        DIRCard(accent: color) {
            VStack(alignment: .leading, spacing: 8) {
                Image(systemName: icon)
                    .font(.title2.weight(.bold))
                    .foregroundStyle(color)
                Text(value)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                Text(title)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(DIRTheme.muted)
                    .lineLimit(1)
                    .minimumScaleFactor(0.68)
                Text(note)
                    .font(.caption2)
                    .foregroundStyle(color)
                    .lineLimit(2)
                    .minimumScaleFactor(0.7)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func conceptBadge(_ text: String, color: Color) -> some View {
        Text(text)
            .font(.caption2.weight(.bold))
            .foregroundStyle(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(Capsule().fill(color.opacity(0.12)).overlay(Capsule().stroke(color.opacity(0.46), lineWidth: 1)))
    }
}

private struct ExperimentalMapGrid: View {
    var body: some View {
        Canvas { context, size in
            let gridColor = Color.white.opacity(0.06)
            for x in stride(from: 0.0, through: size.width, by: 38) {
                var path = Path()
                path.move(to: CGPoint(x: x, y: 0))
                path.addLine(to: CGPoint(x: x, y: size.height))
                context.stroke(path, with: .color(gridColor), lineWidth: 1)
            }
            for y in stride(from: 0.0, through: size.height, by: 38) {
                var path = Path()
                path.move(to: CGPoint(x: 0, y: y))
                path.addLine(to: CGPoint(x: size.width, y: y))
                context.stroke(path, with: .color(gridColor), lineWidth: 1)
            }
        }
    }
}

private struct BathymetryContours: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        for index in 0..<5 {
            let inset = CGFloat(index) * 22
            let y = rect.minY + 28 + CGFloat(index) * 25
            path.move(to: CGPoint(x: rect.minX + 8 + inset * 0.35, y: y))
            path.addCurve(
                to: CGPoint(x: rect.maxX - 20 - inset * 0.18, y: y + 14),
                control1: CGPoint(x: rect.midX - 55, y: y - 32),
                control2: CGPoint(x: rect.midX + 32, y: y + 46)
            )
        }
        return path
    }
}

private struct HeatmapBlobs: View {
    var body: some View {
        ZStack {
            blob(color: DIRTheme.orange, width: 86, height: 56, x: -72, y: 34)
            blob(color: DIRTheme.red, width: 70, height: 46, x: 82, y: -42)
            blob(color: DIRTheme.green, width: 78, height: 48, x: 22, y: 56)
        }
    }

    private func blob(color: Color, width: CGFloat, height: CGFloat, x: CGFloat, y: CGFloat) -> some View {
        Ellipse()
            .fill(color.opacity(0.18))
            .frame(width: width, height: height)
            .blur(radius: 8)
            .offset(x: x, y: y)
    }
}

private struct FatigueWaveform: View {
    var body: some View {
        Canvas { context, size in
            let grid = Path { path in
                for y in stride(from: 0.0, through: size.height, by: 26) {
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addLine(to: CGPoint(x: size.width, y: y))
                }
            }
            context.stroke(grid, with: .color(Color.white.opacity(0.07)), lineWidth: 1)

            var path = Path()
            path.move(to: CGPoint(x: 0, y: size.height * 0.62))
            path.addCurve(to: CGPoint(x: size.width * 0.28, y: size.height * 0.35), control1: CGPoint(x: 28, y: size.height * 0.72), control2: CGPoint(x: 64, y: size.height * 0.22))
            path.addCurve(to: CGPoint(x: size.width * 0.58, y: size.height * 0.72), control1: CGPoint(x: size.width * 0.38, y: size.height * 0.52), control2: CGPoint(x: size.width * 0.48, y: size.height * 0.86))
            path.addCurve(to: CGPoint(x: size.width, y: size.height * 0.44), control1: CGPoint(x: size.width * 0.72, y: size.height * 0.48), control2: CGPoint(x: size.width * 0.86, y: size.height * 0.4))
            context.stroke(path, with: .color(DIRTheme.yellow), style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
        }
    }
}
