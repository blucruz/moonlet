import SwiftUI

struct MoonCalendarGridView: View {
    @Bindable var store: MoonPhaseStore

    private let columns = Array(
        repeating: GridItem(.flexible(), spacing: 7),
        count: 7
    )
    private let weekdayLabels = ["一", "二", "三", "四", "五", "六", "日"]

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                monthButton(systemName: "chevron.left", offset: -1)
                Spacer()
                Text(MoonPhaseFormatting.month(store.displayedMonth, calendar: store.calendar))
                    .font(.system(.title2, design: .serif, weight: .semibold))
                    .foregroundStyle(.white)
                Spacer()
                monthButton(systemName: "chevron.right", offset: 1)
            }

            LazyVGrid(columns: columns, spacing: 7) {
                ForEach(weekdayLabels, id: \.self) { label in
                    Text(label)
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.4))
                        .frame(maxWidth: .infinity)
                }

                ForEach(calendarDays, id: \.self) { date in
                    dayButton(for: date)
                }
            }
        }
        .accessibilityIdentifier("moon-calendar-grid")
    }

    private var calendarDays: [Date] {
        store.dateRange.calendarDays(inMonthContaining: store.displayedMonth)
    }

    private func monthButton(systemName: String, offset: Int) -> some View {
        let enabled = store.calendar.date(
            byAdding: .month,
            value: offset,
            to: store.displayedMonth
        ).map(store.dateRange.monthIntersectsRange) ?? false

        return Button {
            store.moveMonth(by: offset)
        } label: {
            Image(systemName: systemName)
                .font(.headline)
                .frame(width: 38, height: 38)
                .background(.white.opacity(0.055), in: Circle())
        }
        .foregroundStyle(.white.opacity(enabled ? 0.86 : 0.2))
        .disabled(!enabled)
        .accessibilityLabel(offset < 0 ? "上个月" : "下个月")
    }

    private func dayButton(for date: Date) -> some View {
        let enabled = store.dateRange.contains(date)
        let displayed = store.calendar.isDate(
            date,
            equalTo: store.displayedMonth,
            toGranularity: .month
        )
        let identifier = dateIdentifier(date)

        return Button {
            store.select(date)
        } label: {
            MoonCalendarDayCell(
                date: date,
                snapshot: enabled ? store.snapshot(for: date) : nil,
                isToday: store.calendar.isDate(date, inSameDayAs: store.now),
                isDisplayedMonth: displayed,
                isEnabled: enabled,
                calendar: store.calendar
            )
        }
        .buttonStyle(.plain)
        .disabled(!enabled)
        .accessibilityLabel(identifier)
        .accessibilityIdentifier(identifier)
    }

    private func dateIdentifier(_ date: Date) -> String {
        let components = store.calendar.dateComponents([.year, .month, .day], from: date)
        return String(
            format: "%04d-%02d-%02d",
            components.year ?? 0,
            components.month ?? 0,
            components.day ?? 0
        )
    }
}
