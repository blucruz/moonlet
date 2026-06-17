import Foundation

struct StoryFragment: Identifiable, Codable, Equatable {
    let id: String
    let cycleDay: Int
    let lunarPhase: LunarPhase
    let title: String
    let caption: String?
    let duration: TimeInterval
    let layers: [String]

    init?(
        id: String,
        cycleDay: Int,
        lunarPhase: LunarPhase,
        title: String,
        caption: String?,
        duration: TimeInterval,
        layers: [String]
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
    }
}
