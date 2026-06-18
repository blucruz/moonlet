import Foundation

enum LunarPhase: String, Codable, Equatable {
    case newMoon = "new_moon"
    case waxingCrescent = "waxing_crescent"
    case firstQuarter = "first_quarter"
    case waxingGibbous = "waxing_gibbous"
    case fullMoon = "full_moon"
    case waningGibbous = "waning_gibbous"
    case lastQuarter = "last_quarter"
    case waningCrescent = "waning_crescent"

    init(cycleProgress: Double) {
        let progress = cycleProgress - floor(cycleProgress)

        switch progress {
        case 0..<0.0625, 0.9375..<1:
            self = .newMoon
        case 0.0625..<0.1875:
            self = .waxingCrescent
        case 0.1875..<0.3125:
            self = .firstQuarter
        case 0.3125..<0.4375:
            self = .waxingGibbous
        case 0.4375..<0.5625:
            self = .fullMoon
        case 0.5625..<0.6875:
            self = .waningGibbous
        case 0.6875..<0.8125:
            self = .lastQuarter
        default:
            self = .waningCrescent
        }
    }

    var localizationKey: String {
        "phase.\(rawValue)"
    }

    var displayName: String {
        switch self {
        case .newMoon: "新月"
        case .waxingCrescent: "娥眉月"
        case .firstQuarter: "上弦月"
        case .waxingGibbous: "盈凸月"
        case .fullMoon: "满月"
        case .waningGibbous: "亏凸月"
        case .lastQuarter: "下弦月"
        case .waningCrescent: "残月"
        }
    }
}
