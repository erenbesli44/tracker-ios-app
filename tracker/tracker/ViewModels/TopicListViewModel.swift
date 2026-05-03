import Foundation

@Observable
final class TopicListViewModel {
    var state: LoadingState<[Topic]> = .idle

    func load() async {
        let silentRefresh: Bool
        if case .loaded = state { silentRefresh = true } else { silentRefresh = false; state = .loading }
        do {
            let topics = try await APIClient.shared.fetch([Topic].self, path: APIPath.topics)
            let subtopics = topics.filter { $0.parentId != nil }
            state = subtopics.isEmpty ? .empty : .loaded(subtopics)
        } catch {
            if silentRefresh { return }
            if error is CancellationError || (error as? URLError)?.code == .cancelled {
                state = .idle
                return
            }
            state = .error(error.localizedDescription)
        }
    }
}
