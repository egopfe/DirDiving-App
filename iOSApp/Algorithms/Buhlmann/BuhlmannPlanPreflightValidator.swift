import Foundation

/// Explicit gas/profile validation before Bühlmann schedule generation.
enum BuhlmannPlanPreflightValidator {
    static func validate(_ request: BuhlmannPlanRequest) -> [BuhlmannPlanIssue] {
        BuhlmannEngine.validate(request)
    }
}
