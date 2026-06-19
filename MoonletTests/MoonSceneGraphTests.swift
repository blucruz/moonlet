import XCTest
@testable import Moonlet

@MainActor
final class MoonSceneGraphTests: XCTestCase {
    func testMoonAndPhaseLightsShareParallaxNode() {
        let coordinator = MoonSceneKitMoonView.Coordinator()

        XCTAssertTrue(coordinator.moonContainer.parent === coordinator.parallaxNode)
        XCTAssertTrue(coordinator.keyLightNode.parent === coordinator.parallaxNode)
        XCTAssertTrue(coordinator.rimLightNode.parent === coordinator.parallaxNode)
    }
}
