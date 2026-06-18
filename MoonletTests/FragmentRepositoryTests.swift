import XCTest
@testable import Moonlet

final class FragmentRepositoryTests: XCTestCase {
    func testLoadsThirtyFragmentsFromBundleManifest() throws {
        let repository = FragmentRepository(loader: .bundleManifest())

        let fragments = try repository.allFragments()

        XCTAssertEqual(fragments.count, 30)
        XCTAssertEqual(fragments.first?.id, "night-1")
        XCTAssertEqual(fragments.first?.hook, .appearance)
        XCTAssertEqual(fragments.last?.id, "night-30")
    }

    func testReturnsFragmentForRequestedDay() throws {
        let repository = FragmentRepository(loader: .bundleManifest())

        let fragment = try repository.fragment(forCycleDay: 15)

        XCTAssertEqual(fragment.id, "night-15")
        XCTAssertEqual(fragment.cycleDay, 15)
        XCTAssertEqual(fragment.lunarPhase, .fullMoon)
        XCTAssertEqual(fragment.hook, .reveal)
    }

    func testRejectsManifestWithDuplicateCycleDay() {
        let repository = FragmentRepository(loader: .mock(fragments: self.makeFragments { fragments in
            fragments[29] = makeFragment(day: 29, id: "night-30")
        }))

        XCTAssertThrowsError(try repository.allFragments()) { error in
            XCTAssertEqual(error as? FragmentRepositoryError, .duplicateCycleDay(29))
        }
    }

    func testRejectsManifestWithDuplicateIdentifier() {
        let repository = FragmentRepository(loader: .mock(fragments: self.makeFragments { fragments in
            fragments[29] = makeFragment(day: 30, id: "night-29")
        }))

        XCTAssertThrowsError(try repository.allFragments()) { error in
            XCTAssertEqual(error as? FragmentRepositoryError, .duplicateID("night-29"))
        }
    }

    func testRejectsManifestMissingCycleCoverage() {
        let repository = FragmentRepository(loader: .mock(fragments: self.makeFragments { fragments in
            fragments.removeLast()
        }))

        XCTAssertThrowsError(try repository.allFragments()) { error in
            XCTAssertEqual(error as? FragmentRepositoryError, .invalidFragmentCount(29))
        }
    }

    func testReturnsTypedErrorForMissingRequestedDay() {
        let repository = FragmentRepository(loader: .mock())

        XCTAssertThrowsError(try repository.fragment(forCycleDay: 31)) { error in
            XCTAssertEqual(error as? FragmentRepositoryError, .fragmentNotFound(31))
        }
    }

    func testRejectsManifestWithPhaseMismatch() {
        let repository = FragmentRepository(loader: .mock(fragments: self.makeFragments { fragments in
            fragments[14] = StoryFragment(
                id: "night-15",
                cycleDay: 15,
                lunarPhase: .newMoon,
                title: "Night 15",
                caption: nil,
                duration: 24,
                layers: ["sky"],
                hook: .reveal
            )!
        }))

        XCTAssertThrowsError(try repository.allFragments()) { error in
            XCTAssertEqual(
                error as? FragmentRepositoryError,
                .invalidPhase(day: 15, expected: .fullMoon, actual: .newMoon)
            )
        }
    }

    private func makeFragments(_ update: (inout [StoryFragment]) -> Void = { _ in }) -> [StoryFragment] {
        var fragments = (1...30).map { makeFragment(day: $0, id: "night-\($0)") }
        update(&fragments)
        return fragments
    }

    private func makeFragment(day: Int, id: String) -> StoryFragment {
        StoryFragment(
            id: id,
            cycleDay: day,
            lunarPhase: LunarPhaseCalculator().phase(forCycleDay: day),
            title: "Night \(day)",
            caption: nil,
            duration: 24,
            layers: ["sky"],
            hook: day == 15 ? .reveal : .appearance
        )!
    }
}

private extension FragmentManifestLoader {
    static func mock(fragments: @autoclosure @escaping () -> [StoryFragment] = (1...30).map { day in
        StoryFragment(
            id: "night-\(day)",
            cycleDay: day,
            lunarPhase: LunarPhaseCalculator().phase(forCycleDay: day),
            title: "Night \(day)",
            caption: nil,
            duration: 24,
            layers: ["sky"],
            hook: day == 15 ? .reveal : .appearance
        )!
    }) -> FragmentManifestLoader {
        FragmentManifestLoader { fragments() }
    }
}
