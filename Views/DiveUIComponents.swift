import SwiftUI

enum DiveUI {
    static let blue = Color(red: 0.0, green: 0.56, blue: 1.0)
    static let cyan = Color(red: 0.02, green: 0.92, blue: 0.96)
    static let green = Color(red: 0.16, green: 0.9, blue: 0.36)
    static let yellow = Color(red: 1.0, green: 0.84, blue: 0.04)
    static let red = Color(red: 1.0, green: 0.22, blue: 0.18)
    static let orange = Color(red: 1.0, green: 0.56, blue: 0.0)

    static let backgroundTop = Color.black
    static let backgroundBottom = Color(red: 0.0, green: 0.025, blue: 0.036)
    static let panelFill = Color(red: 0.008, green: 0.012, blue: 0.016)
    static let panelFillRaised = Color(red: 0.018, green: 0.026, blue: 0.032)
    static let secondaryText = Color.white.opacity(0.7)
    static let mutedText = Color.white.opacity(0.52)
    static let subtleStroke = Color.white.opacity(0.28)
    static let hairline = Color.white.opacity(0.16)
    static let panelRadius: CGFloat = 12
    static let screenPadding: CGFloat = 10
}

struct DiveScreenBackground: View {
    var body: some View {
        ZStack {
            Color.black
            LinearGradient(
                colors: [DiveUI.backgroundTop, DiveUI.backgroundBottom],
                startPoint: .top,
                endPoint: .bottom
            )
            RadialGradient(
                colors: [DiveUI.blue.opacity(0.16), .clear],
                center: .topTrailing,
                startRadius: 12,
                endRadius: 160
            )
            RadialGradient(
                colors: [DiveUI.green.opacity(0.08), .clear],
                center: .bottomLeading,
                startRadius: 8,
                endRadius: 150
            )
        }
        .ignoresSafeArea()
    }
}

struct DivePanel<Content: View>: View {
    let stroke: Color
    let content: Content

    init(stroke: Color = DiveUI.subtleStroke, @ViewBuilder content: () -> Content) {
        self.stroke = stroke
        self.content = content()
    }

    var body: some View {
        content
            .padding(10)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: DiveUI.panelRadius, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [DiveUI.panelFillRaised.opacity(0.94), DiveUI.panelFill.opacity(0.98)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: DiveUI.panelRadius, style: .continuous)
                            .stroke(stroke.opacity(0.88), lineWidth: 1)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: DiveUI.panelRadius - 2, style: .continuous)
                            .stroke(.white.opacity(0.055), lineWidth: 0.7)
                            .padding(1)
                    )
                    .shadow(color: stroke.opacity(0.18), radius: 5, x: 0, y: 0)
            )
    }
}

struct DiveCommandButton: View {
    let title: String
    let systemImage: String?
    let color: Color
    let action: () -> Void

    init(_ title: String, systemImage: String? = nil, color: Color, action: @escaping () -> Void) {
        self.title = title
        self.systemImage = systemImage
        self.color = color
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 5) {
                Text(title)
                    .font(.caption.bold())
                    .lineLimit(1)
                    .minimumScaleFactor(0.68)
                if let systemImage {
                    Image(systemName: systemImage)
                        .font(.caption.bold())
                }
            }
            .foregroundStyle(color)
            .frame(maxWidth: .infinity, minHeight: 34)
            .padding(.horizontal, 5)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(color.opacity(0.13))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .stroke(color.opacity(0.86), lineWidth: 1)
                    )
                    .shadow(color: color.opacity(0.16), radius: 4, x: 0, y: 0)
            )
            .contentShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

struct DiveClockText: View {
    var size: CGFloat = 14

    var body: some View {
        TimelineView(.periodic(from: .now, by: 30)) { context in
            Text(context.date, format: .dateTime.hour().minute())
                .font(.system(size: size, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
                .monospacedDigit()
        }
    }
}

struct DiveMetric: View {
    let title: String
    let value: String
    let unit: String?
    let color: Color
    let valueSize: CGFloat

    init(_ title: String, value: String, unit: String? = nil, color: Color = DiveUI.blue, valueSize: CGFloat = 24) {
        self.title = title
        self.value = value
        self.unit = unit
        self.color = color
        self.valueSize = valueSize
    }

    var body: some View {
        VStack(spacing: 2) {
            Text(title.uppercased())
                .font(.system(size: 9, weight: .bold, design: .rounded))
                .foregroundStyle(DiveUI.secondaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.62)
            HStack(alignment: .lastTextBaseline, spacing: 3) {
                Text(value)
                    .font(.system(size: valueSize, weight: .regular, design: .rounded))
                    .minimumScaleFactor(0.62)
                    .lineLimit(1)
                    .monospacedDigit()
                    .foregroundStyle(color)
                if let unit {
                    Text(unit)
                        .font(.caption2.bold())
                        .foregroundStyle(color)
                        .lineLimit(1)
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
}

struct DiveScreenHeader: View {
    let title: String
    let subtitle: String?
    let accent: Color
    let systemImage: String?

    init(_ title: String, subtitle: String? = nil, accent: Color = DiveUI.blue, systemImage: String? = nil) {
        self.title = title
        self.subtitle = subtitle
        self.accent = accent
        self.systemImage = systemImage
    }

    var body: some View {
        HStack(spacing: 8) {
            DiveOctopusLogo()
            VStack(alignment: .leading, spacing: 1) {
                HStack(spacing: 5) {
                    if let systemImage {
                        Image(systemName: systemImage)
                    }
                    Text(title)
                }
                .font(.caption.bold())
                .foregroundStyle(accent)
                if let subtitle {
                    Text(subtitle)
                        .font(.system(size: 9, weight: .semibold, design: .rounded))
                        .foregroundStyle(DiveUI.secondaryText)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
            }
            Spacer()
            HStack(spacing: 3) {
                Image(systemName: "digitalcrown.horizontal.press")
                    .font(.caption2.bold())
                Text("CROWN")
                    .font(.system(size: 8, weight: .bold, design: .rounded))
            }
            .foregroundStyle(DiveUI.mutedText)
            .padding(.horizontal, 6)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .stroke(DiveUI.hairline, lineWidth: 1)
            )
        }
    }
}

struct DiveStatusPill: View {
    let text: String
    let color: Color
    let systemImage: String?

    init(_ text: String, color: Color, systemImage: String? = nil) {
        self.text = text
        self.color = color
        self.systemImage = systemImage
    }

    var body: some View {
        HStack(spacing: 4) {
            if let systemImage {
                Image(systemName: systemImage)
            }
            Text(text)
        }
        .font(.system(size: 9, weight: .bold, design: .rounded))
        .lineLimit(1)
        .minimumScaleFactor(0.72)
        .foregroundStyle(color)
        .padding(.horizontal, 7)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(color.opacity(0.12))
                .overlay(Capsule().stroke(color.opacity(0.72), lineWidth: 1))
        )
    }
}

struct DiveOctopusLogo: View {
    var accent: Color = DiveUI.blue

    var body: some View {
        ZStack {
            Circle()
                .fill(accent.opacity(0.22))
                .frame(width: 21, height: 21)
                .offset(y: -4)
                .shadow(color: accent.opacity(0.55), radius: 5, x: 0, y: 0)
            Circle()
                .stroke(accent, lineWidth: 2)
                .frame(width: 21, height: 21)
                .offset(y: -4)
            HStack(spacing: 5) {
                Circle().fill(accent).frame(width: 3, height: 3)
                Circle().fill(accent).frame(width: 3, height: 3)
            }
            .offset(y: -5)
            DiveOctopusTentacles()
                .stroke(accent, style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                .frame(width: 31, height: 18)
                .offset(y: 8)
        }
        .frame(width: 36, height: 32)
    }
}

struct DiveBearingRing: View {
    let headingDegrees: Double
    let bearingDelta: Double?
    let accent: Color
    let size: CGFloat

    init(headingDegrees: Double, bearingDelta: Double? = nil, accent: Color = DiveUI.blue, size: CGFloat = 112) {
        self.headingDegrees = headingDegrees
        self.bearingDelta = bearingDelta
        self.accent = accent
        self.size = size
    }

    var body: some View {
        ZStack {
            Circle()
                .fill(DiveUI.panelFill.opacity(0.82))
            Circle()
                .stroke(DiveUI.hairline, lineWidth: 1)
            Circle()
                .trim(from: 0, to: 0.72)
                .stroke(accent.opacity(0.9), style: StrokeStyle(lineWidth: 2, lineCap: .round))
                .rotationEffect(.degrees(-126))
                .shadow(color: accent.opacity(0.35), radius: 5, x: 0, y: 0)

            ForEach(0..<12, id: \.self) { tick in
                Rectangle()
                    .fill(tick % 3 == 0 ? .white.opacity(0.82) : DiveUI.hairline)
                    .frame(width: tick % 3 == 0 ? 2 : 1, height: tick % 3 == 0 ? 10 : 6)
                    .offset(y: -size * 0.43)
                    .rotationEffect(.degrees(Double(tick) * 30))
            }

            VStack(spacing: 0) {
                Text(cardinal)
                    .font(.system(size: 15, weight: .black, design: .rounded))
                    .foregroundStyle(accent)
                Text("\(Int(headingDegrees.rounded()))\u{00B0}")
                    .font(.system(size: 25, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(.white)
            }

            Image(systemName: "location.north.fill")
                .font(.system(size: size * 0.18, weight: .black))
                .foregroundStyle(bearingDelta == nil ? accent : DiveUI.yellow)
                .offset(y: -size * 0.31)
                .rotationEffect(.degrees(bearingDelta ?? headingDegrees))
                .animation(.easeInOut(duration: 0.25), value: headingDegrees)
                .animation(.easeInOut(duration: 0.25), value: bearingDelta ?? 0)
        }
        .frame(width: size, height: size)
    }

    private var cardinal: String {
        let normalized = (headingDegrees.truncatingRemainder(dividingBy: 360) + 360).truncatingRemainder(dividingBy: 360)
        switch normalized {
        case 337.5..<360, 0..<22.5: return "N"
        case 22.5..<67.5: return "NE"
        case 67.5..<112.5: return "E"
        case 112.5..<157.5: return "SE"
        case 157.5..<202.5: return "S"
        case 202.5..<247.5: return "SW"
        case 247.5..<292.5: return "W"
        default: return "NW"
        }
    }
}

private struct DiveOctopusTentacles: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let top = rect.minY + 2
        let bottom = rect.maxY - 2
        let centers: [CGFloat] = [0.12, 0.3, 0.5, 0.7, 0.88]

        for center in centers {
            let x = rect.minX + rect.width * center
            path.move(to: CGPoint(x: x, y: top))
            path.addCurve(
                to: CGPoint(x: x + (center < 0.5 ? -3 : center > 0.5 ? 3 : 0), y: bottom),
                control1: CGPoint(x: x - 5, y: top + 4),
                control2: CGPoint(x: x + 5, y: bottom - 4)
            )
        }

        return path
    }
}
