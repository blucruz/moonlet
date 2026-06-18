import SwiftUI

struct MoonPhaseMetricsView: View {
    let snapshot: MoonPhaseSnapshot

    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                metric(
                    title: "照明比例",
                    value: MoonPhaseFormatting.illumination(snapshot.illumination),
                    identifier: "moon-illumination"
                )
                metric(
                    title: "月龄",
                    value: MoonPhaseFormatting.age(snapshot.ageDays),
                    identifier: "moon-age"
                )
            }

            metric(
                title: "下一个关键月相",
                value: "\(snapshot.nextPrincipalPhase.displayName) · \(MoonPhaseFormatting.countdown(snapshot.timeUntilNextPrincipalPhase))",
                identifier: "next-principal-phase"
            )
        }
    }

    private func metric(
        title: String,
        value: String,
        identifier: String
    ) -> some View {
        VStack(alignment: .leading, spacing: 7) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.56))
            Text(value)
                .font(.system(.headline, design: .rounded, weight: .medium))
                .foregroundStyle(.white)
                .accessibilityIdentifier(identifier)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(.white.opacity(0.055), in: RoundedRectangle(cornerRadius: 18))
        .overlay {
            RoundedRectangle(cornerRadius: 18)
                .stroke(.white.opacity(0.08), lineWidth: 0.7)
        }
    }
}
