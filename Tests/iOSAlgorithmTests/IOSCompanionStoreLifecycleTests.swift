import XCTest

/// Verifies lazy activity store wiring in `DIRDivingiOSApp` without duplicating the full app dependency graph.
final class IOSCompanionStoreLifecycleTests: XCTestCase {
    private func readSource(_ relativePath: String) -> String {
        let url = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent(relativePath)
        return (try? String(contentsOf: url, encoding: .utf8)) ?? ""
    }

    func testAppRootUsesStoreCoordinator() {
        let source = readSource("iOSApp/App/DIRDivingiOSApp.swift")
        XCTAssertTrue(source.contains("IOSCompanionStoreCoordinator"))
        XCTAssertTrue(source.contains("applyApneaEnvironment"))
        XCTAssertTrue(source.contains("applySnorkelingEnvironment"))
    }

    func testAppRootDoesNotEagerlyDeclareAllActivityStateObjects() {
        let source = readSource("iOSApp/App/DIRDivingiOSApp.swift")
        XCTAssertFalse(source.contains("@StateObject private var apneaLogbookStore"))
        XCTAssertFalse(source.contains("@StateObject private var snorkelingLogbookStore"))
        XCTAssertFalse(source.contains("@StateObject private var apneaProfileStore"))
    }

    func testCoordinatorProvidesLazyApneaAndSnorkelingBundles() {
        let source = readSource("iOSApp/Services/IOSCompanionStoreCoordinator.swift")
        XCTAssertTrue(source.contains("func ensureApneaStores()"))
        XCTAssertTrue(source.contains("func ensureSnorkelingStores()"))
        XCTAssertTrue(source.contains("private var apneaBundle"))
        XCTAssertTrue(source.contains("private var snorkelingBundle"))
    }

    func testApneaEnvironmentUsesGlobalNotDivingLayer() {
        let source = readSource("iOSApp/Services/IOSCompanionStoreCoordinator.swift")
        let apneaBody = extractFunctionBody(named: "applyApneaEnvironment", from: source)
        XCTAssertTrue(apneaBody.contains("applyGlobalEnvironment"))
        XCTAssertFalse(apneaBody.contains(".environmentObject(logStore)"))
    }

    private func extractFunctionBody(named name: String, from source: String) -> String {
        guard let start = source.range(of: "func \(name)") else { return "" }
        let tail = source[start.lowerBound...]
        guard let openBrace = tail.firstIndex(of: "{") else { return "" }
        var depth = 0
        var index = openBrace
        while index < tail.endIndex {
            let char = tail[index]
            if char == "{" { depth += 1 }
            if char == "}" {
                depth -= 1
                if depth == 0 {
                    return String(tail[openBrace...index])
                }
            }
            index = tail.index(after: index)
        }
        return ""
    }

    func testWatchSyncUsesLazyLogbookAttachment() {
        let source = readSource("iOSApp/Services/IOSCompanionStoreCoordinator.swift")
        XCTAssertTrue(source.contains("lazyApneaLogbookForSync"))
        XCTAssertTrue(source.contains("lazySnorkelingLogbookForSync"))
    }

    func testCoordinatorForwardsNestedStoreChangesForRootRouting() {
        let source = readSource("iOSApp/Services/IOSCompanionStoreCoordinator.swift")
        XCTAssertTrue(source.contains("forwardNestedStoreChanges(from: companionActivity)"))
        XCTAssertTrue(source.contains("forwardNestedStoreChanges(from: legalAcceptance)"))
    }
}
