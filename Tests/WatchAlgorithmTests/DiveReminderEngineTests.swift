import XCTest

final class DiveReminderEngineTests: XCTestCase {
    private func makeReminder(
        type: DiveReminderType,
        minute: Int,
        message: String = "Check gas",
        enabled: Bool = true
    ) -> DiveReminder {
        DiveReminder(
            id: UUID(),
            enabled: enabled,
            type: type,
            triggerMinute: minute,
            repeatEveryMinutes: type == .recurring ? minute : nil,
            message: message,
            hapticEnabled: true
        )
    }

    func testSingleReminderFiresOnce() {
        let reminder = makeReminder(type: .single, minute: 5)
        let settings = DiveReminderSettings(remindersEnabled: true, reminders: [reminder])
        var state = DiveReminderRuntimeState()

        let first = DiveReminderEngine.evaluate(runtimeSeconds: 300, runtimeMinute: 5, settings: settings, state: &state)
        XCTAssertEqual(first.count, 1)

        let second = DiveReminderEngine.evaluate(runtimeSeconds: 360, runtimeMinute: 6, settings: settings, state: &state)
        XCTAssertTrue(second.isEmpty)
    }

    func testRecurringReminderFiresAtIntervals() {
        let reminder = makeReminder(type: .recurring, minute: 5)
        let settings = DiveReminderSettings(remindersEnabled: true, reminders: [reminder])
        var state = DiveReminderRuntimeState()

        XCTAssertTrue(DiveReminderEngine.evaluate(runtimeSeconds: 300, runtimeMinute: 5, settings: settings, state: &state).isEmpty == false)
        XCTAssertTrue(DiveReminderEngine.evaluate(runtimeSeconds: 600, runtimeMinute: 10, settings: settings, state: &state).isEmpty == false)
        XCTAssertTrue(DiveReminderEngine.evaluate(runtimeSeconds: 900, runtimeMinute: 15, settings: settings, state: &state).isEmpty == false)
    }

    func testRecurringDoesNotFireMultipleTimesWithinSameMinute() {
        let reminder = makeReminder(type: .recurring, minute: 5)
        let settings = DiveReminderSettings(remindersEnabled: true, reminders: [reminder])
        var state = DiveReminderRuntimeState()

        XCTAssertEqual(DiveReminderEngine.evaluate(runtimeSeconds: 305, runtimeMinute: 5, settings: settings, state: &state).count, 1)
        XCTAssertTrue(DiveReminderEngine.evaluate(runtimeSeconds: 308, runtimeMinute: 5, settings: settings, state: &state).isEmpty)
    }

    func testDisabledReminderDoesNotFire() {
        let reminder = makeReminder(type: .single, minute: 1, enabled: false)
        let settings = DiveReminderSettings(remindersEnabled: true, reminders: [reminder])
        var state = DiveReminderRuntimeState()
        XCTAssertTrue(DiveReminderEngine.evaluate(runtimeSeconds: 120, runtimeMinute: 2, settings: settings, state: &state).isEmpty)
    }

    func testGlobalDisabledPreventsAllReminders() {
        let reminder = makeReminder(type: .single, minute: 1)
        let settings = DiveReminderSettings(remindersEnabled: false, reminders: [reminder])
        var state = DiveReminderRuntimeState()
        XCTAssertTrue(DiveReminderEngine.evaluate(runtimeSeconds: 120, runtimeMinute: 2, settings: settings, state: &state).isEmpty)
    }

    func testSimultaneousRemindersAggregate() {
        let first = makeReminder(type: .single, minute: 10, message: "Check gas")
        let second = makeReminder(type: .single, minute: 10, message: "Check buddy")
        let overlay = DiveReminderEngine.makeOverlay(for: [first, second], runtimeMinute: 10)
        XCTAssertEqual(overlay.messages.count, 2)
        XCTAssertFalse(overlay.title.isEmpty)
    }
}

final class DiveReminderValidationTests: XCTestCase {
    func testCannotSaveEmptyMessage() {
        XCTAssertNil(DiveReminderValidation.sanitizedMessage("   "))
    }

    func testTrimsMessage() {
        XCTAssertEqual(DiveReminderValidation.sanitizedMessage("  Check gas  "), "Check gas")
    }

    func testEnforcesMaxMessageLength() {
        let long = String(repeating: "A", count: 25)
        XCTAssertNil(DiveReminderValidation.sanitizedMessage(long))
    }

    func testEnforcesMaxReminderCount() {
        var settings = DiveReminderSettings()
        settings.reminders = (0..<10).map { index in
            DiveReminder(
                id: UUID(),
                enabled: true,
                type: .single,
                triggerMinute: index + 1,
                repeatEveryMinutes: nil,
                message: "Msg \(index)",
                hapticEnabled: true
            )
        }
        XCTAssertFalse(DiveReminderValidation.canAddReminder(to: settings))
    }
}
