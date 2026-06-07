import SwiftUI
import UIKit

enum DiveUI {
    static let blue = Color(red: 0.0, green: 0.56, blue: 1.0)
    static let cyan = Color(red: 0.02, green: 0.92, blue: 0.96)
    static let green = Color(red: 0.16, green: 0.9, blue: 0.36)
    static let yellow = Color(red: 1.0, green: 0.84, blue: 0.04)
    static let red = Color(red: 1.0, green: 0.22, blue: 0.18)
    static let orange = Color(red: 1.0, green: 0.56, blue: 0.0)

    static let backgroundTop = Color.black
    static let backgroundBottom = Color(red: 0.0, green: 0.025, blue: 0.036)
    static let panelFill = Color(red: 0.008, green: 0.012, blue: 0.016)
    static let panelFillRaised = Color(red: 0.018, green: 0.026, blue: 0.032)
    static let secondaryText = Color.white.opacity(0.7)
    static let mutedText = Color.white.opacity(0.52)
    static let subtleStroke = Color.white.opacity(0.28)
    static let hairline = Color.white.opacity(0.16)
    static let panelRadius: CGFloat = 12
    static let screenPadding: CGFloat = 10

    // Spacing scale (Apple Watch)
    static let spaceXS: CGFloat = 3
    static let spaceS: CGFloat = 6
    static let spaceM: CGFloat = 8
    static let spaceL: CGFloat = 10
    static let spaceXL: CGFloat = 12

    enum Layout {
        static let settingsRowInteractiveMinHeight: CGFloat = 44
        static let settingsRowInfoMinHeight: CGFloat = 40
        static let settingsRowLegalMinHeight: CGFloat = 48
        static let commandButtonMinHeight: CGFloat = 40
        static let compassActionMinHeight: CGFloat = 38
        static let alarmStepperMinHeight: CGFloat = 40
    }

    /// Watch-native readability hierarchy (audit: DIR_DIVING_WATCH_UI_TEXT_VISIBILITY_AUDIT_CURRENT).
    enum Typography {
        static let brandTitle: Font = .system(size: 15, weight: .black, design: .rounded)
        static let brandTitleCompact: Font = .system(size: 12, weight: .black, design: .rounded)
        static let clock: Font = .system(size: 14, weight: .semibold, design: .rounded)
        static let clockLarge: Font = .system(size: 20, weight: .semibold, design: .rounded)
        static let screenTitle: Font = .system(size: 15, weight: .black, design: .rounded)
        static let sectionHeading: Font = .system(size: 12.5, weight: .bold, design: .rounded)
        static let rowTitle: Font = .system(size: 13.5, weight: .semibold, design: .rounded)
        static let rowSubtitle: Font = .system(size: 11.5, weight: .medium, design: .rounded)
        static let statusValue: Font = .system(size: 13, weight: .semibold, design: .rounded)
        static let warningTitle: Font = .system(size: 13, weight: .black, design: .rounded)
        static let warningBody: Font = .system(size: 11.5, weight: .semibold, design: .rounded)
        static let secondaryLabel: Font = .system(size: 11, weight: .semibold, design: .rounded)
        static let unitLabel: Font = .system(size: 11, weight: .semibold, design: .rounded)
        static let metricLabel: Font = .system(size: 11, weight: .bold, design: .rounded)
        static let metricValue: Font = .system(size: 24, weight: .regular, design: .rounded)
        static let metricValueHero: Font = .system(size: 72, weight: .black, design: .rounded)
        static let metricUnitHero: Font = .system(size: 31, weight: .black, design: .rounded)
        static let metricUnit: Font = unitLabel
        static let dashboardLabel: Font = .system(size: 13, weight: .semibold, design: .rounded)
        static let dashboardValue: Font = .system(size: 34, weight: .black, design: .rounded)
        static let dashboardUnit: Font = .system(size: 12, weight: .semibold, design: .rounded)
        static let depthCaption: Font = .system(size: 15, weight: .black, design: .rounded)
        static let statusTitle: Font = .system(size: 15, weight: .black, design: .rounded)
        static let bannerTitle: Font = warningTitle
        static let bannerSubtitle: Font = warningBody
        static let bannerDetail: Font = secondaryLabel
        static let settingsSection: Font = sectionHeading
        static let commandButton: Font = .system(size: 12, weight: .bold, design: .rounded)
        static let readyTitle: Font = .system(size: 18, weight: .black, design: .rounded)
        static let hintCaption: Font = .system(size: 10, weight: .semibold, design: .rounded)
        static let hintCaptionBold: Font = .system(size: 10, weight: .bold, design: .rounded)
        static let destructiveAction: Font = .system(size: 11, weight: .black, design: .rounded)
    }

    /// Ascent alarm palette — high contrast, aligned with `DiveUI.red` family.
    static let alarmRed = Color(red: 1.0, green: 0.22, blue: 0.18)
    static let alarmFill = Color(red: 0.12, green: 0.02, blue: 0.02)
    static let alarmText = Color.white.opacity(0.96)
}

struct DiveScreenBackground: View {
    var body: some View {
        ZStack {
            Color.black
            LinearGradient(
                colors: [DiveUI.backgroundTop, DiveUI.backgroundBottom],
                startPoint: .top,
                endPoint: .bottom
            )
            RadialGradient(
                colors: [DiveUI.blue.opacity(0.16), .clear],
                center: .topTrailing,
                startRadius: 12,
                endRadius: 160
            )
            RadialGradient(
                colors: [DiveUI.green.opacity(0.08), .clear],
                center: .bottomLeading,
                startRadius: 8,
                endRadius: 150
            )
        }
        .ignoresSafeArea()
    }
}

struct DivePanel<Content: View>: View {
    let stroke: Color
    let content: Content

    init(stroke: Color = DiveUI.subtleStroke, @ViewBuilder content: () -> Content) {
        self.stroke = stroke
        self.content = content()
    }

    var body: some View {
        content
            .padding(10)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: DiveUI.panelRadius, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [DiveUI.panelFillRaised.opacity(0.94), DiveUI.panelFill.opacity(0.98)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: DiveUI.panelRadius, style: .continuous)
                            .stroke(stroke.opacity(0.88), lineWidth: 1)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: DiveUI.panelRadius - 2, style: .continuous)
                            .stroke(.white.opacity(0.055), lineWidth: 0.7)
                            .padding(1)
                    )
                    .shadow(color: stroke.opacity(0.18), radius: 5, x: 0, y: 0)
            )
    }
}

struct WatchSettingsSectionHeader: View {
    let title: String

    var body: some View {
        Text(LocalizedStringKey(title))
            .font(DiveUI.Typography.sectionHeading)
            .foregroundStyle(DiveUI.cyan)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, DiveUI.spaceM)
            .padding(.bottom, 2)
    }
}

struct WatchSettingsRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    var showsChevron: Bool = false
    var informational: Bool = false
    var legal: Bool = false
    var statusEmphasis: Bool = false

    private var minHeight: CGFloat {
        if legal { return DiveUI.Layout.settingsRowLegalMinHeight }
        if informational { return DiveUI.Layout.settingsRowInfoMinHeight }
        return DiveUI.Layout.settingsRowInteractiveMinHeight
    }

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(iconColor)
                .frame(width: 26)

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(DiveUI.Typography.rowTitle)
                    .foregroundStyle(.white)
                    .lineLimit(2)
                    .minimumScaleFactor(0.9)
                Text(subtitle)
                    .font(statusEmphasis ? DiveUI.Typography.statusValue : DiveUI.Typography.rowSubtitle)
                    .foregroundStyle(statusEmphasis ? .white : (informational ? DiveUI.secondaryText : .white.opacity(0.92)))
                    .lineLimit(informational || statusEmphasis ? 3 : 2)
                    .fixedSize(horizontal: false, vertical: informational || statusEmphasis)
            }

            Spacer(minLength: 0)

            if showsChevron {
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(.white.opacity(0.5))
            } else if informational {
                Image(systemName: "info.circle")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(DiveUI.secondaryText)
                    .accessibilityLabel(Text(LocalizedStringKey("settings.informational.a11y.hint")))
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .frame(minHeight: minHeight)
        .opacity(informational && !statusEmphasis ? 0.94 : 1)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(informational ? [] : (showsChevron ? .isButton : []))
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color.black.opacity(informational && !statusEmphasis ? 0.38 : 0.52))
                .overlay(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(.white.opacity(informational && !statusEmphasis ? 0.16 : 0.24), lineWidth: 1)
                )
        )
    }
}

struct DiveCommandButton: View {
    let title: String
    let systemImage: String?
    let color: Color
    let action: () -> Void

    init(_ title: String, systemImage: String? = nil, color: Color, action: @escaping () -> Void) {
        self.title = title
        self.systemImage = systemImage
        self.color = color
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 5) {
                Text(LocalizedStringKey(title))
                    .font(DiveUI.Typography.commandButton)
                    .lineLimit(2)
                    .minimumScaleFactor(0.85)
                if let systemImage {
                    Image(systemName: systemImage)
                        .font(.system(size: 12, weight: .bold))
                }
            }
            .foregroundStyle(color)
            .frame(maxWidth: .infinity, minHeight: DiveUI.Layout.commandButtonMinHeight)
            .padding(.horizontal, 5)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(color.opacity(0.13))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .stroke(color.opacity(0.86), lineWidth: 1)
                    )
                    .shadow(color: color.opacity(0.16), radius: 4, x: 0, y: 0)
            )
            .contentShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text(LocalizedStringKey(title)))
        .accessibilityHint(Text(LocalizedStringKey("accessibility.command_button.hint")))
    }
}

/// Compact high-contrast status/warning strip for Watch live surfaces.
struct DiveInlineStatusBanner: View {
    let systemImage: String
    let title: String
    let detail: String?
    let color: Color

    init(systemImage: String, title: String, detail: String? = nil, color: Color) {
        self.systemImage = systemImage
        self.title = title
        self.detail = detail
        self.color = color
    }

    var body: some View {
        HStack(spacing: DiveUI.spaceS) {
            Image(systemName: systemImage)
                .font(.system(size: 14, weight: .black))
            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(DiveUI.Typography.bannerTitle)
                    .lineLimit(2)
                    .minimumScaleFactor(0.9)
                if let detail {
                    Text(detail)
                        .font(DiveUI.Typography.bannerDetail)
                        .lineLimit(3)
                        .minimumScaleFactor(0.9)
                }
            }
            Spacer(minLength: 0)
        }
        .foregroundStyle(color)
        .padding(.horizontal, DiveUI.spaceM)
        .padding(.vertical, 5)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 9, style: .continuous)
                .fill(color.opacity(0.11))
                .overlay(
                    RoundedRectangle(cornerRadius: 9, style: .continuous)
                        .stroke(color.opacity(0.72), lineWidth: 1)
                )
        )
    }
}

struct DiveClockText: View {
    var size: CGFloat = 14

    var body: some View {
        TimelineView(.periodic(from: .now, by: 30)) { context in
            Text(context.date, format: .dateTime.hour().minute())
                .font(.system(size: size, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
                .monospacedDigit()
        }
    }
}

struct DiveMetric: View {
    let title: String
    let value: String
    let unit: String?
    let color: Color
    let valueSize: CGFloat

    init(_ title: String, value: String, unit: String? = nil, color: Color = DiveUI.blue, valueSize: CGFloat = 24) {
        self.title = title
        self.value = value
        self.unit = unit
        self.color = color
        self.valueSize = valueSize
    }

    var body: some View {
        VStack(spacing: 2) {
            Text(LocalizedStringKey(title.uppercased()))
                .font(DiveUI.Typography.metricLabel)
                .foregroundStyle(DiveUI.secondaryText)
                .lineLimit(2)
                .minimumScaleFactor(0.88)
            HStack(alignment: .lastTextBaseline, spacing: 3) {
                Text(value)
                    .font(.system(size: valueSize, weight: .regular, design: .rounded)) // valueSize override for compact metrics
                    .minimumScaleFactor(0.85)
                    .lineLimit(1)
                    .monospacedDigit()
                    .foregroundStyle(color)
                if let unit {
                    Text(unit)
                        .font(DiveUI.Typography.metricUnit)
                        .foregroundStyle(color)
                        .lineLimit(1)
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
}

struct DiveScreenHeader: View {
    let title: String
    let subtitle: String?
    let accent: Color
    let systemImage: String?

    init(_ title: String, subtitle: String? = nil, accent: Color = DiveUI.blue, systemImage: String? = nil) {
        self.title = title
        self.subtitle = subtitle
        self.accent = accent
        self.systemImage = systemImage
    }

    var body: some View {
        HStack(spacing: 8) {
            DiveOctopusLogo()
            VStack(alignment: .leading, spacing: 1) {
                HStack(spacing: 5) {
                    if let systemImage {
                        Image(systemName: systemImage)
                    }
                    Text(LocalizedStringKey(title))
                }
                .font(.caption.bold())
                .foregroundStyle(accent)
                if let subtitle {
                    Text(LocalizedStringKey(subtitle))
                        .font(DiveUI.Typography.secondaryLabel)
                        .foregroundStyle(DiveUI.secondaryText)
                        .lineLimit(2)
                        .minimumScaleFactor(0.9)
                }
            }
            Spacer()
            HStack(spacing: 3) {
                Image(systemName: "digitalcrown.horizontal.press")
                    .font(.system(size: 10, weight: .bold))
                Text("CROWN")
                    .font(.system(size: 10, weight: .bold, design: .rounded))
            }
            .foregroundStyle(DiveUI.mutedText)
            .padding(.horizontal, 6)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .stroke(DiveUI.hairline, lineWidth: 1)
            )
        }
    }
}

struct DiveStatusPill: View {
    let text: String
    let color: Color
    let systemImage: String?

    init(_ text: String, color: Color, systemImage: String? = nil) {
        self.text = text
        self.color = color
        self.systemImage = systemImage
    }

    var body: some View {
        HStack(spacing: 4) {
            if let systemImage {
                Image(systemName: systemImage)
            }
            Text(LocalizedStringKey(text))
        }
        .font(DiveUI.Typography.secondaryLabel)
        .lineLimit(2)
        .minimumScaleFactor(0.9)
        .foregroundStyle(color)
        .padding(.horizontal, 7)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(color.opacity(0.12))
                .overlay(Capsule().stroke(color.opacity(0.72), lineWidth: 1))
        )
    }
}

struct DiveOctopusLogo: View {
    var accent: Color = DiveUI.blue

    var body: some View {
        Group {
            if let url = Bundle.main.url(forResource: "altosinistra", withExtension: "png"),
               let uiImage = UIImage(contentsOfFile: url.path) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
            } else {
                drawnLogo
            }
        }
        .frame(width: 36, height: 32)
    }

    private var drawnLogo: some View {
        ZStack {
            Circle()
                .fill(accent.opacity(0.22))
                .frame(width: 21, height: 21)
                .offset(y: -4)
                .shadow(color: accent.opacity(0.55), radius: 5, x: 0, y: 0)
            Circle()
                .stroke(accent, lineWidth: 2)
                .frame(width: 21, height: 21)
                .offset(y: -4)
            HStack(spacing: 5) {
                Circle().fill(accent).frame(width: 3, height: 3)
                Circle().fill(accent).frame(width: 3, height: 3)
            }
            .offset(y: -5)
            DiveOctopusTentacles()
                .stroke(accent, style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                .frame(width: 31, height: 18)
                .offset(y: 8)
        }
    }
}

/// Legacy dive-widget compass ring used outside MAIN Compass tab (e.g. experimental concepts).
/// MAIN `CompassView` uses the dedicated BUSSOLA dial — do not route new UI through this component.
@available(*, deprecated, message: "Use CompassView for MAIN BUSSOLA. Retained for legacy widget layouts only.")
struct DiveBearingRing: View {
    let headingDegrees: Double
    let bearingDelta: Double?
    let accent: Color
    let size: CGFloat

    init(headingDegrees: Double, bearingDelta: Double? = nil, accent: Color = DiveUI.blue, size: CGFloat = 112) {
        self.headingDegrees = headingDegrees
        self.bearingDelta = bearingDelta
        self.accent = accent
        self.size = size
    }

    var body: some View {
        ZStack {
            Circle()
                .fill(DiveUI.panelFill.opacity(0.82))
            Circle()
                .stroke(DiveUI.hairline, lineWidth: 1)
            Circle()
                .trim(from: 0, to: 0.72)
                .stroke(accent.opacity(0.9), style: StrokeStyle(lineWidth: 2, lineCap: .round))
                .rotationEffect(.degrees(-126))
                .shadow(color: accent.opacity(0.35), radius: 5, x: 0, y: 0)

            ForEach(0..<12, id: \.self) { tick in
                Rectangle()
                    .fill(tick % 3 == 0 ? .white.opacity(0.82) : DiveUI.hairline)
                    .frame(width: tick % 3 == 0 ? 2 : 1, height: tick % 3 == 0 ? 10 : 6)
                    .offset(y: -size * 0.43)
                    .rotationEffect(.degrees(Double(tick) * 30))
            }

            VStack(spacing: 0) {
                Text(cardinal)
                    .font(.system(size: 15, weight: .black, design: .rounded))
                    .foregroundStyle(accent)
                Text("\(Int(headingDegrees.rounded()))\u{00B0}")
                    .font(.system(size: 25, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(.white)
            }

            Image(systemName: "location.north.fill")
                .font(.system(size: size * 0.18, weight: .black))
                .foregroundStyle(bearingDelta == nil ? accent : DiveUI.yellow)
                .offset(y: -size * 0.31)
                .rotationEffect(.degrees(bearingDelta ?? headingDegrees))
                .animation(.easeInOut(duration: 0.25), value: headingDegrees)
                .animation(.easeInOut(duration: 0.25), value: bearingDelta ?? 0)
        }
        .frame(width: size, height: size)
    }

    private var cardinal: String {
        let normalized = (headingDegrees.truncatingRemainder(dividingBy: 360) + 360).truncatingRemainder(dividingBy: 360)
        switch normalized {
        case 337.5..<360, 0..<22.5: return "N"
        case 22.5..<67.5: return "NE"
        case 67.5..<112.5: return "E"
        case 112.5..<157.5: return "SE"
        case 157.5..<202.5: return "S"
        case 202.5..<247.5: return "SW"
        case 247.5..<292.5: return "W"
        default: return "NW"
        }
    }
}

private struct DiveOctopusTentacles: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let top = rect.minY + 2
        let bottom = rect.maxY - 2
        let centers: [CGFloat] = [0.12, 0.3, 0.5, 0.7, 0.88]

        for center in centers {
            let x = rect.minX + rect.width * center
            path.move(to: CGPoint(x: x, y: top))
            path.addCurve(
                to: CGPoint(x: x + (center < 0.5 ? -3 : center > 0.5 ? 3 : 0), y: bottom),
                control1: CGPoint(x: x - 5, y: top + 4),
                control2: CGPoint(x: x + 5, y: bottom - 4)
            )
        }

        return path
    }
}
