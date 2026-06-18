import SwiftUI

struct MoonPhaseShape: View {
    let cycleProgress: Double

    private var progress: Double {
        let normalized = cycleProgress.truncatingRemainder(dividingBy: 1)
        return normalized < 0 ? normalized + 1 : normalized
    }

    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)

            Canvas { context, canvasSize in
                let rect = CGRect(
                    x: (canvasSize.width - size) / 2,
                    y: (canvasSize.height - size) / 2,
                    width: size,
                    height: size
                )
                context.clip(to: Path(ellipseIn: rect))
                context.fill(
                    Path(ellipseIn: rect),
                    with: .radialGradient(
                        Gradient(colors: [
                            Color(red: 0.98, green: 0.96, blue: 0.88),
                            Color(red: 0.68, green: 0.72, blue: 0.82),
                        ]),
                        center: CGPoint(x: rect.midX * 0.86, y: rect.midY * 0.84),
                        startRadius: 0,
                        endRadius: size * 0.65
                    )
                )

                let shadowOffset = shadowOffset(for: size)
                let shadowRect = rect.offsetBy(dx: shadowOffset, dy: 0)
                context.fill(
                    Path(ellipseIn: shadowRect),
                    with: .color(Color(red: 0.025, green: 0.035, blue: 0.07))
                )
            }
            .shadow(
                color: Color(red: 0.62, green: 0.72, blue: 0.98).opacity(0.26),
                radius: size * 0.13
            )
            .overlay {
                Circle()
                    .stroke(.white.opacity(0.16), lineWidth: 0.7)
                    .frame(width: size, height: size)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .aspectRatio(1, contentMode: .fit)
        .accessibilityHidden(true)
    }

    private func shadowOffset(for size: CGFloat) -> CGFloat {
        if progress <= 0.5 {
            return -CGFloat(progress / 0.5) * size * 1.02
        }
        return CGFloat((1 - progress) / 0.5) * size * 1.02
    }
}
