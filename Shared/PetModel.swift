import ActivityKit
import Foundation

public enum PetMood: String, Codable, Hashable, Sendable {
    case hungry, eating, happy, playing, sleeping, bored

    public var title: String {
        switch self {
        case .hungry: return "Персонаж голодний"
        case .eating: return "Персонаж обідає"
        case .happy: return "Персонаж щасливий"
        case .playing: return "Персонаж грається"
        case .sleeping: return "Персонаж спить"
        case .bored: return "Персонаж нудьгує"
        }
    }
}

public struct PetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable, Sendable {
        public var mood: PetMood
        public var energy: Int
        public var joy: Int
        public var food: Int
        public var updatedAt: Date
        public var nextChangeAt: Date

        public init(mood: PetMood, energy: Int, joy: Int, food: Int, updatedAt: Date, nextChangeAt: Date) {
            self.mood = mood
            self.energy = min(100, max(0, energy))
            self.joy = min(100, max(0, joy))
            self.food = min(100, max(0, food))
            self.updatedAt = updatedAt
            self.nextChangeAt = nextChangeAt
        }

        public static func initial(at date: Date = .now) -> Self {
            Self(mood: .happy, energy: 80, joy: 80, food: 80,
                 updatedAt: date, nextChangeAt: date.addingTimeInterval(600))
        }

        public func current(at date: Date = .now) -> Self {
            let hours = max(0, date.timeIntervalSince(updatedAt)) / 3600
            let energy = max(0, self.energy - Int(hours * 3))
            let joy = max(0, self.joy - Int(hours * 4))
            let food = max(0, self.food - Int(hours * 6))
            let mood: PetMood
            if date < nextChangeAt {
                mood = self.mood
            } else if food < 30 {
                mood = .hungry
            } else if energy < 25 {
                mood = .sleeping
            } else if joy < 35 {
                mood = .bored
            } else {
                mood = .happy
            }
            let nextChange = date < nextChangeAt ? nextChangeAt : date.addingTimeInterval(600)
            return Self(mood: mood, energy: energy, joy: joy, food: food,
                        updatedAt: updatedAt, nextChangeAt: nextChange)
        }

        public func applying(_ action: PetAction, at date: Date = .now) -> Self {
            let state = current(at: date)
            switch action {
            case .feed:
                return Self(mood: .eating, energy: state.energy, joy: min(100, state.joy + 5),
                            food: min(100, state.food + 30), updatedAt: date,
                            nextChangeAt: date.addingTimeInterval(240))
            case .play:
                return Self(mood: .playing, energy: max(0, state.energy - 8),
                            joy: min(100, state.joy + 25), food: max(0, state.food - 5),
                            updatedAt: date, nextChangeAt: date.addingTimeInterval(300))
            case .sleep:
                return Self(mood: .sleeping, energy: min(100, state.energy + 35),
                            joy: state.joy, food: state.food, updatedAt: date,
                            nextChangeAt: date.addingTimeInterval(600))
            case .pet:
                return Self(mood: .happy, energy: state.energy,
                            joy: min(100, state.joy + 20), food: state.food,
                            updatedAt: date, nextChangeAt: date.addingTimeInterval(300))
            }
        }

        public var nextMoodTitle: String {
            if food < 30 { return "голодний" }
            if energy < 25 { return "сонний" }
            if joy < 35 { return "нудьгує" }
            return "щасливий"
        }
    }

    public var name: String

    public init(name: String) { self.name = name }
}

public enum PetAction: Sendable {
    case feed, play, sleep, pet
}
