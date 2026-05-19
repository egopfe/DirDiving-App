import SwiftUI

struct DIRSectionHeader: View {
    let title: String
    var subtitle: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(LocalizedStringKey(title.uppercased()))
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .tracking(1.1)
                .foregroundStyle(DIRTheme.cyan)
            if let subtitle {
                Text(LocalizedStringKey(subtitle))
                    .font(.footnote)
                    .foregroundStyle(DIRTheme.muted)
            }
        }
    }
}
