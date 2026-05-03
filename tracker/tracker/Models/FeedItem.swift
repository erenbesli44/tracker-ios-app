import Foundation

nonisolated struct FeedItem: Identifiable, Hashable, Sendable {
    let channel: Channel
    let video: Video
    let shortSummary: String?
    let longSummary: String?
    let highlights: [String]
    let topics: [ResolvedTopic]

    var id: Int { video.id }
}

nonisolated struct ResolvedTopic: Identifiable, Hashable, Sendable {
    let topicId: Int
    let mentionId: Int
    let name: String
    let sentiment: String?
    let summary: String?
    let keyLevels: [String]
    let confidence: Double?

    var id: Int { mentionId }
}
