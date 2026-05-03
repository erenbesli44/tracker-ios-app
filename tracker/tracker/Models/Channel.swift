import Foundation

nonisolated struct Channel: Codable, Identifiable, Hashable, Sendable {
    let id: Int
    let name: String
    let slug: String
    let platform: String
    let channelHandle: String?
    let youtubeChannelId: String?
    let channelUrl: String?
    let bio: String?
    let primaryTopicSlug: String?
    let expectedSubtopics: [String]?
    let legacyPersonId: Int?
    let createdAt: String
    let updatedAt: String?
    let channelMetadata: ChannelMetadata?
}

nonisolated struct ChannelMetadata: Codable, Hashable, Sendable {
    let youtubeChannelId: String?
    let channelUrl: String?
    let channelName: String?
    let uploaderId: String?
    let uploaderUrl: String?
    let subscriberCount: Int?
    let viewCount: Int?
    let videoCount: Int?
    let isVerified: Bool?
    let description: String?
    let tags: [String]?
    let avatarUrl: String?
    let bannerUrl: String?
    let thumbnails: [ChannelThumbnail]?
    let fetchedAt: String?
}

nonisolated struct ChannelThumbnail: Codable, Hashable, Sendable {
    let id: String?
    let url: String?
    let width: Int?
    let height: Int?
}
