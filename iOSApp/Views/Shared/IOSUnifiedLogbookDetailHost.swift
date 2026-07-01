import SwiftUI

struct IOSUnifiedLogbookDetailHost: View {
    let selection: IOSUnifiedLogbookSelection
    @EnvironmentObject private var coordinator: IOSCompanionStoreCoordinator

    var body: some View {
        Group {
            switch selection {
            case .diving(let id):
                divingDetail(id: id)
            case .snorkeling(let id):
                snorkelingDetail(id: id)
            case .apnea(let id):
                apneaDetail(id: id)
            }
        }
    }

    @ViewBuilder
    private func divingDetail(id: UUID) -> some View {
        if let session = coordinator.logStore.session(id: id) {
            DiveDetailView(session: session)
        } else {
            missingSessionPlaceholder
        }
    }

    @ViewBuilder
    private func snorkelingDetail(id: UUID) -> some View {
        let bundle = coordinator.ensureSnorkelingStores()
        if let session = bundle.logbookStore.session(id: id) {
            IOSSnorkelingSessionDetailView(
                session: session,
                isDemoSession: DemoSnorkelingSessionCatalog.isDemoSession(id: id)
            )
            .environmentObject(bundle.logbookStore)
            .environmentObject(bundle.sessionPhotoStore)
            .environmentObject(bundle.equipmentStore)
            .environmentObject(bundle.settingsStore)
        } else {
            missingSessionPlaceholder
        }
    }

    @ViewBuilder
    private func apneaDetail(id: UUID) -> some View {
        let bundle = coordinator.ensureApneaStores()
        if let session = bundle.logbookStore.session(id: id) {
            IOSApneaSessionDetailView(
                session: session,
                isDemoSession: DemoApneaSessionCatalog.isDemoSession(id: id)
            )
            .environmentObject(bundle.logbookStore)
        } else {
            missingSessionPlaceholder
        }
    }

    private var missingSessionPlaceholder: some View {
        Text(DIRIOSLocalizer.string("logbook.unified.empty"))
            .foregroundStyle(DIRTheme.muted)
            .padding()
    }
}
