import SwiftUI

/// Three-preset GF selection menu (mockup screen 5).
struct FullComputerGradientFactorSelectionView: View {
    @EnvironmentObject private var dive: DiveManager
    @EnvironmentObject private var activitySelection: DIRActivitySelectionStore
    @ObservedObject private var gradientFactorStore = FullComputerGradientFactorSettingsStore.shared
    @ObservedObject private var importedPlan = FullComputerImportedPlanStore.shared
    @Environment(\.dismiss) private var dismiss

    private var lockContext: FullComputerGradientFactorLockContextValues {
        FullComputerGradientFactorLockContextValues.current(
            dive: dive,
            activitySelection: activitySelection,
            importedPlan: importedPlan
        )
    }

    private var isLocked: Bool {
        gradientFactorStore.isModificationBlocked(
            isDiveActive: lockContext.isDiveActive,
            isApneaActive: lockContext.isApneaActive,
            isSnorkelingActive: lockContext.isSnorkelingActive,
            isFullComputerRuntimeStarted: lockContext.isFullComputerRuntimeStarted,
            hasActiveImportedIOSPlan: lockContext.hasActiveImportedIOSPlan
        )
    }

    var body: some View {
        ScrollView {
            VStack(spacing: DiveUI.spaceL) {
                Text(String(localized: "full_computer.gradient_factors.select_title"))
                    .font(DiveUI.Typography.screenTitle)
                    .foregroundStyle(DiveUI.cyan)
                    .multilineTextAlignment(.center)

                VStack(spacing: 0) {
                    ForEach(FullComputerGradientFactorPreset.allCases) { preset in
                        presetRow(preset)
                        if preset != FullComputerGradientFactorPreset.allCases.last {
                            Divider().overlay(DiveUI.subtleStroke)
                        }
                    }
                }
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(Color.black.opacity(0.52))
                        .overlay(RoundedRectangle(cornerRadius: 10, style: .continuous).stroke(DiveUI.subtleStroke, lineWidth: 1))
                )

                Text(String(localized: "full_computer.gradient_factors.used_without_ios_plan"))
                    .font(DiveUI.Typography.hintCaption)
                    .foregroundStyle(DiveUI.mutedText)
                    .multilineTextAlignment(.center)

                if isLocked, let reason = lockContext.lockReason {
                    HStack(spacing: 6) {
                        Image(systemName: "lock.fill")
                            .foregroundStyle(DiveUI.orange)
                        Text(reason.localizedMessage)
                            .font(DiveUI.Typography.hintCaptionBold)
                            .foregroundStyle(DiveUI.orange)
                            .multilineTextAlignment(.center)
                    }
                }
            }
            .padding(.horizontal, DiveUI.screenPadding)
            .padding(.vertical, 10)
        }
        .navigationTitle(String(localized: "full_computer.gradient_factors.title"))
    }

    private func presetRow(_ preset: FullComputerGradientFactorPreset) -> some View {
        let selected = gradientFactorStore.selectedWatchPreset == preset
        return Button {
            guard !isLocked else {
                HapticService.shared.notify()
                return
            }
            let updated = gradientFactorStore.updateWatchPreset(
                preset,
                isDiveActive: lockContext.isDiveActive,
                isApneaActive: lockContext.isApneaActive,
                isSnorkelingActive: lockContext.isSnorkelingActive,
                isFullComputerRuntimeStarted: lockContext.isFullComputerRuntimeStarted,
                hasActiveImportedIOSPlan: lockContext.hasActiveImportedIOSPlan
            )
            if updated {
                HapticService.shared.confirm()
                dismiss()
            } else {
                HapticService.shared.notify()
            }
        } label: {
            HStack(alignment: .top, spacing: 10) {
                Circle()
                    .fill(indicatorColor(for: preset))
                    .frame(width: 10, height: 10)
                    .padding(.top, 4)

                VStack(alignment: .leading, spacing: 3) {
                    Text(preset.localizedTitle)
                        .font(DiveUI.Typography.rowTitle)
                        .foregroundStyle(.white)
                    Text(preset.localizedValue)
                        .font(DiveUI.Typography.rowSubtitle)
                        .foregroundStyle(DiveUI.green)
                    Text(preset.localizedSubtitle)
                        .font(DiveUI.Typography.hintCaption)
                        .foregroundStyle(DiveUI.secondaryText)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 0)

                if selected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(DiveUI.blue)
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .opacity(isLocked ? 0.55 : 1)
        }
        .buttonStyle(.plain)
        .disabled(isLocked)
        .accessibilityIdentifier("full_computer_gf_preset_\(preset.rawValue)")
    }

    private func indicatorColor(for preset: FullComputerGradientFactorPreset) -> Color {
        switch preset {
        case .conservative2080: return DiveUI.red
        case .standard3070: return DiveUI.blue
        case .moderate4085: return DiveUI.orange
        }
    }
}
