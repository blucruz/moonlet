import XCTest

final class MoonletDailyFlowUITests: XCTestCase {
    @MainActor
    func testLaunchesIntoDailySceneAndRevealsCalendar() {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.staticTexts["Tonight"].waitForExistence(timeout: 5))

        let window = app.windows.firstMatch
        XCTAssertTrue(window.waitForExistence(timeout: 2))

        window.tap()
        window.tap()
        window.tap()

        XCTAssertTrue(app.staticTexts["Moon Calendar"].waitForExistence(timeout: 2))
    }
}
