import Foundation

public enum PetStore {
    private static let stateKey = "petState"
    private static let autoRestartKey = "autoRestart"

    private static var defaults: UserDefaults {
        let prefix = Bundle.main.bundleIdentifier?
            .replacingOccurrences(of: ".islandpet.widget", with: "")
            .replacingOccurrences(of: ".islandpet", with: "") ?? "com.example"
        return UserDefaults(suiteName: "group.\(prefix).islandpet") ?? .standard
    }

    public static func loadRaw(at date: Date = .now) -> PetAttributes.ContentState {
        guard let data = defaults.data(forKey: stateKey),
              let state = try? JSONDecoder().decode(PetAttributes.ContentState.self, from: data) else {
            return .initial(at: date)
        }
        return state
    }

    public static func load(at date: Date = .now) -> PetAttributes.ContentState {
        loadRaw(at: date).current(at: date)
    }

    public static func save(_ state: PetAttributes.ContentState) {
        guard let data = try? JSONEncoder().encode(state) else { return }
        defaults.set(data, forKey: stateKey)
    }

    public static var autoRestart: Bool {
        get { defaults.object(forKey: autoRestartKey) as? Bool ?? true }
        set { defaults.set(newValue, forKey: autoRestartKey) }
    }
}
