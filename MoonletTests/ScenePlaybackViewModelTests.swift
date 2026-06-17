import XCTest
@testable import Moonlet

final class ScenePlaybackViewModelTests: XCTestCase {
    func testAppModelBootstrapsIntoDailyScene() {
        let appModel = AppModel.bootstrap()

        XCTAssertEqual(appModel.currentRoute, .dailyScene)
        XCTAssertEqual(appModel.currentRoute.accessibilityLabel, "Daily Scene")
    }

    func testStoryFragmentStoresMinimumDailyMetadata() throws {
        XCTAssertNil(
            StoryFragment(
                id: "night-11",
                cycleDay: 0,
                lunarPhase: .waxingGibbous,
                title: "The Light Offshore",
                caption: "A pale signal appears beyond the flats.",
                duration: 28,
                layers: []
            )
        )

        let fragment = try XCTUnwrap(
            StoryFragment(
                id: "night-11",
                cycleDay: 11,
                lunarPhase: .waxingGibbous,
                title: "The Light Offshore",
                caption: "A pale signal appears beyond the flats.",
                duration: 28,
                layers: []
            )
        )

        XCTAssertEqual(fragment.id, "night-11")
        XCTAssertEqual(fragment.cycleDay, 11)
        XCTAssertEqual(fragment.lunarPhase, .waxingGibbous)
        XCTAssertEqual(fragment.duration, 28)
    }

    func testStoryFragmentRejectsNonPositiveDuration() {
        XCTAssertNil(
            StoryFragment(
                id: "night-11",
                cycleDay: 11,
                lunarPhase: .waxingGibbous,
                title: "The Light Offshore",
                caption: "A pale signal appears beyond the flats.",
                duration: 0,
                layers: []
            )
        )
    }
}
