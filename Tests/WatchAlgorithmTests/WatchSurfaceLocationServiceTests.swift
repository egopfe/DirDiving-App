import XCTest

final class WatchSurfaceLocationServiceTests: XCTestCase {
    func testQualityClassifierMarksStaleFix() {
        let quality = WatchSurfaceGPSQualityEvaluator.classify(
            horizontalAccuracyMeters: 8,
            fixAgeSeconds: DiveAlgorithmConfiguration.maximumGPSFallbackAgeSeconds + 10,
            authorizationDenied: false
        )
        XCTAssertEqual(quality, .stale)
    }

    func testQualityClassifierMarksDenied() {
        XCTAssertEqual(
            WatchSurfaceGPSQualityEvaluator.classify(
                horizontalAccuracyMeters: 5,
                fixAgeSeconds: 0,
                authorizationDenied: true
            ),
            .denied
        )
    }

    func testBridgeProducesMeasuredFixFromValidPoint() {
        let now = Date()
        let point = GPSPoint(latitude: 44.40, longitude: 8.93, horizontalAccuracy: 6, timestamp: now)
        let fix = WatchSurfaceLocationBridge.fix(from: point, permission: .authorized, now: now)
        XCTAssertEqual(fix?.source, .measured)
        XCTAssertEqual(fix?.latitude ?? 0, 44.40, accuracy: 0.0001)
    }

    func testBridgeRejectsInvalidCoordinates() {
        let point = GPSPoint(latitude: 999, longitude: 8, horizontalAccuracy: 5, timestamp: Date())
        XCTAssertNil(WatchSurfaceLocationBridge.fix(from: point, permission: .authorized))
    }

    @MainActor
    func testApneaSurfacePointConversion() {
        let fix = WatchSurfaceLocationFix(
            latitude: 45.1,
            longitude: 9.1,
            horizontalAccuracyMeters: 5,
            capturedAt: Date(),
            source: .measured
        )
        let point = WatchSurfaceLocationBridge.apneaSurfacePoint(from: fix)
        XCTAssertEqual(point.latitude, 45.1, accuracy: 0.0001)
    }
}
