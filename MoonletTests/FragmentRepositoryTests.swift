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
}
