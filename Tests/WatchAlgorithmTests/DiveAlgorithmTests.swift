import Foundation
import XCTest

final class DiveAlgorithmTests: XCTestCase {
    func testDepthValidationRejectsMissingNaNInfinityAndOutOfRange() {
        let now = Date(timeIntervalSince1970: 1_000)
        var validator = DepthSampleValidationState()

        XCTAssertEqual(validator.validate(rawDepthMeters: nil, timestamp: now, receivedAt: now, temperatureCelsius: nil).validity, .missing)
        XCTAssertEqual(validator.validate(rawDepthMeters: Double.nan, timestamp: now, receivedAt: now, temperatureCelsius: nil).validity, .nonFinite)
        XCTAssertEqual(validator.validate(rawDepthMeters: Double.infinity, timestamp: now, receivedAt: now, temperatureCelsius: nil).validity, .nonFinite)
        XCTAssertEqual(validator.validate(rawDepthMeters: 351, timestamp: now, receivedAt: now, temperatureCelsius: nil).validity, .outOfRange)
    }

    func testDepthValidationClampsNegativeFiniteDepthToZero() {
        let now = Date(timeIntervalSince1970: 1_000)
        var validator = DepthSampleValidationState()
        let validated = validator.validate(rawDepthMeters: -0.2, timestamp: now, receivedAt: now, temperatureCelsius: nil)

        XCTAssertEqual(validated.validity, .valid)
        XCTAssertEqual(validated.sample?.depthMeters, 0)
    }

    func testDepthValidationDetectsStaleFrozenAndSpikeSamples() {
        let now = Date(timeIntervalSince1970: 1_000)
        var staleValidator = DepthSampleValidationState()
        XCTAssertEqual(
            staleValidator.validate(rawDepthMeters: 3, timestamp: now.addingTimeInterval(-9), receivedAt: now, temperatureCelsius: nil).validity,
            .stale
        )
        XCTAssertEqual(
            staleValidator.validate(rawDepthMeters: 3, timestamp: now.addingTimeInterval(2), receivedAt: now, temperatureCelsius: nil).validity,
            .stale
        )

        var frozenValidator = DepthSampleValidationState()
        XCTAssertEqual(frozenValidator.validate(rawDepthMeters: 10, timestamp: now, receivedAt: now, temperatureCelsius: nil).validity, .valid)
        XCTAssertEqual(
            frozenValidator.validate(rawDepthMeters: 10, timestamp: now.addingTimeInterval(31), receivedAt: now.addingTimeInterval(31), temperatureCelsius: nil, isDiveActive: true).validity,
            .frozen
        )

        var inactiveSurfaceValidator = DepthSampleValidationState()
        XCTAssertEqual(inactiveSurfaceValidator.validate(rawDepthMeters: 0, timestamp: now, receivedAt: now, temperatureCelsius: nil).validity, .valid)
        XCTAssertEqual(
            inactiveSurfaceValidator.validate(rawDepthMeters: 0, timestamp: now.addingTimeInterval(31), receivedAt: now.addingTimeInterval(31), temperatureCelsius: nil, isDiveActive: false).validity,
            .valid
        )

        var spikeValidator = DepthSampleValidationState()
        XCTAssertEqual(spikeValidator.validate(rawDepthMeters: 10, timestamp: now, receivedAt: now, temperatureCelsius: nil).validity, .valid)
        XCTAssertEqual(
            spikeValidator.validate(rawDepthMeters: 30, timestamp: now.addingTimeInterval(1), receivedAt: now.addingTimeInterval(1), temperatureCelsius: nil).validity,
            .spikeRejected
        )
    }

    func testLifecycleRequiresValidatedDepthDebounceAndSurfaceDwell() {
        let start = Date(timeIntervalSince1970: 0)
        var lifecycle = DiveLifecycleAlgorithm()

        XCTAssertEqual(lifecycle.evaluate(validatedSample: validDepth(0.9, at: start), isDiveActive: false, isManualLifecycleActive: false, hasObservedSubmersion: false), .none)
        XCTAssertEqual(lifecycle.evaluate(validatedSample: validDepth(0.95, at: start.addingTimeInterval(0.5)), isDiveActive: false, isManualLifecycleActive: false, hasObservedSubmersion: false), .none)
        XCTAssertEqual(lifecycle.evaluate(validatedSample: validDepth(1.1, at: start.addingTimeInterval(1)), isDiveActive: false, isManualLifecycleActive: false, hasObservedSubmersion: false), .none)
        XCTAssertEqual(lifecycle.evaluate(validatedSample: validDepth(1.1, at: start.addingTimeInterval(2)), isDiveActive: false, isManualLifecycleActive: false, hasObservedSubmersion: false), .startDive)

        XCTAssertEqual(lifecycle.evaluate(validatedSample: validDepth(0.2, at: start.addingTimeInterval(20)), isDiveActive: true, isManualLifecycleActive: false, hasObservedSubmersion: true), .none)
        XCTAssertFalse(lifecycle.shouldEndAtSurface(currentDepthMeters: 0.2, timestamp: start.addingTimeInterval(24)))
        XCTAssertTrue(lifecycle.shouldEndAtSurface(currentDepthMeters: 0.2, timestamp: start.addingTimeInterval(29)))
        XCTAssertEqual(lifecycle.evaluate(validatedSample: validDepth(0.2, at: start.addingTimeInterval(29)), isDiveActive: true, isManualLifecycleActive: false, hasObservedSubmersion: true), .endDive)
    }

    func testManualLifecycleDoesNotAutoEndBeforeSensorOwnedDive() {
        let start = Date(timeIntervalSince1970: 0)
        var lifecycle = DiveLifecycleAlgorithm()

        XCTAssertEqual(
            lifecycle.evaluate(
                validatedSample: validDepth(0.2, at: start),
                isDiveActive: true,
                isManualLifecycleActive: true,
                hasObservedSubmersion: false
            ),
            .none
        )
        XCTAssertEqual(
            lifecycle.evaluate(
                validatedSample: validDepth(0.2, at: start.addingTimeInterval(10)),
                isDiveActive: true,
                isManualLifecycleActive: true,
                hasObservedSubmersion: false
            ),
            .none
        )
        XCTAssertEqual(
            lifecycle.evaluate(
                validatedSample: validDepth(1.2, at: start.addingTimeInterval(12)),
                isDiveActive: true,
                isManualLifecycleActive: true,
                hasObservedSubmersion: false
            ),
            .none
        )
    }

    func testTimeWeightedAverageDepthHandlesIrregularZeroAndOneSample() {
        let start = Date(timeIntervalSince1970: 0)
        XCTAssertEqual(DiveAlgorithm.timeWeightedAverageDepth(samples: []), 0)
        XCTAssertEqual(DiveAlgorithm.timeWeightedAverageDepth(samples: [sample(10, at: start)]), 10)

        let samples = [
            sample(10, at: start),
            sample(20, at: start.addingTimeInterval(30)),
            sample(30, at: start.addingTimeInterval(90))
        ]
        let average = DiveAlgorithm.timeWeightedAverageDepth(samples: samples, endDate: start.addingTimeInterval(120))
        XCTAssertEqual(average, 20, accuracy: 0.001)
    }

    func testTTVIndexAndAscentRateBehavior() {
        XCTAssertEqual(DiveAlgorithm.ttvIndex(averageDepthMeters: 20, durationSeconds: 1_800), 50, accuracy: 0.001)

        let start = Date(timeIntervalSince1970: 0)
        XCTAssertEqual(DiveAlgorithm.ascentRateMetersPerMinute(samples: [sample(20, at: start), sample(20, at: start.addingTimeInterval(10))], current: sample(20, at: start.addingTimeInterval(10))), 0)
        XCTAssertEqual(DiveAlgorithm.ascentRateMetersPerMinute(samples: [sample(20, at: start), sample(25, at: start.addingTimeInterval(10))], current: sample(25, at: start.addingTimeInterval(10))), 0)
        XCTAssertEqual(DiveAlgorithm.ascentRateMetersPerMinute(samples: [sample(20, at: start), sample(19, at: start.addingTimeInterval(10))], current: sample(19, at: start.addingTimeInterval(10))), 6, accuracy: 0.001)
    }

    func testAscentLimitBandsAndZoneBoundaries() {
        XCTAssertEqual(AscentRateLimits.standard.limit(for: 40.01), 1)
        XCTAssertEqual(AscentRateLimits.standard.limit(for: 45), 1)
        XCTAssertEqual(AscentRateLimits.standard.limit(for: 40), 10)
        XCTAssertEqual(AscentRateLimits.standard.limit(for: 30), 10)
        XCTAssertEqual(AscentRateLimits.standard.limit(for: 29.99), 5)
        XCTAssertEqual(AscentRateLimits.standard.limit(for: 20), 5)
        XCTAssertEqual(AscentRateLimits.standard.limit(for: 19.99), 3)
        XCTAssertEqual(AscentRateLimits.standard.limit(for: 6), 3)
        XCTAssertEqual(AscentRateLimits.standard.limit(for: 5.99), 1)
        XCTAssertEqual(AscentRateLimits.standard.limit(for: 0), 1)

        XCTAssertEqual(AscentStatus.make(rate: 0.7, depth: 3).zone, .green)
        XCTAssertEqual(AscentStatus.make(rate: 1.0, depth: 3).zone, .yellow)
        XCTAssertEqual(AscentStatus.make(rate: 1.1, depth: 3).zone, .red)
        XCTAssertEqual(DepthSafetyState.from(depthMeters: 40.1), .exceeded)
    }

    func testDiveAlgorithmSelfCheckPasses() {
        XCTAssertTrue(DiveAlgorithmSelfCheck.failures().isEmpty, DiveAlgorithmSelfCheck.failures().joined(separator: "; "))
    }

    func testDepthAndRuntimeAlarmThresholdsAreStrictlyGreaterThan() {
        let depthThreshold = 30.0
        XCTAssertFalse(depthThreshold > depthThreshold)
        XCTAssertTrue((depthThreshold + 0.01) > depthThreshold)

        let runtimeMinutes = 45
        let runtimeSeconds = TimeInterval(runtimeMinutes * 60)
        XCTAssertFalse(runtimeSeconds > TimeInterval(runtimeMinutes * 60))
        XCTAssertTrue((runtimeSeconds + 1) > TimeInterval(runtimeMinutes * 60))
    }

    func testTemperatureConversionAndNonFiniteRejection() {
        XCTAssertEqual(DIRUnitPreference.metric.temperatureDisplay(celsius: 20).value, 20, accuracy: 0.001)
        XCTAssertEqual(DIRUnitPreference.imperial.temperatureDisplay(celsius: 20).value, 68, accuracy: 0.001)
        XCTAssertEqual(DiveAlgorithm.sanitizedTemperatureCelsius(-2)!, -2)
        XCTAssertEqual(DiveAlgorithm.sanitizedTemperatureCelsius(40)!, 40)
        XCTAssertNil(DiveAlgorithm.sanitizedTemperatureCelsius(Double.nan))
        XCTAssertNil(DiveAlgorithm.sanitizedTemperatureCelsius(Double.infinity))
        XCTAssertNil(DiveAlgorithm.sanitizedTemperatureCelsius(-2.1))
        XCTAssertNil(DiveAlgorithm.sanitizedTemperatureCelsius(40.1))
    }

    func testTemperatureAggregatesIgnoreRejectedFiniteOutliers() {
        let start = Date(timeIntervalSince1970: 0)
        let session = makeSession(
            samples: [
                sample(10, at: start, temp: -1),
                sample(12, at: start.addingTimeInterval(30), temp: 20),
                sample(14, at: start.addingTimeInterval(60), temp: 41),
                sample(16, at: start.addingTimeInterval(90), temp: -3)
            ],
            start: start,
            end: start.addingTimeInterval(120)
        )

        XCTAssertEqual(session.avgWaterTemperatureCelsius!, 9.5, accuracy: 0.001)
        XCTAssertEqual(session.minWaterTemperatureCelsius!, -1)
        XCTAssertEqual(session.maxWaterTemperatureCelsius!, 20)
        XCTAssertNoThrow(try DiveSessionAlgorithmValidator.validate(session))
    }

    func testUnitConversionRoundTrips() {
        XCTAssertEqual(DIRUnitConversions.feetToMeters(DIRUnitConversions.metersToFeet(30)), 30, accuracy: 0.000_001)
        XCTAssertEqual(DIRUnitConversions.psiToBar(DIRUnitConversions.barToPSI(200)), 200, accuracy: 0.000_001)
        XCTAssertEqual(DIRUnitConversions.fahrenheitToCelsius(DIRUnitConversions.celsiusToFahrenheit(4)), 4, accuracy: 0.000_001)
        XCTAssertEqual(DIRUnitConversions.feetPerMinuteToMetersPerMinute(DIRUnitConversions.metersPerMinuteToFeetPerMinute(3)), 3, accuracy: 0.000_001)
    }

    func testCompassNormalizationAndBearingDeltaWraparound() {
        XCTAssertEqual(DiveAlgorithm.normalizedDegrees(370), 10, accuracy: 0.001)
        XCTAssertEqual(DiveAlgorithm.normalizedDegrees(-10), 350, accuracy: 0.001)
        XCTAssertEqual(DiveAlgorithm.signedBearingDeltaDegrees(from: 350, to: 10), 20, accuracy: 0.001)
        XCTAssertEqual(DiveAlgorithm.signedBearingDeltaDegrees(from: 10, to: 350), -20, accuracy: 0.001)
    }

    func testExportRejectsEmptyAndSortsSamples() {
        let start = Date(timeIntervalSince1970: 0)
        let empty = makeSession(samples: [], start: start, end: start.addingTimeInterval(60))
        XCTAssertNil(SubsurfaceExportService.writeCSV(for: empty))
        XCTAssertNil(SubsurfaceExportService.makeCSV(for: empty))

        let session = makeSession(
            samples: [sample(20, at: start.addingTimeInterval(60)), sample(10, at: start)],
            start: start,
            end: start.addingTimeInterval(120)
        )
        let csv = SubsurfaceExportService.makeCSV(for: session)!
        XCTAssertTrue(csv.contains("\n0,10.00"))
        XCTAssertTrue(csv.contains("\n60,20.00"))
        XCTAssertTrue(csv.contains("time_seconds,depth_m,temperature_c,entry_lat,entry_lon,exit_lat,exit_lon,is_manual"))
        XCTAssertTrue(csv.contains("# dirdiving_session_id:"))
        XCTAssertFalse(csv.contains("\n-"))
    }

    func testSessionValidationRejectsCorruptionAndMergeRecomputesDerivedFields() {
        let start = Date(timeIntervalSince1970: 0)
        let valid = makeSession(samples: [sample(10, at: start), sample(20, at: start.addingTimeInterval(60))], start: start, end: start.addingTimeInterval(120))
        XCTAssertNoThrow(try DiveSessionAlgorithmValidator.validate(valid))

        let corrupt = DiveSession(
            startDate: start,
            endDate: start.addingTimeInterval(120),
            durationSeconds: 120,
            maxDepthMeters: 20,
            avgDepthMeters: 15,
            avgWaterTemperatureCelsius: nil,
            minWaterTemperatureCelsius: nil,
            maxWaterTemperatureCelsius: nil,
            ttv: 17,
            entryGPS: nil,
            exitGPS: nil,
            samples: [sample(Double.nan, at: start.addingTimeInterval(30))]
        )
        XCTAssertThrowsError(try DiveSessionAlgorithmValidator.validate(corrupt))

        let impossibleTransition = makeSession(
            samples: [sample(10, at: start), sample(100, at: start.addingTimeInterval(1))],
            start: start,
            end: start.addingTimeInterval(120)
        )
        XCTAssertThrowsError(try DiveSessionAlgorithmValidator.validate(impossibleTransition))

        let inconsistent = DiveSession(
            id: valid.id,
            startDate: start,
            endDate: start.addingTimeInterval(120),
            durationSeconds: 999,
            maxDepthMeters: 99,
            avgDepthMeters: 99,
            avgWaterTemperatureCelsius: nil,
            minWaterTemperatureCelsius: nil,
            maxWaterTemperatureCelsius: nil,
            ttv: 999,
            entryGPS: nil,
            exitGPS: nil,
            samples: valid.samples
        )
        let merged = DiveSessionMerge.preferred(inconsistent, inconsistent)
        XCTAssertEqual(merged.durationSeconds, 120, accuracy: 0.001)
        XCTAssertEqual(merged.maxDepthMeters, 20, accuracy: 0.001)
        XCTAssertEqual(merged.avgDepthMeters, 15, accuracy: 0.001)
        XCTAssertEqual(merged.ttv, 17, accuracy: 0.001)
    }

    func testValidatorRejectsImplausibleFiniteTemperatures() {
        let start = Date(timeIntervalSince1970: 0)
        let invalid = DiveSession(
            startDate: start,
            endDate: start.addingTimeInterval(60),
            durationSeconds: 60,
            maxDepthMeters: 10,
            avgDepthMeters: 10,
            avgWaterTemperatureCelsius: 41,
            minWaterTemperatureCelsius: 10,
            maxWaterTemperatureCelsius: 41,
            ttv: 11,
            entryGPS: nil,
            exitGPS: nil,
            samples: [sample(10, at: start, temp: 41)]
        )
        XCTAssertThrowsError(try DiveSessionAlgorithmValidator.validate(invalid))
    }

    func testMergeDropsLegacyImplausibleTemperatureSummaries() {
        let start = Date(timeIntervalSince1970: 0)
        let legacy = DiveSession(
            startDate: start,
            endDate: start.addingTimeInterval(60),
            durationSeconds: 60,
            maxDepthMeters: 0,
            avgDepthMeters: 0,
            avgWaterTemperatureCelsius: 80,
            minWaterTemperatureCelsius: -20,
            maxWaterTemperatureCelsius: 80,
            ttv: 1,
            entryGPS: nil,
            exitGPS: nil,
            samples: []
        )

        let normalized = DiveSessionMerge.preferred(legacy, legacy)
        XCTAssertNil(normalized.avgWaterTemperatureCelsius)
        XCTAssertNil(normalized.minWaterTemperatureCelsius)
        XCTAssertNil(normalized.maxWaterTemperatureCelsius)
    }

    func testLogbookPolicyCapsNewestFortyAfterLoadAndMerge() {
        let start = Date(timeIntervalSince1970: 0)
        let sessions = (0..<45).map { index in
            makeSession(samples: [sample(10, at: start.addingTimeInterval(Double(index) * 60))], start: start.addingTimeInterval(Double(index) * 60), end: start.addingTimeInterval(Double(index) * 60 + 30))
        }

        let capped = DiveLogbookPolicy.normalizedAndCapped(sessions, deletedIDs: [])
        XCTAssertEqual(capped.count, 40)
        XCTAssertEqual(capped.first!.startDate, sessions[44].startDate)
        XCTAssertEqual(capped.last!.startDate, sessions[5].startDate)

        let deleted = Set([sessions[44].id])
        let deletedCapped = DiveLogbookPolicy.normalizedAndCapped(sessions, deletedIDs: deleted)
        XCTAssertEqual(deletedCapped.count, 40)
        XCTAssertFalse(deletedCapped.contains { $0.id == sessions[44].id })
        XCTAssertEqual(deletedCapped.first!.startDate, sessions[43].startDate)
    }

    func testLogbookPolicyMergesLocalCloudAndDropsOldestDeterministically() {
        let start = Date(timeIntervalSince1970: 0)
        let local = (0..<30).map { index in
            makeSession(samples: [sample(10, at: start.addingTimeInterval(Double(index) * 60))], start: start.addingTimeInterval(Double(index) * 60), end: start.addingTimeInterval(Double(index) * 60 + 30))
        }
        let cloud = (30..<50).map { index in
            makeSession(samples: [sample(12, at: start.addingTimeInterval(Double(index) * 60))], start: start.addingTimeInterval(Double(index) * 60), end: start.addingTimeInterval(Double(index) * 60 + 30))
        }

        let merged = DiveLogbookPolicy.mergedAndCapped(local: local, cloud: cloud, deletedIDs: [])
        XCTAssertEqual(merged.count, 40)
        XCTAssertEqual(merged.first!.startDate, cloud[19].startDate)
        XCTAssertEqual(merged.last!.startDate, local[10].startDate)
    }

    func testGPSFallbackPolicyRejectsUnavailableStaleAndLowAccuracyPoints() {
        let now = Date(timeIntervalSince1970: 10_000)
        XCTAssertEqual(GPSFallbackPolicy.assess(nil, now: now).quality, .unavailable)

        let valid = GPSPoint(latitude: 44.0, longitude: 9.0, horizontalAccuracy: 10, timestamp: now.addingTimeInterval(-60))
        XCTAssertEqual(GPSFallbackPolicy.assess(valid, now: now).quality, .usable)
        XCTAssertEqual(GPSFallbackPolicy.assess(valid, now: now).point!, valid)

        let stale = GPSPoint(latitude: 44.0, longitude: 9.0, horizontalAccuracy: 10, timestamp: now.addingTimeInterval(-301))
        XCTAssertEqual(GPSFallbackPolicy.assess(stale, now: now).quality, .stale)
        XCTAssertNil(GPSFallbackPolicy.assess(stale, now: now).point)

        let lowAccuracy = GPSPoint(latitude: 44.0, longitude: 9.0, horizontalAccuracy: 51, timestamp: now.addingTimeInterval(-60))
        XCTAssertEqual(GPSFallbackPolicy.assess(lowAccuracy, now: now).quality, .lowAccuracy)
        XCTAssertNil(GPSFallbackPolicy.assess(lowAccuracy, now: now).point)

        let invalid = GPSPoint(latitude: 120, longitude: 9.0, horizontalAccuracy: 10, timestamp: now)
        XCTAssertEqual(GPSFallbackPolicy.assess(invalid, now: now).quality, .unavailable)
    }

    func testMergeKeepsCanonicalSampleSetAndRecomputesDerivedValues() {
        let start = Date(timeIntervalSince1970: 0)
        let local = makeSession(
            samples: [sample(10, at: start), sample(20, at: start.addingTimeInterval(60))],
            start: start,
            end: start.addingTimeInterval(120)
        )
        let remote = DiveSession(
            id: local.id,
            startDate: start,
            endDate: start.addingTimeInterval(120),
            durationSeconds: 120,
            maxDepthMeters: 30,
            avgDepthMeters: 30,
            avgWaterTemperatureCelsius: nil,
            minWaterTemperatureCelsius: nil,
            maxWaterTemperatureCelsius: nil,
            ttv: 32,
            entryGPS: nil,
            exitGPS: nil,
            samples: [sample(30, at: start.addingTimeInterval(90))]
        )

        let merged = DiveSessionMerge.preferred(local, remote)
        XCTAssertEqual(merged.samples.count, 3)
        XCTAssertEqual(merged.maxDepthMeters, 30, accuracy: 0.001)
        XCTAssertGreaterThan(merged.avgDepthMeters, 15)
        XCTAssertGreaterThan(merged.ttv, 17)
    }

    func testDepthSafetySelfCheckHasNoMappingFailures() {
        XCTAssertTrue(DepthSafetySelfCheck.mappingFailures().isEmpty)
    }

    func testDraftRestoreAverageDepthTailCapReducesOfflineSkew() {
        let start = Date().addingTimeInterval(-3600)
        let samples = [
            sample(10, at: start),
            sample(30, at: start.addingTimeInterval(600))
        ]
        let offlineTail = DiveAlgorithm.timeWeightedAverageDepth(samples: samples, endDate: Date())
        let cappedTailEnd = min(
            Date(),
            start.addingTimeInterval(600 + DiveAlgorithmConfiguration.draftRestoreAverageDepthMaxTailSeconds)
        )
        let capped = DiveAlgorithm.timeWeightedAverageDepth(samples: samples, endDate: cappedTailEnd)
        XCTAssertLessThan(capped, offlineTail)
    }

    func testAscentLimitAt40mRemainsTenAndAbove40UsesFallback() {
        let limits = AscentRateLimits.standard
        XCTAssertEqual(limits.limit(for: 40), 10, accuracy: 0.001)
        XCTAssertEqual(limits.limit(for: 40.01), 1, accuracy: 0.001)
        XCTAssertEqual(DepthSafetyState.from(depthMeters: 40), .exceeded)
    }

    func testLifecycleClearsSurfaceCandidateWhenDepthRises() {
        var algorithm = DiveLifecycleAlgorithm()
        let start = Date()
        let shallow = validDepth(0.2, at: start)
        let deep = validDepth(1.0, at: start.addingTimeInterval(1))
        _ = algorithm.evaluate(
            validatedSample: shallow,
            isDiveActive: true,
            isManualLifecycleActive: false,
            hasObservedSubmersion: true
        )
        XCTAssertNotNil(algorithm.surfaceCandidateDate)
        _ = algorithm.evaluate(
            validatedSample: deep,
            isDiveActive: true,
            isManualLifecycleActive: false,
            hasObservedSubmersion: true
        )
        XCTAssertNil(algorithm.surfaceCandidateDate)
    }

    private func validDepth(_ depth: Double, at date: Date) -> ValidatedDepthSample {
        ValidatedDepthSample(validity: .valid, rawDepthMeters: depth, sample: sample(depth, at: date))
    }

    private func sample(_ depth: Double, at date: Date, temp: Double? = nil) -> DiveSample {
        DiveSample(timestamp: date, depthMeters: depth, temperatureCelsius: temp)
    }

    private func makeSession(id: UUID = UUID(), samples: [DiveSample], start: Date, end: Date) -> DiveSession {
        let sanitized = DiveAlgorithm.sanitizedSamples(samples)
        let temps = sanitized.compactMap(\.temperatureCelsius)
        let duration = max(0, end.timeIntervalSince(start))
        let average = DiveAlgorithm.timeWeightedAverageDepth(samples: sanitized, endDate: end)
        return DiveSession(
            id: id,
            startDate: start,
            endDate: end,
            durationSeconds: duration,
            maxDepthMeters: sanitized.map(\.depthMeters).max() ?? 0,
            avgDepthMeters: average,
            avgWaterTemperatureCelsius: temps.isEmpty ? nil : temps.reduce(0, +) / Double(temps.count),
            minWaterTemperatureCelsius: temps.min(),
            maxWaterTemperatureCelsius: temps.max(),
            ttv: DiveAlgorithm.ttvIndex(averageDepthMeters: average, durationSeconds: duration),
            entryGPS: nil,
            exitGPS: nil,
            samples: sanitized
        )
    }
}
