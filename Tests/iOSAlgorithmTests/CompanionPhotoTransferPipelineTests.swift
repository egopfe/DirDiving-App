import UIKit
import XCTest

final class CompanionPhotoTransferPipelineTests: XCTestCase {
    func testValidJPEGAcceptedAndOutputsJPEGCompatibleData() throws {
        let image = makeSolidImage(size: CGSize(width: 120, height: 80), color: .blue)
        let input = try XCTUnwrap(image.jpegData(compressionQuality: 0.9))
        let prepared = try WatchPhotoPreprocessor.prepareForWatch(from: input)
        XCTAssertEqual(prepared.data.prefix(2), Data([0xFF, 0xD8]))
        XCTAssertFalse(prepared.data.isEmpty)
    }

    func testOversizedImageResizedWithinExpectedMaxDimension() throws {
        let image = makeSolidImage(size: CGSize(width: 900, height: 700), color: .green)
        let input = try XCTUnwrap(image.jpegData(compressionQuality: 0.95))
        let prepared = try WatchPhotoPreprocessor.prepareForWatch(from: input)
        XCTAssertTrue(prepared.didConvert)
        let decoded = try XCTUnwrap(UIImage(data: prepared.data))
        let cgImage = try XCTUnwrap(decoded.cgImage)
        let maxSide = max(cgImage.width, cgImage.height)
        XCTAssertLessThanOrEqual(
            maxSide,
            Int(WatchPhotoPreprocessor.optimalMaxDimension.rounded(.up)) + 4
        )
    }

    func testPNGInputConvertedToJPEGCompatibleOutput() throws {
        let image = makeSolidImage(size: CGSize(width: 160, height: 120), color: .red)
        let input = try XCTUnwrap(image.pngData())
        XCTAssertFalse(input.starts(with: [0xFF, 0xD8]))
        let prepared = try WatchPhotoPreprocessor.prepareForWatch(from: input)
        XCTAssertTrue(prepared.didConvert)
        XCTAssertEqual(prepared.data.prefix(2), Data([0xFF, 0xD8]))
    }

    func testFileNameUsesUUIDAndDoesNotCollideDuringRapidSends() {
        let names = (0..<50).map { _ in
            CompanionPhotoTransferSupport.makeFileName(photoID: UUID())
        }
        XCTAssertEqual(Set(names).count, names.count)
        XCTAssertTrue(names.allSatisfy { $0.hasPrefix("companion_") && $0.hasSuffix(".jpg") })
    }

    func testSharedMetadataKeysMatchBetweenIOSAndWatchTargets() {
        XCTAssertEqual(WatchSyncKeys.companionPhotoFileNameKey, "photoFileName")
        XCTAssertEqual(WatchSyncKeys.companionPhotoIDKey, "photoID")
        XCTAssertEqual(WatchSyncKeys.companionPhotoAckType, "companionPhotoAck")
        XCTAssertEqual(WatchSyncKeys.companionPhotoAckStatusKey, "status")
        XCTAssertEqual(WatchSyncKeys.companionPhotoAckStoredFileNameKey, "storedFileName")
        XCTAssertEqual(WatchSyncKeys.companionPhotoAckErrorCodeKey, "errorCode")
        XCTAssertEqual(
            CompanionPhotoTransferSupport.expectedWatchSyncPhotoKeys["companionPhotoIDKey"],
            WatchSyncKeys.companionPhotoIDKey
        )
    }

    func testAckImportedMapsToImportedOnWatchState() throws {
        let photoID = UUID().uuidString
        var transfer: CompanionPhotoTransferStatus? = CompanionPhotoTransferStatus(
            photoID: photoID,
            fileName: "companion_\(photoID).jpg",
            state: .deliveredToConnectivity
        )
        let payload = CompanionPhotoTransferSupport.makeTransferMetadata(photoID: photoID, fileName: "companion_\(photoID).jpg")
            .merging([
                "type": WatchSyncKeys.companionPhotoAckType,
                WatchSyncKeys.companionPhotoAckStatusKey: CompanionPhotoTransferSupport.ackStatusImported,
                WatchSyncKeys.companionPhotoAckStoredFileNameKey: "companion_\(photoID).jpg",
            ]) { _, new in new }
        let ack = try XCTUnwrap(CompanionPhotoTransferSupport.parseCompanionPhotoAck(payload))
        CompanionPhotoTransferSupport.applyAck(ack, to: &transfer)
        XCTAssertEqual(transfer?.state, .importedOnWatch)
        XCTAssertEqual(transfer?.storedFileNameOnWatch, "companion_\(photoID).jpg")
    }

    func testAckRejectedMapsToRejectedByWatchState() throws {
        let photoID = UUID().uuidString
        var transfer: CompanionPhotoTransferStatus? = CompanionPhotoTransferStatus(
            photoID: photoID,
            fileName: "companion_\(photoID).jpg",
            state: .deliveredToConnectivity
        )
        let payload: [String: Any] = [
            "type": WatchSyncKeys.companionPhotoAckType,
            WatchSyncKeys.companionPhotoIDKey: photoID,
            WatchSyncKeys.companionPhotoAckStatusKey: CompanionPhotoTransferSupport.ackStatusRejected,
            WatchSyncKeys.companionPhotoAckErrorCodeKey: "invalidImage",
        ]
        let ack = try XCTUnwrap(CompanionPhotoTransferSupport.parseCompanionPhotoAck(payload))
        CompanionPhotoTransferSupport.applyAck(ack, to: &transfer)
        XCTAssertEqual(transfer?.state, .rejectedByWatch)
        XCTAssertEqual(transfer?.rejectionErrorCode, "invalidImage")
    }

    private func makeSolidImage(size: CGSize, color: UIColor) -> UIImage {
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        return renderer.image { context in
            color.setFill()
            context.fill(CGRect(origin: .zero, size: size))
        }
    }
}
