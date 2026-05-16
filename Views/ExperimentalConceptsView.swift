import SwiftUI

struct ExperimentalConceptDeckView: View {
    var body: some View {
        VStack(spacing: 10) {
            DivePanel(stroke: DiveUI.cyan) {
                VStack(alignment: .leading, spacing: 7) {
                    HStack {
                        Label("EXPERIMENTAL CONCEPTS", systemImage: "testtube.2")
                            .font(.system(size: 11, weight: .black, design: .rounded))
                            .foregroundStyle(DiveUI.cyan)
                        Spacer()
                        DiveStatusPill("UI ONLY", color: DiveUI.yellow)
                    }
                    Text("Visual placeholders only. No algorithms, sensors, sync, analytics or persistence are implemented here.")
                        .font(.system(size: 10, weight: .semibold, design: .rounded))
                        .foregroundStyle(DiveUI.secondaryText)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            ExperimentalExplorationOverview()
            ExperimentalUnderwaterCompassConcept()
            ExperimentalRouteNavigationConcept()
            ExperimentalSafetyConcepts()
            ExperimentalApneaIntelligenceConcept()
        }
    }
}

private struct ExperimentalExplorationOverview: View {
    var body: some View {
        VStack(spacing: 8) {
            // TODO: Wire these cards to future experimental navigation only after backend scope is approved.
            conceptScreen(
                title: "EXPLORATION MODE",
                subtitle: "Premium underwater overview",
                symbol: "water.waves.and.arrow.trianglehead.down",
                color: DiveUI.cyan
            ) {
                HStack(spacing: 0) {
                    metric("WPT", "04", DiveUI.cyan)
                    divider
                    metric("DRIFT", "--", DiveUI.yellow)
                    divider
                    metric("SAFE", "ON", DiveUI.green)
                }
            }

            conceptScreen(
                title: "UNDERWATER REFERENCES",
                subtitle: "Static visual reference layer",
                symbol: "photo.on.rectangle.angled",
                color: DiveUI.blue
            ) {
                HStack(spacing: 6) {
                    referenceChip("REEF", DiveUI.green)
                    referenceChip("LINE", DiveUI.cyan)
                    referenceChip("EXIT", DiveUI.yellow)
                }
            }
        }
    }
}

private struct ExperimentalUnderwaterCompassConcept: View {
    var body: some View {
        VStack(spacing: 8) {
            // TODO: Connect this underwater compass concept only after sensor and bearing scope is approved.
            conceptScreen(
                title: "UNDERWATER COMPASS",
                subtitle: "High-contrast visual heading concept",
                symbol: "safari.fill",
                color: DiveUI.cyan
            ) {
                HStack(spacing: 10) {
                    ExperimentalCompassDial()
                    VStack(alignment: .leading, spacing: 5) {
                        routeRow("HEADING", "042\u{00B0}", DiveUI.cyan)
                        routeRow("TARGET", "058\u{00B0}", DiveUI.green)
                        routeRow("CROWN", "LEG PREVIEW", DiveUI.yellow)
                    }
                }
            }

            conceptScreen(
                title: "ADVANCED ROUTE NAV",
                subtitle: "Static multi-leg presentation",
                symbol: "map.fill",
                color: DiveUI.blue
            ) {
                RouteLegPreview()
            }
        }
    }

    private func routeRow(_ title: String, _ value: String, _ color: Color) -> some View {
        HStack(spacing: 6) {
            Text(title)
                .font(.system(size: 8, weight: .black, design: .rounded))
                .foregroundStyle(DiveUI.mutedText)
            Spacer(minLength: 0)
            Text(value)
                .font(.system(size: 10, weight: .black, design: .rounded))
                .foregroundStyle(color)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
    }
}

private struct ExperimentalRouteNavigationConcept: View {
    var body: some View {
        VStack(spacing: 8) {
            // TODO: Replace static preview bearings with validated route navigation when implemented.
            conceptScreen(
                title: "ADVANCED WAYPOINT MODE",
                subtitle: "Crown-first route preview",
                symbol: "point.topleft.down.curvedto.point.bottomright.up",
                color: DiveUI.blue
            ) {
                HStack(spacing: 10) {
                    DiveBearingRing(headingDegrees: 38, bearingDelta: -14, accent: DiveUI.blue, size: 82)
                    VStack(alignment: .leading, spacing: 5) {
                        routeRow("NEXT", "REEF NORD", DiveUI.cyan)
                        routeRow("BEARING", "038\u{00B0}", DiveUI.green)
                        routeRow("DEVIATION", "-14\u{00B0}", DiveUI.yellow)
                    }
                }
            }

            conceptScreen(
                title: "WAYPOINT REACHED",
                subtitle: "Confirmation state",
                symbol: "checkmark.seal.fill",
                color: DiveUI.green
            ) {
                HStack(spacing: 10) {
                    ZStack {
                        Circle().fill(DiveUI.green.opacity(0.16))
                        Circle().stroke(DiveUI.green.opacity(0.9), lineWidth: 1)
                        Image(systemName: "checkmark")
                            .font(.system(size: 22, weight: .black))
                            .foregroundStyle(DiveUI.green)
                    }
                    .frame(width: 52, height: 52)
                    VStack(alignment: .leading, spacing: 3) {
                        Text("WPT 02")
                            .font(.system(size: 17, weight: .black, design: .rounded))
                            .foregroundStyle(.white)
                        Text("READY FOR NEXT LEG")
                            .font(.system(size: 9, weight: .bold, design: .rounded))
                            .foregroundStyle(DiveUI.green)
                    }
                    Spacer(minLength: 0)
                }
            }

            conceptScreen(
                title: "RETURN BEARING",
                subtitle: "Plausible return direction",
                symbol: "arrow.uturn.backward.circle.fill",
                color: DiveUI.yellow
            ) {
                HStack(spacing: 0) {
                    metric("ENTRY", "214\u{00B0}", DiveUI.yellow)
                    divider
                    metric("RANGE", "-- m", .white)
                    divider
                    metric("CONF", "LOW", DiveUI.red)
                }
            }
        }
    }

    private func routeRow(_ title: String, _ value: String, _ color: Color) -> some View {
        HStack(spacing: 6) {
            Text(title)
                .font(.system(size: 8, weight: .black, design: .rounded))
                .foregroundStyle(DiveUI.mutedText)
            Spacer(minLength: 0)
            Text(value)
                .font(.system(size: 10, weight: .black, design: .rounded))
                .foregroundStyle(color)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
    }
}

private struct ExperimentalSafetyConcepts: View {
    var body: some View {
        VStack(spacing: 8) {
            // TODO: Drift, route deviation and safety bubble are visual placeholders only.
            conceptScreen(
                title: "DRIFT INDICATOR",
                subtitle: "Visual-only drift cue",
                symbol: "wind",
                color: DiveUI.yellow
            ) {
                VStack(spacing: 7) {
                    DriftBars()
                    HStack {
                        DiveStatusPill("SLOW", color: DiveUI.green)
                        DiveStatusPill("MED", color: DiveUI.yellow)
                        DiveStatusPill("HIGH", color: DiveUI.red)
                    }
                }
            }

            conceptScreen(
                title: "DRIFT WARNING",
                subtitle: "Presentation concept only",
                symbol: "water.waves",
                color: DiveUI.yellow
            ) {
                HStack(spacing: 10) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(DiveUI.yellow.opacity(0.13))
                        Image(systemName: "arrow.right")
                            .font(.system(size: 34, weight: .black))
                            .foregroundStyle(DiveUI.yellow)
                            .rotationEffect(.degrees(12))
                            .shadow(color: DiveUI.yellow.opacity(0.55), radius: 7, x: 0, y: 0)
                    }
                    .frame(width: 58, height: 58)

                    VStack(alignment: .leading, spacing: 3) {
                        Text("LATERAL PUSH")
                            .font(.system(size: 17, weight: .black, design: .rounded))
                            .foregroundStyle(.white)
                        Text("NO DRIFT CALCULATION")
                            .font(.system(size: 9, weight: .bold, design: .rounded))
                            .foregroundStyle(DiveUI.yellow)
                    }
                    Spacer(minLength: 0)
                }
            }

            conceptScreen(
                title: "ROUTE DEVIATION",
                subtitle: "Warning presentation concept",
                symbol: "exclamationmark.triangle.fill",
                color: DiveUI.red
            ) {
                HStack(spacing: 9) {
                    Image(systemName: "arrow.triangle.branch")
                        .font(.system(size: 36, weight: .black))
                        .foregroundStyle(DiveUI.red)
                        .rotationEffect(.degrees(-18))
                    VStack(alignment: .leading, spacing: 2) {
                        Text("OFF ROUTE")
                            .font(.system(size: 19, weight: .black, design: .rounded))
                            .foregroundStyle(DiveUI.red)
                        Text("VISUAL WARNING ONLY")
                            .font(.system(size: 9, weight: .bold, design: .rounded))
                            .foregroundStyle(DiveUI.secondaryText)
                    }
                    Spacer(minLength: 0)
                }
            }

            conceptScreen(
                title: "SAFETY BUBBLE",
                subtitle: "Team spacing visualization",
                symbol: "circle.dotted",
                color: DiveUI.green
            ) {
                ZStack {
                    Circle().stroke(DiveUI.green.opacity(0.28), lineWidth: 8)
                    Circle().stroke(DiveUI.green.opacity(0.9), lineWidth: 1)
                    Circle().fill(DiveUI.blue).frame(width: 9, height: 9).offset(x: -22, y: 14)
                    Circle().fill(DiveUI.yellow).frame(width: 9, height: 9).offset(x: 24, y: -8)
                    Text("TEAM")
                        .font(.system(size: 18, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                }
                .frame(height: 88)
            }
        }
    }
}

private struct ExperimentalApneaIntelligenceConcept: View {
    var body: some View {
        VStack(spacing: 8) {
            // TODO: AI exploration, overlays, readiness and fatigue are static UI placeholders only.
            HStack(spacing: 8) {
                premiumMiniCard("AI EXPLORATION", value: "CONCEPT", symbol: "sparkles", color: DiveUI.cyan)
                premiumMiniCard("MARINE OVERLAYS", value: "LAYER", symbol: "leaf.fill", color: DiveUI.green)
            }
            HStack(spacing: 8) {
                premiumMiniCard("APNEA READINESS", value: "--%", symbol: "lungs.fill", color: DiveUI.yellow)
                premiumMiniCard("FATIGUE EST.", value: "N/A", symbol: "waveform.path.ecg", color: DiveUI.red)
            }
        }
    }
}

private struct ExperimentalCompassDial: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(DiveUI.panelFill.opacity(0.85))
            Circle()
                .stroke(DiveUI.cyan.opacity(0.82), lineWidth: 2)
                .shadow(color: DiveUI.cyan.opacity(0.38), radius: 7, x: 0, y: 0)
            Circle()
                .trim(from: 0, to: 0.18)
                .stroke(DiveUI.yellow, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                .rotationEffect(.degrees(-64))
            ForEach(0..<8, id: \.self) { tick in
                Rectangle()
                    .fill(tick % 2 == 0 ? .white.opacity(0.9) : DiveUI.hairline)
                    .frame(width: 2, height: tick % 2 == 0 ? 10 : 6)
                    .offset(y: -38)
                    .rotationEffect(.degrees(Double(tick) * 45))
            }
            VStack(spacing: -1) {
                Text("NE")
                    .font(.system(size: 15, weight: .black, design: .rounded))
                    .foregroundStyle(DiveUI.cyan)
                Text("042\u{00B0}")
                    .font(.system(size: 22, weight: .black, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(.white)
            }
            Image(systemName: "location.north.fill")
                .font(.system(size: 18, weight: .black))
                .foregroundStyle(DiveUI.yellow)
                .offset(y: -27)
                .rotationEffect(.degrees(16))
        }
        .frame(width: 92, height: 92)
    }
}

private struct RouteLegPreview: View {
    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 7) {
                routeNode("01", color: DiveUI.green, isActive: false)
                routeLine(DiveUI.green)
                routeNode("02", color: DiveUI.cyan, isActive: true)
                routeLine(DiveUI.yellow)
                routeNode("03", color: DiveUI.yellow, isActive: false)
            }
            HStack(spacing: 0) {
                metric("LEG", "02/05", DiveUI.cyan)
                divider
                metric("NEXT", "REEF", DiveUI.green)
                divider
                metric("DEV", "+09\u{00B0}", DiveUI.yellow)
            }
        }
    }

    private func routeNode(_ text: String, color: Color, isActive: Bool) -> some View {
        Text(text)
            .font(.system(size: 11, weight: .black, design: .rounded))
            .foregroundStyle(isActive ? .black : color)
            .frame(width: 32, height: 32)
            .background(
                Circle()
                    .fill(isActive ? color : color.opacity(0.14))
                    .overlay(Circle().stroke(color.opacity(0.9), lineWidth: 1))
                    .shadow(color: color.opacity(isActive ? 0.5 : 0.18), radius: 6, x: 0, y: 0)
            )
    }

    private func routeLine(_ color: Color) -> some View {
        Capsule()
            .fill(color.opacity(0.65))
            .frame(height: 3)
    }
}

private struct DriftBars: View {
    var body: some View {
        HStack(alignment: .bottom, spacing: 5) {
            ForEach(0..<7, id: \.self) { index in
                RoundedRectangle(cornerRadius: 3, style: .continuous)
                    .fill(color(for: index))
                    .frame(width: 12, height: CGFloat(14 + index * 5))
            }
        }
        .frame(maxWidth: .infinity)
    }

    private func color(for index: Int) -> Color {
        if index > 4 { return DiveUI.red }
        if index > 2 { return DiveUI.yellow }
        return DiveUI.green
    }
}

private func conceptScreen<Content: View>(
    title: String,
    subtitle: String,
    symbol: String,
    color: Color,
    @ViewBuilder content: () -> Content
) -> some View {
    DivePanel(stroke: color) {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 7) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(color.opacity(0.14))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .stroke(color.opacity(0.55), lineWidth: 1)
                        )
                    Image(systemName: symbol)
                        .font(.system(size: 15, weight: .black))
                        .foregroundStyle(color)
                }
                .frame(width: 28, height: 28)
                VStack(alignment: .leading, spacing: 1) {
                    Text(title)
                        .font(.system(size: 11, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                    Text(subtitle)
                        .font(.system(size: 9, weight: .semibold, design: .rounded))
                        .foregroundStyle(DiveUI.secondaryText)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
                Spacer(minLength: 0)
                DiveStatusPill("TODO", color: color)
            }
            content()
        }
    }
}

private func premiumMiniCard(_ title: String, value: String, symbol: String, color: Color) -> some View {
    DivePanel(stroke: color) {
        VStack(spacing: 5) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.14))
                    .frame(width: 34, height: 34)
                    .shadow(color: color.opacity(0.25), radius: 6, x: 0, y: 0)
                Image(systemName: symbol)
                    .font(.system(size: 16, weight: .black))
                    .foregroundStyle(color)
            }
            Text(value)
                .font(.system(size: 18, weight: .black, design: .rounded))
                .foregroundStyle(.white)
                .lineLimit(1)
            Text(title)
                .font(.system(size: 8, weight: .black, design: .rounded))
                .foregroundStyle(DiveUI.secondaryText)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.68)
        }
        .frame(minHeight: 78)
    }
}

private func referenceChip(_ title: String, _ color: Color) -> some View {
    Text(title)
        .font(.system(size: 9, weight: .black, design: .rounded))
        .foregroundStyle(color)
        .lineLimit(1)
        .minimumScaleFactor(0.72)
        .frame(maxWidth: .infinity, minHeight: 30)
        .background(
            Capsule()
                .fill(color.opacity(0.12))
                .overlay(Capsule().stroke(color.opacity(0.68), lineWidth: 1))
                .shadow(color: color.opacity(0.16), radius: 4, x: 0, y: 0)
        )
}

private func metric(_ title: String, _ value: String, _ color: Color) -> some View {
    VStack(spacing: 2) {
        Text(title)
            .font(.system(size: 8, weight: .black, design: .rounded))
            .foregroundStyle(DiveUI.mutedText)
        Text(value)
            .font(.system(size: 17, weight: .black, design: .rounded))
            .monospacedDigit()
            .foregroundStyle(color)
            .lineLimit(1)
            .minimumScaleFactor(0.62)
    }
    .frame(maxWidth: .infinity)
}

private var divider: some View {
    Rectangle()
        .fill(DiveUI.hairline)
        .frame(width: 1, height: 34)
}
