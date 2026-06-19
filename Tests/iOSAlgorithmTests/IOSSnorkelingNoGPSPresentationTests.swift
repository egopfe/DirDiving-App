import XCTest

final class IOSSnorkelingNoGPSPresentationTests: XCTestCase {
    func testNoGPSSessionShowsTruthfulEmptyMapState() {
        let session = SnorkelingSession(startMode: .watch, state: .completed, warnings: [.incompleteGPS])
        let model = SnorkelingSessionMapPresentation.make(from: session)
        XCTAssertFalse(model.isAvailable)
        XCTAssertEqual(model.unavailableReasonKey, "snorkeling.ios.map.gps_unavailable")
    }

    func testNoGPSSessionDoesNotCreateZeroCoordinate() {
        let session = SnorkelingSession(startMode: .watch, state: .completed)
        let presentation = IOSSnorkelingDashboardPresentationMapper.make(
            lastSession: session,
            sessions: [session],
            statistics: SnorkelingLogbookStatistics.aggregate(from: [session]),
            watchConnectivityText: "ok",
            watchConnectivityIsPositive: true,
            syncStatusText: "ok",
            syncStatusIsPositive: true
        )
        XCTAssertFalse(presentation.mapPreviewAvailable)
        XCTAssertEqual(presentation.mapPreviewModel?.isAvailable, false)
    }

    func testNoGPSSessionCannotExportGPX() {
        let session = SnorkelingSession(startMode: .watch, state: .completed)
        let options = SnorkelingExportPrivacyOptions(
            locationPrecision: .exact,
            includeBuddyContactDetails: false,
            includeEmergencyContact: false,
            includeGroupContacts: false,
            locationSharingAcknowledged: true
        )
        XCTAssertNil(SnorkelingSessionExportEngine.buildGPX(for: session, options: options))
    }

    func testNoGPSSessionCanExportNonGeographicFormats() throws {
        var dip = SnorkelingDip(startedAtMonotonicSeconds: 0, durationSeconds: 30, maxDepthMeters: 4, averageDepthMeters: 3)
        dip.samples = [
            SnorkelingDipSample(monotonicRelativeTimestampSeconds: 0, depthMeters: 2, temperatureCelsius: 22, verticalSpeedMetersPerSecond: 0, depthQuality: .measured)
        ]
        let session = SnorkelingSession(
            startMode: .watch,
            state: .completed,
            dips: [dip]
        )
        XCTAssertNotNil(SnorkelingSessionExportEngine.buildCSV(for: session))
        _ = try SnorkelingSessionExportEngine.buildJSON(for: session)
    }

    func testUnderwaterUnavailablePointsDoNotCreateMapPolyline() {
        let point = SnorkelingTrackPoint(
            monotonicRelativeTimestampSeconds: 0,
            latitude: 44.1,
            longitude: 8.9,
            gpsQuality: .unavailable,
            isUnderwater: true
        )
        let model = SnorkelingSessionMapPresentation.make(from: SnorkelingSession(
            startMode: .watch,
            state: .completed,
            trackPoints: [point, point]
        ))
        XCTAssertFalse(model.isAvailable)
    }
}
