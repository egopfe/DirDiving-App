import SwiftUI

enum DiveUI {
    static let blue = Color(red: 0.0, green: 0.48, blue: 1.0)
    static let green = Color(red: 0.18, green: 0.82, blue: 0.35)
    static let yellow = Color(red: 1.0, green: 0.84, blue: 0.04)
    static let red = Color(red: 1.0, green: 0.23, blue: 0.19)
    static let orange = Color(red: 1.0, green: 0.58, blue: 0.0)
    static let panelFill = Color.black
    static let secondaryText = Color.white.opacity(0.72)
    static let subtleStroke = Color.white.opacity(0.34)
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
            .padding(8)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(DiveUI.panelFill)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(stroke, lineWidth: 1)
                    )
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
                    .minimumScaleFactor(0.7)
                if let systemImage {
                    Image(systemName: systemImage)
                        .font(.caption.bold())
                }
            }
            .foregroundStyle(color)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 9)
                    .fill(color.opacity(0.12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 9)
                            .stroke(color.opacity(0.82), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

struct DiveMetric: View {
    let title: String
    let value: String
    let unit: String?
    let color: Color

    init(_ title: String, value: String, unit: String? = nil, color: Color = DiveUI.blue) {
        self.title = title
        self.value = value
        self.unit = unit
        self.color = color
    }

    var body: some View {
        VStack(spacing: 2) {
            Text(title)
                .font(.caption2.bold())
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            HStack(alignment: .lastTextBaseline, spacing: 3) {
                Text(value)
                    .font(.system(size: 24, weight: .regular, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(color)
                if let unit {
                    Text(unit)
                        .font(.caption2.bold())
                        .foregroundStyle(color)
                }
            }
        }
    }
}

struct DiveOctopusLogo: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(DiveUI.blue.opacity(0.18))
                .frame(width: 19, height: 19)
                .offset(y: -4)
            Circle()
                .stroke(DiveUI.blue, lineWidth: 2)
                .frame(width: 19, height: 19)
                .offset(y: -4)
            HStack(spacing: 5) {
                Circle().fill(DiveUI.blue).frame(width: 3, height: 3)
                Circle().fill(DiveUI.blue).frame(width: 3, height: 3)
            }
            .offset(y: -5)
            DiveOctopusTentacles()
                .stroke(DiveUI.blue, style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                .frame(width: 29, height: 17)
                .offset(y: 8)
        }
        .frame(width: 34, height: 30)
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

