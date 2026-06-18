import Foundation
import Observation

@Observable
final class AppModel {
    var currentRoute: AppRoute
    var isCalendarPresented: Bool
    var currentDate: Date
    var currentCycleDay: Int
    var currentFragment: StoryFragment
    var cycleFragments: [StoryFragment]
    var playbackModel: ScenePlaybackViewModel

    init(
        currentRoute: AppRoute,
        isCalendarPresented: Bool,
        currentDate: Date,
        currentCycleDay: Int,
        currentFragment: StoryFragment,
        cycleFragments: [StoryFragment],
        playbackModel: ScenePlaybackViewModel
    ) {
        self.currentRoute = currentRoute
        self.isCalendarPresented = isCalendarPresented
        self.currentDate = currentDate
        self.currentCycleDay = currentCycleDay
        self.currentFragment = currentFragment
        self.cycleFragments = cycleFragments
        self.playbackModel = playbackModel
    }

    static func bootstrap(
        date: Date = .now,
        calculator: LunarPhaseCalculator = LunarPhaseCalculator(),
        repository: FragmentRepository = FragmentRepository(loader: .bundleManifest())
    ) -> AppModel {
        let cycleDay = calculator.contentDay(for: date)
        let fragments = (try? repository.allFragments()) ?? fallbackFragments(using: calculator)
        let baseFragment = fragments.first(where: { $0.cycleDay == cycleDay }) ?? fragments[cycleDay - 1]
        let fragment = configuredFragment(baseFragment)

        return AppModel(
            currentRoute: .dailyScene,
            isCalendarPresented: false,
            currentDate: date,
            currentCycleDay: cycleDay,
            currentFragment: fragment,
            cycleFragments: fragments,
            playbackModel: ScenePlaybackViewModel(fragment: fragment)
        )
    }

    func revealCalendar() {
        isCalendarPresented = true
    }

    func dismissCalendar() {
        isCalendarPresented = false
    }

    func refreshIfNeeded(
        date: Date = .now,
        calculator: LunarPhaseCalculator = LunarPhaseCalculator(),
        repository: FragmentRepository = FragmentRepository(loader: .bundleManifest())
    ) {
        let nextCycleDay = calculator.contentDay(for: date)
        guard nextCycleDay != currentCycleDay else {
            currentDate = date
            return
        }

        let fragments = (try? repository.allFragments()) ?? Self.fallbackFragments(using: calculator)
        let baseFragment = fragments.first(where: { $0.cycleDay == nextCycleDay }) ?? fragments[nextCycleDay - 1]
        let fragment = Self.configuredFragment(baseFragment)

        currentDate = date
        currentCycleDay = nextCycleDay
        currentFragment = fragment
        cycleFragments = fragments
        playbackModel = ScenePlaybackViewModel(fragment: fragment)
    }
}

private extension AppModel {
    static func configuredFragment(_ fragment: StoryFragment) -> StoryFragment {
        guard ProcessInfo.processInfo.arguments.contains("-uiTesting-short-fragment") else {
            return fragment
        }

        return StoryFragment(
            id: fragment.id,
            cycleDay: fragment.cycleDay,
            lunarPhase: fragment.lunarPhase,
            title: fragment.title,
            caption: fragment.caption,
            duration: 0.1,
            layers: fragment.layers,
            hook: fragment.hook
        ) ?? fragment
    }

    static func fallbackFragments(using calculator: LunarPhaseCalculator) -> [StoryFragment] {
        (1...30).compactMap { day in
            StoryFragment(
                id: "fallback-night-\(day)",
                cycleDay: day,
                lunarPhase: calculator.phase(forCycleDay: day),
                title: "Night \(day)",
                caption: "The tide keeps its own quiet record.",
                duration: 24,
                layers: ["moon-glow", "mist-bank", "shoreline"],
                hook: .appearance
            )
        }
    }
}
