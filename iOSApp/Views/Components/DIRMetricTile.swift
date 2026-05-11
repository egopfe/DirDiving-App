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
                if let icon { Image(systemName: icon).font(.caption).foregroundStyle(color) }
                Text(title).font(.caption2).foregroundStyle(DIRTheme.muted)
            }
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(value).font(.system(size: 22, weight: .semibold, design: .rounded)).monospacedDigit().foregroundStyle(color)
                if let unit { Text(unit).font(.caption).foregroundStyle(DIRTheme.muted) }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(RoundedRectangle(cornerRadius: 0).fill(Color.clear))
    }
}
