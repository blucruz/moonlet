import SwiftUI

@main
struct MoonletApp: App {
    @State private var appModel = AppModel.bootstrap()

    var body: some Scene {
        WindowGroup {
            Text(appModel.currentRoute.accessibilityLabel)
        }
    }
}
