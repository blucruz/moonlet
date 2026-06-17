struct MotionProfile: Equatable {
    let fogSpeed: Double
    let parallaxDepth: Double
    let cameraDrift: Double

    static func forPhase(_ phase: LunarPhase) -> MotionProfile {
        switch phase {
        case .newMoon:
            MotionProfile(fogSpeed: 0.15, parallaxDepth: 0.2, cameraDrift: 0.1)
        case .fullMoon:
            MotionProfile(fogSpeed: 0.35, parallaxDepth: 0.5, cameraDrift: 0.25)
        default:
            MotionProfile(fogSpeed: 0.22, parallaxDepth: 0.35, cameraDrift: 0.18)
        }
    }
}
