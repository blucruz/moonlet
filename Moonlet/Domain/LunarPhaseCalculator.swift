import Foundation

struct LunarPhaseCalculator: Sendable {
    private static let julianUnixEpoch = 2_440_587.5
    private static let julianJ2000 = 2_451_545.0
    private static let synodicMonth = 29.530588853

    private let calendar: Calendar
    private let referenceNewMoon: Date

    init(referenceNewMoon: Date = .init(timeIntervalSince1970: 1_717_286_400)) {
        self.calendar = .current
        self.referenceNewMoon = referenceNewMoon
    }

    func snapshot(for date: Date) -> MoonPhaseSnapshot? {
        let elongation = lunarElongationDegrees(at: date)
        let progress = elongation / 360
        let illumination = (1 - cos(elongation.radians)) / 2
        let direction: MoonPhaseDirection = progress < 0.5 ? .waxing : .waning
        let next = nextPrincipalPhase(after: date, progress: progress)

        return MoonPhaseSnapshot(
            date: date,
            phase: LunarPhase(cycleProgress: progress),
            cycleProgress: progress,
            ageDays: progress * Self.synodicMonth,
            illumination: illumination,
            direction: direction,
            nextPrincipalPhase: next.phase,
            nextPrincipalPhaseDate: next.date
        )
    }

    // Kept for the dormant story subsystem until that code is removed.
    func contentDay(for date: Date) -> Int {
        let referenceStartOfDay = calendar.startOfDay(for: referenceNewMoon)
        let currentStartOfDay = calendar.startOfDay(for: date)
        let dayOffset = calendar.dateComponents(
            [.day],
            from: referenceStartOfDay,
            to: currentStartOfDay
        ).day ?? 0
        let normalizedDays = positiveRemainder(Double(dayOffset), modulus: Self.synodicMonth)
        return min(30, Int(floor(normalizedDays)) + 1)
    }

    func phase(forCycleDay day: Int) -> LunarPhase {
        switch min(max(day, 1), 30) {
        case 1...2: .newMoon
        case 3...7: .waxingCrescent
        case 8...10: .firstQuarter
        case 11...14: .waxingGibbous
        case 15...16: .fullMoon
        case 17...21: .waningGibbous
        case 22...24: .lastQuarter
        default: .waningCrescent
        }
    }

    func fragmentContext(for date: Date) -> (cycleDay: Int, phase: LunarPhase) {
        let day = contentDay(for: date)
        return (day, phase(forCycleDay: day))
    }

    private func julianDate(for date: Date) -> Double {
        date.timeIntervalSince1970 / 86_400 + Self.julianUnixEpoch
    }

    private func daysSinceJ2000(for date: Date) -> Double {
        julianDate(for: date) - Self.julianJ2000
    }

    private func solarLongitudeDegrees(daysSinceJ2000 days: Double) -> Double {
        let meanLongitude = normalize(280.46646 + 0.98564736 * days)
        let meanAnomaly = normalize(357.52911 + 0.98560028 * days)

        return normalize(
            meanLongitude
                + 1.914602 * sin(meanAnomaly.radians)
                + 0.019993 * sin((2 * meanAnomaly).radians)
                + 0.000289 * sin((3 * meanAnomaly).radians)
        )
    }

    private func lunarLongitudeDegrees(daysSinceJ2000 days: Double) -> Double {
        let meanLongitude = normalize(218.3164477 + 13.17639648 * days)
        let meanAnomaly = normalize(134.9633964 + 13.06499295 * days)
        let solarMeanAnomaly = normalize(357.5291092 + 0.98560028 * days)
        let elongation = normalize(297.8501921 + 12.19074912 * days)

        return normalize(
            meanLongitude
                + 6.289 * sin(meanAnomaly.radians)
                + 1.274 * sin((2 * elongation - meanAnomaly).radians)
                + 0.658 * sin((2 * elongation).radians)
                + 0.214 * sin((2 * meanAnomaly).radians)
                - 0.186 * sin(solarMeanAnomaly.radians)
                - 0.059 * sin((2 * elongation - 2 * meanAnomaly).radians)
                - 0.057 * sin((2 * elongation - solarMeanAnomaly - meanAnomaly).radians)
                + 0.053 * sin((2 * elongation + meanAnomaly).radians)
                + 0.046 * sin((2 * elongation - solarMeanAnomaly).radians)
                + 0.041 * sin((solarMeanAnomaly - meanAnomaly).radians)
                - 0.035 * sin(elongation.radians)
                - 0.031 * sin((solarMeanAnomaly + meanAnomaly).radians)
        )
    }

    private func lunarElongationDegrees(at date: Date) -> Double {
        let days = daysSinceJ2000(for: date)
        return normalize(
            lunarLongitudeDegrees(daysSinceJ2000: days)
                - solarLongitudeDegrees(daysSinceJ2000: days)
        )
    }

    private func nextPrincipalPhase(
        after date: Date,
        progress: Double
    ) -> (phase: PrincipalMoonPhase, date: Date) {
        let candidates: [(progress: Double, phase: PrincipalMoonPhase)] = [
            (0.25, .firstQuarter),
            (0.50, .fullMoon),
            (0.75, .lastQuarter),
            (1.00, .newMoon),
        ]
        let target = candidates.first(where: { $0.progress > progress + 1e-8 })
            ?? candidates[0]
        let targetProgress = target.progress.truncatingRemainder(dividingBy: 1)
        let deltaProgress = target.progress > progress
            ? target.progress - progress
            : 1 - progress + target.progress
        var estimate = date.addingTimeInterval(
            deltaProgress * Self.synodicMonth * 86_400
        )

        for _ in 0..<8 {
            let error = signedAngularError(
                current: lunarElongationDegrees(at: estimate),
                target: targetProgress * 360
            )
            let derivative = angularVelocityDegreesPerSecond(at: estimate)
            guard derivative.isFinite, abs(derivative) > 1e-8 else { break }
            estimate = estimate.addingTimeInterval(-error / derivative)
        }

        if estimate <= date {
            estimate = estimate.addingTimeInterval(Self.synodicMonth * 86_400)
        }

        return (target.phase, estimate)
    }

    private func angularVelocityDegreesPerSecond(at date: Date) -> Double {
        let interval: TimeInterval = 1_800
        let before = lunarElongationDegrees(at: date.addingTimeInterval(-interval))
        let after = lunarElongationDegrees(at: date.addingTimeInterval(interval))
        return signedAngularError(current: after, target: before) / (2 * interval)
    }

    private func signedAngularError(current: Double, target: Double) -> Double {
        var difference = normalize(current - target)
        if difference > 180 {
            difference -= 360
        }
        return difference
    }

    private func normalize(_ angle: Double) -> Double {
        positiveRemainder(angle, modulus: 360)
    }

    private func positiveRemainder(_ value: Double, modulus: Double) -> Double {
        let remainder = value.truncatingRemainder(dividingBy: modulus)
        return remainder < 0 ? remainder + modulus : remainder
    }
}

private extension Double {
    var radians: Double {
        self * .pi / 180
    }
}
