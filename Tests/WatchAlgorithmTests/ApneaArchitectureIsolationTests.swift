import XCTest

/// Static architecture boundary: Apnea production engine must not mutate Diving / FC runtime.
final class ApneaArchitectureIsolationTests: XCTestCase {
    private let productionApneaPaths = [
        "Shared/Utils/ApneaSessionEngine.swift",
        "Shared/Utils/ApneaLifecycleStateMachine.swift",
        "Shared/Models/ApneaRecoveryPolicy.swift",
        "Shared/Utils/ApneaSessionCheckpoint.swift",
        "Shared/Utils/DepthMeasurementFeed.swift",
        "Shared/Utils/ApneaSchemaMigration.swift",
        "Shared/Models/ApneaSession.swift",
        "Services/ApneaSessionSyncCodec.swift",
        "Services/ApneaSyncWatchReceiver.swift",
        "Shared/Utils/ApneaSyncTransferSupport.swift",
        "Services/ApneaWatchRuntimeStore.swift",
        "Views/ApneaView.swift",
    ]

    private let forbiddenSymbols = [
        "DiveManager",
        "FullComputerRuntimeEngine",
        "BuhlmannEngine",
        "DiveLifecycleAlgorithm",
        "dirdiving_dive_session",
    ]

    func testApneaProductionSourcesDoNotReferenceDivingOrFCRuntime() throws {
        let root = repositoryRoot()
        var violations: [String] = []
        for relative in productionApneaPaths {
            let url = root.appendingPathComponent(relative)
            let text = try String(contentsOf: url, encoding: .utf8)
            for symbol in forbiddenSymbols {
                if text.contains(symbol) {
                    violations.append("\(relative): \(symbol)")
                }
            }
        }
        XCTAssertTrue(violations.isEmpty, "Forbidden cross-domain references: \(violations)")
    }

    func testApneaSessionEngineSourceIsUIIndependent() throws {
        let path = repositoryRoot().appendingPathComponent("Shared/Utils/ApneaSessionEngine.swift")
        let text = try String(contentsOf: path, encoding: .utf8)
        XCTAssertFalse(text.contains("SwiftUI"))
        XCTAssertFalse(text.contains("Timer.scheduledTimer"))
        XCTAssertTrue(text.contains("UI-independent"))
    }

    func testApneaViewIncludedInMainWatchTarget() throws {
        let project = try String(
            contentsOf: repositoryRoot().appendingPathComponent("project.yml"),
            encoding: .utf8
        )
        XCTAssertFalse(project.contains("- ApneaView.swift"))
    }

    func testApneaRuntimeDoesNotWriteDiveLogStore() throws {
        let path = repositoryRoot().appendingPathComponent("Services/ApneaWatchRuntimeStore.swift")
        let text = try String(contentsOf: path, encoding: .utf8)
        XCTAssertFalse(text.contains("DiveLogStore"))
        XCTAssertFalse(text.contains("dirdiving_dive_session"))
    }

    func testApneaProductionUIAndRuntimeDoNotReferenceDiveManager() throws {
        let paths = ["Views/ApneaView.swift", "Services/ApneaWatchRuntimeStore.swift"]
        let root = repositoryRoot()
        var violations: [String] = []
        for relative in paths {
            let text = try String(contentsOf: root.appendingPathComponent(relative), encoding: .utf8)
            for symbol in ["DiveManager", "DiveLogStore", "ExplorationStore"] {
                if text.contains(symbol) {
                    violations.append("\(relative): \(symbol)")
                }
            }
        }
        XCTAssertTrue(violations.isEmpty, violations.joined(separator: ", "))
    }

    func testSyncNamespaceKeysRemainIsolated() {
        XCTAssertTrue(ApneaReleaseSelfCheck.verifySyncNamespaceIsolation().isEmpty)
        XCTAssertNotEqual(
            ApneaReleaseSelfCheck.apneaSessionPayloadKey,
            ApneaReleaseSelfCheck.diveSessionPayloadKey
        )
        XCTAssertNotEqual(
            ApneaReleaseSelfCheck.apneaPlanTransferType,
            ApneaReleaseSelfCheck.fullComputerPlanTransferType
        )
    }

    private func repositoryRoot() -> URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }
}
