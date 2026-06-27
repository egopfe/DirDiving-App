import SwiftUI

/// Gradient Factors info + navigation to selection or locked state (mockup screens 4–8 entry).
struct FullComputerGradientFactorsInfoView: View {
    @EnvironmentObject private var dive: DiveManager
    @EnvironmentObject private var activitySelection: DIRActivitySelectionStore
    @ObservedObject private var configuration = FullComputerPrediveConfigurationStore.shared
    @ObservedObject private var importedPlan = FullComputerImportedPlanStore.shared
    @ObservedObject private var gradientFactorStore = FullComputerGradientFactorSettingsStore.shared

    private var lockContext: FullComputerGradientFactorLockContextValues {
        FullComputerGradientFactorLockContextValues.current(
            dive: dive,
            activitySelection: activitySelection,
            importedPlan: importedPlan
        )
    }

    private var resolved: FullComputerResolvedGradientFactors {
        configuration.resolvedGradientFactorsForRuntime(activitySelection: activitySelection)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: DiveUI.spaceL) {
                Image(systemName: "info.circle.fill")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(DiveUI.blue)

                Text(String(localized: "full_computer.gradient_factors.title"))
                    .font(DiveUI.Typography.screenTitle)
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)

                Text(String(localized: "full_computer.gradient_factors.info"))
                    .font(DiveUI.Typography.hintCaption)
                    .foregroundStyle(DiveUI.secondaryText)
                    .multilineTextAlignment(.center)

                if resolved.isLocked {
                    NavigationLink {
                        FullComputerGradientFactorCurrentValueView(resolved: resolved)
                    } label: {
                        currentValueLinkLabel(String(localized: "full_computer.gradient_factors.view_current"))
                    }
                    .buttonStyle(.plain)
                } else {
                    NavigationLink {
                        FullComputerGradientFactorSelectionView()
                    } label: {
                        currentValueLinkLabel(String(localized: "full_computer.gradient_factors.select_preset"))
                    }
                    .buttonStyle(.plain)

                    NavigationLink {
                        FullComputerGradientFactorCurrentValueView(
                            resolved: .watchSettings(preset: gradientFactorStore.selectedWatchPreset)
                        )
                    } label: {
                        currentValueLinkLabel(String(localized: "full_computer.gradient_factors.view_current"))
                    }
                    .buttonStyle(.plain)
                }

                if let reason = lockContext.lockReason {
                    HStack(spacing: 6) {
                        Image(systemName: "lock.fill")
                            .foregroundStyle(lockColor(for: reason))
                        Text(reason.localizedMessage)
                            .font(DiveUI.Typography.hintCaptionBold)
                            .foregroundStyle(lockColor(for: reason))
                            .multilineTextAlignment(.center)
                    }
                }
            }
            .padding(.horizontal, DiveUI.screenPadding)
            .padding(.vertical, 10)
        }
        .navigationTitle(String(localized: "full_computer.gradient_factors.title"))
    }

    private func currentValueLinkLabel(_ title: String) -> some View {
        Text(title)
            .font(DiveUI.Typography.commandButton)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, minHeight: DiveUI.Layout.commandButtonMinHeight)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(DiveUI.subtleStroke, lineWidth: 1)
            )
    }

    private func lockColor(for reason: FullComputerGradientFactorLockReason) -> Color {
        switch reason {
        case .activeDive: return DiveUI.red
        case .importedIOSPlan: return DiveUI.orange
        case .fullComputerRuntimeStarted: return DiveUI.orange
        }
    }
}

@MainActor
struct FullComputerGradientFactorLockContextValues {
    let isDiveActive: Bool
    let isApneaActive: Bool
    let isSnorkelingActive: Bool
    let isFullComputerRuntimeStarted: Bool
    let hasActiveImportedIOSPlan: Bool

    var lockReason: FullComputerGradientFactorLockReason? {
        FullComputerGradientFactorSettingsStore.shared.lockReason(
            isDiveActive: isDiveActive,
            isApneaActive: isApneaActive,
            isSnorkelingActive: isSnorkelingActive,
            isFullComputerRuntimeStarted: isFullComputerRuntimeStarted,
            hasActiveImportedIOSPlan: hasActiveImportedIOSPlan
        )
    }

    static func current(
        dive: DiveManager,
        activitySelection: DIRActivitySelectionStore,
        importedPlan: FullComputerImportedPlanStore
    ) -> FullComputerGradientFactorLockContextValues {
        FullComputerGradientFactorLockContextValues(
            isDiveActive: dive.isDiveActive,
            isApneaActive: ApneaWatchRuntimeStore.shared?.isSessionActive ?? false,
            isSnorkelingActive: SnorkelingWatchRuntimeStore.shared?.isSessionActive ?? false,
            isFullComputerRuntimeStarted: FullComputerGradientFactorLockContext.isFullComputerRuntimeStarted(
                fullComputerPrediveConfirmed: activitySelection.selection.fullComputerPrediveConfirmed,
                hasFullComputerEngine: dive.hasActiveFullComputerEngine,
                sessionConfigured: activitySelection.sessionConfigured,
                divingMode: activitySelection.selection.divingMode
            ),
            hasActiveImportedIOSPlan: importedPlan.hasActiveImportedIOSPlan
        )
    }
}
