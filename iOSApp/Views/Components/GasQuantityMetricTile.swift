import SwiftUI

struct GasQuantityMetricTile: View {
    let title: String
    let display: GasLedgerDisplayValue
    var color: Color = .white

    var body: some View {
        VStack(alignment: .center, spacing: 4) {
            Text(LocalizedStringKey(title.uppercased()))
                .font(DIRTypography.captionSemibold)
                .foregroundStyle(DIRTheme.muted)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(display.litersText)
                .font(DIRTypography.metricValue)
                .monospacedDigit()
                .foregroundStyle(color)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(display.pressureSecondaryText)
                .font(.caption2)
                .foregroundStyle(DIRTheme.muted)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(title), \(display.accessibilityLabel)")
    }
}
