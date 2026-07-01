import SwiftUI

/// Backward-compatible entry that opens the Diving Import / Export Center sheet.
struct CSVImportPanel: View {
    @State private var showImportCenter = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button {
                showImportCenter = true
            } label: {
                Label(DIRIOSLocalizer.string("diving.import_export.center.title"), systemImage: "square.and.arrow.down.on.square")
                    .font(.callout.weight(.semibold))
                    .foregroundStyle(DIRTheme.cyan)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(RoundedRectangle(cornerRadius: 8).stroke(DIRTheme.cyan, lineWidth: 1))
            }
            .buttonStyle(.plain)
            .accessibilityHint(DIRIOSLocalizer.string("diving.import_export.center.subtitle"))
        }
        .sheet(isPresented: $showImportCenter) {
            DivingImportExportCenterView(initialTab: .importTab)
        }
    }
}
