import SwiftUI

struct DIRBackground: View {
    var body: some View {
        ZStack {
            Color.black
            LinearGradient(
                colors: [.black, DIRTheme.background, Color(red: 0.0, green: 0.030, blue: 0.045)],
                startPoint: .top,
                endPoint: .bottom
            )
            RadialGradient(colors: [DIRTheme.cyan.opacity(0.11), .clear], center: .topTrailing, startRadius: 20, endRadius: 360)
            RadialGradient(colors: [DIRTheme.green.opacity(0.08), .clear], center: .bottomLeading, startRadius: 24, endRadius: 420)
            LinearGradient(
                colors: [.white.opacity(0.035), .clear, DIRTheme.cyan.opacity(0.035)],
                startPoint: .top,
                endPoint: .bottom
            )
        }
        .ignoresSafeArea()
    }
}

/// Edge-to-edge decorative background with scrollable or interactive content layered above.
/// Interactive content respects safe areas; only the background ignores them.
struct DIRScreenContainer<Content: View>: View {
    @ViewBuilder private var content: () -> Content

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    var body: some View {
        ZStack(alignment: .top) {
            DIRBackground()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            content()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            DIRBackground()
        }
    }
}
