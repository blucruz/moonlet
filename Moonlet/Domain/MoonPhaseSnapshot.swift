import Foundation

enum MoonPhaseDirection: Equatable, Sendable {
    case waxing
    case waning
}

enum PrincipalMoonPhase: CaseIterable, Equatable, Sendable {
    case newMoon
    case firstQuarter
    case fullMoon
    case lastQuarter

    var localizationKey: String {
        switch self {
        case .newMoon: "phase.newMoon"
        case .firstQuarter: "phase.firstQuarter"
        case .fullMoon: "phase.fullMoon"
        case .lastQuarter: "phase.lastQuarter"
        }
    }

    var displayName: String {
        switch self {
        case .newMoon: "新月"
        case .firstQuarter: "上弦月"
        case .fullMoon: "满月"
        case .lastQuarter: "下弦月"
        }
    }
}

struct MoonPhaseSnapshot: Equatable, Sendable {
    let date: Date
    let phase: LunarPhase
    let cycleProgress: Double
    let ageDays: Double
    let illumination: Double
    let direction: MoonPhaseDirection
    let nextPrincipalPhase: PrincipalMoonPhase
    let nextPrincipalPhaseDate: Date

    var timeUntilNextPrincipalPhase: TimeInterval {
        nextPrincipalPhaseDate.timeIntervalSince(date)
    }

    init?(
        date: Date,
        phase: LunarPhase,
        cycleProgress: Double,
        ageDays: Double,
        illumination: Double,
        direction: MoonPhaseDirection,
        nextPrincipalPhase: PrincipalMoonPhase,
        nextPrincipalPhaseDate: Date
    ) {
        guard cycleProgress.isFinite,
              cycleProgress >= 0,
              cycleProgress < 1,
              ageDays.isFinite,
              ageDays >= 0,
              illumination.isFinite,
              illumination >= 0,
              illumination <= 1,
              nextPrincipalPhaseDate > date else {
            return nil
        }

        self.date = date
        self.phase = phase
        self.cycleProgress = cycleProgress
        self.ageDays = ageDays
        self.illumination = illumination
        self.direction = direction
        self.nextPrincipalPhase = nextPrincipalPhase
        self.nextPrincipalPhaseDate = nextPrincipalPhaseDate
    }
}
