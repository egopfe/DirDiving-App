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
                        WatchBackButtonLabel()
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(String(localized: "watch.nav.back.a11y"))
                }
            }
    }
}

extension View {
    func watchSubscreenBackToolbar() -> some View {
        modifier(WatchSubscreenBackToolbar())
    }
}
