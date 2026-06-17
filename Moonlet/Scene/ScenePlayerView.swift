import Observation
import SwiftUI

struct ScenePlayerView: View {
    @Bindable var model: ScenePlaybackViewModel
    @State private var ambientAudioController = AmbientAudioController()
    @State private var hapticCuePlayer = HapticCuePlayer()

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if model.playbackState == .resting {
                BreathingStillView(
                    title: model.fragment.title,
                    cycleDay: model.fragment.cycleDay,
                    phase: model.fragment.lunarPhase,
                    hook: model.fragment.hook,
                    caption: model.fragment.caption
                )
            } else {
                SceneLayerView(fragment: model.fragment)
            }
        }
        .task {
            guard model.playbackState == .idle else { return }

            ambientAudioController.playLoop(for: model.fragment.hook)
            hapticCuePlayer.prepareIfNeeded()
            await model.start()

            guard model.playbackState == .resting else { return }
            hapticCuePlayer.playRestTransitionCue()
        }
        .onDisappear {
            ambientAudioController.stop()
            hapticCuePlayer.stop()
        }
    }
}
