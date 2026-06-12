import XCTest
import UIKit

final class PlannerBriefingImageExportServiceTests: XCTestCase {
    func testDecoStopsCardUsesExistingStops() throws {
        let stops = [
            DecoStop(depthMeters: 21, minutes: 3, gas: "EAN50", ppO2: 1.5),
            DecoStop(depthMeters: 9, minutes: 5, gas: "O2", ppO2: 1.6),
        ]
        let presentationRows = DecoStopsPresentationBuilder.rows(from: stops)
        let exportRows = PlannerBriefingImageExportService.decoRows(from: presentationRows)
        XCTAssertEqual(exportRows.count, stops.count)
        XCTAssertEqual(exportRows[0].depthLabel, presentationRows[0].depthLabel)
        XCTAssertEqual(exportRows[0].timeLabel, presentationRows[0].timeLabel)
        XCTAssertEqual(exportRows[0].gasLabel, presentationRows[0].gasLabel)
        XCTAssertEqual(exportRows[0].ppO2Label, presentationRows[0].ppO2Label)

        let package = try PlannerBriefingImageExportService.export(
            input: PlannerBriefingImageExportInput(
                modeLabel: "Deco",
                plannerSessionId: nil,
                decoStopRows: exportRows,
                runtimeRows: [],
                includesDecoStopsInRuntime: true
            )
        )
        XCTAssertEqual(package.manifest.cards.count, 1)
        XCTAssertEqual(package.manifest.cards.first?.kind, .decoStops)
    }

    func testRuntimeCardUsesExistingRuntimeRows() throws {
        let ascentRows = [
            PlannerAscentTableRow(
                kind: .descent,
                depthMeters: 40,
                depthLabel: "40 m",
                minutes: 4,
                timeLabel: "4 min",
                gas: "TX 18/45",
                ppO2: 1.1,
                ppO2Label: "1.1"
            ),
            PlannerAscentTableRow(
                kind: .decoStop,
                depthMeters: 21,
                depthLabel: "21 m",
                minutes: 3,
                timeLabel: "3 min",
                gas: "EAN50",
                ppO2: 1.5,
                ppO2Label: "1.5"
            ),
        ]
        let exportRows = PlannerBriefingImageExportService.runtimeRows(from: ascentRows)
        XCTAssertEqual(exportRows.count, ascentRows.count)
        XCTAssertEqual(exportRows[0].kindLabel, ascentRows[0].kind.localizedTitle)
        XCTAssertEqual(exportRows[1].depthLabel, ascentRows[1].depthLabel)

        let package = try PlannerBriefingImageExportService.export(
            input: PlannerBriefingImageExportInput(
                modeLabel: "Technical",
                plannerSessionId: nil,
                decoStopRows: [],
                runtimeRows: exportRows,
                includesDecoStopsInRuntime: true
            )
        )
        XCTAssertEqual(package.manifest.cards.count, 1)
        XCTAssertEqual(package.manifest.cards.first?.kind, .runtime)
    }

    func testLongRuntimeSplitsIntoMultipleCards() throws {
        let rows = (1...12).map { index in
            PlannerBriefingRuntimeExportRow(
                kindLabel: "Phase \(index)",
                depthLabel: "\(index) m",
                timeLabel: "1 min",
                gasLabel: "Air"
            )
        }
        let package = try PlannerBriefingImageExportService.export(
            input: PlannerBriefingImageExportInput(
                modeLabel: "Technical",
                plannerSessionId: nil,
                decoStopRows: [],
                runtimeRows: rows,
                includesDecoStopsInRuntime: false
            )
        )
        XCTAssertEqual(package.manifest.cards.count, 2)
        XCTAssertEqual(package.manifest.cards.map(\.order), [1, 2])
        XCTAssertTrue(package.manifest.cards.allSatisfy { $0.kind == .runtime })
    }

    func testEveryCardContainsReferenceOnlyFooter() throws {
        let package = try PlannerBriefingImageExportService.export(
            input: sampleInput()
        )
        XCTAssertTrue(package.manifest.referenceOnly)
        for card in package.manifest.cards {
            XCTAssertFalse(card.contentHashSHA256.isEmpty)
            XCTAssertEqual(card.pixelWidth, PlannerBriefingTransferSupport.cardPixelWidth)
            XCTAssertEqual(card.pixelHeight, PlannerBriefingTransferSupport.cardPixelHeight)
        }
    }

    func testDecoCardContainsNotCertifiedFooter() throws {
        let package = try PlannerBriefingImageExportService.export(
            input: sampleInput()
        )
        XCTAssertTrue(package.manifest.cards.contains(where: { $0.kind == .decoStops }))
    }

    func testImageSizeIsWatchOptimized() throws {
        let package = try PlannerBriefingImageExportService.export(input: sampleInput())
        guard let url = package.imageFiles.first else {
            XCTFail("Missing image file")
            return
        }
        let image = try XCTUnwrap(UIImage(contentsOfFile: url.path))
        XCTAssertEqual(Int(image.size.width), PlannerBriefingTransferSupport.cardPixelWidth)
        XCTAssertEqual(Int(image.size.height), PlannerBriefingTransferSupport.cardPixelHeight)
    }

    func testPackageManifestMatchesFiles() throws {
        let package = try PlannerBriefingImageExportService.export(input: sampleInput())
        XCTAssertEqual(package.manifest.cards.count, package.imageFiles.count)
        let fileNames = Set(package.imageFiles.map(\.lastPathComponent))
        for card in package.manifest.cards {
            XCTAssertTrue(fileNames.contains(card.fileName))
            let url = package.imageFiles.first { $0.lastPathComponent == card.fileName }
            let data = try Data(contentsOf: XCTUnwrap(url))
            XCTAssertEqual(PlannerBriefingTransferSupport.sha256Hex(data: data), card.contentHashSHA256)
        }
    }

    private func sampleInput() -> PlannerBriefingImageExportInput {
        PlannerBriefingImageExportInput(
            modeLabel: "Deco",
            plannerSessionId: UUID(),
            decoStopRows: [
                PlannerBriefingDecoStopExportRow(
                    depthLabel: "21 m",
                    timeLabel: "3 min",
                    gasLabel: "EAN50",
                    ppO2Label: "1.5"
                ),
            ],
            runtimeRows: [
                PlannerBriefingRuntimeExportRow(
                    kindLabel: "Bottom",
                    depthLabel: "40 m",
                    timeLabel: "20 min",
                    gasLabel: "TX 18/45"
                ),
            ],
            includesDecoStopsInRuntime: true
        )
    }
}
