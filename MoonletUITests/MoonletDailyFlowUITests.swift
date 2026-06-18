import XCTest

final class MoonletDailyFlowUITests: XCTestCase {
    @MainActor
    func testLaunchesIntoDailySceneAndRevealsCalendar() {
        let app = XCUIApplication()
        app.launchArguments = ["-uiTesting-short-fragment"]
        app.launch()

        XCTAssertTrue(app.otherElements["daily-scene-root"].waitForExistence(timeout: 5))

        app.swipeDown()

        XCTAssertTrue(app.staticTexts["Moon Calendar"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.buttons["Close Calendar"].waitForExistence(timeout: 2))

        app.buttons["Close Calendar"].tap()

        XCTAssertFalse(app.staticTexts["Moon Calendar"].waitForExistence(timeout: 1))
        XCTAssertTrue(app.otherElements["daily-scene-root"].waitForExistence(timeout: 2))
    }

    @MainActor
    func testRestStateShowsNightMetadata() {
        let app = XCUIApplication()
        app.launchArguments = ["-uiTesting-short-fragment"]
        app.launch()

        let restingMetadata = app.otherElements["resting-night-metadata"]

        XCTAssertTrue(restingMetadata.waitForExistence(timeout: 5))
        XCTAssertTrue(restingMetadata.label.contains("Night"))
    }
}
