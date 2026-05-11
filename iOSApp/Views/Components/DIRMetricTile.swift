import SwiftUI

struct DIRMetricTile: View {
    let title: String
    let value: String
    var unit: String?
    var color: Color = .white
    var icon: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                if let icon { Image(systemName: icon).font(.caption).foregroundStyle(color) }
                Text(title.uppercased()).font(.caption2).foregroundStyle(DIRTheme.muted)
                Spacer()
            }
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(value).font(.system(size: 26, weight: .bold, design: .rounded)).foregroundStyle(color)
                if let unit { Text(unit).font(.caption).foregroundStyle(DIRTheme.muted) }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(RoundedRectangle(cornerRadius: 18).fill(DIRTheme.surface2.opacity(0.90)))
    }
}
