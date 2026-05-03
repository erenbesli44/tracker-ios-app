import Foundation

nonisolated enum Secrets {
    static let trackerAPIKey: String = {
        guard let value = Bundle.main.object(forInfoDictionaryKey: "TrackerAPIKey") as? String,
              !value.isEmpty,
              value != "$(TRACKER_API_KEY)",
              value != "YOUR_API_KEY_HERE" else {
            fatalError("TrackerAPIKey missing. Copy Secrets.sample.xcconfig to Secrets.xcconfig, set TRACKER_API_KEY, and wire the xcconfig in Xcode (Project → Info → Configurations).")
        }
        return value
    }()
}
