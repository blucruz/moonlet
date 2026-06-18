import XCTest

final class MoonletDailyFlowUITests: XCTestCase {
    @MainActor
    func testLaunchesIntoTodayMoonPhaseAndSwitchesTabs() {
        let app = configuredApplication()
        app.launch()

        XCTAssertTrue(app.scrollViews["moon-phase-detail"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.tabBars.buttons["今天"].isSelected)
        XCTAssertTrue(app.staticTexts["moon-phase-name"].exists)

        app.tabBars.buttons["月历"].tap()

        XCTAssertTrue(app.otherElements["moon-calendar-grid"].waitForExistence(timeout: 3))
    }

    @MainActor
    func testCalendarAllowsSelectingAnInRangeDate() {
        let app = configuredApplication()
        app.launch()

        app.tabBars.buttons["月历"].tap()
        XCTAssertTrue(app.otherElements["moon-calendar-grid"].waitForExistence(timeout: 3))

        app.buttons["2026-06-20"].tap()

        XCTAssertTrue(app.scrollViews["moon-phase-detail"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.navigationBars.buttons.firstMatch.exists)
    }

    private func configuredApplication() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["-uiTesting-date", "2026-06-18T12:00:00Z"]
        return app
    }
}
