import SwiftUI

struct DecoStopsSectionView: View {
    let rows: [DecoStopPresentationRow]
    var titleKey: String = "planner.deco_stops.title"
    var subtitleKey: String = "planner.deco_stops.subtitle"
    var accessibilityKey: String = "planner.deco_stops.table.a11y"

    var body: some View {
        DIRCard(DIRIOSLocalizer.string(titleKey), icon: "list.number", accent: DIRTheme.cyan) {
            Text(DIRIOSLocalizer.string(subtitleKey))
                .font(.caption2)
                .foregroundStyle(DIRTheme.muted)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)

            VStack(spacing: 0) {
                tableRow(
                    [
                        DIRIOSLocalizer.string("planner.deco_stops.column.index"),
                        DIRIOSLocalizer.string("planner.deco_stops.column.depth"),
                        DIRIOSLocalizer.string("planner.deco_stops.column.time"),
                        DIRIOSLocalizer.string("planner.deco_stops.column.gas"),
                        DIRIOSLocalizer.string("planner.deco_stops.column.ppo2")
                    ],
                    isHeader: true
                )
                ForEach(rows) { row in
                    tableRow(
                        [
                            "\(row.index)",
                            row.depthLabel,
                            row.timeLabel,
                            row.gasLabel,
                            row.ppO2Label
                        ],
                        ppO2Warning: row.hasPPO2Warning,
                        columnHeaders: [
                            DIRIOSLocalizer.string("planner.deco_stops.column.index"),
                            DIRIOSLocalizer.string("planner.deco_stops.column.depth"),
                            DIRIOSLocalizer.string("planner.deco_stops.column.time"),
                            DIRIOSLocalizer.string("planner.deco_stops.column.gas"),
                            DIRIOSLocalizer.string("planner.deco_stops.column.ppo2")
                        ]
                    )
                    if row.id != rows.last?.id {
                        Divider().overlay(DIRTheme.hairline)
                    }
                }
            }
            .background(
                RoundedRectangle(cornerRadius: DIRTheme.compactRadius)
                    .fill(DIRTheme.surface2.opacity(0.45))
            )
            .accessibilityElement(children: .contain)
            .accessibilityLabel(DIRIOSLocalizer.string(accessibilityKey))
        }
    }

    private func tableRow(
        _ values: [String],
        isHeader: Bool = false,
        ppO2Warning: Bool = false,
        columnHeaders: [String]? = nil
    ) -> some View {
        HStack(spacing: 6) {
            ForEach(Array(values.enumerated()), id: \.offset) { index, value in
                let isPPO2Column = !isHeader && index == values.count - 1
                Text(value)
                    .font(isHeader ? .caption.weight(.semibold) : .caption.monospacedDigit())
                    .foregroundStyle(
                        isHeader
                            ? DIRTheme.muted
                            : (isPPO2Column && ppO2Warning ? DIRTheme.red : .white)
                    )
                    .frame(maxWidth: .infinity, alignment: index == 0 ? .leading : (index == values.count - 1 ? .trailing : .center))
                    .lineLimit(2)
                    .minimumScaleFactor(0.82)
                    .accessibilityLabel(
                        isHeader || columnHeaders == nil
                            ? value
                            : tableColumnAccessibilityLabel(index: index, value: value, headers: columnHeaders)
                    )
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, isHeader ? 8 : 10)
        .background(isHeader ? DIRTheme.surface2.opacity(0.65) : Color.clear)
        .accessibilityElement(children: isHeader ? .combine : .contain)
        .accessibilityAddTraits(isHeader ? .isHeader : [])
    }

    private func tableColumnAccessibilityLabel(index: Int, value: String, headers: [String]?) -> String {
        guard let headers, index < headers.count else { return value }
        return "\(headers[index]): \(value)"
    }
}
