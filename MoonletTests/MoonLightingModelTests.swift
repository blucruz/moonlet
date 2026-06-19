import XCTest
@testable import Moonlet

final class MoonLightingModelTests: XCTestCase {
    func testFirstQuarterLightsFromViewerRight() {
        let vector = MoonLightingModel(cycleProgress: 0.25).keyLightPosition

        XCTAssertGreaterThan(vector.x, 0)
        XCTAssertEqual(vector.z, 0, accuracy: 0.0001)
    }

    func testFullMoonLightsFromCamera() {
        let vector = MoonLightingModel(cycleProgress: 0.5).keyLightPosition

        XCTAssertEqual(vector.x, 0, accuracy: 0.0001)
        XCTAssertGreaterThan(vector.z, 0)
    }

    func testLastQuarterLightsFromViewerLeft() {
        let vector = MoonLightingModel(cycleProgress: 0.75).keyLightPosition

        XCTAssertLessThan(vector.x, 0)
        XCTAssertEqual(vector.z, 0, accuracy: 0.0001)
    }

    func testProgressWrapsIntoUnitInterval() {
        XCTAssertEqual(
            MoonLightingModel(cycleProgress: 1.25).progress,
            0.25,
            accuracy: 0.0001
        )
        XCTAssertEqual(
            MoonLightingModel(cycleProgress: -0.25).progress,
            0.75,
            accuracy: 0.0001
        )
    }
}
