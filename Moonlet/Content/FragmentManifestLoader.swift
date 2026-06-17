import Foundation

struct FragmentManifestLoader {
    var load: () throws -> [StoryFragment]

    static func bundleManifest(
        bundle: Bundle = .fragmentResources,
        fileName: String = "cycle-001",
        subdirectory: String = "Fragments"
    ) -> FragmentManifestLoader {
        FragmentManifestLoader {
            let url = bundle.url(forResource: fileName, withExtension: "json", subdirectory: subdirectory)
                ?? bundle.url(forResource: fileName, withExtension: "json")

            guard let url else {
                throw CocoaError(.fileReadNoSuchFile)
            }

            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode([StoryFragment].self, from: data)
        }
    }
}

extension Bundle {
    static var fragmentResources: Bundle {
        Bundle(for: FragmentBundleToken.self)
    }
}

private final class FragmentBundleToken {}
