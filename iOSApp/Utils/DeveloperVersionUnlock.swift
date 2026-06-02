import SwiftUI

struct DeveloperVersionUnlockGesture: ViewModifier {
    @Binding var tapCount: Int
    var onUnlocked: () -> Void

    func body(content: Content) -> some View {
        content
            .contentShape(Rectangle())
            .onTapGesture {
                tapCount += 1
                guard tapCount >= 7 else { return }
                tapCount = 0
                DeveloperSettings.unlockDeveloperSection()
                onUnlocked()
            }
    }
}

extension View {
    func developerVersionUnlock(tapCount: Binding<Int>, onUnlocked: @escaping () -> Void) -> some View {
        modifier(DeveloperVersionUnlockGesture(tapCount: tapCount, onUnlocked: onUnlocked))
    }
}
