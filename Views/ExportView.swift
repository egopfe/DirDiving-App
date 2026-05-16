import SwiftUI

struct ExportView: View {
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

                Spacer(minLength: 27)
            }
            .padding(.horizontal, 12)
        }
        // TODO: Pass the actual exported CSV filename when this completion screen is wired into export flow.
    }
}
