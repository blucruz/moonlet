import Observation

@Observable
final class AppModel {
    var currentRoute: AppRoute

    init(currentRoute: AppRoute) {
        self.currentRoute = currentRoute
    }

    static func bootstrap() -> AppModel {
        AppModel(currentRoute: .dailyScene)
    }
}
