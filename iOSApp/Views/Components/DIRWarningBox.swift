import SwiftUI

enum DIRWarningBoxSeverity {
    case caution
    case critical
    case info

    var accent: Color {
        switch self {
        case .caution: return DIRTheme.yellow
        case .critical: return DIRTheme.red
        case .info: return DIRTheme.cyan
        }
    }

    var iconName: String {
        switch self {
        case .caution: return "exclamationmark.triangle.fill"
        case .critical: return "exclamationmark.octagon.fill"
        case .info: return "info.circle.fill"
        }
    }
}

struct DIRWarningBox: View {
    let text: String
    var severity: DIRWarningBoxSeverity = .caution

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: severity.iconName)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(severity.accent)
            Text(LocalizedStringKey(text))
                .font(DIRTypography.footnote.weight(.medium))
                .foregroundStyle(.white.opacity(severity == .info ? 0.82 : 0.92))
                .lineSpacing(DIRTypography.bodyLineSpacing)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: DIRTheme.cardRadius)
                .fill(severity.accent.opacity(severity == .info ? 0.10 : 0.15))
                .overlay(
                    RoundedRectangle(cornerRadius: DIRTheme.cardRadius)
                        .stroke(severity.accent.opacity(severity == .info ? 0.32 : 0.42), lineWidth: 1)
                )
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel(text)
    }
}
