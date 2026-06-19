import CoreMotion
import Foundation

final class MoonMotionController {
    private let motionManager = CMMotionManager()
    private let queue = OperationQueue()
    private let parallaxModel = MoonParallaxModel()

    private var neutralPitch: Double?
    private var neutralRoll: Double?
    private var smoothedPitch = 0.0
    private var smoothedYaw = 0.0

    var onMotionUpdate: ((MoonParallaxRotation) -> Void)?

    init() {
        queue.name = "MoonMotionController.queue"
        queue.qualityOfService = .userInteractive
        motionManager.deviceMotionUpdateInterval = 1.0 / 60.0
    }

    func start() {
        guard motionManager.isDeviceMotionAvailable, !motionManager.isDeviceMotionActive else {
            return
        }

        motionManager.startDeviceMotionUpdates(to: queue) { [weak self] motion, _ in
            guard let self, let motion else {
                return
            }

            let attitude = motion.attitude
            guard let neutralPitch = self.neutralPitch,
                  let neutralRoll = self.neutralRoll else {
                self.neutralPitch = attitude.pitch
                self.neutralRoll = attitude.roll
                self.onMotionUpdate?(.zero)
                return
            }

            let target = self.parallaxModel.rotation(
                neutralPitch: neutralPitch,
                neutralRoll: neutralRoll,
                pitch: attitude.pitch,
                roll: attitude.roll
            )
            self.smoothedPitch += (
                target.pitch - self.smoothedPitch
            ) * 0.12
            self.smoothedYaw += (
                target.yaw - self.smoothedYaw
            ) * 0.12

            self.onMotionUpdate?(
                MoonParallaxRotation(
                    pitch: self.smoothedPitch,
                    yaw: self.smoothedYaw
                )
            )
        }
    }

    func stop() {
        if motionManager.isDeviceMotionActive {
            motionManager.stopDeviceMotionUpdates()
        }

        neutralPitch = nil
        neutralRoll = nil
        smoothedPitch = 0
        smoothedYaw = 0
    }
}
