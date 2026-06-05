import SwiftUI
import PhotosUI
import UIKit

struct WatchPhotoTransferPanel: View {
    @EnvironmentObject private var watchSync: WatchSyncService
    @State private var selectedItem: PhotosPickerItem?
    @State private var conversionNotice: String?

    var body: some View {
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
        .padding(.vertical, 4)
        .onChange(of: selectedItem) { _, item in
            guard let item else { return }
            Task { await send(item) }
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
