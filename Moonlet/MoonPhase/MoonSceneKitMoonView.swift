import SceneKit
import SwiftUI
import UIKit

struct MoonSceneKitMoonView: UIViewRepresentable {
    let cycleProgress: Double

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIView(context: Context) -> SCNView {
        let view = SCNView()
        view.backgroundColor = .clear
        view.isOpaque = false
        view.antialiasingMode = .multisampling4X
        view.rendersContinuously = true
        view.isPlaying = true
        view.preferredFramesPerSecond = 60
        view.autoenablesDefaultLighting = false
        view.allowsCameraControl = false
        view.scene = context.coordinator.scene
        context.coordinator.attach(into: view)
        context.coordinator.update(cycleProgress: cycleProgress)
        return view
    }

    func updateUIView(_ uiView: SCNView, context: Context) {
        context.coordinator.update(cycleProgress: cycleProgress)
    }

    static func dismantleUIView(_ uiView: SCNView, coordinator: Coordinator) {
        coordinator.stop()
        uiView.isPlaying = false
    }

    @MainActor
    final class Coordinator {
        let scene = SCNScene()
        let moonContainer = SCNNode()
        let moonNode = SCNNode()
        let keyLightNode = SCNNode()
        let rimLightNode = SCNNode()
        let ambientLightNode = SCNNode()
        let cameraNode = SCNNode()
        let motionController = MoonMotionController()

        private var hasInstalledMoon = false
        private var hasStartedMotion = false
        private var currentCycleProgress: Double = 0

        init() {
            configureScene()
            configureMotion()
        }

        @MainActor
        func attach(into view: SCNView) {
            view.scene = scene
            if view.pointOfView == nil {
                view.pointOfView = cameraNode
            }
            startMotionIfNeeded()
        }

        @MainActor
        func update(cycleProgress: Double) {
            currentCycleProgress = MoonLightingModel(
                cycleProgress: cycleProgress
            ).progress
            installMoonIfNeeded()
            updateLighting()
        }

        func stop() {
            motionController.stop()
            hasStartedMotion = false
        }

        @MainActor
        private func configureScene() {
            scene.rootNode.addChildNode(cameraNode)
            scene.rootNode.addChildNode(keyLightNode)
            scene.rootNode.addChildNode(rimLightNode)
            scene.rootNode.addChildNode(ambientLightNode)
            scene.rootNode.addChildNode(moonContainer)
            scene.background.contents = UIColor.clear

            let camera = SCNCamera()
            camera.fieldOfView = 22
            camera.wantsHDR = true
            camera.bloomIntensity = 0.23
            camera.bloomThreshold = 0.74
            camera.bloomBlurRadius = 9
            camera.exposureOffset = -0.28
            camera.minimumExposure = -1.2
            camera.maximumExposure = 0.4
            camera.automaticallyAdjustsZRange = false
            camera.zNear = 0.1
            camera.zFar = 100
            cameraNode.camera = camera
            cameraNode.position = SCNVector3(0, 0, 6.5)

            let keyLight = SCNLight()
            keyLight.type = .directional
            keyLight.intensity = 1_180
            keyLight.temperature = 6_100
            keyLight.color = UIColor(
                red: 0.96,
                green: 0.98,
                blue: 1,
                alpha: 1
            )
            keyLight.castsShadow = true
            keyLight.shadowMode = .deferred
            keyLight.shadowRadius = 1.5
            keyLight.shadowColor = UIColor.black.withAlphaComponent(0.95)
            keyLightNode.light = keyLight

            let rimLight = SCNLight()
            rimLight.type = .directional
            rimLight.intensity = 92
            rimLight.temperature = 7_800
            rimLight.color = UIColor(
                red: 0.68,
                green: 0.80,
                blue: 1,
                alpha: 1
            )
            rimLightNode.light = rimLight

            let ambientLight = SCNLight()
            ambientLight.type = .ambient
            ambientLight.intensity = 24
            ambientLight.color = UIColor(
                red: 0.18,
                green: 0.22,
                blue: 0.31,
                alpha: 1
            )
            ambientLightNode.light = ambientLight

            moonContainer.position = SCNVector3(0, 0, 0)
            moonContainer.eulerAngles.x = -0.055
        }

        @MainActor
        private func installMoonIfNeeded() {
            guard !hasInstalledMoon else {
                return
            }

            let sphere = SCNSphere(radius: 1)
            sphere.segmentCount = 256

            let material = SCNMaterial()
            material.lightingModel = .physicallyBased
            material.diffuse.contents = loadImage(named: "lroc_color_2k")
                ?? UIColor(white: 0.56, alpha: 1)
            material.diffuse.intensity = 0.88
            material.diffuse.wrapS = .repeat
            material.diffuse.wrapT = .clamp
            material.roughness.contents = UIColor(white: 0.94, alpha: 1)
            material.metalness.contents = 0.0
            material.displacement.contents = loadImage(named: "ldem_3_8bit")
            material.displacement.wrapS = .repeat
            material.displacement.wrapT = .clamp
            material.displacement.intensity = 0.0005
            material.specular.contents = UIColor(white: 0.025, alpha: 1)
            material.locksAmbientWithDiffuse = false
            sphere.firstMaterial = material

            moonNode.geometry = sphere
            moonNode.eulerAngles.y = -.pi * 0.08
            moonContainer.addChildNode(moonNode)
            hasInstalledMoon = true
        }

        @MainActor
        private func loadImage(named name: String) -> UIImage? {
            guard let url = Bundle.main.url(forResource: name, withExtension: "jpg") else {
                return nil
            }
            return UIImage(contentsOfFile: url.path)
        }

        @MainActor
        private func updateLighting() {
            let lighting = MoonLightingModel(
                cycleProgress: currentCycleProgress
            )
            let position = lighting.keyLightPosition

            keyLightNode.position = SCNVector3(
                Float(position.x),
                Float(position.y),
                Float(position.z)
            )
            keyLightNode.look(at: moonContainer.position)

            rimLightNode.position = SCNVector3(
                Float(position.x * 0.92),
                Float(position.y + 0.75),
                Float(position.z * 0.92)
            )
            rimLightNode.look(at: moonContainer.position)
        }

        private func configureMotion() {
            motionController.onMotionUpdate = { [weak self] pitch, roll, accelerationZ in
                DispatchQueue.main.async {
                    guard let self else {
                        return
                    }

                    let subtleDrift = Float(accelerationZ) * 0.045
                    self.moonContainer.eulerAngles = SCNVector3(
                        Float(pitch) * 0.095 - 0.055,
                        Float(roll) * 0.11 + subtleDrift,
                        Float(roll) * 0.028
                    )
                }
            }
        }

        private func startMotionIfNeeded() {
            guard !hasStartedMotion else {
                return
            }

            hasStartedMotion = true
            motionController.start()
        }
    }
}
