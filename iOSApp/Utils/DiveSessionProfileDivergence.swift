import Foundation

/// Detects meaningful depth-profile divergence between local and cloud copies of the same session.
enum DiveSessionProfileDivergence {
    static let depthToleranceMeters = 0.05
    static let timestampToleranceSeconds: TimeInterval = 1.0

    static func profilesDiverge(_ local: DiveSession, _ cloud: DiveSession) -> Bool {
        let localSamples = DiveProfileMath.sanitizedSamples(local.samples)
        let cloudSamples = DiveProfileMath.sanitizedSamples(cloud.samples)

        if localSamples.isEmpty || cloudSamples.isEmpty {
            return false
        }

        if localSamples.count != cloudSamples.count {
            return true
        }

        let sortedLocal = localSamples.sorted { $0.timestamp < $1.timestamp }
        let sortedCloud = cloudSamples.sorted { $0.timestamp < $1.timestamp }
        for index in sortedLocal.indices {
            let localSample = sortedLocal[index]
            let cloudSample = sortedCloud[index]
            if abs(localSample.timestamp.timeIntervalSince(cloudSample.timestamp)) > timestampToleranceSeconds {
                return true
            }
            if abs(localSample.depthMeters - cloudSample.depthMeters) > depthToleranceMeters {
                return true
            }
        }

        if abs(local.maxDepthMeters - cloud.maxDepthMeters) > depthToleranceMeters {
            return true
        }

        return false
    }

    static func profileSummary(_ session: DiveSession) -> String {
        let samples = DiveProfileMath.sanitizedSamples(session.samples)
        guard !samples.isEmpty else { return "—" }
        return String(
            format: String(localized: "cloud.merge.profile_summary.format"),
            samples.count,
            session.maxDepthMeters
        )
    }
}
