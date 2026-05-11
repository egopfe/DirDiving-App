import SwiftUI

struct DIRBackground: View {
    var body: some View {
        LinearGradient(
            colors: [DIRTheme.background, Color(red: 0.0, green: 0.022, blue: 0.050), .black],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
        .overlay {
            RadialGradient(colors: [DIRTheme.cyan.opacity(0.16), .clear], center: .topTrailing, startRadius: 20, endRadius: 420)
                .ignoresSafeArea()
        }
    }
}
