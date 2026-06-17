import XCTest
@testable import Moonlet

final class LunarPhaseCalculatorTests: XCTestCase {
    func testReturnsExpectedPhaseBucketsForKnownCycleDays() {
        let calculator = LunarPhaseCalculator()

        XCTAssertEqual(calculator.phase(forCycleDay: 1), .newMoon)
        XCTAssertEqual(calculator.phase(forCycleDay: 30), .waningCrescent)
        XCTAssertEqual(calculator.phase(forCycleDay: 0), .newMoon)
        XCTAssertEqual(calculator.phase(forCycleDay: 31), .waningCrescent)
        XCTAssertEqual(calculator.phase(forCycleDay: 6), .waxingCrescent)
        XCTAssertEqual(calculator.phase(forCycleDay: 15), .fullMoon)
        XCTAssertEqual(calculator.phase(forCycleDay: 27), .waningCrescent)
    }

    func testMapsDateIntoThirtyDayContentIndex() {
        let calculator = LunarPhaseCalculator(referenceNewMoon: .init(timeIntervalSince1970: 1_717_286_400))
        let current = Date(timeIntervalSince1970: 1_717_286_400 + (8 * 86_400))

        XCTAssertEqual(calculator.contentDay(for: current), 9)
    }

    func testContentDayStaysStableAcrossLocalDayBoundaryAroundReferenceTime() {
        let calculator = LunarPhaseCalculator(referenceNewMoon: .init(timeIntervalSince1970: 1_717_286_400))
        let calendar = Calendar.current
        let referenceComponents = calendar.dateComponents(in: calendar.timeZone, from: .init(timeIntervalSince1970: 1_717_286_400))

        let beforeRollover = calendar.date(from: DateComponents(
            year: referenceComponents.year,
            month: referenceComponents.month,
            day: referenceComponents.day,
            hour: 7,
            minute: 59
        ))!
        let afterRollover = calendar.date(from: DateComponents(
            year: referenceComponents.year,
            month: referenceComponents.month,
            day: referenceComponents.day,
            hour: 8,
            minute: 1
        ))!

        XCTAssertEqual(calculator.contentDay(for: beforeRollover), 1)
        XCTAssertEqual(calculator.contentDay(for: afterRollover), 1)
    }
}
