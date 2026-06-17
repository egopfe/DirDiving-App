import Foundation

enum ApneaSyncPackageBuilder {
    static func build(
        plan: ApneaSessionPlan,
        profile: ApneaCompanionProfile?,
        settings: ApneaCompanionSettings,
        packageID: UUID,
        revision: Int,
        expiresAt: Date? = Date().addingTimeInterval(ApneaSyncCodec.defaultTTL)
    ) throws -> ApneaSyncPackage {
        var normalizedPlan = plan
        normalizedPlan.transferState = .validated
        let body = ApneaSyncPackageBody(
            schemaVersion: ApneaSyncCodec.currentSchemaVersion,
            packageID: packageID,
            revision: revision,
            createdAt: Date(),
            expiresAt: expiresAt,
            plan: normalizedPlan,
            profile: profile,
            settings: settings,
            capabilities: .current
        )
        return try ApneaSyncCodec.seal(body)
    }
}
