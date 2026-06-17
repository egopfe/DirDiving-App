import Foundation
import Combine

@MainActor
final class ApneaImportedPlanStore: ObservableObject {
    static let shared = ApneaImportedPlanStore()

    static let activatedKey = "dirdiving_watch_apnea_imported_plan_activated_v1"
    static let pendingKey = "dirdiving_watch_apnea_imported_plan_pending_v1"
    static let importedChecksumsKey = "dirdiving_watch_apnea_imported_plan_checksums_v1"

    @Published private(set) var activatedPackage: ApneaSyncPackage?
    @Published private(set) var pendingPackage: ApneaSyncPackage?
    @Published private(set) var activatedPackageID: UUID?
    @Published private(set) var activatedRevision: Int?
    @Published private(set) var lastImportAt: Date?
    @Published private(set) var lastImportError: ApneaSyncValidationError?
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
           let package = try? ApneaSyncCodec.decode(data) {
            activatedPackage = package
            activatedPackageID = packageID
            activatedRevision = revision
        }
    }

    var hasPendingActivation: Bool {
        pendingPackage != nil
    }

    func importPayload(_ package: ApneaSyncPackage, source: String, sessionInProgress: Bool) -> Bool {
        staleRevisionRejected = false
        let fingerprint = "\(package.body.packageID.uuidString)|\(package.body.revision)|\(package.payloadChecksumSHA256)"
        if importedChecksums.contains(fingerprint) {
            return true
        }

        do {
            try ApneaSyncCodec.validate(package)
        } catch let error as ApneaSyncValidationError {
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

        activate(package)
        return true
    }

    func activatePendingIfNeeded(sessionInProgress: Bool) {
        guard !sessionInProgress, let pending = pendingPackage else { return }
        activate(pending)
        pendingPackage = nil
        clearPendingStorage()
    }

    func dismissPendingPlan() {
        pendingPackage = nil
        clearPendingStorage()
    }

    var readyPresentation: ApneaWatchImportedPlanPresentation {
        let package = activatedPackage ?? pendingPackage
        let plan = package?.body.plan
        let profile = package?.body.profile
        let settings = package?.body.settings ?? .default
        let targetDepth = plan?.entries.sorted(by: { $0.orderIndex < $1.orderIndex }).first?.targetDepthMeters
            ?? profile?.targetDepthMeters
            ?? 0
        let recoveryPolicy = plan?.recoveryPolicy ?? profile?.recoveryPolicy ?? .default
        let alarms = plan?.alarms.isEmpty == false ? (plan?.alarms ?? []) : (profile?.alarms ?? [])
        return ApneaWatchImportedPlanPresentation(
            targetDepthMeters: targetDepth,
            recoveryPolicyLabel: ApneaRecoveryPresentation.recoveryLabel(for: recoveryPolicy),
            enabledAlarmLabels: ApneaRecoveryPresentation.enabledAlarmLabels(from: alarms),
            missionModeEnabled: settings.missionModeEnabled,
            packageRevision: package?.body.revision,
            packageID: package?.body.packageID,
            hasImportedPlan: package != nil,
            isPendingWhileSessionActive: pendingPackage != nil && activatedPackage == nil
        )
    }

    #if DEBUG
    func resetForTests() {
        activatedPackage = nil
        pendingPackage = nil
        activatedPackageID = nil
        activatedRevision = nil
        lastImportAt = nil
        lastImportError = nil
        staleRevisionRejected = false
        importedChecksums = []
        UserDefaults.standard.removeObject(forKey: Self.pendingKey)
        UserDefaults.standard.removeObject(forKey: Self.activatedKey)
        UserDefaults.standard.removeObject(forKey: Self.importedChecksumsKey)
    }
    #endif

    private func activate(_ package: ApneaSyncPackage) {
        activatedPackage = package
        activatedPackageID = package.body.packageID
        activatedRevision = package.body.revision
        guard let data = try? ApneaSyncCodec.encode(package) else { return }
        UserDefaults.standard.set(
            [
                "packageID": package.body.packageID.uuidString,
                "revision": package.body.revision,
                "packageData": data,
            ],
            forKey: Self.activatedKey
        )
    }

    private func rememberChecksum(_ fingerprint: String) {
        importedChecksums.insert(fingerprint)
        let trimmed = Array(importedChecksums.suffix(64))
        importedChecksums = Set(trimmed)
        UserDefaults.standard.set(Array(importedChecksums), forKey: Self.importedChecksumsKey)
    }

    private func persistPending(_ package: ApneaSyncPackage) {
        guard let data = try? ApneaSyncCodec.encode(package) else { return }
        UserDefaults.standard.set(data, forKey: Self.pendingKey)
    }

    private func loadPending() -> ApneaSyncPackage? {
        guard let data = UserDefaults.standard.data(forKey: Self.pendingKey) else { return nil }
        return try? ApneaSyncCodec.decode(data)
    }

    private func clearPendingStorage() {
        UserDefaults.standard.removeObject(forKey: Self.pendingKey)
    }
}

struct ApneaWatchImportedPlanPresentation: Equatable {
    var targetDepthMeters: Double
    var recoveryPolicyLabel: String
    var enabledAlarmLabels: [String]
    var missionModeEnabled: Bool
    var packageRevision: Int?
    var packageID: UUID?
    var hasImportedPlan: Bool
    var isPendingWhileSessionActive: Bool
}
