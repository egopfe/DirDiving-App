import SwiftUI

struct IOSUnifiedLogbookListView: View {
    let hostActivity: DIRActivityMode
    @Binding var selection: IOSUnifiedLogbookSelection?

    @EnvironmentObject private var coordinator: IOSCompanionStoreCoordinator
    @AppStorage(IOSUnitPreference.storageKey) private var unitsRaw = IOSUnitPreference.metric.rawValue

    private var unitPreference: IOSUnitPreference { IOSUnitPreference.fromStorage(unitsRaw) }

    private var entries: [IOSUnifiedLogbookEntry] {
        IOSUnifiedLogbookPresentationBuilder.build(
            divingSessions: coordinator.logStore.sessions,
            snorkelingSessions: coordinator.snorkelingLogbookStoreForPresentation().sessions,
            apneaSessions: coordinator.apneaLogbookStoreForPresentation().sessions,
            units: unitPreference,
            includeDemo: false
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            aggregatedHeader
            if entries.isEmpty {
                emptyState
            } else {
                entryCountLabel
                ForEach(entries) { entry in
                    Button {
                        selection = selection(for: entry)
                    } label: {
                        IOSUnifiedLogbookEntryRow(entry: entry)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .onAppear {
            coordinator.ensureStoresForUnifiedLogbook()
        }
    }

    private var aggregatedHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Text(DIRIOSLocalizer.string("logbook.visibility.all_activities_badge"))
                    .font(.caption.weight(.bold))
                    .foregroundStyle(CompanionActivityPresentation.accent(for: hostActivity))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(CompanionActivityPresentation.accent(for: hostActivity).opacity(0.15))
                    )
                Text(DIRIOSLocalizer.string("logbook.unified.title"))
                    .font(.headline)
                    .foregroundStyle(.white)
            }
            Text(DIRIOSLocalizer.string("logbook.unified.presentation_only"))
                .font(.caption)
                .foregroundStyle(DIRTheme.muted)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: DIRTheme.cardRadius)
                .fill(DIRTheme.surface.opacity(0.6))
                .overlay(RoundedRectangle(cornerRadius: DIRTheme.cardRadius).stroke(DIRTheme.hairline, lineWidth: 1))
        )
        .accessibilityElement(children: .combine)
    }

    private var entryCountLabel: some View {
        Text("\(entries.count)")
            .font(.caption.weight(.semibold))
            .foregroundStyle(DIRTheme.muted)
            .accessibilityLabel("\(entries.count) entries")
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "doc.text")
                .font(.largeTitle)
                .foregroundStyle(DIRTheme.muted)
            Text(DIRIOSLocalizer.string("logbook.unified.empty"))
                .font(.callout)
                .foregroundStyle(DIRTheme.muted)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
    }

    private func selection(for entry: IOSUnifiedLogbookEntry) -> IOSUnifiedLogbookSelection {
        switch entry.activity {
        case .diving: return .diving(entry.sourceID)
        case .snorkeling: return .snorkeling(entry.sourceID)
        case .apnea: return .apnea(entry.sourceID)
        }
    }
}

extension View {
    func iosUnifiedLogbookNavigationDestination(
        selection: Binding<IOSUnifiedLogbookSelection?>
    ) -> some View {
        navigationDestination(item: selection) { item in
            IOSUnifiedLogbookDetailHost(selection: item)
        }
    }
}
