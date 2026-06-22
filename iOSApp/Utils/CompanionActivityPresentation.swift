import SwiftUI

enum CompanionActivityPresentation {
    static func title(for mode: DIRActivityMode) -> String {
        CompanionActivityCopy.title(for: mode)
    }

    static func subtitle(for mode: DIRActivityMode) -> String {
        CompanionActivityCopy.subtitle(for: mode)
    }

    static func features(for mode: DIRActivityMode) -> [String] {
        CompanionActivityCopy.features(for: mode)
    }

    static func accent(for mode: DIRActivityMode) -> Color {
        switch mode {
        case .diving: return Color(red: 0.04, green: 0.52, blue: 1.0)
        case .apnea: return Color(red: 0.125, green: 0.78, blue: 0.78)
        case .snorkeling: return DIRTheme.orange
        }
    }

    static func icon(for mode: DIRActivityMode) -> String {
        switch mode {
        case .diving: return "cylinder.fill"
        case .apnea: return "lungs.fill"
        case .snorkeling: return "water.waves.and.arrow.trianglehead.down"
        }
    }

    static func accessibilitySummary(for mode: DIRActivityMode, isLastUsed: Bool = false) -> String {
        CompanionActivityCopy.accessibilitySummary(for: mode, isLastUsed: isLastUsed)
    }

    static func accessibilityHint(for mode: DIRActivityMode, isAvailable: Bool) -> String {
        CompanionActivityCopy.accessibilityHint(for: mode, isAvailable: isAvailable)
    }
}
