import SwiftUI

/// Viewport metrics derived from the current window — no device-model lookups.
struct IOSCompanionViewportMetrics {
    let size: CGSize
    let safeAreaInsets: EdgeInsets

    init(size: CGSize, safeAreaInsets: EdgeInsets) {
        self.size = size
        self.safeAreaInsets = safeAreaInsets
    }

    /// Interactive area between Dynamic Island/notch and home indicator.
    var contentAreaHeight: CGFloat {
        max(0, size.height - safeAreaInsets.top - safeAreaInsets.bottom)
    }

    var contentAreaWidth: CGFloat {
        max(0, size.width - safeAreaInsets.leading - safeAreaInsets.trailing)
    }

    /// Longest screen edge — used to scale decorative gradients.
    var longestEdge: CGFloat {
        max(size.width, size.height)
    }

    func fractionOfContentArea(_ fraction: CGFloat) -> CGFloat {
        contentAreaHeight * fraction
    }

    func disclaimerScrollHeight(fraction: CGFloat = IOSCompanionAdaptiveLayout.disclaimerScrollFraction) -> CGFloat {
        fractionOfContentArea(fraction)
    }
}

enum IOSCompanionAdaptiveLayout {
    /// Legal disclaimer nested scroll area (step 2 onboarding).
    static let disclaimerScrollFraction: CGFloat = 0.54

    /// Minimum scroll-gate height as a fraction of content area (small phones).
    static let disclaimerScrollMinFraction: CGFloat = 0.28
}

private struct IOSCompanionViewportMetricsKey: EnvironmentKey {
    static let defaultValue = IOSCompanionViewportMetrics(
        size: CGSize(width: 390, height: 844),
        safeAreaInsets: EdgeInsets()
    )
}

extension EnvironmentValues {
    var iosCompanionViewportMetrics: IOSCompanionViewportMetrics {
        get { self[IOSCompanionViewportMetricsKey.self] }
        set { self[IOSCompanionViewportMetricsKey.self] = newValue }
    }
}
