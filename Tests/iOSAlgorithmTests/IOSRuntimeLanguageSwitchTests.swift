import XCTest
@testable import DIRDivingiOSApp

final class IOSRuntimeLanguageSwitchTests: XCTestCase {
    private var originalLanguage: String?

    override func setUp() {
        super.setUp()
        originalLanguage = UserDefaults.standard.string(forKey: DIRIOSAppLanguage.storageKey)
    }

    override func tearDown() {
        if let originalLanguage {
            UserDefaults.standard.set(originalLanguage, forKey: DIRIOSAppLanguage.storageKey)
        } else {
            UserDefaults.standard.removeObject(forKey: DIRIOSAppLanguage.storageKey)
        }
        super.tearDown()
    }

    func testDIRIOSLocalizerResolvesDifferentTabPlannerLabelsPerLanguage() {
        UserDefaults.standard.set(DIRIOSAppLanguage.english.rawValue, forKey: DIRIOSAppLanguage.storageKey)
        let english = DIRIOSLocalizer.string("tab.planner", language: .english)

        UserDefaults.standard.set(DIRIOSAppLanguage.italian.rawValue, forKey: DIRIOSAppLanguage.storageKey)
        let italian = DIRIOSLocalizer.string("tab.planner", language: .italian)

        XCTAssertEqual(english, "Planner")
        XCTAssertEqual(italian, "Pianifica")
        XCTAssertNotEqual(english, italian)
    }

    func testDIRIOSLocalizerFallsBackToKeyForUnknownEntry() {
        let value = DIRIOSLocalizer.string("ios.runtime.language.missing.key", language: .english)
        XCTAssertEqual(value, "ios.runtime.language.missing.key")
    }

    func testDIRIOSLocalizerPreservesFormatArguments() {
        let english = DIRIOSLocalizer.formatted(
            "checklist.status.ready_badge_format",
            language: .english,
            2, 5
        )
        XCTAssertTrue(english.contains("2"))
        XCTAssertTrue(english.contains("5"))

        let italian = DIRIOSLocalizer.formatted(
            "checklist.status.ready_badge_format",
            language: .italian,
            2, 5
        )
        XCTAssertTrue(italian.contains("2"))
        XCTAssertTrue(italian.contains("5"))
        XCTAssertNotEqual(english, italian)
    }

    func testLanguageOptionKeysExistInCatalogs() {
        let keys = [
            "language.option.system",
            "language.option.italian",
            "language.option.english",
            "language.option.system.detail",
            "language.option.italian.detail",
            "language.option.english.detail"
        ]
        for key in keys {
            XCTAssertFalse(DIRIOSLocalizer.string(key, language: .english).isEmpty)
            XCTAssertFalse(DIRIOSLocalizer.string(key, language: .italian).isEmpty)
        }
    }

    func testShippedIOSUIUsesRuntimeLocalizer() throws {
        let root = repositoryRoot()
        let more = try String(contentsOf: root.appendingPathComponent("iOSApp/Views/MoreView.swift"))
        let tabBar = try String(contentsOf: root.appendingPathComponent("iOSApp/Views/Components/DIRCompanionTabBar.swift"))

        XCTAssertTrue(more.contains("DIRIOSLocalizer.string"))
        XCTAssertFalse(more.contains("String(localized:"))
        XCTAssertTrue(tabBar.contains("DIRIOSLocalizer.string"))
        XCTAssertTrue(tabBar.contains("DIRIOSAppLanguage.storageKey"))
    }

    private func repositoryRoot() -> URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }
}
