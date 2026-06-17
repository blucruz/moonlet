import SwiftUI

struct MoonCalendarView: View {
    let fragments: [StoryFragment]
    let currentCycleDay: Int
    let onDismiss: () -> Void

    @Environment(\.dismiss) private var dismiss

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 5)

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Moon Calendar")
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(.white)

                    Text("Thirty nights held in a single quiet grid.")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.72))

                    LazyVGrid(columns: columns, spacing: 10) {
                        ForEach(fragments.sorted(by: { $0.cycleDay < $1.cycleDay })) { fragment in
                            MoonCalendarDayCell(
                                day: fragment.cycleDay,
                                title: fragment.title,
                                isCurrent: fragment.cycleDay == currentCycleDay,
                                isUnlocked: fragment.cycleDay <= currentCycleDay
                            )
                        }
                    }
                }
                .padding(20)
            }
            .background(.black.opacity(0.96))
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") {
                        onDismiss()
                        dismiss()
                    }
                    .accessibilityLabel("Close Calendar")
                }
            }
        }
        .ignoresSafeArea()
        .accessibilityIdentifier("moon-calendar-view")
    }
}
