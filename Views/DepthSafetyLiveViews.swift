import SwiftUI

struct DepthSafetyBannerView: View {
    let state: DepthSafetyState

    var body: some View {
        switch state {
        case .normal:
            EmptyView()
        case .caution, .critical:
            depthBanner(
                title: String(localized: "depth.safety.approaching.title"),
                subtitle: nil,
                stroke: state == .critical ? DiveUI.orange : DiveUI.yellow,
                fillOpacity: state == .critical ? 0.16 : 0.10
            )
        case .exceeded:
            VStack(spacing: 6) {
                depthBanner(
                    title: String(localized: "depth.safety.exceeded.title"),
                    subtitle: String(localized: "depth.safety.exceeded.ascend"),
                    stroke: DiveUI.red,
                    fillOpacity: 0.18
                )
                depthBanner(
                    title: String(localized: "depth.safety.exceeded.readings"),
                    subtitle: nil,
                    stroke: DiveUI.red.opacity(0.85),
                    fillOpacity: 0.12
                )
            }
        }
    }

    private func depthBanner(title: String, subtitle: String?, stroke: Color, fillOpacity: Double) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            HStack(spacing: 6) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 13, weight: .black))
                Text(title)
                    .font(.system(size: 11, weight: .black, design: .rounded))
                    .lineLimit(3)
                    .minimumScaleFactor(0.72)
                    .fixedSize(horizontal: false, vertical: true)
            }
            if let subtitle {
                Text(subtitle)
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .lineLimit(2)
                    .minimumScaleFactor(0.72)
            }
        }
        .foregroundStyle(stroke)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(stroke.opacity(fillOpacity))
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(stroke.opacity(0.82), lineWidth: 1.2)
                )
        )
        .accessibilityElement(children: .combine)
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
