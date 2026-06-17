import XCTest
@testable import Moonlet

final class ScenePlaybackViewModelTests: XCTestCase {
    func testStoryFragmentStoresMinimumDailyMetadata() {
        let fragment = StoryFragment(
            id: "night-11",
            cycleDay: 11,
            lunarPhase: .waxingGibbous,
            title: "The Light Offshore",
            caption: "A pale signal appears beyond the flats.",
            duration: 28,
            layers: []
        )

        XCTAssertEqual(fragment.cycleDay, 11)
        XCTAssertEqual(fragment.lunarPhase, .waxingGibbous)
        XCTAssertEqual(fragment.duration, 28)
    }
}
