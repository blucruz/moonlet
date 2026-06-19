import CoreMotion
import Foundation

final class MoonMotionController {
    private let motionManager = CMMotionManager()
    private let queue = OperationQueue()

    var onMotionUpdate: ((Double, Double, Double) -> Void)?

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
            guard let motion else {
                return
            }

            let attitude = motion.attitude
            self?.onMotionUpdate?(
                attitude.pitch,
                attitude.roll,
                motion.userAcceleration.z
            )
        }
    }

    func stop() {
        guard motionManager.isDeviceMotionActive else {
            return
        }
        motionManager.stopDeviceMotionUpdates()
    }
}
