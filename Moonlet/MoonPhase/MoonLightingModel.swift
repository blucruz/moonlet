import Foundation

struct MoonLightVector: Equatable, Sendable {
    let x: Double
    let y: Double
    let z: Double
}

struct MoonLightingModel: Equatable, Sendable {
    let progress: Double

    init(cycleProgress: Double) {
        let normalized = cycleProgress.truncatingRemainder(dividingBy: 1)
        progress = normalized < 0 ? normalized + 1 : normalized
    }

    var keyLightPosition: MoonLightVector {
        let angle = progress * 2 * .pi - .pi / 2
        let radius = 6.0

        return MoonLightVector(
            x: cos(angle) * radius,
            y: 0.55,
            z: sin(angle) * radius
        )
    }
}
