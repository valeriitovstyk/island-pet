import ActivityKit
import Foundation

@MainActor
public enum PetActivityManager {
    public static var isAvailable: Bool {
        ActivityAuthorizationInfo().areActivitiesEnabled
    }

    public static var isRunning: Bool {
        Activity<PetAttributes>.activities.contains {
            $0.activityState == .active || $0.activityState == .stale
        }
    }

    public static func refreshOnOpen() async -> PetAttributes.ContentState {
        var state = PetStore.load()
        state.updatedAt = .now
        let activities = Activity<PetAttributes>.activities
        if let current = activities.first(where: { $0.activityState == .active }) {
            await current.update(ActivityContent(state: state, staleDate: state.nextChangeAt))
        } else if PetStore.autoRestart {
            for stale in activities where stale.activityState == .stale {
                await stale.end(nil, dismissalPolicy: .immediate)
            }
            await start(with: state)
        }
        return state
    }

    public static func start(with state: PetAttributes.ContentState? = nil) async {
        guard isAvailable, !isRunning else { return }
        let current = state ?? PetStore.load()
        do {
            _ = try Activity.request(attributes: PetAttributes(name: "Острівний персонаж"),
                                     content: ActivityContent(state: current, staleDate: current.nextChangeAt),
                                     pushType: nil)
        } catch {
            // The app remains usable when Live Activities are unavailable.
        }
    }

    public static func stop() async {
        for activity in Activity<PetAttributes>.activities {
            await activity.end(nil, dismissalPolicy: .immediate)
        }
    }

    @discardableResult
    public static func perform(_ action: PetAction) async -> PetAttributes.ContentState {
        let state = PetStore.loadRaw().applying(action)
        PetStore.save(state)
        for activity in Activity<PetAttributes>.activities where activity.activityState == .active || activity.activityState == .stale {
            await activity.update(ActivityContent(state: state, staleDate: state.nextChangeAt))
        }
        return state
    }
}
