import SwiftUI

/// Compact hint for Crown rotation + Action Button primary action during active sessions.
struct WatchUnderwaterPrimaryActionHintView: View {
    @EnvironmentObject private var underwaterRouter: WatchUnderwaterActionRouter
    @EnvironmentObject private var navigation: AppNavigationStore
    @EnvironmentObject private var compass: CompassManager
    @EnvironmentObject private var dive: DiveManager
    @EnvironmentObject private var apneaRuntime: ApneaWatchRuntimeStore
    @EnvironmentObject private var snorkelingRuntime: SnorkelingWatchRuntimeStore

    private var isSessionActive: Bool {
        dive.isDiveActive || apneaRuntime.isSessionActive || snorkelingRuntime.isSessionActive
    }

    private var actionLabel: String {
        let action = underwaterRouter.resolvedPrimaryAction()
        if action == .compassSetOrUpdateBearing, compass.bearingDegrees != nil {
            return String(localized: "watch.hardware.action.update_bearing")
        }
        return action.localizedHintLabel
    }

    var body: some View {
        if isSessionActive {
            VStack(alignment: .trailing, spacing: 2) {
                Text(String(localized: "watch.hardware.crown.screen"))
                    .font(DiveUI.Typography.hintCaption)
                    .foregroundStyle(DiveUI.secondaryText)
                HStack(spacing: 4) {
                    Text(String(localized: "watch.hardware.action.button"))
                        .font(DiveUI.Typography.hintCaption)
                        .foregroundStyle(DiveUI.secondaryText)
                    Text(actionLabel)
                        .font(DiveUI.Typography.hintCaptionBold)
                        .foregroundStyle(DiveUI.cyan)
                        .lineLimit(1)
                        .minimumScaleFactor(0.85)
                }
            }
            .padding(.horizontal, 7)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(Color.black.opacity(0.72))
                    .overlay(
                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .stroke(DiveUI.cyan.opacity(0.45), lineWidth: 0.8)
                    )
            )
            .accessibilityElement(children: .combine)
            .accessibilityLabel(
                String(
                    format: String(localized: "watch.hardware.hint.a11y"),
                    actionLabel
                )
            )
        }
    }
}
