import SwiftUI

struct DIRSearchBar: View {
    @Binding var text: String
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass").foregroundStyle(DIRTheme.muted)
            TextField("Cerca immersioni", text: $text).foregroundStyle(.white)
        }
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 14).fill(DIRTheme.surface2.opacity(0.90)))
    }
}
