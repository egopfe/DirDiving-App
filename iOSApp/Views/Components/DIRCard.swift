import SwiftUI

struct DIRCard<Content: View>: View {
    let title: String?
    let icon: String?
    let accent: Color?
    @ViewBuilder let content: Content

    init(_ title: String? = nil, icon: String? = nil, accent: Color? = nil, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.accent = accent
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            if let title {
                HStack {
                    if let icon {
                        Image(systemName: icon)
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(accent ?? DIRTheme.cyan)
                    }
                    Text(title.uppercased())
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .tracking(0.8)
                        .foregroundStyle(.white)
                    Spacer()
                }
            }
            content
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: DIRTheme.cardRadius)
                .fill(
                    LinearGradient(
                        colors: [DIRTheme.surface2.opacity(0.76), DIRTheme.surface.opacity(0.92)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(RoundedRectangle(cornerRadius: DIRTheme.cardRadius).stroke(accent.map { $0.opacity(0.5) } ?? DIRTheme.hairline, lineWidth: 1))
                .overlay(alignment: .leading) {
                    if let accent {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(accent)
                            .frame(width: 3)
                            .padding(.vertical, 10)
                    }
                }
                .shadow(color: (accent ?? DIRTheme.cyan).opacity(0.08), radius: 12, x: 0, y: 8)
        )
    }
}
