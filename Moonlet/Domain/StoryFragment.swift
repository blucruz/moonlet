import Foundation

struct StoryFragment: Identifiable, Codable, Equatable {
    let id: String
    let cycleDay: Int
    let lunarPhase: LunarPhase
    let title: String
    let caption: String?
    let duration: TimeInterval
    let layers: [String]
}
