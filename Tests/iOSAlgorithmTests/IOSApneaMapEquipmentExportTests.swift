import XCTest

final class IOSApneaMapEquipmentExportTests: XCTestCase {
    func testExportFilenameSanitizesSpecialCharacters() {
        var session = makeSession()
        session.createdAt = Date(timeIntervalSince1970: 1_700_000_000)
        let filename = ApneaExportFileNaming.filename(for: session, format: .pdf)
        XCTAssertTrue(filename.hasSuffix(".pdf"))
        XCTAssertFalse(filename.contains("/"))
        XCTAssertFalse(filename.contains(":"))
    }

    func testPrivacyBlocksGPSWithoutAcknowledgement() {
        var session = makeSession()
        session.surfaceGPSPoints = [
            ApneaSurfaceGPSPoint(latitude: 44.1, longitude: 8.9, horizontalAccuracyMeters: 8),
            ApneaSurfaceGPSPoint(latitude: 44.11, longitude: 8.91, horizontalAccuracyMeters: 10),
        ]
        let options = ApneaExportPrivacyOptions(
            includeSurfaceGPS: true,
            includeBuddyContactDetails: false,
            includeEmergencyContact: false,
            locationSharingAcknowledged: false
        )
        XCTAssertFalse(ApneaExportPrivacyPolicy.canExportLocation(options: options, session: session))
        XCTAssertNil(ApneaSessionExportEngine.buildGPX(for: session, options: options))
    }

    func testGPXExportWithoutFixReturnsNil() {
        let session = makeSession()
        let options = ApneaExportPrivacyOptions(
            includeSurfaceGPS: true,
            includeBuddyContactDetails: false,
            includeEmergencyContact: false,
            locationSharingAcknowledged: true
        )
        XCTAssertNil(ApneaSessionExportEngine.buildGPX(for: session, options: options))
    }

    func testCSVAndJSONLargeDataset() throws {
        var dives: [ApneaDive] = []
        for diveIndex in 0..<25 {
            let samples = (0..<40).map {
                ApneaSample(monotonicRelativeTimestampSeconds: TimeInterval($0), depthMeters: Double($0 % 20))
            }
            dives.append(
                ApneaDive(
                    startedAtMonotonicSeconds: TimeInterval(diveIndex * 200),
                    durationSeconds: 40,
                    maxDepthMeters: 19,
                    averageDepthMeters: 10,
                    samples: samples
                )
            )
        }
        let session = ApneaSession(startMode: .watch, state: .completed, dives: dives)
        let csv = ApneaSessionExportEngine.buildCSV(for: session)
        XCTAssertNotNil(csv)
        XCTAssertGreaterThan(csv?.data.count ?? 0, 1_000)
        let json = try ApneaSessionExportEngine.buildJSON(for: session)
        XCTAssertGreaterThan(json.data.count, 1_000)
    }

    func testRedactedSessionRemovesGPSAndContacts() {
        var session = makeSession()
        session.surfaceGPSPoints = [
            ApneaSurfaceGPSPoint(latitude: 44.1, longitude: 8.9),
            ApneaSurfaceGPSPoint(latitude: 44.2, longitude: 8.95),
        ]
        session.buddy = ApneaBuddyInfo(name: "Alex", contactNotes: "+39 123", isSafetyDiverPresent: true)
        let redacted = ApneaExportPrivacyPolicy.redactedSession(session, options: .redacted)
        XCTAssertTrue(redacted.surfaceGPSPoints.isEmpty)
        XCTAssertNil(redacted.buddy?.contactNotes)
    }

    func testMapPermissionDeniedState() {
        let session = makeSession()
        let model = ApneaSessionMapPresentation.make(from: session, permission: .denied)
        XCTAssertFalse(model.isAvailable)
        XCTAssertEqual(model.unavailableReasonKey, "apnea.ios.map.permission_denied")
    }

    func testMapFixQualityClassification() {
        var model = ApneaSessionMapModel(
            coordinates: [],
            sessionStartText: nil,
            sessionEndText: nil,
            accuracyMeters: 8,
            isAvailable: true,
            unavailableReasonKey: nil
        )
        XCTAssertEqual(model.fixQuality, .good)
        model.accuracyMeters = 25
        XCTAssertEqual(model.fixQuality, .fair)
        model.accuracyMeters = 80
        XCTAssertEqual(model.fixQuality, .poor)
    }

    @MainActor
    func testEquipmentStoreCRUDAndActiveProfile() {
        let defaults = UserDefaults(suiteName: #function)!
        defaults.removePersistentDomain(forName: #function)
        IOSApneaEquipmentStore.testHook_defaults = defaults
        defer { IOSApneaEquipmentStore.testHook_defaults = nil }

        let store = IOSApneaEquipmentStore()
        XCTAssertFalse(store.profiles.isEmpty)
        let custom = ApneaReusableEquipmentProfile(displayName: "Pool setup", items: [ApneaEquipmentItem(category: .fins, label: "Short fins")])
        store.add(custom)
        store.setActive(id: custom.id)
        XCTAssertEqual(store.activeProfile?.id, custom.id)
    }

    @MainActor
    func testBuddyConfirmationTimestamp() {
        let defaults = UserDefaults(suiteName: #function)!
        defaults.removePersistentDomain(forName: #function)
        IOSApneaBuddySafetyStore.testHook_defaults = defaults
        defer { IOSApneaBuddySafetyStore.testHook_defaults = nil }

        let store = IOSApneaBuddySafetyStore()
        let date = Date(timeIntervalSince1970: 1_900_000_000)
        store.confirmPreSession(at: date)
        XCTAssertTrue(store.profile.preSessionConfirmation.isConfirmed)
        XCTAssertEqual(store.profile.preSessionConfirmation.confirmedAt, date)
    }

    func testPDFLinesLayoutContainsSessionMetrics() {
        let lines = ApneaSessionExportEngine.buildPDFLines(for: makeSession())
        XCTAssertTrue(lines.contains { $0.contains("Dives:") })
        XCTAssertTrue(lines.contains { $0.contains("Max depth:") })
    }

    private func makeSession() -> ApneaSession {
        let dive = ApneaDive(
            startedAtMonotonicSeconds: 0,
            durationSeconds: 84,
            maxDepthMeters: 24.4,
            averageDepthMeters: 14,
            samples: [
                ApneaSample(monotonicRelativeTimestampSeconds: 0, depthMeters: 0),
                ApneaSample(monotonicRelativeTimestampSeconds: 42, depthMeters: 24.4),
                ApneaSample(monotonicRelativeTimestampSeconds: 84, depthMeters: 0),
            ]
        )
        var session = ApneaSession(startMode: .watch, state: .completed, dives: [dive])
        session.statistics = session.refreshedStatistics()
        return session
    }
}
