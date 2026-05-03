import Foundation

nonisolated struct Video: Codable, Identifiable, Hashable, Sendable {
    let id: Int
    let personId: Int?
    let channelId: Int?
    let platform: String
    let videoUrl: String
    let videoId: String
    let title: String?
    let publishedAt: String?
    let duration: Int?
    let createdAt: String
}
