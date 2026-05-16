import SwiftUI

struct DIRMetricTile: View {
    let title: String
    let value: String
    var unit: String?
    var color: Color = .white
    var icon: String?

    var body: some View {
        VStack(alignment: .center, spacing: 7) {
            HStack {
                if let icon { Image(systemName: icon).font(.caption.weight(.bold)).foregroundStyle(color) }
                Text(title.uppercased())
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                    .foregroundStyle(DIRTheme.muted)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(value)
                    .font(.system(size: 24, weight: .semibold, design: .rounded))
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
    }
}
