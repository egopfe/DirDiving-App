import SwiftUI
import PhotosUI
import UIKit

struct WatchPhotoTransferPanel: View {
    @EnvironmentObject private var watchSync: WatchSyncService
    @State private var selectedItem: PhotosPickerItem?
    @State private var statusMessage: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(String(localized: "watch_photo.title"))
                .font(.callout.weight(.semibold))
                .foregroundStyle(.white)
            PhotosPicker(selection: $selectedItem, matching: .images) {
                Label(String(localized: "watch_photo.pick"), systemImage: "photo.on.rectangle.angled")
                    .font(.callout.weight(.semibold))
                    .foregroundStyle(DIRTheme.cyan)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(RoundedRectangle(cornerRadius: 8).stroke(DIRTheme.cyan, lineWidth: 1))
            }
            .buttonStyle(.plain)
            if let statusMessage {
                Text(statusMessage)
                    .font(.caption2)
                    .foregroundStyle(DIRTheme.muted)
            }
        }
        .padding(.vertical, 4)
        .onChange(of: selectedItem) { _, item in
            guard let item else { return }
            Task { await send(item) }
        }
    }

    @MainActor
    private func send(_ item: PhotosPickerItem) async {
        guard let data = try? await item.loadTransferable(type: Data.self) else {
            statusMessage = String(localized: "watch_photo.error.load")
            return
        }
        let compressed = UIImage(data: data)?.jpegData(compressionQuality: 0.72) ?? data
        let fileName = "companion_\(Int(Date().timeIntervalSince1970)).jpg"
        watchSync.sendPhotoToWatch(compressed, fileName: fileName)
        statusMessage = watchSync.lastMessage
    }
}
