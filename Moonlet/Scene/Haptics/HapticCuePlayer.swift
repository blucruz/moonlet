import CoreHaptics

final class HapticCuePlayer {
    private var engine: CHHapticEngine?

    func prepareIfNeeded() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else {
            return
        }

        if engine == nil {
            engine = try? CHHapticEngine()
            engine?.isAutoShutdownEnabled = true
        }

        try? engine?.start()
    }

    func playRestTransitionCue() {
        prepareIfNeeded()

        guard let engine else {
            return
        }

        let events = [
            CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    .init(parameterID: .hapticIntensity, value: 0.35),
                    .init(parameterID: .hapticSharpness, value: 0.2),
                ],
                relativeTime: 0
            ),
            CHHapticEvent(
                eventType: .hapticContinuous,
                parameters: [
                    .init(parameterID: .hapticIntensity, value: 0.12),
                    .init(parameterID: .hapticSharpness, value: 0.05),
                ],
                relativeTime: 0.04,
                duration: 0.18
            ),
        ]

        guard let pattern = try? CHHapticPattern(events: events, parameters: []) else {
            return
        }

        let player = try? engine.makePlayer(with: pattern)
        try? player?.start(atTime: CHHapticTimeImmediate)
    }

    func stop() {
        engine?.stop(completionHandler: nil)
        engine = nil
    }
}
