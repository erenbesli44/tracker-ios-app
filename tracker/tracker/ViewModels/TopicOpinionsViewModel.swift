import Foundation

@Observable
final class TopicOpinionsViewModel {
    let topic: Topic
    var state: LoadingState<TopicOpinionsResponse> = .idle
    init(topic: Topic) {
        self.topic = topic
    }

    private func sortedResponse(_ response: TopicOpinionsResponse) -> TopicOpinionsResponse {
        let sortedGroups = response.channelOpinions
            .map { group in
                let sortedEntries = group.entries.sorted {
                    DateFormatting.parse($0.publishedAt ?? "") ?? .distantPast >
                    DateFormatting.parse($1.publishedAt ?? "") ?? .distantPast
                }
                return ChannelOpinionGroup(
                    channelId: group.channelId,
                    channelName: group.channelName,
                    channelSlug: group.channelSlug,
                    channelHandle: group.channelHandle,
                    avatarUrl: group.avatarUrl,
                    mentionCount: group.mentionCount,
                    latestSentiment: group.latestSentiment,
                    entries: sortedEntries
                )
            }
            .sorted {
                let l = $0.entries.first.flatMap { DateFormatting.parse($0.publishedAt ?? "") } ?? .distantPast
                let r = $1.entries.first.flatMap { DateFormatting.parse($0.publishedAt ?? "") } ?? .distantPast
                return l > r
            }
        return TopicOpinionsResponse(topic: response.topic, totalChannels: response.totalChannels, channelOpinions: sortedGroups)
    }

    func load() async {
        state = .loading
        do {
            let response = try await APIClient.shared.fetch(
                TopicOpinionsResponse.self,
                path: APIPath.topicOpinions(slug: topic.slug),
                queryItems: [
                    URLQueryItem(name: "limit", value: "5")
                ]
            )
            let sorted = sortedResponse(response)
            state = sorted.totalChannels == 0 ? .empty : .loaded(sorted)
        } catch {
            if error is CancellationError || (error as? URLError)?.code == .cancelled {
                state = .idle
                return
            }
            state = .error(error.localizedDescription)
        }
    }
}
