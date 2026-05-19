import SwiftUI

struct DIRWarningBox: View {
    let text: String
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.subheadline.weight(.bold))
                .foregroundStyle(DIRTheme.orange)
            Text(LocalizedStringKey(text))
                .font(.footnote.weight(.medium))
                .foregroundStyle(.white.opacity(0.86))
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: DIRTheme.cardRadius)
                .fill(DIRTheme.orange.opacity(0.15))
                .overlay(RoundedRectangle(cornerRadius: DIRTheme.cardRadius).stroke(DIRTheme.orange.opacity(0.42), lineWidth: 1))
        )
    }
}
