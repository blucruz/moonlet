import SwiftUI

@main
struct MoonletApp: App {
    @State private var store: MoonPhaseStore
    @Environment(\.scenePhase) private var scenePhase

    init() {
        let now = Self.testingDateFromArguments() ?? .now
        _store = State(initialValue: MoonPhaseStore(now: now))
    }

    var body: some Scene {
        WindowGroup {
            rootView
        }
    }

    private var rootView: some View {
        @Bindable var store = store

        return TabView(selection: $store.selectedTab) {
            NavigationStack {
                if let snapshot = store.todaySnapshot {
                    MoonPhaseDetailView(snapshot: snapshot, isToday: true)
                } else {
                    ContentUnavailableView(
                        "暂时无法计算月相",
                        systemImage: "moon.stars"
                    )
                }
            }
            .tabItem {
                Label("今天", systemImage: "moon.fill")
            }
            .tag(AppRoute.today)

            MoonCalendarView(store: store)
                .tabItem {
                    Label("月历", systemImage: "calendar")
                }
                .tag(AppRoute.calendar)
        }
        .tint(Color(red: 0.88, green: 0.84, blue: 0.74))
        .preferredColorScheme(.dark)
        .onChange(of: scenePhase) { _, phase in
            if phase == .active {
                store.refresh(now: Self.testingDateFromArguments() ?? .now)
            }
        }
    }

    private static func testingDateFromArguments() -> Date? {
        let arguments = ProcessInfo.processInfo.arguments
        guard let flagIndex = arguments.firstIndex(of: "-uiTesting-date"),
              arguments.indices.contains(flagIndex + 1) else {
            return nil
        }
        return ISO8601DateFormatter().date(from: arguments[flagIndex + 1])
    }
}
