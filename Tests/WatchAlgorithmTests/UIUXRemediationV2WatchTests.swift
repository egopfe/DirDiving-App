import XCTest

final class UIUXRemediationV2WatchTests: XCTestCase {
    private let reminderAccessibilityKeys = [
        "dive_reminder.overlay.runtime_a11y",
        "dive_reminder.overlay.a11y.dismiss_hint",
        "live.a11y.ttv_hint",
        "a11y.watch.haptics_off_badge.label"
    ]

    func testReminderOverlayAccessibilityKeysExist() throws {
        let en = try loadWatchStrings(named: "en")
        let it = try loadWatchStrings(named: "it")
        for key in reminderAccessibilityKeys {
            XCTAssertFalse(en[key, default: ""].isEmpty, "Missing EN key: \(key)")
            XCTAssertFalse(it[key, default: ""].isEmpty, "Missing IT key: \(key)")
        }
    }

    func testDiveReminderOverlayViewProvidesAccessibilityLabel() throws {
        let source = try String(contentsOf: repositoryRoot().appendingPathComponent("Views/DiveReminderOverlayView.swift"))
        XCTAssertTrue(source.contains("overlayAccessibilityLabel"))
        XCTAssertTrue(source.contains("dive_reminder.overlay.a11y.dismiss_hint"))
        XCTAssertTrue(source.contains("onDismiss"))
        XCTAssertTrue(source.contains("dive_reminder.overlay.runtime_a11y"))
    }

    func testDiveLiveViewUsesLocalizedTTVHint() throws {
        let source = try String(contentsOf: repositoryRoot().appendingPathComponent("Views/DiveLiveView.swift"))
        XCTAssertTrue(source.contains("live.a11y.ttv_hint"))
        XCTAssertFalse(source.contains("TTV informativo derivato da profondita media"))
    }

    func testHapticsOffBadgeHasAccessibilityLabel() throws {
        let source = try String(contentsOf: repositoryRoot().appendingPathComponent("Views/DiveLiveView.swift"))
        XCTAssertTrue(source.contains("a11y.watch.haptics_off_badge.label"))
        XCTAssertTrue(source.contains("a11y.watch.haptics_off_badge.hint"))
    }

    func testUserImagesViewSupportsSwipePaging() throws {
        let source = try String(contentsOf: repositoryRoot().appendingPathComponent("Views/UserImagesView.swift"))
        XCTAssertTrue(source.contains("imageSwipeGesture"))
        XCTAssertTrue(source.contains("selectAdjacentImage"))
    }

    func testUserImagesDeleteErrorUsesReadableTypography() throws {
        let source = try String(contentsOf: repositoryRoot().appendingPathComponent("Views/UserImagesView.swift"))
        XCTAssertTrue(source.contains("DiveUI.Typography.warningBody"))
        XCTAssertFalse(source.contains("size: 9, weight: .semibold"))
    }

    func testSingleReminderOverlayAccessibilityLabel() {
        let overlay = DiveReminderEngine.makeOverlay(
            for: [DiveReminder(id: UUID(), enabled: true, type: .single, triggerMinute: 5, repeatEveryMinutes: nil, message: "Check gas", hapticEnabled: true)],
            runtimeMinute: 5
        )
        let label = reminderOverlayAccessibilityLabel(for: overlay)
        XCTAssertTrue(label.localizedCaseInsensitiveContains("Check gas"))
        XCTAssertTrue(label.localizedCaseInsensitiveContains("REMINDER") || label.localizedCaseInsensitiveContains("PROMEMORIA"))
    }

    func testMultipleReminderOverlayAccessibilityLabelIncludesHiddenCount() {
        let reminders = [
            DiveReminder(id: UUID(), enabled: true, type: .single, triggerMinute: 5, repeatEveryMinutes: nil, message: "One", hapticEnabled: true),
            DiveReminder(id: UUID(), enabled: true, type: .single, triggerMinute: 5, repeatEveryMinutes: nil, message: "Two", hapticEnabled: true),
            DiveReminder(id: UUID(), enabled: true, type: .single, triggerMinute: 5, repeatEveryMinutes: nil, message: "Three", hapticEnabled: true)
        ]
        let overlay = DiveReminderEngine.makeOverlay(for: reminders, runtimeMinute: 5)
        let label = reminderOverlayAccessibilityLabel(for: overlay)
        XCTAssertEqual(overlay.hiddenCount, 1)
        XCTAssertTrue(label.contains("One"))
        XCTAssertTrue(label.contains("Two"))
        XCTAssertTrue(label.contains("+1") || label.localizedCaseInsensitiveContains("1"))
    }

    private func reminderOverlayAccessibilityLabel(for content: DiveReminderOverlayContent) -> String {
        var parts = [content.title]
        parts.append(contentsOf: content.messages)
        if content.hiddenCount > 0 {
            parts.append(String(format: String(localized: "dive_reminder.overlay.more_format"), content.hiddenCount))
        }
        parts.append(
            String(
                format: String(localized: "dive_reminder.overlay.runtime_a11y"),
                Formatters.time(TimeInterval(content.runtimeMinute * 60))
            )
        )
        return parts.joined(separator: ". ")
    }

    private func repositoryRoot() -> URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }

    private func loadWatchStrings(named locale: String) throws -> [String: String] {
        let url = repositoryRoot().appendingPathComponent("Resources/\(locale).lproj/Localizable.strings")
        return parseStringsFile(try String(contentsOf: url, encoding: .utf8))
    }

    private func parseStringsFile(_ raw: String) -> [String: String] {
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
