import CryptoKit
import XCTest

final class IOSMockupRasterSnapshotTests: XCTestCase {
    func testIOSRasterSnapshotRegistryCoversAllTwentyMockups() {
        XCTAssertEqual(MockupVisualRegressionRegistry.iosRasterEntries.count, 20)
    }

    func testMockupPNGDimensionsMatchIOSContracts() throws {
        let root = repositoryRoot()
        for entry in MockupVisualRegressionRegistry.iosRasterEntries {
            let expected = IOSMockupSnapshotContracts.expectedDimensions(
                mockupID: entry.mockupID,
                path: entry.path
            )
            let path = root.appendingPathComponent(entry.path)
            let (width, height) = try pngDimensions(at: path)
            XCTAssertEqual(width, expected.width, entry.mockupID)
            XCTAssertEqual(height, expected.height, entry.mockupID)
        }
    }

    func testImplementationViewsExistForIOSContracts() {
        let root = repositoryRoot()
        for entry in MockupVisualRegressionRegistry.iosRasterEntries {
            let relative = IOSMockupSnapshotContracts.resolvedImplementationPath(
                mockupID: entry.mockupID,
                implementationView: entry.implementationView
            )
            XCTAssertTrue(
                FileManager.default.fileExists(atPath: root.appendingPathComponent(relative).path),
                "\(entry.mockupID) -> \(relative)"
            )
        }
    }

    func testDashboardPresentationFingerprintsAreDeterministic() throws {
        let session = ApneaSession(
            id: IOSMockupPreviewFixtures.fixedSessionID,
            startMode: .manual,
            state: .completed,
            createdAt: IOSMockupPreviewFixtures.fixedDate,
            dives: [
                ApneaDive(startedAtMonotonicSeconds: 0, durationSeconds: 90, maxDepthMeters: 12, averageDepthMeters: 10),
            ]
        )
        let first = IOSApneaDashboardPresentationMapper.make(
            lastSession: session,
            aggregate: .empty,
            watchConnectivityText: "Connected",
            watchConnectivityIsPositive: true,
            locale: IOSMockupPreviewFixtures.fixedLocaleEN
        )
        let second = IOSApneaDashboardPresentationMapper.make(
            lastSession: session,
            aggregate: .empty,
            watchConnectivityText: "Connected",
            watchConnectivityIsPositive: true,
            locale: IOSMockupPreviewFixtures.fixedLocaleEN
        )
        XCTAssertEqual(first, second)
        let fingerprint = IOSMockupSnapshotContracts.deterministicFingerprint(String(describing: first))
        XCTAssertEqual(fingerprint.count, 64)
    }

    func testDecoPlanTransferFixtureFingerprintIsStable() throws {
        let package = try IOSDivePlanTransferMockupFixtures.validDecoPlanPackage()
        let labels = IOSDivePlanTransferMockupFixtures.presentationLabels(for: package)
        let payload = "\(labels.bottomGas)|\(labels.decoGases)|\(labels.gf)|\(labels.planKind)"
        let first = IOSMockupSnapshotContracts.deterministicFingerprint(payload)
        let second = IOSMockupSnapshotContracts.deterministicFingerprint(payload)
        XCTAssertEqual(first, second)
        XCTAssertNoThrow(try DivePlanPackageCodec.validate(package))
    }

    func testAccessibilityAndLocalizationContractsForPrimaryDashboards() throws {
        let en = try loadIOSStrings("en")
        for entry in MockupVisualRegressionRegistry.iosRasterEntries {
            for key in IOSMockupSnapshotContracts.localizationKeys(for: entry.mockupID) {
                XCTAssertFalse(en[key, default: ""].isEmpty, "\(entry.mockupID) missing \(key)")
            }
        }
        let apneaSource = try String(
            contentsOf: repositoryRoot().appendingPathComponent("iOSApp/Views/Apnea/IOSApneaDashboardView.swift"),
            encoding: .utf8
        )
        XCTAssertTrue(apneaSource.contains("accessibilityIdentifier(\"apnea.ios.dashboard\")"))
    }

    private func pngDimensions(at url: URL) throws -> (Int, Int) {
        let handle = try FileHandle(forReadingFrom: url)
        defer { try? handle.close() }
        let header = try handle.read(upToCount: 24) ?? Data()
        guard header.count >= 24,
              header[0] == 0x89, header[1] == 0x50, header[2] == 0x4E, header[3] == 0x47 else {
            throw NSError(domain: "IOSMockupRasterSnapshotTests", code: 1)
        }
        let width = Int(header[16]) << 24 | Int(header[17]) << 16 | Int(header[18]) << 8 | Int(header[19])
        let height = Int(header[20]) << 24 | Int(header[21]) << 16 | Int(header[22]) << 8 | Int(header[23])
        return (width, height)
    }

    private func repositoryRoot() -> URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }

    private func loadIOSStrings(_ locale: String) throws -> [String: String] {
        let url = repositoryRoot().appendingPathComponent("iOSApp/Resources/\(locale).lproj/Localizable.strings")
        let raw = try String(contentsOf: url)
        var result: [String: String] = [:]
        let pattern = #"\"([^\"]+)\"\s*=\s*\"([^\"]*)\";"#
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return result }
        let range = NSRange(raw.startIndex..<raw.endIndex, in: raw)
        regex.enumerateMatches(in: raw, range: range) { match, _, _ in
            guard let match,
                  let keyRange = Range(match.range(at: 1), in: raw),
                  let valueRange = Range(match.range(at: 2), in: raw) else { return }
            result[String(raw[keyRange])] = String(raw[valueRange])
        }
        return result
    }
}
