import SwiftUI

/// Shared iOS Companion typography — visual-only tokens aligned with `DIRTheme`.
enum DIRTypography {
    static let screenTitle = Font.system(size: 30, weight: .bold, design: .rounded)
    static let screenSubtitle = Font.callout
    static let sectionTitle = Font.system(size: 13, weight: .bold, design: .rounded)
    static let cardTitle = Font.system(size: 13, weight: .bold, design: .rounded)
    static let body = Font.callout
    static let bodyMedium = Font.callout.weight(.medium)
    static let label = Font.subheadline
    static let value = Font.title3.weight(.semibold)
    static let metricValue = Font.system(size: 28, weight: .bold, design: .rounded)
    static let metricUnit = Font.caption.weight(.semibold)
    static let caption = Font.caption
    static let captionSemibold = Font.caption.weight(.semibold)
    static let footnote = Font.footnote
    static let legalBody = Font.callout.weight(.medium)
    static let warning = Font.subheadline.weight(.semibold)

    static let sectionTracking: CGFloat = 0.8
    static let bodyLineSpacing: CGFloat = 4
    static let legalLineSpacing: CGFloat = 5
}

extension View {
    func dirScreenTitleStyle() -> some View {
        font(DIRTypography.screenTitle)
            .foregroundStyle(.white)
    }

    func dirScreenSubtitleStyle() -> some View {
        font(DIRTypography.screenSubtitle)
            .foregroundStyle(DIRTheme.muted)
            .lineSpacing(2)
    }

    func dirLegalBodyStyle() -> some View {
        font(DIRTypography.legalBody)
            .foregroundStyle(.white.opacity(0.9))
            .lineSpacing(DIRTypography.legalLineSpacing)
            .fixedSize(horizontal: false, vertical: true)
    }
}
