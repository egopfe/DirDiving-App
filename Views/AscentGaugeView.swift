import SwiftUI

struct AscentGaugeView: View {
    let status: AscentStatus
    var units: DIRUnitPreference = .metric

    private var rateUnitLabel: String { units.ascentRateUnitLabel }

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            VStack(alignment: .leading, spacing: 0) {
                Text("VELOCITA")
                Text("RISALITA")
            }
            .font(.system(size: 10, weight: .black, design: .rounded))
            .foregroundStyle(.white)
            .lineLimit(1)
            .minimumScaleFactor(0.78)

            HStack(alignment: .center, spacing: 5) {
                scaleLabels
                    .frame(width: 27)

                gaugeBar
                    .frame(width: 31, height: 126)
            }

            Text(rateUnitLabel)
                .font(.system(size: 10, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .frame(width: 64, alignment: .trailing)
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 4)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(DiveUI.panelFill.opacity(0.72))
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(DiveUI.hairline, lineWidth: 1)
                )
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(String(localized: "ascent.gauge.a11y"))
        .accessibilityValue(ascentAccessibilityValue)
        .animation(.easeInOut(duration: 0.22), value: status.currentRateMetersPerMinute)
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
                if index > 0 { Spacer(minLength: 0) }
                scaleLabel(formattedRate(tick.0), tick.1)
            }
        }
    }

    private var gaugeBar: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .fill(.white.opacity(0.08))
                    .overlay(
                        VStack(spacing: 0) {
                            Rectangle().fill(DiveUI.red)
                            Rectangle().fill(DiveUI.orange)
                            Rectangle().fill(DiveUI.yellow)
                            Rectangle().fill(DiveUI.green)
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
                        .padding(2)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 4, style: .continuous)
                            .stroke(.white.opacity(0.7), lineWidth: 1)
                    )

                VStack(spacing: max((geometry.size.height - 6) / 5.0 - 1, 0)) {
                    ForEach(0..<6, id: \.self) { tick in
                        Rectangle()
                            .fill(tick == 0 || tick == 5 ? .white : .white.opacity(0.76))
                            .frame(width: tick == 0 || tick == 5 ? 35 : 30, height: 1)
                    }
                }
                .frame(maxHeight: .infinity)

                Triangle()
                    .fill(.white)
                    .frame(width: 15, height: 17)
                    .rotationEffect(.degrees(180))
                    .shadow(color: pointerColor.opacity(0.6), radius: 4, x: 0, y: 0)
                    .offset(x: 25, y: pointerOffset(in: geometry.size.height))
            }
        }
    }

    private var pointerColor: Color {
        let ratio = status.currentRateMetersPerMinute / max(status.limitMetersPerMinute, 0.1)
        if ratio >= 0.75 { return DiveUI.red }
        if ratio >= 0.5 { return DiveUI.yellow }
        return DiveUI.green
    }

    private func scaleLabel(_ text: String, _ color: Color) -> some View {
        Text(text)
            .font(.system(size: 10, weight: .black, design: .rounded))
            .monospacedDigit()
            .foregroundStyle(color)
            .lineLimit(1)
            .minimumScaleFactor(0.75)
    }

    private func pointerOffset(in height: CGFloat) -> CGFloat {
        let ratio = min(max(status.currentRateMetersPerMinute / max(status.limitMetersPerMinute, 0.1), 0), 1)
        return -height * ratio
    }

    private func formattedRate(_ metersPerMinute: Double) -> String {
        Formatters.one(units.ascentRateDisplay(metersPerMinute: metersPerMinute).value)
    }

    private var ascentAccessibilityValue: String {
        let limit = units.ascentRateDisplay(metersPerMinute: status.limitMetersPerMinute)
        let current = units.ascentRateDisplay(metersPerMinute: status.currentRateMetersPerMinute)
        return String(
            format: String(localized: "ascent.gauge.a11y.value_format"),
            Formatters.one(limit.value),
            limit.unit,
            Formatters.one(current.value),
            current.unit
        )
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
