import SwiftUI

struct DepthSafetyBannerView: View {
    let state: DepthSafetyState

    var body: some View {
        switch state {
        case .normal:
            EmptyView()
        case .caution:
            depthBanner(
                title: String(localized: "depth.safety.caution.title"),
                subtitle: nil,
                stroke: DiveUI.yellow,
                fillOpacity: 0.10,
                accessibilityLabel: String(localized: "depth.safety.a11y.caution"),
                accessibilityHint: nil
            )
        case .critical:
            depthBanner(
                title: String(localized: "depth.safety.critical.title"),
                subtitle: nil,
                stroke: DiveUI.orange,
                fillOpacity: 0.16,
                accessibilityLabel: String(localized: "depth.safety.a11y.critical"),
                accessibilityHint: nil
            )
        case .exceeded:
            depthBanner(
                title: String(localized: "depth.safety.exceeded.title"),
                subtitle: String(
                    format: "%@\n%@",
                    String(localized: "depth.safety.exceeded.ascend"),
                    String(localized: "depth.safety.exceeded.readings")
                ),
                stroke: DiveUI.red,
                fillOpacity: 0.18,
                accessibilityLabel: String(localized: "depth.safety.a11y.exceeded"),
                accessibilityHint: String(localized: "depth.safety.exceeded.readings")
            )
        }
    }

    private func depthBanner(
        title: String,
        subtitle: String?,
        stroke: Color,
        fillOpacity: Double,
        accessibilityLabel: String,
        accessibilityHint: String?
    ) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            HStack(spacing: 6) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 13, weight: .black))
                Text(title)
                    .font(DiveUI.Typography.bannerTitle)
                    .lineLimit(3)
                    .minimumScaleFactor(0.9)
                    .fixedSize(horizontal: false, vertical: true)
            }
            if let subtitle {
                Text(subtitle)
                    .font(DiveUI.Typography.bannerSubtitle)
                    .lineLimit(2)
                    .minimumScaleFactor(0.9)
            }
        }
        .foregroundStyle(stroke)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 8)
        .padding(.vertical, 8)
        .frame(minHeight: 44)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(stroke.opacity(fillOpacity))
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(stroke.opacity(0.82), lineWidth: 1.2)
                )
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityHint(accessibilityHint ?? "")
    }
}

struct DepthSafetyReadoutStyle {
    let depthColor: Color
    let depthShadow: Color
    let labelColor: Color
    let panelStroke: Color

    static func forState(_ state: DepthSafetyState, redWarningBlink: Bool) -> DepthSafetyReadoutStyle {
        if redWarningBlink {
            return DepthSafetyReadoutStyle(
                depthColor: DiveUI.red,
                depthShadow: DiveUI.red.opacity(0.75),
                labelColor: DiveUI.red,
                panelStroke: DiveUI.red.opacity(0.7)
            )
        }
        switch state {
        case .normal:
            return DepthSafetyReadoutStyle(
                depthColor: .white,
                depthShadow: .clear,
                labelColor: DiveUI.blue,
                panelStroke: .white.opacity(0.34)
            )
        case .caution:
            return DepthSafetyReadoutStyle(
                depthColor: DiveUI.yellow,
                depthShadow: DiveUI.yellow.opacity(0.45),
                labelColor: DiveUI.yellow,
                panelStroke: DiveUI.yellow.opacity(0.72)
            )
        case .critical:
            return DepthSafetyReadoutStyle(
                depthColor: DiveUI.orange,
                depthShadow: DiveUI.orange.opacity(0.55),
                labelColor: DiveUI.orange,
                panelStroke: DiveUI.orange.opacity(0.85)
            )
        case .exceeded:
            return DepthSafetyReadoutStyle(
                depthColor: DiveUI.red,
                depthShadow: DiveUI.red.opacity(0.8),
                labelColor: DiveUI.red,
                panelStroke: DiveUI.red.opacity(0.9)
            )
        }
    }
}
