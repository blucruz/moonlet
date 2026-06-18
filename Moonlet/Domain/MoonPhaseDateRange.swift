import Foundation

struct MoonPhaseDateRange: Equatable, Sendable {
    let today: Date
    let startDate: Date
    let endDate: Date
    let days: [Date]
    let calendar: Calendar

    init(today: Date, calendar: Calendar = .current) {
        self.calendar = calendar
        let todayStart = calendar.startOfDay(for: today)
        self.today = todayStart
        self.startDate = calendar.date(byAdding: .day, value: -30, to: todayStart)!
        self.endDate = calendar.date(byAdding: .day, value: 30, to: todayStart)!
        self.days = (-30...30).compactMap { offset in
            guard let day = calendar.date(byAdding: .day, value: offset, to: todayStart) else {
                return nil
            }
            return calendar.date(bySettingHour: 12, minute: 0, second: 0, of: day)
        }
    }

    func contains(_ date: Date) -> Bool {
        let day = calendar.startOfDay(for: date)
        return day >= startDate && day <= endDate
    }

    func sampleDate(for date: Date) -> Date? {
        guard contains(date) else { return nil }
        return calendar.date(bySettingHour: 12, minute: 0, second: 0, of: date)
    }

    func monthStart(containing date: Date) -> Date? {
        calendar.date(
            from: calendar.dateComponents([.year, .month], from: date)
        )
    }

    func monthIntersectsRange(_ date: Date) -> Bool {
        guard let start = monthStart(containing: date),
              let nextMonth = calendar.date(byAdding: .month, value: 1, to: start),
              let lastDay = calendar.date(byAdding: .day, value: -1, to: nextMonth) else {
            return false
        }
        return calendar.startOfDay(for: lastDay) >= startDate && start <= endDate
    }

    func calendarDays(inMonthContaining date: Date) -> [Date] {
        guard let monthStart = monthStart(containing: date),
              let monthRange = calendar.range(of: .day, in: .month, for: monthStart),
              let monthEnd = calendar.date(
                byAdding: .day,
                value: monthRange.count - 1,
                to: monthStart
              ) else {
            return []
        }

        let firstWeekday = calendar.component(.weekday, from: monthStart)
        let mondayBasedLeadingDays = (firstWeekday + 5) % 7
        let finalWeekday = calendar.component(.weekday, from: monthEnd)
        let mondayBasedTrailingDays = (7 - ((finalWeekday + 5) % 7) - 1)
        guard let gridStart = calendar.date(
            byAdding: .day,
            value: -mondayBasedLeadingDays,
            to: monthStart
        ) else {
            return []
        }

        let count = mondayBasedLeadingDays + monthRange.count + mondayBasedTrailingDays
        return (0..<count).compactMap {
            calendar.date(byAdding: .day, value: $0, to: gridStart)
        }
    }
}
