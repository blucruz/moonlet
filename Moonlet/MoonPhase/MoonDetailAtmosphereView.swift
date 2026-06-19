import SwiftUI

struct MoonDetailAtmosphereView: View {
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                LinearGradient(
                    colors: [
                        Color(red: 0.025, green: 0.055, blue: 0.13),
                        Color(red: 0.008, green: 0.018, blue: 0.052),
                        .black,
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )

                RadialGradient(
                    colors: [
                        Color(red: 0.48, green: 0.64, blue: 0.94)
                            .opacity(0.18),
                        Color(red: 0.16, green: 0.28, blue: 0.50)
                            .opacity(0.07),
                        .clear,
                    ],
                    center: UnitPoint(x: 0.5, y: 0.29),
                    startRadius: 18,
                    endRadius: min(geometry.size.width, 360) * 0.66
                )

                MoonDetailStarfield()
                MoonDetailEdgeClouds(size: geometry.size)
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

private struct MoonDetailStarfield: View {
    private let stars: [Star] = [
        .init(x: 0.08, y: 0.09, size: 1.2, opacity: 0.48),
        .init(x: 0.18, y: 0.19, size: 1.5, opacity: 0.34),
        .init(x: 0.31, y: 0.08, size: 1.0, opacity: 0.42),
        .init(x: 0.43, y: 0.17, size: 1.1, opacity: 0.27),
        .init(x: 0.58, y: 0.07, size: 1.3, opacity: 0.38),
        .init(x: 0.72, y: 0.16, size: 1.0, opacity: 0.32),
        .init(x: 0.87, y: 0.10, size: 1.7, opacity: 0.52),
        .init(x: 0.94, y: 0.27, size: 1.0, opacity: 0.30),
        .init(x: 0.12, y: 0.39, size: 1.1, opacity: 0.25),
        .init(x: 0.83, y: 0.42, size: 1.2, opacity: 0.29),
        .init(x: 0.22, y: 0.58, size: 0.9, opacity: 0.24),
        .init(x: 0.91, y: 0.62, size: 1.4, opacity: 0.30),
        .init(x: 0.68, y: 0.73, size: 0.9, opacity: 0.20),
    ]

    var body: some View {
        GeometryReader { geometry in
            ForEach(Array(stars.enumerated()), id: \.offset) { _, star in
                Circle()
                    .fill(.white.opacity(star.opacity))
                    .frame(width: star.size, height: star.size)
                    .shadow(
                        color: Color(red: 0.65, green: 0.78, blue: 1)
                            .opacity(star.opacity * 0.45),
                        radius: star.size * 1.7
                    )
                    .position(
                        x: geometry.size.width * star.x,
                        y: geometry.size.height * star.y
                    )
            }
        }
    }

    private struct Star {
        let x: CGFloat
        let y: CGFloat
        let size: CGFloat
        let opacity: Double
    }
}

private struct MoonDetailEdgeClouds: View {
    let size: CGSize

    var body: some View {
        ZStack {
            cloudBank(
                width: size.width * 0.72,
                height: size.height * 0.12,
                opacity: 0.20
            )
            .offset(x: -size.width * 0.44, y: -size.height * 0.14)

            cloudBank(
                width: size.width * 0.62,
                height: size.height * 0.10,
                opacity: 0.15
            )
            .offset(x: size.width * 0.45, y: -size.height * 0.02)

            cloudBank(
                width: size.width * 1.18,
                height: size.height * 0.15,
                opacity: 0.21
            )
            .offset(x: -size.width * 0.22, y: size.height * 0.34)
        }
        .blur(radius: 22)
        .blendMode(.screen)
    }

    private func cloudBank(
        width: CGFloat,
        height: CGFloat,
        opacity: Double
    ) -> some View {
        Capsule()
            .fill(
                LinearGradient(
                    colors: [
                        Color(red: 0.23, green: 0.32, blue: 0.47)
                            .opacity(opacity),
                        Color(red: 0.10, green: 0.16, blue: 0.28)
                            .opacity(opacity * 0.72),
                        .clear,
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .frame(width: width, height: height)
    }
}
