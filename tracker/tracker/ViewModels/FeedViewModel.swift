import Foundation

@Observable
final class FeedViewModel {
    var state: LoadingState<[FeedItem]> = .idle
    var isLoadingMore = false
    private(set) var hasMore = false

    private let channelId: Int?
    private let pageSize = 15

    private var currentPage = 0
    private var totalPages = 1
    private var channelDict: [Int: Channel] = [:]
    private var topicDict: [Int: Topic] = [:]

    init(channelId: Int? = nil) {
        self.channelId = channelId
    }

    func load() async {
        if case .loaded = state { } else { state = .loading }
        currentPage = 0
        totalPages = 1
        hasMore = false
        do {
            async let topicsTask = APIClient.shared.fetch([Topic].self, path: APIPath.topics)
            if let channelId {
                async let channelTask = APIClient.shared.fetch(Channel.self, path: APIPath.channel(channelId: channelId))
                let (topics, channel) = try await (topicsTask, channelTask)
                topicDict = Dictionary(uniqueKeysWithValues: topics.map { ($0.id, $0) })
                channelDict = [channel.id: channel]
            } else {
                async let channelsTask = APIClient.shared.fetch([Channel].self, path: APIPath.channels)
                let (topics, channels) = try await (topicsTask, channelsTask)
                topicDict = Dictionary(uniqueKeysWithValues: topics.map { ($0.id, $0) })
                channelDict = Dictionary(uniqueKeysWithValues: channels.map { ($0.id, $0) })
            }
            try await fetchNextPage()
        } catch {
            state = .error(error.localizedDescription)
        }
    }

    func loadMore() async {
        guard !isLoadingMore, hasMore else { return }
        isLoadingMore = true
        defer { isLoadingMore = false }
        do {
            try await fetchNextPage()
        } catch {
            // non-fatal: existing items stay visible
        }
    }

    private func fetchNextPage() async throws {
        let nextPage = currentPage + 1
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "page", value: String(nextPage)),
            URLQueryItem(name: "size", value: String(pageSize))
        ]
        if let channelId {
            queryItems.append(URLQueryItem(name: "channel_id", value: String(channelId)))
        }

        let response = try await APIClient.shared.fetch(
            PaginatedResponse<Video>.self,
            path: APIPath.videos,
            queryItems: queryItems
        )

        currentPage = response.page
        totalPages = response.pages
        hasMore = currentPage < totalPages

        let newItems = try await enrich(response.items)

        switch state {
        case .loaded(let existing):
            state = newItems.isEmpty ? .loaded(existing) : .loaded(existing + newItems)
        default:
            state = newItems.isEmpty ? .empty : .loaded(newItems)
        }
    }

    private func enrich(_ videos: [Video]) async throws -> [FeedItem] {
        let topicDict = self.topicDict
        let channelDict = self.channelDict
        let orderedIds = videos.map { $0.id }

        var feedItems: [FeedItem] = []
        try await withThrowingTaskGroup(of: FeedItem?.self) { group in
            for video in videos {
                group.addTask {
                    async let summaryTask = Self.fetchSummary(videoId: video.id)
                    async let classTask = Self.fetchClassification(videoId: video.id)
                    let (summary, classification) = await (summaryTask, classTask)

                    guard summary?.shortSummary != nil || !(classification?.mentions ?? []).isEmpty || !(summary?.highlights ?? []).isEmpty else {
                        return nil
                    }
                    guard let channel = channelDict[video.channelId ?? -1] else { return nil }

                    let resolved = (classification?.mentions ?? []).compactMap { mention -> ResolvedTopic? in
                        guard let topic = topicDict[mention.topicId] else { return nil }
                        return ResolvedTopic(
                            topicId: mention.topicId,
                            mentionId: mention.id,
                            name: topic.name,
                            sentiment: mention.sentiment,
                            summary: mention.summary,
                            keyLevels: mention.keyLevels ?? [],
                            confidence: mention.confidence
                        )
                    }

                    return FeedItem(
                        channel: channel,
                        video: video,
                        shortSummary: summary?.shortSummary,
                        longSummary: summary?.longSummary,
                        highlights: summary?.highlights ?? [],
                        topics: resolved
                    )
                }
            }
            for try await item in group {
                if let item { feedItems.append(item) }
            }
        }

        // Restore API order (TaskGroup delivers out of order)
        feedItems.sort {
            (orderedIds.firstIndex(of: $0.id) ?? Int.max) < (orderedIds.firstIndex(of: $1.id) ?? Int.max)
        }
        return feedItems
    }

    private static func fetchSummary(videoId: Int) async -> VideoSummary? {
        try? await APIClient.shared.fetch(VideoSummary.self, path: APIPath.videoSummary(videoId: videoId))
    }

    private static func fetchClassification(videoId: Int) async -> Classification? {
        try? await APIClient.shared.fetch(Classification.self, path: APIPath.videoClassification(videoId: videoId))
    }
}
