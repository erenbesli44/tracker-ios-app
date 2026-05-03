import Foundation
import Observation

@MainActor
@Observable
final class VideoDetailViewModel {
    var item: FeedItem
    var isEnriching = false

    private static var cache: [Int: FeedItem] = [:]

    init(item: FeedItem) {
        if let cached = Self.cache[item.video.id] {
            self.item = cached
        } else {
            self.item = item
        }
    }

    func loadIfNeeded() async {
        guard needsEnrichment(item) else { return }

        isEnriching = true
        defer { isEnriching = false }

        async let summaryTask: VideoSummary? = try? APIClient.shared.fetch(
            VideoSummary.self, path: APIPath.videoSummary(videoId: item.video.id)
        )
        async let classificationTask: Classification? = try? APIClient.shared.fetch(
            Classification.self, path: APIPath.videoClassification(videoId: item.video.id)
        )
        async let topicsTask: [Topic]? = try? APIClient.shared.fetch(
            [Topic].self, path: APIPath.topics
        )

        let (summary, classification, topics) = await (summaryTask, classificationTask, topicsTask)

        let topicDict = Dictionary(uniqueKeysWithValues: (topics ?? []).map { ($0.id, $0) })
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

        let enriched = FeedItem(
            channel: item.channel,
            video: item.video,
            shortSummary: summary?.shortSummary ?? item.shortSummary,
            longSummary: summary?.longSummary ?? item.longSummary,
            highlights: summary?.highlights ?? item.highlights,
            topics: resolved.isEmpty ? item.topics : resolved
        )
        item = enriched
        Self.cache[enriched.video.id] = enriched
    }

    private func needsEnrichment(_ item: FeedItem) -> Bool {
        item.longSummary == nil || item.highlights.isEmpty || item.topics.isEmpty
    }
}
