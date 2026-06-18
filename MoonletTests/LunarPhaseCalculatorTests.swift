import XCTest
@testable import Moonlet

final class LunarPhaseCalculatorTests: XCTestCase {
    func testMapsCycleProgressIntoEightOrderedPhases() {
        XCTAssertEqual(LunarPhase(cycleProgress: 0.00), .newMoon)
        XCTAssertEqual(LunarPhase(cycleProgress: 0.10), .waxingCrescent)
        XCTAssertEqual(LunarPhase(cycleProgress: 0.25), .firstQuarter)
        XCTAssertEqual(LunarPhase(cycleProgress: 0.40), .waxingGibbous)
        XCTAssertEqual(LunarPhase(cycleProgress: 0.50), .fullMoon)
        XCTAssertEqual(LunarPhase(cycleProgress: 0.65), .waningGibbous)
        XCTAssertEqual(LunarPhase(cycleProgress: 0.75), .lastQuarter)
        XCTAssertEqual(LunarPhase(cycleProgress: 0.90), .waningCrescent)
    }

    func testSnapshotRejectsOutOfRangeAstronomicalValues() {
        XCTAssertNil(MoonPhaseSnapshot(
            date: .now,
            phase: .fullMoon,
            cycleProgress: 1.2,
            ageDays: 12,
            illumination: 0.8,
            direction: .waxing,
            nextPrincipalPhase: .lastQuarter,
            nextPrincipalPhaseDate: .now.addingTimeInterval(86_400)
        ))
    }

    func testKnownNewMoonHasLowIlluminationAndNearZeroAge() throws {
        let date = try XCTUnwrap(ISO8601DateFormatter().date(from: "2024-04-08T18:21:00Z"))
        let snapshot = try XCTUnwrap(LunarPhaseCalculator().snapshot(for: date))

        XCTAssertEqual(snapshot.phase, .newMoon)
        XCTAssertLessThan(snapshot.illumination, 0.02)
        XCTAssertTrue(snapshot.ageDays < 1 || snapshot.ageDays > 28.5)
    }

    func testKnownFullMoonHasHighIllumination() throws {
        let date = try XCTUnwrap(ISO8601DateFormatter().date(from: "2024-04-23T23:49:00Z"))
        let snapshot = try XCTUnwrap(LunarPhaseCalculator().snapshot(for: date))

        XCTAssertEqual(snapshot.phase, .fullMoon)
        XCTAssertGreaterThan(snapshot.illumination, 0.98)
    }

    func testKnownQuarterPhasesHaveHalfIllumination() throws {
        let formatter = ISO8601DateFormatter()
        let waxingDate = try XCTUnwrap(formatter.date(from: "2024-04-15T19:13:00Z"))
        let waningDate = try XCTUnwrap(formatter.date(from: "2024-05-01T11:27:00Z"))
        let waxing = try XCTUnwrap(LunarPhaseCalculator().snapshot(for: waxingDate))
        let waning = try XCTUnwrap(LunarPhaseCalculator().snapshot(for: waningDate))

        XCTAssertEqual(waxing.phase, .firstQuarter)
        XCTAssertEqual(waxing.illumination, 0.5, accuracy: 0.04)
        XCTAssertEqual(waxing.direction, .waxing)
        XCTAssertEqual(waning.phase, .lastQuarter)
        XCTAssertEqual(waning.illumination, 0.5, accuracy: 0.04)
        XCTAssertEqual(waning.direction, .waning)
    }

    func testDirectionChangesFromWaxingToWaningAcrossFullMoon() throws {
        let formatter = ISO8601DateFormatter()
        let beforeDate = try XCTUnwrap(formatter.date(from: "2024-04-22T12:00:00Z"))
        let afterDate = try XCTUnwrap(formatter.date(from: "2024-04-25T12:00:00Z"))
        let before = try XCTUnwrap(LunarPhaseCalculator().snapshot(for: beforeDate))
        let after = try XCTUnwrap(LunarPhaseCalculator().snapshot(for: afterDate))

        XCTAssertEqual(before.direction, .waxing)
        XCTAssertEqual(after.direction, .waning)
    }

    func testNextPrincipalPhaseIsFutureAndChronologicallyCorrect() throws {
        let formatter = ISO8601DateFormatter()
        let date = try XCTUnwrap(formatter.date(from: "2024-04-10T00:00:00Z"))
        let expected = try XCTUnwrap(formatter.date(from: "2024-04-15T19:13:00Z"))
        let snapshot = try XCTUnwrap(LunarPhaseCalculator().snapshot(for: date))

        XCTAssertEqual(snapshot.nextPrincipalPhase, .firstQuarter)
        XCTAssertGreaterThan(snapshot.nextPrincipalPhaseDate, date)
        XCTAssertLessThan(
            abs(snapshot.nextPrincipalPhaseDate.timeIntervalSince(expected)),
            12 * 3_600
        )
    }
}
