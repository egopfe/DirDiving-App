import SwiftUI

struct AscentGaugeView: View {
    let status: AscentStatus
    var units: DIRUnitPreference = .metric

    private var rateUnitLabel: String { units.ascentRateUnitLabel }
    private var labelWidth: CGFloat { units == .imperial ? 70 : 64 }
    private var scaleLabelWidth: CGFloat { units == .imperial ? 32 : 27 }

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(String(localized: "ascent.gauge.title"))
                .font(DiveUI.Typography.metricLabel)
                .foregroundStyle(.white)
                .lineLimit(2)
                .minimumScaleFactor(0.9)
                .multilineTextAlignment(.leading)
                .frame(width: labelWidth, alignment: .leading)

            HStack(alignment: .center, spacing: 5) {
                scaleLabels
                    .frame(width: scaleLabelWidth)

                gaugeBar
                    .frame(width: 31, height: 126)
            }

            Text(rateUnitLabel)
                .font(DiveUI.Typography.unitLabel)
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.78)
                .frame(width: labelWidth, alignment: .trailing)
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
            (limit * AscentStatus.greenThresholdRatio, DiveUI.yellow),
            (limit * 0.5, DiveUI.green),
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
                        gaugeBands
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

    private var gaugeBands: some View {
        GeometryReader { geometry in
            let height = max(geometry.size.height - 4, 0)
            let greenHeight = height * CGFloat(AscentStatus.greenThresholdRatio)
            let yellowHeight = height * CGFloat(AscentStatus.redThresholdRatio - AscentStatus.greenThresholdRatio)
            ZStack(alignment: .top) {
                VStack(spacing: 0) {
                    Rectangle()
                        .fill(DiveUI.yellow)
                        .frame(height: yellowHeight)
                    Rectangle()
                        .fill(DiveUI.green)
                        .frame(height: greenHeight)
                }
                Rectangle()
                    .fill(DiveUI.red)
                    .frame(height: max(2, height * 0.04))
            }
            .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
            .padding(2)
        }
    }

    private var pointerColor: Color {
        switch status.zone {
        case .green: return DiveUI.green
        case .yellow: return DiveUI.yellow
        case .red: return DiveUI.red
        }
    }

    private func scaleLabel(_ text: String, _ color: Color) -> some View {
        Text(text)
            .font(.system(size: 10, weight: .black, design: .rounded))
            .monospacedDigit()
            .foregroundStyle(color)
            .lineLimit(1)
            .minimumScaleFactor(0.7)
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
