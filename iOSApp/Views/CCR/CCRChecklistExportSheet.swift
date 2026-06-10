import SwiftUI

struct CCRChecklistExportSheet: View {
    @Binding var candidates: [CCRChecklistExportCandidate]
    let onConfirm: () -> Void
    let onCancel: () -> Void

    var body: some View {
        NavigationStack {
            DIRScreenContainer {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach($candidates) { $candidate in
                            Toggle(isOn: $candidate.isSelected) {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(candidate.item.title)
                                        .font(.callout.weight(.semibold))
                                        .foregroundStyle(.white)
                                    if let role = candidate.item.gasRole {
                                        Text(role.localizedTitle)
                                            .font(.caption2)
                                            .foregroundStyle(DIRTheme.muted)
                                    }
                                    if let gasText = candidate.item.gasText.nilIfEmpty {
                                        Text(gasText)
                                            .font(.caption2)
                                            .foregroundStyle(DIRTheme.cyan)
                                    }
                                }
                            }
                            .tint(DIRTheme.cyan)
                        }
                    }
                    .padding(16)
                }
                .dirCompanionScrollSurface()
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "checklist_planner.sync.cancel")) { onCancel() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(String(localized: "checklist_planner.sync.confirm")) { onConfirm() }
                        .disabled(!candidates.contains(where: \.isSelected))
                }
            }
            .navigationTitle(String(localized: "checklist_planner.sync.choose_add"))
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

private extension String {
    var nilIfEmpty: String? {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}
