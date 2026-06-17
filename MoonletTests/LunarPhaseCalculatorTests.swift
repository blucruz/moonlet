import XCTest
@testable import Moonlet

final class LunarPhaseCalculatorTests: XCTestCase {
    func testReturnsExpectedPhaseBucketsForKnownCycleDays() {
        let calculator = LunarPhaseCalculator()

        XCTAssertEqual(calculator.phase(forCycleDay: 1), .newMoon)
        XCTAssertEqual(calculator.phase(forCycleDay: 6), .waxingCrescent)
        XCTAssertEqual(calculator.phase(forCycleDay: 15), .fullMoon)
        XCTAssertEqual(calculator.phase(forCycleDay: 27), .waningCrescent)
    }

    func testMapsDateIntoThirtyDayContentIndex() {
        let calculator = LunarPhaseCalculator(referenceNewMoon: .init(timeIntervalSince1970: 1_717_286_400))
        let current = Date(timeIntervalSince1970: 1_717_286_400 + (8 * 86_400))

        XCTAssertEqual(calculator.contentDay(for: current), 9)
    }
}
