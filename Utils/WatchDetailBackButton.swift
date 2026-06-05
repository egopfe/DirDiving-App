import SwiftUI

struct WatchDetailBackButton: View {
    @Environment(\.dismiss) private var dismiss
    var onBack: (() -> Void)?

    var body: some View {
        Button {
            if let onBack {
                onBack()
            } else {
                dismiss()
            }
        } label: {
            HStack(spacing: 2) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 11, weight: .bold))
                Text(String(localized: "watch.nav.back"))
                    .font(DiveUI.Typography.secondaryLabel)
            }
            .foregroundStyle(DiveUI.cyan)
        }
        .buttonStyle(.plain)
    }
}
