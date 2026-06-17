import Foundation

enum ApneaSessionPlanValidationIssue: Equatable, Hashable {
    case emptyTitle
    case noEntries
    case invalidDepth(index: Int)
    case invalidDuration(index: Int)
    case invalidRecovery(index: Int)
    case nonMonotonicPyramid(index: Int)
    case duplicateOrderIndex
}

enum ApneaSessionPlanValidator {
    static func validate(_ plan: ApneaSessionPlan) -> [ApneaSessionPlanValidationIssue] {
        var issues: [ApneaSessionPlanValidationIssue] = []
        if plan.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            issues.append(.emptyTitle)
        }
        if plan.entries.isEmpty {
            issues.append(.noEntries)
        }

        var seenOrder = Set<Int>()
        let sorted = plan.entries.sorted { $0.orderIndex < $1.orderIndex }
        for entry in sorted {
            if !seenOrder.insert(entry.orderIndex).inserted {
                issues.append(.duplicateOrderIndex)
            }
            if !entry.targetDepthMeters.isFinite || entry.targetDepthMeters <= 0 {
                issues.append(.invalidDepth(index: entry.orderIndex))
            }
            if !entry.targetDurationSeconds.isFinite || entry.targetDurationSeconds <= 0 {
                issues.append(.invalidDuration(index: entry.orderIndex))
            }
            if !entry.plannedRecoverySeconds.isFinite || entry.plannedRecoverySeconds < 0 {
                issues.append(.invalidRecovery(index: entry.orderIndex))
            }
        }

        if plan.kind == .pyramid, sorted.count >= 3 {
            let depths = sorted.map(\.targetDepthMeters)
            let peak = depths.max() ?? 0
            guard let peakIndex = depths.firstIndex(of: peak) else { return issues }
            for index in 0..<peakIndex where depths[index] >= depths[index + 1] {
                issues.append(.nonMonotonicPyramid(index: sorted[index].orderIndex))
            }
            for index in peakIndex..<(depths.count - 1) where depths[index] <= depths[index + 1] {
                issues.append(.nonMonotonicPyramid(index: sorted[index].orderIndex))
            }
        }

        return issues
    }

    static func isValid(_ plan: ApneaSessionPlan) -> Bool {
        validate(plan).isEmpty
    }
}
