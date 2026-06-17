import Foundation
import Observation

@Observable
final class AppModel {
    var currentRoute: AppRoute
    var isCalendarPresented: Bool
    let currentDate: Date
    let currentCycleDay: Int
    let currentFragment: StoryFragment
    let cycleFragments: [StoryFragment]

    init(
        currentRoute: AppRoute,
        isCalendarPresented: Bool,
        currentDate: Date,
        currentCycleDay: Int,
        currentFragment: StoryFragment,
        cycleFragments: [StoryFragment]
    ) {
        self.currentRoute = currentRoute
        self.isCalendarPresented = isCalendarPresented
        self.currentDate = currentDate
        self.currentCycleDay = currentCycleDay
        self.currentFragment = currentFragment
        self.cycleFragments = cycleFragments
    }

    static func bootstrap(
        date: Date = .now,
        calculator: LunarPhaseCalculator = LunarPhaseCalculator(),
        repository: FragmentRepository = FragmentRepository(loader: .bundleManifest())
    ) -> AppModel {
        do {
            let fragments = try repository.allFragments()
            let cycleDay = calculator.contentDay(for: date)
            let fragment = try repository.fragment(forCycleDay: cycleDay)

            return AppModel(
                currentRoute: .dailyScene,
                isCalendarPresented: false,
                currentDate: date,
                currentCycleDay: cycleDay,
                currentFragment: fragment,
                cycleFragments: fragments
            )
        } catch {
            fatalError("Failed to bootstrap Moonlet app state: \(error)")
        }
    }

    func toggleCalendarPresentation() {
        isCalendarPresented.toggle()
    }
}
