import Foundation

struct FragmentRepository {
    let loader: FragmentManifestLoader

    func allFragments() throws -> [StoryFragment] {
        try loader.load().sorted { $0.cycleDay < $1.cycleDay }
    }

    func fragment(forCycleDay day: Int) throws -> StoryFragment {
        guard let fragment = try allFragments().first(where: { $0.cycleDay == day }) else {
            throw CocoaError(.fileReadNoSuchFile)
        }

        return fragment
    }
}
