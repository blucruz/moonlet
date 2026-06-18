import SwiftUI

struct MoonCalendarView: View {
    @Bindable var store: MoonPhaseStore

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    Text("月历")
                        .font(.system(size: 34, weight: .semibold, design: .serif))
                        .foregroundStyle(.white)

                    Text("查看今天前后约一个月的月相")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.56))

                    MoonCalendarGridView(store: store)
                        .padding(.top, 14)
                }
                .padding(.horizontal, 18)
                .padding(.top, 22)
                .padding(.bottom, 36)
            }
            .background(MoonPhaseBackground())
            .navigationDestination(
                isPresented: Binding(
                    get: { store.selectedDate != nil },
                    set: { if !$0 { store.clearSelection() } }
                )
            ) {
                selectedDateDetail
            }
        }
    }

    @ViewBuilder
    private var selectedDateDetail: some View {
        if let date = store.selectedDate,
           let snapshot = store.snapshot(for: date) {
            MoonPhaseDetailView(snapshot: snapshot, isToday: false)
        } else {
            ContentUnavailableView(
                "暂时无法计算月相",
                systemImage: "moon.stars"
            )
        }
    }
}
