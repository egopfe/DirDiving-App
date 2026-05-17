import SwiftUI

struct ExportView: View {
    @Environment(\.dismiss) private var dismiss
    var fileName: String = "export.csv"

    var body: some View {
        ZStack {
            DiveScreenBackground()

            VStack(spacing: 0) {
                Spacer(minLength: 33)

                Image(systemName: "icloud.and.arrow.up")
                    .font(.system(size: 62, weight: .medium))
                    .foregroundStyle(DiveUI.green)
                    .shadow(color: DiveUI.green.opacity(0.28), radius: 7, x: 0, y: 0)

                Spacer(minLength: 23)

                Text("ESPORTAZIONE\nCOMPLETATA")
                    .font(.system(size: 16, weight: .black, design: .rounded))
                    .foregroundStyle(DiveUI.green)
                    .multilineTextAlignment(.center)
                    .lineSpacing(1)

                Spacer(minLength: 11)

                Text(fileName)
                    .font(.system(size: 12, weight: .regular, design: .rounded))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.78)

                Text("pronto per Subsurface")
                    .font(.system(size: 12, weight: .regular, design: .rounded))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.78)

                Spacer(minLength: 16)

                Button {
                    dismiss()
                } label: {
                    Text("TORNA AI LOG")
                        .font(.system(size: 10, weight: .black, design: .rounded))
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
