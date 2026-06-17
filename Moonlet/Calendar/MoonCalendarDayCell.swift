import SwiftUI

struct MoonCalendarDayCell: View {
    let fragment: StoryFragment
    let isCurrentDay: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Day \(fragment.cycleDay)")
                .font(.caption.weight(.semibold))
                .foregroundStyle(isCurrentDay ? .black.opacity(0.85) : .white.opacity(0.72))

            Text(fragment.title)
                .font(.footnote.weight(.medium))
                .foregroundStyle(isCurrentDay ? .black : .white)
                .lineLimit(3)

            Spacer(minLength: 0)

            Text(fragment.lunarPhase.rawValue.replacingOccurrences(of: "_", with: " ").capitalized)
                .font(.caption2)
                .foregroundStyle(isCurrentDay ? .black.opacity(0.6) : .white.opacity(0.5))
        }
        .padding(12)
        .frame(maxWidth: .infinity, minHeight: 108, alignment: .topLeading)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(isCurrentDay ? Color.white.opacity(0.92) : Color.white.opacity(0.1))
        )
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(isCurrentDay ? Color.white : Color.white.opacity(0.12), lineWidth: 1)
        }
    }
}
