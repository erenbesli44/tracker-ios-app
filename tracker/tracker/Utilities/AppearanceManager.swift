import Foundation
import Observation

@Observable
final class AppearanceManager {
    static let shared = AppearanceManager()

    var appearance: AppAppearance {
        didSet { UserDefaults.standard.set(appearance.rawValue, forKey: "app_appearance") }
    }

    private init() {
        let stored = UserDefaults.standard.string(forKey: "app_appearance") ?? "system"
        self.appearance = AppAppearance(rawValue: stored) ?? .system
    }
}
