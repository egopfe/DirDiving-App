import Foundation
import Combine

@MainActor
final class FullComputerImportedPlanStore: ObservableObject {
    static let shared = FullComputerImportedPlanStore()

    static let pendingKey = "dirdiving_watch_fc_imported_plan_pending_v1"
    static let activatedKey = "dirdiving_watch_fc_imported_plan_activated_v1"
    static let importedChecksumsKey = "dirdiving_watch_fc_imported_plan_checksums_v1"

    @Published private(set) var pendingPackage: DivePlanPackage?
    @Published private(set) var activatedPlanID: UUID?
    @Published private(set) var activatedRevision: Int?
    @Published private(set) var lastImportAt: Date?
    @Published private(set) var lastImportError: DivePlanPackageValidationError?

    private var importedChecksums: Set<String> = []

    private init() {
        pendingPackage = loadPending()
        importedChecksums = Set(UserDefaults.standard.stringArray(forKey: Self.importedChecksumsKey) ?? [])
        if let activated = UserDefaults.standard.dictionary(forKey: Self.activatedKey),
           let planIDRaw = activated["planID"] as? String,
           let planID = UUID(uuidString: planIDRaw),
           let revision = activated["revision"] as? Int {
            activatedPlanID = planID
            activatedRevision = revision
        }
    }

    var hasPendingActivation: Bool {
        pendingPackage != nil
    }

    func importPayload(_ package: DivePlanPackage, source: String) -> Bool {
        let fingerprint = "\(package.body.planID.uuidString)|\(package.body.revision)|\(package.payloadChecksumSHA256)"
        if importedChecksums.contains(fingerprint) {
            return true
        }

        do {
            try DivePlanPackageCodec.validate(package)
            let profile = try FullComputerGasProfile(importing: package)
            if !FullComputerGasProfileValidator.validate(profile).isEmpty {
                lastImportError = .invalidGases
                return false
            }
        } catch let error as DivePlanPackageValidationError {
            lastImportError = error
            return false
        } catch {
            lastImportError = .decodeFailed
            return false
        }

        if let current = pendingPackage {
            if package.body.planID == current.body.planID,
               package.body.revision < current.body.revision {
                return false
            }
            if package.body.planID == current.body.planID,
               package.body.revision == current.body.revision,
               package.payloadChecksumSHA256 == current.payloadChecksumSHA256 {
                rememberChecksum(fingerprint)
                return true
            }
        }

        pendingPackage = package
        lastImportAt = Date()
        lastImportError = nil
        persistPending(package)
        rememberChecksum(fingerprint)
        return true
    }

    func activatePendingPlan(configuration: FullComputerPrediveConfigurationStore = .shared) throws {
        guard let package = pendingPackage else { return }
        let profile = try FullComputerGasProfile(importing: package)
        configuration.importProfile(profile)
        activatedPlanID = package.body.planID
        activatedRevision = package.body.revision
        pendingPackage = nil
        clearPendingStorage()
        UserDefaults.standard.set(
            ["planID": package.body.planID.uuidString, "revision": package.body.revision],
            forKey: Self.activatedKey
        )
    }

    func dismissPendingPlan() {
        pendingPackage = nil
        clearPendingStorage()
    }

    #if DEBUG
    func resetForTests() {
        pendingPackage = nil
        activatedPlanID = nil
        activatedRevision = nil
        lastImportAt = nil
        lastImportError = nil
        importedChecksums = []
        UserDefaults.standard.removeObject(forKey: Self.pendingKey)
        UserDefaults.standard.removeObject(forKey: Self.activatedKey)
        UserDefaults.standard.removeObject(forKey: Self.importedChecksumsKey)
    }
    #endif

    private func rememberChecksum(_ fingerprint: String) {
        importedChecksums.insert(fingerprint)
        let trimmed = Array(importedChecksums.suffix(64))
        importedChecksums = Set(trimmed)
        UserDefaults.standard.set(Array(importedChecksums), forKey: Self.importedChecksumsKey)
    }

    private func persistPending(_ package: DivePlanPackage) {
        guard let data = try? DivePlanPackageCodec.encode(package) else { return }
        UserDefaults.standard.set(data, forKey: Self.pendingKey)
    }

    private func loadPending() -> DivePlanPackage? {
        guard let data = UserDefaults.standard.data(forKey: Self.pendingKey) else { return nil }
        return try? DivePlanPackageCodec.decode(data)
    }

    private func clearPendingStorage() {
        UserDefaults.standard.removeObject(forKey: Self.pendingKey)
    }
}