import SwiftUI
import UniformTypeIdentifiers

/// Reusable CSV import affordance (Logbook, More, Analysis empty state).
struct CSVImportPanel: View {
    @EnvironmentObject private var logStore: DiveLogStore
    @State private var showImporter = false
    @State private var importMessage: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button {
                showImporter = true
            } label: {
                Label(DIRIOSLocalizer.string("import.csv.action"), systemImage: "square.and.arrow.down")
                    .font(.callout.weight(.semibold))
                    .foregroundStyle(DIRTheme.cyan)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(RoundedRectangle(cornerRadius: 8).stroke(DIRTheme.cyan, lineWidth: 1))
            }
            .buttonStyle(.plain)
            .accessibilityHint(DIRIOSLocalizer.string("import.csv.action.hint"))

            if let importMessage {
                Text(importMessage)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(DIRTheme.yellow)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .fileImporter(isPresented: $showImporter, allowedContentTypes: [.commaSeparatedText, .plainText]) { result in
            switch result {
            case .success(let url):
                switch DiveImportService.importCSV(from: url) {
                case .success(let summary):
                    let alreadyImported = logStore.session(id: summary.session.id) != nil
                    logStore.add(summary.session)
                    importMessage = summary.message(alreadyImported: alreadyImported)
                case .failure(let error):
                    importMessage = error.localizedDescription
                }
            case .failure(let error):
                importMessage = error.localizedDescription
            }
        }
    }
}
