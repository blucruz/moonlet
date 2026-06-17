import SwiftUI

@main
struct MoonletApp: App {
    @State private var appModel = AppModel.bootstrap()

    var body: some Scene {
        WindowGroup {
            MoonletAppView(appModel: appModel)
        }
    }
}

private struct MoonletAppView: View {
    @Bindable var appModel: AppModel

    var body: some View {
        ScenePlayerView(model: appModel.playbackModel)
            .overlay(alignment: .topLeading) {
                DailySceneOverlay(
                    routeLabel: appModel.currentRoute.accessibilityLabel,
                    fragment: appModel.currentFragment
                )
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 20)
                    .onEnded { value in
                        let isDownwardReveal = value.translation.height > 36 &&
                            abs(value.translation.height) > abs(value.translation.width)

                        if isDownwardReveal {
                            appModel.revealCalendar()
                        }
                    }
            )
            .accessibilityElement(children: .contain)
            .accessibilityLabel(appModel.currentRoute.accessibilityLabel)
            .accessibilityIdentifier("daily-scene-root")
            .sheet(
                isPresented: Binding(
                    get: { appModel.isCalendarPresented },
                    set: { isPresented in
                        if isPresented {
                            appModel.revealCalendar()
                        } else {
                            appModel.dismissCalendar()
                        }
                    }
                )
            ) {
                MoonCalendarView(
                    fragments: appModel.cycleFragments,
                    currentCycleDay: appModel.currentCycleDay,
                    onDismiss: appModel.dismissCalendar
                )
            }
    }
}

private struct DailySceneOverlay: View {
    let routeLabel: String
    let fragment: StoryFragment

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(routeLabel)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.white.opacity(0.9))

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
