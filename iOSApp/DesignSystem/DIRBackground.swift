import SwiftUI

struct DIRBackground: View {
    var body: some View {
        LinearGradient(
            colors: [.black, DIRTheme.background, Color(red: 0.0, green: 0.030, blue: 0.045)],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
        .overlay {
            RadialGradient(colors: [DIRTheme.cyan.opacity(0.11), .clear], center: .topTrailing, startRadius: 20, endRadius: 360)
                .ignoresSafeArea()
        }
    }
}
