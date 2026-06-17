import XCTest

@MainActor
final class PlannerWatchBriefingTransferTests: XCTestCase {
    func testHandleAckMarksSentOnImportedStatus() {
        let service = PlannerBriefingWatchTransferService()
        let packageId = UUID()
        service.handleAck(packageId: packageId, status: PlannerBriefingTransferSupport.ackStatusImported)
        XCTAssertEqual(service.state, .idle)

        service.testing_simulateQueued(packageId: packageId)
        service.handleAck(packageId: packageId, status: PlannerBriefingTransferSupport.ackStatusImported)
        if case .sent(let sentId) = service.state {
            XCTAssertEqual(sentId, packageId)
        } else {
            XCTFail("Expected sent state after ack")
        }
    }

    func testHandleAckMarksFailedOnRejectedStatus() {
        let service = PlannerBriefingWatchTransferService()
        let packageId = UUID()
        service.testing_simulateQueued(packageId: packageId)
        service.handleAck(packageId: packageId, status: PlannerBriefingTransferSupport.ackStatusRejected)
        if case .failed = service.state {
            XCTAssertTrue(true)
        } else {
            XCTFail("Expected failed state after rejected ack")
        }
    }
}
