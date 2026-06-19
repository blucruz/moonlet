import Foundation

struct MoonParallaxRotation: Equatable, Sendable {
    let pitch: Double
    let yaw: Double

    static let zero = MoonParallaxRotation(pitch: 0, yaw: 0)
}

struct MoonParallaxModel: Sendable {
    static let maximumRotation = degreesToRadians(2)
    static let deadZone = degreesToRadians(0.5)
    static let fullInputRange = degreesToRadians(15)

    func rotation(
        neutralPitch: Double,
        neutralRoll: Double,
        pitch: Double,
        roll: Double
    ) -> MoonParallaxRotation {
        MoonParallaxRotation(
            pitch: mappedRotation(
                delta: angularDelta(from: neutralPitch, to: pitch)
            ),
            yaw: mappedRotation(
                delta: angularDelta(from: neutralRoll, to: roll)
            )
        )
    }

    private func angularDelta(from neutral: Double, to current: Double) -> Double {
        var delta = (current - neutral).truncatingRemainder(
            dividingBy: 2 * .pi
        )

        if delta > .pi {
            delta -= 2 * .pi
        } else if delta < -.pi {
            delta += 2 * .pi
        }

        return delta
    }

    private func mappedRotation(delta: Double) -> Double {
        let magnitude = abs(delta)
        guard magnitude > Self.deadZone else {
            return 0
        }

        let usableRange = Self.fullInputRange - Self.deadZone
        let normalized = min(
            1,
            (magnitude - Self.deadZone) / usableRange
        )

        return -delta.sign * normalized * Self.maximumRotation
    }

    private static func degreesToRadians(_ degrees: Double) -> Double {
        degrees * .pi / 180
    }
}

private extension Double {
    var sign: Double {
        self < 0 ? -1 : 1
    }
}
