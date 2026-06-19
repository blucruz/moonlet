import XCTest
@testable import Moonlet

final class MoonParallaxModelTests: XCTestCase {
    func testNeutralAttitudeProducesNoRotation() {
        let output = MoonParallaxModel().rotation(
            neutralPitch: 0.4,
            neutralRoll: -0.2,
            pitch: 0.4,
            roll: -0.2
        )

        XCTAssertEqual(output.pitch, 0, accuracy: 0.0001)
        XCTAssertEqual(output.yaw, 0, accuracy: 0.0001)
    }

    func testTiltMapsInOppositeDirection() {
        let output = MoonParallaxModel().rotation(
            neutralPitch: 0,
            neutralRoll: 0,
            pitch: degreesToRadians(10),
            roll: degreesToRadians(10)
        )

        XCTAssertLessThan(output.pitch, 0)
        XCTAssertLessThan(output.yaw, 0)
    }

    func testDeadZoneSuppressesSmallTremor() {
        let output = MoonParallaxModel().rotation(
            neutralPitch: 0,
            neutralRoll: 0,
            pitch: degreesToRadians(0.3),
            roll: degreesToRadians(-0.3)
        )

        XCTAssertEqual(output.pitch, 0, accuracy: 0.0001)
        XCTAssertEqual(output.yaw, 0, accuracy: 0.0001)
    }

    func testRotationIsLimitedToTwoDegrees() {
        let output = MoonParallaxModel().rotation(
            neutralPitch: 0,
            neutralRoll: 0,
            pitch: .pi,
            roll: -.pi
        )

        XCTAssertEqual(
            abs(output.pitch),
            degreesToRadians(2),
            accuracy: 0.0001
        )
        XCTAssertEqual(
            abs(output.yaw),
            degreesToRadians(2),
            accuracy: 0.0001
        )
    }

    func testAngleDeltaWrapsAcrossPiBoundary() {
        let output = MoonParallaxModel().rotation(
            neutralPitch: degreesToRadians(179),
            neutralRoll: 0,
            pitch: degreesToRadians(-179),
            roll: 0
        )

        XCTAssertGreaterThan(output.pitch, degreesToRadians(-1))
        XCTAssertLessThan(output.pitch, 0)
    }

    private func degreesToRadians(_ degrees: Double) -> Double {
        degrees * .pi / 180
    }
}
