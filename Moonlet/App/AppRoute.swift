enum AppRoute {
    case today
    case calendar
    case dailyScene
    case moonCalendar

    var accessibilityLabel: String {
        switch self {
        case .today:
            "今天"
        case .calendar:
            "月历"
        case .dailyScene:
            "Daily Scene"
        case .moonCalendar:
            "Moon Calendar"
        }
    }
}
