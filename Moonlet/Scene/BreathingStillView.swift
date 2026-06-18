import SwiftUI

struct BreathingStillView: View {
    let title: String
    let cycleDay: Int
    let phase: LunarPhase
    let hook: FragmentHook
    let caption: String?

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 24.0, paused: false)) { context in
            let time = context.date.timeIntervalSinceReferenceDate

            ZStack {
                MoonlitBackdropView(time: time)

                VStack(alignment: .leading, spacing: 0) {
                    moonHeader(time: time)

                    Spacer(minLength: 0)

                    posterCopy
                }
                .padding(.horizontal, 30)
                .padding(.top, 48)
                .padding(.bottom, 44)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            }
            .ignoresSafeArea()
        }
    }

    @ViewBuilder
    private func moonHeader(time: TimeInterval) -> some View {
        HStack {
            Spacer()

            MoonDiscView(phase: phase, time: time)
                .frame(width: 300, height: 300)
                .offset(x: 28, y: -6)
        }
        .frame(maxWidth: .infinity)
    }

    private var posterCopy: some View {
        VStack(alignment: .leading, spacing: 18) {
            VStack(alignment: .leading, spacing: 10) {
                Text("Tonight")
                    .font(.system(size: 18, weight: .medium, design: .serif))
                    .tracking(0.3)
                    .foregroundStyle(.white.opacity(0.88))

                RoundedRectangle(cornerRadius: 999)
                    .fill(
                        LinearGradient(
                            colors: [Color(red: 0.91, green: 0.79, blue: 0.66), .clear],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: 48, height: 2)
                    .opacity(0.9)
            }

            VStack(alignment: .leading, spacing: 14) {
                Text(title)
                    .font(.system(size: 58, weight: .medium, design: .serif))
                    .tracking(-1.8)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                Color(red: 0.98, green: 0.93, blue: 0.89),
                                Color(red: 0.91, green: 0.86, blue: 0.84),
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .fixedSize(horizontal: false, vertical: true)

                if let caption, caption.isEmpty == false {
                    Text(caption)
                        .font(.system(size: 20, weight: .regular, design: .serif))
                        .tracking(0.2)
                        .foregroundStyle(Color.white.opacity(0.76))
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            Text("Night \(cycleDay)  •  \(phase.displayName)  •  \(hook.displayName)")
                .font(.system(size: 14, weight: .medium, design: .serif))
                .tracking(1.2)
                .foregroundStyle(Color(red: 0.87, green: 0.74, blue: 0.58).opacity(0.92))
                .padding(.top, 4)
                .accessibilityElement(children: .ignore)
                .accessibilityIdentifier("resting-night-metadata")
                .accessibilityLabel(metadataAccessibilityLabel)
        }
        .frame(maxWidth: 540, alignment: .leading)
        .shadow(color: .black.opacity(0.28), radius: 22, x: 0, y: 10)
    }

    private var metadataAccessibilityLabel: String {
        var parts = [
            "Night \(cycleDay)",
            title,
            phase.displayName,
            hook.displayName,
        ]

        if let caption, caption.isEmpty == false {
            parts.append(caption)
        }

        return parts.joined(separator: ", ")
    }
}

private struct MoonlitBackdropView: View {
    let time: TimeInterval

    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height

            ZStack {
                LinearGradient(
                    colors: [
                        Color(red: 0.04, green: 0.08, blue: 0.14),
                        Color(red: 0.01, green: 0.02, blue: 0.05),
                        .black,
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )

                RadialGradient(
                    colors: [
                        Color(red: 0.34, green: 0.46, blue: 0.68).opacity(0.28),
                        Color(red: 0.10, green: 0.16, blue: 0.26).opacity(0.12),
                        .clear,
                    ],
                    center: .init(x: 0.72, y: 0.26),
                    startRadius: 24,
                    endRadius: 360
                )

                StarfieldView()

                DriftingMistView(
                    width: width,
                    height: height,
                    time: time,
                    anchorY: height * 0.22,
                    opacity: 0.28
                )

                DriftingMistView(
                    width: width * 0.92,
                    height: height,
                    time: time + 17,
                    anchorY: height * 0.63,
                    opacity: 0.44
                )

                DriftingMistView(
                    width: width * 1.08,
                    height: height,
                    time: time + 41,
                    anchorY: height * 0.86,
                    opacity: 0.38
                )
            }
        }
    }
}

private struct StarfieldView: View {
    private let stars: [Star] = [
        .init(x: 0.07, y: 0.15, size: 2.0, opacity: 0.58),
        .init(x: 0.12, y: 0.32, size: 1.5, opacity: 0.48),
        .init(x: 0.24, y: 0.10, size: 1.6, opacity: 0.44),
        .init(x: 0.34, y: 0.06, size: 1.4, opacity: 0.50),
        .init(x: 0.46, y: 0.19, size: 1.6, opacity: 0.42),
        .init(x: 0.56, y: 0.13, size: 1.2, opacity: 0.33),
        .init(x: 0.65, y: 0.10, size: 1.6, opacity: 0.52),
        .init(x: 0.78, y: 0.18, size: 2.1, opacity: 0.64),
        .init(x: 0.89, y: 0.31, size: 2.4, opacity: 0.72),
        .init(x: 0.82, y: 0.54, size: 1.8, opacity: 0.44),
        .init(x: 0.41, y: 0.60, size: 1.8, opacity: 0.56),
        .init(x: 0.69, y: 0.69, size: 1.4, opacity: 0.36),
    ]

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(Array(stars.enumerated()), id: \.offset) { _, star in
                    Circle()
                        .fill(Color.white.opacity(star.opacity))
                        .frame(width: star.size, height: star.size)
                        .blur(radius: 0.2)
                        .position(
                            x: geometry.size.width * star.x,
                            y: geometry.size.height * star.y
                        )
                }
            }
        }
        .allowsHitTesting(false)
    }
}

private struct DriftingMistView: View {
    let width: CGFloat
    let height: CGFloat
    let time: TimeInterval
    let anchorY: CGFloat
    let opacity: Double

    var body: some View {
        let drift = sin(time * 0.12) * 18
        let verticalLift = cos(time * 0.1) * 6

        ZStack {
            Ellipse()
                .fill(Color.white.opacity(0.22))
                .frame(width: width * 0.42, height: 84)
                .blur(radius: 26)
                .offset(x: -width * 0.28 + drift, y: verticalLift)

            Ellipse()
                .fill(Color(red: 0.72, green: 0.78, blue: 0.88).opacity(0.24))
                .frame(width: width * 0.56, height: 118)
                .blur(radius: 36)
                .offset(x: width * 0.08 - drift * 0.55, y: 24 - verticalLift)

            Ellipse()
                .fill(Color(red: 0.30, green: 0.38, blue: 0.52).opacity(0.22))
                .frame(width: width * 0.48, height: 132)
                .blur(radius: 42)
                .offset(x: width * 0.26 + drift * 0.35, y: 50)
        }
        .opacity(opacity)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .offset(y: anchorY)
    }
}

private struct MoonDiscView: View {
    let phase: LunarPhase
    let time: TimeInterval

    private var rimOpacity: Double {
        0.26 + (sin(time * 0.5) * 0.04)
    }

    private var haloScale: CGFloat {
        1.0 + CGFloat(sin(time * 0.22) * 0.018)
    }

    private var shadowOffsetX: CGFloat {
        switch phase {
        case .newMoon:
            0
        case .waxingCrescent:
            -122
        case .firstQuarter:
            -96
        case .waxingGibbous:
            -58
        case .fullMoon:
            -280
        case .waningGibbous:
            58
        case .lastQuarter:
            96
        case .waningCrescent:
            122
        }
    }

    private var shadowOpacity: Double {
        switch phase {
        case .newMoon:
            0.97
        case .waxingCrescent, .waningCrescent:
            0.95
        case .firstQuarter, .lastQuarter:
            0.9
        case .waxingGibbous, .waningGibbous:
            0.78
        case .fullMoon:
            0.0
        }
    }

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(red: 0.83, green: 0.89, blue: 0.99).opacity(0.46),
                            Color(red: 0.37, green: 0.49, blue: 0.69).opacity(0.18),
                            .clear,
                        ],
                        center: .center,
                        startRadius: 22,
                        endRadius: 160
                    )
                )
                .scaleEffect(haloScale * 1.14)
                .blur(radius: 18)

            Circle()
                .stroke(Color.white.opacity(rimOpacity), lineWidth: 0.8)
                .scaleEffect(haloScale * 1.01)
                .blur(radius: 0.25)

            Circle()
                .fill(moonBaseGradient)
                .overlay(alignment: .topLeading) {
                    craterTexture
                        .clipShape(Circle())
                }
                .overlay {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [.clear, Color.black.opacity(0.18)],
                                center: .center,
                                startRadius: 70,
                                endRadius: 148
                            )
                        )
                }
                .overlay {
                    phaseShadow
                        .clipShape(Circle())
                }
                .overlay {
                    Circle()
                        .stroke(Color.white.opacity(0.16), lineWidth: 0.9)
                }
                .shadow(color: Color(red: 0.64, green: 0.77, blue: 1).opacity(0.26), radius: 26, x: 10, y: 0)
                .padding(26)
        }
        .drawingGroup()
        .accessibilityHidden(true)
    }

    private var moonBaseGradient: some ShapeStyle {
        RadialGradient(
            colors: [
                Color(red: 0.95, green: 0.96, blue: 0.98),
                Color(red: 0.86, green: 0.88, blue: 0.92),
                Color(red: 0.62, green: 0.66, blue: 0.74),
            ],
            center: .init(x: 0.78, y: 0.32),
            startRadius: 14,
            endRadius: 150
        )
    }

    private var phaseShadow: some View {
        Circle()
            .fill(
                RadialGradient(
                    colors: [
                        Color(red: 0.01, green: 0.03, blue: 0.07).opacity(0.98),
                        Color(red: 0.01, green: 0.03, blue: 0.08).opacity(0.96),
                        Color(red: 0.03, green: 0.06, blue: 0.12).opacity(0.88),
                        Color(red: 0.08, green: 0.12, blue: 0.20).opacity(0.18),
                        .clear,
                    ],
                    center: .center,
                    startRadius: 12,
                    endRadius: 150
                )
            )
            .frame(width: 258, height: 258)
            .blur(radius: 2)
            .offset(x: shadowOffsetX, y: 1)
            .opacity(shadowOpacity)
    }

    private var craterTexture: some View {
        ZStack {
            crater(x: 0.66, y: 0.22, size: 46, depth: 0.18)
            crater(x: 0.76, y: 0.44, size: 34, depth: 0.16)
            crater(x: 0.68, y: 0.65, size: 30, depth: 0.18)
            crater(x: 0.57, y: 0.34, size: 24, depth: 0.13)
            crater(x: 0.80, y: 0.71, size: 22, depth: 0.12)
            crater(x: 0.47, y: 0.58, size: 18, depth: 0.12)
            crater(x: 0.39, y: 0.22, size: 14, depth: 0.10)

            Group {
                craterRing(x: 0.51, y: 0.14, size: 18)
                craterRing(x: 0.62, y: 0.17, size: 14)
                craterRing(x: 0.59, y: 0.50, size: 17)
                craterRing(x: 0.36, y: 0.55, size: 14)
                craterRing(x: 0.44, y: 0.68, size: 16)
                craterRing(x: 0.71, y: 0.56, size: 15)
                craterRing(x: 0.77, y: 0.30, size: 13)
                craterRing(x: 0.31, y: 0.43, size: 11)
            }

            Ellipse()
                .fill(Color(red: 0.45, green: 0.50, blue: 0.60).opacity(0.26))
                .frame(width: 108, height: 80)
                .offset(x: 22, y: -8)
                .blur(radius: 1.2)

            Ellipse()
                .fill(Color.white.opacity(0.08))
                .frame(width: 86, height: 48)
                .offset(x: 44, y: 32)
                .blur(radius: 2.1)
        }
    }

    private func crater(x: CGFloat, y: CGFloat, size: CGFloat, depth: Double) -> some View {
        ZStack {
            Ellipse()
                .fill(Color.black.opacity(depth))
                .frame(width: size, height: size * 0.82)
                .blur(radius: 1.2)

            Ellipse()
                .stroke(Color.white.opacity(0.16), lineWidth: 0.8)
                .frame(width: size * 0.92, height: size * 0.72)
                .offset(x: 1, y: -1)
        }
        .offset(x: (x - 0.5) * 180, y: (y - 0.5) * 180)
    }

    private func craterRing(x: CGFloat, y: CGFloat, size: CGFloat) -> some View {
        Circle()
            .stroke(Color.white.opacity(0.15), lineWidth: 0.75)
            .frame(width: size, height: size)
            .overlay {
                Circle()
                    .fill(Color.black.opacity(0.08))
                    .padding(2)
            }
            .offset(x: (x - 0.5) * 180, y: (y - 0.5) * 180)
    }
}

private struct Star {
    let x: CGFloat
    let y: CGFloat
    let size: CGFloat
    let opacity: Double
}

private extension FragmentHook {
    var displayName: String {
        switch self {
        case .appearance:
            "Appearance"
        case .approach:
            "Approach"
        case .reveal:
            "Reveal"
        case .departure:
            "Departure"
        case .echo:
            "Echo"
        }
    }
}
