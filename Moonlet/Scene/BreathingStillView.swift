import SwiftUI

struct BreathingStillView: View {
    let cycleDay: Int
    let phase: LunarPhase
    let caption: String?

    var body: some View {
        VStack(spacing: 18) {
            Circle()
                .fill(.white.opacity(0.9))
                .frame(width: 112, height: 112)
                .overlay {
                    Circle()
                        .stroke(.white.opacity(0.3), lineWidth: 18)
                        .scaleEffect(1.08)
                }

            Text("Day \(cycleDay)")
                .font(.title2.weight(.semibold))
                .foregroundStyle(.white)

            Text(phase.rawValue.replacingOccurrences(of: "_", with: " ").capitalized)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.7))

            if let caption, caption.isEmpty == false {
                Text(caption)
                    .font(.body)
                    .foregroundStyle(.white.opacity(0.82))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
}
