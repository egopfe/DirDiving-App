import SwiftUI
import PhotosUI
import UIKit

struct WatchPhotoTransferPanel: View {
    @EnvironmentObject private var watchSync: WatchSyncService
    @State private var selectedItem: PhotosPickerItem?
    @State private var conversionNotice: String?
    @State private var pendingDeleteFileName: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            uploadSection
            manageSection
        }
        .padding(.vertical, 4)
        .onAppear {
            watchSync.requestWatchImageInventory()
        }
        .onChange(of: selectedItem) { _, item in
            guard let item else { return }
            Task { await send(item) }
        }
        .confirmationDialog(
            String(localized: "watch_photo.delete.confirm.title"),
            isPresented: Binding(
                get: { pendingDeleteFileName != nil },
                set: { if !$0 { pendingDeleteFileName = nil } }
            ),
            titleVisibility: .visible
        ) {
            Button(String(localized: "watch_photo.delete.confirm.action"), role: .destructive) {
                if let pendingDeleteFileName {
                    watchSync.requestDeletePhotoOnWatch(storedFileName: pendingDeleteFileName)
                }
                pendingDeleteFileName = nil
            }
            Button(String(localized: "watch_photo.delete.cancel"), role: .cancel) {
                pendingDeleteFileName = nil
            }
        } message: {
            Text(String(localized: "watch_photo.delete.confirm.message"))
        }
    }

    private var uploadSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(String(localized: "watch_photo.title"))
                .font(.callout.weight(.semibold))
                .foregroundStyle(.white)
            if let conversionNotice {
                Text(conversionNotice)
                    .font(.caption2)
                    .foregroundStyle(DIRTheme.yellow)
                    .fixedSize(horizontal: false, vertical: true)
            }
            PhotosPicker(selection: $selectedItem, matching: .images) {
                Label(String(localized: "watch_photo.pick"), systemImage: "photo.on.rectangle.angled")
                    .font(.callout.weight(.semibold))
                    .foregroundStyle(DIRTheme.cyan)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(RoundedRectangle(cornerRadius: 8).stroke(DIRTheme.cyan, lineWidth: 1))
            }
            .buttonStyle(.plain)
            if let statusMessage = photoStatusMessage {
                Text(statusMessage)
                    .font(.caption2)
                    .foregroundStyle(DIRTheme.muted)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var manageSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(String(localized: "watch_photo.manage.title"))
                        .font(.callout.weight(.semibold))
                        .foregroundStyle(.white)
                    Text(String(localized: "watch_photo.manage.subtitle"))
                        .font(.caption2)
                        .foregroundStyle(DIRTheme.muted)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer()
                Button(String(localized: "watch_photo.inventory.refresh")) {
                    watchSync.requestWatchImageInventory()
                }
                .font(.caption2.weight(.semibold))
                .foregroundStyle(DIRTheme.cyan)
                .buttonStyle(.plain)
            }

            Text(inventoryStatusText)
                .font(.caption2)
                .foregroundStyle(DIRTheme.muted)
                .fixedSize(horizontal: false, vertical: true)

            if watchSync.watchImageInventory.isEmpty {
                Text(String(localized: "watch_photo.inventory.empty"))
                    .font(.caption2)
                    .foregroundStyle(DIRTheme.muted)
            } else {
                ForEach(watchSync.watchImageInventory) { item in
                    inventoryRow(item)
                }
            }

            Text(String(localized: "watch_photo.inventory.keep_note"))
                .font(.caption2)
                .foregroundStyle(DIRTheme.muted)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .stroke(DIRTheme.cyan.opacity(0.35), lineWidth: 1)
        )
    }

    private func inventoryRow(_ item: WatchUserImageInventoryItem) -> some View {
        let deleteState = deleteState(for: item.storedFileName)
        return VStack(alignment: .leading, spacing: 4) {
            Text(item.displayName)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.white)
                .lineLimit(1)
            Text(item.storedFileName)
                .font(.caption2)
                .foregroundStyle(DIRTheme.muted)
                .lineLimit(1)
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
            if let deleteState {
                Text(deleteStatusText(deleteState))
                    .font(.caption2)
                    .foregroundStyle(DIRTheme.yellow)
            }
            if item.isDeletable {
                Button(String(localized: "watch_photo.delete.button")) {
                    pendingDeleteFileName = item.storedFileName
                }
                .font(.caption2.weight(.semibold))
                .foregroundStyle(DIRTheme.red)
                .buttonStyle(.plain)
                .disabled(deleteState == .pending || deleteState == .sending || deleteState == .deliveredToConnectivity)
            }
        }
        .padding(.vertical, 4)
    }

    private var inventoryStatusText: String {
        switch watchSync.watchImageInventoryStatus {
        case .unknown:
            return String(localized: "watch_photo.inventory.loading")
        case .loading:
            return String(localized: "watch_photo.inventory.loading")
        case .loaded:
            if let date = watchSync.lastInventoryRefreshDate {
                return String(format: String(localized: "watch_photo.inventory.last_updated"), date.formatted(date: .abbreviated, time: .shortened))
            }
            return String(localized: "watch_photo.inventory.last_updated")
        case .watchUnavailable:
            return String(localized: "watch_photo.inventory.watch_unavailable")
        case .failed:
            return watchSync.inventoryErrorMessage ?? String(localized: "watch_photo.inventory.failed")
        case .stale:
            return watchSync.inventoryErrorMessage ?? String(localized: "watch_photo.inventory.stale")
        }
    }

    private var photoStatusMessage: String? {
        guard let transfer = watchSync.companionPhotoTransfer else {
            return watchSync.lastMessage
        }
        switch transfer.state {
        case .queued:
            return String(localized: "watch_photo_status_queued")
        case .sending:
            return String(localized: "watch_photo_status_sending")
        case .deliveredToConnectivity:
            return String(localized: "watch_photo_status_delivered")
        case .importedOnWatch:
            return String(localized: "watch_photo_status_imported")
        case .rejectedByWatch:
            return String(localized: "watch_photo_status_rejected")
        case .failed:
            return transfer.errorMessage ?? String(localized: "watch_photo_status_failed")
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
            return String(localized: "watch_photo.delete.status.pending")
        case .sending:
            return String(localized: "watch_photo.delete.status.sending")
        case .deliveredToConnectivity:
            return String(localized: "watch_photo.delete.status.delivered")
        case .deletedOnWatch:
            return String(localized: "watch_photo.delete.status.deleted")
        case .notFound:
            return String(localized: "watch_photo.delete.status.not_found")
        case .rejectedByWatch:
            return String(localized: "watch_photo.delete.status.rejected")
        case .failed:
            return String(localized: "watch_photo.delete.status.failed")
        }
    }

    @MainActor
    private func send(_ item: PhotosPickerItem) async {
        conversionNotice = nil
        guard let data = try? await item.loadTransferable(type: Data.self) else {
            watchSync.reportCompanionPhotoFailure(message: String(localized: "watch_photo.error.load"))
            return
        }
        do {
            let prepared = try WatchPhotoPreprocessor.prepareForWatch(from: data)
            if prepared.conversionWarning {
                conversionNotice = String(localized: "watch_photo.convert.warning")
            }
            let photoID = UUID()
            let fileName = CompanionPhotoTransferSupport.makeFileName(photoID: photoID)
            watchSync.sendPhotoToWatch(prepared.data, fileName: fileName, photoID: photoID.uuidString)
        } catch {
            watchSync.reportCompanionPhotoFailure(message: error.localizedDescription)
        }
    }
}
