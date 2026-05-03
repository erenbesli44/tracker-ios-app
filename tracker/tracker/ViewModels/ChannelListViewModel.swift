import Foundation

@Observable
final class ChannelListViewModel {
    var state: LoadingState<[Channel]> = .idle

    func loadChannels() async {
        let silentRefresh: Bool
        if case .loaded = state { silentRefresh = true } else { silentRefresh = false; state = .loading }
        do {
            let channels = try await APIClient.shared.fetch(
                [Channel].self,
                path: APIPath.channels
            )
            state = channels.isEmpty ? .empty : .loaded(channels)
        } catch {
            if silentRefresh { return }
            state = .error(error.localizedDescription)
        }
    }
}
