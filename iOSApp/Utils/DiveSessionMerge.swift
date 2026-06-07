import Foundation
import os

/// Documented merge policy for iCloud / sync session reconciliation.
enum DiveSessionMergePolicy: String {
    /// Metadata follows last-write-wins (`endDate`, then sample count, then duration).
    case metadataLastWriteWins
    /// Compatible depth profiles are union-merged by timestamp with max depth per second.
    case compatibleProfileUnion
    /// Divergent depth profiles keep the newer session's whole profile (no hybrid samples).
    case divergentProfileUsesNewerWholeProfile
}

enum DiveSessionMerge {
    private static let logger = Logger(subsystem: "com.egopfe.dirdiving.ios", category: "DiveSessionMerge")

    static func preferred(_ local: DiveSession, _ remote: DiveSession) -> DiveSession {
        let winner = newer(local, remote)
        let loser = winner.id == local.id ? remote : local
        if DiveSessionProfileDivergence.profilesDiverge(winner, loser) {
            logger.notice(
                "Profile merge policy \(DiveSessionMergePolicy.divergentProfileUsesNewerWholeProfile.rawValue, privacy: .public): session \(winner.id.uuidString, privacy: .public) keeps newer whole profile; divergent samples from loser discarded."
            )
        }
        let entryGPS = winner.entryGPS ?? loser.entryGPS
        let exitGPS = winner.exitGPS ?? loser.exitGPS
        let entryGPSFixSource = winner.entryGPS == nil && loser.entryGPS != nil ? loser.entryGPSFixSource : winner.entryGPSFixSource
        let exitGPSFixSource = winner.exitGPS == nil && loser.exitGPS != nil ? loser.exitGPSFixSource : winner.exitGPSFixSource
        let siteName = winner.siteName ?? loser.siteName
        let buddy = winner.buddy ?? loser.buddy
        let notes = winner.notes ?? loser.notes
        let sacLitersMinute = winner.sacLitersMinute ?? loser.sacLitersMinute
        let isDemo = winner.isDemo || loser.isDemo
        let isManual = winner.isManual || loser.isManual
        let equipmentUsed = mergedString(winner.equipmentUsed, loser.equipmentUsed)
        let entryPressureText = mergedString(winner.entryPressureText, loser.entryPressureText)
        let exitPressureText = mergedString(winner.exitPressureText, loser.exitPressureText)
        let entryPressureBar = winner.entryPressureBar ?? loser.entryPressureBar
        let exitPressureBar = winner.exitPressureBar ?? loser.exitPressureBar
        let decompressionNotes = mergedString(winner.decompressionNotes, loser.decompressionNotes)
        let startDate = min(winner.startDate, loser.startDate)
        let endDate = max(winner.endDate, loser.endDate)
        let samples = resolvedSamples(
            winner: winner,
            loser: loser,
            startDate: startDate,
            endDate: endDate
        )
        let summary = DiveProfileMath.summary(samples: samples, startDate: startDate, endDate: endDate)

        return DiveSession(
            id: winner.id,
            startDate: startDate,
            endDate: endDate,
            durationSeconds: summary.durationSeconds,
            maxDepthMeters: summary.samples.isEmpty ? max(winner.maxDepthMeters, loser.maxDepthMeters) : summary.maxDepthMeters,
            avgDepthMeters: summary.samples.isEmpty
                ? mergedManualAverageDepthMeters(winner: winner, loser: loser)
                : summary.averageDepthMeters,
            avgWaterTemperatureCelsius: summary.averageTemperatureCelsius ?? winner.avgWaterTemperatureCelsius ?? loser.avgWaterTemperatureCelsius,
            ttv: summary.samples.isEmpty ? max(winner.ttv, loser.ttv) : summary.ttv,
            entryGPS: entryGPS,
            exitGPS: exitGPS,
            entryGPSFixSource: entryGPSFixSource,
            exitGPSFixSource: exitGPSFixSource,
            samples: summary.samples,
            siteName: siteName,
            buddy: buddy,
            notes: notes,
            gasLabel: winner.gasLabel,
            sacLitersMinute: sacLitersMinute,
            isDemo: isDemo,
            exceededSupportedDepthRange: winner.exceededSupportedDepthRange || loser.exceededSupportedDepthRange || summary.exceededSupportedDepthRange,
            isManual: isManual,
            equipmentUsed: equipmentUsed,
            entryPressureText: entryPressureText,
            exitPressureText: exitPressureText,
            entryPressureBar: entryPressureBar,
            exitPressureBar: exitPressureBar,
            decompressionNotes: decompressionNotes
        )
    }

    /// Uses whole-profile winner when both sides have divergent samples; otherwise unions compatible profiles.
    private static func resolvedSamples(
        winner: DiveSession,
        loser: DiveSession,
        startDate: Date,
        endDate: Date
    ) -> [DiveSample] {
        if DiveSessionProfileDivergence.profilesDiverge(winner, loser) {
            return DiveProfileMath.sanitizedSamples(winner.samples)
                .filter { $0.timestamp >= startDate && $0.timestamp <= endDate }
        }
        return mergedSamples(winner.samples, loser.samples, startDate: startDate, endDate: endDate)
    }

    private static func mergedSamples(_ first: [DiveSample], _ second: [DiveSample], startDate: Date, endDate: Date) -> [DiveSample] {
        let candidates = DiveProfileMath.sanitizedSamples(first + second)
            .filter { $0.timestamp >= startDate && $0.timestamp <= endDate }
        var byTimestamp: [TimeInterval: DiveSample] = [:]
        for sample in candidates {
            let key = sample.timestamp.timeIntervalSinceReferenceDate.rounded(.toNearestOrAwayFromZero)
            if let existing = byTimestamp[key] {
                byTimestamp[key] = sample.depthMeters >= existing.depthMeters ? sample : existing
            } else {
                byTimestamp[key] = sample
            }
        }
        return byTimestamp.values.sorted { $0.timestamp < $1.timestamp }
    }

    private static func mergedString(_ primary: String?, _ secondary: String?) -> String? {
        if let primary, !primary.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return primary
        }
        if let secondary, !secondary.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return secondary
        }
        return nil
    }

    /// When neither side has a depth profile, keep the newer session's average depth; if missing, the larger trusted value (never `min`, which under-reports).
    private static func mergedManualAverageDepthMeters(winner: DiveSession, loser: DiveSession) -> Double {
        let winnerAvg = winner.avgDepthMeters
        let loserAvg = loser.avgDepthMeters
        if winnerAvg > 0, loserAvg > 0 {
            return max(winnerAvg, loserAvg)
        }
        if winnerAvg > 0 { return winnerAvg }
        if loserAvg > 0 { return loserAvg }
        return 0
    }

    private static func newer(_ lhs: DiveSession, _ rhs: DiveSession) -> DiveSession {
        if lhs.endDate != rhs.endDate {
            return lhs.endDate >= rhs.endDate ? lhs : rhs
        }
        if lhs.samples.count != rhs.samples.count {
            return lhs.samples.count >= rhs.samples.count ? lhs : rhs
        }
        if lhs.durationSeconds != rhs.durationSeconds {
            return lhs.durationSeconds >= rhs.durationSeconds ? lhs : rhs
        }
        return lhs
    }
}
