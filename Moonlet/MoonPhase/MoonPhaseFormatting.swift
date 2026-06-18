import Foundation

enum MoonPhaseFormatting {
    static func illumination(_ value: Double) -> String {
        value.formatted(.percent.precision(.fractionLength(0)))
    }

    static func age(_ days: Double) -> String {
        "\(days.formatted(.number.precision(.fractionLength(1)))) 天"
    }

    static func countdown(_ interval: TimeInterval) -> String {
        let totalHours = max(0, Int(interval / 3_600))
        let days = totalHours / 24
        let hours = totalHours % 24

        if days > 0 {
            return "\(days) 天 \(hours) 小时"
        }
        return "\(hours) 小时"
    }

    static func date(_ date: Date, calendar: Calendar = .current) -> String {
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.locale = Locale(identifier: "zh-Hans")
        formatter.setLocalizedDateFormatFromTemplate("yMMMMd")
        return formatter.string(from: date)
    }

    static func month(_ date: Date, calendar: Calendar = .current) -> String {
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.locale = Locale(identifier: "zh-Hans")
        formatter.setLocalizedDateFormatFromTemplate("yMMMM")
        return formatter.string(from: date)
    }
}
