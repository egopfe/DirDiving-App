import SwiftUI

struct ExportView: View {
    @Environment(\.dismiss) private var dismiss
    var fileName: String = "export.csv"
    var exportURL: URL?

    var body: some View {
        ZStack {
            DiveScreenBackground()

            VStack(spacing: 0) {
                HStack {
                    WatchDetailBackButton()
                    Spacer()
                }
                .padding(.horizontal, 12)
                .padding(.top, 8)

                Spacer(minLength: 20)

                Image(systemName: "icloud.and.arrow.up")
                    .font(.system(size: 62, weight: .medium))
                    .foregroundStyle(DiveUI.green)
                    .shadow(color: DiveUI.green.opacity(0.28), radius: 7, x: 0, y: 0)

                Spacer(minLength: 23)

                Text(String(localized: "export.complete.title"))
                    .font(.system(size: 16, weight: .black, design: .rounded))
                    .foregroundStyle(DiveUI.green)
                    .multilineTextAlignment(.center)
                    .lineSpacing(1)

                Spacer(minLength: 11)

                Text(fileName)
                    .font(.system(size: 12, weight: .regular, design: .rounded))
                    .foregroundStyle(.white)
                    .lineLimit(2)
                    .minimumScaleFactor(0.9)

                Text(String(localized: "export.complete.subsurface"))
                    .font(DiveUI.Typography.rowSubtitle)
                    .foregroundStyle(.white)
                    .lineLimit(2)
                    .minimumScaleFactor(0.9)

                Spacer(minLength: 12)

                if let exportURL {
                    ShareLink(item: exportURL) {
                        HStack(spacing: 5) {
                            Text(String(localized: "log.share.csv.button"))
                            Image(systemName: "square.and.arrow.up")
                        }
                        .font(DiveUI.Typography.secondaryLabel)
                        .foregroundStyle(DiveUI.blue)
                        .frame(maxWidth: .infinity, minHeight: 40)
                        .padding(.vertical, 7)
                        .background(
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .stroke(DiveUI.blue.opacity(0.82), lineWidth: 1)
                        )
                    }
                    .padding(.horizontal, 4)
                }

                Spacer(minLength: 12)

                Button {
                    dismiss()
                } label: {
                    Text(String(localized: "export.back_to_logs"))
                        .font(DiveUI.Typography.hintCaptionBold)
                        .foregroundStyle(DiveUI.yellow)
                        .padding(.horizontal, 11)
                        .padding(.vertical, 7)
                        .background(Capsule().stroke(DiveUI.yellow.opacity(0.86), lineWidth: 1))
                }
                .buttonStyle(.plain)

                Spacer(minLength: 11)
            }
            .padding(.horizontal, 12)
        }
    }
}
