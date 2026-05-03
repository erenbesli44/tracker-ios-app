import Foundation

@Observable
final class ChannelProfileViewModel {
    var state: LoadingState<[TopicOverview]> = .idle
    var channel: Channel

    init(channel: Channel) {
        self.channel = channel
    }

    func load() async {
        if case .loaded = state { } else {
            state = .loading
        }
        do {
            async let overviewTask = APIClient.shared.fetch(
                ChannelOverview.self,
                path: APIPath.channelTopicsOverview(channelId: channel.id)
            )
            async let channelTask: Channel? = channel.channelMetadata == nil
                ? try? APIClient.shared.fetch(Channel.self, path: APIPath.channel(channelId: channel.id))
                : nil

            let (overview, fullChannel) = try await (overviewTask, channelTask)

            if let fullChannel {
                channel = fullChannel
            }

            let topics = overview.topics.sorted { lhs, rhs in
                let l = DateFormatting.parse(lhs.latestPublishedAt) ?? .distantPast
                let r = DateFormatting.parse(rhs.latestPublishedAt) ?? .distantPast
                return l > r
            }
            state = topics.isEmpty ? .empty : .loaded(topics)
        } catch {
            state = .error(error.localizedDescription)
        }
    }
}
