import SwiftUI

struct AscentGaugeView: View {
    let status: AscentStatus

    var body: some View {
        VStack(alignment: .trailing, spacing: 5) {
            Text("VELOCITÀ\nRISALITA")
                .font(.caption2.bold())
                .foregroundStyle(.white)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(alignment: .center, spacing: 5) {
                VStack(alignment: .trailing) {
                    scaleLabel("3.0", .red)
                    Spacer()
                    scaleLabel("2.3", .orange)
                    Spacer()
                    scaleLabel("1.5", .yellow)
                    Spacer()
                    scaleLabel("0.8", .green)
                    Spacer()
                    scaleLabel("0.0", .green)
                }
                .frame(width: 28)

                GeometryReader { geometry in
                    ZStack(alignment: .bottom) {
                        VStack(spacing: 0) {
                            Rectangle().fill(.red)
                            Rectangle().fill(.orange)
                            Rectangle().fill(.yellow)
                            Rectangle().fill(.green)
                        }
                        .clipShape(Rectangle())

                        VStack(spacing: geometry.size.height / 5.0 - 1) {
                            ForEach(0..<6, id: \.self) { _ in
                                Rectangle()
                                    .fill(.white)
                                    .frame(width: 28, height: 1)
                            }
                        }
                        .frame(maxHeight: .infinity)

                        Triangle()
                            .fill(.white)
                            .frame(width: 14, height: 16)
                            .rotationEffect(.degrees(180))
                            .offset(x: 26, y: pointerOffset(in: geometry.size.height))
                    }
                }
                .frame(width: 30)
            }

            Text("m/min")
                .font(.caption2)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, alignment: .center)
        }
    }

    private func scaleLabel(_ text: String, _ color: Color) -> some View {
        Text(text)
            .font(.caption2.bold())
            .monospacedDigit()
            .foregroundStyle(color)
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
