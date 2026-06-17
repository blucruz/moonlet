enum AppRoute {
    case dailyScene
    case moonCalendar

    var accessibilityLabel: String {
        switch self {
        case .dailyScene:
            "Daily Scene"
        case .moonCalendar:
            "Moon Calendar"
        }
    }
}
