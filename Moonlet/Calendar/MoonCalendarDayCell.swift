import SwiftUI

struct MoonCalendarDayCell: View {
    let day: Int
    let title: String
    let isCurrent: Bool
    let isUnlocked: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("\(day)")
                .font(.headline.monospacedDigit())
                .foregroundStyle(primaryColor)

            Spacer(minLength: 0)

            if isUnlocked {
                Text(title)
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(primaryColor.opacity(0.82))
                    .lineLimit(2)
            } else {
                Image(systemName: "moonphase.waning.crescent")
                    .font(.caption)
                    .foregroundStyle(primaryColor.opacity(0.55))
            }
        }
        .padding(10)
        .frame(maxWidth: .infinity, minHeight: 76, alignment: .topLeading)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(backgroundColor)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(borderColor, lineWidth: isCurrent ? 1.5 : 1)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityLabel)
    }

    private var backgroundColor: Color {
        if isCurrent {
            return .white.opacity(0.92)
        }

        return isUnlocked ? .white.opacity(0.12) : .white.opacity(0.05)
    }

    private var borderColor: Color {
        if isCurrent {
            return .white
        }

        return isUnlocked ? .white.opacity(0.2) : .white.opacity(0.08)
    }

    private var primaryColor: Color {
        if isCurrent {
            return .black
        }

        return isUnlocked ? .white : .white.opacity(0.42)
    }

    private var accessibilityLabel: String {
        if isCurrent {
            return "Day \(day), current day, \(title)"
        }

        if isUnlocked {
            return "Day \(day), unlocked, \(title)"
        }

        return "Day \(day), locked"
    }
}
