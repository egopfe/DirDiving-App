import SwiftUI

struct DIRWarningBox: View {
    let text: String
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill").foregroundStyle(DIRTheme.orange)
            Text(text).font(.footnote).foregroundStyle(.white.opacity(0.84))
        }
        .padding(14)
        .background(RoundedRectangle(cornerRadius: 16).fill(DIRTheme.orange.opacity(0.16)).overlay(RoundedRectangle(cornerRadius: 16).stroke(DIRTheme.orange.opacity(0.35), lineWidth: 1)))
    }
}
