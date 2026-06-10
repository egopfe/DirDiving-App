import SwiftUI

/// Pop-up list of photos stored on the paired Apple Watch, with per-item delete.
struct WatchPhotoManagementSheet: View {
    @EnvironmentObject private var watchSync: WatchSyncService
    @Environment(\.dismiss) private var dismiss
    @State private var pendingDeleteFileName: String?

    var body: some View {
        NavigationStack {
            DIRScreenContainer {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 14) {
                        Text(DIRIOSLocalizer.string("watch_photo.manage.subtitle"))
                            .font(.caption)
                            .foregroundStyle(DIRTheme.muted)
                            .fixedSize(horizontal: false, vertical: true)

                        Text(inventoryStatusText)
                            .font(.caption2)
                            .foregroundStyle(DIRTheme.muted)
                            .fixedSize(horizontal: false, vertical: true)

                        if watchSync.watchImageInventory.isEmpty {
                            Text(DIRIOSLocalizer.string("watch_photo.inventory.empty"))
                                .font(.callout.weight(.semibold))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.vertical, 24)
                        } else {
                            ForEach(watchSync.watchImageInventory) { item in
                                inventoryRow(item)
                                Divider().overlay(DIRTheme.hairline)
                            }
                        }

                        Text(DIRIOSLocalizer.string("watch_photo.inventory.keep_note"))
                            .font(.caption2)
                            .foregroundStyle(DIRTheme.muted)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 10)
                    .padding(.bottom, 22)
                }
                .dirCompanionScrollSurface()
            }
            .navigationTitle(DIRIOSLocalizer.string("watch_photo.manage.title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(DIRIOSLocalizer.string("watch_photo.manage.close")) {
                        dismiss()
                    }
                    .foregroundStyle(DIRTheme.cyan)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(DIRIOSLocalizer.string("watch_photo.inventory.refresh")) {
                        watchSync.requestWatchImageInventory()
                    }
                    .foregroundStyle(DIRTheme.cyan)
                }
            }
        }
        .onAppear {
            watchSync.requestWatchImageInventory()
        }
        .confirmationDialog(
            DIRIOSLocalizer.string("watch_photo.delete.confirm.title"),
            isPresented: Binding(
                get: { pendingDeleteFileName != nil },
                set: { if !$0 { pendingDeleteFileName = nil } }
            ),
            titleVisibility: .visible
        ) {
            Button(DIRIOSLocalizer.string("watch_photo.delete.confirm.action"), role: .destructive) {
                if let pendingDeleteFileName {
                    watchSync.requestDeletePhotoOnWatch(storedFileName: pendingDeleteFileName)
                }
                pendingDeleteFileName = nil
            }
            Button(DIRIOSLocalizer.string("watch_photo.delete.cancel"), role: .cancel) {
                pendingDeleteFileName = nil
            }
        } message: {
            Text(DIRIOSLocalizer.string("watch_photo.delete.confirm.message"))
        }
    }

    private func inventoryRow(_ item: WatchUserImageInventoryItem) -> some View {
        let deleteState = deleteState(for: item.storedFileName)
        return VStack(alignment: .leading, spacing: 6) {
            Text(item.displayName)
                .font(.callout.weight(.semibold))
                .foregroundStyle(.white)
                .lineLimit(2)
            Text(item.storedFileName)
                .font(.caption2)
                .foregroundStyle(DIRTheme.muted)
                .lineLimit(1)
            HStack(spacing: 12) {
                if let importedAt = item.importedAt {
                    Text(importedAt, style: .date)
                        .font(.caption2)
                        .foregroundStyle(DIRTheme.muted)
                }
                if let byteCount = item.byteCount {
                    Text(ByteCountFormatter.string(fromByteCount: Int64(byteCount), countStyle: .file))
                        .font(.caption2)
                        .foregroundStyle(DIRTheme.muted)
                }
            }
            if let deleteState {
                Text(deleteStatusText(deleteState))
                    .font(.caption2)
                    .foregroundStyle(DIRTheme.yellow)
            }
            if item.isDeletable {
                Button(DIRIOSLocalizer.string("watch_photo.delete.button")) {
                    pendingDeleteFileName = item.storedFileName
                }
                .font(.caption.weight(.semibold))
                .foregroundStyle(DIRTheme.red)
                .buttonStyle(.plain)
                .disabled(deleteState == .pending || deleteState == .sending || deleteState == .deliveredToConnectivity)
            }
        }
        .padding(.vertical, 4)
    }

    private var inventoryStatusText: String {
        switch watchSync.watchImageInventoryStatus {
        case .unknown, .loading:
            return DIRIOSLocalizer.string("watch_photo.inventory.loading")
        case .loaded:
            if let date = watchSync.lastInventoryRefreshDate {
                return DIRIOSLocalizer.formatted("watch_photo.inventory.last_updated", date.formatted(date: .abbreviated, time: .shortened))
            }
            return DIRIOSLocalizer.string("watch_photo.inventory.last_updated")
        case .watchUnavailable:
            return DIRIOSLocalizer.string("watch_photo.inventory.watch_unavailable")
        case .failed:
            return watchSync.inventoryErrorMessage ?? DIRIOSLocalizer.string("watch_photo.inventory.failed")
        case .stale:
            return watchSync.inventoryErrorMessage ?? DIRIOSLocalizer.string("watch_photo.inventory.stale")
        }
    }

    private func deleteState(for storedFileName: String) -> WatchPhotoDeleteRequestState.State? {
        watchSync.pendingDeleteRequests.values
            .filter { $0.storedFileName == storedFileName }
            .sorted { $0.createdAt > $1.createdAt }
            .first?
            .state
    }

    private func deleteStatusText(_ state: WatchPhotoDeleteRequestState.State) -> String {
        switch state {
        case .pending:
            return DIRIOSLocalizer.string("watch_photo.delete.status.pending")
        case .sending:
            return DIRIOSLocalizer.string("watch_photo.delete.status.sending")
        case .deliveredToConnectivity:
            return DIRIOSLocalizer.string("watch_photo.delete.status.delivered")
        case .deletedOnWatch:
            return DIRIOSLocalizer.string("watch_photo.delete.status.deleted")
        case .notFound:
            return DIRIOSLocalizer.string("watch_photo.delete.status.not_found")
        case .rejectedByWatch:
            return DIRIOSLocalizer.string("watch_photo.delete.status.rejected")
        case .failed:
            return DIRIOSLocalizer.string("watch_photo.delete.status.failed")
        }
    }
}
