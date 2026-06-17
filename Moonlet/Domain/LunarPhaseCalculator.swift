import Foundation

struct LunarPhaseCalculator {
    private let calendar: Calendar
    private let synodicMonth: Double = 29.530588853
    private let referenceNewMoon: Date

    init(referenceNewMoon: Date = .init(timeIntervalSince1970: 1_717_286_400)) {
        self.calendar = .current
        self.referenceNewMoon = referenceNewMoon
    }

    func contentDay(for date: Date) -> Int {
        let referenceStartOfDay = calendar.startOfDay(for: referenceNewMoon)
        let currentStartOfDay = calendar.startOfDay(for: date)
        let dayOffset = calendar.dateComponents([.day], from: referenceStartOfDay, to: currentStartOfDay).day ?? 0
        let normalizedDays = Double(dayOffset)
            .truncatingRemainder(dividingBy: synodicMonth)
            .addingPositiveCycleOffset(synodicMonth)

        return min(30, Int(floor(normalizedDays)) + 1)
    }

    func phase(forCycleDay day: Int) -> LunarPhase {
        switch min(max(day, 1), 30) {
        case 1...2:
            return .newMoon
        case 3...7:
            return .waxingCrescent
        case 8...10:
            return .firstQuarter
        case 11...14:
            return .waxingGibbous
        case 15...16:
            return .fullMoon
        case 17...21:
            return .waningGibbous
        case 22...24:
            return .lastQuarter
        default:
            return .waningCrescent
        }
    }

    func fragmentContext(for date: Date) -> (cycleDay: Int, phase: LunarPhase) {
        let day = contentDay(for: date)
        return (day, phase(forCycleDay: day))
    }
}

private extension Double {
    func addingPositiveCycleOffset(_ cycleLength: Double) -> Double {
        let remainder = self.truncatingRemainder(dividingBy: cycleLength)
        return remainder < 0 ? remainder + cycleLength : remainder
    }
}
