import SwiftUI

struct SceneLayerView: View {
    let fragment: StoryFragment

    private var motionProfile: MotionProfile {
        MotionProfile.forPhase(fragment.lunarPhase)
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.indigo.opacity(0.9), Color.black],
                startPoint: .top,
                endPoint: .bottom
            )

            ForEach(Array(fragment.layers.enumerated()), id: \.offset) { index, layer in
                RoundedRectangle(cornerRadius: 24)
                    .fill(layerColor(for: index).opacity(0.24))
                    .frame(
                        width: 260 + CGFloat(index * 28),
                        height: 260 + CGFloat(index * 36)
                    )
                    .overlay(alignment: .bottomLeading) {
                        Text(layer.capitalized)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.white.opacity(0.8))
                            .padding(14)
                    }
                    .parallaxLayer(
                        depth: motionProfile.parallaxDepth * Double(index + 1),
                        isActive: true
                    )
            }
        }
        .ignoresSafeArea()
    }

    private func layerColor(for index: Int) -> Color {
        let colors: [Color] = [.blue, .teal, .mint, .cyan]
        return colors[index % colors.count]
    }
}
