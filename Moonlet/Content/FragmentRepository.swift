import Foundation

enum FragmentRepositoryError: Error, Equatable {
    case invalidFragmentCount(Int)
    case duplicateCycleDay(Int)
    case duplicateID(String)
    case missingCycleDay(Int)
    case fragmentNotFound(Int)
}

struct FragmentRepository {
    let loader: FragmentManifestLoader

    func allFragments() throws -> [StoryFragment] {
        let fragments = try loader.load().sorted { $0.cycleDay < $1.cycleDay }
        try validate(fragments)
        return fragments
    }

    func fragment(forCycleDay day: Int) throws -> StoryFragment {
        guard let fragment = try allFragments().first(where: { $0.cycleDay == day }) else {
            throw FragmentRepositoryError.fragmentNotFound(day)
        }

        return fragment
    }

    private func validate(_ fragments: [StoryFragment]) throws {
        guard fragments.count == 30 else {
            throw FragmentRepositoryError.invalidFragmentCount(fragments.count)
        }

        var seenDays = Set<Int>()
        var seenIDs = Set<String>()

        for fragment in fragments {
            if !seenDays.insert(fragment.cycleDay).inserted {
                throw FragmentRepositoryError.duplicateCycleDay(fragment.cycleDay)
            }

            if !seenIDs.insert(fragment.id).inserted {
                throw FragmentRepositoryError.duplicateID(fragment.id)
            }
        }

        for day in 1...30 where !seenDays.contains(day) {
            throw FragmentRepositoryError.missingCycleDay(day)
        }
    }
}
