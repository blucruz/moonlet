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

    func testStoryFragmentDecodesValidPayload() throws {
        let decoder = JSONDecoder()
        let data = """
        {
          "id": "night-11",
          "cycleDay": 11,
          "lunarPhase": "waxing_gibbous",
          "title": "The Light Offshore",
          "caption": "A pale signal appears beyond the flats.",
          "duration": 28,
          "layers": []
        }
        """.data(using: .utf8)!

        let fragment = try decoder.decode(StoryFragment.self, from: data)

        XCTAssertEqual(fragment.id, "night-11")
        XCTAssertEqual(fragment.cycleDay, 11)
        XCTAssertEqual(fragment.lunarPhase, .waxingGibbous)
        XCTAssertEqual(fragment.duration, 28)
    }

    func testStoryFragmentRejectsInvalidDecodedPayload() throws {
        let decoder = JSONDecoder()
        let data = """
        {
          "id": "night-11",
          "cycleDay": 0,
          "lunarPhase": "waxing_gibbous",
          "title": "The Light Offshore",
          "caption": "A pale signal appears beyond the flats.",
          "duration": 28,
          "layers": []
        }
        """.data(using: .utf8)!

        XCTAssertThrowsError(try decoder.decode(StoryFragment.self, from: data)) { error in
            guard case let DecodingError.dataCorrupted(context) = error else {
                return XCTFail("Expected dataCorrupted, got \(error)")
            }

            XCTAssertTrue(context.debugDescription.contains("StoryFragment"))
        }
    }

    @MainActor
    func testPlaybackTransitionsIntoRestStateAfterDuration() async {
        let fragment = StoryFragment(
            id: "night-11",
            cycleDay: 11,
            lunarPhase: .waxingGibbous,
            title: "The Light Offshore",
            caption: "A pale signal appears beyond the flats.",
            duration: 0.01,
            layers: ["sky", "fog", "light"],
            hook: .appearance
        )

        let model = ScenePlaybackViewModel(fragment: try! XCTUnwrap(fragment))
        let playbackTask = Task {
            await model.start()
        }

        await Task.yield()

        XCTAssertEqual(model.playbackState, .playing)

        try? await Task.sleep(for: .milliseconds(30))

        await playbackTask.value

        XCTAssertEqual(model.playbackState, .resting)
    }

    @MainActor
    func testPlaybackCancellationDoesNotTransitionIntoRestState() async {
        let fragment = StoryFragment(
            id: "night-12",
            cycleDay: 12,
            lunarPhase: .waxingGibbous,
            title: "The Tide Holds",
            caption: "The water waits below the reeds.",
            duration: 1,
            layers: ["sky", "fog", "water"],
            hook: .appearance
        )

        let model = ScenePlaybackViewModel(fragment: try! XCTUnwrap(fragment))
        let playbackTask = Task {
            await model.start()
        }

        await Task.yield()

        XCTAssertEqual(model.playbackState, .playing)

        playbackTask.cancel()
        await playbackTask.value

        XCTAssertEqual(model.playbackState, .idle)
    }
}
