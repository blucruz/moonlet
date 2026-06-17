import SwiftUI

@main
struct MoonletApp: App {
    @State private var appModel = AppModel.bootstrap()

    var body: some Scene {
        WindowGroup {
            ZStack {
                ScenePlayerView(
                    model: ScenePlaybackViewModel(fragment: appModel.currentFragment)
                )
                .overlay(alignment: .topLeading) {
                    DailySceneOverlay(fragment: appModel.currentFragment)
                }
                .contentShape(Rectangle())
                .onTapGesture(count: 3) {
                    appModel.toggleCalendarPresentation()
                }
                .accessibilityIdentifier("daily-scene-root")

                if appModel.isCalendarPresented {
                    MoonCalendarView(
                        fragments: appModel.cycleFragments,
                        currentCycleDay: appModel.currentCycleDay
                    )
                    .transition(.opacity)
                    .zIndex(1)
                }
            }
            .animation(.easeInOut(duration: 0.2), value: appModel.isCalendarPresented)
        }
    }
}

private struct DailySceneOverlay: View {
    let fragment: StoryFragment

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Tonight")
                .font(.caption.weight(.medium))
                .foregroundStyle(.white.opacity(0.72))

            Text(fragment.title)
                .font(.title2.weight(.semibold))
                .foregroundStyle(.white)

            if let caption = fragment.caption, caption.isEmpty == false {
                Text(caption)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.84))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
