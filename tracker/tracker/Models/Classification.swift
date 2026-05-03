import Foundation

nonisolated struct Classification: Codable, Hashable, Sendable {
    let videoId: Int
    let totalMentions: Int
    let mentions: [TopicMention]
}

nonisolated struct TopicMention: Codable, Identifiable, Hashable, Sendable {
    let id: Int
    let videoId: Int
    let channelId: Int?
    let personId: Int?
    let topicId: Int
    let summary: String
    let sentiment: String?
    let keyLevels: [String]?
    let startTime: String?
    let endTime: String?
    let confidence: Double
}
