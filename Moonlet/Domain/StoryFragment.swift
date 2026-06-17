import Foundation

struct StoryFragment: Identifiable, Codable, Equatable {
    let id: String
    let cycleDay: Int
    let lunarPhase: LunarPhase
    let title: String
    let caption: String?
    let duration: TimeInterval
    let layers: [String]
    let hook: FragmentHook

    private enum CodingKeys: String, CodingKey {
        case id
        case cycleDay
        case lunarPhase
        case title
        case caption
        case duration
        case layers
        case hook
    }

    init?(
        id: String,
        cycleDay: Int,
        lunarPhase: LunarPhase,
        title: String,
        caption: String?,
        duration: TimeInterval,
        layers: [String],
        hook: FragmentHook = .appearance
    ) {
        guard (1...30).contains(cycleDay), duration > 0 else {
            return nil
        }

        self.id = id
        self.cycleDay = cycleDay
        self.lunarPhase = lunarPhase
        self.title = title
        self.caption = caption
        self.duration = duration
        self.layers = layers
        self.hook = hook
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let candidate = StoryFragment(
            id: try container.decode(String.self, forKey: .id),
            cycleDay: try container.decode(Int.self, forKey: .cycleDay),
            lunarPhase: try container.decode(LunarPhase.self, forKey: .lunarPhase),
            title: try container.decode(String.self, forKey: .title),
            caption: try container.decodeIfPresent(String.self, forKey: .caption),
            duration: try container.decode(TimeInterval.self, forKey: .duration),
            layers: try container.decode([String].self, forKey: .layers),
            hook: try container.decodeIfPresent(FragmentHook.self, forKey: .hook) ?? .appearance
        )

        guard let candidate else {
            throw DecodingError.dataCorrupted(
                .init(
                    codingPath: container.codingPath,
                    debugDescription: "Invalid StoryFragment values."
                )
            )
        }

        self = candidate
    }
}
