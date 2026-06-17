import SwiftUI

struct BreathingStillView: View {
    let title: String
    let cycleDay: Int
    let phase: LunarPhase
    let hook: FragmentHook
    let caption: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Spacer()

            Circle()
                .fill(.white.opacity(0.9))
                .frame(width: 112, height: 112)
                .overlay {
                    Circle()
                        .stroke(.white.opacity(0.3), lineWidth: 18)
                        .scaleEffect(1.08)
                }

            VStack(alignment: .leading, spacing: 8) {
                Text("Night \(cycleDay)")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.92))

                Text(title)
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(.white)

                Text("\(phase.displayName) • \(hook.displayName)")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.white.opacity(0.7))

                if let caption, caption.isEmpty == false {
                    Text(caption)
                        .font(.body)
                        .foregroundStyle(.white.opacity(0.82))
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .accessibilityElement(children: .ignore)
            .accessibilityIdentifier("resting-night-metadata")
            .accessibilityLabel(metadataAccessibilityLabel)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 32)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
        .background(
            RadialGradient(
                colors: [Color.white.opacity(0.14), Color.black],
                center: .center,
                startRadius: 20,
                endRadius: 320
            )
        )
        .ignoresSafeArea()
    }

    private var metadataAccessibilityLabel: String {
        var parts = [
            "Night \(cycleDay)",
            title,
            phase.displayName,
            hook.displayName,
        ]

        if let caption, caption.isEmpty == false {
            parts.append(caption)
        }

        return parts.joined(separator: ", ")
    }
}

private extension LunarPhase {
    var displayName: String {
        switch self {
        case .newMoon:
            "New Moon"
        case .waxingCrescent:
            "Waxing Crescent"
        case .firstQuarter:
            "First Quarter"
        case .waxingGibbous:
            "Waxing Gibbous"
        case .fullMoon:
            "Full Moon"
        case .waningGibbous:
            "Waning Gibbous"
        case .lastQuarter:
            "Last Quarter"
        case .waningCrescent:
            "Waning Crescent"
        }
    }
}

private extension FragmentHook {
    var displayName: String {
        switch self {
        case .appearance:
            "Appearance"
        case .approach:
            "Approach"
        case .reveal:
            "Reveal"
        case .departure:
            "Departure"
        case .echo:
            "Echo"
        }
    }
}
