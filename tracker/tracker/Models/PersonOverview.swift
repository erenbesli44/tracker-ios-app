import Foundation

nonisolated struct ChannelOverview: Codable, Sendable {
    let channelId: Int?
    let personId: Int?
    let topics: [TopicOverview]
}

nonisolated struct TopicOverview: Codable, Identifiable, Hashable, Sendable {
    let topic: TopicInfo
    let mentionCount: Int
    let latestSentiment: String?
    let latestSummary: String
    let latestPublishedAt: String?
    let latestVideoUrl: String?

    var id: Int { topic.id }
}

nonisolated struct TopicInfo: Codable, Hashable, Sendable {
    let id: Int
    let name: String
    let slug: String
    let parentId: Int?
    let parentName: String?
}
