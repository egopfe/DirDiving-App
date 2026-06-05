import SwiftUI

private struct DisclaimerContentHeightKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

private struct DisclaimerViewportHeightKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

private struct DisclaimerBottomMaxYKey: PreferenceKey {
    static var defaultValue: CGFloat = .greatestFiniteMagnitude
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = min(value, nextValue())
    }
}

/// Enables accept when disclaimer fits the viewport or the user scrolls to the end.
struct LegalDisclaimerScrollGate<Content: View>: View {
    @Binding var reachedBottom: Bool
    var maxHeight: CGFloat?
    var heightFraction: CGFloat = IOSCompanionAdaptiveLayout.disclaimerScrollFraction
    @ViewBuilder let content: () -> Content

    @State private var contentHeight: CGFloat = 0
    @State private var viewportHeight: CGFloat = 0
    @State private var bottomMaxY: CGFloat = .greatestFiniteMagnitude

    init(
        reachedBottom: Binding<Bool>,
        maxHeight: CGFloat? = nil,
        heightFraction: CGFloat = IOSCompanionAdaptiveLayout.disclaimerScrollFraction,
        @ViewBuilder content: @escaping () -> Content
    ) {
        _reachedBottom = reachedBottom
        self.maxHeight = maxHeight
        self.heightFraction = heightFraction
        self.content = content
    }

    var body: some View {
        Group {
            if let maxHeight {
                scrollGate(maxHeight: maxHeight)
            } else {
                scrollGate(maxHeight: nil)
                    .containerRelativeFrame(
                        .vertical,
                        count: 100,
                        span: max(28, Int(heightFraction * 100)),
                        spacing: 0,
                        alignment: .top
                    )
            }
        }
    }

    @ViewBuilder
    private func scrollGate(maxHeight: CGFloat?) -> some View {
        ScrollView(showsIndicators: true) {
            VStack(alignment: .leading, spacing: 0) {
                content()
                Color.clear
                    .frame(height: 1)
                    .background(
                        GeometryReader { geo in
                            Color.clear.preference(
                                key: DisclaimerBottomMaxYKey.self,
                                value: geo.frame(in: .named("legalDisclaimerScroll")).maxY
                            )
                        }
                    )
            }
            .background(
                GeometryReader { geo in
                    Color.clear.preference(key: DisclaimerContentHeightKey.self, value: geo.size.height)
                }
            )
        }
        .coordinateSpace(name: "legalDisclaimerScroll")
        .applyDisclaimerMaxHeight(maxHeight)
        .background(
            GeometryReader { geo in
                Color.clear.preference(key: DisclaimerViewportHeightKey.self, value: geo.size.height)
            }
        )
        .onPreferenceChange(DisclaimerContentHeightKey.self) { contentHeight = $0; evaluate() }
        .onPreferenceChange(DisclaimerViewportHeightKey.self) { viewportHeight = $0; evaluate() }
        .onPreferenceChange(DisclaimerBottomMaxYKey.self) { bottomMaxY = $0; evaluate() }
    }

    private func evaluate() {
        guard viewportHeight > 0, contentHeight > 0 else { return }
        if contentHeight <= viewportHeight + 4 {
            reachedBottom = true
            return
        }
        if bottomMaxY <= viewportHeight + 8 {
            reachedBottom = true
        }
    }
}

private extension View {
    @ViewBuilder
    func applyDisclaimerMaxHeight(_ maxHeight: CGFloat?) -> some View {
        if let maxHeight {
            frame(maxHeight: maxHeight)
        } else {
            self
        }
    }
}
