import Foundation
import Observation

@MainActor
@Observable
final class MoonPhaseStore {
    var selectedTab: AppRoute = .today
    var displayedMonth: Date
    var selectedDate: Date?
    private(set) var now: Date
    private(set) var dateRange: MoonPhaseDateRange

    let calendar: Calendar
    private let calculator: LunarPhaseCalculator
    private var cache: [Date: MoonPhaseSnapshot] = [:]

    init(
        now: Date = .now,
        calendar: Calendar = .current,
        calculator: LunarPhaseCalculator = .init()
    ) {
        self.now = now
        self.calendar = calendar
        self.calculator = calculator
        self.dateRange = MoonPhaseDateRange(today: now, calendar: calendar)
        self.displayedMonth = calendar.date(
            from: calendar.dateComponents([.year, .month], from: now)
        ) ?? calendar.startOfDay(for: now)
    }

    var todaySnapshot: MoonPhaseSnapshot? {
        calculator.snapshot(for: now)
    }

    func snapshot(for date: Date) -> MoonPhaseSnapshot? {
        guard let sample = dateRange.sampleDate(for: date) else { return nil }
        let key = calendar.startOfDay(for: sample)
        if let cached = cache[key] {
            return cached
        }
        let snapshot = calculator.snapshot(for: sample)
        cache[key] = snapshot
        return snapshot
    }

    func select(_ date: Date) {
        guard dateRange.contains(date) else { return }
        selectedDate = date
    }

    func clearSelection() {
        selectedDate = nil
    }

    @discardableResult
    func moveMonth(by offset: Int) -> Bool {
        guard let target = calendar.date(
            byAdding: .month,
            value: offset,
            to: displayedMonth
        ),
        dateRange.monthIntersectsRange(target),
        let normalized = dateRange.monthStart(containing: target) else {
            return false
        }
        displayedMonth = normalized
        return true
    }

    func refresh(now newNow: Date = .now) {
        let oldDay = calendar.startOfDay(for: now)
        let newDay = calendar.startOfDay(for: newNow)
        now = newNow

        guard oldDay != newDay else { return }

        dateRange = MoonPhaseDateRange(today: newNow, calendar: calendar)
        cache.removeAll()
        selectedDate = selectedDate.flatMap { dateRange.contains($0) ? $0 : nil }
        if !dateRange.monthIntersectsRange(displayedMonth) {
            displayedMonth = dateRange.monthStart(containing: newNow) ?? newDay
        }
    }
}
