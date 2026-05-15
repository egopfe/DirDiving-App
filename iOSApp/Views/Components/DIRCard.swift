import SwiftUI

struct DIRCard<Content: View>: View {
    let title: String?
    let icon: String?
    @ViewBuilder let content: Content

    init(_ title: String? = nil, icon: String? = nil, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            if let title {
                HStack {
                    if let icon { Image(systemName: icon).foregroundStyle(DIRTheme.cyan) }
                    Text(title).font(.headline).foregroundStyle(.white)
                    Spacer()
                }
            }
            content
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: DIRTheme.cardRadius)
                .fill(DIRTheme.surface.opacity(0.86))
                .overlay(RoundedRectangle(cornerRadius: DIRTheme.cardRadius).stroke(DIRTheme.hairline, lineWidth: 1))
        )
    }
}
