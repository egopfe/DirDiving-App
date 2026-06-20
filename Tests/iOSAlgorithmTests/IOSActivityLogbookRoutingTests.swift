import XCTest

final class IOSActivityLogbookRoutingTests: XCTestCase {
    func testSixForbiddenCrossActivityLogbookRoutesDataDriven() {
        XCTAssertEqual(IOSActivityLogbookRoutingPolicy.forbiddenCrossRoutes.count, 6)
        for (source, target) in IOSActivityLogbookRoutingPolicy.forbiddenCrossRoutes {
            XCTAssertFalse(
                IOSActivityLogbookRoutingPolicy.isRouteAllowed(from: source, to: target),
                "forbidden route source=\(source) target=\(target)"
            )
        }
    }

    func testOwningLogbookMatchesActivity() {
        XCTAssertEqual(IOSActivityLogbookRoutingPolicy.owningLogbook(for: .diving), .diving)
        XCTAssertEqual(IOSActivityLogbookRoutingPolicy.owningLogbook(for: .apnea), .apnea)
        XCTAssertEqual(IOSActivityLogbookRoutingPolicy.owningLogbook(for: .snorkeling), .snorkeling)
    }

    func testAppRootRoutesToActivitySpecificRoots() throws {
        let source = try readSource("iOSApp/App/DIRDivingiOSApp.swift")
        XCTAssertTrue(source.contains("IOSApneaRootView"))
        XCTAssertTrue(source.contains("IOSSnorkelingRootView"))
        XCTAssertTrue(source.contains("applyDivingEnvironment"))
        XCTAssertFalse(source.contains("applySharedEnvironment(to: ContentView"))
    }

    func testDivingRootUsesDivingLogbookOnly() throws {
        let contentView = try readSource("iOSApp/Views/ContentView.swift")
        XCTAssertTrue(contentView.contains("LogbookView"))
        let apneaRoot = try readSource("iOSApp/Views/Apnea/IOSApneaRootView.swift")
        XCTAssertTrue(apneaRoot.contains("IOSApneaSessionsListView"))
        XCTAssertFalse(apneaRoot.contains("LogbookView"))
        XCTAssertFalse(apneaRoot.contains("DiveLogStore"))
        let snorkelingRoot = try readSource("iOSApp/Views/Snorkeling/IOSSnorkelingRootView.swift")
        XCTAssertTrue(snorkelingRoot.contains("IOSSnorkelingSessionsListView"))
        XCTAssertFalse(snorkelingRoot.contains("LogbookView"))
    }

    func testApneaViewsDoNotReferenceDivingLogbook() throws {
        let apneaDir = repositoryRoot().appendingPathComponent("iOSApp/Views/Apnea")
        let files = try FileManager.default.contentsOfDirectory(at: apneaDir, includingPropertiesForKeys: nil)
            .filter { $0.pathExtension == "swift" }
        for file in files {
            let source = try String(contentsOf: file)
            XCTAssertFalse(source.contains("DiveLogStore"), file.lastPathComponent)
            XCTAssertFalse(source.contains("LogbookView"), file.lastPathComponent)
        }
    }

    func testSnorkelingViewsDoNotReferenceDivingLogbook() throws {
        let dir = repositoryRoot().appendingPathComponent("iOSApp/Views/Snorkeling")
        let files = try FileManager.default.contentsOfDirectory(at: dir, includingPropertiesForKeys: nil)
            .filter { $0.pathExtension == "swift" }
        for file in files {
            let source = try String(contentsOf: file)
            XCTAssertFalse(source.contains("DiveLogStore"), file.lastPathComponent)
            XCTAssertFalse(source.contains("LogbookView"), file.lastPathComponent)
        }
    }

    private func repositoryRoot() -> URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }

    private func readSource(_ relativePath: String) throws -> String {
        try String(contentsOf: repositoryRoot().appendingPathComponent(relativePath), encoding: .utf8)
    }
}

import XCTest

final class IOSCompanionEnvironmentIsolationTests: XCTestCase {
    func testApneaEnvironmentDoesNotInjectDiveLogStore() throws {
        let source = try readSource("iOSApp/Services/IOSCompanionStoreCoordinator.swift")
        let apneaBody = extractFunctionBody(named: "applyApneaEnvironment", from: source)
        XCTAssertFalse(apneaBody.contains(".environmentObject(logStore)"))
        XCTAssertTrue(apneaBody.contains("applyGlobalEnvironment"))
    }

    func testSnorkelingEnvironmentDoesNotInjectDiveLogStore() throws {
        let source = try readSource("iOSApp/Services/IOSCompanionStoreCoordinator.swift")
        let snorkelingBody = extractFunctionBody(named: "applySnorkelingEnvironment", from: source)
        XCTAssertFalse(snorkelingBody.contains(".environmentObject(logStore)"))
        XCTAssertTrue(snorkelingBody.contains("applyGlobalEnvironment"))
    }

    func testDivingEnvironmentInjectsDiveLogStore() throws {
        let source = try readSource("iOSApp/Services/IOSCompanionStoreCoordinator.swift")
        let divingBody = extractFunctionBody(named: "applyDivingEnvironment", from: source)
        XCTAssertTrue(divingBody.contains(".environmentObject(logStore)"))
    }

    func testDivingSettingsStoreFacadeExists() throws {
        let source = try readSource("iOSApp/Services/IOSDivingSettingsStore.swift")
        XCTAssertTrue(source.contains("registryNamespace"))
        XCTAssertTrue(source.contains("plannerAscentSpeedSettings"))
    }

    func testNamingMapAlignsSpecAndImplementation() throws {
        let source = try readSource("iOSApp/Utils/ActivitySettingsNamingMap.swift")
        XCTAssertTrue(source.contains("\"DivingSettingsStore\": \"IOSDivingSettingsStore\""))
        XCTAssertTrue(source.contains("\"SharedSettingsStore\": \"SharedIOSSettingsStore\""))
    }

    private func repositoryRoot() -> URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }

    private func readSource(_ relativePath: String) throws -> String {
        try String(contentsOf: repositoryRoot().appendingPathComponent(relativePath), encoding: .utf8)
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
}
