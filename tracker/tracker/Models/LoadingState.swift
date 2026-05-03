import Foundation

nonisolated enum LoadingState<T: Sendable>: Sendable {
    case idle
    case loading
    case loaded(T)
    case empty
    case error(String)
}
