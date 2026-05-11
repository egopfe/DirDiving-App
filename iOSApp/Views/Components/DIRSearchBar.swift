import SwiftUI

struct DIRSearchBar: View {
    @Binding var text: String
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass").foregroundStyle(DIRTheme.muted)
            TextField("Cerca immersioni", text: $text).foregroundStyle(.white)
        }
        .font(.callout)
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(RoundedRectangle(cornerRadius: 8).fill(DIRTheme.surface2.opacity(0.78)))
    }
}
