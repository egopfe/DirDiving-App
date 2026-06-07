import SwiftUI
import PhotosUI
import UIKit

struct WatchPhotoTransferPanel: View {
    @EnvironmentObject private var watchSync: WatchSyncService
    @State private var selectedItem: PhotosPickerItem?
    @State private var stagedPhoto: StagedWatchPhoto?
    @State private var showManageSheet = false
    @State private var isPreparingPhoto = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            uploadSection
            manageButton
        }
        .padding(.vertical, 4)
        .onChange(of: selectedItem) { _, item in
            guard let item else {
                stagedPhoto = nil
                return
            }
            Task { await stagePhoto(from: item) }
        }
        .sheet(isPresented: $showManageSheet) {
            WatchPhotoManagementSheet()
                .environmentObject(watchSync)
        }
        .onChange(of: watchSync.companionPhotoTransfer?.state) { _, state in
            guard state == .importedOnWatch,
                  let stagedPhoto,
                  watchSync.companionPhotoTransfer?.photoID == stagedPhoto.photoID.uuidString else {
                return
            }
            clearStagedPhoto()
        }
    }

    private var uploadSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(String(localized: "watch_photo.title"))
                .font(.callout.weight(.semibold))
                .foregroundStyle(.white)
            Text(String(localized: "watch_photo.manual_hint"))
                .font(.caption2)
                .foregroundStyle(DIRTheme.muted)
                .fixedSize(horizontal: false, vertical: true)

            PhotosPicker(selection: $selectedItem, matching: .images) {
                Label(String(localized: "watch_photo.pick"), systemImage: "photo.on.rectangle.angled")
                    .font(.callout.weight(.semibold))
                    .foregroundStyle(DIRTheme.cyan)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(RoundedRectangle(cornerRadius: 8).stroke(DIRTheme.cyan, lineWidth: 1))
            }
            .buttonStyle(.plain)

            if isPreparingPhoto {
                Text(String(localized: "watch_photo.preparing"))
                    .font(.caption2)
                    .foregroundStyle(DIRTheme.muted)
            }

            if let stagedPhoto {
                stagedPhotoPreview(stagedPhoto)
            }

            Button {
                sendStagedPhoto()
            } label: {
                Label(String(localized: "watch_photo.send_to_watch"), systemImage: "applewatch.and.arrow.forward")
                    .font(.callout.weight(.semibold))
                    .foregroundStyle(canSendStagedPhoto ? DIRTheme.cyan : DIRTheme.muted)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(canSendStagedPhoto ? DIRTheme.cyan : DIRTheme.hairline, lineWidth: 1)
                    )
            }
            .buttonStyle(.plain)
            .disabled(!canSendStagedPhoto)

            if let statusMessage = photoStatusMessage {
                Text(statusMessage)
                    .font(.caption2)
                    .foregroundStyle(DIRTheme.muted)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var manageButton: some View {
        Button {
            showManageSheet = true
        } label: {
            Label(String(localized: "watch_photo.manage.open"), systemImage: "trash.circle")
                .font(.callout.weight(.semibold))
                .foregroundStyle(DIRTheme.cyan)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(RoundedRectangle(cornerRadius: 8).stroke(DIRTheme.cyan.opacity(0.75), lineWidth: 1))
        }
        .buttonStyle(.plain)
    }

    private var canSendStagedPhoto: Bool {
        stagedPhoto != nil && !isPreparingPhoto && !isTransferInFlight
    }

    private var isTransferInFlight: Bool {
        guard let transfer = watchSync.companionPhotoTransfer else { return false }
        switch transfer.state {
        case .queued, .sending, .deliveredToConnectivity:
            return true
        case .importedOnWatch, .rejectedByWatch, .failed:
            return false
        }
    }

    @ViewBuilder
    private func stagedPhotoPreview(_ staged: StagedWatchPhoto) -> some View {
        HStack(spacing: 10) {
            Image(uiImage: staged.preview)
                .resizable()
                .scaledToFill()
                .frame(width: 56, height: 56)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            VStack(alignment: .leading, spacing: 4) {
                Text(String(localized: "watch_photo.staged.ready"))
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.white)
                Text(staged.fileName)
                    .font(.caption2)
                    .foregroundStyle(DIRTheme.muted)
                    .lineLimit(1)
                if let notice = staged.conversionNotice {
                    Text(notice)
                        .font(.caption2)
                        .foregroundStyle(DIRTheme.yellow)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            Spacer(minLength: 0)
            Button(String(localized: "watch_photo.staged.clear")) {
                clearStagedPhoto()
            }
            .font(.caption2.weight(.semibold))
            .foregroundStyle(DIRTheme.orange)
            .buttonStyle(.plain)
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .stroke(DIRTheme.hairline, lineWidth: 1)
        )
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
            return String(localized: "watch_photo_status_delivered_pending")
        case .importedOnWatch:
            return String(localized: "watch_photo_status_imported")
        case .rejectedByWatch:
            if let code = transfer.rejectionErrorCode {
                return String(format: String(localized: "watch_photo_status_rejected_detail"), code)
            }
            return String(localized: "watch_photo_status_rejected")
        case .failed:
            return transfer.errorMessage ?? String(localized: "watch_photo_status_failed")
        }
    }

    @MainActor
    private func stagePhoto(from item: PhotosPickerItem) async {
        isPreparingPhoto = true
        defer { isPreparingPhoto = false }
        guard let data = try? await item.loadTransferable(type: Data.self) else {
            watchSync.reportCompanionPhotoFailure(message: String(localized: "watch_photo.error.load"))
            stagedPhoto = nil
            return
        }
        do {
            let prepared = try await Task.detached(priority: .userInitiated) {
                try WatchPhotoPreprocessor.prepareForWatch(from: data)
            }.value
            let photoID = UUID()
            let fileName = CompanionPhotoTransferSupport.makeFileName(photoID: photoID)
            guard let preview = UIImage(data: prepared.data) else {
                throw WatchPhotoPreprocessor.Failure.unreadableImage
            }
            stagedPhoto = StagedWatchPhoto(
                photoID: photoID,
                fileName: fileName,
                data: prepared.data,
                preview: preview,
                conversionNotice: prepared.conversionWarning
                    ? String(localized: "watch_photo.convert.warning")
                    : nil
            )
        } catch {
            stagedPhoto = nil
            watchSync.reportCompanionPhotoFailure(message: error.localizedDescription)
        }
    }

    private func sendStagedPhoto() {
        guard let stagedPhoto else { return }
        watchSync.sendPhotoToWatch(stagedPhoto.data, fileName: stagedPhoto.fileName, photoID: stagedPhoto.photoID.uuidString)
    }

    private func clearStagedPhoto() {
        stagedPhoto = nil
        selectedItem = nil
    }
}

private struct StagedWatchPhoto: Equatable {
    let photoID: UUID
    let fileName: String
    let data: Data
    let preview: UIImage
    let conversionNotice: String?

    static func == (lhs: StagedWatchPhoto, rhs: StagedWatchPhoto) -> Bool {
        lhs.photoID == rhs.photoID && lhs.fileName == rhs.fileName && lhs.data == rhs.data
    }
}
