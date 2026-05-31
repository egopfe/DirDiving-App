import SwiftUI

struct DIRSearchBar: View {
    @Binding var text: String
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass").foregroundStyle(DIRTheme.muted)
            TextField(String(localized: "logbook.search.placeholder"), text: $text)
                .foregroundStyle(.white)
                .accessibilityLabel(String(localized: "logbook.search.a11y"))
        }
        .font(.callout)
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(DIRTheme.surface2.opacity(0.78))
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(DIRTheme.hairline, lineWidth: 1))
        )
    }
}
