import SwiftUI

struct MoonCalendarDayCell: View {
    let date: Date
    let snapshot: MoonPhaseSnapshot?
    let isToday: Bool
    let isDisplayedMonth: Bool
    let isEnabled: Bool
    let calendar: Calendar

    var body: some View {
        VStack(spacing: 6) {
            if let snapshot {
                MoonPhaseShape(cycleProgress: snapshot.cycleProgress)
                    .frame(width: 27, height: 27)
            } else {
                Circle()
                    .fill(.white.opacity(0.04))
                    .frame(width: 27, height: 27)
            }

            Text(calendar.component(.day, from: date), format: .number)
                .font(.caption2.weight(isToday ? .bold : .regular))
                .foregroundStyle(.white.opacity(isEnabled ? 0.88 : 0.26))
        }
        .frame(maxWidth: .infinity)
        .frame(height: 58)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isToday ? .white.opacity(0.11) : .white.opacity(0.025))
        )
        .overlay {
            if isToday {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(red: 0.89, green: 0.83, blue: 0.69), lineWidth: 1)
            }
        }
        .opacity(isDisplayedMonth ? 1 : 0.42)
    }
}
