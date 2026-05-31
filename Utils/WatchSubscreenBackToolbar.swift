import SwiftUI

/// Ensures a visible back affordance on pushed Watch settings/sub-screens (watchOS TabView stack).
struct WatchSubscreenBackToolbar: ViewModifier {
    @Environment(\.dismiss) private var dismiss

    func body(content: Content) -> some View {
        content
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        HStack(spacing: 2) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 11, weight: .bold))
                            Text(String(localized: "watch.nav.back"))
                                .font(.system(size: 10, weight: .semibold, design: .rounded))
                        }
                        .foregroundStyle(DiveUI.cyan)
                    }
                    .buttonStyle(.plain)
                }
            }
    }
}

extension View {
    func watchSubscreenBackToolbar() -> some View {
        modifier(WatchSubscreenBackToolbar())
    }
}
