import XCTest

@MainActor
final class WatchCMAltimeterLifecycleTests: XCTestCase {
    override func setUp() {
        super.setUp()
        FullComputerPrediveConfigurationStore.shared.resetForTests()
        FullComputerPrediveConfigurationStore.shared.clearEnvironmentForTestsOnly()
        FullComputerEnvironmentSensorService.shared.resetForTests()
        WatchFullComputerAltitudeSensorProposalSettingsStore.shared.resetForTests()
        FullComputerAltitudeSamplingPolicy.testHook_timeoutSeconds = nil
    }

    override func tearDown() {
        FullComputerAltitudeSamplingPolicy.testHook_timeoutSeconds = nil
        FullComputerEnvironmentSensorService.shared.resetForTests()
        WatchFullComputerAltitudeSensorProposalSettingsStore.shared.resetForTests()
        FullComputerPrediveConfigurationStore.shared.resetForTests()
        super.tearDown()
    }

    func testLateErrorAfterProposalReadyDoesNotChangeStateOrPendingProposal() {
        let config = FullComputerPrediveConfigurationStore.shared
        config.setDraftEnvironment(altitudeMeters: 900, salinity: .salt, source: .watchSettingsManual)
        let provider = FakeAbsoluteAltitudeProvider()
        let service = FullComputerEnvironmentSensorService(provider: provider)
        let now = Date()

        service.requestProposal(into: config)
        emitStableWindow(on: provider, base: 1_250, now: now)
        XCTAssertEqual(service.state, .proposalReady)
        XCTAssertNotNil(config.pendingSensorProposal)

        provider.emitFailure(.sensorFailure)
        XCTAssertEqual(service.state, .proposalReady)
        XCTAssertNotNil(config.pendingSensorProposal)
        XCTAssertEqual(try XCTUnwrap(config.draftEnvironment?.altitudeMeters), 900, accuracy: 0.01)
    }

    func testLateNilDataAfterProposalReadyIsIgnored() {
        let config = FullComputerPrediveConfigurationStore.shared
        let provider = FakeAbsoluteAltitudeProvider()
        let service = FullComputerEnvironmentSensorService(provider: provider)
        let now = Date()

        service.requestProposal(into: config)
        emitStableWindow(on: provider, base: 1_100, now: now)
        provider.emitNilDataNilError()
        XCTAssertEqual(service.state, .proposalReady)
    }

    func testSupersededRequestIgnoresDelayedSampleFromFirstRequest() {
        let config = FullComputerPrediveConfigurationStore.shared
        let provider = FakeAbsoluteAltitudeProvider()
        let service = FullComputerEnvironmentSensorService(provider: provider)
        let now = Date()

        service.requestProposal(into: config)
        provider.emit(altitudeMeters: 500, accuracyMeters: 5, precisionMeters: 1, sensorMeasuredAt: now)
        service.requestProposal(into: config)
        XCTAssertEqual(provider.startCount, 2)
        emitStableWindow(on: provider, base: 1_600, now: now.addingTimeInterval(2), count: 5)
        XCTAssertEqual(service.state, .proposalReady)
        XCTAssertEqual(try XCTUnwrap(config.pendingSensorProposal?.altitudeMeters), 1_600, accuracy: 1)
    }

    func testCancelIgnoresDelayedSample() {
        let config = FullComputerPrediveConfigurationStore.shared
        let provider = FakeAbsoluteAltitudeProvider()
        let service = FullComputerEnvironmentSensorService(provider: provider)
        let now = Date()

        service.requestProposal(into: config)
        service.cancel()
        provider.emit(altitudeMeters: 1_000, accuracyMeters: 5, precisionMeters: 1, sensorMeasuredAt: now)
        XCTAssertNil(config.pendingSensorProposal)
        XCTAssertNotEqual(service.state, .proposalReady)
    }

    func testTimeoutWithoutSamples() async {
        FullComputerAltitudeSamplingPolicy.testHook_timeoutSeconds = 0.05
        let config = FullComputerPrediveConfigurationStore.shared
        config.setDraftEnvironment(altitudeMeters: 200, salinity: .salt, source: .watchSettingsManual)
        let provider = FakeAbsoluteAltitudeProvider()
        let service = FullComputerEnvironmentSensorService(provider: provider)

        service.requestProposal(into: config)
        try? await Task.sleep(nanoseconds: 120_000_000)
        XCTAssertEqual(service.state, .timedOut)
        XCTAssertEqual(try XCTUnwrap(config.draftEnvironment?.altitudeMeters), 200, accuracy: 0.01)
        XCTAssertNil(config.pendingSensorProposal)
    }

    func testNilDataStreamFailsDeterministically() {
        let config = FullComputerPrediveConfigurationStore.shared
        config.setDraftEnvironment(altitudeMeters: 300, salinity: .fresh, source: .watchSettingsManual)
        let provider = FakeAbsoluteAltitudeProvider()
        let service = FullComputerEnvironmentSensorService(provider: provider)

        service.requestProposal(into: config)
        for _ in 0..<FullComputerAltitudeSamplingPolicy.maximumConsecutiveNilDataCallbacks {
            provider.emitNilDataNilError()
        }
        XCTAssertEqual(service.state, .failed)
        XCTAssertEqual(service.lastDiagnostic, FullComputerEnvironmentSensorError.nilDataStream.rawValue)
        XCTAssertNil(config.pendingSensorProposal)
    }

    func testDuplicateRequestIfNeededDoesNotRestartSampling() {
        let config = FullComputerPrediveConfigurationStore.shared
        let provider = FakeAbsoluteAltitudeProvider()
        let service = FullComputerEnvironmentSensorService(provider: provider)

        service.requestProposalIfNeeded(into: config)
        service.requestProposalIfNeeded(into: config)
        XCTAssertEqual(provider.startCount, 1)
        XCTAssertEqual(service.state, .sampling)
    }

    func testProposalReadyDoesNotRestartOnSecondRequestIfNeeded() {
        let config = FullComputerPrediveConfigurationStore.shared
        let provider = FakeAbsoluteAltitudeProvider()
        let service = FullComputerEnvironmentSensorService(provider: provider)
        let now = Date()

        service.requestProposal(into: config)
        emitStableWindow(on: provider, base: 800, now: now)
        let starts = provider.startCount
        service.requestProposalIfNeeded(into: config)
        XCTAssertEqual(provider.startCount, starts)
    }

    func testManualOnlyModeBlocksAutomaticSampling() {
        WatchFullComputerAltitudeSensorProposalSettingsStore.shared.setMode(.manualOnly)
        let config = FullComputerPrediveConfigurationStore.shared
        let provider = FakeAbsoluteAltitudeProvider()
        let service = FullComputerEnvironmentSensorService(provider: provider)

        service.requestProposalIfNeeded(into: config)
        service.requestProposal(into: config)
        XCTAssertEqual(provider.startCount, 0)
        XCTAssertNotEqual(service.state, .sampling)
    }

    func testStaleSensorTimestampRejected() {
        let now = Date(timeIntervalSince1970: 80_000)
        let stale = now.addingTimeInterval(-(FullComputerEnvironmentRecord.maximumSensorAgeSeconds + 10))
        let sample = FullComputerAbsoluteAltitudeSample(
            altitudeMeters: 1_000,
            accuracyMeters: 5,
            precisionMeters: 1,
            sensorMeasuredAt: stale,
            receivedAt: now
        )
        XCTAssertFalse(FullComputerAltitudeSamplingPolicy.isUsable(sample, referenceNow: now))
    }

    func testFutureSensorTimestampRejected() {
        let now = Date(timeIntervalSince1970: 81_000)
        let future = now.addingTimeInterval(FullComputerAltitudeSamplingPolicy.maximumFutureSensorTimestampSkewSeconds + 1)
        let sample = FullComputerAbsoluteAltitudeSample(
            altitudeMeters: 1_000,
            accuracyMeters: 5,
            precisionMeters: 1,
            sensorMeasuredAt: future,
            receivedAt: now
        )
        XCTAssertFalse(FullComputerAltitudeSamplingPolicy.isUsable(sample, referenceNow: now))
    }

    func testCapturedAtUsesSensorTimestamp() throws {
        let config = FullComputerPrediveConfigurationStore.shared
        let provider = FakeAbsoluteAltitudeProvider()
        let service = FullComputerEnvironmentSensorService(provider: provider)
        let sensorTime = Date()
        let receipt = sensorTime.addingTimeInterval(2)

        service.requestProposal(into: config)
        emitStableWindow(on: provider, base: 1_400, now: sensorTime, receivedAt: receipt)
        let proposal = try XCTUnwrap(config.pendingSensorProposal)
        XCTAssertLessThanOrEqual(abs(proposal.capturedAt.timeIntervalSince(sensorTime)), 1.0)
        XCTAssertEqual(try XCTUnwrap(proposal.sensorReceivedAt).timeIntervalSince1970, receipt.timeIntervalSince1970, accuracy: 0.01)
    }

    private func emitStableWindow(
        on provider: FakeAbsoluteAltitudeProvider,
        base: Double,
        now: Date,
        receivedAt: Date? = nil,
        count: Int = 5
    ) {
        for offset in 0..<count {
            provider.emit(
                altitudeMeters: base + Double(offset) * 0.5,
                accuracyMeters: 6,
                precisionMeters: 1,
                sensorMeasuredAt: now.addingTimeInterval(Double(offset) * 0.2),
                receivedAt: receivedAt ?? now.addingTimeInterval(Double(offset) * 0.2)
            )
        }
    }
}
