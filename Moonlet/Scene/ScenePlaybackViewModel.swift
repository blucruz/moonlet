import Foundation
import Observation

enum ScenePlaybackState: Equatable {
    case idle
    case playing
    case resting
}

@Observable
final class ScenePlaybackViewModel {
    let fragment: StoryFragment
    var playbackState: ScenePlaybackState = .idle

    init(fragment: StoryFragment) {
        self.fragment = fragment
    }

    @MainActor
    func start() async {
        playbackState = .playing
        do {
            try await Task.sleep(for: .seconds(fragment.duration))
            playbackState = .resting
        } catch is CancellationError {
            playbackState = .idle
        } catch {
            playbackState = .idle
        }
    }
}
