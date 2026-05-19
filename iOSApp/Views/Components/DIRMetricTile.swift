import SwiftUI

struct DIRMetricTile: View {
    let title: String
    let value: String
    var unit: String?
    var color: Color = .white
    var icon: String?

    init(title: String, value: String, unit: String? = nil, color: Color = .white, icon: String? = nil) {
        self.title = title
        self.value = value
        self.unit = unit
        self.color = color
        self.icon = icon
    }

    init(title: String, measurement: DisplayMeasurement, color: Color = .white, icon: String? = nil) {
        self.init(title: title, value: measurement.value, unit: measurement.unit, color: color, icon: icon)
    }

    var body: some View {
        VStack(alignment: .center, spacing: 7) {
            HStack {
                if let icon { Image(systemName: icon).font(.caption.weight(.bold)).foregroundStyle(color) }
                Text(title.uppercased())
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundStyle(DIRTheme.muted)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(value)
                    .font(.system(size: 25, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(color)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                if let unit { Text(unit).font(.caption).foregroundStyle(DIRTheme.muted) }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 13)
        .background(RoundedRectangle(cornerRadius: 0).fill(Color.clear))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(title), \(value) \(unit ?? "")")
    }
}
