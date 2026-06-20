import SwiftUI

/// Detailed Watch ↔ iPhone sync diagnostics moved out of main Settings for readability.
struct WatchSyncDiagnosticsView: View {
    @EnvironmentObject private var watchSync: WatchSyncService
    @State private var showClearSyncQueueConfirmation = false

    var body: some View {
        ZStack {
            DiveScreenBackground()

            ScrollView {
                VStack(spacing: 10) {
                    HStack {
                        WatchDetailBackButton()
                        Spacer()
                    }

                    Text(String(localized: "settings.diagnostics.sync.title"))
                        .font(DiveUI.Typography.screenTitle)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)

                    WatchSettingsSectionHeader(title: String(localized: "settings.section.sync"))

                    statusRow(
                        icon: "applewatch.radiowaves.left.and.right",
                        iconColor: watchSync.isSupported ? DiveUI.green : DiveUI.orange,
                        title: String(localized: "settings.row.sync_companion.title"),
                        subtitle: watchSync.isSupported ? watchSync.lastSyncStatus : String(localized: "settings.sync.open_ios")
                    )
                    statusRow(
                        icon: "tray.and.arrow.up",
                        iconColor: watchSync.pendingTransferCount == 0 ? DiveUI.green : DiveUI.yellow,
                        title: String(localized: "settings.row.sync_pending.title"),
                        subtitle: String(format: String(localized: "watch.sync.pending_count_format"), watchSync.pendingTransferCount)
                    )
                    statusRow(
                        icon: "paperplane.fill",
                        iconColor: watchSync.sentTransferCount == 0 ? DiveUI.secondaryText : DiveUI.cyan,
                        title: String(localized: "settings.row.sync_sent.title"),
                        subtitle: String(format: String(localized: "watch.sync.sent_count_format"), watchSync.sentTransferCount)
                    )
                    statusRow(
                        icon: "checkmark.seal.fill",
                        iconColor: watchSync.acknowledgedTransferCount == 0 ? DiveUI.secondaryText : DiveUI.green,
                        title: String(localized: "settings.row.sync_ack.title"),
                        subtitle: String(format: String(localized: "watch.sync.ack_count_format"), watchSync.acknowledgedTransferCount)
                    )
                    statusRow(
                        icon: "exclamationmark.arrow.triangle.2.circlepath",
                        iconColor: watchSync.failedTransferCount == 0 ? DiveUI.green : DiveUI.red,
                        title: String(localized: "settings.row.sync_errors.title"),
                        subtitle: String(format: String(localized: "watch.sync.failed_count_format"), watchSync.failedTransferCount, lastRetryText)
                    )

                    if !watchSync.recentActivity.isEmpty {
                        syncActivityPanel
                    }

                    if watchSync.pendingTransferCount > 0 || watchSync.activationState != .activated {
                        Button {
                            watchSync.retryPendingTransfers()
                            HapticService.shared.confirm()
                        } label: {
                            settingsRow(
                                icon: "arrow.triangle.2.circlepath",
                                iconColor: DiveUI.cyan,
                                title: String(localized: "settings.row.retry_sync.title"),
                                subtitle: String(localized: "settings.sync.retry.subtitle"),
                                showsChevron: true
                            )
                        }
                        .buttonStyle(.plain)
                    }

                    if watchSync.pendingTransferCount > 0 || watchSync.failedTransferCount > 0 {
                        Button {
                            showClearSyncQueueConfirmation = true
                            HapticService.shared.notify()
                        } label: {
                            settingsRow(
                                icon: "trash",
                                iconColor: DiveUI.red,
                                title: String(localized: "settings.row.clear_queue.title"),
                                subtitle: String(localized: "settings.sync.clear.subtitle"),
                                showsChevron: true
                            )
                        }
                        .buttonStyle(.plain)
                    }

                    WatchSettingsSectionHeader(title: String(localized: "settings.section.reference"))

                    settingsRow(
                        icon: "function",
                        iconColor: DiveUI.green,
                        title: String(localized: "settings.row.ttv.title"),
                        subtitle: String(localized: "settings.ttv.info"),
                        informational: true
                    )
                    settingsRow(
                        icon: "sun.max",
                        iconColor: DiveUI.yellow,
                        title: String(localized: "settings.row.display.title"),
                        subtitle: String(localized: "settings.display.watchos"),
                        informational: true
                    )
                    settingsRow(
                        icon: "speaker.slash",
                        iconColor: DiveUI.yellow,
                        title: String(localized: "settings.row.audio.title"),
                        subtitle: String(localized: "settings.audio.info"),
                        informational: true
                    )
                    settingsRow(
                        icon: "mappin.and.ellipse",
                        iconColor: DiveUI.cyan,
                        title: String(localized: "settings.row.gps_behavior.title"),
                        subtitle: String(localized: "settings.row.gps_behavior.subtitle"),
                        informational: true
                    )
                    settingsRow(
                        icon: "hand.tap",
                        iconColor: DiveUI.green,
                        title: String(localized: "settings.row.manual_start.title"),
                        subtitle: String(localized: "settings.manual.fallback"),
                        informational: true
                    )
                }
                .padding(.horizontal, 11)
                .padding(.top, 9)
                .padding(.bottom, 8)
            }
        }
        .confirmationDialog(String(localized: "settings.sync.clear.confirm.title"), isPresented: $showClearSyncQueueConfirmation, titleVisibility: .visible) {
            Button(String(localized: "settings.sync.clear.confirm.action"), role: .destructive) {
                watchSync.clearFailedQueue()
                HapticService.shared.confirm()
            }
            Button(String(localized: "log.delete.cancel"), role: .cancel) {
                HapticService.shared.confirm()
            }
        } message: {
            Text(String(localized: "settings.sync.clear.confirm.message"))
        }
    }

    private var lastRetryText: String {
        guard let date = watchSync.lastRetryDate else { return String(localized: "mai") }
        return Self.retryFormatter.string(from: date)
    }

    private static let retryFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()

    private var syncActivityPanel: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(String(localized: "sync.activity.section_title"))
                .font(DiveUI.Typography.sectionHeading)
                .foregroundStyle(DiveUI.cyan)
            ForEach(Array(watchSync.recentActivity.prefix(4))) { activity in
                VStack(alignment: .leading, spacing: 3) {
                    Text(activity.title)
                        .font(DiveUI.Typography.rowTitle)
                        .foregroundStyle(.white)
                    Text(activity.detail)
                        .font(DiveUI.Typography.rowSubtitle)
                        .foregroundStyle(DiveUI.secondaryText)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.vertical, 2)
            }
        }
        .padding(.horizontal, 9)
        .padding(.vertical, 7)
        .background(
            RoundedRectangle(cornerRadius: 7, style: .continuous)
                .fill(Color.black.opacity(0.38))
                .overlay(
                    RoundedRectangle(cornerRadius: 7, style: .continuous)
                        .stroke(.white.opacity(0.24), lineWidth: 1)
                )
        )
    }

    private func statusRow(icon: String, iconColor: Color, title: String, subtitle: String) -> some View {
        settingsRow(icon: icon, iconColor: iconColor, title: title, subtitle: subtitle, informational: true)
    }

    private func settingsRow(
        icon: String,
        iconColor: Color,
        title: String,
        subtitle: String,
        informational: Bool = false,
        showsChevron: Bool = false,
        legal: Bool = false
    ) -> some View {
        WatchSettingsRow(
            icon: icon,
            iconColor: iconColor,
            title: title,
            subtitle: subtitle,
            showsChevron: showsChevron,
            informational: informational,
            legal: legal
        )
    }
}
