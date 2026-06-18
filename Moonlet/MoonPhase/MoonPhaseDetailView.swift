import SwiftUI

struct MoonPhaseDetailView: View {
    let snapshot: MoonPhaseSnapshot
    let isToday: Bool

    var body: some View {
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

                MoonPhaseShape(cycleProgress: snapshot.cycleProgress)
                    .frame(width: 236, height: 236)
                    .padding(.top, 34)

                Text(snapshot.phase.displayName)
                    .font(.system(size: 38, weight: .medium, design: .serif))
                    .foregroundStyle(.white)
                    .padding(.top, 28)
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
        .background(MoonPhaseBackground())
        .accessibilityIdentifier("moon-phase-detail")
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
