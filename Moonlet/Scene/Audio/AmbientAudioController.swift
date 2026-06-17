import AVFoundation

final class AmbientAudioController {
    private var player: AVAudioPlayer?

    func playLoop(for hook: FragmentHook) {
        guard let url = Bundle.main.url(forResource: hook.ambientLoopName, withExtension: "mp3") else {
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
