import AppIntents

public struct SharedPetIntentsPackage: AppIntentsPackage {
    public init() {}
}

public struct FeedPetIntent: LiveActivityIntent {
    public static var title: LocalizedStringResource = "Погодувати"
    public static var description = IntentDescription("Нагодувати острівного персонажа")
    public static var openAppWhenRun: Bool = false

    public init() {}

    public func perform() async throws -> some IntentResult {
        await PetActivityManager.perform(.feed)
        return .result()
    }
}

public struct PlayWithPetIntent: LiveActivityIntent {
    public static var title: LocalizedStringResource = "Погратися"
    public static var description = IntentDescription("Погратися з острівним персонажем")
    public static var openAppWhenRun: Bool = false

    public init() {}

    public func perform() async throws -> some IntentResult {
        await PetActivityManager.perform(.play)
        return .result()
    }
}

public struct SleepPetIntent: LiveActivityIntent {
    public static var title: LocalizedStringResource = "Спати"
    public static var description = IntentDescription("Вкласти острівного персонажа спати")
    public static var openAppWhenRun: Bool = false

    public init() {}

    public func perform() async throws -> some IntentResult {
        await PetActivityManager.perform(.sleep)
        return .result()
    }
}

public struct PetPetIntent: AppIntent {
    public static var title: LocalizedStringResource = "Погладити персонажа"
    public static var description = IntentDescription("Погладити острівного персонажа")
    public static var openAppWhenRun: Bool = false

    public init() {}

    public func perform() async throws -> some IntentResult {
        await PetActivityManager.perform(.pet)
        return .result()
    }
}
