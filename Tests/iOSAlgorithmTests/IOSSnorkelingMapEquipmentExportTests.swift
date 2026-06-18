import XCTest

final class IOSSnorkelingMapEquipmentExportTests: XCTestCase {
    func testExportFilenameSanitizesSpecialCharacters() {
        var session = makeSession()
        session.createdAt = Date(timeIntervalSince1970: 1_700_000_000)
        let filename = SnorkelingExportFileNaming.filename(for: session, format: .pdf)
        XCTAssertTrue(filename.hasSuffix(".pdf"))
        XCTAssertFalse(filename.contains("/"))
        XCTAssertFalse(filename.contains(":"))
    }

    func testPrivacyBlocksGPSWithoutAcknowledgement() {
        var session = makeSession()
        session.trackPoints = [
            surfacePoint(seconds: 0, lat: 44.1, lon: 8.9),
            surfacePoint(seconds: 60, lat: 44.11, lon: 8.91),
        ]
        let options = SnorkelingExportPrivacyOptions(
            locationPrecision: .exact,
            includeBuddyContactDetails: false,
            includeEmergencyContact: false,
            includeGroupContacts: false,
            locationSharingAcknowledged: false
        )
        XCTAssertFalse(SnorkelingExportPrivacyPolicy.canExportLocation(options: options, session: session))
        XCTAssertNil(SnorkelingSessionExportEngine.buildGPX(for: session, options: options))
    }

    func testReducedPrecisionRoundsCoordinates() {
        XCTAssertEqual(SnorkelingExportPrivacyPolicy.reducedCoordinate(44.123456), 44.123, accuracy: 0.0001)
    }

    func testGPXExportWithoutFixReturnsNil() {
        let session = makeSession()
        let options = SnorkelingExportPrivacyOptions(
            locationPrecision: .exact,
            includeBuddyContactDetails: false,
            includeEmergencyContact: false,
            includeGroupContacts: false,
            locationSharingAcknowledged: true
        )
        XCTAssertNil(SnorkelingSessionExportEngine.buildGPX(for: session, options: options))
    }

    func testCSVAndJSONLargeDataset() throws {
        var dips: [SnorkelingDip] = []
        for dipIndex in 0..<20 {
            let samples = (0..<30).map {
                SnorkelingDipSample(monotonicRelativeTimestampSeconds: TimeInterval($0), depthMeters: Double($0 % 12))
            }
            dips.append(
                SnorkelingDip(
                    startedAtMonotonicSeconds: TimeInterval(dipIndex * 120),
                    endedAtMonotonicSeconds: TimeInterval(dipIndex * 120 + 30),
                    durationSeconds: 30,
                    maxDepthMeters: 12,
                    averageDepthMeters: 6,
                    samples: samples,
                    events: []
                )
            )
        }
        let session = SnorkelingSession(startMode: .watch, state: .completed, dips: dips)
        let csv = SnorkelingSessionExportEngine.buildCSV(for: session)
        XCTAssertNotNil(csv)
        XCTAssertGreaterThan(csv?.data.count ?? 0, 1_000)
        let json = try SnorkelingSessionExportEngine.buildJSON(for: session)
        XCTAssertGreaterThan(json.data.count, 1_000)
    }

    func testRedactedSessionRemovesGPSAndContacts() {
        var session = makeSession()
        session.trackPoints = [
            surfacePoint(seconds: 0, lat: 44.1, lon: 8.9),
            surfacePoint(seconds: 30, lat: 44.2, lon: 8.95),
        ]
        session.buddy = SnorkelingBuddyInfo(name: "Alex", contactNotes: "+39 123", isBuddyPresent: true)
        let redacted = SnorkelingExportPrivacyPolicy.redactedSession(session, options: .redacted)
        XCTAssertTrue(SnorkelingExportPrivacyPolicy.measuredSurfacePoints(from: redacted).isEmpty)
        XCTAssertNil(redacted.buddy?.contactNotes)
    }

    func testMapPermissionDeniedState() {
        let session = makeSession()
        let model = SnorkelingSessionMapPresentation.make(from: session, permission: .denied)
        XCTAssertFalse(model.isAvailable)
        XCTAssertEqual(model.unavailableReasonKey, "snorkeling.ios.map.permission_denied")
    }

    func testPDFLinesLayoutContainsSessionMetrics() {
        let lines = SnorkelingSessionExportEngine.buildPDFLines(for: makeSession())
        XCTAssertTrue(lines.contains { $0.contains("Dips:") })
        XCTAssertTrue(lines.contains { $0.contains("Max depth:") })
    }

    @MainActor
    func testEquipmentStoreCRUDAndActiveProfile() {
        let defaults = UserDefaults(suiteName: #function)!
        defaults.removePersistentDomain(forName: #function)
        IOSSnorkelingEquipmentStore.testHook_defaults = defaults
        defer { IOSSnorkelingEquipmentStore.testHook_defaults = nil }

        let store = IOSSnorkelingEquipmentStore()
        XCTAssertFalse(store.profiles.isEmpty)
        let custom = SnorkelingReusableEquipmentProfile(displayName: "Reef kit", items: [SnorkelingEquipmentItem(category: .fins, label: "Travel fins")])
        store.add(custom)
        store.setActive(id: custom.id)
        XCTAssertEqual(store.activeProfile?.id, custom.id)
    }

    @MainActor
    func testBuddyConfirmationTimestamp() {
        let defaults = UserDefaults(suiteName: #function)!
        defaults.removePersistentDomain(forName: #function)
        IOSSnorkelingBuddySafetyStore.testHook_defaults = defaults
        defer { IOSSnorkelingBuddySafetyStore.testHook_defaults = nil }

        let store = IOSSnorkelingBuddySafetyStore()
        let date = Date(timeIntervalSince1970: 1_900_000_000)
        store.confirmPreSession(at: date)
        XCTAssertTrue(store.profile.preSessionConfirmation.isConfirmed)
        XCTAssertEqual(store.profile.preSessionConfirmation.confirmedAt, date)
    }

    @MainActor
    func testPhotoStoreHandlesMissingThumbnailGracefully() {
        let store = IOSSnorkelingSessionPhotoStore()
        let attachment = SnorkelingSessionPhotoAttachment(
            sessionID: UUID(),
            localFilename: "missing.jpg",
            stripLocationMetadata: true
        )
        XCTAssertNil(store.thumbnailImage(for: attachment))
    }

    private func surfacePoint(seconds: TimeInterval, lat: Double, lon: Double) -> SnorkelingTrackPoint {
        SnorkelingTrackPoint(
            monotonicRelativeTimestampSeconds: seconds,
            latitude: lat,
            longitude: lon,
            horizontalAccuracyMeters: 10,
            gpsQuality: .measured,
            isUnderwater: false
        )
    }

    private func makeSession() -> SnorkelingSession {
        let dip = SnorkelingDip(
            startedAtMonotonicSeconds: 0,
            endedAtMonotonicSeconds: 60,
            durationSeconds: 60,
            maxDepthMeters: 10,
            averageDepthMeters: 6,
            samples: [
                SnorkelingDipSample(monotonicRelativeTimestampSeconds: 0, depthMeters: 0),
                SnorkelingDipSample(monotonicRelativeTimestampSeconds: 30, depthMeters: 10),
                SnorkelingDipSample(monotonicRelativeTimestampSeconds: 60, depthMeters: 0),
            ],
            events: []
        )
        var session = SnorkelingSession(startMode: .watch, state: .completed, dips: [dip])
        session.statistics = session.refreshedStatistics()
        return session
    }
}
