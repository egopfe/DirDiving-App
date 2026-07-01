import SwiftUI
import WatchConnectivity

struct IOSApneaSessionPlannerView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var plannerStore: IOSApneaPlannerStore
    @EnvironmentObject private var profileStore: IOSApneaProfileStore
    @EnvironmentObject private var settingsStore: IOSApneaSettingsStore
    @EnvironmentObject private var transferService: IOSApneaWatchTransferService
    @EnvironmentObject private var watchSync: WatchSyncService

    @State private var transferMessage: String?

    var body: some View {
        DIRScreenContainer {
            Form {
                Section(DIRIOSLocalizer.string("apnea.ios.planner.title_field")) {
                    TextField(DIRIOSLocalizer.string("apnea.ios.planner.title_field"), text: $plannerStore.draftPlan.title)
                        .onChange(of: plannerStore.draftPlan.title) { _, _ in plannerStore.persist() }
                }

                Section(DIRIOSLocalizer.string("apnea.ios.planner.session_type")) {
                    Picker(DIRIOSLocalizer.string("apnea.ios.planner.session_type"), selection: Binding(
                        get: { plannerStore.draftPlan.kind },
                        set: { plannerStore.setKind($0) }
                    )) {
                        Text(DIRIOSLocalizer.string("apnea.ios.planner.kind.pyramid")).tag(ApneaSessionPlanKind.pyramid)
                        Text(DIRIOSLocalizer.string("apnea.ios.planner.kind.custom")).tag(ApneaSessionPlanKind.custom)
                        Text(DIRIOSLocalizer.string("apnea.ios.planner.kind.repeated")).tag(ApneaSessionPlanKind.repeatedDepth)
                    }
                }

                Section(DIRIOSLocalizer.string("apnea.ios.profiles.title")) {
                    Picker(DIRIOSLocalizer.string("apnea.ios.profiles.title"), selection: Binding(
                        get: { plannerStore.draftPlan.profileID ?? profileStore.allProfiles().first?.id },
                        set: { profileID in
                            guard let profileID,
                                  let profile = profileStore.profile(id: profileID) else { return }
                            plannerStore.applyProfile(profile)
                        }
                    )) {
                        ForEach(profileStore.allProfiles()) { profile in
                            Text(profile.isPreset ? DIRIOSLocalizer.string(profile.displayName) : profile.displayName)
                                .tag(Optional(profile.id))
                        }
                    }
                }

                Section(DIRIOSLocalizer.string("apnea.ios.planner.series")) {
                    ForEach(plannerStore.draftPlan.entries.sorted { $0.orderIndex < $1.orderIndex }) { entry in
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(String(format: "%.0f m", entry.targetDepthMeters))
                                Spacer()
                                Text(Formatters.time(entry.targetDurationSeconds))
                                Spacer()
                                Text(Formatters.time(entry.plannedRecoverySeconds))
                            }
                            .font(.subheadline.monospacedDigit())
                        }
                        .swipeActions {
                            Button(role: .destructive) {
                                plannerStore.removeEntry(id: entry.id)
                            } label: {
                                Text(DIRIOSLocalizer.string("common.delete"))
                            }
                        }
                    }
                    Button(DIRIOSLocalizer.string("apnea.ios.planner.add_dive")) {
                        plannerStore.addEntry()
                    }
                }

                Section(DIRIOSLocalizer.string("apnea.ios.planner.recovery")) {
                    Text(recoverySummary)
                        .foregroundStyle(DIRTheme.muted)
                }

                Section(DIRIOSLocalizer.string("apnea.ios.planner.notes")) {
                    TextField(DIRIOSLocalizer.string("apnea.ios.planner.notes"), text: Binding(
                        get: { plannerStore.draftPlan.notes ?? "" },
                        set: {
                            plannerStore.draftPlan.notes = $0.isEmpty ? nil : $0
                            plannerStore.persist()
                        }
                    ), axis: .vertical)
                }

                Section(DIRIOSLocalizer.string("apnea.ios.planner.readiness")) {
                    if plannerStore.validationIssues.isEmpty {
                        Text(DIRIOSLocalizer.string("apnea.session_check.ready"))
                            .foregroundStyle(DIRTheme.green)
                            .font(.headline.weight(.semibold))
                    } else {
                        ForEach(plannerStore.validationIssues, id: \.self) { issue in
                            Text(validationText(for: issue))
                                .foregroundStyle(DIRTheme.orange)
                                .font(.caption)
                        }
                    }
                }

                Section(DIRIOSLocalizer.string("apnea.ios.planner.watch_transfer")) {
                    HStack(spacing: 10) {
                        Image(systemName: transferStatusIcon)
                            .foregroundStyle(transferStatusColor)
                        Text(transferMessage ?? transferStatusText(transferService.state))
                            .foregroundStyle(DIRTheme.muted)
                            .font(.caption)
                    }
                }
            }
            .scrollContentBackground(.hidden)
        }
        .navigationTitle(DIRIOSLocalizer.string("apnea.ios.planner.title"))
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button(DIRIOSLocalizer.string("common.close")) { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button(DIRIOSLocalizer.string("apnea.ios.planner.send_watch")) {
                    sendToWatch()
                }
                .disabled(!plannerStore.isValid)
            }
        }
        .onAppear {
            if let profileID = plannerStore.draftPlan.profileID,
               let profile = profileStore.profile(id: profileID) {
                plannerStore.applyProfile(profile)
            }
            transferMessage = transferStatusText(transferService.state)
        }
        .onChange(of: transferService.state) { _, newState in
            transferMessage = transferStatusText(newState)
        }
    }

    private var recoverySummary: String {
        let policy = plannerStore.draftPlan.recoveryPolicy
        let underwater = plannerStore.draftPlan.estimatedUnderwaterSeconds
        let recovery = plannerStore.draftPlan.estimatedRecoverySeconds
        return String(
            format: DIRIOSLocalizer.string("apnea.ios.planner.estimate_format"),
            Formatters.time(underwater),
            Formatters.time(recovery),
            IOSApneaProfilePresentation.recoveryLabel(for: policy)
        )
    }

    private var watchConnectivity: ApneaWatchTransferConnectivityContext {
        let session = WCSession.default
        return ApneaWatchTransferConnectivityContext(
            isSupported: watchSync.isSupported,
            activationState: watchSync.activationState,
            isPaired: session.isPaired,
            isWatchAppInstalled: session.isWatchAppInstalled,
            isReachable: session.isReachable
        )
    }

    private func sendToWatch() {
        plannerStore.persist()
        let profile = plannerStore.draftPlan.profileID.flatMap { profileStore.profile(id: $0) }
        let ok = transferService.send(
            plan: plannerStore.draftPlan,
            profile: profile,
            settings: settingsStore.settings,
            connectivity: watchConnectivity
        )
        if ok {
            transferMessage = transferStatusText(transferService.state)
        } else if let error = transferService.lastErrorMessage {
            transferMessage = DIRIOSLocalizer.string(error)
        }
    }

    private var transferStatusIcon: String {
        switch transferService.state {
        case .draft, .validated: return "doc.text"
        case .sending: return "arrow.up.circle"
        case .queued: return "clock"
        case .awaitingAck: return "hourglass"
        case .acknowledged: return "checkmark.circle.fill"
        case .failed: return "exclamationmark.triangle.fill"
        }
    }

    private var transferStatusColor: Color {
        switch transferService.state {
        case .acknowledged: return DIRTheme.green
        case .failed: return DIRTheme.red
        case .awaitingAck, .sending: return DIRTheme.cyan
        case .queued: return DIRTheme.yellow
        default: return DIRTheme.muted
        }
    }

    private func transferStatusText(_ state: IOSApneaWatchSyncState) -> String {
        switch state {
        case .draft, .validated:
            return DIRIOSLocalizer.string("apnea.ios.watch.state.draft")
        case .sending:
            return DIRIOSLocalizer.string("apnea.ios.watch.state.sending")
        case .queued:
            return DIRIOSLocalizer.string("apnea.ios.watch.state.queued")
        case .awaitingAck(let packageID, let revision, _):
            return String(
                format: DIRIOSLocalizer.string("apnea.ios.watch.state.awaiting_ack_revision"),
                revision,
                String(packageID.uuidString.prefix(8))
            )
        case .acknowledged(let packageID, let revision, _):
            return String(
                format: DIRIOSLocalizer.string("apnea.ios.watch.state.delivered_revision"),
                revision,
                String(packageID.uuidString.prefix(8))
            )
        case .failed(let messageKey):
            return DIRIOSLocalizer.string(messageKey)
        }
    }

    private func validationText(for issue: ApneaSessionPlanValidationIssue) -> String {
        switch issue {
        case .emptyTitle: return DIRIOSLocalizer.string("apnea.ios.planner.issue.empty_title")
        case .noEntries: return DIRIOSLocalizer.string("apnea.ios.planner.issue.no_entries")
        case .invalidDepth(let index): return String(format: DIRIOSLocalizer.string("apnea.ios.planner.issue.invalid_depth"), index + 1)
        case .invalidDuration(let index): return String(format: DIRIOSLocalizer.string("apnea.ios.planner.issue.invalid_duration"), index + 1)
        case .invalidRecovery(let index): return String(format: DIRIOSLocalizer.string("apnea.ios.planner.issue.invalid_recovery"), index + 1)
        case .nonMonotonicPyramid(let index): return String(format: DIRIOSLocalizer.string("apnea.ios.planner.issue.pyramid"), index + 1)
        case .duplicateOrderIndex: return DIRIOSLocalizer.string("apnea.ios.planner.issue.duplicate_order")
        }
    }
}
