import AppIntents
import Shared
import SwiftUI

@main
struct IslandPetApp: App {
    var body: some Scene {
        WindowGroup {
            PetHomeView()
        }
    }
}

struct PetShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(intent: PetPetIntent(),
                    phrases: ["Погладити персонажа в \(.applicationName)"],
                    shortTitle: "Погладити", systemImageName: "hand.tap")
        AppShortcut(intent: FeedPetIntent(),
                    phrases: ["Погодувати персонажа в \(.applicationName)"],
                    shortTitle: "Погодувати", systemImageName: "fork.knife")
        AppShortcut(intent: PlayWithPetIntent(),
                    phrases: ["Погратися з персонажем в \(.applicationName)"],
                    shortTitle: "Погратися", systemImageName: "gamecontroller")
        AppShortcut(intent: SleepPetIntent(),
                    phrases: ["Вкласти персонажа спати в \(.applicationName)"],
                    shortTitle: "Спати", systemImageName: "moon.zzz")
    }
}

struct IslandPetIntentsPackage: AppIntentsPackage {
    static var includedPackages: [any AppIntentsPackage.Type] {
        [SharedPetIntentsPackage.self]
    }
}
