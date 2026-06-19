import SwiftUI

struct MoonPhaseDetailView: View {
    let snapshot: MoonPhaseSnapshot
    let isToday: Bool

    var body: some View {
        ZStack {
            MoonDetailAtmosphereView()

            ScrollView {
                VStack(spacing: 0) {
                    VStack(spacing: 8) {
                        Text(isToday ? "今天" : "月相详情")
                            .font(.caption.weight(.semibold))
                            .tracking(1.8)
                            .foregroundStyle(.white.opacity(0.58))

                        Text(MoonPhaseFormatting.date(snapshot.date))
                            .font(.system(.title3, design: .serif, weight: .medium))
                            .foregroundStyle(.white.opacity(0.88))
                    }

                    ZStack {
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        Color(red: 0.50, green: 0.66, blue: 0.98)
                                            .opacity(0.18),
                                        .clear,
                                    ],
                                    center: .center,
                                    startRadius: 62,
                                    endRadius: 178
                                )
                            )
                            .frame(width: 334, height: 334)
                            .blur(radius: 13)

                        MoonSceneKitMoonView(
                            cycleProgress: snapshot.cycleProgress
                        )
                        .frame(width: 286, height: 286)
                    }
                    .frame(height: 306)
                    .padding(.top, 20)

                    Text(snapshot.phase.displayName)
                        .font(.system(size: 38, weight: .medium, design: .serif))
                        .foregroundStyle(.white)
                        .padding(.top, 19)
                        .accessibilityIdentifier("moon-phase-name")

                    Text(snapshot.direction == .waxing ? "月光渐盈" : "月光渐亏")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.56))
                        .padding(.top, 8)

                    MoonPhaseMetricsView(snapshot: snapshot)
                        .padding(.top, 34)
                }
                .padding(.horizontal, 22)
                .padding(.top, 30)
                .padding(.bottom, 40)
            }
            .accessibilityIdentifier("moon-phase-detail")
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct MoonPhaseBackground: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.07, green: 0.10, blue: 0.23),
                    Color(red: 0.025, green: 0.035, blue: 0.09),
                    .black,
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            RadialGradient(
                colors: [Color.indigo.opacity(0.24), .clear],
                center: .top,
                startRadius: 20,
                endRadius: 420
            )
        }
        .ignoresSafeArea()
    }
}
