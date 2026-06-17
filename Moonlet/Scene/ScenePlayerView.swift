import SwiftUI

struct ScenePlayerView: View {
    let model: ScenePlaybackViewModel

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if model.playbackState == .resting {
                BreathingStillView(
                    cycleDay: model.fragment.cycleDay,
                    phase: model.fragment.lunarPhase,
                    caption: model.fragment.caption
                )
            } else {
                SceneLayerView(fragment: model.fragment)
            }
        }
        .task {
            guard model.playbackState == .idle else { return }
            await model.start()
        }
    }
}
