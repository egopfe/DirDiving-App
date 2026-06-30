import Foundation
import Combine

@MainActor
final class SnorkelingImportedRouteStore: ObservableObject {
    static let shared = SnorkelingImportedRouteStore()

    static let activatedKey = "dirdiving_watch_snorkeling_imported_route_activated_v1"
    static let pendingKey = "dirdiving_watch_snorkeling_imported_route_pending_v1"
    static let importedChecksumsKey = "dirdiving_watch_snorkeling_imported_route_checksums_v1"

    @Published private(set) var activatedPackage: SnorkelingRouteSyncPackage?
    @Published private(set) var pendingPackage: SnorkelingRouteSyncPackage?
    @Published private(set) var activatedPackageID: UUID?
    @Published private(set) var activatedRevision: Int?
    @Published private(set) var lastImportAt: Date?
    @Published private(set) var lastImportError: SnorkelingRouteSyncValidationError?
    @Published private(set) var staleRevisionRejected = false

    private var importedChecksums: Set<String> = []

    private init() {
        pendingPackage = loadPending()
        importedChecksums = Set(UserDefaults.standard.stringArray(forKey: Self.importedChecksumsKey) ?? [])
        if let activated = UserDefaults.standard.dictionary(forKey: Self.activatedKey),
           let packageIDRaw = activated["packageID"] as? String,
           let packageID = UUID(uuidString: packageIDRaw),
           let revision = activated["revision"] as? Int,
           let data = activated["packageData"] as? Data,
           let package = try? SnorkelingRouteSyncCodec.decode(data) {
            activatedPackage = package
            activatedPackageID = packageID
            activatedRevision = revision
        }
    }

    var hasPendingActivation: Bool {
        pendingPackage != nil
    }

    var activeRoutePlan: SnorkelingRoutePlan? {
        (activatedPackage ?? pendingPackage)?.body.routePlan
    }

    var activePlanningMetadata: SnorkelingRoutePlanningMetadata? {
        (activatedPackage ?? pendingPackage)?.body.planningMetadata
    }

    func importPayload(_ package: SnorkelingRouteSyncPackage, source: String, sessionInProgress: Bool) -> Bool {
        staleRevisionRejected = false
        let fingerprint = "\(package.body.packageID.uuidString)|\(package.body.revision)|\(package.payloadChecksumSHA256)"
        if importedChecksums.contains(fingerprint) {
            return true
        }

        do {
            try SnorkelingRouteSyncCodec.validate(package)
        } catch let error as SnorkelingRouteSyncValidationError {
            lastImportError = error
            return false
        } catch {
            lastImportError = .decodeFailed
            return false
        }

        if let current = activatedPackage ?? pendingPackage {
            if package.body.packageID == current.body.packageID,
               package.body.revision < current.body.revision {
                staleRevisionRejected = true
                lastImportError = nil
                return false
            }
            if package.body.packageID == current.body.packageID,
               package.body.revision == current.body.revision,
               package.payloadChecksumSHA256 == current.payloadChecksumSHA256 {
                rememberChecksum(fingerprint)
                return true
            }
        }

        lastImportAt = Date()
        lastImportError = nil
        rememberChecksum(fingerprint)

        if sessionInProgress {
            pendingPackage = package
            persistPending(package)
            return true
        }

        activatedPackage = package
        activatedPackageID = package.body.packageID
        activatedRevision = package.body.revision
        pendingPackage = nil
        persistActivated(package)
        UserDefaults.standard.removeObject(forKey: Self.pendingKey)
        return true
    }

    func activatePendingIfNeeded() {
        guard let pending = pendingPackage else { return }
        activatedPackage = pending
        activatedPackageID = pending.body.packageID
        activatedRevision = pending.body.revision
        pendingPackage = nil
        persistActivated(pending)
        UserDefaults.standard.removeObject(forKey: Self.pendingKey)
    }

    private func rememberChecksum(_ fingerprint: String) {
        importedChecksums.insert(fingerprint)
        UserDefaults.standard.set(Array(importedChecksums), forKey: Self.importedChecksumsKey)
    }

    private func persistActivated(_ package: SnorkelingRouteSyncPackage) {
        guard let data = try? SnorkelingRouteSyncCodec.encode(package) else { return }
        UserDefaults.standard.set(
            [
                "packageID": package.body.packageID.uuidString,
                "revision": package.body.revision,
                "packageData": data,
            ],
            forKey: Self.activatedKey
        )
    }

    private func persistPending(_ package: SnorkelingRouteSyncPackage) {
        guard let data = try? SnorkelingRouteSyncCodec.encode(package) else { return }
        UserDefaults.standard.set(data, forKey: Self.pendingKey)
    }

    private func loadPending() -> SnorkelingRouteSyncPackage? {
        guard let data = UserDefaults.standard.data(forKey: Self.pendingKey) else { return nil }
        return try? SnorkelingRouteSyncCodec.decode(data)
    }

    #if DEBUG
    func resetForTesting() {
        activatedPackage = nil
        pendingPackage = nil
        activatedPackageID = nil
        activatedRevision = nil
        lastImportAt = nil
        lastImportError = nil
        staleRevisionRejected = false
        importedChecksums = []
        UserDefaults.standard.removeObject(forKey: Self.activatedKey)
        UserDefaults.standard.removeObject(forKey: Self.pendingKey)
        UserDefaults.standard.removeObject(forKey: Self.importedChecksumsKey)
    }
    #endif
}
