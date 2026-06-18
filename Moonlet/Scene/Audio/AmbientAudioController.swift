import AVFoundation

final class AmbientAudioController {
    private var player: AVAudioPlayer?
    private static let fallbackResourceName = "moonlet-ambient"

    func playLoop(for hook: FragmentHook) {
        let preferredURL = Bundle.main.url(forResource: hook.ambientLoopName, withExtension: "wav")
            ?? Bundle.main.url(forResource: hook.ambientLoopName, withExtension: "mp3")
        let fallbackURL = Bundle.main.url(
            forResource: Self.fallbackResourceName,
            withExtension: "wav"
        )

        guard let url = preferredURL ?? fallbackURL else {
            stop()
            return
        }

        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.numberOfLoops = -1
            player.volume = 0.15
            player.prepareToPlay()
            player.play()
            self.player = player
        } catch {
            stop()
        }
    }

    func stop() {
        player?.stop()
        player = nil
    }
}

private extension FragmentHook {
    var ambientLoopName: String {
        switch self {
        case .appearance:
            "moonlet-appearance"
        case .approach:
            "moonlet-approach"
        case .reveal:
            "moonlet-reveal"
        case .departure:
            "moonlet-departure"
        case .echo:
            "moonlet-echo"
        }
    }
}
