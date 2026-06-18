import XCTest
@testable import Moonlet

@MainActor
final class MoonPhaseStoreTests: XCTestCase {
    func testBootstrapsOnTodayTabWithCurrentSnapshot() throws {
        let now = try XCTUnwrap(ISO8601DateFormatter().date(from: "2026-06-18T12:00:00Z"))
        let store = MoonPhaseStore(now: now)

        XCTAssertEqual(store.selectedTab, .today)
        XCTAssertNil(store.selectedDate)
        XCTAssertNotNil(store.todaySnapshot)
    }

    func testRejectsSelectionOutsideThirtyDayRange() throws {
        let formatter = ISO8601DateFormatter()
        let now = try XCTUnwrap(formatter.date(from: "2026-06-18T12:00:00Z"))
        let store = MoonPhaseStore(now: now)
        let invalid = try XCTUnwrap(formatter.date(from: "2026-08-01T12:00:00Z"))

        store.select(invalid)

        XCTAssertNil(store.selectedDate)
    }

    func testRefreshMovesDateWindowWhenLocalDayChanges() throws {
        let formatter = ISO8601DateFormatter()
        let first = try XCTUnwrap(formatter.date(from: "2026-06-18T12:00:00Z"))
        let next = try XCTUnwrap(formatter.date(from: "2026-06-19T12:00:00Z"))
        let store = MoonPhaseStore(now: first)
        let oldEnd = store.dateRange.endDate

        store.refresh(now: next)

        XCTAssertGreaterThan(store.dateRange.endDate, oldEnd)
    }

    func testMonthNavigationStopsOutsideAvailableMonths() throws {
        let now = try XCTUnwrap(ISO8601DateFormatter().date(from: "2026-06-18T12:00:00Z"))
        let store = MoonPhaseStore(now: now)

        XCTAssertTrue(store.moveMonth(by: 1))
        XCTAssertFalse(store.moveMonth(by: 1))
        XCTAssertTrue(store.moveMonth(by: -1))
    }
}
