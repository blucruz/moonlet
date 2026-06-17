import SwiftUI

struct ParallaxLayer: ViewModifier {
    let depth: Double
    let isActive: Bool

    func body(content: Content) -> some View {
        content
            .offset(
                x: isActive ? depth * 12 : 0,
                y: isActive ? depth * -6 : 0
            )
    }
}

extension View {
    func parallaxLayer(depth: Double, isActive: Bool) -> some View {
        modifier(ParallaxLayer(depth: depth, isActive: isActive))
    }
}
