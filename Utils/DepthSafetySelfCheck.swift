import Foundation

/// Lightweight validation helpers (run from debugger or future test target).
enum DepthSafetySelfCheck {
    static func mappingFailures() -> [String] {
        var failures: [String] = []
        let cases: [(Double, DepthSafetyState)] = [
            (34.9, .normal),
            (35.0, .caution),
            (37.99, .caution),
            (38.0, .critical),
            (39.99, .critical),
            (40.0, .exceeded),
            (41.0, .exceeded)
        ]
        for (depth, expected) in cases {
            let actual = DepthSafetyState.from(depthMeters: depth)
            if actual != expected {
                failures.append("depth \(depth): expected \(expected), got \(actual)")
            }
        }
        return failures
    }
}
