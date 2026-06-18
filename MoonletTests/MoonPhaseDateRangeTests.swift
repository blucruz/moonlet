import XCTest
@testable import Moonlet

final class MoonPhaseDateRangeTests: XCTestCase {
    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "America/Los_Angeles")!
        return calendar
    }

    func testIncludesExactlyThirtyLocalDaysBeforeAndAfterToday() throws {
        let today = try XCTUnwrap(ISO8601DateFormatter().date(from: "2026-06-18T19:00:00Z"))
        let range = MoonPhaseDateRange(today: today, calendar: calendar)

        XCTAssertEqual(range.days.count, 61)
        XCTAssertTrue(range.contains(range.startDate))
        XCTAssertTrue(range.contains(range.endDate))
        XCTAssertFalse(range.contains(calendar.date(byAdding: .day, value: -1, to: range.startDate)!))
        XCTAssertFalse(range.contains(calendar.date(byAdding: .day, value: 1, to: range.endDate)!))
    }

    func testCalendarSamplesEachDayAtLocalNoonAcrossDST() throws {
        let today = try XCTUnwrap(ISO8601DateFormatter().date(from: "2026-03-08T20:00:00Z"))
        let range = MoonPhaseDateRange(today: today, calendar: calendar)

        XCTAssertTrue(range.days.allSatisfy {
            calendar.component(.hour, from: $0) == 12
        })
    }

    func testMonthGridContainsWholeWeeks() throws {
        let today = try XCTUnwrap(ISO8601DateFormatter().date(from: "2026-06-18T19:00:00Z"))
        let range = MoonPhaseDateRange(today: today, calendar: calendar)
        let month = try XCTUnwrap(calendar.date(from: DateComponents(year: 2026, month: 6, day: 1)))
        let grid = range.calendarDays(inMonthContaining: month)

        XCTAssertEqual(grid.count % 7, 0)
        XCTAssertGreaterThanOrEqual(grid.count, 35)
    }
}
