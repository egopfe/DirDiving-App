import Foundation

enum ApneaDataQualityEvaluator {
    static func evaluate(session: ApneaSession, heartRateAvailable: Bool = false) -> ApneaSessionQualityReport {
        let stats = session.refreshedStatistics()
        let validHolds = session.dives.filter { $0.durationSeconds > 0 }.count
        let recoveryComplete = session.dives.allSatisfy { dive in
            guard let recovery = dive.recoveryAfter else { return true }
            return recovery.completedSeconds != nil || recovery.wasSkipped
        }
        let depthAvailable = stats.sessionMaxDepthMeters > 0 || session.dives.contains { !$0.samples.isEmpty }
        let gapCount = session.dives.flatMap(\.samples).filter { $0.quality == .missing || $0.quality == .rejected }.count

        let completeness: ApneaDataQualityLevel
        if validHolds == 0 { completeness = .unavailable }
        else if session.warnings.contains(.dataQualityDegraded) || session.warnings.contains(.sparseSamples) { completeness = .poor }
        else if gapCount > 0 { completeness = .medium }
        else { completeness = .good }

        let depthSignal: ApneaSensorSignalLevel
        if !depthAvailable { depthSignal = .unavailable }
        else if session.warnings.contains(.sparseSamples) { depthSignal = .weak }
        else { depthSignal = .good }

        let sensors = ApneaSensorQuality(
            depth: depthSignal,
            heartRate: heartRateAvailable ? .good : .unavailable,
            spO2: .unavailable
        )

        let overall: ApneaDataQualityLevel
        switch (completeness, depthSignal) {
        case (.good, .good): overall = .good
        case (.unavailable, _), (.poor, _): overall = .poor
        case (_, .unavailable): overall = .medium
        default: overall = .medium
        }

        return ApneaSessionQualityReport(
            overall: overall,
            sensors: sensors,
            sessionCompleteness: completeness,
            validHoldCount: validHolds,
            recoveryTrackingComplete: recoveryComplete,
            depthAvailable: depthAvailable,
            heartRateAvailable: heartRateAvailable,
            sensorGapCount: gapCount
        )
    }
}

enum ApneaSensorQualityEvaluator {
    static func compactLabels(for sensors: ApneaSensorQuality) -> [String] {
        var labels: [String] = []
        switch sensors.depth {
        case .good: labels.append("apnea.watch.sensors_ok")
        case .weak: labels.append("apnea.watch.depth_weak")
        case .unavailable: break
        }
        if sensors.heartRate == .unavailable {
            labels.append("apnea.watch.hr_unavailable")
        }
        return labels
    }
}
