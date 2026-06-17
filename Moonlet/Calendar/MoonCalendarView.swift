import SwiftUI

struct MoonCalendarView: View {
    let fragments: [StoryFragment]
    let currentCycleDay: Int

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Moon Calendar")
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(.white)

                Text("A quiet ledger of the current cycle.")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.72))

                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(fragments) { fragment in
                        MoonCalendarDayCell(
                            fragment: fragment,
                            isCurrentDay: fragment.cycleDay == currentCycleDay
                        )
                    }
                }
            }
            .padding(20)
        }
        .background(.black.opacity(0.88))
        .ignoresSafeArea()
        .accessibilityIdentifier("moon-calendar-view")
    }
}
