import SwiftUI

struct AscentGaugeView: View {
    let status: AscentStatus

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("VELOCIT\u{00C0}\nRISALITA")
                .font(.caption2.bold())
                .foregroundStyle(.white)
                .multilineTextAlignment(.leading)
                .lineLimit(2)

            HStack(alignment: .center, spacing: 4) {
                scaleLabels
                    .frame(width: 26)

                gaugeBar
                    .frame(width: 28, height: 112)
            }

            Text("m/min")
                .font(.caption2)
                .foregroundStyle(.white)
                .frame(width: 58, alignment: .trailing)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var scaleLabels: some View {
        let limit = max(status.limitMetersPerMinute, 0.5)
        let ticks: [(Double, Color)] = [
            (limit, DiveUI.red),
            (limit * 0.75, DiveUI.orange),
            (limit * 0.5, DiveUI.yellow),
            (limit * 0.25, DiveUI.green),
            (0, DiveUI.green)
        ]
        return VStack(alignment: .trailing, spacing: 0) {
            ForEach(Array(ticks.enumerated()), id: \.offset) { index, tick in
                if index > 0 { Spacer() }
                scaleLabel(Formatters.one(tick.0), tick.1)
            }
        }
    }

    private var gaugeBar: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                VStack(spacing: 0) {
                    Rectangle().fill(DiveUI.red)
                    Rectangle().fill(DiveUI.orange)
                    Rectangle().fill(DiveUI.yellow)
                    Rectangle().fill(DiveUI.green)
                }
                .clipShape(Rectangle())

                VStack(spacing: geometry.size.height / 5.0 - 1) {
                    ForEach(0..<6, id: \.self) { _ in
                        Rectangle()
                            .fill(.white)
                            .frame(width: 34, height: 1)
                    }
                }
                .frame(maxHeight: .infinity)

                Triangle()
                    .fill(.white)
                    .frame(width: 14, height: 16)
                    .rotationEffect(.degrees(180))
                    .offset(x: 23, y: pointerOffset(in: geometry.size.height))
            }
        }
    }

    private func scaleLabel(_ text: String, _ color: Color) -> some View {
        Text(text)
            .font(.caption2.bold())
            .monospacedDigit()
            .foregroundStyle(color)
            .lineLimit(1)
            .minimumScaleFactor(0.75)
    }

    private func pointerOffset(in height: CGFloat) -> CGFloat {
        let ratio = min(max(status.currentRateMetersPerMinute / max(status.limitMetersPerMinute, 0.1), 0), 1)
        return -height * ratio
    }
}

private struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}
