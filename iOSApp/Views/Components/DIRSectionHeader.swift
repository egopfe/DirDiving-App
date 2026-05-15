import SwiftUI

struct DIRSectionHeader: View {
    let title: String
    var subtitle: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title.uppercased()).font(.caption.weight(.bold)).tracking(1.3).foregroundStyle(DIRTheme.cyan)
            if let subtitle { Text(subtitle).font(.footnote).foregroundStyle(DIRTheme.muted) }
        }
    }
}
