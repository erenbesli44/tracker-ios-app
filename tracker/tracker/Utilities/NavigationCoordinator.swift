import SwiftUI
import Observation

@MainActor
@Observable
final class NavigationCoordinator {
    var path = NavigationPath()

    func push(_ value: some Hashable) {
        path.append(value)
    }

    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    func popToRoot() {
        path = NavigationPath()
    }
}
