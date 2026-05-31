import SwiftUI

/// Legacy full-screen ascent warning — superseded by `AscentWarningBannerView` on the live dive screen.
/// Kept as a thin wrapper so existing references compile; do not use for new UI.
struct AscentWarningView: View {
    let status: AscentStatus
    let depthMeters: Double
    let runtime: TimeInterval

    var body: some View {
        AscentWarningBannerView(
            rateMetersPerMinute: status.currentRateMetersPerMinute,
            isActive: status.isOverLimit
        )
    }
}
