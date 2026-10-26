import ActivityKit
import AppIntents
import Shared
import SwiftUI
import WidgetKit

@main
struct IslandPetWidgetBundle: WidgetBundle {
    var body: some Widget {
        IslandPetActivityWidget()
    }
}

struct IslandPetActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: PetAttributes.self) { context in
            PetActivityCard(state: context.state)
                .widgetURL(URL(string: "islandpet://open"))
                .activityBackgroundTint(Color(red: 0.08, green: 0.09, blue: 0.12))
                .activitySystemActionForegroundColor(.white)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    PetView(mood: context.state.mood, size: 54, animated: false)
                }
                DynamicIslandExpandedRegion(.center) {
                    Text(context.state.mood.title).font(.headline)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    VStack(spacing: 8) {
                        Text("Наступний настрій — \(context.state.nextMoodTitle)")
                            .font(.caption)
                        actionButtons
                    }
                }
            } compactLeading: {
                PetView(mood: context.state.mood, size: 28, animated: false)
            } compactTrailing: {
                Text(timerInterval: Date.now...max(Date.now.addingTimeInterval(1), context.state.nextChangeAt), countsDown: true)
                    .font(.caption2.monospacedDigit())
            } minimal: {
                PetView(mood: context.state.mood, size: 26, animated: false)
            }
            .widgetURL(URL(string: "islandpet://open"))
        }
    }
}

struct IslandPetWidgetIntentsPackage: AppIntentsPackage {
    static var includedPackages: [any AppIntentsPackage.Type] {
        [SharedPetIntentsPackage.self]
    }
}

private struct PetActivityCard: View {
    let state: PetAttributes.ContentState

    var body: some View {
        VStack(spacing: 10) {
            HStack(spacing: 12) {
                PetView(mood: state.mood, size: 62, animated: false)
                VStack(alignment: .leading, spacing: 3) {
                    Text(state.mood.title).font(.headline).contentTransition(.opacity)
                    Text("Наступний настрій — \(state.nextMoodTitle)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(timerInterval: Date.now...max(Date.now.addingTimeInterval(1), state.nextChangeAt), countsDown: true)
                        .font(.caption.monospacedDigit())
                    ProgressView(timerInterval: state.updatedAt...state.nextChangeAt, countsDown: false)
                        .tint(PetPalette.accent)
                }
            }
            actionButtons
        }
        .padding(12)
    }
}

private var actionButtons: some View {
    HStack(spacing: 8) {
        Button(intent: FeedPetIntent()) {
            Label("Погодувати", systemImage: "fork.knife")
        }
        Button(intent: PlayWithPetIntent()) {
            Label("Погратися", systemImage: "gamecontroller")
        }
        Button(intent: SleepPetIntent()) {
            Label("Спати", systemImage: "moon.zzz")
        }
    }
    .font(.caption2.bold())
    .buttonStyle(.plain)
    .labelStyle(.titleOnly)
    .frame(maxWidth: .infinity)
}
